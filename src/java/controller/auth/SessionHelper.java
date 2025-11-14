package controller.auth;

import entity.User;
import jakarta.servlet.http.HttpSession;

/**
 * Lớp helper để quản lý session của người dùng
 * Cung cấp các phương thức tiện ích để thiết lập và xóa thông tin người dùng trong session
 * Giúp tránh code trùng lặp và đảm bảo tính nhất quán
 */
public final class SessionHelper {
    
    /**
     * Constructor private để ngăn việc khởi tạo instance
     * Đây là utility class chỉ chứa static methods
     */
    private SessionHelper() {
        // Ngăn chặn việc khởi tạo instance
    }
    
    /**
     * Thiết lập các thuộc tính session cho người dùng sau khi đăng nhập thành công
     * Lưu thông tin người dùng vào session để sử dụng trong các request tiếp theo
     * 
     * @param session HTTP session hiện tại
     * @param user Đối tượng User chứa thông tin người dùng đã đăng nhập
     */
    public static void setUserSession(HttpSession session, User user) {
        // Lưu toàn bộ đối tượng User vào session
        session.setAttribute(AuthConstants.SESSION_USER, user);
        // Lưu tên đầy đủ của người dùng
        session.setAttribute(AuthConstants.SESSION_USER_NAME, user.getFullName());
        // Lưu email của người dùng
        session.setAttribute(AuthConstants.SESSION_USER_EMAIL, user.getEmail());
        // Lưu vai trò của người dùng (Admin, Staff, Customer)
        session.setAttribute(AuthConstants.SESSION_USER_ROLE, user.getRole());
        // Lưu ID của người dùng
        session.setAttribute(AuthConstants.SESSION_USER_ID, user.getUserID());
    }
    
    /**
     * Xóa tất cả các thuộc tính session liên quan đến người dùng
     * Được sử dụng khi người dùng đăng xuất hoặc session hết hạn
     * 
     * @param session HTTP session cần xóa thông tin
     */
    public static void clearUserSession(HttpSession session) {
        // Xóa đối tượng User
        session.removeAttribute(AuthConstants.SESSION_USER);
        // Xóa tên người dùng
        session.removeAttribute(AuthConstants.SESSION_USER_NAME);
        // Xóa email người dùng
        session.removeAttribute(AuthConstants.SESSION_USER_EMAIL);
        // Xóa vai trò người dùng
        session.removeAttribute(AuthConstants.SESSION_USER_ROLE);
        // Xóa ID người dùng
        session.removeAttribute(AuthConstants.SESSION_USER_ID);
        // Xóa hành động OAuth (nếu có) - dùng cho flow đăng nhập/đăng ký qua Google
        session.removeAttribute(AuthConstants.SESSION_OAUTH_ACTION);
    }
}

