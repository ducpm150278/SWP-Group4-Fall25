/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dal.UserDAO;
import entity.User;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.sql.Date;

/**
 *
 * @author leanh
 */
@WebServlet(name = "CustomerProfileServlet", urlPatterns = {"/CustomerProfile"})
public class CustomerProfileServlet extends HttpServlet {

    private UserDAO userDAO = new UserDAO();

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet CustomerProfileServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet CustomerProfileServlet at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = "customer1@gmail.com";
        User user = userDAO.getUserByEmail(email);
        request.getSession().setAttribute("user", user);
        request.getRequestDispatcher("profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String userIdParam = request.getParameter("userId");
        if (userIdParam == null || userIdParam.isEmpty()) {
            System.out.println("⚠️ userId is missing in POST request!");
            request.setAttribute("error", "Thiếu thông tin người dùng (userId).");
            request.getRequestDispatcher("profile.jsp").forward(request, response);
            return; // stop here, don’t continue
        }

        int userId = Integer.parseInt(userIdParam);
        String fullName = request.getParameter("fullName");
        String phone = request.getParameter("phone");
        String gender = request.getParameter("gender");
        String dob = request.getParameter("birthdate");
        String address = request.getParameter("address");

        User updatedUser = new User();
        updatedUser.setUserID(userId);
        updatedUser.setFullName(fullName);
        updatedUser.setPhoneNumber(phone);
        updatedUser.setGender(gender);
        updatedUser.setDateOfBirth(Date.valueOf(dob));
        updatedUser.setAddress(address);

        boolean success = userDAO.updateUser(updatedUser);

        if (success) {
            // fetch lai user cho dung voi field
            User refreshedUser = userDAO.getUserByEmail("customer1@gmail.com");

            // Update lai session 
            HttpSession session = request.getSession();
            session.setAttribute("user", refreshedUser);

            // Show confirm / re-display updated info
            request.setAttribute("message", "Cập nhật thành công!");
            request.getRequestDispatcher("profile.jsp").forward(request, response);
        } else {
            request.setAttribute("error", "Cập nhật thất bại!");
            request.getRequestDispatcher("profile.jsp").forward(request, response);
        }

    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
