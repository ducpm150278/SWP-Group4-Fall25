package controller.auth;

import dal.UserDAO;
import entity.User;
import java.io.IOException;
import java.sql.Date;
import java.util.UUID;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import utils.EmailService;

/**
 * Controller chính xử lý xác thực người dùng
 * Xử lý các chức năng: đăng nhập, đăng ký, đăng xuất, quên mật khẩu và đặt lại mật khẩu
 * 
 * Các endpoint được hỗ trợ:
 * - GET/POST /auth/login - Hiển thị trang đăng nhập và xử lý đăng nhập
 * - GET/POST /auth/signup - Hiển thị trang đăng ký và xử lý đăng ký
 * - GET/POST /auth/logout - Redirect đến /logout (LogoutServlet xử lý)
 * - GET/POST /auth/forgot-password - Hiển thị trang quên mật khẩu và xử lý yêu cầu reset
 * - GET/POST /auth/reset-password - Hiển thị trang đặt lại mật khẩu và xử lý reset
 */
public class AuthController extends HttpServlet {

    /** DAO để thao tác với dữ liệu người dùng trong database */
    private UserDAO userDAO = new UserDAO();
    /** Service để gửi email (dùng cho chức năng quên mật khẩu) */
    private EmailService emailService = new EmailService();

    /**
     * Xử lý các request GET - hiển thị các trang form
     * 
     * @param request HTTP request từ client
     * @param response HTTP response để gửi về client
     * @throws ServletException nếu có lỗi servlet
     * @throws IOException nếu có lỗi I/O
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Lấy action từ path info (ví dụ: /auth/login -> "/login")
        String action = request.getPathInfo();
        
        // Nếu không có action, redirect về trang đăng nhập
        if (action == null) {
            response.sendRedirect(request.getContextPath() + AuthConstants.JSP_LOGIN);
            return;
        }
        
        // Phân loại action và gọi method tương ứng
        switch (action) {
            case "/login":
                // Hiển thị trang đăng nhập
                showLoginPage(request, response);
                break;
            case "/signup":
                // Hiển thị trang đăng ký
                showSignupPage(request, response);
                break;
            case "/logout":
                // Xử lý đăng xuất - redirect đến LogoutServlet
                // LogoutServlet xử lý cleanup session kỹ lưỡng hơn
                response.sendRedirect(request.getContextPath() + "/logout");
                break;
            case "/forgot-password":
                // Hiển thị trang quên mật khẩu
                showForgotPasswordPage(request, response);
                break;
            case "/reset-password":
                // Hiển thị trang đặt lại mật khẩu (cần token)
                showResetPasswordPage(request, response);
                break;
            default:
                // Action không hợp lệ, trả về lỗi 404
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    /**
     * Xử lý các request POST - xử lý dữ liệu từ form
     * 
     * @param request HTTP request từ client
     * @param response HTTP response để gửi về client
     * @throws ServletException nếu có lỗi servlet
     * @throws IOException nếu có lỗi I/O
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Lấy action từ path info
        String action = request.getPathInfo();
        
        // Nếu không có action, redirect về trang đăng nhập
        if (action == null) {
            response.sendRedirect(request.getContextPath() + AuthConstants.JSP_LOGIN);
            return;
        }
        
        // Phân loại action và gọi method xử lý tương ứng
        switch (action) {
            case "/login":
                // Xử lý đăng nhập (kiểm tra email/password)
                handleLogin(request, response);
                break;
            case "/signup":
                // Xử lý đăng ký (tạo tài khoản mới)
                handleSignup(request, response);
                break;
            case "/logout":
                // Xử lý đăng xuất - redirect đến LogoutServlet
                // LogoutServlet xử lý cleanup session kỹ lưỡng hơn
                response.sendRedirect(request.getContextPath() + "/logout");
                break;
            case "/forgot-password":
                // Xử lý yêu cầu quên mật khẩu (gửi email reset)
                handleForgotPassword(request, response);
                break;
            case "/reset-password":
                // Xử lý đặt lại mật khẩu (với token)
                handleResetPassword(request, response);
                break;
            default:
                // Action không hợp lệ, trả về lỗi 404
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    /**
     * Hiển thị trang đăng nhập
     * Forward request đến trang JSP đăng nhập
     * 
     * @param request HTTP request
     * @param response HTTP response
     * @throws ServletException nếu có lỗi servlet
     * @throws IOException nếu có lỗi I/O
     */
    private void showLoginPage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher(AuthConstants.JSP_LOGIN).forward(request, response);
    }

    /**
     * Hiển thị trang đăng ký
     * Forward request đến trang JSP đăng ký
     * 
     * @param request HTTP request
     * @param response HTTP response
     * @throws ServletException nếu có lỗi servlet
     * @throws IOException nếu có lỗi I/O
     */
    private void showSignupPage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher(AuthConstants.JSP_SIGNUP).forward(request, response);
    }

    /**
     * Hiển thị trang quên mật khẩu
     * Forward request đến trang JSP quên mật khẩu
     * 
     * @param request HTTP request
     * @param response HTTP response
     * @throws ServletException nếu có lỗi servlet
     * @throws IOException nếu có lỗi I/O
     */
    private void showForgotPasswordPage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher(AuthConstants.JSP_FORGOT_PASSWORD).forward(request, response);
    }

    /**
     * Hiển thị trang đặt lại mật khẩu
     * Kiểm tra token từ URL parameter, nếu hợp lệ thì hiển thị form đặt lại mật khẩu
     * 
     * @param request HTTP request (chứa token trong parameter)
     * @param response HTTP response
     * @throws ServletException nếu có lỗi servlet
     * @throws IOException nếu có lỗi I/O
     */
    private void showResetPasswordPage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Lấy token từ URL parameter (được gửi qua email)
        String token = request.getParameter("token");
        
        // Kiểm tra token có tồn tại và không rỗng
        if (token == null || token.trim().isEmpty()) {
            // Token không hợp lệ, hiển thị lỗi và quay về trang quên mật khẩu
            request.setAttribute("error", "Invalid or missing reset token");
            request.getRequestDispatcher(AuthConstants.JSP_FORGOT_PASSWORD).forward(request, response);
            return;
        }
        
        // TODO: Validate token in database - kiểm tra token có tồn tại và chưa hết hạn
        // Hiện tại chỉ kiểm tra token có tồn tại, chưa kiểm tra trong database
        
        // Lưu token vào request attribute để JSP sử dụng
        request.setAttribute("token", token);
        // Forward đến trang đặt lại mật khẩu
        request.getRequestDispatcher(AuthConstants.JSP_RESET_PASSWORD).forward(request, response);
    }

    /**
     * Xử lý đăng nhập người dùng
     * Kiểm tra email và password, tạo session nếu đăng nhập thành công
     * 
     * @param request HTTP request chứa email và password từ form
     * @param response HTTP response để redirect sau khi đăng nhập
     * @throws ServletException nếu có lỗi servlet
     * @throws IOException nếu có lỗi I/O
     */
    private void handleLogin(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Lấy email và password từ form
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        
        // Kiểm tra email và password có được nhập hay không
        if (email == null || password == null || email.trim().isEmpty() || password.trim().isEmpty()) {
            request.setAttribute("error", "Email and password are required");
            request.getRequestDispatcher(AuthConstants.JSP_LOGIN).forward(request, response);
            return;
        }
        
        // Xác thực người dùng với email và password
        User user = userDAO.authenticate(email.trim(), password);
        
        // Kiểm tra xác thực có thành công không
        if (user == null) {
            // Email hoặc password không đúng
            request.setAttribute("error", "Invalid email or password");
            request.getRequestDispatcher(AuthConstants.JSP_LOGIN).forward(request, response);
            return;
        }
        
        // Kiểm tra tài khoản có đang hoạt động không
        if (!AuthConstants.STATUS_ACTIVE.equals(user.getAccountStatus())) {
            // Tài khoản bị khóa hoặc không hoạt động
            request.setAttribute("error", "Your account is not active. Please contact support.");
            request.getRequestDispatcher(AuthConstants.JSP_LOGIN).forward(request, response);
            return;
        }
        
        // Đăng nhập thành công - tạo session
        HttpSession session = request.getSession();
        // Lưu thông tin người dùng vào session
        SessionHelper.setUserSession(session, user);
        
        // Kiểm tra xem có URL redirect được lưu trước đó không
        // (ví dụ: người dùng cố truy cập trang cần đăng nhập, sau khi đăng nhập sẽ redirect về trang đó)
        String redirectAfterLogin = (String) session.getAttribute(AuthConstants.SESSION_REDIRECT_AFTER_LOGIN);
        if (redirectAfterLogin != null) {
            // Xóa URL redirect khỏi session và redirect đến URL đó
            session.removeAttribute(AuthConstants.SESSION_REDIRECT_AFTER_LOGIN);
            response.sendRedirect(redirectAfterLogin);
            return;
        }
        
        // Redirect dựa trên vai trò của người dùng
        String userRole = user.getRole();
        if (AuthConstants.ROLE_ADMIN.equals(userRole)) {
            // Admin được redirect đến trang quản lý
            response.sendRedirect(request.getContextPath() + AuthConstants.PATH_ADMIN_LIST);
        } else if (AuthConstants.ROLE_STAFF.equals(userRole)) {
            // Staff được redirect đến trang quản lý của staff
            response.sendRedirect(request.getContextPath() + AuthConstants.PATH_STAFF_MANAGER);
        } else {
            // Customer được redirect về trang chủ
            response.sendRedirect(request.getContextPath() + AuthConstants.JSP_INDEX);
        }
    }

    /**
     * Xử lý đăng ký tài khoản mới
     * 
     * Flow xử lý:
     * Bước 1: Lấy tất cả thông tin từ form (fullName, email, password, phone, gender, address, dateOfBirth)
     * Bước 2: Validation các trường bắt buộc (fullName, email, password)
     * Bước 3: Kiểm tra password và confirmPassword có khớp không
     * Bước 4: Kiểm tra độ dài password (tối thiểu 6 ký tự)
     * Bước 5: Kiểm tra email đã tồn tại chưa
     * Bước 6: Kiểm tra số điện thoại đã tồn tại chưa (nếu có)
     * Bước 7: Parse ngày sinh (nếu có)
     * Bước 8: Tạo user mới trong database
     * Bước 9: Thông báo kết quả và redirect
     * 
     * @param request HTTP request chứa thông tin đăng ký từ form
     * @param response HTTP response để forward hoặc redirect
     * @throws ServletException nếu có lỗi servlet
     * @throws IOException nếu có lỗi I/O
     */
    private void handleSignup(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Bước 1: Lấy tất cả thông tin từ form
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phoneNumber = request.getParameter("phoneNumber");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String gender = request.getParameter("gender");
        String address = request.getParameter("address");
        String dateOfBirthStr = request.getParameter("dateOfBirth");
        
        // Bước 2: Validation các trường bắt buộc
        // Kiểm tra fullName, email, password có được nhập hay không
        if (fullName == null || email == null || password == null || 
            fullName.trim().isEmpty() || email.trim().isEmpty() || password.trim().isEmpty()) {
            request.setAttribute("error", "Full name, email, and password are required");
            request.getRequestDispatcher(AuthConstants.JSP_SIGNUP).forward(request, response);
            return;
        }
        
        // Bước 3: Kiểm tra password và confirmPassword có khớp không
        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Passwords do not match");
            request.getRequestDispatcher(AuthConstants.JSP_SIGNUP).forward(request, response);
            return;
        }
        
        // Bước 4: Kiểm tra độ dài password (tối thiểu 6 ký tự)
        if (password.length() < AuthConstants.MIN_PASSWORD_LENGTH) {
            request.setAttribute("error", "Password must be at least " + AuthConstants.MIN_PASSWORD_LENGTH + " characters long");
            request.getRequestDispatcher(AuthConstants.JSP_SIGNUP).forward(request, response);
            return;
        }
        
        // Bước 5: Kiểm tra email đã tồn tại trong database chưa
        if (userDAO.checkExistedEmail(email.trim())) {
            request.setAttribute("error", "Email already exists");
            request.getRequestDispatcher(AuthConstants.JSP_SIGNUP).forward(request, response);
            return;
        }
        
        // Bước 6: Kiểm tra số điện thoại đã tồn tại chưa (nếu người dùng có nhập)
        if (phoneNumber != null && !phoneNumber.trim().isEmpty() && userDAO.checkExistedPhone(phoneNumber.trim())) {
            request.setAttribute("error", "Phone number already exists");
            request.getRequestDispatcher(AuthConstants.JSP_SIGNUP).forward(request, response);
            return;
        }
        
        // Bước 7: Parse ngày sinh từ string sang Date object
        Date dateOfBirth = null;
        if (dateOfBirthStr != null && !dateOfBirthStr.trim().isEmpty()) {
            try {
                // Format mong đợi: YYYY-MM-DD
                dateOfBirth = Date.valueOf(dateOfBirthStr);
            } catch (IllegalArgumentException e) {
                // Format không hợp lệ
                request.setAttribute("error", "Invalid date of birth format");
                request.getRequestDispatcher(AuthConstants.JSP_SIGNUP).forward(request, response);
                return;
            }
        }
        
        // Bước 8: Tạo user mới trong database
        // Vai trò mặc định là Customer, trạng thái mặc định là Active
        boolean success = userDAO.addNewUser(
            fullName.trim(),                                    // Tên đầy đủ
            email.trim(),                                       // Email
            phoneNumber != null ? phoneNumber.trim() : null,    // Số điện thoại (có thể null)
            password,                                           // Mật khẩu (chưa hash, DAO sẽ hash)
            gender != null ? gender : AuthConstants.DEFAULT_GENDER, // Giới tính (mặc định "Other")
            AuthConstants.ROLE_CUSTOMER,                        // Vai trò mặc định là Customer
            address != null ? address.trim() : null,            // Địa chỉ (có thể null)
            dateOfBirth,                                        // Ngày sinh (có thể null)
            AuthConstants.STATUS_ACTIVE                         // Trạng thái mặc định là Active
        );
        
        // Bước 9: Xử lý kết quả và thông báo
        if (success) {
            // Đăng ký thành công - hiển thị thông báo và redirect đến trang đăng nhập
            request.setAttribute("success", "Account created successfully! You can now login.");
            request.getRequestDispatcher(AuthConstants.JSP_LOGIN).forward(request, response);
        } else {
            // Đăng ký thất bại - hiển thị lỗi và quay lại form đăng ký
            request.setAttribute("error", "Failed to create account. Please try again.");
            request.getRequestDispatcher(AuthConstants.JSP_SIGNUP).forward(request, response);
        }
    }

    /**
     * Xử lý yêu cầu quên mật khẩu
     * 
     * Flow xử lý:
     * Bước 1: Lấy email từ form
     * Bước 2: Validation email có được nhập hay không
     * Bước 3: Tìm user trong database theo email
     * Bước 4: Nếu không tìm thấy user, vẫn hiển thị thông báo thành công (bảo mật - không tiết lộ email có tồn tại hay không)
     * Bước 5: Nếu tìm thấy user, tạo reset token (UUID ngẫu nhiên)
     * Bước 6: Lưu reset token vào database (kèm thời gian hết hạn)
     * Bước 7: Xây dựng link reset password
     * Bước 8: Xây dựng nội dung email
     * Bước 9: Gửi email chứa link reset password
     * Bước 10: Thông báo kết quả
     * 
     * Lưu ý bảo mật: Luôn hiển thị thông báo thành công dù email có tồn tại hay không,
     * để tránh kẻ tấn công dò tìm email hợp lệ trong hệ thống.
     * 
     * @param request HTTP request chứa email từ form
     * @param response HTTP response để forward
     * @throws ServletException nếu có lỗi servlet
     * @throws IOException nếu có lỗi I/O
     */
    private void handleForgotPassword(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Bước 1: Lấy email từ form
        String email = request.getParameter("email");
        
        // Bước 2: Validation email có được nhập hay không
        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("error", "Email is required");
            request.getRequestDispatcher(AuthConstants.JSP_FORGOT_PASSWORD).forward(request, response);
            return;
        }
        
        // Bước 3: Tìm user trong database theo email
        User user = userDAO.getUserByEmail(email.trim());
        
        // Bước 4: Nếu không tìm thấy user, vẫn hiển thị thông báo thành công
        // (Bảo mật: không tiết lộ email có tồn tại trong hệ thống hay không)
        if (user == null) {
            // Hiển thị thông báo chung, không xác nhận email có tồn tại hay không
            request.setAttribute("success", "If the email exists, a password reset link has been sent.");
            request.getRequestDispatcher(AuthConstants.JSP_FORGOT_PASSWORD).forward(request, response);
            return;
        }
        
        // Bước 5: Tạo reset token ngẫu nhiên (UUID)
        // Token này sẽ được gửi qua email và dùng để xác thực khi reset password
        String resetToken = UUID.randomUUID().toString();
        
        // Bước 6: Lưu reset token vào database
        // Token sẽ được lưu kèm với thời gian hết hạn (thường là 1 giờ)
        boolean tokenStored = userDAO.storePasswordResetToken(email.trim(), resetToken);
        
        if (!tokenStored) {
            // Nếu không lưu được token, hiển thị lỗi
            request.setAttribute("error", "Failed to generate reset token. Please try again.");
            request.getRequestDispatcher(AuthConstants.JSP_FORGOT_PASSWORD).forward(request, response);
            return;
        }
        
        // Bước 7: Xây dựng link reset password
        // Link sẽ có dạng: http://domain:port/context-path/auth/reset-password?token=...
        String resetLink = buildResetPasswordLink(request, resetToken);
        
        // Bước 8: Xây dựng nội dung email
        String subject = "Password Reset Request";
        String body = buildResetPasswordEmailBody(user.getFullName(), resetLink);
        
        // Bước 9: Gửi email chứa link reset password
        boolean emailSent = emailService.sendEmail(email, subject, body);
        
        // Bước 10: Thông báo kết quả
        if (emailSent) {
            // Email gửi thành công
            request.setAttribute("success", "Password reset link has been sent to your email.");
        } else {
            // Email gửi thất bại
            request.setAttribute("error", "Failed to send reset email. Please try again later.");
        }
        
        request.getRequestDispatcher(AuthConstants.JSP_FORGOT_PASSWORD).forward(request, response);
    }

    /**
     * Xử lý đặt lại mật khẩu với token
     * 
     * Flow xử lý:
     * Bước 1: Lấy token, newPassword, confirmPassword từ form
     * Bước 2: Validation token có tồn tại không
     * Bước 3: Validation password fields có được nhập hay không
     * Bước 4: Kiểm tra newPassword và confirmPassword có khớp không
     * Bước 5: Kiểm tra độ dài password (tối thiểu 6 ký tự)
     * Bước 6: Validate token và lấy user từ database
     * Bước 7: Kiểm tra token có hợp lệ và chưa hết hạn không
     * Bước 8: Update password mới cho user
     * Bước 9: Thông báo kết quả và redirect đến trang đăng nhập
     * 
     * @param request HTTP request chứa token và password mới từ form
     * @param response HTTP response để forward hoặc redirect
     * @throws ServletException nếu có lỗi servlet
     * @throws IOException nếu có lỗi I/O
     */
    private void handleResetPassword(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Bước 1: Lấy token và password mới từ form
        String token = request.getParameter("token");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");
        
        // Bước 2: Validation token có tồn tại không
        if (token == null || token.trim().isEmpty()) {
            request.setAttribute("error", "Invalid reset token");
            request.getRequestDispatcher(AuthConstants.JSP_FORGOT_PASSWORD).forward(request, response);
            return;
        }
        
        // Bước 3: Validation password fields có được nhập hay không
        if (newPassword == null || confirmPassword == null || 
            newPassword.trim().isEmpty() || confirmPassword.trim().isEmpty()) {
            request.setAttribute("error", "Password fields are required");
            // Giữ lại token để hiển thị lại form
            request.setAttribute("token", token);
            request.getRequestDispatcher(AuthConstants.JSP_RESET_PASSWORD).forward(request, response);
            return;
        }
        
        // Bước 4: Kiểm tra newPassword và confirmPassword có khớp không
        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("error", "Passwords do not match");
            // Giữ lại token để hiển thị lại form
            request.setAttribute("token", token);
            request.getRequestDispatcher(AuthConstants.JSP_RESET_PASSWORD).forward(request, response);
            return;
        }
        
        // Bước 5: Kiểm tra độ dài password (tối thiểu 6 ký tự)
        if (newPassword.length() < AuthConstants.MIN_PASSWORD_LENGTH) {
            request.setAttribute("error", "Password must be at least " + AuthConstants.MIN_PASSWORD_LENGTH + " characters long");
            // Giữ lại token để hiển thị lại form
            request.setAttribute("token", token);
            request.getRequestDispatcher(AuthConstants.JSP_RESET_PASSWORD).forward(request, response);
            return;
        }
        
        // Bước 6: Validate token và lấy user từ database
        // Token phải tồn tại trong database và chưa hết hạn
        User user = userDAO.getUserByResetToken(token);
        
        // Bước 7: Kiểm tra token có hợp lệ và chưa hết hạn không
        if (user == null) {
            // Token không tồn tại hoặc đã hết hạn
            request.setAttribute("error", "Invalid or expired reset token");
            request.getRequestDispatcher(AuthConstants.JSP_FORGOT_PASSWORD).forward(request, response);
            return;
        }
        
        // Bước 8: Update password mới cho user
        // Password sẽ được hash trước khi lưu vào database
        boolean success = userDAO.updatePasswordByToken(token, newPassword);
        
        // Bước 9: Thông báo kết quả và redirect đến trang đăng nhập
        if (success) {
            // Reset password thành công
            request.setAttribute("success", "Password has been reset successfully. You can now login with your new password.");
        } else {
            // Reset password thất bại
            request.setAttribute("error", "Failed to reset password. Please try again.");
        }
        
        // Redirect đến trang đăng nhập sau khi reset password
        request.getRequestDispatcher(AuthConstants.JSP_LOGIN).forward(request, response);
    }

    /**
     * Xây dựng link reset password đầy đủ
     * 
     * Link sẽ có format: http://domain:port/context-path/auth/reset-password?token=...
     * 
     * Ví dụ: http://localhost:8080/SWP-Group4-Fall25/auth/reset-password?token=abc123...
     * 
     * @param request HTTP request để lấy thông tin server (scheme, serverName, serverPort, contextPath)
     * @param token Reset token được tạo ngẫu nhiên
     * @return URL đầy đủ để reset password
     */
    private String buildResetPasswordLink(HttpServletRequest request, String token) {
        // Xây dựng URL đầy đủ: scheme://serverName:port/contextPath/path?token=...
        return request.getScheme() +                                    // http hoặc https
               "://" + 
               request.getServerName() +                                 // localhost hoặc domain
               ":" + 
               request.getServerPort() +                                 // 8080 hoặc port khác
               request.getContextPath() +                                // /SWP-Group4-Fall25
               "/auth/reset-password?token=" + token;                    // Path và token
    }
    
    /**
     * Xây dựng nội dung email reset password
     * 
     * Email sẽ chứa:
     * - Lời chào với tên user
     * - Thông báo về yêu cầu reset password
     * - Link reset password
     * - Thông tin về thời gian hết hạn (1 giờ)
     * - Lời nhắc nếu không phải user yêu cầu thì bỏ qua email
     * 
     * @param userName Tên của user (để cá nhân hóa email)
     * @param resetLink Link để reset password
     * @return Nội dung email dạng plain text
     */
    private String buildResetPasswordEmailBody(String userName, String resetLink) {
        return "Hello " + userName + ",\n\n" +
               "You requested a password reset. Click the link below to reset your password:\n\n" +
               resetLink + "\n\n" +
               "This link will expire in 1 hour.\n\n" +
               "If you didn't request this, please ignore this email.\n\n" +
               "Best regards,\nCinema Management Team";
    }
}

