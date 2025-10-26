package controller;

import dal.DiscountDAO;
import entity.BookingSession;
import entity.Discount;
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
import java.time.format.DateTimeFormatter;
import java.util.Map;

/**
 * Servlet for Step 4: Payment with VNPay integration
 */
@WebServlet(name = "BookingPaymentServlet", urlPatterns = {"/booking/payment"})
public class BookingPaymentServlet extends HttpServlet {
    
    private DiscountDAO discountDAO;
    
    @Override
    public void init() throws ServletException {
        discountDAO = new DiscountDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        BookingSession bookingSession = BookingSessionManager.getBookingSession(session);
        
        // Validate booking session
        if (!BookingSessionManager.isValidForPayment(bookingSession)) {
            response.sendRedirect(request.getContextPath() + "/booking/select-screening");
            return;
        }
        
        // Calculate remaining time
        long remainingSeconds = BookingSessionManager.getRemainingSeconds(bookingSession.getReservationExpiry());
        request.setAttribute("remainingSeconds", remainingSeconds);
        
        // Calculate totals
        bookingSession.calculateTotals();
        
        request.setAttribute("bookingSession", bookingSession);
        
        // Forward to payment page
        request.getRequestDispatcher("/booking/payment.jsp").forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        BookingSession bookingSession = BookingSessionManager.getBookingSession(session);
        
        String action = request.getParameter("action");
        
        // Handle discount code application
        if ("applyDiscount".equals(action)) {
            handleDiscountApplication(request, response, bookingSession);
            return;
        }
        
        // Handle payment submission
        if ("payment".equals(action)) {
            handlePaymentSubmission(request, response, bookingSession);
            return;
        }
        
        doGet(request, response);
    }
    
    /**
     * Handle discount code application
     */
    private void handleDiscountApplication(HttpServletRequest request, HttpServletResponse response,
                                          BookingSession bookingSession) throws ServletException, IOException {
        
        String discountCode = request.getParameter("discountCode");
        
        if (discountCode == null || discountCode.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập mã giảm giá!");
            doGet(request, response);
            return;
        }
        
        // Validate discount code
        Discount discount = discountDAO.getDiscountByCode(discountCode.trim());
        
        if (discount == null) {
            request.setAttribute("error", "Mã giảm giá không tồn tại!");
            doGet(request, response);
            return;
        }
        
        // Check if discount is active
        if (!"Active".equals(discount.getStatus())) {
            request.setAttribute("error", "Mã giảm giá không còn hiệu lực!");
            doGet(request, response);
            return;
        }
        
        // Check if discount is within valid date range
        LocalDateTime now = LocalDateTime.now();
        if (now.isBefore(discount.getStartDate()) || now.isAfter(discount.getEndDate())) {
            request.setAttribute("error", "Mã giảm giá đã hết hạn sử dụng!");
            doGet(request, response);
            return;
        }
        
        // Check if discount has reached max usage
        if (discount.getUsageCount() >= discount.getMaxUsage()) {
            request.setAttribute("error", "Mã giảm giá đã hết lượt sử dụng!");
            doGet(request, response);
            return;
        }
        
        // Calculate discount amount
        double subtotal = bookingSession.getTicketSubtotal() + bookingSession.getFoodSubtotal();
        double discountAmount = subtotal * (discount.getDiscountPercentage() / 100.0);
        
        // Apply discount
        bookingSession.setDiscountID(discount.getDiscountID());
        bookingSession.setDiscountCode(discount.getCode());
        bookingSession.setDiscountAmount(discountAmount);
        bookingSession.calculateTotals();
        
        request.setAttribute("success", "Áp dụng mã giảm giá thành công! Giảm " + 
                            String.format("%.0f%%", discount.getDiscountPercentage()));
        doGet(request, response);
    }
    
    /**
     * Handle payment submission - redirect to VNPay
     */
    private void handlePaymentSubmission(HttpServletRequest request, HttpServletResponse response,
                                        BookingSession bookingSession) throws ServletException, IOException {
        
        // Validate booking session
        if (!BookingSessionManager.isValidForPayment(bookingSession)) {
            request.setAttribute("error", "Phiên đặt vé không hợp lệ!");
            response.sendRedirect(request.getContextPath() + "/booking/select-screening");
            return;
        }
        
        // Check terms agreement
        String agreeTerms = request.getParameter("agreeTerms");
        if (!"on".equals(agreeTerms)) {
            request.setAttribute("error", "Vui lòng đồng ý với điều khoản và điều kiện!");
            doGet(request, response);
            return;
        }
        
        // Get payment method
        String paymentMethod = request.getParameter("paymentMethod");
        if (paymentMethod == null || paymentMethod.isEmpty()) {
            paymentMethod = "VNPay";
        }
        
        // Calculate final amount
        bookingSession.calculateTotals();
        double totalAmount = bookingSession.getTotalAmount();
        
        // Generate order ID
        String orderID = VNPayUtils.generateTxnRef();
        
        // Store order ID in session for callback verification
        request.getSession().setAttribute("orderID", orderID);
        
        // Build order info
        String orderInfo = "Thanh toan ve xem phim " + bookingSession.getMovieTitle() + 
                          " - " + bookingSession.getSeatCount() + " ghe";
        
        // Get client IP
        String ipAddress = VNPayUtils.getIpAddress(request);
        
        try {
            // Create VNPay payment URL
            Map<String, String> vnpParams = VNPayUtils.createPaymentParams(
                orderID,
                (long) totalAmount,
                orderInfo,
                ipAddress
            );
            
            String paymentUrl = VNPayUtils.buildPaymentUrl(vnpParams);
            
            // Redirect to VNPay
            response.sendRedirect(paymentUrl);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Không thể tạo liên kết thanh toán. Vui lòng thử lại!");
            doGet(request, response);
        }
    }
}

