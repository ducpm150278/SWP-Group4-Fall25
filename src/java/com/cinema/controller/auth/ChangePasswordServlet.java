package com.cinema.controller.auth;


import com.cinema.dal.UserDAO;
import com.cinema.entity.User;
import com.cinema.utils.Constants;
import com.cinema.utils.SessionUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Servlet to handle user password change
 */
@WebServlet(name = "ChangePasswordServlet", urlPatterns = {"/ChangePassword"})
public class ChangePasswordServlet extends HttpServlet {

    private UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher(Constants.JSP_PROFILE_CHANGE_PASSWORD).forward(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User userFromSession = (User) SessionUtils.getUser(session);

        if (userFromSession == null) {
            response.sendRedirect(request.getContextPath() + Constants.URL_AUTH_LOGIN);
            return;
        }

        User user = userDAO.getUserById(userFromSession.getUserID());

        if (user == null) {
            request.setAttribute("error", "Không tìm thấy người dùng!");
            request.getRequestDispatcher(Constants.JSP_PROFILE_CHANGE_PASSWORD).forward(request, response);
            return;
        }

        String oldPassword = request.getParameter("oldPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        // Validate input
        if (oldPassword == null || oldPassword.trim().isEmpty() ||
            newPassword == null || newPassword.trim().isEmpty() ||
            confirmPassword == null || confirmPassword.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng điền đầy đủ thông tin!");
            request.getRequestDispatcher(Constants.JSP_PROFILE_CHANGE_PASSWORD).forward(request, response);
            return;
        }

        // Validate password length
        if (newPassword.length() < Constants.MIN_PASSWORD_LENGTH) {
            request.setAttribute("error", "Mật khẩu mới phải có ít nhất " + Constants.MIN_PASSWORD_LENGTH + " ký tự!");
            request.getRequestDispatcher(Constants.JSP_PROFILE_CHANGE_PASSWORD).forward(request, response);
            return;
        }

        if (user.getPassword() == null || !user.getPassword().equals(oldPassword)) {
            request.setAttribute("error", "Mật khẩu cũ không chính xác!");
            request.getRequestDispatcher(Constants.JSP_PROFILE_CHANGE_PASSWORD).forward(request, response);
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("error", "Mật khẩu xác nhận không khớp!");
            request.getRequestDispatcher(Constants.JSP_PROFILE_CHANGE_PASSWORD).forward(request, response);
            return;
        }

        boolean success = userDAO.updatePassword(user.getUserID(), newPassword);
        if (!success) {
            request.setAttribute("error", "Đổi mật khẩu thất bại!");
        } else {
            request.setAttribute("message", "Đổi mật khẩu thành công!");
        }

        request.getRequestDispatcher(Constants.JSP_PROFILE_CHANGE_PASSWORD).forward(request, response);
    }
}
