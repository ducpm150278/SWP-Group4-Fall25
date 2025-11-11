package controller;

import dal.SupportDAO;
import entity.SupportMessage;
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
        User user = (User) session.getAttribute("user");

        if (user == null || (!"Admin".equals(user.getRole()) && !"Staff".equals(user.getRole()))) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        try {
            int ticketId = Integer.parseInt(request.getParameter("id"));
            SupportTicket ticket = supportDAO.getTicketById_Staff(ticketId);
            
            if (ticket == null) {
                response.sendRedirect(request.getContextPath() + "/staff-support");
                return;
            }
            
            List<SupportMessage> messages = supportDAO.getMessagesByTicketId(ticketId);
            
            request.setAttribute("ticket", ticket);
            request.setAttribute("messages", messages);
            request.setAttribute("activePage", "support-tickets"); 
            request.getRequestDispatcher("staff-support-detail.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/staff-support");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User staff = (User) session.getAttribute("user");

        if (staff == null) {
            response.sendRedirect("login.jsp");
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
                session.setAttribute("message", "Đã gửi phản hồi thành công.");
            } else {
                session.setAttribute("error", "Lỗi khi gửi phản hồi.");
            }
            
            response.sendRedirect(request.getContextPath() + "/staff-support");
            
        } catch (Exception e) {
            session.setAttribute("error", "Dữ liệu gửi lên không hợp lệ.");
            response.sendRedirect(request.getContextPath() + "/staff-support");
        }
    }
}