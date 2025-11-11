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

@WebServlet(name = "SupportServlet", urlPatterns = {"/support"})
public class SupportServlet extends HttpServlet {

    private SupportDAO supportDAO;

    @Override
    public void init() throws ServletException {
        supportDAO = new SupportDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        if (action == null) action = "list"; 
        switch (action) {
            case "new":
                request.getRequestDispatcher("new-ticket.jsp").forward(request, response);
                break;
            case "view":
                viewTicket(request, response, userId); 
                break;
            case "list":
            default:
                listTickets(request, response, userId);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();

        Integer userId = (Integer) session.getAttribute("userId");
        User user = (User) session.getAttribute("user");
        
        if (userId == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/support");
            return;
        }
        
        switch (action) {
            case "create":
                createTicket(request, response, userId); 
                break;
            case "reply":
                if (user == null) {
                    response.sendRedirect("login.jsp"); 
                    return;
                }
                replyToTicket(request, response, user); 
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/support");
        }
    }

    private void listTickets(HttpServletRequest request, HttpServletResponse response, int userId)
            throws ServletException, IOException {
        List<SupportTicket> tickets = supportDAO.getTicketsByUserId(userId);
        request.setAttribute("tickets", tickets);
        request.getRequestDispatcher("support-history.jsp").forward(request, response);
    }

    private void viewTicket(HttpServletRequest request, HttpServletResponse response, int userId)
            throws ServletException, IOException {
        try {
            int ticketId = Integer.parseInt(request.getParameter("id"));
            SupportTicket ticket = supportDAO.getTicketById(ticketId, userId);
            
            if (ticket == null) {
                response.sendRedirect(request.getContextPath() + "/support");
                return;
            }
            
            List<SupportMessage> messages = supportDAO.getMessagesByTicketId(ticketId);
            
            request.setAttribute("ticket", ticket);
            request.setAttribute("messages", messages);
            request.getRequestDispatcher("support-detail.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/support");
        }
    }

    private void createTicket(HttpServletRequest request, HttpServletResponse response, int userId)
            throws ServletException, IOException {
        
        String title = request.getParameter("title");
        String supportType = request.getParameter("supportType");
        String messageContent = request.getParameter("comment");
        
        SupportTicket ticket = new SupportTicket();
        ticket.setUserID(userId); 
        ticket.setTitle(title);
        ticket.setSupportType(supportType);
        
        boolean success = supportDAO.createTicket(ticket, messageContent); 
        
        if (success) {
            response.sendRedirect(request.getContextPath() + "/support");
        } else {
            request.setAttribute("error", "Lỗi khi tạo ticket. Vui lòng thử lại.");
            request.getRequestDispatcher("new-ticket.jsp").forward(request, response);
        }
    }

    private void replyToTicket(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        
        try {
            int ticketId = Integer.parseInt(request.getParameter("ticketId"));
            String messageContent = request.getParameter("replyComment");

            SupportTicket ticket = supportDAO.getTicketById(ticketId, user.getUserID());
            if (ticket == null) {
                response.sendRedirect(request.getContextPath() + "/support");
                return;
            }

            SupportMessage message = new SupportMessage();
            message.setTicketID(ticketId);
            message.setSenderUserID(user.getUserID());
            message.setMessageContent(messageContent);
            message.setSenderRole(user.getRole());

            boolean success = supportDAO.addMessageAndUpdateTicket(message, "In Progress");
            
            response.sendRedirect(request.getContextPath() + "/support?action=view&id=" + ticketId);
            
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/support");
        }
    }
}