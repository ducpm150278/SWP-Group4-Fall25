package controller;

import dal.BillingDAO;
import dal.BookingDAO;
import dal.SeatDAO;
import dal.TicketDAO;
import entity.Booking;
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
    private BookingDAO bookingDAO;
    
    @Override
    public void init() throws ServletException {
        ticketDAO = new TicketDAO();
        billingDAO = new BillingDAO();
        seatDAO = new SeatDAO();
        bookingDAO = new BookingDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        System.out.println("=== VNPay Callback Received ===");
        
        HttpSession session = request.getSession();
        BookingSession bookingSession = BookingSessionManager.getBookingSession(session);
        
        // Get VNPay response parameters
        Map<String, String> vnpParams = new HashMap<>();
        request.getParameterMap().forEach((key, values) -> {
            if (values.length > 0) {
                vnpParams.put(key, values[0]);
                System.out.println(key + " = " + values[0]);
            }
        });
        
        // Get secure hash
        String vnpSecureHash = request.getParameter("vnp_SecureHash");
        String responseCode = request.getParameter("vnp_ResponseCode");
        String transactionNo = request.getParameter("vnp_TransactionNo");
        String orderID = request.getParameter("vnp_TxnRef");
        String amount = request.getParameter("vnp_Amount");
        
        System.out.println("Response Code: " + responseCode);
        System.out.println("Transaction No: " + transactionNo);
        System.out.println("Order ID: " + orderID);
        System.out.println("Amount: " + amount);
        
        // Check if booking session exists
        if (bookingSession == null) {
            System.out.println("ERROR: BookingSession is null!");
            request.setAttribute("error", "Phiên đặt vé đã hết hạn. Vui lòng đặt vé lại.");
            request.getRequestDispatcher("/booking/payment-failed.jsp").forward(request, response);
            return;
        }
        
        // Validate signature
        Map<String, String> paramsForValidation = new HashMap<>(vnpParams);
        boolean signatureValid = VNPayUtils.validateSignature(paramsForValidation, vnpSecureHash);
        System.out.println("Signature Valid: " + signatureValid);
        
        if (!signatureValid) {
            System.out.println("ERROR: Invalid signature!");
            request.setAttribute("error", "Chữ ký không hợp lệ!");
            request.setAttribute("message", "Giao dịch có thể bị giả mạo. Vui lòng liên hệ bộ phận hỗ trợ.");
            request.getRequestDispatcher("/booking/payment-failed.jsp").forward(request, response);
            return;
        }
        
        // Check response code
        if (!VNPayConfig.RESPONSE_CODE_SUCCESS.equals(responseCode)) {
            // Payment failed
            String errorMessage = VNPayUtils.getResponseMessage(responseCode);
            System.out.println("ERROR: Payment failed with code: " + responseCode);
            
            request.setAttribute("error", errorMessage);
            request.setAttribute("responseCode", responseCode);
            request.getRequestDispatcher("/booking/payment-failed.jsp").forward(request, response);
            return;
        }
        
        System.out.println("Payment successful, processing booking...");
        
        // Payment successful - process booking
        try {
            boolean bookingSuccess = processBooking(session, bookingSession, orderID, transactionNo);
            
            if (bookingSuccess) {
                System.out.println("SUCCESS: Booking processed successfully!");
                
                // Store success info for display BEFORE clearing session
                request.setAttribute("orderID", orderID);
                request.setAttribute("transactionNo", transactionNo);
                request.setAttribute("amount", Long.parseLong(amount) / 100); // Convert back from VNPay format
                request.setAttribute("bookingSession", bookingSession);
                
                // Clear booking session
                BookingSessionManager.clearBookingSession(session);
                
                request.getRequestDispatcher("/booking/payment-success.jsp").forward(request, response);
            } else {
                System.out.println("ERROR: processBooking returned false!");
                request.setAttribute("error", "Không thể hoàn tất đặt vé. Vui lòng liên hệ bộ phận hỗ trợ.");
                request.getRequestDispatcher("/booking/payment-failed.jsp").forward(request, response);
            }
            
        } catch (Exception e) {
            System.out.println("EXCEPTION in booking process: " + e.getMessage());
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
        
        System.out.println("Processing booking for order: " + orderID);
        
        // Get user from session (session attribute is "userId" with lowercase 'i')
        Integer userID = (Integer) session.getAttribute("userId");
        System.out.println("User ID from session: " + userID);
        
        if (userID == null) {
            System.out.println("ERROR: UserID is null!");
            return false;
        }
        
        try {
            LocalDateTime bookingTime = LocalDateTime.now();
            
            // Step 1: Create Booking first
            System.out.println("=== Step 1: Creating Booking ===");
            String bookingCode = bookingDAO.generateBookingCode();
            double totalAmount = bookingSession.getTotalAmount();
            double discountAmount = bookingSession.getDiscountAmount();
            double finalAmount = totalAmount - discountAmount;
            
            Booking booking = new Booking(
                bookingCode,
                userID,
                bookingSession.getScreeningID(),
                totalAmount,
                discountAmount,
                finalAmount,
                "VNPay"
            );
            booking.setBookingDate(bookingTime);
            booking.setPaymentDate(bookingTime);
            booking.setPaymentStatus("Completed");
            booking.setStatus("Confirmed");
            booking.setNotes("Order ID: " + orderID + " | Transaction: " + transactionNo);
            
            int bookingID = bookingDAO.createBooking(booking);
            
            if (bookingID <= 0) {
                System.out.println("ERROR: Failed to create booking!");
                return false;
            }
            
            System.out.println("✓ Booking created with ID: " + bookingID);
            
            // Step 2: Create tickets with BookingID
            System.out.println("=== Step 2: Creating Tickets ===");
            List<Ticket> tickets = new ArrayList<>();
            
            System.out.println("Creating tickets for " + bookingSession.getSelectedSeatIDs().size() + " seats");
            
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
            
            // Insert tickets into database with BookingID
            System.out.println("Inserting tickets into database...");
            List<Integer> ticketIDs = ticketDAO.createTickets(tickets, bookingID);
            System.out.println("Created " + ticketIDs.size() + " tickets");
            
            if (ticketIDs.isEmpty()) {
                System.out.println("ERROR: No tickets created!");
                return false;
            }
            
            // Step 3: Create billing record (linked to booking, not individual tickets)
            System.out.println("=== Step 3: Creating Billing ===");
            // Note: Current BillingDAO might need update to work with Bookings
            // For now, we can skip detailed billing or create a simplified version
            System.out.println("Billing will be handled through Booking record");
            
            // Update discount usage if discount was applied
            if (bookingSession.getDiscountID() != null) {
                System.out.println("Updating discount usage for discount ID: " + bookingSession.getDiscountID());
                billingDAO.updateDiscountUsage(bookingSession.getDiscountID());
            }
            
            // Release seat reservations (they're now booked)
            System.out.println("Releasing seat reservations...");
            seatDAO.releaseReservationsBySession(bookingSession.getReservationSessionID());
            
            // Update screening available seats
            System.out.println("Updating screening available seats...");
            for (int i = 0; i < ticketIDs.size(); i++) {
                ticketDAO.updateScreeningAvailableSeats(bookingSession.getScreeningID());
            }
            
            System.out.println("Booking process completed successfully!");
            return true;
            
        } catch (Exception e) {
            System.out.println("EXCEPTION in processBooking: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}

