package controller;

import dal.BookingDAO;
import entity.BookingDetailDTO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

/**
 * Servlet to handle user booking history and management
 */
@WebServlet(name = "BookingHistoryServlet", urlPatterns = {"/booking-history"})
public class BookingHistoryServlet extends HttpServlet {
    
    private BookingDAO bookingDAO;
    
    @Override
    public void init() throws ServletException {
        bookingDAO = new BookingDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Integer userID = (Integer) session.getAttribute("userId");
        
        // Check if user is logged in
        if (userID == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        // Get filter parameter
        String statusFilter = request.getParameter("status");
        
        // Get booking details
        List<BookingDetailDTO> bookingDetails;
        
        if (statusFilter != null && !statusFilter.isEmpty() && !"all".equals(statusFilter)) {
            // Filter by status - need to implement filtering in DAO or here
            bookingDetails = bookingDAO.getUserBookingDetails(userID);
            // Filter in Java
            bookingDetails = bookingDetails.stream()
                .filter(b -> statusFilter.equalsIgnoreCase(b.getStatus()))
                .toList();
        } else {
            // Get all bookings
            bookingDetails = bookingDAO.getUserBookingDetails(userID);
        }
        
        // Set attributes
        request.setAttribute("bookingDetails", bookingDetails);
        request.setAttribute("statusFilter", statusFilter != null ? statusFilter : "all");
        
        // Forward to JSP
        request.getRequestDispatcher("/booking-history.jsp").forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Integer userID = (Integer) session.getAttribute("userId");
        
        // Check if user is logged in
        if (userID == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        
        if ("cancel".equals(action)) {
            // Cancel booking
            int bookingID = Integer.parseInt(request.getParameter("bookingID"));
            
            // Verify booking belongs to user
            BookingDetailDTO booking = bookingDAO.getBookingDetailByID(bookingID, userID);
            
            if (booking == null) {
                request.setAttribute("error", "Không tìm thấy đơn đặt vé!");
                doGet(request, response);
                return;
            }
            
            // Check if can be cancelled
            if (!booking.canBeCancelled()) {
                request.setAttribute("error", "Không thể hủy đơn đặt vé này. Chỉ có thể hủy các đơn chưa chiếu phim.");
                doGet(request, response);
                return;
            }
            
            // Cancel the booking
            boolean cancelled = bookingDAO.cancelBooking(bookingID);
            
            if (cancelled) {
                request.setAttribute("message", "Đã hủy đơn đặt vé thành công!");
            } else {
                request.setAttribute("error", "Có lỗi xảy ra khi hủy đơn đặt vé.");
            }
        }
        
        // Redirect back to booking history
        doGet(request, response);
    }
}

