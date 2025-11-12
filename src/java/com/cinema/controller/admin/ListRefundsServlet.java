package com.cinema.controller.admin;


import com.cinema.dal.BookingDAO;
import com.cinema.entity.BookingDetailDTO;
import com.cinema.utils.Constants;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "ListRefundsServlet", urlPatterns = {"/list-refunds"})
public class ListRefundsServlet extends HttpServlet {

    private BookingDAO bookingDAO;

    @Override
    public void init() throws ServletException {
        bookingDAO = new BookingDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        List<BookingDetailDTO> refundRequests = bookingDAO.getRefundRequests();
        
        request.setAttribute("refundRequests", refundRequests);
        request.setAttribute("activePage", "list-refunds");
        request.getRequestDispatcher(Constants.JSP_STAFF_LIST_REFUNDS).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        int bookingID = Integer.parseInt(request.getParameter("bookingID"));
        
        if ("approve".equals(action)) {
            bookingDAO.approveRefund(bookingID);
            request.setAttribute("message", "Đã phê duyệt hoàn tiền cho đơn " + bookingID);
        } else if ("deny".equals(action)) {
            bookingDAO.denyRefund(bookingID);
            request.setAttribute("error", "Đã từ chối hoàn tiền cho đơn " + bookingID);
        }
        
        doGet(request, response); 
    }
}