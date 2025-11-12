/*
 * Helper xử lý Google OAuth
 * Xử lý đổi authorization code lấy access token và lấy thông tin người dùng từ Google
 */
package com.cinema.utils;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;

public class GoogleOAuthHelper {
    
    /**
     * Đổi authorization code lấy access token
     * Sau khi người dùng xác thực, Google redirect về với authorization code
     * Method này gửi POST request đến Google để đổi code lấy access token
     * 
     * Flow:
     * 1. Nhận authorization code từ Google callback
     * 2. Gửi POST request với code, client_id, client_secret, redirect_uri
     * 3. Google trả về JSON chứa access_token và refresh_token
     * 4. Parse và trả về access_token
     * 
     * @param code Authorization code từ Google (sau khi người dùng xác thực)
     * @return Access token để sử dụng gọi Google API
     * @throws IOException nếu request thất bại hoặc response không hợp lệ
     */
    public static String exchangeCodeForToken(String code) throws IOException {
        String tokenUrl = GoogleOAuthConfig.getTokenUrl();
        
        // Bước 1: Chuẩn bị POST data để gửi đến Google
        Map<String, String> params = new HashMap<>();
        params.put("client_id", GoogleOAuthConfig.CLIENT_ID);           // Client ID để xác thực
        params.put("client_secret", GoogleOAuthConfig.CLIENT_SECRET);   // Client secret để xác thực
        params.put("code", code);                                        // Authorization code từ callback
        params.put("grant_type", "authorization_code");                  // Loại grant (authorization code flow)
        params.put("redirect_uri", GoogleOAuthConfig.REDIRECT_URI);      // Redirect URI (phải khớp với lúc request)
        
        // Bước 2: Build POST data string (application/x-www-form-urlencoded format)
        StringBuilder postData = new StringBuilder();
        for (Map.Entry<String, String> entry : params.entrySet()) {
            if (postData.length() != 0) {
                postData.append("&");  // Thêm dấu & giữa các parameters
            }
            // URL encode key và value
            postData.append(URLEncoder.encode(entry.getKey(), StandardCharsets.UTF_8));
            postData.append("=");
            postData.append(URLEncoder.encode(entry.getValue(), StandardCharsets.UTF_8));
        }
        
        // Bước 3: Tạo HTTP POST connection
        URL url = new URL(tokenUrl);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setDoOutput(true);  // Cho phép gửi POST data
        conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
        
        // Bước 4: Gửi POST data
        try (OutputStreamWriter writer = new OutputStreamWriter(conn.getOutputStream())) {
            writer.write(postData.toString());
        }
        
        // Bước 5: Đọc response từ Google
        int responseCode = conn.getResponseCode();
        if (responseCode == HttpURLConnection.HTTP_OK) {
            // Response thành công - đọc JSON response
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream()))) {
                StringBuilder response = new StringBuilder();
                String line;
                while ((line = reader.readLine()) != null) {
                    response.append(line);
                }
                
                // Bước 6: Parse JSON response để lấy access_token
                String jsonResponse = response.toString();
                return extractAccessToken(jsonResponse);
            }
        } else {
            // Response lỗi - đọc error response để debug
            StringBuilder errorResponse = new StringBuilder();
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getErrorStream()))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    errorResponse.append(line);
                }
            } catch (Exception e) {
                // Ignore nếu error stream không có
            }
            throw new IOException("Token exchange failed with response code: " + responseCode + 
                                ". Error response: " + errorResponse.toString());
        }
    }
    
    /**
     * Lấy thông tin người dùng từ Google bằng access token
     * Gửi GET request đến Google User Info API với access token
     * Trả về JSON chứa: id, email, name, picture, v.v.
     * 
     * @param accessToken Access token từ exchangeCodeForToken()
     * @return JSON string chứa thông tin người dùng
     * @throws IOException nếu request thất bại hoặc access token không hợp lệ
     */
    public static String getUserInfo(String accessToken) throws IOException {
        // Build URL với access token (có thể dùng query param hoặc Authorization header)
        String userInfoUrl = GoogleOAuthConfig.getUserInfoUrl() + "?access_token=" + accessToken;
        
        // Bước 1: Tạo HTTP GET connection
        URL url = new URL(userInfoUrl);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        // Cũng có thể dùng Authorization header thay vì query param
        conn.setRequestProperty("Authorization", "Bearer " + accessToken);
        
        // Bước 2: Đọc response
        int responseCode = conn.getResponseCode();
        
        if (responseCode == HttpURLConnection.HTTP_OK) {
            // Response thành công - đọc JSON response
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream()))) {
                StringBuilder response = new StringBuilder();
                String line;
                while ((line = reader.readLine()) != null) {
                    response.append(line);
                }
                String userInfoJson = response.toString();
                return userInfoJson;
            }
        } else {
            // Response lỗi - đọc error response để debug
            StringBuilder errorResponse = new StringBuilder();
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getErrorStream()))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    errorResponse.append(line);
                }
            } catch (Exception e) {
                // Ignore nếu error stream không có
            }
            throw new IOException("User info request failed with response code: " + responseCode + 
                                ". Error response: " + errorResponse.toString());
        }
    }
    
    /**
     * Parse access token từ JSON response
     * JSON response từ token exchange có format:
     * {"access_token": "...", "refresh_token": "...", "expires_in": 3600, ...}
     * 
     * Lưu ý: Đây là simple JSON parsing. Trong production nên dùng thư viện như Jackson hoặc Gson
     * 
     * @param jsonResponse JSON response từ token exchange
     * @return Access token string
     * @throws RuntimeException nếu không tìm thấy access_token trong response
     */
    private static String extractAccessToken(String jsonResponse) {
        // Thử format 1: "access_token":"..."
        String tokenKey = "\"access_token\":\"";
        int startIndex = jsonResponse.indexOf(tokenKey);
        if (startIndex != -1) {
            startIndex += tokenKey.length();
            int endIndex = jsonResponse.indexOf("\"", startIndex);
            if (endIndex != -1) {
                return jsonResponse.substring(startIndex, endIndex);
            }
        }
        
        // Thử format 2: "access_token": "..." (có khoảng trắng)
        tokenKey = "\"access_token\":";
        startIndex = jsonResponse.indexOf(tokenKey);
        if (startIndex != -1) {
            startIndex += tokenKey.length();
            // Bỏ qua khoảng trắng
            while (startIndex < jsonResponse.length() && Character.isWhitespace(jsonResponse.charAt(startIndex))) {
                startIndex++;
            }
            // Kiểm tra có dấu ngoặc kép không
            if (startIndex < jsonResponse.length() && jsonResponse.charAt(startIndex) == '"') {
                startIndex++; // Bỏ qua dấu ngoặc kép mở
                int endIndex = jsonResponse.indexOf("\"", startIndex);
                if (endIndex != -1) {
                    return jsonResponse.substring(startIndex, endIndex);
                }
            }
        }
        
        throw new RuntimeException("Access token not found in response: " + jsonResponse);
    }
    
    /**
     * Parse email từ JSON response của User Info API
     * JSON có format: {"id": "...", "email": "...", "name": "...", ...}
     * 
     * @param jsonResponse JSON response từ getUserInfo()
     * @return Email của người dùng hoặc null nếu không tìm thấy
     */
    public static String extractUserEmail(String jsonResponse) {
        // Thử các format JSON khác nhau
        String[] emailKeys = {"\"email\":\"", "\"email\":", "\"email\":"};
        
        for (String emailKey : emailKeys) {
            int startIndex = jsonResponse.indexOf(emailKey);
            if (startIndex != -1) {
                startIndex += emailKey.length();
                
                // Bỏ qua khoảng trắng
                while (startIndex < jsonResponse.length() && Character.isWhitespace(jsonResponse.charAt(startIndex))) {
                    startIndex++;
                }
                
                // Xử lý giá trị có dấu ngoặc kép
                if (startIndex < jsonResponse.length() && jsonResponse.charAt(startIndex) == '"') {
                    startIndex++; // Bỏ qua dấu ngoặc kép mở
                    int endIndex = jsonResponse.indexOf("\"", startIndex);
                    if (endIndex != -1) {
                        String email = jsonResponse.substring(startIndex, endIndex);
                        return email;
                    }
                }
            }
        }
        
        return null;
    }
    
    /**
     * Parse tên người dùng từ JSON response của User Info API
     * JSON có format: {"id": "...", "email": "...", "name": "...", ...}
     * 
     * @param jsonResponse JSON response từ getUserInfo()
     * @return Tên người dùng hoặc null nếu không tìm thấy
     */
    public static String extractUserName(String jsonResponse) {
        // Thử các format JSON khác nhau
        String[] nameKeys = {"\"name\":\"", "\"name\":", "\"name\":"};
        
        for (String nameKey : nameKeys) {
            int startIndex = jsonResponse.indexOf(nameKey);
            if (startIndex != -1) {
                startIndex += nameKey.length();
                
                // Bỏ qua khoảng trắng
                while (startIndex < jsonResponse.length() && Character.isWhitespace(jsonResponse.charAt(startIndex))) {
                    startIndex++;
                }
                
                // Xử lý giá trị có dấu ngoặc kép
                if (startIndex < jsonResponse.length() && jsonResponse.charAt(startIndex) == '"') {
                    startIndex++; // Bỏ qua dấu ngoặc kép mở
                    int endIndex = jsonResponse.indexOf("\"", startIndex);
                    if (endIndex != -1) {
                        String name = jsonResponse.substring(startIndex, endIndex);
                        return name;
                    }
                }
            }
        }
        
        return null;
    }
    
    /**
     * Parse Google User ID từ JSON response của User Info API
     * Google User ID là ID duy nhất của người dùng trên Google
     * 
     * @param jsonResponse JSON response từ getUserInfo()
     * @return Google User ID hoặc null nếu không tìm thấy
     */
    public static String extractUserId(String jsonResponse) {
        String idKey = "\"id\":\"";
        int startIndex = jsonResponse.indexOf(idKey);
        if (startIndex != -1) {
            startIndex += idKey.length();
            int endIndex = jsonResponse.indexOf("\"", startIndex);
            if (endIndex != -1) {
                return jsonResponse.substring(startIndex, endIndex);
            }
        }
        return null;
    }
}
