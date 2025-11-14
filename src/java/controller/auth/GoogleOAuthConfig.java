/*
 * Lớp cấu hình Google OAuth 2.0
 * Chứa các thông tin cấu hình cần thiết để tích hợp Google OAuth vào ứng dụng
 * 
 * Các thông tin cấu hình bao gồm:
 * - Client ID và Client Secret (lấy từ Google Cloud Console)
 * - Các endpoint URLs của Google OAuth API
 * - Redirect URI (phải khớp với cấu hình trong Google Cloud Console)
 * - Scopes (quyền truy cập cần thiết)
 * - Các tham số OAuth khác
 * 
 * Lưu ý: Trong môi trường production, nên lưu CLIENT_SECRET ở nơi an toàn hơn (environment variables, config file được bảo vệ)
 */
package controller.auth;

public class GoogleOAuthConfig {
    
    // ========== THÔNG TIN XÁC THỰC CLIENT (CLIENT CREDENTIALS) ==========
    /**
     * Google OAuth 2.0 Client ID
     * Được cấp từ Google Cloud Console khi tạo OAuth 2.0 Client
     * TODO: Thay thế bằng Client ID thực tế của bạn
     * Lấy từ: https://console.cloud.google.com/ → APIs & Services → Credentials
     */
    public static final String CLIENT_ID = "237120821381-52m0kgbl35ci18mani6ql3oinsaj3bh5.apps.googleusercontent.com";
    
    /**
     * Google OAuth 2.0 Client Secret
     * Được cấp từ Google Cloud Console, cần được bảo mật
     * TODO: Thay thế bằng Client Secret thực tế của bạn
     * Lưu ý: Không commit secret này vào public repository
     */
    public static final String CLIENT_SECRET = "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";
    
    // ========== CÁC ENDPOINT URLs CỦA GOOGLE OAUTH API ==========
    /**
     * Endpoint để bắt đầu quá trình xác thực OAuth
     * Người dùng sẽ được redirect đến URL này để đăng nhập và cấp quyền
     */
    public static final String AUTHORIZATION_ENDPOINT = "https://accounts.google.com/o/oauth2/v2/auth";
    
    /**
     * Endpoint để đổi authorization code lấy access token
     * Sử dụng trong bước exchange code for token
     */
    public static final String TOKEN_ENDPOINT = "https://oauth2.googleapis.com/token";
    
    /**
     * Endpoint để lấy thông tin user từ Google
     * Sử dụng access token để truy vấn thông tin user (email, name, etc.)
     */
    public static final String USER_INFO_ENDPOINT = "https://www.googleapis.com/oauth2/v2/userinfo";
    
    // ========== CẤU HÌNH REDIRECT ==========
    /**
     * Redirect URI sau khi Google xác thực xong
     * Phải khớp chính xác với URI đã cấu hình trong Google Cloud Console
     * Format: http://domain:port/context-path/servlet-path
     */
    public static final String REDIRECT_URI = "http://localhost:8080/SWP-Group4-Fall25/GoogleAuthCallback";
    
    // ========== SCOPES (QUYỀN TRUY CẬP) ==========
    /**
     * Scopes yêu cầu từ Google
     * - openid: Xác thực OpenID Connect
     * - email: Truy cập email của user
     * - profile: Truy cập thông tin profile cơ bản (name, picture, etc.)
     */
    public static final String SCOPE = "openid email profile";
    
    // ========== CÁC THAM SỐ OAUTH ==========
    /**
     * Response type cho OAuth flow
     * "code" nghĩa là sử dụng Authorization Code flow (flow chuẩn và an toàn nhất)
     */
    public static final String RESPONSE_TYPE = "code";
    
    /**
     * Access type
     * "offline" cho phép nhận refresh token (để refresh access token sau khi hết hạn)
     * "online" chỉ nhận access token (không có refresh token)
     */
    public static final String ACCESS_TYPE = "offline";
    
    /**
     * Prompt type
     * "consent" yêu cầu user xác nhận quyền truy cập mỗi lần (để đảm bảo user biết đang cấp quyền gì)
     * Có thể dùng "select_account" để cho phép user chọn tài khoản Google
     */
    public static final String PROMPT = "consent";
    
    /**
     * Xây dựng URL xác thực Google OAuth 2.0 đầy đủ
     * 
     * Flow:
     * 1. Tạo base URL từ AUTHORIZATION_ENDPOINT
     * 2. Thêm các query parameters: client_id, redirect_uri, scope, response_type, access_type, prompt
     * 3. Trả về URL hoàn chỉnh để redirect người dùng đến Google
     * 
     * @return URL xác thực đầy đủ với tất cả parameters cần thiết
     */
    public static String getAuthorizationUrl() {
        StringBuilder url = new StringBuilder();
        // Base URL của Google authorization endpoint
        url.append(AUTHORIZATION_ENDPOINT);
        // Thêm Client ID
        url.append("?client_id=").append(CLIENT_ID);
        // Thêm Redirect URI (nơi Google sẽ redirect về sau khi xác thực)
        url.append("&redirect_uri=").append(REDIRECT_URI);
        // Thêm Scopes (quyền truy cập cần thiết)
        url.append("&scope=").append(SCOPE);
        // Thêm Response Type (code cho Authorization Code flow)
        url.append("&response_type=").append(RESPONSE_TYPE);
        // Thêm Access Type (offline để nhận refresh token)
        url.append("&access_type=").append(ACCESS_TYPE);
        // Thêm Prompt (consent để yêu cầu user xác nhận)
        url.append("&prompt=").append(PROMPT);
        return url.toString();
    }
    
    /**
     * Lấy URL của token endpoint
     * Endpoint này được sử dụng để đổi authorization code lấy access token
     * 
     * @return URL của token endpoint
     */
    public static String getTokenUrl() {
        return TOKEN_ENDPOINT;
    }
    
    /**
     * Lấy URL của user info endpoint
     * Endpoint này được sử dụng để lấy thông tin user từ Google bằng access token
     * 
     * @return URL của user info endpoint
     */
    public static String getUserInfoUrl() {
        return USER_INFO_ENDPOINT;
    }
}

