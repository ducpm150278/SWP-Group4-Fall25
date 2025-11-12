package com.cinema.controller.booking;

import com.cinema.dal.DiscountDAO;
import com.cinema.dal.SeatDAO;
import com.cinema.dal.ComboDAO;
import com.cinema.dal.FoodDAO;
import com.cinema.entity.BookingSession;
import com.cinema.entity.Discount;
import com.cinema.entity.Seat;
import com.cinema.entity.Combo;
import com.cinema.entity.Food;
import com.cinema.utils.BookingSessionManager;
import com.cinema.utils.Constants;
import com.cinema.utils.VNPayConfig;
import com.cinema.utils.VNPayUtils;

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
 * Servlet xử lý bước 4: Thanh toán với tích hợp VNPay
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
    
    /**
     * Xử lý request GET - hiển thị trang thanh toán
     * Flow: Validate booking session -> Tính thời gian còn lại -> Lấy chi tiết ghế/combo/food -> Tính tổng -> Hiển thị
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        BookingSession bookingSession = BookingSessionManager.getBookingSession(session);
        
        // Bước 1: Validate booking session có đủ thông tin để thanh toán không
        // Phải có: screening, seats, và reservation chưa hết hạn
        if (!BookingSessionManager.isValidForPayment(bookingSession)) {
            response.sendRedirect(request.getContextPath() + Constants.URL_BOOKING_SELECT_SCREENING);
            return;
        }
        
        // Bước 2: Tính thời gian còn lại của reservation (tính bằng giây)
        // Hiển thị trên frontend để người dùng biết còn bao nhiêu thời gian để thanh toán
        long remainingSeconds = BookingSessionManager.getRemainingSeconds(bookingSession.getReservationExpiry());
        request.setAttribute("remainingSeconds", remainingSeconds);
        
        // Bước 3: Lấy chi tiết ghế để hiển thị breakdown
        // Bao gồm: label, type, multiplier, và giá của từng ghế
        List<Map<String, Object>> seatDetails = new ArrayList<>();
        double baseTicketPrice = bookingSession.getTicketPrice();
        for (Integer seatID : bookingSession.getSelectedSeatIDs()) {
            Seat seat = seatDAO.getSeatByID(seatID);
            if (seat != null) {
                Map<String, Object> detail = new HashMap<>();
                detail.put("label", seat.getSeatLabel());              // Ví dụ: "A1", "B5"
                detail.put("type", seat.getSeatType());                // Ví dụ: "VIP", "Normal"
                detail.put("multiplier", seat.getPriceMultiplier());   // Ví dụ: 1.5, 1.0
                detail.put("price", baseTicketPrice * seat.getPriceMultiplier()); // Giá thực tế của ghế
                seatDetails.add(detail);
            }
        }
        request.setAttribute("seatDetails", seatDetails);
        
        // Bước 4: Lấy chi tiết combo để hiển thị breakdown
        // Bao gồm: tên, số lượng, giá (ưu tiên discountPrice), và tổng tiền
        List<Map<String, Object>> comboDetails = new ArrayList<>();
        for (Map.Entry<Integer, Integer> entry : bookingSession.getSelectedCombos().entrySet()) {
            Combo combo = comboDAO.getComboById(entry.getKey());
            if (combo != null) {
                Map<String, Object> detail = new HashMap<>();
                detail.put("name", combo.getComboName());
                detail.put("quantity", entry.getValue());
                // Ưu tiên dùng discountPrice nếu có, nếu không thì dùng totalPrice
                double price = combo.getDiscountPrice() != null ? 
                              combo.getDiscountPrice().doubleValue() : 
                              combo.getTotalPrice().doubleValue();
                detail.put("price", price);
                detail.put("total", price * entry.getValue()); // Tổng = giá * số lượng
                comboDetails.add(detail);
            }
        }
        request.setAttribute("comboDetails", comboDetails);
        
        // Bước 5: Lấy chi tiết đồ ăn để hiển thị breakdown
        // Bao gồm: tên, số lượng, giá, và tổng tiền
        List<Map<String, Object>> foodDetails = new ArrayList<>();
        for (Map.Entry<Integer, Integer> entry : bookingSession.getSelectedFoods().entrySet()) {
            Food food = foodDAO.getFoodById(entry.getKey());
            if (food != null) {
                Map<String, Object> detail = new HashMap<>();
                detail.put("name", food.getFoodName());
                detail.put("quantity", entry.getValue());
                detail.put("price", food.getPrice().doubleValue());
                detail.put("total", food.getPrice().doubleValue() * entry.getValue()); // Tổng = giá * số lượng
                foodDetails.add(detail);
            }
        }
        request.setAttribute("foodDetails", foodDetails);
        
        // Bước 6: Tính tổng tiền (ticketSubtotal + foodSubtotal - discountAmount)
        // calculateTotals() sẽ tính totalAmount và finalAmount
        bookingSession.calculateTotals();
        
        request.setAttribute("bookingSession", bookingSession);
        
        // Bước 7: Chuyển tiếp đến trang JSP thanh toán
        request.getRequestDispatcher(Constants.JSP_BOOKING_PAYMENT).forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        BookingSession bookingSession = BookingSessionManager.getBookingSession(session);
        
        String action = request.getParameter("action");
        
        // Handle discount code application
        if (Constants.ACTION_APPLY_DISCOUNT.equals(action)) {
            handleDiscountApplication(request, response, bookingSession);
            return;
        }
        
        // Handle payment submission
        if (Constants.ACTION_PAYMENT.equals(action)) {
            handlePaymentSubmission(request, response, bookingSession);
            return;
        }
        
        doGet(request, response);
    }
    
    /**
     * Xử lý áp dụng mã giảm giá
     * Flow: Validate discount code -> Kiểm tra status -> Kiểm tra date range -> Kiểm tra usage limit -> Tính discount amount -> Áp dụng
     */
    private void handleDiscountApplication(HttpServletRequest request, HttpServletResponse response,
                                          BookingSession bookingSession) throws ServletException, IOException {
        
        // Bước 1: Lấy mã giảm giá từ form
        String discountCode = request.getParameter("discountCode");
        
        // Bước 2: Kiểm tra mã giảm giá không được để trống
        if (discountCode == null || discountCode.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập mã giảm giá!");
            doGet(request, response);
            return;
        }
        
        // Bước 3: Tìm discount trong database theo code
        Discount discount = discountDAO.getDiscountByCode(discountCode.trim());
        
        if (discount == null) {
            request.setAttribute("error", "Mã giảm giá không tồn tại!");
            doGet(request, response);
            return;
        }
        
        // Bước 4: Kiểm tra discount có đang active không
        // Chỉ cho phép sử dụng discount có status Active
        if (!Constants.DISCOUNT_STATUS_ACTIVE.equals(discount.getStatus())) {
            request.setAttribute("error", "Mã giảm giá không còn hiệu lực!");
            doGet(request, response);
            return;
        }
        
        // Bước 5: Kiểm tra discount có trong khoảng thời gian hợp lệ không
        // Discount phải có startDate <= now <= endDate
        LocalDateTime now = LocalDateTime.now();
        if (now.isBefore(discount.getStartDate()) || now.isAfter(discount.getEndDate())) {
            request.setAttribute("error", "Mã giảm giá đã hết hạn sử dụng!");
            doGet(request, response);
            return;
        }
        
        // Bước 6: Kiểm tra discount có vượt quá số lượt sử dụng tối đa không
        // Sử dụng actualUsageCount từ Bookings table để đảm bảo độ chính xác
        // Đếm số booking đã sử dụng discount này
        int actualUsageCount = discountDAO.getActualUsageCount(discount.getDiscountID());
        
        if (actualUsageCount >= discount.getMaxUsage()) {
            request.setAttribute("error", "Mã giảm giá đã hết lượt sử dụng! (Đã dùng " + actualUsageCount + "/" + discount.getMaxUsage() + " lượt)");
            doGet(request, response);
            return;
        }
        
        // Bước 7: Tính số tiền giảm giá dựa trên loại discount
        // subtotal = ticketSubtotal + foodSubtotal (tổng trước khi giảm)
        double subtotal = bookingSession.getTicketSubtotal() + bookingSession.getFoodSubtotal();
        // discountAmount được tính dựa trên discountType (Percentage hoặc Fixed)
        double discountAmount = discount.calculateDiscountAmount(subtotal);
        
        // Bước 8: Áp dụng discount vào booking session
        bookingSession.setDiscountID(discount.getDiscountID());
        bookingSession.setDiscountCode(discount.getCode());
        bookingSession.setDiscountAmount(discountAmount);
        // Tính lại tổng tiền sau khi áp dụng discount
        bookingSession.calculateTotals();
        
        // Bước 9: QUAN TRỌNG: Lưu bookingSession lại vào session để đảm bảo persistence
        request.getSession().setAttribute("bookingSession", bookingSession);
        
        // Bước 10: Format thông báo thành công dựa trên loại discount
        String successMessage;
        if (Constants.DISCOUNT_TYPE_PERCENTAGE.equals(discount.getDiscountType())) {
            // Discount theo phần trăm: "Giảm 20%"
            successMessage = "Áp dụng mã giảm giá thành công! Giảm " + 
                           String.format("%.0f%%", discount.getDiscountValue());
        } else {
            // Discount theo số tiền cố định: "Giảm 50,000 đ"
            successMessage = "Áp dụng mã giảm giá thành công! Giảm " + 
                           String.format("%,.0f đ", discount.getDiscountValue());
        }
        request.setAttribute("success", successMessage);
        doGet(request, response);
    }
    
    /**
     * Xử lý submit thanh toán - chuyển hướng đến VNPay
     * Flow: Validate booking session -> Kiểm tra đồng ý điều khoản -> Tính final amount -> Tạo order ID -> Tạo VNPay URL -> Redirect
     */
    private void handlePaymentSubmission(HttpServletRequest request, HttpServletResponse response,
                                        BookingSession bookingSession) throws ServletException, IOException {
        
        // Bước 1: Validate booking session có đủ thông tin để thanh toán không
        if (!BookingSessionManager.isValidForPayment(bookingSession)) {
            request.setAttribute("error", "Phiên đặt vé không hợp lệ!");
            response.sendRedirect(request.getContextPath() + Constants.URL_BOOKING_SELECT_SCREENING);
            return;
        }
        
        // Bước 2: Kiểm tra người dùng đã đồng ý với điều khoản chưa
        // Checkbox "agreeTerms" phải được check
        String agreeTerms = request.getParameter("agreeTerms");
        if (!"on".equals(agreeTerms)) {
            request.setAttribute("error", "Vui lòng đồng ý với điều khoản và điều kiện!");
            doGet(request, response);
            return;
        }
        
        // Bước 3: Lấy phương thức thanh toán (mặc định là VNPay)
        String paymentMethod = request.getParameter("paymentMethod");
        if (paymentMethod == null || paymentMethod.isEmpty()) {
            paymentMethod = Constants.PAYMENT_METHOD_VNPAY;
        }
        
        // Bước 4: Tính số tiền cuối cùng cần thanh toán
        bookingSession.calculateTotals();
        // totalAmount = ticketSubtotal + foodSubtotal (tổng trước khi giảm giá)
        double totalAmount = bookingSession.getTotalAmount();
        // finalAmount = totalAmount - discountAmount (tổng sau khi giảm giá) - đây là số tiền khách hàng thực sự phải trả
        double finalAmount = totalAmount - bookingSession.getDiscountAmount();
        
        // Bước 5: Tạo order ID duy nhất cho giao dịch
        // Order ID này sẽ được sử dụng để track giao dịch với VNPay
        String orderID = VNPayUtils.generateTxnRef();
        
        // Bước 6: Lưu order ID vào session để verify trong callback
        // Khi VNPay callback về, sẽ sử dụng order ID này để xác thực
        request.getSession().setAttribute(Constants.SESSION_ORDER_ID, orderID);
        
        // Bước 7: Tạo thông tin đơn hàng để hiển thị trên VNPay
        // Ví dụ: "Thanh toan ve xem phim Avatar - 2 ghe"
        String orderInfo = "Thanh toan ve xem phim " + bookingSession.getMovieTitle() + 
                          " - " + bookingSession.getSeatCount() + " ghe";
        
        // Bước 8: Lấy IP address của client
        // VNPay yêu cầu IP address để bảo mật
        String ipAddress = VNPayUtils.getIpAddress(request);
        
        try {
            // Bước 9: Tạo VNPay payment URL với return URL động
            // Gửi finalAmount (sau khi giảm giá) đến VNPay vì đây là số tiền khách hàng thực sự phải trả
            Map<String, String> vnpParams = VNPayUtils.createPaymentParams(
                orderID,              // Mã đơn hàng
                (long) finalAmount,   // Số tiền thanh toán (sau khi giảm giá)
                orderInfo,            // Thông tin đơn hàng
                ipAddress,            // IP address của client
                request               // Request để lấy return URL
            );
            
            // Bước 10: Xây dựng URL thanh toán VNPay với signature
            String paymentUrl = VNPayUtils.buildPaymentUrl(vnpParams);
            
            // Bước 11: Chuyển hướng người dùng đến trang thanh toán VNPay
            // Sau khi thanh toán, VNPay sẽ redirect về callback URL
            response.sendRedirect(paymentUrl);
            
        } catch (Exception e) {
            // Xử lý lỗi khi tạo payment URL
            request.setAttribute("error", "Không thể tạo liên kết thanh toán. Vui lòng thử lại!");
            doGet(request, response);
        }
    }
}

