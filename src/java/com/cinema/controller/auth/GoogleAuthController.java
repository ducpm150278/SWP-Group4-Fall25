package com.cinema.controller.auth;

import com.cinema.utils.Constants;
import com.cinema.utils.GoogleOAuthConfig;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Controller xử lý Google OAuth
 * Xử lý chuyển hướng đăng nhập và đăng ký bằng Google OAuth
 */
public class GoogleAuthController extends HttpServlet {

    /**
     * Xử lý request GET - chuyển hướng đến Google OAuth
     * Flow: Nhận action (login/signup) -> Lưu vào session -> Chuyển hướng đến Google
     * 
     * OAuth Flow:
     * 1. Người dùng click "Đăng nhập bằng Google" hoặc "Đăng ký bằng Google"
     * 2. Hệ thống lưu action (login/signup) vào session
     * 3. Chuyển hướng người dùng đến Google OAuth authorization page
     * 4. Người dùng xác thực với Google
     * 5. Google redirect về callback URL với authorization code
     * 6. GoogleAuthCallbackController xử lý callback
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Lấy action từ query parameter (login hoặc signup)
        String action = request.getParameter("action");
        
        // Kiểm tra action có hợp lệ không (chỉ chấp nhận login hoặc signup)
        if (Constants.ACTION_LOGIN.equals(action) || Constants.ACTION_SIGNUP.equals(action)) {
            // Lưu action vào session để sử dụng sau khi callback từ Google
            // Action này sẽ quyết định hành vi: đăng nhập người dùng hiện có hoặc tạo tài khoản mới
            request.getSession().setAttribute(Constants.SESSION_OAUTH_ACTION, action);
            
            // Lấy URL authorization từ GoogleOAuthConfig và chuyển hướng người dùng
            // URL này sẽ đưa người dùng đến trang xác thực của Google
            String authUrl = GoogleOAuthConfig.getAuthorizationUrl();
            response.sendRedirect(authUrl);
        } else {
            // Nếu action không hợp lệ hoặc không có, mặc định là đăng nhập
            // Đảm bảo luôn có action trong session để callback controller biết cách xử lý
            request.getSession().setAttribute(Constants.SESSION_OAUTH_ACTION, Constants.ACTION_LOGIN);
            String authUrl = GoogleOAuthConfig.getAuthorizationUrl();
            response.sendRedirect(authUrl);
        }
    }
}
