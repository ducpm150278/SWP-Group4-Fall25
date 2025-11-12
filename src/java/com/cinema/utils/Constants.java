package com.cinema.utils;

/**
 * Lớp chứa các hằng số tập trung cho ứng dụng
 * Bao gồm: vai trò người dùng, trạng thái, đường dẫn JSP, URL, session keys, v.v.
 */
public class Constants {
    
    // ========== USER ROLES ==========
    // Các vai trò người dùng trong hệ thống
    // Admin: Quản trị viên - có quyền cao nhất
    // Staff: Nhân viên - quản lý phim, xử lý refund
    // Customer: Khách hàng - người dùng thông thường
    public static final String ROLE_ADMIN = "Admin";
    public static final String ROLE_STAFF = "Staff";
    public static final String ROLE_CUSTOMER = "Customer";
    
    // ========== ACCOUNT STATUS ==========
    // Trạng thái tài khoản người dùng
    // Active: Tài khoản đang hoạt động, có thể đăng nhập
    // Inactive: Tài khoản bị vô hiệu hóa, không thể đăng nhập
    // Upcoming: (Không dùng cho account, chỉ dùng cho movie)
    public static final String STATUS_ACTIVE = "Active";
    public static final String STATUS_INACTIVE = "Inactive";
    public static final String STATUS_UPCOMING = "Upcoming";
    
    // ========== MOVIE STATUS ==========
    // Trạng thái phim
    // Active: Phim đang chiếu, có thể đặt vé
    // Upcoming: Phim sắp chiếu, có thể xem thông tin nhưng chưa đặt vé
    public static final String MOVIE_STATUS_ACTIVE = "Active";
    public static final String MOVIE_STATUS_UPCOMING = "Upcoming";
    
    // ========== SEAT STATUS ==========
    // Trạng thái ghế trong phòng chiếu
    // Available: Ghế có sẵn, có thể đặt
    // Unavailable: Ghế không khả dụng (đã bị vô hiệu hóa vĩnh viễn)
    // Maintenance: Ghế đang bảo trì (tạm thời không sử dụng)
    public static final String SEAT_STATUS_AVAILABLE = "Available";
    public static final String SEAT_STATUS_UNAVAILABLE = "Unavailable";
    public static final String SEAT_STATUS_MAINTENANCE = "Maintenance";
    
    // ========== BOOKING STATUS ==========
    // Trạng thái đơn đặt vé
    // Confirmed: Đơn đã được xác nhận (đã thanh toán thành công)
    // Cancelled: Đơn đã bị hủy
    // Completed: Đơn đã hoàn thành (đã xem phim xong)
    public static final String BOOKING_STATUS_CONFIRMED = "Confirmed";
    public static final String BOOKING_STATUS_CANCELLED = "Cancelled";
    public static final String BOOKING_STATUS_COMPLETED = "Completed";
    
    // ========== PAYMENT STATUS ==========
    // Trạng thái thanh toán
    // Completed: Thanh toán thành công
    // Pending: Đang chờ thanh toán
    // Failed: Thanh toán thất bại
    public static final String PAYMENT_STATUS_COMPLETED = "Completed";
    public static final String PAYMENT_STATUS_PENDING = "Pending";
    public static final String PAYMENT_STATUS_FAILED = "Failed";
    
    // ========== DISCOUNT STATUS ==========
    // Trạng thái mã giảm giá
    // Active: Mã giảm giá đang hoạt động, có thể sử dụng
    public static final String DISCOUNT_STATUS_ACTIVE = "Active";
    
    // ========== DISCOUNT TYPES ==========
    // Loại mã giảm giá
    // Percentage: Giảm theo phần trăm (ví dụ: 20% -> giảm 20% tổng tiền)
    // Fixed: Giảm số tiền cố định (ví dụ: 50,000 đ -> giảm 50,000 đ)
    public static final String DISCOUNT_TYPE_PERCENTAGE = "Percentage";
    public static final String DISCOUNT_TYPE_FIXED = "Fixed";
    
    // ========== JSP PATHS ==========
    // Đường dẫn đến các trang JSP trong ứng dụng
    // Được sử dụng trong RequestDispatcher.forward() để hiển thị trang
    // Tất cả paths đều là absolute path (bắt đầu bằng "/") để tránh vấn đề với servlet mapping patterns
    public static final String JSP_AUTH_LOGIN = "/pages/auth/login.jsp";                    // Trang đăng nhập
    public static final String JSP_AUTH_SIGNUP = "/pages/auth/signup.jsp";                   // Trang đăng ký
    public static final String JSP_AUTH_FORGOT_PASSWORD = "/pages/auth/forgot-password.jsp"; // Trang quên mật khẩu
    public static final String JSP_AUTH_RESET_PASSWORD = "/pages/auth/reset-password.jsp";    // Trang đặt lại mật khẩu
    public static final String JSP_MOVIE_GUEST_LIST = "/pages/movie/guest-movies.jsp";        // Trang danh sách phim (khách)
    public static final String JSP_MOVIE_GUEST_DETAIL = "/pages/movie/guest-movie-detail.jsp"; // Trang chi tiết phim (khách)
    public static final String JSP_BOOKING_SELECT_SCREENING = "/pages/booking/select-screening.jsp"; // Trang chọn suất chiếu
    public static final String JSP_BOOKING_SELECT_SEATS = "/pages/booking/select-seats.jsp";      // Trang chọn ghế
    public static final String JSP_BOOKING_SELECT_FOOD = "/pages/booking/select-food.jsp";         // Trang chọn đồ ăn
    public static final String JSP_BOOKING_PAYMENT = "/pages/booking/payment.jsp";                 // Trang thanh toán
    public static final String JSP_BOOKING_HISTORY = "/pages/booking/booking-history.jsp";  // Trang lịch sử đặt vé
    public static final String JSP_BOOKING_PAYMENT_SUCCESS = "/pages/booking/payment-success.jsp"; // Trang thanh toán thành công
    public static final String JSP_BOOKING_PAYMENT_FAILED = "/pages/booking/payment-failed.jsp";   // Trang thanh toán thất bại
    public static final String JSP_PROFILE_CHANGE_PASSWORD = "/pages/profile/change-password.jsp"; // Trang đổi mật khẩu
    public static final String JSP_PROFILE_VIEW_BOOKING = "/pages/profile/view-booking.jsp";  // Trang xem chi tiết booking
    public static final String JSP_STAFF_LIST_REFUNDS = "/pages/staff/list-refunds.jsp";      // Trang danh sách refund (Staff)
    public static final String JSP_STAFF_CHECK_IN = "/pages/staff/staff-check-in.jsp";        // Trang check-in (Staff)
    public static final String JSP_STAFF_NEW_TICKET = "/pages/staff/new-ticket.jsp";          // Trang tạo ticket mới (Staff)
    public static final String JSP_FOOD_COMBO = "/pages/food/combo.jsp";                     // Trang quản lý combo
    public static final String JSP_FOOD_EDIT_COMBO = "/pages/food/edit-combo.jsp";           // Trang chỉnh sửa combo
    public static final String JSP_FOOD_ADD_COMBO = "/pages/food/add-combo.jsp";             // Trang thêm combo
    public static final String JSP_FOOD_COMBO_FOOD_EDIT = "/pages/food/combo-food-edit.jsp";  // Trang chỉnh sửa combo-food
    public static final String JSP_ADMIN_DASHBOARD = "/pages/adminFE/admin_dashboard.jsp";    // Trang dashboard Admin
    public static final String JSP_PROFILE_WRITE_REVIEW = "/pages/profile/write-review.jsp";  // Trang viết review
    public static final String JSP_PROFILE_PROFILE = "/pages/profile/profile.jsp";            // Trang profile
    public static final String JSP_AUTH_VERIFY_EMAIL = "/pages/auth/verifyEmail.jsp";        // Trang xác thực email
    public static final String JSP_SUPPORT_HISTORY = "/pages/support/support-history.jsp";   // Trang lịch sử support
    public static final String JSP_SUPPORT_DETAIL = "/pages/support/support-detail.jsp";      // Trang chi tiết support
    public static final String JSP_STAFF_SUPPORT_DETAIL = "/pages/support/staff-support-detail.jsp"; // Trang chi tiết support (Staff)
    public static final String JSP_STAFF_SUPPORT_LIST = "/pages/support/staff-support-list.jsp";   // Trang danh sách support (Staff)
    public static final String JSP_SCREENING_ADD = "/pages/screening/add-screening.jsp";      // Trang thêm lịch chiếu
    public static final String JSP_SCREENING_EDIT = "/pages/screening/edit-screening.jsp";  // Trang chỉnh sửa lịch chiếu
    public static final String JSP_SCREENING_LIST = "/pages/screening/list-screening.jsp";    // Trang danh sách lịch chiếu
    public static final String JSP_SCREENING_VIEW = "/pages/screening/view-screening.jsp";    // Trang xem chi tiết lịch chiếu
    public static final String JSP_MOVIE_ADD = "/pages/movie/add-movie.jsp";                  // Trang thêm phim
    public static final String JSP_MOVIE_EDIT = "/pages/movie/edit-movie.jsp";                // Trang chỉnh sửa phim
    public static final String JSP_MOVIE_LIST = "/pages/movie/list-movie.jsp";                // Trang danh sách phim
    public static final String JSP_DISCOUNT_ADD = "/pages/discount/add-discount.jsp";          // Trang thêm mã giảm giá
    public static final String JSP_DISCOUNT_EDIT = "/pages/discount/edit-discount.jsp";        // Trang chỉnh sửa mã giảm giá
    public static final String JSP_DISCOUNT_LIST = "/pages/discount/list-discount.jsp";       // Trang danh sách mã giảm giá
    public static final String JSP_DISCOUNT_VIEW = "/pages/discount/view-discount.jsp";       // Trang xem chi tiết mã giảm giá
    
    // ========== URL PATTERNS ==========
    // Các URL patterns được sử dụng trong response.sendRedirect()
    // Khác với JSP paths, đây là các URL servlet patterns
    public static final String URL_HOME = "/index.jsp";                          // Trang chủ
    public static final String URL_ADMIN_DASHBOARD = "/adminFE/dashboard";       // Dashboard Admin
    public static final String URL_AUTH_LOGIN = "/auth/login";                   // URL đăng nhập
    public static final String URL_AUTH_SIGNUP = "/auth/signup";                 // URL đăng ký
    public static final String URL_BOOKING_SELECT_SCREENING = "/booking/select-screening"; // URL chọn suất chiếu
    public static final String URL_BOOKING_SELECT_SEATS = "/booking/select-seats";         // URL chọn ghế
    public static final String URL_BOOKING_SELECT_FOOD = "/booking/select-food";            // URL chọn đồ ăn
    public static final String URL_BOOKING_PAYMENT = "/booking/payment";                    // URL thanh toán
    public static final String URL_GUEST_MOVIES = "guest-movies";                          // URL danh sách phim (khách)
    public static final String URL_BOOKING_HISTORY = "/booking-history";                    // URL lịch sử đặt vé
    public static final String URL_LIST_SCREENING = "/listScreening";                       // URL danh sách lịch chiếu
    public static final String URL_SUPPORT = "/support";                                    // URL hỗ trợ
    public static final String URL_STAFF_SUPPORT = "/staff-support";                        // URL hỗ trợ nhân viên
    
    // ========== VALIDATION CONSTANTS ==========
    // Các hằng số dùng cho validation
    public static final int MIN_PASSWORD_LENGTH = 6;    // Độ dài tối thiểu của mật khẩu
    public static final int MIN_SEATS = 1;               // Số ghế tối thiểu có thể chọn
    public static final int MAX_SEATS = 8;               // Số ghế tối đa có thể chọn trong một lần đặt
    public static final int MOVIES_PER_PAGE = 12;       // Số phim hiển thị trên mỗi trang
    
    // ========== SESSION ATTRIBUTE KEYS ==========
    // Các key để lưu/đọc dữ liệu từ HttpSession
    // Sử dụng constants này để tránh typo và đảm bảo tính nhất quán
    public static final String SESSION_REDIRECT_AFTER_LOGIN = "redirectAfterLogin";  // URL để redirect sau khi đăng nhập
    public static final String SESSION_LOGIN_MESSAGE = "loginMessage";                // Thông báo hiển thị khi đăng nhập
    public static final String SESSION_ORDER_ID = "orderID";                          // Order ID từ VNPay để verify callback
    public static final String SESSION_OAUTH_ACTION = "oauth_action";                 // Action OAuth (login/signup)
    public static final String SESSION_VERIFICATION_CODE = "verificationCode";        // Mã xác thực email
    public static final String SESSION_VERIFICATION_EMAIL = "verificationEmail";      // Email đang được xác thực
    public static final String SESSION_VERIFICATION_EXPIRY = "verificationExpiry";    // Thời gian hết hạn mã xác thực
    public static final String SESSION_MESSAGE = "message";                           // Thông báo chung (success/info)
    public static final String SESSION_ERROR = "error";                               // Thông báo lỗi
    public static final String SESSION_BOOKING_SESSION = "bookingSession";            // BookingSession object
    
    // ========== ACTION PARAMETERS ==========
    // Các giá trị action parameter từ form/request
    // Được sử dụng để xác định hành động cần thực hiện trong servlet
    public static final String ACTION_SKIP = "skip";                    // Bỏ qua bước (ví dụ: bỏ qua chọn đồ ăn)
    public static final String ACTION_CANCEL = "cancel";                // Hủy booking
    public static final String ACTION_APPLY_DISCOUNT = "applyDiscount"; // Áp dụng mã giảm giá
    public static final String ACTION_PAYMENT = "payment";              // Submit thanh toán
    public static final String ACTION_LOGIN = "login";                  // Đăng nhập
    public static final String ACTION_SIGNUP = "signup";                // Đăng ký
    public static final String ACTION_SEND_CODE = "sendcode";           // Gửi mã xác thực
    public static final String ACTION_VERIFY = "verify";                // Xác thực mã
    
    // ========== FILTER VALUES ==========
    // Các giá trị filter cho danh sách
    public static final String FILTER_ALL = "all";  // Hiển thị tất cả (không filter)
    
    // ========== PAYMENT METHODS ==========
    // Các phương thức thanh toán được hỗ trợ
    public static final String PAYMENT_METHOD_VNPAY = "VNPay";  // Thanh toán qua VNPay
    
    // Private constructor to prevent instantiation
    private Constants() {
        throw new UnsupportedOperationException("Constants class cannot be instantiated");
    }
}
