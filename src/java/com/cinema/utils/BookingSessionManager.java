package com.cinema.utils;


import com.cinema.entity.BookingSession;
import jakarta.servlet.http.HttpSession;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Lớp quản lý vòng đời session đặt vé
 * Quản lý booking session từ khi chọn suất chiếu đến khi thanh toán
 */
public class BookingSessionManager {
    
    // Thời gian hết hạn của reservation (tính bằng phút)
    // Sau thời gian này, ghế sẽ được giải phóng tự động
    private static final int RESERVATION_TIMEOUT_MINUTES = 15;
    
    /**
     * Lấy hoặc tạo booking session từ session
     * Nếu chưa có booking session, tạo mới và lưu vào session
     * 
     * @param session HttpSession để lưu/đọc booking session
     * @return BookingSession object (mới hoặc đã tồn tại)
     */
    public static BookingSession getBookingSession(HttpSession session) {
        // Lấy booking session từ session attribute
        BookingSession bookingSession = (BookingSession) session.getAttribute(Constants.SESSION_BOOKING_SESSION);
        
        // Nếu chưa có, tạo mới và lưu vào session
        if (bookingSession == null) {
            bookingSession = new BookingSession();
            session.setAttribute(Constants.SESSION_BOOKING_SESSION, bookingSession);
        }
        
        return bookingSession;
    }
    
    /**
     * Xóa booking session khỏi session
     * Được gọi khi booking hoàn tất hoặc bị hủy
     * 
     * @param session HttpSession chứa booking session cần xóa
     */
    public static void clearBookingSession(HttpSession session) {
        session.removeAttribute(Constants.SESSION_BOOKING_SESSION);
    }
    
    /**
     * Tạo reservation session ID duy nhất
     * Reservation session ID được sử dụng để track reservation trong database
     * 
     * @return UUID string duy nhất
     */
    public static String generateReservationSessionID() {
        return UUID.randomUUID().toString();
    }
    
    /**
     * Tính thời gian hết hạn của reservation
     * Reservation sẽ hết hạn sau RESERVATION_TIMEOUT_MINUTES phút từ thời điểm hiện tại
     * 
     * @return LocalDateTime đại diện cho thời điểm hết hạn
     */
    public static LocalDateTime getReservationExpiry() {
        return LocalDateTime.now().plusMinutes(RESERVATION_TIMEOUT_MINUTES);
    }
    
    /**
     * Kiểm tra reservation đã hết hạn chưa
     * 
     * @param expiryTime Thời điểm hết hạn cần kiểm tra
     * @return true nếu đã hết hạn hoặc expiryTime là null, false nếu chưa hết hạn
     */
    public static boolean isReservationExpired(LocalDateTime expiryTime) {
        if (expiryTime == null) {
            // Không có expiry time - coi như đã hết hạn
            return true;
        }
        // Kiểm tra thời gian hiện tại có sau expiryTime không
        return LocalDateTime.now().isAfter(expiryTime);
    }
    
    /**
     * Tính số giây còn lại của reservation
     * 
     * @param expiryTime Thời điểm hết hạn
     * @return Số giây còn lại (>= 0), 0 nếu đã hết hạn hoặc expiryTime là null
     */
    public static long getRemainingSeconds(LocalDateTime expiryTime) {
        if (expiryTime == null) {
            return 0;  // Không có expiry time - trả về 0
        }
        
        LocalDateTime now = LocalDateTime.now();
        if (now.isAfter(expiryTime)) {
            return 0;  // Đã hết hạn - trả về 0
        }
        
        // Tính số giây còn lại bằng Duration
        return java.time.Duration.between(now, expiryTime).getSeconds();
    }
    
    /**
     * Format thời gian còn lại thành chuỗi hiển thị (MM:SS)
     * 
     * @param seconds Số giây còn lại
     * @return Chuỗi format "MM:SS" (ví dụ: "14:30"), "00:00" nếu <= 0
     */
    public static String formatRemainingTime(long seconds) {
        if (seconds <= 0) {
            return "00:00";
        }
        
        // Chuyển đổi giây thành phút và giây
        long minutes = seconds / 60;
        long secs = seconds % 60;
        
        // Format với 2 chữ số cho cả phút và giây
        return String.format("%02d:%02d", minutes, secs);
    }
    
    /**
     * Validate booking session có đủ thông tin để thanh toán không
     * Kiểm tra: session tồn tại, có screening, có seats, và reservation chưa hết hạn
     * 
     * @param session BookingSession cần validate
     * @return true nếu hợp lệ để thanh toán, false nếu không
     */
    public static boolean isValidForPayment(BookingSession session) {
        if (session == null) {
            return false;  // Session không tồn tại
        }
        
        // Kiểm tra screening đã được chọn chưa
        if (session.getScreeningID() <= 0) {
            return false;  // Chưa chọn suất chiếu
        }
        
        // Kiểm tra ghế đã được chọn chưa
        if (session.getSelectedSeatIDs() == null || session.getSelectedSeatIDs().isEmpty()) {
            return false;  // Chưa chọn ghế
        }
        
        // Kiểm tra reservation chưa hết hạn
        if (isReservationExpired(session.getReservationExpiry())) {
            return false;  // Reservation đã hết hạn
        }
        
        return true;  // Tất cả điều kiện đều thỏa mãn
    }
    
    /**
     * Tính các subtotal cho booking session
     * Tính ticketSubtotal và foodSubtotal, sau đó gọi calculateTotals() để tính totalAmount và finalAmount
     * 
     * @param session BookingSession cần tính subtotal
     * @param combos Map<comboID, Combo> chứa thông tin combo để tính giá
     * @param foods Map<foodID, Food> chứa thông tin food để tính giá
     */
    public static void calculateSubtotals(BookingSession session, 
                                         java.util.Map<Integer, com.cinema.entity.Combo> combos,
                                         java.util.Map<Integer, com.cinema.entity.Food> foods) {
        // Bước 1: Tính ticket subtotal
        // ticketSubtotal = giá vé cơ bản * số lượng ghế
        // Lưu ý: giá vé thực tế có thể khác nhau tùy loại ghế (VIP, Normal), nhưng ở đây chỉ tính base price
        double ticketSubtotal = session.getTicketPrice() * session.getSeatCount();
        session.setTicketSubtotal(ticketSubtotal);
        
        // Bước 2: Tính food subtotal (bao gồm combo và food riêng lẻ)
        double foodSubtotal = 0;
        
        // Bước 2.1: Tính tổng tiền combo
        // Duyệt qua các combo đã chọn và tính tổng
        if (combos != null && session.getSelectedCombos() != null) {
            for (java.util.Map.Entry<Integer, Integer> entry : session.getSelectedCombos().entrySet()) {
                com.cinema.entity.Combo combo = combos.get(entry.getKey());
                if (combo != null) {
                    // Ưu tiên dùng discountPrice nếu có, nếu không thì dùng totalPrice
                    double price = combo.getDiscountPrice() != null ? 
                                  combo.getDiscountPrice().doubleValue() : 
                                  combo.getTotalPrice().doubleValue();
                    // Tổng = giá * số lượng
                    foodSubtotal += price * entry.getValue();
                }
            }
        }
        
        // Bước 2.2: Tính tổng tiền food riêng lẻ
        // Duyệt qua các food đã chọn và tính tổng
        if (foods != null && session.getSelectedFoods() != null) {
            for (java.util.Map.Entry<Integer, Integer> entry : session.getSelectedFoods().entrySet()) {
                com.cinema.entity.Food food = foods.get(entry.getKey());
                if (food != null) {
                    // Tổng = giá * số lượng
                    foodSubtotal += food.getPrice().doubleValue() * entry.getValue();
                }
            }
        }
        
        // Lưu food subtotal vào session
        session.setFoodSubtotal(foodSubtotal);
        
        // Bước 3: Tính tổng tiền cuối cùng (totalAmount và finalAmount)
        // calculateTotals() sẽ tính: totalAmount = ticketSubtotal + foodSubtotal
        // và finalAmount = totalAmount - discountAmount
        session.calculateTotals();
    }
}

