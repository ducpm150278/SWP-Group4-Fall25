package controller.auth;

/**
 * Lớp chứa các hằng số cho module xác thực (authentication)
 * Tập trung tất cả các giá trị cố định để dễ bảo trì và tránh magic strings/numbers
 */
public final class AuthConstants {
    
    /**
     * Constructor private để ngăn việc khởi tạo instance
     * Đây là utility class chỉ chứa constants
     */
    private AuthConstants() {
        // Ngăn chặn việc khởi tạo instance
    }
    
    // ========== VAI TRÒ NGƯỜI DÙNG (USER ROLES) ==========
    /** Vai trò quản trị viên - có quyền cao nhất trong hệ thống */
    public static final String ROLE_ADMIN = "Admin";
    /** Vai trò nhân viên - có quyền quản lý một số chức năng */
    public static final String ROLE_STAFF = "Staff";
    /** Vai trò khách hàng - người dùng thông thường */
    public static final String ROLE_CUSTOMER = "Customer";
    
    // ========== TRẠNG THÁI TÀI KHOẢN (ACCOUNT STATUS) ==========
    /** Trạng thái tài khoản đang hoạt động */
    public static final String STATUS_ACTIVE = "Active";
    
    // ========== HÀNH ĐỘNG OAuth (OAUTH ACTIONS) ==========
    /** Hành động đăng nhập qua Google OAuth */
    public static final String ACTION_LOGIN = "login";
    /** Hành động đăng ký qua Google OAuth */
    public static final String ACTION_SIGNUP = "signup";
    
    // ========== VALIDATION (KIỂM TRA DỮ LIỆU) ==========
    /** Độ dài tối thiểu của mật khẩu (6 ký tự) */
    public static final int MIN_PASSWORD_LENGTH = 6;
    /** Regex pattern để validate định dạng email */
    public static final String EMAIL_REGEX = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$";
    
    // ========== GIÁ TRỊ MẶC ĐỊNH (DEFAULT VALUES) ==========
    /** Giới tính mặc định khi người dùng không chọn */
    public static final String DEFAULT_GENDER = "Other";
    /** Mật khẩu placeholder cho người dùng đăng ký qua Google OAuth 
     * (vì Google không cung cấp mật khẩu) */
    public static final String OAUTH_PLACEHOLDER_PASSWORD = "GOOGLE_OAUTH_USER";
    
    // ========== THUỘC TÍNH SESSION (SESSION ATTRIBUTES) ==========
    /** Key lưu đối tượng User trong session */
    public static final String SESSION_USER = "user";
    /** Key lưu tên người dùng trong session */
    public static final String SESSION_USER_NAME = "userName";
    /** Key lưu email người dùng trong session */
    public static final String SESSION_USER_EMAIL = "userEmail";
    /** Key lưu vai trò người dùng trong session */
    public static final String SESSION_USER_ROLE = "userRole";
    /** Key lưu ID người dùng trong session */
    public static final String SESSION_USER_ID = "userId";
    /** Key lưu hành động OAuth (login/signup) trong session để xử lý callback */
    public static final String SESSION_OAUTH_ACTION = "oauth_action";
    /** Key lưu URL để redirect sau khi đăng nhập thành công */
    public static final String SESSION_REDIRECT_AFTER_LOGIN = "redirectAfterLogin";
    
    // ========== ĐƯỜNG DẪN JSP (JSP PATHS) ==========
    /** Đường dẫn đến trang đăng nhập */
    public static final String JSP_LOGIN = "/login.jsp";
    /** Đường dẫn đến trang đăng ký */
    public static final String JSP_SIGNUP = "/signup.jsp";
    /** Đường dẫn đến trang quên mật khẩu */
    public static final String JSP_FORGOT_PASSWORD = "/forgot-password.jsp";
    /** Đường dẫn đến trang đặt lại mật khẩu */
    public static final String JSP_RESET_PASSWORD = "/reset-password.jsp";
    /** Đường dẫn đến trang chủ */
    public static final String JSP_INDEX = "/index.jsp";
    
    // ========== ĐƯỜNG DẪN REDIRECT (REDIRECT PATHS) ==========
    /** Đường dẫn redirect cho Admin sau khi đăng nhập */
    public static final String PATH_ADMIN_LIST = "/list";
    /** Đường dẫn redirect cho Staff sau khi đăng nhập */
    public static final String PATH_STAFF_MANAGER = "/manager";
}

