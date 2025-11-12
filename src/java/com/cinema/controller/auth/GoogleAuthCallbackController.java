package com.cinema.controller.auth;


import com.cinema.dal.UserDAO;
import com.cinema.entity.User;
import com.cinema.utils.Constants;
import com.cinema.utils.GoogleOAuthHelper;
import com.cinema.utils.SessionUtils;
import java.io.IOException;
import java.sql.Date;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Controller xử lý callback từ Google OAuth
 * Xử lý callback từ Google OAuth và thực hiện đăng nhập/đăng ký
 */
public class GoogleAuthCallbackController extends HttpServlet {

    private UserDAO userDAO = new UserDAO();

    /**
     * Xử lý callback từ Google OAuth sau khi người dùng xác thực
     * 
     * OAuth Callback Flow:
     * 1. Google redirect về URL này với authorization code hoặc error
     * 2. Đổi authorization code lấy access token
     * 3. Sử dụng access token để lấy thông tin người dùng từ Google
     * 4. Kiểm tra người dùng đã tồn tại trong hệ thống chưa
     * 5. Dựa vào action (login/signup) và trạng thái người dùng để quyết định hành động:
     *    - Login + User exists: Đăng nhập
     *    - Login + User not exists: Từ chối, yêu cầu đăng ký
     *    - Signup + User exists: Từ chối, yêu cầu đăng nhập
     *    - Signup + User not exists: Tạo tài khoản mới và đăng nhập
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Bước 1: Lấy authorization code và error từ Google callback
        // Google sẽ gửi code nếu xác thực thành công, hoặc error nếu có lỗi
        String code = request.getParameter("code");
        String error = request.getParameter("error");
        
        // Bước 2: Kiểm tra lỗi từ Google OAuth
        // Nếu có error parameter, có nghĩa là người dùng từ chối hoặc có lỗi xảy ra
        if (error != null) {
            request.setAttribute("error", "Google OAuth error: " + error);
            request.getRequestDispatcher(Constants.JSP_AUTH_LOGIN).forward(request, response);
            return;
        }
        
        // Bước 3: Kiểm tra authorization code có tồn tại không
        // Code là bắt buộc để đổi lấy access token
        if (code == null || code.trim().isEmpty()) {
            request.setAttribute("error", "No authorization code received from Google");
            request.getRequestDispatcher(Constants.JSP_AUTH_LOGIN).forward(request, response);
            return;
        }
        
        try {
            // Bước 4: Đổi authorization code lấy access token
            // Authorization code chỉ có thể sử dụng một lần và có thời gian hết hạn ngắn
            String accessToken = GoogleOAuthHelper.exchangeCodeForToken(code);
            
            // Bước 5: Sử dụng access token để lấy thông tin người dùng từ Google API
            // Thông tin trả về dạng JSON chứa email, name, id, v.v.
            String userInfoJson = GoogleOAuthHelper.getUserInfo(accessToken);
            
            // Bước 6: Trích xuất email và tên từ JSON response
            // Email là bắt buộc để xác định người dùng, name để hiển thị
            String email = GoogleOAuthHelper.extractUserEmail(userInfoJson);
            String name = GoogleOAuthHelper.extractUserName(userInfoJson);
            
            // Bước 7: Kiểm tra có lấy được thông tin cần thiết không
            if (email == null || name == null) {
                request.setAttribute("error", "Failed to retrieve user information from Google");
                request.getRequestDispatcher(Constants.JSP_AUTH_LOGIN).forward(request, response);
                return;
            }
            
            // Bước 8: Lấy action từ session (login hoặc signup)
            // Action này được lưu trong GoogleAuthController trước khi redirect đến Google
            HttpSession session = request.getSession();
            String action = (String) session.getAttribute(Constants.SESSION_OAUTH_ACTION);
            if (action == null) {
                // Nếu không có action trong session, mặc định là đăng nhập
                action = Constants.ACTION_LOGIN;
            }
            
            // Bước 9: Kiểm tra người dùng đã tồn tại trong hệ thống chưa
            // Sử dụng email làm unique identifier
            User existingUser = userDAO.getUserByEmail(email);
            
            // Bước 10: Xử lý dựa trên trạng thái người dùng và action
            if (existingUser != null) {
                // Trường hợp 1: Người dùng đã tồn tại trong hệ thống
                if (Constants.ACTION_LOGIN.equals(action)) {
                    // Sub-case 1.1: Action là LOGIN và người dùng tồn tại - cho phép đăng nhập
                    
                    // Kiểm tra trạng thái tài khoản
                    if (!Constants.STATUS_ACTIVE.equals(existingUser.getAccountStatus())) {
                        // Tài khoản không active - tự động kích hoạt cho người dùng Google OAuth
                        // Điều này cho phép người dùng Google OAuth đăng nhập ngay cả khi tài khoản bị inactive
                        boolean updateSuccess = userDAO.updateUserStatus(existingUser.getUserID(), Constants.STATUS_ACTIVE);
                        if (updateSuccess) {
                            // Làm mới dữ liệu người dùng để có thông tin mới nhất
                            existingUser = userDAO.getUserByEmail(email);
                        } else {
                            // Không thể cập nhật trạng thái - có thể do lỗi database
                            request.setAttribute("error", "Your account is not active. Please contact support.");
                            request.getRequestDispatcher(Constants.JSP_AUTH_LOGIN).forward(request, response);
                            return;
                        }
                    }
                    
                    // Tạo session cho người dùng sau khi xác thực thành công
                    // Sử dụng pattern SessionUtils để đảm bảo tính nhất quán
                    session.setAttribute(SessionUtils.ATTR_USER, existingUser);
                    session.setAttribute(SessionUtils.ATTR_USER_NAME, existingUser.getFullName());
                    session.setAttribute(SessionUtils.ATTR_USER_EMAIL, existingUser.getEmail());
                    session.setAttribute(SessionUtils.ATTR_USER_ROLE, existingUser.getRole());
                    session.setAttribute(SessionUtils.ATTR_USER_ID, existingUser.getUserID());
                    
                    // Chuyển hướng dựa trên vai trò của người dùng
                    if (Constants.ROLE_ADMIN.equals(existingUser.getRole())) {
                        response.sendRedirect(request.getContextPath() + Constants.URL_ADMIN_DASHBOARD);
                    } else {
                        response.sendRedirect(request.getContextPath() + Constants.URL_HOME);
                    }
                } else if (Constants.ACTION_SIGNUP.equals(action)) {
                    // Sub-case 1.2: Action là SIGNUP nhưng người dùng đã tồn tại - từ chối
                    // Không cho phép đăng ký lại với email đã tồn tại
                    request.setAttribute("error", "An account with this Google email already exists. Please use login instead.");
                    request.getRequestDispatcher(Constants.JSP_AUTH_LOGIN).forward(request, response);
                    return;
                }
                
            } else if (Constants.ACTION_SIGNUP.equals(action)) {
                // Trường hợp 2: Người dùng chưa tồn tại và action là SIGNUP - tạo tài khoản mới
                
                // Chuẩn bị dữ liệu mặc định cho các trường Google không cung cấp
                String phoneNumber = null; // Google không cung cấp số điện thoại trong OAuth scope
                String password = "GOOGLE_OAUTH_USER"; // Mật khẩu placeholder - người dùng OAuth không cần mật khẩu
                String gender = "Other"; // Giới tính mặc định vì Google không cung cấp
                String address = null; // Google không cung cấp địa chỉ trong OAuth scope
                Date dateOfBirth = null; // Google không cung cấp ngày sinh trong OAuth scope
                
                // Tạo tài khoản mới với thông tin từ Google
                boolean success = userDAO.addNewUser(
                    name,                          // Tên từ Google
                    email,                         // Email từ Google (unique)
                    phoneNumber,                   // null
                    password,                      // Placeholder password
                    gender,                        // Mặc định "Other"
                    Constants.ROLE_CUSTOMER,       // Vai trò mặc định là Customer
                    address,                       // null
                    dateOfBirth,                   // null
                    Constants.STATUS_ACTIVE        // Trạng thái Active để có thể đăng nhập ngay
                );
                
                if (success) {
                    // Tạo tài khoản thành công - lấy thông tin người dùng vừa tạo
                    User newUser = userDAO.getUserByEmail(email);
                    
                    // Tạo session cho người dùng mới
                    session.setAttribute(SessionUtils.ATTR_USER, newUser);
                    session.setAttribute(SessionUtils.ATTR_USER_NAME, newUser.getFullName());
                    session.setAttribute(SessionUtils.ATTR_USER_EMAIL, newUser.getEmail());
                    session.setAttribute(SessionUtils.ATTR_USER_ROLE, newUser.getRole());
                    session.setAttribute(SessionUtils.ATTR_USER_ID, newUser.getUserID());
                    
                    // Chuyển hướng về trang chủ sau khi đăng ký thành công
                    response.sendRedirect(request.getContextPath() + Constants.URL_HOME);
                } else {
                    // Tạo tài khoản thất bại - có thể do lỗi database
                    request.setAttribute("error", "Failed to create account. Please try again.");
                    request.getRequestDispatcher(Constants.JSP_AUTH_SIGNUP).forward(request, response);
                }
                
            } else {
                // Trường hợp 3: Người dùng chưa tồn tại nhưng action không phải SIGNUP
                if (Constants.ACTION_LOGIN.equals(action)) {
                    // Sub-case 3.1: Action là LOGIN nhưng người dùng chưa tồn tại - từ chối
                    // Yêu cầu người dùng đăng ký trước
                    request.setAttribute("error", "No account found with this Google email. Please sign up first.");
                    request.getRequestDispatcher(Constants.JSP_AUTH_LOGIN).forward(request, response);
                } else {
                    // Sub-case 3.2: Action không hợp lệ - không nên xảy ra trong flow bình thường
                    request.setAttribute("error", "Invalid action. Please try again.");
                    request.getRequestDispatcher(Constants.JSP_AUTH_LOGIN).forward(request, response);
                }
            }
            
        } catch (Exception e) {
            // Xử lý lỗi xác thực
            request.setAttribute("error", "Authentication failed: " + e.getMessage() + ". Please try again.");
            request.getRequestDispatcher(Constants.JSP_AUTH_LOGIN).forward(request, response);
        }
    }
}
