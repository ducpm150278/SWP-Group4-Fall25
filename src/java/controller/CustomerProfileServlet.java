/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dal.UserDAO;
import entity.User;
import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDate;
import java.util.List;
import java.util.ArrayList;
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
        String message = (String) session.getAttribute("message");
    if (message != null) {
        request.setAttribute("message", message);
        session.removeAttribute("message");
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
    String address = request.getParameter("address");
    String dob_str = request.getParameter("dateOfBirth");
    
    List<String> errors = new ArrayList<>();
    LocalDate dob = null;
    

    if (fullName == null || fullName.trim().isEmpty()) {
        errors.add("Họ và tên không được để trống.");
    } else if (fullName.matches(".*\\d.*")) {
        errors.add("Họ và tên không được chứa số.");
    }
    
    if (phone != null && !phone.isEmpty() && !phone.matches("^[0-9\\+\\s]*$")) {
        errors.add("Số điện thoại chỉ được chứa số (0-9), dấu cộng (+) và khoảng trắng.");
    }
    
    if (dob_str != null && !dob_str.isEmpty()) {
        try {
            dob = LocalDate.parse(dob_str); 
            if (dob.isAfter(LocalDate.now())) {
                errors.add("Ngày sinh không được ở tương lai.");
            }
        } catch (Exception e) {
            errors.add("Định dạng ngày sinh không hợp lệ (cần theo dạng yyyy-mm-dd).");
        }
    }

    User userForJsp = userDAO.getUserById(userId);
    userForJsp.setFullName(fullName); 
    userForJsp.setPhoneNumber(phone);
    userForJsp.setGender(gender);
    userForJsp.setAddress(address);
    if (dob != null) {
         userForJsp.setDateOfBirth(Date.valueOf(dob));
    } else if (dob_str != null && dob_str.isEmpty()) {
         userForJsp.setDateOfBirth(null);
    }
    if (!errors.isEmpty()) {
        request.setAttribute("errors", errors); 
        request.setAttribute("user", userForJsp);
        request.getRequestDispatcher("profile.jsp").forward(request, response);
        return; 
    }
    
    boolean success = userDAO.updateUser(userForJsp); 
    if (success) {
        User refreshedUser = userDAO.getUserById(userId);
        session.setAttribute("user", refreshedUser);
        session.setAttribute("userName", refreshedUser.getFullName());
        
        session.setAttribute("message", "Cập nhật hồ sơ thành công!");
        response.sendRedirect("CustomerProfile"); 
    } else {
        request.setAttribute("error", "Cập nhật thất bại do lỗi máy chủ!");
        request.setAttribute("user", userForJsp);
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
