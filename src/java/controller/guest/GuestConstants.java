package controller.guest;

/**
 * Lớp chứa các hằng số cho module khách (guest)
 * Tập trung tất cả các giá trị cố định để dễ bảo trì và tránh magic strings/numbers
 */
public final class GuestConstants {
    
    /**
     * Constructor private để ngăn việc khởi tạo instance
     * Đây là utility class chỉ chứa constants
     */
    private GuestConstants() {
        // Ngăn chặn việc khởi tạo instance
    }
    
    // ========== PHÂN TRANG (PAGINATION) ==========
    /** Số lượng bản ghi hiển thị trên mỗi trang */
    public static final int RECORDS_PER_PAGE = 12;
    /** Trang mặc định khi không có tham số page */
    public static final int DEFAULT_PAGE = 1;
    
    // ========== TRẠNG THÁI PHIM (MOVIE STATUS) ==========
    /** Trạng thái phim đang chiếu (Active) */
    public static final String STATUS_ACTIVE = "Active";
    /** Trạng thái phim sắp chiếu (Upcoming) */
    public static final String STATUS_UPCOMING = "Upcoming";
    
    // ========== ĐƯỜNG DẪN JSP (JSP PATHS) ==========
    /** Đường dẫn đến trang danh sách phim cho khách */
    public static final String JSP_GUEST_MOVIES = "guest-movies.jsp";
    /** Đường dẫn đến trang chi tiết phim cho khách */
    public static final String JSP_GUEST_MOVIE_DETAIL = "guest-movie-detail.jsp";
    
    // ========== ĐƯỜNG DẪN REDIRECT (REDIRECT PATHS) ==========
    /** Đường dẫn servlet danh sách phim cho khách */
    public static final String PATH_GUEST_MOVIES = "guest-movies";
}

