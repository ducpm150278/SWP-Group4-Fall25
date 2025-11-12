package com.cinema.controller.support;


import com.cinema.dal.SupportDAO;
import com.cinema.entity.SupportTicket;
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
        User user = (User) session.getAttribute(SessionUtils.ATTR_USER);

        if (user == null || (!Constants.ROLE_ADMIN.equals(user.getRole()) && !Constants.ROLE_STAFF.equals(user.getRole()))) {
            response.sendRedirect(request.getContextPath() + Constants.URL_AUTH_LOGIN);
            return;
        }
        
        List<SupportTicket> tickets = supportDAO.getAllTicketsForStaff();
        
        request.setAttribute("tickets", tickets);
        request.setAttribute("activePage", "support-tickets");
        request.getRequestDispatcher(Constants.JSP_STAFF_SUPPORT_LIST).forward(request, response);
    }
}