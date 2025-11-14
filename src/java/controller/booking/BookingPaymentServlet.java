package controller.booking;

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
import java.util.Map;
import java.util.List;
import java.util.ArrayList;
import java.util.HashMap;

/**
 * Servlet xử lý Bước 4 của quy trình đặt vé: Thanh toán với tích hợp VNPay
 * 
 * Flow tổng quan:
 * 1. Kiểm tra booking session hợp lệ (đã chọn suất chiếu, ghế)
 * 2. Load chi tiết ghế, combo, đồ ăn để hiển thị breakdown
 * 3. Tính tổng tiền (ticketSubtotal + foodSubtotal - discountAmount)
 * 4. Hiển thị form thanh toán với:
 *    - Breakdown chi tiết (ghế, combo, đồ ăn)
 *    - Form nhập mã giảm giá (tùy chọn)
 *    - Checkbox đồng ý điều khoản
 *    - Nút thanh toán
 * 5. Xử lý 2 actions:
 *    - applyDiscount: Áp dụng mã giảm giá
 *    - payment: Submit thanh toán và redirect đến VNPay
 * 6. Sau khi thanh toán thành công, VNPay sẽ callback về VNPayCallbackServlet
 * 
 * Tính năng:
 * - Áp dụng mã giảm giá (percentage hoặc fixed amount)
 * - Tích hợp VNPay để thanh toán online
 * - Hiển thị breakdown chi tiết giá
 * - Countdown timer cho reservation
 * 
 * Endpoint: /booking/payment
 */
@WebServlet(name = "BookingPaymentServlet", urlPatterns = {"/booking/payment"})
public class BookingPaymentServlet extends HttpServlet {
    
    /** DAO để thao tác với dữ liệu mã giảm giá */
    private DiscountDAO discountDAO;
    /** DAO để thao tác với dữ liệu ghế */
    private SeatDAO seatDAO;
    /** DAO để thao tác với dữ liệu combo */
    private ComboDAO comboDAO;
    /** DAO để thao tác với dữ liệu đồ ăn */
    private FoodDAO foodDAO;
    
    /**
     * Khởi tạo servlet - tạo các DAO instances
     */
    @Override
    public void init() throws ServletException {
        discountDAO = new DiscountDAO();
        seatDAO = new SeatDAO();
        comboDAO = new ComboDAO();
        foodDAO = new FoodDAO();
    }
    
    /**
     * Xử lý request GET - hiển thị form thanh toán với breakdown chi tiết
     * 
     * Flow xử lý:
     * Bước 1: Validate booking session (đã chọn suất chiếu, ghế)
     * Bước 2: Tính thời gian còn lại của reservation (để hiển thị countdown)
     * Bước 3: Load chi tiết ghế đã chọn (label, type, multiplier, price) để hiển thị breakdown
     * Bước 4: Load chi tiết combo đã chọn (name, quantity, price, total) để hiển thị breakdown
     * Bước 5: Load chi tiết đồ ăn đã chọn (name, quantity, price, total) để hiển thị breakdown
     * Bước 6: Tính tổng tiền (ticketSubtotal + foodSubtotal - discountAmount)
     * Bước 7: Forward đến trang JSP để hiển thị form thanh toán
     * 
     * @param request HTTP request
     * @param response HTTP response
     * @throws ServletException nếu có lỗi servlet
     * @throws IOException nếu có lỗi I/O
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        BookingSession bookingSession = BookingSessionManager.getBookingSession(session);
        
        // Bước 1: Validate booking session
        // Phải có đầy đủ thông tin: suất chiếu, ghế đã chọn
        if (!BookingSessionManager.isValidForPayment(bookingSession)) {
            // Session không hợp lệ, redirect về Bước 1
            response.sendRedirect(request.getContextPath() + BookingConstants.PATH_SELECT_SCREENING);
            return;
        }
        
        // Bước 2: Tính thời gian còn lại của reservation (để hiển thị countdown)
        // Frontend sẽ dùng số giây này để hiển thị countdown timer
        long remainingSeconds = BookingSessionManager.getRemainingSeconds(bookingSession.getReservationExpiry());
        request.setAttribute("remainingSeconds", remainingSeconds);
        
        // Bước 3: Load chi tiết ghế đã chọn để hiển thị breakdown
        // Mỗi ghế sẽ có: label (A1, B5), type (VIP, Normal), multiplier, price
        List<Map<String, Object>> seatDetails = new ArrayList<>();
        double baseTicketPrice = bookingSession.getTicketPrice();
        for (Integer seatID : bookingSession.getSelectedSeatIDs()) {
            Seat seat = seatDAO.getSeatByID(seatID);
            if (seat != null) {
                Map<String, Object> detail = new HashMap<>();
                detail.put("label", seat.getSeatLabel());                    // Tên ghế (A1, B5)
                detail.put("type", seat.getSeatType());                      // Loại ghế (VIP, Normal)
                detail.put("multiplier", seat.getPriceMultiplier());         // Hệ số nhân giá (1.0, 1.5)
                detail.put("price", baseTicketPrice * seat.getPriceMultiplier()); // Giá vé cho ghế này
                seatDetails.add(detail);
            }
        }
        request.setAttribute("seatDetails", seatDetails);
        
        // Bước 4: Load chi tiết combo đã chọn để hiển thị breakdown
        // Mỗi combo sẽ có: name, quantity, price (ưu tiên discountPrice), total
        List<Map<String, Object>> comboDetails = new ArrayList<>();
        for (Map.Entry<Integer, Integer> entry : bookingSession.getSelectedCombos().entrySet()) {
            Combo combo = comboDAO.getComboById(entry.getKey());
            if (combo != null) {
                Map<String, Object> detail = new HashMap<>();
                detail.put("name", combo.getComboName());                    // Tên combo
                detail.put("quantity", entry.getValue());                    // Số lượng
                // Ưu tiên dùng discountPrice nếu có, không thì dùng totalPrice
                double price = combo.getDiscountPrice() != null ? 
                              combo.getDiscountPrice().doubleValue() : 
                              combo.getTotalPrice().doubleValue();
                detail.put("price", price);                                  // Giá đơn vị
                detail.put("total", price * entry.getValue());               // Tổng giá (price * quantity)
                comboDetails.add(detail);
            }
        }
        request.setAttribute("comboDetails", comboDetails);
        
        // Bước 5: Load chi tiết đồ ăn đã chọn để hiển thị breakdown
        // Mỗi món ăn sẽ có: name, quantity, price, total
        List<Map<String, Object>> foodDetails = new ArrayList<>();
        for (Map.Entry<Integer, Integer> entry : bookingSession.getSelectedFoods().entrySet()) {
            Food food = foodDAO.getFoodById(entry.getKey());
            if (food != null) {
                Map<String, Object> detail = new HashMap<>();
                detail.put("name", food.getFoodName());                      // Tên món ăn
                detail.put("quantity", entry.getValue());                    // Số lượng
                detail.put("price", food.getPrice().doubleValue());          // Giá đơn vị
                detail.put("total", food.getPrice().doubleValue() * entry.getValue()); // Tổng giá (price * quantity)
                foodDetails.add(detail);
            }
        }
        request.setAttribute("foodDetails", foodDetails);
        
        // Bước 6: Tính tổng tiền
        // Tổng = ticketSubtotal + foodSubtotal - discountAmount
        bookingSession.calculateTotals();
        
        // Gửi bookingSession đến JSP
        request.setAttribute("bookingSession", bookingSession);
        
        // Bước 7: Forward đến trang JSP để hiển thị form thanh toán
        request.getRequestDispatcher(BookingConstants.JSP_PAYMENT).forward(request, response);
    }
    
    /**
     * Xử lý request POST - xử lý apply discount hoặc submit payment
     * 
     * Flow xử lý:
     * Bước 1: Lấy action từ request (applyDiscount hoặc payment)
     * Bước 2: Nếu action = applyDiscount → xử lý áp dụng mã giảm giá
     * Bước 3: Nếu action = payment → xử lý submit thanh toán
     * Bước 4: Nếu action không hợp lệ → hiển thị lại form
     * 
     * @param request HTTP request chứa action và các parameters
     * @param response HTTP response để redirect hoặc forward
     * @throws ServletException nếu có lỗi servlet
     * @throws IOException nếu có lỗi I/O
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        BookingSession bookingSession = BookingSessionManager.getBookingSession(session);
        
        // Bước 1: Lấy action từ request
        String action = request.getParameter("action");
        
        // Bước 2: Xử lý áp dụng mã giảm giá
        if (BookingConstants.ACTION_APPLY_DISCOUNT.equals(action)) {
            handleDiscountApplication(request, response, bookingSession);
            return;
        }
        
        // Bước 3: Xử lý submit thanh toán
        if (BookingConstants.ACTION_PAYMENT.equals(action)) {
            handlePaymentSubmission(request, response, bookingSession);
            return;
        }
        
        // Bước 4: Action không hợp lệ, hiển thị lại form
        doGet(request, response);
    }
    
    /**
     * Xử lý áp dụng mã giảm giá
     * 
     * Flow xử lý:
     * Bước 1: Lấy mã giảm giá từ form
     * Bước 2: Validation mã giảm giá có được nhập hay không
     * Bước 3: Tìm mã giảm giá trong database
     * Bước 4: Kiểm tra mã giảm giá có tồn tại không
     * Bước 5: Kiểm tra trạng thái mã giảm giá (phải là "Active")
     * Bước 6: Kiểm tra mã giảm giá có trong khoảng thời gian hiệu lực không (startDate <= now <= endDate)
     * Bước 7: Kiểm tra mã giảm giá còn lượt sử dụng không (actualUsageCount < maxUsage)
     * Bước 8: Tính số tiền giảm dựa trên loại mã (Percentage hoặc Fixed)
     * Bước 9: Áp dụng discount vào BookingSession
     * Bước 10: Tính lại tổng tiền (totalAmount = subtotal - discountAmount)
     * Bước 11: Thông báo kết quả và hiển thị lại form
     * 
     * @param request HTTP request chứa discountCode
     * @param response HTTP response để forward
     * @param bookingSession BookingSession hiện tại
     * @throws ServletException nếu có lỗi servlet
     * @throws IOException nếu có lỗi I/O
     */
    private void handleDiscountApplication(HttpServletRequest request, HttpServletResponse response,
                                          BookingSession bookingSession) throws ServletException, IOException {
        
        // Bước 1: Lấy mã giảm giá từ form
        String discountCode = request.getParameter(BookingConstants.PARAM_DISCOUNT_CODE);
        
        // Bước 2: Validation mã giảm giá có được nhập hay không
        if (discountCode == null || discountCode.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập mã giảm giá!");
            doGet(request, response);
            return;
        }
        
        // Bước 3: Tìm mã giảm giá trong database
        Discount discount = discountDAO.getDiscountByCode(discountCode.trim());
        
        // Bước 4: Kiểm tra mã giảm giá có tồn tại không
        if (discount == null) {
            request.setAttribute("error", "Mã giảm giá không tồn tại!");
            doGet(request, response);
            return;
        }
        
        // Bước 5: Kiểm tra trạng thái mã giảm giá (phải là "Active")
        if (!"Active".equals(discount.getStatus())) {
            request.setAttribute("error", "Mã giảm giá không còn hiệu lực!");
            doGet(request, response);
            return;
        }
        
        // Bước 6: Kiểm tra mã giảm giá có trong khoảng thời gian hiệu lực không
        LocalDateTime now = LocalDateTime.now();
        if (now.isBefore(discount.getStartDate()) || now.isAfter(discount.getEndDate())) {
            // Mã giảm giá chưa bắt đầu hoặc đã hết hạn
            request.setAttribute("error", "Mã giảm giá đã hết hạn sử dụng!");
            doGet(request, response);
            return;
        }
        
        // Bước 7: Kiểm tra mã giảm giá còn lượt sử dụng không
        int actualUsageCount = discountDAO.getActualUsageCount(discount.getDiscountID());
        if (actualUsageCount >= discount.getMaxUsage()) {
            // Đã dùng hết lượt
            request.setAttribute("error", "Mã giảm giá đã hết lượt sử dụng! (Đã dùng " + actualUsageCount + "/" + discount.getMaxUsage() + " lượt)");
            doGet(request, response);
            return;
        }
        
        // Bước 8: Tính số tiền giảm dựa trên loại mã
        // Subtotal = giá vé + giá đồ ăn/combo (chưa trừ discount)
        double subtotal = bookingSession.getTicketSubtotal() + bookingSession.getFoodSubtotal();
        // Tính discount amount: nếu là Percentage thì tính %, nếu là Fixed thì lấy giá trị cố định
        double discountAmount = discount.calculateDiscountAmount(subtotal);
        
        // Bước 9: Áp dụng discount vào BookingSession
        bookingSession.setDiscountID(discount.getDiscountID());        // ID mã giảm giá
        bookingSession.setDiscountCode(discount.getCode());            // Mã giảm giá (để hiển thị)
        bookingSession.setDiscountAmount(discountAmount);              // Số tiền được giảm
        
        // Bước 10: Tính lại tổng tiền (totalAmount = subtotal - discountAmount)
        bookingSession.calculateTotals();
        
        // QUAN TRỌNG: Lưu lại BookingSession vào session để đảm bảo persistence
        request.getSession().setAttribute("bookingSession", bookingSession);
        
        // Bước 11: Thông báo kết quả
        // Format thông báo khác nhau tùy loại mã (Percentage hoặc Fixed)
        String successMessage;
        if ("Percentage".equals(discount.getDiscountType())) {
            // Mã giảm giá theo phần trăm (ví dụ: 10%)
            successMessage = "Áp dụng mã giảm giá thành công! Giảm " + 
                           String.format("%.0f%%", discount.getDiscountValue());
        } else {
            // Mã giảm giá theo số tiền cố định (ví dụ: 50,000 đ)
            successMessage = "Áp dụng mã giảm giá thành công! Giảm " + 
                           String.format("%,.0f đ", discount.getDiscountValue());
        }
        request.setAttribute("success", successMessage);
        
        // Hiển thị lại form với thông báo thành công
        doGet(request, response);
    }
    
    /**
     * Xử lý submit thanh toán - redirect đến VNPay
     * 
     * Flow xử lý:
     * Bước 1: Validate booking session
     * Bước 2: Kiểm tra người dùng đã đồng ý với điều khoản chưa
     * Bước 3: Lấy phương thức thanh toán (mặc định là VNPay)
     * Bước 4: Tính tổng tiền cuối cùng (ticketSubtotal + foodSubtotal - discountAmount)
     * Bước 5: Tạo order ID duy nhất (dùng cho VNPay)
     * Bước 6: Lưu order ID vào session (để verify khi VNPay callback)
     * Bước 7: Xây dựng thông tin đơn hàng (order info)
     * Bước 8: Lấy IP address của client
     * Bước 9: Tạo VNPay payment parameters
     * Bước 10: Xây dựng VNPay payment URL
     * Bước 11: Redirect người dùng đến VNPay để thanh toán
     * 
     * Sau khi thanh toán:
     * - Nếu thành công: VNPay sẽ redirect về VNPayCallbackServlet với response code = "00"
     * - Nếu thất bại: VNPay sẽ redirect về VNPayCallbackServlet với response code khác "00"
     * 
     * @param request HTTP request chứa agreeTerms và paymentMethod
     * @param response HTTP response để redirect đến VNPay
     * @param bookingSession BookingSession hiện tại
     * @throws ServletException nếu có lỗi servlet
     * @throws IOException nếu có lỗi I/O
     */
    private void handlePaymentSubmission(HttpServletRequest request, HttpServletResponse response,
                                        BookingSession bookingSession) throws ServletException, IOException {
        
        // Bước 1: Validate booking session
        // Phải có đầy đủ thông tin: suất chiếu, ghế đã chọn
        if (!BookingSessionManager.isValidForPayment(bookingSession)) {
            request.setAttribute("error", "Phiên đặt vé không hợp lệ!");
            response.sendRedirect(request.getContextPath() + BookingConstants.PATH_SELECT_SCREENING);
            return;
        }
        
        // Bước 2: Kiểm tra người dùng đã đồng ý với điều khoản chưa
        // Form sẽ gửi "on" nếu checkbox được chọn
        String agreeTerms = request.getParameter(BookingConstants.PARAM_AGREE_TERMS);
        if (!"on".equals(agreeTerms)) {
            request.setAttribute("error", "Vui lòng đồng ý với điều khoản và điều kiện!");
            doGet(request, response);
            return;
        }
        
        // Bước 3: Lấy phương thức thanh toán (mặc định là VNPay)
        String paymentMethod = request.getParameter(BookingConstants.PARAM_PAYMENT_METHOD);
        if (paymentMethod == null || paymentMethod.isEmpty()) {
            paymentMethod = BookingConstants.PAYMENT_METHOD_VNPAY;
        }
        
        // Bước 4: Tính tổng tiền cuối cùng
        // totalAmount = ticketSubtotal + foodSubtotal - discountAmount
        bookingSession.calculateTotals();
        double totalAmount = bookingSession.getTotalAmount();
        
        // Bước 5: Tạo order ID duy nhất
        // Order ID này sẽ được gửi đến VNPay và dùng để track giao dịch
        String orderID = VNPayUtils.generateTxnRef();
        
        // Bước 6: Lưu order ID vào session
        // Order ID sẽ được dùng để verify khi VNPay callback về
        request.getSession().setAttribute("orderID", orderID);
        
        // Bước 7: Xây dựng thông tin đơn hàng
        // Thông tin này sẽ hiển thị trên trang thanh toán VNPay
        String orderInfo = "Thanh toan ve xem phim " + bookingSession.getMovieTitle() + 
                          " - " + bookingSession.getSeatCount() + " ghe";
        
        // Bước 8: Lấy IP address của client
        // IP address cần thiết cho VNPay để xác thực
        String ipAddress = VNPayUtils.getIpAddress(request);
        
        try {
            // Bước 9: Tạo VNPay payment parameters
            // Bao gồm: orderID, amount, orderInfo, ipAddress, và các tham số khác
            Map<String, String> vnpParams = VNPayUtils.createPaymentParams(
                orderID,                    // Mã đơn hàng
                (long) totalAmount,         // Tổng tiền (VNPay yêu cầu đơn vị là đồng, không có phần thập phân)
                orderInfo,                  // Thông tin đơn hàng
                ipAddress,                  // IP address của client
                request                     // Request để lấy thông tin server (return URL)
            );
            
            // Bước 10: Xây dựng VNPay payment URL
            // URL này sẽ chứa tất cả parameters đã được ký (signed) bằng secret key
            String paymentUrl = VNPayUtils.buildPaymentUrl(vnpParams);
            
            // Bước 11: Redirect người dùng đến VNPay để thanh toán
            // Người dùng sẽ được chuyển đến trang thanh toán của VNPay
            // Sau khi thanh toán xong, VNPay sẽ redirect về VNPayCallbackServlet
            response.sendRedirect(paymentUrl);
            
        } catch (Exception e) {
            // Xử lý lỗi nếu không thể tạo payment URL
            e.printStackTrace();
            request.setAttribute("error", "Không thể tạo liên kết thanh toán. Vui lòng thử lại!");
            doGet(request, response);
        }
    }
}

