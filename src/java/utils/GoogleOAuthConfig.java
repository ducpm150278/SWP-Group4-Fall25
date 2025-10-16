/*
 * Google OAuth Configuration
 * Contains OAuth 2.0 client credentials and configuration
 */
package utils;

public class GoogleOAuthConfig {
    
    // Google OAuth 2.0 Client Configuration
    // TODO: Replace with your actual Google OAuth 2.0 credentials
    // Get these from Google Cloud Console: https://console.cloud.google.com/
    public static final String CLIENT_ID = "237120821381-52m0kgbl35ci18mani6ql3oinsaj3bh5.apps.googleusercontent.com";
    public static final String CLIENT_SECRET = "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";
    
    // OAuth 2.0 URLs
    public static final String AUTHORIZATION_ENDPOINT = "https://accounts.google.com/o/oauth2/v2/auth";
    public static final String TOKEN_ENDPOINT = "https://oauth2.googleapis.com/token";
    public static final String USER_INFO_ENDPOINT = "https://www.googleapis.com/oauth2/v2/userinfo";
    
    // Redirect URI (must match the one configured in Google Cloud Console)
    public static final String REDIRECT_URI = "http://localhost:8080/SWP-Group4-Fall25/GoogleAuthCallback";
    
    // Scopes for user information
    public static final String SCOPE = "openid email profile";
    
    // Response type
    public static final String RESPONSE_TYPE = "code";
    
    // Access type
    public static final String ACCESS_TYPE = "offline";
    
    // Prompt type
    public static final String PROMPT = "consent";
    
    /**
     * Builds the Google OAuth 2.0 authorization URL
     * @return Complete authorization URL
     */
    public static String getAuthorizationUrl() {
        StringBuilder url = new StringBuilder();
        url.append(AUTHORIZATION_ENDPOINT);
        url.append("?client_id=").append(CLIENT_ID);
        url.append("&redirect_uri=").append(REDIRECT_URI);
        url.append("&scope=").append(SCOPE);
        url.append("&response_type=").append(RESPONSE_TYPE);
        url.append("&access_type=").append(ACCESS_TYPE);
        url.append("&prompt=").append(PROMPT);
        return url.toString();
    }
    
    /**
     * Builds the token exchange URL
     * @return Token endpoint URL
     */
    public static String getTokenUrl() {
        return TOKEN_ENDPOINT;
    }
    
    /**
     * Builds the user info URL
     * @return User info endpoint URL
     */
    public static String getUserInfoUrl() {
        return USER_INFO_ENDPOINT;
    }
}
