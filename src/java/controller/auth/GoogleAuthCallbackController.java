package controller.auth;

import dal.UserDAO;
import entity.User;
import java.io.IOException;
import java.sql.Date;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Controller xử lý callback từ Google OAuth sau khi người dùng xác thực
 * 
 * Flow xử lý OAuth Callback:
 * 1. Google redirect về servlet này với authorization code (hoặc error)
 * 2. Kiểm tra error parameter - nếu có thì hiển thị lỗi
 * 3. Kiểm tra code parameter - nếu không có thì báo lỗi
 * 4. Đổi authorization code lấy access token (exchangeCodeForToken)
 * 5. Sử dụng access token để lấy thông tin user từ Google API (getUserInfo)
 * 6. Trích xuất email và name từ JSON response
 * 7. Lấy action từ session (login hoặc signup) - được lưu từ GoogleAuthController
 * 8. Kiểm tra user đã tồn tại trong database chưa
 * 9. Xử lý theo 4 trường hợp:
 *    - User tồn tại + action = login: Cho phép đăng nhập, tạo session, redirect theo role
 *    - User tồn tại + action = signup: Từ chối, yêu cầu dùng login
 *    - User không tồn tại + action = signup: Tạo user mới, tạo session, redirect về trang chủ
 *    - User không tồn tại + action = login: Từ chối, yêu cầu đăng ký trước
 * 
 * Endpoint: /GoogleAuthCallback
 */
public class GoogleAuthCallbackController extends HttpServlet {

    /** DAO để thao tác với dữ liệu người dùng trong database */
    private UserDAO userDAO = new UserDAO();

    /**
     * Xử lý callback từ Google OAuth
     * 
     * Flow chi tiết:
     * Bước 1: Kiểm tra error parameter từ Google
     * Bước 2: Kiểm tra authorization code
     * Bước 3: Đổi code lấy access token
     * Bước 4: Lấy thông tin user từ Google
     * Bước 5: Trích xuất email và name
     * Bước 6: Lấy action (login/signup) từ session
     * Bước 7: Kiểm tra user tồn tại trong database
     * Bước 8: Xử lý theo logic phân nhánh
     * 
     * @param request HTTP request chứa code hoặc error từ Google
     * @param response HTTP response để redirect hoặc forward
     * @throws ServletException nếu có lỗi servlet
     * @throws IOException nếu có lỗi I/O
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Bước 1: Lấy authorization code và error từ Google callback
        String code = request.getParameter("code");
        String error = request.getParameter("error");
        
        // Kiểm tra nếu Google trả về error (người dùng từ chối hoặc có lỗi)
        if (error != null) {
            request.setAttribute("error", "Google OAuth error: " + error);
            request.getRequestDispatcher(AuthConstants.JSP_LOGIN).forward(request, response);
            return;
        }
        
        // Bước 2: Kiểm tra authorization code có tồn tại không
        if (code == null || code.trim().isEmpty()) {
            request.setAttribute("error", "No authorization code received from Google");
            request.getRequestDispatcher(AuthConstants.JSP_LOGIN).forward(request, response);
            return;
        }
        
        try {
            // Bước 3: Đổi authorization code lấy access token
            // Gửi POST request đến Google token endpoint với code, client_id, client_secret
            String accessToken = GoogleOAuthHelper.exchangeCodeForToken(code);
            
            // Bước 4: Sử dụng access token để lấy thông tin user từ Google API
            // Gửi GET request đến Google userinfo endpoint với access token
            String userInfoJson = GoogleOAuthHelper.getUserInfo(accessToken);
            
            // Bước 5: Trích xuất email và name từ JSON response
            String email = GoogleOAuthHelper.extractUserEmail(userInfoJson);
            String name = GoogleOAuthHelper.extractUserName(userInfoJson);
            
            // Kiểm tra xem có lấy được thông tin user không
            if (email == null || name == null) {
                request.setAttribute("error", "Failed to retrieve user information from Google");
                request.getRequestDispatcher(AuthConstants.JSP_LOGIN).forward(request, response);
                return;
            }
            
            // Bước 6: Lấy action từ session (login hoặc signup)
            // Action này được lưu từ GoogleAuthController khi người dùng click "Đăng nhập với Google" hoặc "Đăng ký với Google"
            HttpSession session = request.getSession();
            String action = (String) session.getAttribute(AuthConstants.SESSION_OAUTH_ACTION);
            // Nếu không có action trong session, mặc định là login
            if (action == null) {
                action = AuthConstants.ACTION_LOGIN;
            }
            
            // Bước 7: Kiểm tra user đã tồn tại trong database chưa
            User existingUser = userDAO.getUserByEmail(email);
            
            // Bước 8: Xử lý theo logic phân nhánh
            
            // TRƯỜNG HỢP 1: User đã tồn tại trong database
            if (existingUser != null) {
                // TRƯỜNG HỢP 1.1: User tồn tại + action = login → Cho phép đăng nhập
                if (AuthConstants.ACTION_LOGIN.equals(action)) {
                    // Kiểm tra trạng thái tài khoản
                    if (!AuthConstants.STATUS_ACTIVE.equals(existingUser.getAccountStatus())) {
                        // Đối với user đăng nhập qua Google OAuth, tự động kích hoạt tài khoản
                        boolean updateSuccess = userDAO.updateUserStatus(existingUser.getUserID(), AuthConstants.STATUS_ACTIVE);
                        if (updateSuccess) {
                            // Refresh lại thông tin user sau khi update
                            existingUser = userDAO.getUserByEmail(email);
                        } else {
                            // Nếu không update được, hiển thị lỗi
                            request.setAttribute("error", "Your account is not active. Please contact support.");
                            request.getRequestDispatcher(AuthConstants.JSP_LOGIN).forward(request, response);
                            return;
                        }
                    }
                    
                    // Tạo session cho user đã đăng nhập thành công
                    SessionHelper.setUserSession(session, existingUser);
                    
                    // Redirect dựa trên vai trò của user
                    String userRole = existingUser.getRole();
                    if (AuthConstants.ROLE_ADMIN.equals(userRole)) {
                        // Admin redirect đến trang quản lý
                        response.sendRedirect(request.getContextPath() + AuthConstants.PATH_ADMIN_LIST);
                    } else {
                        // Customer và Staff redirect về trang chủ
                        response.sendRedirect(request.getContextPath() + AuthConstants.JSP_INDEX);
                    }
                } 
                // TRƯỜNG HỢP 1.2: User tồn tại + action = signup → Từ chối, yêu cầu dùng login
                else if (AuthConstants.ACTION_SIGNUP.equals(action)) {
                    // Không cho phép đăng ký với email đã tồn tại
                    request.setAttribute("error", "An account with this Google email already exists. Please use login instead.");
                    request.getRequestDispatcher(AuthConstants.JSP_LOGIN).forward(request, response);
                    return;
                }
                
            } 
            // TRƯỜNG HỢP 2: User chưa tồn tại trong database
            else if (AuthConstants.ACTION_SIGNUP.equals(action)) {
                // TRƯỜNG HỢP 2.1: User không tồn tại + action = signup → Tạo user mới
                
                // Google không cung cấp một số thông tin, đặt giá trị mặc định
                String phoneNumber = null; // Google không cung cấp số điện thoại
                String password = AuthConstants.OAUTH_PLACEHOLDER_PASSWORD; // Password placeholder vì Google không có password
                String gender = AuthConstants.DEFAULT_GENDER; // Giới tính mặc định
                String address = null; // Google không cung cấp địa chỉ
                Date dateOfBirth = null; // Google không cung cấp ngày sinh
                
                // Tạo user mới với thông tin từ Google
                boolean success = userDAO.addNewUser(
                    name,                                    // Tên từ Google
                    email,                                   // Email từ Google
                    phoneNumber,                             // null
                    password,                                // Placeholder password
                    gender,                                  // Mặc định "Other"
                    AuthConstants.ROLE_CUSTOMER,             // Mặc định là Customer
                    address,                                 // null
                    dateOfBirth,                             // null
                    AuthConstants.STATUS_ACTIVE              // Tự động kích hoạt
                );
                
                if (success) {
                    // Lấy user vừa tạo để lấy đầy đủ thông tin (bao gồm UserID)
                    User newUser = userDAO.getUserByEmail(email);
                    
                    // Tạo session cho user mới
                    SessionHelper.setUserSession(session, newUser);
                    
                    // Redirect về trang chủ sau khi đăng ký thành công
                    response.sendRedirect(request.getContextPath() + AuthConstants.JSP_INDEX);
                } else {
                    // Nếu tạo user thất bại, hiển thị lỗi
                    request.setAttribute("error", "Failed to create account. Please try again.");
                    request.getRequestDispatcher(AuthConstants.JSP_SIGNUP).forward(request, response);
                }
                
            } else {
                // TRƯỜNG HỢP 2.2: User không tồn tại + action = login → Từ chối, yêu cầu đăng ký trước
                if (AuthConstants.ACTION_LOGIN.equals(action)) {
                    // Không cho phép đăng nhập với email chưa tồn tại
                    request.setAttribute("error", "No account found with this Google email. Please sign up first.");
                    request.getRequestDispatcher(AuthConstants.JSP_LOGIN).forward(request, response);
                } else {
                    // Trường hợp không hợp lệ (không nên xảy ra)
                    request.setAttribute("error", "Invalid action. Please try again.");
                    request.getRequestDispatcher(AuthConstants.JSP_LOGIN).forward(request, response);
                }
            }
            
        } catch (Exception e) {
            // Xử lý lỗi nếu có exception trong quá trình OAuth
            System.err.println("Google OAuth error: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Authentication failed: " + e.getMessage() + ". Please try again.");
            request.getRequestDispatcher(AuthConstants.JSP_LOGIN).forward(request, response);
        }
    }
}

