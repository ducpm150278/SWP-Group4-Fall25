package controller;

import dal.BillingDAO;
import dal.SeatDAO;
import dal.TicketDAO;
import entity.BookingSession;
import entity.Ticket;
import utils.BookingSessionManager;
import utils.VNPayConfig;
import utils.VNPayUtils;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Servlet to handle VNPay payment callback
 */
@WebServlet(name = "VNPayCallbackServlet", urlPatterns = {"/vnpay-callback"})
public class VNPayCallbackServlet extends HttpServlet {
    
    private TicketDAO ticketDAO;
    private BillingDAO billingDAO;
    private SeatDAO seatDAO;
    
    @Override
    public void init() throws ServletException {
        ticketDAO = new TicketDAO();
        billingDAO = new BillingDAO();
        seatDAO = new SeatDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        BookingSession bookingSession = BookingSessionManager.getBookingSession(session);
        
        // Get VNPay response parameters
        Map<String, String> vnpParams = new HashMap<>();
        request.getParameterMap().forEach((key, values) -> {
            if (values.length > 0) {
                vnpParams.put(key, values[0]);
            }
        });
        
        // Get secure hash
        String vnpSecureHash = request.getParameter("vnp_SecureHash");
        String responseCode = request.getParameter("vnp_ResponseCode");
        String transactionNo = request.getParameter("vnp_TransactionNo");
        String orderID = request.getParameter("vnp_TxnRef");
        String amount = request.getParameter("vnp_Amount");
        
        // Validate signature
        if (!VNPayUtils.validateSignature(new HashMap<>(vnpParams), vnpSecureHash)) {
            request.setAttribute("error", "Chữ ký không hợp lệ!");
            request.setAttribute("message", "Giao dịch có thể bị giả mạo. Vui lòng liên hệ bộ phận hỗ trợ.");
            request.getRequestDispatcher("/booking/payment-failed.jsp").forward(request, response);
            return;
        }
        
        // Check response code
        if (!VNPayConfig.RESPONSE_CODE_SUCCESS.equals(responseCode)) {
            // Payment failed
            String errorMessage = VNPayUtils.getResponseMessage(responseCode);
            
            request.setAttribute("error", errorMessage);
            request.setAttribute("responseCode", responseCode);
            request.getRequestDispatcher("/booking/payment-failed.jsp").forward(request, response);
            return;
        }
        
        // Payment successful - process booking
        try {
            boolean bookingSuccess = processBooking(session, bookingSession, orderID, transactionNo);
            
            if (bookingSuccess) {
                // Clear booking session
                BookingSessionManager.clearBookingSession(session);
                
                // Store success info for display
                request.setAttribute("orderID", orderID);
                request.setAttribute("transactionNo", transactionNo);
                request.setAttribute("amount", Long.parseLong(amount) / 100); // Convert back from VNPay format
                request.setAttribute("bookingSession", bookingSession);
                
                request.getRequestDispatcher("/booking/payment-success.jsp").forward(request, response);
            } else {
                request.setAttribute("error", "Không thể hoàn tất đặt vé. Vui lòng liên hệ bộ phận hỗ trợ.");
                request.getRequestDispatcher("/booking/payment-failed.jsp").forward(request, response);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra khi xử lý đặt vé: " + e.getMessage());
            request.getRequestDispatcher("/booking/payment-failed.jsp").forward(request, response);
        }
    }
    
    /**
     * Process booking after successful payment
     */
    private boolean processBooking(HttpSession session, BookingSession bookingSession, 
                                   String orderID, String transactionNo) {
        
        // Get user from session (session attribute is "userId" with lowercase 'i')
        Integer userID = (Integer) session.getAttribute("userId");
        if (userID == null) {
            return false;
        }
        
        try {
            // Create tickets
            List<Ticket> tickets = new ArrayList<>();
            LocalDateTime bookingTime = LocalDateTime.now();
            
            for (Integer seatID : bookingSession.getSelectedSeatIDs()) {
                Ticket ticket = new Ticket(
                    bookingSession.getScreeningID(),
                    userID,
                    seatID,
                    bookingSession.getTicketPrice()
                );
                ticket.setBookingTime(bookingTime);
                tickets.add(ticket);
            }
            
            // Insert tickets into database
            List<Integer> ticketIDs = ticketDAO.createTickets(tickets);
            
            if (ticketIDs.isEmpty()) {
                return false;
            }
            
            // Calculate amount per ticket for billing
            double totalAmount = bookingSession.getTotalAmount();
            double amountPerTicket = totalAmount / ticketIDs.size();
            
            // Create billing records
            boolean billingCreated = billingDAO.createBillingsForTickets(
                userID,
                ticketIDs,
                bookingSession.getDiscountID(),
                amountPerTicket,
                "VNPay"
            );
            
            if (!billingCreated) {
                return false;
            }
            
            // Update discount usage if discount was applied
            if (bookingSession.getDiscountID() != null) {
                billingDAO.updateDiscountUsage(bookingSession.getDiscountID());
            }
            
            // Release seat reservations (they're now booked)
            seatDAO.releaseReservationsBySession(bookingSession.getReservationSessionID());
            
            // Update screening available seats
            for (int i = 0; i < ticketIDs.size(); i++) {
                ticketDAO.updateScreeningAvailableSeats(bookingSession.getScreeningID());
            }
            
            return true;
            
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}

