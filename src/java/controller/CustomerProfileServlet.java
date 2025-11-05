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
        HttpSession session = request.getSession();
        User userFromSession = (User) session.getAttribute("user");
        if (userFromSession == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        User freshUser = userDAO.getUserById(userFromSession.getUserID());
        if (freshUser != null) {
            request.setAttribute("user", freshUser);
        } else {
            request.setAttribute("error", "Logged in user not found in database.");
        }
        if (session.getAttribute("message") != null) {
            request.setAttribute("message", session.getAttribute("message"));
            session.removeAttribute("message");
        }

        request.getRequestDispatcher("profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User userFromSession = (User) session.getAttribute("user");
        if (userFromSession == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        int userId = userFromSession.getUserID();
        String fullName = request.getParameter("fullName");
        String phone = request.getParameter("phoneNumber");
        String gender = request.getParameter("gender");
        String dob_str = request.getParameter("dateOfBirth");
        String address = request.getParameter("address");
        Date sqlDateOfBirth = null;
        if (dob_str != null && !dob_str.isEmpty()) {
            try {
                sqlDateOfBirth = Date.valueOf(dob_str);
            } catch (IllegalArgumentException e) {
                System.err.println("Invalid date format: " + dob_str);
            }
        }
        User updatedUser = new User();
        updatedUser.setUserID(userId);
        updatedUser.setFullName(fullName);
        updatedUser.setPhoneNumber(phone);
        updatedUser.setGender(gender);
        updatedUser.setAddress(address);
        updatedUser.setDateOfBirth(sqlDateOfBirth);
        
        boolean success = userDAO.updateUser(updatedUser);
        if (success) {
            User refreshedUser = userDAO.getUserById(userId);
            session.setAttribute("user", refreshedUser);
            session.setAttribute("userName", refreshedUser.getFullName());
            session.setAttribute("userEmail", refreshedUser.getEmail());
            session.setAttribute("message", "Cập nhật thành công!");
            response.sendRedirect("CustomerProfile");

        } else {
            request.setAttribute("error", "Cập nhật thất bại!");
            request.setAttribute("user", updatedUser);
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
