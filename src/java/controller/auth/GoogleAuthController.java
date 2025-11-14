package controller.auth;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Controller xử lý đăng nhập/đăng ký qua Google OAuth
 * Khởi tạo quá trình OAuth bằng cách redirect người dùng đến trang xác thực của Google
 * 
 * Flow:
 * 1. Người dùng click "Đăng nhập/Đăng ký với Google"
 * 2. Servlet này nhận request với parameter "action" (login hoặc signup)
 * 3. Lưu action vào session để xử lý sau khi Google callback
 * 4. Redirect người dùng đến Google OAuth authorization page
 */
public class GoogleAuthController extends HttpServlet {

    /**
     * Xử lý request GET để bắt đầu quá trình OAuth với Google
     * 
     * @param request HTTP request chứa parameter "action" (login hoặc signup)
     * @param response HTTP response để redirect đến Google OAuth
     * @throws ServletException nếu có lỗi servlet
     * @throws IOException nếu có lỗi I/O
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Lấy action từ request parameter (login hoặc signup)
        String action = request.getParameter("action");
        
        // Xác định hành động OAuth: nếu action hợp lệ (login hoặc signup) thì dùng action đó,
        // nếu không thì mặc định là login
        String oauthAction = (action != null && (AuthConstants.ACTION_LOGIN.equals(action) || AuthConstants.ACTION_SIGNUP.equals(action))) 
            ? action 
            : AuthConstants.ACTION_LOGIN;
        
        // Lưu hành động vào session để sử dụng sau khi Google callback
        // (khi Google redirect về, cần biết người dùng muốn login hay signup)
        request.getSession().setAttribute(AuthConstants.SESSION_OAUTH_ACTION, oauthAction);
        
        // Lấy URL xác thực của Google OAuth (chứa client_id, redirect_uri, scope, etc.)
        String authUrl = GoogleOAuthConfig.getAuthorizationUrl();
        
        // Redirect người dùng đến trang xác thực của Google
        response.sendRedirect(authUrl);
    }
}

