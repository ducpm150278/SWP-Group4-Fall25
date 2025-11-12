package com.cinema.controller.profile;



import com.cinema.dal.UserDAO;
import com.cinema.entity.User;
import com.cinema.utils.Constants;
import com.cinema.utils.SessionUtils;
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
        User userFromSession = (User) session.getAttribute(SessionUtils.ATTR_USER);
        if (userFromSession == null) {
            response.sendRedirect(request.getContextPath() + Constants.URL_AUTH_LOGIN);
            return;
        }
        User freshUser = userDAO.getUserById(userFromSession.getUserID());
        if (freshUser != null) {
            request.setAttribute("user", freshUser);
        } else {
            request.setAttribute(Constants.SESSION_ERROR, "Logged in user not found in database.");
        }
        if (session.getAttribute(Constants.SESSION_MESSAGE) != null) {
            request.setAttribute(Constants.SESSION_MESSAGE, session.getAttribute(Constants.SESSION_MESSAGE));
            session.removeAttribute(Constants.SESSION_MESSAGE);
        }

        request.getRequestDispatcher(Constants.JSP_PROFILE_PROFILE).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User userFromSession = (User) session.getAttribute(SessionUtils.ATTR_USER);
        if (userFromSession == null) {
            response.sendRedirect(request.getContextPath() + Constants.URL_AUTH_LOGIN);
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
            session.setAttribute(SessionUtils.ATTR_USER, refreshedUser);
            session.setAttribute(SessionUtils.ATTR_USER_NAME, refreshedUser.getFullName());
            session.setAttribute(SessionUtils.ATTR_USER_EMAIL, refreshedUser.getEmail());
            session.setAttribute(Constants.SESSION_MESSAGE, "Cập nhật thành công!");
            response.sendRedirect("CustomerProfile");

        } else {
            request.setAttribute(Constants.SESSION_ERROR, "Cập nhật thất bại!");
            request.setAttribute("user", updatedUser);
            request.getRequestDispatcher(Constants.JSP_PROFILE_PROFILE).forward(request, response);
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
