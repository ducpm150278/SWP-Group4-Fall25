package com.cinema.controller.booking;

import com.cinema.dal.BookingDAO;
import com.cinema.dal.ComboDAO;
import com.cinema.dal.DiscountDAO;
import com.cinema.dal.FoodDAO;
import com.cinema.dal.SeatDAO;
import com.cinema.dal.TicketDAO;
import com.cinema.entity.Booking;
import com.cinema.entity.BookingSession;
import com.cinema.entity.Combo;
import com.cinema.entity.Food;
import com.cinema.entity.Ticket;
import com.cinema.utils.BookingSessionManager;
import com.cinema.utils.Constants;
import com.cinema.utils.SessionUtils;
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
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Servlet xử lý callback từ VNPay sau khi thanh toán
 */
@WebServlet(name = "VNPayCallbackServlet", urlPatterns = {"/vnpay-callback"})
public class VNPayCallbackServlet extends HttpServlet {
    
    private TicketDAO ticketDAO;
    private DiscountDAO discountDAO;
    private SeatDAO seatDAO;
    private BookingDAO bookingDAO;
    private FoodDAO foodDAO;
    private ComboDAO comboDAO;
    
    @Override
    public void init() throws ServletException {
        ticketDAO = new TicketDAO();
        discountDAO = new DiscountDAO();
        seatDAO = new SeatDAO();
        bookingDAO = new BookingDAO();
        foodDAO = new FoodDAO();
        comboDAO = new ComboDAO();
    }
    
    /**
     * Xử lý callback từ VNPay sau khi thanh toán
     * Flow: Lấy parameters -> Validate booking session -> Validate signature -> Kiểm tra response code -> Xử lý booking -> Hiển thị kết quả
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        BookingSession bookingSession = BookingSessionManager.getBookingSession(session);
        
        // Bước 1: Lấy tất cả parameters từ VNPay callback
        // VNPay sẽ redirect về URL này với các parameters chứa thông tin giao dịch
        Map<String, String> vnpParams = new HashMap<>();
        request.getParameterMap().forEach((key, values) -> {
            if (values.length > 0) {
                vnpParams.put(key, values[0]);
            }
        });
        
        // Bước 2: Lấy các thông tin quan trọng từ VNPay response
        String vnpSecureHash = request.getParameter("vnp_SecureHash");      // Chữ ký bảo mật để verify
        String responseCode = request.getParameter("vnp_ResponseCode");     // Mã phản hồi (00 = thành công)
        String transactionNo = request.getParameter("vnp_TransactionNo");  // Số giao dịch từ VNPay
        String orderID = request.getParameter("vnp_TxnRef");                // Order ID đã gửi đến VNPay
        String amount = request.getParameter("vnp_Amount");                // Số tiền (đã nhân 100)
        String bankCode = request.getParameter("vnp_BankCode");            // Mã ngân hàng
        String payDate = request.getParameter("vnp_PayDate");              // Ngày thanh toán
        
        // Bước 3: Kiểm tra booking session có tồn tại không
        // Nếu session hết hạn hoặc không tồn tại, không thể xử lý booking
        if (bookingSession == null) {
            request.setAttribute("error", "Phiên đặt vé đã hết hạn. Vui lòng đặt vé lại.");
            request.getRequestDispatcher(Constants.JSP_BOOKING_PAYMENT_FAILED).forward(request, response);
            return;
        }
        
        // Bước 4: Validate chữ ký bảo mật từ VNPay
        // Chữ ký được tạo từ tất cả parameters và secret key để đảm bảo request không bị giả mạo
        Map<String, String> paramsForValidation = new HashMap<>(vnpParams);
        boolean signatureValid = VNPayUtils.validateSignature(paramsForValidation, vnpSecureHash);
        
        if (!signatureValid) {
            // Chữ ký không hợp lệ - có thể bị giả mạo hoặc tham số bị thay đổi
            request.setAttribute("error", "Chữ ký không hợp lệ!");
            request.setAttribute("message", "Giao dịch có thể bị giả mạo. Vui lòng liên hệ bộ phận hỗ trợ.");
            request.getRequestDispatcher(Constants.JSP_BOOKING_PAYMENT_FAILED).forward(request, response);
            return;
        }
        
        // Bước 5: Kiểm tra response code từ VNPay
        // Response code "00" có nghĩa là thanh toán thành công
        if (!VNPayConfig.RESPONSE_CODE_SUCCESS.equals(responseCode)) {
            // Thanh toán thất bại - lấy thông báo lỗi tương ứng với response code
            String errorMessage = VNPayUtils.getResponseMessage(responseCode);
            
            request.setAttribute("error", errorMessage);
            request.setAttribute("responseCode", responseCode);
            request.getRequestDispatcher(Constants.JSP_BOOKING_PAYMENT_FAILED).forward(request, response);
            return;
        }
        
        // Bước 6: Thanh toán thành công - xử lý booking
        // Tạo booking record, tickets, và lưu thông tin đồ ăn/combo
        try {
            boolean bookingSuccess = processBooking(session, bookingSession, orderID, transactionNo);
            
            if (bookingSuccess) {
                // Booking thành công - lưu thông tin để hiển thị TRƯỚC KHI xóa session
                request.setAttribute("orderID", orderID);
                request.setAttribute("transactionNo", transactionNo);
                request.setAttribute("amount", Long.parseLong(amount) / 100); // Chuyển đổi từ VNPay format (đã nhân 100)
                request.setAttribute("bookingSession", bookingSession);
                
                // Xóa booking session sau khi đã lưu thông tin vào request
                // Đảm bảo không còn dữ liệu cũ trong session
                BookingSessionManager.clearBookingSession(session);
                
                // Hiển thị trang thành công
                request.getRequestDispatcher(Constants.JSP_BOOKING_PAYMENT_SUCCESS).forward(request, response);
            } else {
                // Booking thất bại - có thể do lỗi database hoặc dữ liệu không hợp lệ
                request.setAttribute("error", "Không thể hoàn tất đặt vé. Vui lòng liên hệ bộ phận hỗ trợ.");
                request.getRequestDispatcher(Constants.JSP_BOOKING_PAYMENT_FAILED).forward(request, response);
            }
            
        } catch (Exception e) {
            // Xử lý exception khi process booking
            request.setAttribute("error", "Có lỗi xảy ra khi xử lý đặt vé: " + e.getMessage());
            request.getRequestDispatcher(Constants.JSP_BOOKING_PAYMENT_FAILED).forward(request, response);
        }
    }
    
    /**
     * Xử lý booking sau khi thanh toán VNPay thành công
     * Flow: Tạo Booking record -> Tạo Tickets -> Lưu Combo/Food items -> Cập nhật discount usage -> Release reservations
     * 
     * @param session HttpSession để lấy user ID
     * @param bookingSession BookingSession chứa thông tin booking
     * @param orderID Order ID từ VNPay
     * @param transactionNo Transaction number từ VNPay
     * @return true nếu booking thành công, false nếu có lỗi
     */
    private boolean processBooking(HttpSession session, BookingSession bookingSession, 
                                   String orderID, String transactionNo) {
        
        // Bước 1: Lấy user ID từ session
        Integer userID = SessionUtils.getUserId(session);
        if (userID == null) {
            // Không có user ID - không thể tạo booking
            return false;
        }
        
        try {
            LocalDateTime bookingTime = LocalDateTime.now();
            
            // Bước 2: Tạo Booking record chính
            // Tạo booking code duy nhất
            String bookingCode = bookingDAO.generateBookingCode();
            
            // Đảm bảo tổng tiền được tính đúng
            bookingSession.calculateTotals();
            // totalAmount = ticketSubtotal + foodSubtotal (tổng trước khi giảm giá)
            double totalAmount = bookingSession.getTicketSubtotal() + bookingSession.getFoodSubtotal();
            double discountAmount = bookingSession.getDiscountAmount();
            // finalAmount = totalAmount - discountAmount (tổng sau khi giảm giá)
            double finalAmount = totalAmount - discountAmount;
            
            // Tạo Booking object với tất cả thông tin cần thiết
            Booking booking = new Booking(
                bookingCode,                              // Mã booking duy nhất
                userID,                                  // ID người dùng
                bookingSession.getScreeningID(),         // ID suất chiếu
                totalAmount,                             // Tổng tiền trước giảm giá
                discountAmount,                          // Số tiền giảm giá
                finalAmount,                             // Tổng tiền cuối cùng (sau giảm giá)
                Constants.PAYMENT_METHOD_VNPAY          // Phương thức thanh toán
            );
            booking.setBookingDate(bookingTime);
            booking.setPaymentDate(bookingTime);
            booking.setPaymentStatus(Constants.PAYMENT_STATUS_COMPLETED);  // Trạng thái thanh toán: Completed
            booking.setStatus(Constants.BOOKING_STATUS_CONFIRMED);        // Trạng thái booking: Confirmed
            
            // Bước 3: Set Transaction ID
            // Ưu tiên dùng transaction number từ VNPay, nếu không có thì dùng orderID
            String finalTransactionID;
            if (transactionNo != null && !transactionNo.trim().isEmpty() && !"0".equals(transactionNo)) {
                // Có transaction number từ VNPay - sử dụng nó
                finalTransactionID = transactionNo;
            } else {
                // Không có transaction number (sandbox/test mode) - tạo từ orderID
                finalTransactionID = "VNPAY_" + orderID;
            }
            booking.setTransactionID(finalTransactionID);
            
            // Lưu thông tin giao dịch vào notes để tracking
            String notes = "VNPay Order: " + orderID;
            if (transactionNo != null && !transactionNo.trim().isEmpty()) {
                notes += " | VNPay Txn: " + transactionNo;
            }
            booking.setNotes(notes);
            
            // Tạo booking trong database
            int bookingID = bookingDAO.createBooking(booking);
            
            if (bookingID <= 0) {
                // Tạo booking thất bại
                return false;
            }
            
            // Bước 4: Tạo tickets cho các ghế đã chọn
            // Mỗi ghế sẽ có một ticket riêng
            // QUAN TRỌNG: Tính giá vé đúng dựa trên priceMultiplier của từng ghế
            List<Ticket> tickets = new ArrayList<>();
            double baseTicketPrice = bookingSession.getTicketPrice();
            
            for (Integer seatID : bookingSession.getSelectedSeatIDs()) {
                // Lấy thông tin ghế để tính giá đúng
                com.cinema.entity.Seat seat = seatDAO.getSeatByID(seatID);
                double actualSeatPrice = baseTicketPrice; // Default to base price
                
                if (seat != null) {
                    // Tính giá vé thực tế = giá vé cơ bản * priceMultiplier
                    actualSeatPrice = baseTicketPrice * seat.getPriceMultiplier();
                }
                
                Ticket ticket = new Ticket(
                    bookingSession.getScreeningID(),     // ID suất chiếu
                    userID,                              // ID người dùng
                    seatID,                              // ID ghế
                    actualSeatPrice                      // Giá vé đã tính với multiplier
                );
                ticket.setBookingTime(bookingTime);
                tickets.add(ticket);
            }
            
            // Insert tickets vào database
            List<Integer> ticketIDs = ticketDAO.createTickets(tickets, bookingID);
            
            if (ticketIDs.isEmpty()) {
                // Tạo tickets thất bại
                return false;
            }
            
            // Bước 5: Lưu combo và đồ ăn (tùy chọn - bỏ qua nếu khách hàng không chọn)
            // Lưu combo items
            if (bookingSession.getSelectedCombos() != null && !bookingSession.getSelectedCombos().isEmpty()) {
                // Lấy giá của từng combo (ưu tiên discountPrice)
                java.util.Map<Integer, Double> comboPrices = new java.util.HashMap<>();
                
                for (Integer comboID : bookingSession.getSelectedCombos().keySet()) {
                    int quantity = bookingSession.getSelectedCombos().get(comboID);
                    Combo combo = comboDAO.getComboById(comboID);
                    if (combo != null) {
                        // Ưu tiên dùng discountPrice nếu có, nếu không thì dùng totalPrice
                        double price = combo.getDiscountPrice() != null ? 
                                      combo.getDiscountPrice().doubleValue() : 
                                      combo.getTotalPrice().doubleValue();
                        comboPrices.put(comboID, price);
                    }
                }
                
                // Lưu combo items vào database
                bookingDAO.addBookingComboItems(bookingID, 
                                                 bookingSession.getSelectedCombos(), 
                                                 comboPrices);
            }
            
            // Lưu food items
            if (bookingSession.getSelectedFoods() != null && !bookingSession.getSelectedFoods().isEmpty()) {
                // Lấy giá của từng food item
                java.util.Map<Integer, Double> foodPrices = new java.util.HashMap<>();
                
                for (Integer foodID : bookingSession.getSelectedFoods().keySet()) {
                    int quantity = bookingSession.getSelectedFoods().get(foodID);
                    Food food = foodDAO.getFoodById(foodID);
                    if (food != null) {
                        foodPrices.put(foodID, food.getPrice().doubleValue());
                    }
                }
                
                // Lưu food items vào database
                bookingDAO.addBookingFoodItems(bookingID, 
                                             bookingSession.getSelectedFoods(), 
                                             foodPrices);
            }
            
            // Bước 6: Hoàn tất booking
            // Cập nhật số lượt sử dụng discount nếu có áp dụng discount
            if (bookingSession.getDiscountID() != null) {
                discountDAO.updateDiscountUsage(bookingSession.getDiscountID());
            }
            
            // Giải phóng reservation tạm thời của ghế
            // Ghế đã được đặt vĩnh viễn thông qua tickets, không cần reserve nữa
            seatDAO.releaseReservationsBySession(bookingSession.getReservationSessionID());
            
            // Lưu ý: AvailableSeats được tính động thông qua view vw_CurrentScreenings
            // Không cần cập nhật thủ công
            
            return true;
            
        } catch (Exception e) {
            // Xử lý exception - trả về false để báo lỗi
            return false;
        }
    }
}

