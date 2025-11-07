package controller;

import dal.DiscountDAO;
import dal.SeatDAO;
import dal.ComboDAO;
import dal.FoodDAO;
import entity.BookingSession;
import entity.Discount;
import entity.Seat;
import entity.Combo;
import entity.Food;
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
import java.util.List;
import java.util.ArrayList;
import java.util.HashMap;

/**
 * Servlet for Step 4: Payment with VNPay integration
 */
@WebServlet(name = "BookingPaymentServlet", urlPatterns = {"/booking/payment"})
public class BookingPaymentServlet extends HttpServlet {
    
    private DiscountDAO discountDAO;
    private SeatDAO seatDAO;
    private ComboDAO comboDAO;
    private FoodDAO foodDAO;
    
    @Override
    public void init() throws ServletException {
        discountDAO = new DiscountDAO();
        seatDAO = new SeatDAO();
        comboDAO = new ComboDAO();
        foodDAO = new FoodDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        BookingSession bookingSession = BookingSessionManager.getBookingSession(session);
        
        System.out.println("=== BookingPaymentServlet GET ===");
        System.out.println("Session ID: " + session.getId());
        System.out.println("Selected Combos in Session: " + bookingSession.getSelectedCombos());
        System.out.println("Selected Foods in Session: " + bookingSession.getSelectedFoods());
        System.out.println("Food Subtotal: " + bookingSession.getFoodSubtotal());
        
        // Validate booking session
        if (!BookingSessionManager.isValidForPayment(bookingSession)) {
            response.sendRedirect(request.getContextPath() + "/booking/select-screening");
            return;
        }
        
        // Calculate remaining time
        long remainingSeconds = BookingSessionManager.getRemainingSeconds(bookingSession.getReservationExpiry());
        request.setAttribute("remainingSeconds", remainingSeconds);
        
        // Get seat details for breakdown
        List<Map<String, Object>> seatDetails = new ArrayList<>();
        double baseTicketPrice = bookingSession.getTicketPrice();
        for (Integer seatID : bookingSession.getSelectedSeatIDs()) {
            Seat seat = seatDAO.getSeatByID(seatID);
            if (seat != null) {
                Map<String, Object> detail = new HashMap<>();
                detail.put("label", seat.getSeatLabel());
                detail.put("type", seat.getSeatType());
                detail.put("multiplier", seat.getPriceMultiplier());
                detail.put("price", baseTicketPrice * seat.getPriceMultiplier());
                seatDetails.add(detail);
            }
        }
        request.setAttribute("seatDetails", seatDetails);
        
        // Get combo details for breakdown
        List<Map<String, Object>> comboDetails = new ArrayList<>();
        for (Map.Entry<Integer, Integer> entry : bookingSession.getSelectedCombos().entrySet()) {
            Combo combo = comboDAO.getComboById(entry.getKey());
            if (combo != null) {
                Map<String, Object> detail = new HashMap<>();
                detail.put("name", combo.getComboName());
                detail.put("quantity", entry.getValue());
                double price = combo.getDiscountPrice() != null ? 
                              combo.getDiscountPrice().doubleValue() : 
                              combo.getTotalPrice().doubleValue();
                detail.put("price", price);
                detail.put("total", price * entry.getValue());
                comboDetails.add(detail);
            }
        }
        request.setAttribute("comboDetails", comboDetails);
        
        // Get food details for breakdown
        List<Map<String, Object>> foodDetails = new ArrayList<>();
        for (Map.Entry<Integer, Integer> entry : bookingSession.getSelectedFoods().entrySet()) {
            Food food = foodDAO.getFoodById(entry.getKey());
            if (food != null) {
                Map<String, Object> detail = new HashMap<>();
                detail.put("name", food.getFoodName());
                detail.put("quantity", entry.getValue());
                detail.put("price", food.getPrice().doubleValue());
                detail.put("total", food.getPrice().doubleValue() * entry.getValue());
                foodDetails.add(detail);
            }
        }
        request.setAttribute("foodDetails", foodDetails);
        
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
        System.out.println("Attempting to apply discount code: [" + discountCode.trim() + "]");
        Discount discount = discountDAO.getDiscountByCode(discountCode.trim());
        
        if (discount == null) {
            System.out.println("Discount not found in database for code: [" + discountCode.trim() + "]");
            request.setAttribute("error", "Mã giảm giá không tồn tại!");
            doGet(request, response);
            return;
        }
        
        System.out.println("Discount found: " + discount.getCode() + ", Status: " + discount.getStatus());
        
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
        // Use actual usage count from Bookings table to ensure accuracy
        int actualUsageCount = discountDAO.getActualUsageCount(discount.getDiscountID());
        System.out.println("Discount validation - Code: " + discount.getCode() + 
                         ", MaxUsage: " + discount.getMaxUsage() + 
                         ", Stored UsageCount: " + discount.getUsageCount() + 
                         ", Actual UsageCount: " + actualUsageCount);
        
        if (actualUsageCount >= discount.getMaxUsage()) {
            request.setAttribute("error", "Mã giảm giá đã hết lượt sử dụng! (Đã dùng " + actualUsageCount + "/" + discount.getMaxUsage() + " lượt)");
            doGet(request, response);
            return;
        }
        
        // Calculate discount amount based on type
        double subtotal = bookingSession.getTicketSubtotal() + bookingSession.getFoodSubtotal();
        double discountAmount = discount.calculateDiscountAmount(subtotal);
        
        // Debug logging for discount calculation
        System.out.println("Discount calculation - Code: " + discount.getCode() + 
                         ", Type: " + discount.getDiscountType() + 
                         ", DiscountValue: " + discount.getDiscountValue() + 
                         ", Subtotal: " + subtotal + 
                         ", Calculated Discount Amount: " + discountAmount);
        
        // Apply discount
        bookingSession.setDiscountID(discount.getDiscountID());
        bookingSession.setDiscountCode(discount.getCode());
        bookingSession.setDiscountAmount(discountAmount);
        bookingSession.calculateTotals();
        
        // CRITICAL: Save bookingSession back to session to ensure persistence
        request.getSession().setAttribute("bookingSession", bookingSession);
        
        // Format success message based on discount type
        String successMessage;
        if ("Percentage".equals(discount.getDiscountType())) {
            successMessage = "Áp dụng mã giảm giá thành công! Giảm " + 
                           String.format("%.0f%%", discount.getDiscountValue());
        } else {
            successMessage = "Áp dụng mã giảm giá thành công! Giảm " + 
                           String.format("%,.0f đ", discount.getDiscountValue());
        }
        request.setAttribute("success", successMessage);
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
        
        System.out.println("=== Payment Submission ===");
        System.out.println("Session ID: " + request.getSession().getId());
        System.out.println("Selected Combos: " + bookingSession.getSelectedCombos());
        System.out.println("Selected Foods: " + bookingSession.getSelectedFoods());
        System.out.println("Food Subtotal: " + bookingSession.getFoodSubtotal());
        System.out.println("Total Amount: " + totalAmount);
        
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
            // Create VNPay payment URL with dynamic return URL
            Map<String, String> vnpParams = VNPayUtils.createPaymentParams(
                orderID,
                (long) totalAmount,
                orderInfo,
                ipAddress,
                request
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

