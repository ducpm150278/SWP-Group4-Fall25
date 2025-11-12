/**
 * Cấu hình Google OAuth 2.0
 * Chứa thông tin xác thực OAuth 2.0 client và các cấu hình
 * 
 * Lưu ý: 
 * - CLIENT_ID và CLIENT_SECRET cần được lấy từ Google Cloud Console
 * - REDIRECT_URI phải khớp với URI đã cấu hình trong Google Cloud Console
 * - Khi deploy production, cần cập nhật REDIRECT_URI cho domain thật
 */
package com.cinema.utils;

public class GoogleOAuthConfig {
    
    // ========== Google OAuth 2.0 Client Configuration ==========
    // Thông tin xác thực OAuth 2.0 client từ Google Cloud Console
    // Lấy từ: https://console.cloud.google.com/apis/credentials
    public static final String CLIENT_ID = "237120821381-52m0kgbl35ci18mani6ql3oinsaj3bh5.apps.googleusercontent.com";
    public static final String CLIENT_SECRET = "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";
    
    // ========== OAuth 2.0 Endpoints ==========
    // Các URL endpoints của Google OAuth 2.0
    public static final String AUTHORIZATION_ENDPOINT = "https://accounts.google.com/o/oauth2/v2/auth";  // URL để redirect người dùng đăng nhập
    public static final String TOKEN_ENDPOINT = "https://oauth2.googleapis.com/token";                    // URL để đổi authorization code lấy access token
    public static final String USER_INFO_ENDPOINT = "https://www.googleapis.com/oauth2/v2/userinfo";      // URL để lấy thông tin người dùng
    
    // ========== Redirect URI ==========
    // URI callback sau khi người dùng xác thực thành công
    // QUAN TRỌNG: Phải khớp chính xác với URI đã cấu hình trong Google Cloud Console
    public static final String REDIRECT_URI = "http://localhost:8080/SWP-Group4-Fall25/GoogleAuthCallback";
    
    // ========== OAuth 2.0 Parameters ==========
    // Các tham số cho OAuth 2.0 flow
    public static final String SCOPE = "openid email profile";  // Quyền truy cập: openid (xác thực), email (email), profile (thông tin cá nhân)
    public static final String RESPONSE_TYPE = "code";          // Loại response: authorization code
    public static final String ACCESS_TYPE = "offline";          // Yêu cầu refresh token (để sử dụng lâu dài)
    public static final String PROMPT = "consent";              // Luôn hiển thị consent screen (để đảm bảo có refresh token)
    
    /**
     * Xây dựng URL authorization để redirect người dùng đến Google đăng nhập
     * Flow: Người dùng click "Đăng nhập bằng Google" -> Redirect đến URL này -> Google xác thực -> Callback về REDIRECT_URI
     * 
     * @return URL authorization đầy đủ với tất cả parameters
     */
    public static String getAuthorizationUrl() {
        StringBuilder url = new StringBuilder();
        url.append(AUTHORIZATION_ENDPOINT);
        url.append("?client_id=").append(CLIENT_ID);              // Client ID để Google biết ứng dụng nào đang yêu cầu
        url.append("&redirect_uri=").append(REDIRECT_URI);         // URI callback sau khi xác thực
        url.append("&scope=").append(SCOPE);                      // Quyền truy cập cần thiết
        url.append("&response_type=").append(RESPONSE_TYPE);     // Yêu cầu authorization code
        url.append("&access_type=").append(ACCESS_TYPE);         // Yêu cầu refresh token
        url.append("&prompt=").append(PROMPT);                   // Luôn hiển thị consent screen
        return url.toString();
    }
    
    /**
     * Lấy URL endpoint để đổi authorization code lấy access token
     * Sau khi người dùng xác thực, Google redirect về với authorization code
     * Ứng dụng cần đổi code này lấy access token để gọi API
     * 
     * @return Token endpoint URL
     */
    public static String getTokenUrl() {
        return TOKEN_ENDPOINT;
    }
    
    /**
     * Lấy URL endpoint để lấy thông tin người dùng từ Google
     * Sử dụng access token để gọi API này và lấy thông tin: email, name, id, v.v.
     * 
     * @return User info endpoint URL
     */
    public static String getUserInfoUrl() {
        return USER_INFO_ENDPOINT;
    }
}
