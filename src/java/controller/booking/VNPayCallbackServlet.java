package controller.booking;

import dal.BookingDAO;
import dal.ComboDAO;
import dal.DiscountDAO;
import dal.FoodDAO;
import dal.SeatDAO;
import dal.TicketDAO;
import entity.Booking;
import entity.BookingSession;
import entity.Combo;
import entity.Food;
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



import javax.mail.Authenticator;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import java.util.Properties;
import entity.User;
import dal.UserDAO;
import java.time.format.DateTimeFormatter; 
import java.util.Locale;
/**
 * Servlet xử lý callback từ VNPay sau khi người dùng thanh toán
 * 
 * Flow tổng quan:
 * 1. VNPay redirect về servlet này sau khi người dùng thanh toán
 * 2. Nhận các parameters từ VNPay (response code, transaction number, order ID, amount, signature, etc.)
 * 3. Validate signature để đảm bảo request đến từ VNPay (tránh giả mạo)
 * 4. Kiểm tra response code:
 *    - "00" = Thanh toán thành công
 *    - Khác "00" = Thanh toán thất bại
 * 5. Nếu thành công:
 *    - Xử lý booking (tạo booking record, tickets, food items)
 *    - Clear booking session
 *    - Hiển thị trang thành công
 * 6. Nếu thất bại:
 *    - Hiển thị trang thất bại với thông báo lỗi
 * 
 * Process Booking Flow (khi thanh toán thành công):
 * Step 1: Tạo Booking record trong database
 * Step 2: Tạo Tickets cho các ghế đã chọn
 * Step 3: Lưu Combo và Food items (nếu có)
 * Step 4: Finalize (update discount usage, release reservations)
 * 
 * Endpoint: /vnpay-callback
 */
@WebServlet(name = "VNPayCallbackServlet", urlPatterns = {"/vnpay-callback"})
public class VNPayCallbackServlet extends HttpServlet {
    
    /** DAO để thao tác với dữ liệu vé */
    private TicketDAO ticketDAO;
    /** DAO để thao tác với dữ liệu mã giảm giá */
    private DiscountDAO discountDAO;
    /** DAO để thao tác với dữ liệu ghế */
    private SeatDAO seatDAO;
    /** DAO để thao tác với dữ liệu booking */
    private BookingDAO bookingDAO;
    /** DAO để thao tác với dữ liệu đồ ăn */
    private FoodDAO foodDAO;
    /** DAO để thao tác với dữ liệu combo */
    private ComboDAO comboDAO;
    
    private UserDAO userDAO;
    /**
     * Khởi tạo servlet - tạo các DAO instances
     */
    @Override
    public void init() throws ServletException {
        ticketDAO = new TicketDAO();
        discountDAO = new DiscountDAO();
        seatDAO = new SeatDAO();
        bookingDAO = new BookingDAO();
        foodDAO = new FoodDAO();
        comboDAO = new ComboDAO();
        userDAO = new UserDAO();
    }
    
    /**
     * Xử lý callback từ VNPay sau khi người dùng thanh toán
     * 
     * Flow xử lý:
     * Bước 1: Lấy BookingSession từ session
     * Bước 2: Thu thập tất cả parameters từ VNPay
     * Bước 3: Lấy các thông tin quan trọng: secureHash, responseCode, transactionNo, orderID, amount
     * Bước 4: Kiểm tra BookingSession có tồn tại không
     * Bước 5: Validate signature để đảm bảo request đến từ VNPay (bảo mật)
     * Bước 6: Kiểm tra response code:
     *    - "00" = Thanh toán thành công → xử lý booking
     *    - Khác "00" = Thanh toán thất bại → hiển thị lỗi
     * Bước 7: Nếu thành công, gọi processBooking để tạo booking record
     * Bước 8: Hiển thị trang kết quả (thành công hoặc thất bại)
     * 
     * @param request HTTP request chứa parameters từ VNPay
     * @param response HTTP response để forward
     * @throws ServletException nếu có lỗi servlet
     * @throws IOException nếu có lỗi I/O
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        BookingSession bookingSession = BookingSessionManager.getBookingSession(session);
        
        // Bước 2: Thu thập tất cả parameters từ VNPay
        // VNPay sẽ gửi nhiều parameters trong URL query string
        Map<String, String> vnpParams = new HashMap<>();
        request.getParameterMap().forEach((key, values) -> {
            if (values.length > 0) {
                vnpParams.put(key, values[0]);
            }
        });
        
        // Bước 3: Lấy các thông tin quan trọng từ VNPay response
        String vnpSecureHash = request.getParameter("vnp_SecureHash");        // Chữ ký để verify
        String responseCode = request.getParameter("vnp_ResponseCode");       // Mã phản hồi ("00" = thành công)
        String transactionNo = request.getParameter("vnp_TransactionNo");     // Số giao dịch từ VNPay
        String orderID = request.getParameter("vnp_TxnRef");                  // Mã đơn hàng (order ID)
        String amount = request.getParameter("vnp_Amount");                   // Số tiền (đơn vị: đồng, không có phần thập phân)
        
        // Bước 4: Kiểm tra BookingSession có tồn tại không
        // Nếu không có, có thể session đã hết hạn hoặc người dùng truy cập trực tiếp URL
        if (bookingSession == null) {
            request.setAttribute("error", "Phiên đặt vé đã hết hạn. Vui lòng đặt vé lại.");
            request.getRequestDispatcher(BookingConstants.JSP_PAYMENT_FAILED).forward(request, response);
            return;
        }
        
        // Bước 5: Validate signature để đảm bảo request đến từ VNPay
        // Signature được tính từ tất cả parameters + secret key
        // Nếu signature không khớp, có thể request bị giả mạo
        Map<String, String> paramsForValidation = new HashMap<>(vnpParams);
        boolean signatureValid = VNPayUtils.validateSignature(paramsForValidation, vnpSecureHash);
        
        if (!signatureValid) {
            // Signature không hợp lệ - có thể bị giả mạo
            request.setAttribute("error", "Chữ ký không hợp lệ!");
            request.setAttribute("message", "Giao dịch có thể bị giả mạo. Vui lòng liên hệ bộ phận hỗ trợ.");
            request.getRequestDispatcher(BookingConstants.JSP_PAYMENT_FAILED).forward(request, response);
            return;
        }
        
        // Bước 6: Kiểm tra response code
        // "00" = Thanh toán thành công
        if (!VNPayConfig.RESPONSE_CODE_SUCCESS.equals(responseCode)) {
            // Thanh toán thất bại - lấy thông báo lỗi tương ứng với response code
            String errorMessage = VNPayUtils.getResponseMessage(responseCode);
            request.setAttribute("error", errorMessage);
            request.setAttribute("responseCode", responseCode);
            request.getRequestDispatcher(BookingConstants.JSP_PAYMENT_FAILED).forward(request, response);
            return;
        }
        
        // Bước 7: Thanh toán thành công - xử lý booking
        // Tạo booking record, tickets, food items trong database
        try {
            boolean bookingSuccess = processBooking(session, bookingSession, orderID, transactionNo);
            
            if (bookingSuccess) {
                // Booking thành công
                // Lưu thông tin để hiển thị TRƯỚC KHI clear session
                request.setAttribute("orderID", orderID);                      // Mã đơn hàng
                request.setAttribute("transactionNo", transactionNo);          // Số giao dịch VNPay
                request.setAttribute("amount", Long.parseLong(amount) / 100); // Số tiền (VNPay gửi dạng x100, chia lại)
                request.setAttribute("bookingSession", bookingSession);        // Booking session (để hiển thị chi tiết)
                
                
                                // gui email
                Integer userID = (Integer) session.getAttribute("userId");
                if (userID != null) {
                    User user = userDAO.getUserById(userID);
                    String bookingCode = (String) session.getAttribute("lastBookingCode"); // Lấy mã booking đã lưu
                    if (user != null && bookingCode != null) {
                        sendBookingConfirmationEmail(bookingSession, bookingCode, user);
                    } else {
                        System.err.println("✗ Lỗi: Không thể gửi email. Không tìm thấy User hoặc BookingCode trong session.");
                    }
                }
                
                
                // Xóa booking session sau khi đã lưu thông tin vào request
                BookingSessionManager.clearBookingSession(session);
                
                // Hiển thị trang thanh toán thành công
                request.getRequestDispatcher(BookingConstants.JSP_PAYMENT_SUCCESS).forward(request, response);
            } else {
                // Booking thất bại (có thể do lỗi database)
                request.setAttribute("error", "Không thể hoàn tất đặt vé. Vui lòng liên hệ bộ phận hỗ trợ.");
                request.getRequestDispatcher(BookingConstants.JSP_PAYMENT_FAILED).forward(request, response);
            }
            
        } catch (Exception e) {
            // Xử lý exception nếu có lỗi trong quá trình booking
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra khi xử lý đặt vé: " + e.getMessage());
            request.getRequestDispatcher(BookingConstants.JSP_PAYMENT_FAILED).forward(request, response);
        }
    }
    
    /**
     * Xử lý booking sau khi thanh toán VNPay thành công
     * Tạo booking record, tickets, food items và hoàn tất giao dịch
     * 
     * Flow xử lý:
     * Step 1: Tạo Booking record trong database
     *    - Tạo booking code duy nhất
     *    - Tính toán các giá trị: totalAmount, discountAmount, finalAmount
     *    - Thiết lập thông tin booking: userID, screeningID, payment method, status
     *    - Lưu transaction ID từ VNPay
     *    - Tạo booking record trong database
     * 
     * Step 2: Tạo Tickets cho các ghế đã chọn
     *    - Tạo Ticket object cho mỗi ghế đã chọn
     *    - Liên kết tickets với bookingID
     *    - Lưu tickets vào database
     * 
     * Step 3: Lưu Combo và Food items (nếu có)
     *    - Lưu combo items với số lượng và giá
     *    - Lưu food items với số lượng và giá
     *    - Validate combo/food tồn tại trong database
     * 
     * Step 4: Finalize booking
     *    - Update discount usage count (nếu có áp dụng mã giảm giá)
     *    - Release temporary seat reservations (ghế đã được đặt vĩnh viễn qua tickets)
     * 
     * @param session HTTP session chứa userID
     * @param bookingSession BookingSession chứa thông tin đặt vé
     * @param orderID Mã đơn hàng từ VNPay
     * @param transactionNo Số giao dịch từ VNPay
     * @return true nếu booking thành công, false nếu thất bại
     */
    private boolean processBooking(HttpSession session, BookingSession bookingSession, 
                                   String orderID, String transactionNo) {
        
        // Lấy userID từ session
        // UserID cần thiết để tạo booking và tickets
        Integer userID = (Integer) session.getAttribute("userId");
        if (userID == null) {
            System.err.println("ERROR: UserID is null in session!");
            return false;
        }
        
        try {
            // Lấy thời gian hiện tại làm booking time và payment time
            LocalDateTime bookingTime = LocalDateTime.now();
            
            // ========== STEP 1: TẠO BOOKING RECORD ==========
            
            // Tạo booking code duy nhất (ví dụ: BK20250101123456)
            String bookingCode = bookingDAO.generateBookingCode();
            
            
            // đang lưu tạm booking code 
            session.setAttribute("lastBookingCode", bookingCode);
            
            
            // Tính toán các giá trị
            double totalAmount = bookingSession.getTotalAmount();        // Tổng tiền (ticket + food)
            double discountAmount = bookingSession.getDiscountAmount();  // Số tiền được giảm (nếu có)
            double finalAmount = totalAmount - discountAmount;           // Số tiền cuối cùng phải trả
            
            // Tạo Booking object
            Booking booking = new Booking(
                bookingCode,                        // Mã booking duy nhất
                userID,                            // ID người dùng
                bookingSession.getScreeningID(),   // ID suất chiếu
                totalAmount,                       // Tổng tiền
                discountAmount,                    // Số tiền giảm giá
                finalAmount,                       // Số tiền cuối cùng
                "VNPay"                           // Phương thức thanh toán
            );
            
            // Thiết lập thông tin bổ sung
            booking.setBookingDate(bookingTime);        // Thời gian đặt vé
            booking.setPaymentDate(bookingTime);        // Thời gian thanh toán
            booking.setPaymentStatus("Completed");      // Trạng thái thanh toán: đã hoàn thành
            booking.setStatus("Confirmed");             // Trạng thái booking: đã xác nhận
            
            // Thiết lập Transaction ID
            // Ưu tiên dùng transaction number từ VNPay, nếu không có thì dùng orderID
            String finalTransactionID;
            if (transactionNo != null && !transactionNo.trim().isEmpty() && !"0".equals(transactionNo)) {
                // Có transaction number từ VNPay
                finalTransactionID = transactionNo;
            } else {
                // Fallback cho sandbox/test mode (VNPay không cung cấp transaction number)
                finalTransactionID = "VNPAY_" + orderID;
            }
            booking.setTransactionID(finalTransactionID);
            
            // Tạo notes để lưu thông tin giao dịch VNPay
            String notes = "VNPay Order: " + orderID;
            if (transactionNo != null && !transactionNo.trim().isEmpty()) {
                notes += " | VNPay Txn: " + transactionNo;
            }
            booking.setNotes(notes);
            
            // Tạo booking record trong database
            int bookingID = bookingDAO.createBooking(booking);
            
            if (bookingID <= 0) {
                // Không thể tạo booking record
                System.err.println("ERROR: Failed to create booking in database!");
                return false;
            }
            
            // ========== STEP 2: TẠO TICKETS CHO CÁC GHẾ ĐÃ CHỌN ==========
            
            // Tạo danh sách tickets cho mỗi ghế đã chọn
            List<Ticket> tickets = new ArrayList<>();
            for (Integer seatID : bookingSession.getSelectedSeatIDs()) {
                Ticket ticket = new Ticket(
                    bookingSession.getScreeningID(),   // ID suất chiếu
                    userID,                            // ID người dùng
                    seatID,                            // ID ghế
                    bookingSession.getTicketPrice()    // Giá vé cơ bản
                );
                ticket.setBookingTime(bookingTime);    // Thời gian đặt vé
                tickets.add(ticket);
            }
            
            // Lưu tickets vào database
            // Method này sẽ tạo tickets và liên kết với bookingID
            List<Integer> ticketIDs = ticketDAO.createTickets(tickets, bookingID);
            
            if (ticketIDs.isEmpty()) {
                // Không thể tạo tickets
                System.err.println("ERROR: Failed to create tickets in database!");
                return false;
            }
            
            // ========== STEP 3: LƯU COMBO VÀ FOOD ITEMS (NẾU CÓ) ==========
            
            // Lưu combo items (nếu người dùng đã chọn combo)
            if (bookingSession.getSelectedCombos() != null && !bookingSession.getSelectedCombos().isEmpty()) {
                // Tạo map lưu giá của từng combo
                java.util.Map<Integer, Double> comboPrices = new java.util.HashMap<>();
                
                // Lấy giá của từng combo (ưu tiên discountPrice nếu có)
                for (Integer comboID : bookingSession.getSelectedCombos().keySet()) {
                    int quantity = bookingSession.getSelectedCombos().get(comboID);
                    Combo combo = comboDAO.getComboById(comboID);
                    if (combo != null) {
                        // Ưu tiên dùng discountPrice nếu có, không thì dùng totalPrice
                        double price = combo.getDiscountPrice() != null ? 
                                      combo.getDiscountPrice().doubleValue() : 
                                      combo.getTotalPrice().doubleValue();
                        comboPrices.put(comboID, price);
                    } else {
                        // Combo không tồn tại trong database
                        System.err.println("ERROR: Combo ID " + comboID + " not found in database!");
                        return false;
                    }
                }
                
                // Lưu combo items vào database
                bookingDAO.addBookingComboItems(bookingID, 
                                                bookingSession.getSelectedCombos(),  // Map<comboID, quantity>
                                                comboPrices);                        // Map<comboID, price>
            }
            
            // Lưu food items (nếu người dùng đã chọn đồ ăn)
            if (bookingSession.getSelectedFoods() != null && !bookingSession.getSelectedFoods().isEmpty()) {
                // Tạo map lưu giá của từng món ăn
                java.util.Map<Integer, Double> foodPrices = new java.util.HashMap<>();
                
                // Lấy giá của từng món ăn
                for (Integer foodID : bookingSession.getSelectedFoods().keySet()) {
                    int quantity = bookingSession.getSelectedFoods().get(foodID);
                    Food food = foodDAO.getFoodById(foodID);
                    if (food != null) {
                        foodPrices.put(foodID, food.getPrice().doubleValue());
                    } else {
                        // Food không tồn tại trong database
                        System.err.println("ERROR: Food ID " + foodID + " not found in database!");
                        return false;
                    }
                }
                
                // Lưu food items vào database
                bookingDAO.addBookingFoodItems(bookingID, 
                                               bookingSession.getSelectedFoods(),  // Map<foodID, quantity>
                                               foodPrices);                        // Map<foodID, price>
            }
            
            // ========== STEP 4: FINALIZE BOOKING ==========
            
            // Update discount usage count (nếu có áp dụng mã giảm giá)
            // Tăng số lượt sử dụng của mã giảm giá lên 1
            if (bookingSession.getDiscountID() != null) {
                discountDAO.updateDiscountUsage(bookingSession.getDiscountID());
            }
            
            // Release temporary seat reservations
            // Các ghế đã được đặt vĩnh viễn qua tickets, không cần giữ reservation nữa
            // Xóa các reservation records được tạo tạm thời trong Bước 2 (chọn ghế)
            seatDAO.releaseReservationsBySession(bookingSession.getReservationSessionID());
            
            // Lưu ý: AvailableSeats được tính động qua view vw_CurrentScreenings
            // Không cần cập nhật thủ công
            
            return true;
            
        } catch (Exception e) {
            // Xử lý exception nếu có lỗi trong quá trình booking
            System.err.println("ERROR: Booking process failed - " + e.getClass().getName() + ": " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
        // Gửi email xác nhận đặt vé thành công cho khách hàng
private boolean sendBookingConfirmationEmail(BookingSession bookingSession, String bookingCode, User user) {
        
        System.out.println("Chuẩn bị gửi email xác nhận đến: " + user.getEmail());
        
        // 1. Thông tin người gửi
        final String fromEmail = "swordartonline282@gmail.com"; 
        final String password = "lfbo sxny fzru zygm"; 
        
        // 2. Cấu hình Properties
        Properties props = new Properties();
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587"); // TLS Port
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        
        // 3. Tạo Authen
        Authenticator auth = new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(fromEmail, password);
            }
        };
        Session mailSession = Session.getInstance(props, auth);
        
        try {
            MimeMessage msg = new MimeMessage(mailSession);
            msg.setFrom(new InternetAddress(fromEmail));
            msg.addRecipient(Message.RecipientType.TO, new InternetAddress(user.getEmail()));
            
            // 4. Tạo Nội dung Email
            msg.setSubject("Xác nhận đặt vé thành công! Mã vé: " + bookingCode, "UTF-8");
            
            // Lấy thông tin chi tiết từ bookingSession
            String movieTitle = bookingSession.getMovieTitle();
            LocalDateTime screeningTimeObj = bookingSession.getScreeningTime(); 
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("EEEE, dd/MM/yyyy - HH:mm", new Locale("vi", "VN"));
            String screeningTime = screeningTimeObj.format(formatter); 
            String cinemaName = bookingSession.getCinemaName();
            String roomName = bookingSession.getRoomName();
            String seats = String.join(", ", bookingSession.getSelectedSeatLabels());
            double finalAmount = bookingSession.getTotalAmount() - bookingSession.getDiscountAmount();
            
            String emailBody = "Chào " + user.getFullName() + ",\n\n"
                    + "Cảm ơn bạn đã đặt vé tại Cinema! Đơn hàng của bạn đã được xác nhận.\n\n"
                    + "--------------------------------------------------\n"
                    + "THÔNG TIN VÉ (Mã: " + bookingCode + ")\n"
                    + "--------------------------------------------------\n\n"
                    + "Phim: " + movieTitle + "\n"
                    + "Rạp: " + cinemaName + "\n"
                    + "Phòng: " + roomName + "\n"
                    + "Suất chiếu: " + screeningTime + "\n"
                    + "Ghế: " + seats + "\n\n"
                    + "Tổng Thanh Toán: " + String.format("%,.0f VNĐ", finalAmount) + "\n\n"
                    + "Để lấy vé, vui lòng mở màn hình email này khi tới quầy lấy vé tại rạp chiếu phim bạn đã chọn\n\n"
                    + "--------------------------------------------------\n\n"
                    + "Chúc bạn có một buổi xem phim vui vẻ!\n\n"
                    + "Trân trọng,\n"
                    + "Đội ngũ Cinema";
            
            msg.setText(emailBody, "UTF-8");

            // 5. Gửi Email
            Transport.send(msg);
            System.out.println("✓ Email xác nhận đã gửi thành công!");
            return true;
            
        } catch (Exception e) { // bắt lỗi format
            System.err.println("✗ Lỗi khi gửi email: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}

