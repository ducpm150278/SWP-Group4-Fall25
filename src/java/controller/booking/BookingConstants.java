package controller.booking;

/**
 * Lớp chứa các hằng số cho module đặt vé (booking)
 * Tập trung tất cả các giá trị cố định để dễ bảo trì và tránh magic strings/numbers
 */
public final class BookingConstants {
    
    /**
     * Constructor private để ngăn việc khởi tạo instance
     * Đây là utility class chỉ chứa constants
     */
    private BookingConstants() {
        // Ngăn chặn việc khởi tạo instance
    }
    
    // ========== GIỚI HẠN CHỌN GHẾ (SEAT SELECTION LIMITS) ==========
    /** Số lượng ghế tối thiểu có thể chọn trong một lần đặt vé */
    public static final int MIN_SEATS = 1;
    /** Số lượng ghế tối đa có thể chọn trong một lần đặt vé */
    public static final int MAX_SEATS = 8;
    
    // ========== TRẠNG THÁI GHẾ (SEAT STATUS) ==========
    /** Trạng thái ghế không khả dụng (đã bị hủy hoặc không sử dụng) */
    public static final String SEAT_STATUS_UNAVAILABLE = "Unavailable";
    /** Trạng thái ghế đang bảo trì (không thể đặt) */
    public static final String SEAT_STATUS_MAINTENANCE = "Maintenance";
    
    // ========== HÀNH ĐỘNG (ACTIONS) ==========
    /** Hành động bỏ qua bước chọn đồ ăn (skip food selection) */
    public static final String ACTION_SKIP = "skip";
    /** Hành động áp dụng mã giảm giá */
    public static final String ACTION_APPLY_DISCOUNT = "applyDiscount";
    /** Hành động thanh toán */
    public static final String ACTION_PAYMENT = "payment";
    
    // ========== THAM SỐ REQUEST (REQUEST PARAMETERS) ==========
    /** Tham số để xác định request có phải AJAX không */
    public static final String PARAM_AJAX = "ajax";
    /** Giá trị "true" cho tham số AJAX */
    public static final String PARAM_AJAX_TRUE = "true";
    /** Tham số chứa danh sách ID các ghế được chọn */
    public static final String PARAM_SEAT_IDS = "seatIDs";
    /** Tham số chứa danh sách ID các combo được chọn */
    public static final String PARAM_COMBO_IDS = "comboIDs";
    /** Tham số chứa số lượng của từng combo */
    public static final String PARAM_COMBO_QUANTITIES = "comboQuantities";
    /** Tham số chứa danh sách ID các món ăn được chọn */
    public static final String PARAM_FOOD_IDS = "foodIDs";
    /** Tham số chứa số lượng của từng món ăn */
    public static final String PARAM_FOOD_QUANTITIES = "foodQuantities";
    /** Tham số chứa mã giảm giá */
    public static final String PARAM_DISCOUNT_CODE = "discountCode";
    /** Tham số xác nhận đồng ý với điều khoản */
    public static final String PARAM_AGREE_TERMS = "agreeTerms";
    /** Tham số phương thức thanh toán */
    public static final String PARAM_PAYMENT_METHOD = "paymentMethod";
    /** Tham số ID suất chiếu */
    public static final String PARAM_SCREENING_ID = "screeningID";
    
    // ========== ĐƯỜNG DẪN JSP (JSP PATHS) ==========
    /** Đường dẫn đến trang chọn suất chiếu (bước 1) */
    public static final String JSP_SELECT_SCREENING = "/booking/select-screening.jsp";
    /** Đường dẫn đến trang chọn ghế (bước 2) */
    public static final String JSP_SELECT_SEATS = "/booking/select-seats.jsp";
    /** Đường dẫn đến trang chọn đồ ăn (bước 3) */
    public static final String JSP_SELECT_FOOD = "/booking/select-food.jsp";
    /** Đường dẫn đến trang thanh toán (bước 4) */
    public static final String JSP_PAYMENT = "/booking/payment.jsp";
    /** Đường dẫn đến trang thanh toán thành công */
    public static final String JSP_PAYMENT_SUCCESS = "/booking/payment-success.jsp";
    /** Đường dẫn đến trang thanh toán thất bại */
    public static final String JSP_PAYMENT_FAILED = "/booking/payment-failed.jsp";
    
    // ========== ĐƯỜNG DẪN REDIRECT (REDIRECT PATHS) ==========
    /** Đường dẫn servlet chọn suất chiếu */
    public static final String PATH_SELECT_SCREENING = "/booking/select-screening";
    /** Đường dẫn servlet chọn ghế */
    public static final String PATH_SELECT_SEATS = "/booking/select-seats";
    /** Đường dẫn servlet chọn đồ ăn */
    public static final String PATH_SELECT_FOOD = "/booking/select-food";
    /** Đường dẫn servlet thanh toán */
    public static final String PATH_PAYMENT = "/booking/payment";
    
    // ========== PHƯƠNG THỨC THANH TOÁN (PAYMENT METHODS) ==========
    /** Phương thức thanh toán qua VNPay */
    public static final String PAYMENT_METHOD_VNPAY = "VNPay";
}

