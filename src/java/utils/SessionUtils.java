package utils;

import jakarta.servlet.http.HttpSession;

/**
 * Utility class for consistent session attribute handling
 */
public class SessionUtils {
    
    // Session attribute names
    public static final String ATTR_USER = "user";
    public static final String ATTR_USER_ID = "userId";  // Note: lowercase 'i'
    public static final String ATTR_USER_NAME = "userName";
    public static final String ATTR_USER_EMAIL = "userEmail";
    public static final String ATTR_USER_ROLE = "userRole";
    
    /**
     * Get user ID from session
     */
    public static Integer getUserId(HttpSession session) {
        if (session == null) {
            return null;
        }
        return (Integer) session.getAttribute(ATTR_USER_ID);
    }
    
    /**
     * Get user object from session
     */
    public static Object getUser(HttpSession session) {
        if (session == null) {
            return null;
        }
        return session.getAttribute(ATTR_USER);
    }
    
    /**
     * Check if user is logged in
     */
    public static boolean isLoggedIn(HttpSession session) {
        if (session == null) {
            return false;
        }
        Integer userId = getUserId(session);
        Object user = getUser(session);
        return userId != null || user != null;
    }
    
    /**
     * Get user name from session
     */
    public static String getUserName(HttpSession session) {
        if (session == null) {
            return null;
        }
        return (String) session.getAttribute(ATTR_USER_NAME);
    }
    
    /**
     * Get user email from session
     */
    public static String getUserEmail(HttpSession session) {
        if (session == null) {
            return null;
        }
        return (String) session.getAttribute(ATTR_USER_EMAIL);
    }
    
    /**
     * Get user role from session
     */
    public static String getUserRole(HttpSession session) {
        if (session == null) {
            return null;
        }
        return (String) session.getAttribute(ATTR_USER_ROLE);
    }
    
    /**
     * Check if user has specific role
     */
    public static boolean hasRole(HttpSession session, String role) {
        if (session == null || role == null) {
            return false;
        }
        String userRole = getUserRole(session);
        return role.equalsIgnoreCase(userRole);
    }
    
    /**
     * Check if user is admin
     */
    public static boolean isAdmin(HttpSession session) {
        return hasRole(session, "Admin");
    }
    
    /**
     * Check if user is customer
     */
    public static boolean isCustomer(HttpSession session) {
        return hasRole(session, "Customer");
    }
}

