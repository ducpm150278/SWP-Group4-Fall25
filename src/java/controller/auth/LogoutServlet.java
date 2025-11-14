package controller.auth;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Servlet xử lý đăng xuất người dùng
 * Xóa tất cả thông tin người dùng khỏi session và redirect về trang chủ
 * 
 * Endpoint: /logout
 * Hỗ trợ cả GET và POST request
 */
public class LogoutServlet extends HttpServlet {

    /**
     * Xử lý request GET để đăng xuất
     * 
     * @param request HTTP request
     * @param response HTTP response
     * @throws ServletException nếu có lỗi servlet
     * @throws IOException nếu có lỗi I/O
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        handleLogout(request, response);
    }

    /**
     * Xử lý request POST để đăng xuất
     * 
     * @param request HTTP request
     * @param response HTTP response
     * @throws ServletException nếu có lỗi servlet
     * @throws IOException nếu có lỗi I/O
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        handleLogout(request, response);
    }

    /**
     * Xử lý logic đăng xuất
     * Xóa tất cả thông tin người dùng khỏi session và vô hiệu hóa session
     * Sau đó redirect về trang chủ
     * 
     * @param request HTTP request
     * @param response HTTP response
     * @throws ServletException nếu có lỗi servlet
     * @throws IOException nếu có lỗi I/O
     */
    private void handleLogout(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Lấy session hiện tại (không tạo mới nếu chưa có)
        HttpSession session = request.getSession(false);
        
        // Nếu session tồn tại, thực hiện cleanup
        if (session != null) {
            // Xóa tất cả các thuộc tính session liên quan đến người dùng
            // (user, userName, userEmail, userRole, userId, oauth_action)
            SessionHelper.clearUserSession(session);
            
            // Vô hiệu hóa session - xóa hoàn toàn session khỏi server
            session.invalidate();
        }
        
        // Redirect về trang chủ sau khi đăng xuất thành công
        response.sendRedirect(request.getContextPath() + AuthConstants.JSP_INDEX);
    }
}

