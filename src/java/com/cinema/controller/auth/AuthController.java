package com.cinema.controller.auth;


import com.cinema.dal.UserDAO;
import com.cinema.entity.User;
import com.cinema.utils.Constants;
import com.cinema.utils.EmailService;
import com.cinema.utils.SessionUtils;
import java.io.IOException;
import java.sql.Date;
import java.util.UUID;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Controller xử lý xác thực người dùng
 * Xử lý các chức năng: đăng nhập, đăng ký, đăng xuất, quên mật khẩu và đặt lại mật khẩu
 */
public class AuthController extends HttpServlet {

    private UserDAO userDAO = new UserDAO();
    private EmailService emailService = new EmailService();

    /**
     * Xử lý các request GET - hiển thị các trang form
     * Phân tích pathInfo để xác định action và hiển thị trang tương ứng
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Lấy action từ pathInfo (ví dụ: /auth/login -> "/login")
        String action = request.getPathInfo();
        
        // Nếu không có action, mặc định chuyển về trang đăng nhập
        if (action == null || action.equals("/") || action.isEmpty()) {
            redirectToLogin(request, response);
            return;
        }
        
        
        // Phân loại action và xử lý tương ứng
        switch (action) {
            case "/login":
                showLoginPage(request, response);
                break;
            case "/signup":
                showSignupPage(request, response);
                break;
            case "/logout":
                handleLogout(request, response);
                break;
            case "/forgot-password":
                showForgotPasswordPage(request, response);
                break;
            case "/reset-password":
                showResetPasswordPage(request, response);
                break;
            default:
                // Action không hợp lệ - trả về lỗi 404
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    /**
     * Xử lý các request POST - xử lý logic đăng nhập, đăng ký, đăng xuất, quên mật khẩu
     * Phân tích pathInfo để xác định action và gọi method xử lý tương ứng
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Lấy action từ pathInfo để xác định hành động cần thực hiện
        String action = request.getPathInfo();
        
        // Nếu không có action, mặc định chuyển về trang đăng nhập
        if (action == null) {
            redirectToLogin(request, response);
            return;
        }
        
        // Phân loại action và gọi method xử lý logic tương ứng
        switch (action) {
            case "/login":
                handleLogin(request, response);
                break;
            case "/signup":
                handleSignup(request, response);
                break;
            case "/logout":
                handleLogout(request, response);
                break;
            case "/forgot-password":
                handleForgotPassword(request, response);
                break;
            case "/reset-password":
                handleResetPassword(request, response);
                break;
            default:
                // Action không hợp lệ - trả về lỗi 404
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }
    
    /**
     * Chuyển hướng về trang đăng nhập
     */
    private void redirectToLogin(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        response.sendRedirect(request.getContextPath() + Constants.URL_AUTH_LOGIN);
    }

    /**
     * Hiển thị trang đăng nhập
     */
    private void showLoginPage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        forwardToJSP(request, response, Constants.JSP_AUTH_LOGIN);
    }

    /**
     * Hiển thị trang đăng ký
     */
    private void showSignupPage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        forwardToJSP(request, response, Constants.JSP_AUTH_SIGNUP);
    }

    /**
     * Hiển thị trang quên mật khẩu
     */
    private void showForgotPasswordPage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        forwardToJSP(request, response, Constants.JSP_AUTH_FORGOT_PASSWORD);
    }

    /**
     * Hiển thị trang đặt lại mật khẩu với token
     * Kiểm tra token có tồn tại trong request parameter, nếu không có thì hiển thị lỗi
     * Token sẽ được validate chi tiết trong method handleResetPassword khi submit form
     */
    private void showResetPasswordPage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Lấy token từ query parameter (từ link trong email)
        String token = request.getParameter("token");
        
        // Kiểm tra token có tồn tại và không rỗng
        if (token == null || token.trim().isEmpty()) {
            // Token không hợp lệ - hiển thị lỗi và quay về trang quên mật khẩu
            request.setAttribute("error", "Invalid or missing reset token");
            forwardToJSP(request, response, Constants.JSP_AUTH_FORGOT_PASSWORD);
            return;
        }
        
        // Token hợp lệ - truyền token vào JSP để hiển thị form đặt lại mật khẩu
        // Token sẽ được validate chi tiết trong handleResetPassword method khi người dùng submit
        request.setAttribute("token", token);
        forwardToJSP(request, response, Constants.JSP_AUTH_RESET_PASSWORD);
    }
    
    /**
     * Chuyển tiếp request đến JSP
     */
    private void forwardToJSP(HttpServletRequest request, HttpServletResponse response, String jspPath)
            throws ServletException, IOException {
        // JSP paths trong Constants đã là absolute path (bắt đầu bằng "/")
        request.getRequestDispatcher(jspPath).forward(request, response);
    }
    
    /**
     * Chuyển tiếp request đến JSP kèm thông báo lỗi
     */
    private void forwardWithError(HttpServletRequest request, HttpServletResponse response, 
                                  String jspPath, String errorMessage)
            throws ServletException, IOException {
        request.setAttribute("error", errorMessage);
        forwardToJSP(request, response, jspPath);
    }

    /**
     * Xử lý đăng nhập người dùng
     * Flow: Validate input -> Authenticate -> Check account status -> Create session -> Redirect
     */
    private void handleLogin(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Bước 1: Lấy thông tin đăng nhập từ form
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        
        // Bước 2: Kiểm tra email và mật khẩu không được để trống
        // Sử dụng isBlank() để kiểm tra null, empty và chỉ chứa khoảng trắng
        if (isBlank(email) || isBlank(password)) {
            forwardWithError(request, response, Constants.JSP_AUTH_LOGIN, "Email and password are required");
            return;
        }
        
        // Bước 3: Xác thực thông tin đăng nhập với database
        // trim() email để loại bỏ khoảng trắng thừa, password không trim vì có thể chứa khoảng trắng hợp lệ
        User user = userDAO.authenticate(email.trim(), password);
        
        // Bước 4: Kiểm tra xác thực có thành công không
        if (user == null) {
            // Email hoặc mật khẩu không đúng - không tiết lộ cụ thể cái nào sai vì lý do bảo mật
            forwardWithError(request, response, Constants.JSP_AUTH_LOGIN, "Invalid email or password");
            return;
        }
        
        // Bước 5: Kiểm tra tài khoản có đang hoạt động không
        // Chỉ cho phép đăng nhập nếu tài khoản ở trạng thái Active
        if (!Constants.STATUS_ACTIVE.equals(user.getAccountStatus())) {
            forwardWithError(request, response, Constants.JSP_AUTH_LOGIN, 
                    "Your account is not active. Please contact support.");
            return;
        }
        
        // Bước 6: Tạo session cho người dùng sau khi xác thực thành công
        HttpSession session = request.getSession();
        createUserSession(session, user);
        
        // Bước 7: Kiểm tra xem có URL redirect trước khi đăng nhập không
        // Trường hợp này xảy ra khi người dùng chưa đăng nhập nhưng cố gắng truy cập trang cần đăng nhập
        // (ví dụ: từ booking flow), hệ thống sẽ lưu URL đó và redirect lại sau khi đăng nhập
        String redirectAfterLogin = (String) session.getAttribute(Constants.SESSION_REDIRECT_AFTER_LOGIN);
        if (redirectAfterLogin != null) {
            // Xóa redirect URL khỏi session để không sử dụng lại
            session.removeAttribute(Constants.SESSION_REDIRECT_AFTER_LOGIN);
            response.sendRedirect(redirectAfterLogin);
            return;
        }
        
        // Bước 8: Chuyển hướng dựa trên vai trò của người dùng
        // Admin -> Dashboard, Staff -> Movie management, Customer -> Home
        redirectAfterLogin(request, response, user.getRole());
    }
    
    /**
     * Tạo session cho người dùng sau khi đăng nhập thành công
     * Lưu tất cả thông tin cần thiết của người dùng vào session để sử dụng trong các request sau
     * Sử dụng constants từ SessionUtils để đảm bảo tính nhất quán
     */
    private void createUserSession(HttpSession session, User user) {
        // Lưu object User đầy đủ để có thể truy cập tất cả thông tin
        session.setAttribute(SessionUtils.ATTR_USER, user);
        // Lưu từng thuộc tính riêng lẻ để dễ dàng truy cập mà không cần cast
        session.setAttribute(SessionUtils.ATTR_USER_NAME, user.getFullName());
        session.setAttribute(SessionUtils.ATTR_USER_EMAIL, user.getEmail());
        session.setAttribute(SessionUtils.ATTR_USER_ROLE, user.getRole());
        session.setAttribute(SessionUtils.ATTR_USER_ID, user.getUserID());
    }
    
    /**
     * Chuyển hướng người dùng sau khi đăng nhập dựa trên vai trò
     * Mỗi vai trò sẽ được chuyển đến trang phù hợp với quyền hạn của họ
     */
    private void redirectAfterLogin(HttpServletRequest request, HttpServletResponse response, String role)
            throws IOException {
        String redirectUrl;
        
        // Admin được chuyển đến trang quản trị
        if (Constants.ROLE_ADMIN.equals(role)) {
            redirectUrl = request.getContextPath() + Constants.URL_ADMIN_DASHBOARD;
        } 
        // Staff được chuyển đến trang quản lý phim
        else if (Constants.ROLE_STAFF.equals(role)) {
            redirectUrl = request.getContextPath() + "/list"; // Staff goes to movie management
        } 
        // Customer và các vai trò khác được chuyển về trang chủ
        else {
            redirectUrl = request.getContextPath() + Constants.URL_HOME;
        }
        
        response.sendRedirect(redirectUrl);
    }

    /**
     * Xử lý đăng ký tài khoản mới
     * Flow: Lấy dữ liệu -> Validate -> Kiểm tra trùng lặp -> Parse dữ liệu -> Tạo tài khoản
     */
    private void handleSignup(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Bước 1: Lấy tất cả thông tin từ form đăng ký
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phoneNumber = request.getParameter("phoneNumber");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String gender = request.getParameter("gender");
        String address = request.getParameter("address");
        String dateOfBirthStr = request.getParameter("dateOfBirth");
        
        // Bước 2: Kiểm tra tính hợp lệ của dữ liệu đầu vào
        // Validate các trường bắt buộc, độ dài mật khẩu, và xác nhận mật khẩu
        String validationError = validateSignupInput(fullName, email, password, confirmPassword);
        if (validationError != null) {
            forwardWithError(request, response, Constants.JSP_AUTH_SIGNUP, validationError);
            return;
        }
        
        // Bước 3: Kiểm tra email đã tồn tại trong hệ thống chưa
        // Email phải là duy nhất trong hệ thống
        if (userDAO.checkExistedEmail(email.trim())) {
            forwardWithError(request, response, Constants.JSP_AUTH_SIGNUP, "Email already exists");
            return;
        }
        
        // Bước 4: Kiểm tra số điện thoại đã tồn tại chưa (nếu người dùng có nhập)
        // Số điện thoại là tùy chọn nhưng nếu có thì phải là duy nhất
        if (!isBlank(phoneNumber) && userDAO.checkExistedPhone(phoneNumber.trim())) {
            forwardWithError(request, response, Constants.JSP_AUTH_SIGNUP, "Phone number already exists");
            return;
        }
        
        // Bước 5: Parse ngày sinh từ string sang Date object
        // Nếu ngày sinh không hợp lệ format nhưng có giá trị thì báo lỗi
        Date dateOfBirth = parseDateOfBirth(dateOfBirthStr);
        if (dateOfBirth == null && !isBlank(dateOfBirthStr)) {
            forwardWithError(request, response, Constants.JSP_AUTH_SIGNUP, "Invalid date of birth format");
            return;
        }
        
        // Bước 6: Tạo tài khoản mới trong database
        // Tất cả người dùng mới đăng ký mặc định là Customer với trạng thái Active
        boolean success = userDAO.addNewUser(
            fullName.trim(),                    // Trim để loại bỏ khoảng trắng thừa
            email.trim(),                       // Trim email
            phoneNumber != null ? phoneNumber.trim() : null,  // Trim phone nếu có
            password,                           // Không trim password
            gender != null ? gender : "Other",  // Mặc định giới tính là "Other" nếu không chọn
            Constants.ROLE_CUSTOMER,            // Vai trò mặc định là Customer
            address != null ? address.trim() : null,  // Trim address nếu có
            dateOfBirth,                        // Date object hoặc null
            Constants.STATUS_ACTIVE              // Trạng thái mặc định là Active
        );
        
        // Bước 7: Xử lý kết quả tạo tài khoản
        if (success) {
            // Tạo tài khoản thành công - hiển thị thông báo và chuyển về trang đăng nhập
            request.setAttribute("success", "Account created successfully! You can now login.");
            forwardToJSP(request, response, Constants.JSP_AUTH_LOGIN);
        } else {
            // Tạo tài khoản thất bại - hiển thị lỗi và quay lại form đăng ký
            forwardWithError(request, response, Constants.JSP_AUTH_SIGNUP, 
                    "Failed to create account. Please try again.");
        }
    }
    
    /**
     * Kiểm tra tính hợp lệ của dữ liệu đăng ký
     * @param fullName Tên đầy đủ
     * @param email Email
     * @param password Mật khẩu
     * @param confirmPassword Xác nhận mật khẩu
     * @return Thông báo lỗi nếu có, null nếu hợp lệ
     */
    private String validateSignupInput(String fullName, String email, String password, String confirmPassword) {
        // Kiểm tra các trường bắt buộc không được để trống
        // fullName, email và password là các trường bắt buộc
        if (isBlank(fullName) || isBlank(email) || isBlank(password)) {
            return "Full name, email, and password are required";
        }
        
        // Kiểm tra mật khẩu và xác nhận mật khẩu phải khớp nhau
        // Đảm bảo người dùng nhập đúng mật khẩu mong muốn
        if (!password.equals(confirmPassword)) {
            return "Passwords do not match";
        }
        
        // Kiểm tra độ dài tối thiểu của mật khẩu
        // Mật khẩu phải có ít nhất MIN_PASSWORD_LENGTH ký tự để đảm bảo bảo mật
        if (password.length() < Constants.MIN_PASSWORD_LENGTH) {
            return "Password must be at least " + Constants.MIN_PASSWORD_LENGTH + " characters long";
        }
        
        // Tất cả validation đều pass - trả về null để báo hiệu dữ liệu hợp lệ
        return null;
    }
    
    /**
     * Kiểm tra chuỗi có rỗng hoặc chỉ chứa khoảng trắng không
     */
    private boolean isBlank(String str) {
        return str == null || str.trim().isEmpty();
    }
    
    /**
     * Parse chuỗi ngày sinh thành Date object
     */
    private Date parseDateOfBirth(String dateOfBirthStr) {
        if (dateOfBirthStr == null || dateOfBirthStr.trim().isEmpty()) {
            return null;
        }
        try {
            return Date.valueOf(dateOfBirthStr);
        } catch (IllegalArgumentException e) {
            return null;
        }
    }

    /**
     * Xử lý yêu cầu quên mật khẩu - gửi email chứa link đặt lại mật khẩu
     * Flow: Validate email -> Kiểm tra user tồn tại -> Tạo token -> Lưu token -> Gửi email
     */
    private void handleForgotPassword(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Bước 1: Lấy email từ form
        String email = request.getParameter("email");
        
        // Bước 2: Kiểm tra email không được để trống
        if (isBlank(email)) {
            forwardWithError(request, response, Constants.JSP_AUTH_FORGOT_PASSWORD, "Email is required");
            return;
        }
        
        // Bước 3: Tìm người dùng theo email trong database
        User user = userDAO.getUserByEmail(email.trim());
        
        // Bước 4: Xử lý trường hợp email không tồn tại
        // Vì lý do bảo mật, không tiết lộ email có tồn tại hay không
        // Điều này ngăn chặn kẻ tấn công dò tìm email hợp lệ trong hệ thống
        if (user == null) {
            // Hiển thị thông báo chung chung để không tiết lộ thông tin
            request.setAttribute("success", "If the email exists, a password reset link has been sent.");
            forwardToJSP(request, response, Constants.JSP_AUTH_FORGOT_PASSWORD);
            return;
        }
        
        // Bước 5: Tạo token đặt lại mật khẩu ngẫu nhiên
        // Sử dụng UUID để đảm bảo token là duy nhất và khó đoán
        String resetToken = UUID.randomUUID().toString();
        
        // Bước 6: Lưu token vào database kèm với thời gian hết hạn
        // Token sẽ có thời gian hết hạn (thường là 1 giờ) để đảm bảo bảo mật
        boolean tokenStored = userDAO.storePasswordResetToken(email.trim(), resetToken);
        
        if (!tokenStored) {
            // Không thể lưu token - có thể do lỗi database
            forwardWithError(request, response, Constants.JSP_AUTH_FORGOT_PASSWORD, 
                    "Failed to generate reset token. Please try again.");
            return;
        }
        
        // Bước 7: Tạo link đặt lại mật khẩu và nội dung email
        // Link sẽ chứa token để xác thực khi người dùng click vào
        String resetLink = buildResetPasswordLink(request, resetToken);
        String emailBody = buildResetPasswordEmailBody(user.getFullName(), resetLink);
        
        // Bước 8: Gửi email chứa link đặt lại mật khẩu
        boolean emailSent = emailService.sendEmail(email, "Password Reset Request", emailBody);
        
        // Bước 9: Xử lý kết quả gửi email
        if (emailSent) {
            request.setAttribute("success", "Password reset link has been sent to your email.");
        } else {
            // Gửi email thất bại - có thể do lỗi SMTP hoặc cấu hình email
            request.setAttribute("error", "Failed to send reset email. Please try again later.");
        }
        
        forwardToJSP(request, response, Constants.JSP_AUTH_FORGOT_PASSWORD);
    }
    
    /**
     * Tạo link đặt lại mật khẩu
     * Xây dựng URL đầy đủ bao gồm scheme, server name, port, context path và token
     * @param request HttpServletRequest để lấy thông tin server
     * @param token Token đặt lại mật khẩu
     * @return URL đầy đủ để đặt lại mật khẩu
     */
    private String buildResetPasswordLink(HttpServletRequest request, String token) {
        // Xây dựng URL động dựa trên request hiện tại
        // Đảm bảo link hoạt động đúng cả với localhost, ngrok, hoặc domain thực
        return request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + 
               request.getContextPath() + "/auth/reset-password?token=" + token;
    }
    
    /**
     * Tạo nội dung email đặt lại mật khẩu
     * @param fullName Tên đầy đủ của người dùng
     * @param resetLink Link để đặt lại mật khẩu
     * @return Nội dung email dạng text
     */
    private String buildResetPasswordEmailBody(String fullName, String resetLink) {
        return "Hello " + fullName + ",\n\n" +
               "You requested a password reset. Click the link below to reset your password:\n\n" +
               resetLink + "\n\n" +
               "This link will expire in 1 hour.\n\n" +
               "If you didn't request this, please ignore this email.\n\n" +
               "Best regards,\nCinema Management Team";
    }

    /**
     * Xử lý đặt lại mật khẩu với token
     * Flow: Validate token -> Validate password -> Verify token -> Update password
     */
    private void handleResetPassword(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Bước 1: Lấy token và mật khẩu mới từ form
        String token = request.getParameter("token");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");
        
        // Bước 2: Kiểm tra token có tồn tại không
        if (isBlank(token)) {
            forwardWithError(request, response, Constants.JSP_AUTH_FORGOT_PASSWORD, "Invalid reset token");
            return;
        }
        
        // Bước 3: Kiểm tra tính hợp lệ của mật khẩu mới
        // Validate độ dài, format và xác nhận mật khẩu
        String passwordValidationError = validatePasswordReset(newPassword, confirmPassword);
        if (passwordValidationError != null) {
            // Giữ lại token trong request để người dùng không phải nhập lại
            request.setAttribute("token", token);
            forwardWithError(request, response, Constants.JSP_AUTH_RESET_PASSWORD, passwordValidationError);
            return;
        }
        
        // Bước 4: Xác thực token và lấy thông tin người dùng từ database
        // Token phải tồn tại, chưa hết hạn và chưa được sử dụng
        User user = userDAO.getUserByResetToken(token);
        
        if (user == null) {
            // Token không hợp lệ hoặc đã hết hạn
            forwardWithError(request, response, Constants.JSP_AUTH_FORGOT_PASSWORD, 
                    "Invalid or expired reset token");
            return;
        }
        
        // Bước 5: Cập nhật mật khẩu mới vào database
        // Mật khẩu sẽ được hash trước khi lưu vào database
        boolean success = userDAO.updatePasswordByToken(token, newPassword);
        
        // Bước 6: Xử lý kết quả cập nhật mật khẩu
        if (success) {
            // Cập nhật thành công - thông báo và chuyển về trang đăng nhập
            request.setAttribute("success", "Password has been reset successfully. You can now login with your new password.");
        } else {
            // Cập nhật thất bại - có thể do lỗi database
            request.setAttribute("error", "Failed to reset password. Please try again.");
        }
        
        forwardToJSP(request, response, Constants.JSP_AUTH_LOGIN);
    }
    
    /**
     * Kiểm tra tính hợp lệ của mật khẩu mới khi đặt lại
     * @param newPassword Mật khẩu mới
     * @param confirmPassword Xác nhận mật khẩu mới
     * @return Thông báo lỗi nếu có, null nếu hợp lệ
     */
    private String validatePasswordReset(String newPassword, String confirmPassword) {
        // Kiểm tra các trường mật khẩu không được để trống
        if (isBlank(newPassword) || isBlank(confirmPassword)) {
            return "Password fields are required";
        }
        
        // Kiểm tra mật khẩu và xác nhận mật khẩu phải khớp nhau
        if (!newPassword.equals(confirmPassword)) {
            return "Passwords do not match";
        }
        
        // Kiểm tra độ dài tối thiểu của mật khẩu
        // Đảm bảo mật khẩu đủ mạnh để bảo vệ tài khoản
        if (newPassword.length() < Constants.MIN_PASSWORD_LENGTH) {
            return "Password must be at least " + Constants.MIN_PASSWORD_LENGTH + " characters long";
        }
        
        // Tất cả validation đều pass
        return null;
    }

    /**
     * Xử lý đăng xuất - hủy session và chuyển về trang chủ
     * Sử dụng getSession(false) để không tạo session mới nếu chưa có
     */
    private void handleLogout(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Lấy session hiện tại (không tạo mới nếu chưa có)
        HttpSession session = request.getSession(false);
        
        // Nếu session tồn tại, hủy nó để xóa tất cả thông tin người dùng
        if (session != null) {
            // invalidate() sẽ xóa tất cả attributes và hủy session
            session.invalidate();
        }
        
        // Chuyển hướng về trang chủ sau khi đăng xuất
        response.sendRedirect(request.getContextPath() + Constants.URL_HOME);
    }
}
