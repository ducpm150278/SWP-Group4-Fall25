package com.cinema.controller.auth;

import com.cinema.utils.Constants;
import com.cinema.utils.SessionUtils;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Servlet xử lý đăng xuất
 * Xử lý đăng xuất người dùng và dọn dẹp session
 */
@WebServlet(name = "LogoutServlet", urlPatterns = {"/logout", "/admin/logout"})
public class LogoutServlet extends HttpServlet {

    /**
     * Xử lý request GET - đăng xuất
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        handleLogout(request, response);
    }

    /**
     * Xử lý request POST - đăng xuất
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        handleLogout(request, response);
    }

    /**
     * Xử lý logic đăng xuất - xóa tất cả session attributes và chuyển về trang chủ
     * Xóa tất cả thông tin người dùng, booking session, và các session attributes khác
     */
    private void handleLogout(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        
        if (session != null) {
            // Xóa tất cả session attributes sử dụng constants từ SessionUtils
            session.removeAttribute(SessionUtils.ATTR_USER);
            session.removeAttribute(SessionUtils.ATTR_USER_NAME);
            session.removeAttribute(SessionUtils.ATTR_USER_EMAIL);
            session.removeAttribute(SessionUtils.ATTR_USER_ROLE);
            session.removeAttribute(SessionUtils.ATTR_USER_ID);
            
            // Xóa các session attributes khác
            session.removeAttribute(Constants.SESSION_OAUTH_ACTION);
            session.removeAttribute(Constants.SESSION_BOOKING_SESSION);
            session.removeAttribute(Constants.SESSION_ORDER_ID);
            session.removeAttribute(Constants.SESSION_REDIRECT_AFTER_LOGIN);
            session.removeAttribute(Constants.SESSION_MESSAGE);
            session.removeAttribute(Constants.SESSION_ERROR);
            session.removeAttribute(Constants.SESSION_LOGIN_MESSAGE);
            
            // Hủy session (sẽ xóa tất cả attributes còn lại)
            session.invalidate();
        }
        
        // Chuyển hướng về trang chủ
        response.sendRedirect(request.getContextPath() + Constants.URL_HOME);
    }
}
