package com.cinema.utils;


import jakarta.servlet.http.HttpSession;

/**
 * Lớp tiện ích để xử lý session attributes một cách nhất quán
 * Cung cấp các phương thức để lấy và kiểm tra thông tin người dùng từ session
 */
public class SessionUtils {
    
    // ========== SESSION ATTRIBUTE NAMES ==========
    // Các tên attribute được sử dụng để lưu thông tin người dùng trong session
    // Sử dụng constants này để đảm bảo tính nhất quán và tránh typo
    public static final String ATTR_USER = "user";           // User object đầy đủ
    public static final String ATTR_USER_ID = "userId";      // User ID (Integer) - Lưu ý: lowercase 'i'
    public static final String ATTR_USER_NAME = "userName";  // Tên người dùng (String)
    public static final String ATTR_USER_EMAIL = "userEmail"; // Email người dùng (String)
    public static final String ATTR_USER_ROLE = "userRole";   // Vai trò người dùng (String)
    
    /**
     * Lấy User ID từ session
     * @param session HttpSession chứa thông tin người dùng
     * @return User ID (Integer) hoặc null nếu không có
     */
    public static Integer getUserId(HttpSession session) {
        if (session == null) {
            return null;
        }
        return (Integer) session.getAttribute(ATTR_USER_ID);
    }
    
    /**
     * Lấy User object từ session
     * @param session HttpSession chứa thông tin người dùng
     * @return User object hoặc null nếu không có
     */
    public static Object getUser(HttpSession session) {
        if (session == null) {
            return null;
        }
        return session.getAttribute(ATTR_USER);
    }
    
    /**
     * Kiểm tra người dùng đã đăng nhập chưa
     * Kiểm tra bằng cách xem có userId hoặc user object trong session không
     * @param session HttpSession cần kiểm tra
     * @return true nếu đã đăng nhập, false nếu chưa
     */
    public static boolean isLoggedIn(HttpSession session) {
        if (session == null) {
            return false;
        }
        // Kiểm tra cả userId và user object để đảm bảo tính linh hoạt
        Integer userId = getUserId(session);
        Object user = getUser(session);
        return userId != null || user != null;
    }
    
    /**
     * Lấy tên người dùng từ session
     * @param session HttpSession chứa thông tin người dùng
     * @return Tên người dùng (String) hoặc null nếu không có
     */
    public static String getUserName(HttpSession session) {
        if (session == null) {
            return null;
        }
        return (String) session.getAttribute(ATTR_USER_NAME);
    }
    
    /**
     * Lấy email người dùng từ session
     * @param session HttpSession chứa thông tin người dùng
     * @return Email người dùng (String) hoặc null nếu không có
     */
    public static String getUserEmail(HttpSession session) {
        if (session == null) {
            return null;
        }
        return (String) session.getAttribute(ATTR_USER_EMAIL);
    }
    
    /**
     * Lấy vai trò người dùng từ session
     * @param session HttpSession chứa thông tin người dùng
     * @return Vai trò người dùng (String) hoặc null nếu không có
     */
    public static String getUserRole(HttpSession session) {
        if (session == null) {
            return null;
        }
        return (String) session.getAttribute(ATTR_USER_ROLE);
    }
    
    /**
     * Kiểm tra người dùng có vai trò cụ thể không
     * So sánh case-insensitive để đảm bảo tính linh hoạt
     * @param session HttpSession chứa thông tin người dùng
     * @param role Vai trò cần kiểm tra
     * @return true nếu người dùng có vai trò đó, false nếu không
     */
    public static boolean hasRole(HttpSession session, String role) {
        if (session == null || role == null) {
            return false;
        }
        String userRole = getUserRole(session);
        // So sánh case-insensitive để tránh lỗi do chữ hoa/thường
        return role.equalsIgnoreCase(userRole);
    }
    
    /**
     * Kiểm tra người dùng có phải Admin không
     * @param session HttpSession chứa thông tin người dùng
     * @return true nếu là Admin, false nếu không
     */
    public static boolean isAdmin(HttpSession session) {
        return hasRole(session, Constants.ROLE_ADMIN);
    }
    
    /**
     * Kiểm tra người dùng có phải Customer không
     * @param session HttpSession chứa thông tin người dùng
     * @return true nếu là Customer, false nếu không
     */
    public static boolean isCustomer(HttpSession session) {
        return hasRole(session, Constants.ROLE_CUSTOMER);
    }
}

