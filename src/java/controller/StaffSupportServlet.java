package controller;

import dal.SupportDAO;
import entity.SupportTicket;
import entity.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "StaffSupportServlet", urlPatterns = {"/staff-support"})
public class StaffSupportServlet extends HttpServlet {

    private SupportDAO supportDAO;

    @Override
    public void init() throws ServletException {
        supportDAO = new SupportDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null || (!"Admin".equals(user.getRole()) && !"Staff".equals(user.getRole()))) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        List<SupportTicket> tickets = supportDAO.getAllTicketsForStaff();
        
        request.setAttribute("tickets", tickets);
        request.setAttribute("activePage", "support-tickets");
        request.getRequestDispatcher("staff-support-list.jsp").forward(request, response);
    }
}