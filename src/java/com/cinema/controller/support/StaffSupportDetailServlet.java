package com.cinema.controller.support;


import com.cinema.dal.SupportDAO;
import com.cinema.entity.SupportMessage;
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

@WebServlet(name = "StaffSupportDetailServlet", urlPatterns = {"/staff-support-detail"})
public class StaffSupportDetailServlet extends HttpServlet {

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
        
        try {
            int ticketId = Integer.parseInt(request.getParameter("id"));
            SupportTicket ticket = supportDAO.getTicketById_Staff(ticketId);
            
            if (ticket == null) {
                response.sendRedirect(request.getContextPath() + Constants.URL_STAFF_SUPPORT);
                return;
            }
            
            List<SupportMessage> messages = supportDAO.getMessagesByTicketId(ticketId);
            
            request.setAttribute("ticket", ticket);
            request.setAttribute("messages", messages);
            request.setAttribute("activePage", "support-tickets"); 
            request.getRequestDispatcher(Constants.JSP_STAFF_SUPPORT_DETAIL).forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + Constants.URL_STAFF_SUPPORT);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User staff = (User) session.getAttribute(SessionUtils.ATTR_USER);

        if (staff == null) {
            response.sendRedirect(request.getContextPath() + Constants.URL_AUTH_LOGIN);
            return;
        }

        try {
            int ticketId = Integer.parseInt(request.getParameter("ticketId"));
            String messageContent = request.getParameter("replyComment");
            String newStatus = request.getParameter("newStatus"); 

            SupportMessage message = new SupportMessage();
            message.setTicketID(ticketId);
            message.setSenderUserID(staff.getUserID());
            message.setMessageContent(messageContent);
            message.setSenderRole(staff.getRole()); 
            
            boolean success = supportDAO.addMessageAndUpdateTicket(message, newStatus); 
            
            if (success) {
                session.setAttribute(Constants.SESSION_MESSAGE, "Đã gửi phản hồi thành công.");
            } else {
                session.setAttribute(Constants.SESSION_ERROR, "Lỗi khi gửi phản hồi.");
            }
            
            response.sendRedirect(request.getContextPath() + Constants.URL_STAFF_SUPPORT);
            
        } catch (Exception e) {
            session.setAttribute(Constants.SESSION_ERROR, "Dữ liệu gửi lên không hợp lệ.");
            response.sendRedirect(request.getContextPath() + Constants.URL_STAFF_SUPPORT);
        }
    }
}