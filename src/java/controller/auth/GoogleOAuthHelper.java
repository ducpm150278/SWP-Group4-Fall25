/*
 * Lớp helper cung cấp các phương thức tiện ích cho Google OAuth flow
 * 
 * Các chức năng chính:
 * 1. Đổi authorization code lấy access token (exchangeCodeForToken)
 * 2. Lấy thông tin user từ Google API (getUserInfo)
 * 3. Parse JSON response để trích xuất các thông tin cần thiết (extract methods)
 * 
 * Lưu ý: Các method parse JSON sử dụng cách parse thủ công (string manipulation).
 * Trong môi trường production, nên sử dụng thư viện JSON như Jackson hoặc Gson để an toàn và hiệu quả hơn.
 */
package controller.auth;

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
     * Đổi authorization code lấy access token từ Google
     * 
     * Flow xử lý:
     * Bước 1: Chuẩn bị POST data với các tham số: client_id, client_secret, code, grant_type, redirect_uri
     * Bước 2: Encode các tham số thành URL-encoded format
     * Bước 3: Tạo HTTP POST request đến Google token endpoint
     * Bước 4: Gửi POST data
     * Bước 5: Đọc response (JSON chứa access_token)
     * Bước 6: Parse JSON để trích xuất access_token
     * 
     * @param code Authorization code nhận được từ Google callback
     * @return Access token để sử dụng cho các API calls tiếp theo
     * @throws IOException nếu request thất bại hoặc không thể đọc response
     */
    public static String exchangeCodeForToken(String code) throws IOException {
        // Bước 1: Lấy token endpoint URL từ config
        String tokenUrl = GoogleOAuthConfig.getTokenUrl();
        
        // Bước 2: Chuẩn bị POST data với các tham số bắt buộc
        Map<String, String> params = new HashMap<>();
        params.put("client_id", GoogleOAuthConfig.CLIENT_ID);           // Client ID của ứng dụng
        params.put("client_secret", GoogleOAuthConfig.CLIENT_SECRET);   // Client Secret để xác thực
        params.put("code", code);                                       // Authorization code từ Google
        params.put("grant_type", "authorization_code");                 // Loại grant (Authorization Code flow)
        params.put("redirect_uri", GoogleOAuthConfig.REDIRECT_URI);     // Redirect URI (phải khớp với lúc request)
        
        // Bước 3: Xây dựng POST data string dạng URL-encoded
        // Format: key1=value1&key2=value2&key3=value3
        StringBuilder postData = new StringBuilder();
        for (Map.Entry<String, String> entry : params.entrySet()) {
            // Thêm dấu & giữa các cặp key-value (trừ cặp đầu tiên)
            if (postData.length() != 0) {
                postData.append("&");
            }
            // Encode key và value để đảm bảo an toàn với các ký tự đặc biệt
            postData.append(URLEncoder.encode(entry.getKey(), StandardCharsets.UTF_8));
            postData.append("=");
            postData.append(URLEncoder.encode(entry.getValue(), StandardCharsets.UTF_8));
        }
        
        // Bước 4: Tạo HTTP POST connection đến Google token endpoint
        URL url = new URL(tokenUrl);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");                                    // Phương thức POST
        conn.setDoOutput(true);                                           // Cho phép gửi data
        conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded"); // Content type
        
        // Bước 5: Gửi POST data đến Google
        try (OutputStreamWriter writer = new OutputStreamWriter(conn.getOutputStream())) {
            writer.write(postData.toString());
        }
        
        // Bước 6: Đọc response từ Google
        int responseCode = conn.getResponseCode();
        if (responseCode == HttpURLConnection.HTTP_OK) {
            // Response thành công (200 OK)
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream()))) {
                StringBuilder response = new StringBuilder();
                String line;
                // Đọc toàn bộ response
                while ((line = reader.readLine()) != null) {
                    response.append(line);
                }
                
                // Bước 7: Parse JSON response để trích xuất access_token
                // Response format: {"access_token":"...", "token_type":"Bearer", "expires_in":3600, ...}
                String jsonResponse = response.toString();
                return extractAccessToken(jsonResponse);
            }
        } else {
            // Response lỗi - đọc error stream để debug
            StringBuilder errorResponse = new StringBuilder();
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getErrorStream()))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    errorResponse.append(line);
                }
            } catch (Exception e) {
                // Bỏ qua nếu không đọc được error stream
            }
            // Throw exception với thông tin lỗi chi tiết
            throw new IOException("Token exchange failed with response code: " + responseCode + 
                                ". Error response: " + errorResponse.toString());
        }
    }
    
    /**
     * Lấy thông tin user từ Google API sử dụng access token
     * 
     * Flow xử lý:
     * Bước 1: Xây dựng URL user info endpoint với access token trong query parameter
     * Bước 2: Tạo HTTP GET request đến Google userinfo API
     * Bước 3: Thêm Authorization header với Bearer token
     * Bước 4: Gửi request và đọc response
     * Bước 5: Trả về JSON string chứa thông tin user (email, name, id, picture, etc.)
     * 
     * @param accessToken Access token đã nhận được từ exchangeCodeForToken
     * @return JSON string chứa thông tin user từ Google
     * @throws IOException nếu request thất bại hoặc không thể đọc response
     */
    public static String getUserInfo(String accessToken) throws IOException {
        // Bước 1: Xây dựng URL với access token trong query parameter
        // Có thể dùng query param hoặc Authorization header (ở đây dùng cả hai để đảm bảo)
        String userInfoUrl = GoogleOAuthConfig.getUserInfoUrl() + "?access_token=" + accessToken;
        
        System.out.println("Requesting user info from: " + userInfoUrl);
        
        // Bước 2: Tạo HTTP GET connection
        URL url = new URL(userInfoUrl);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        // Bước 3: Thêm Authorization header với Bearer token (cách chuẩn hơn)
        conn.setRequestProperty("Authorization", "Bearer " + accessToken);
        
        // Bước 4: Gửi request và kiểm tra response code
        int responseCode = conn.getResponseCode();
        System.out.println("User info response code: " + responseCode);
        
        if (responseCode == HttpURLConnection.HTTP_OK) {
            // Response thành công - đọc JSON response
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream()))) {
                StringBuilder response = new StringBuilder();
                String line;
                // Đọc toàn bộ response
                while ((line = reader.readLine()) != null) {
                    response.append(line);
                }
                String userInfoJson = response.toString();
                System.out.println("User info response: " + userInfoJson);
                // Bước 5: Trả về JSON string
                return userInfoJson;
            }
        } else {
            // Response lỗi - đọc error stream để debug
            StringBuilder errorResponse = new StringBuilder();
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getErrorStream()))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    errorResponse.append(line);
                }
            } catch (Exception e) {
                // Bỏ qua nếu không đọc được error stream
            }
            // Throw exception với thông tin lỗi chi tiết
            throw new IOException("User info request failed with response code: " + responseCode + 
                                ". Error response: " + errorResponse.toString());
        }
    }
    
    /**
     * Trích xuất access token từ JSON response của token exchange
     * 
     * Logic parse JSON thủ công:
     * 1. Tìm chuỗi "access_token":" trong JSON
     * 2. Lấy vị trí bắt đầu của token (sau dấu nháy kép)
     * 3. Tìm vị trí kết thúc (dấu nháy kép tiếp theo)
     * 4. Trích xuất substring giữa hai vị trí đó
     * 
     * Hỗ trợ 2 format JSON:
     * - Format 1: "access_token":"token_value"
     * - Format 2: "access_token": "token_value" (có khoảng trắng)
     * 
     * Lưu ý: Đây là cách parse thủ công, không an toàn với JSON phức tạp.
     * Trong production nên dùng thư viện JSON như Jackson hoặc Gson.
     * 
     * @param jsonResponse JSON response từ Google token endpoint
     * @return Access token được trích xuất
     * @throws RuntimeException nếu không tìm thấy access_token trong response
     */
    private static String extractAccessToken(String jsonResponse) {
        // Debug: In response để troubleshoot
        System.out.println("Token exchange response: " + jsonResponse);
        
        // Parse JSON thủ công - tìm access_token
        // Format mong đợi: {"access_token":"ya29.a0AfH6SMB...", "token_type":"Bearer", ...}
        
        // Thử format 1: "access_token":"value" (không có khoảng trắng)
        String tokenKey = "\"access_token\":\"";
        int startIndex = jsonResponse.indexOf(tokenKey);
        if (startIndex != -1) {
            // Tìm thấy key, lấy vị trí bắt đầu của value (sau dấu nháy kép)
            startIndex += tokenKey.length();
            // Tìm vị trí kết thúc (dấu nháy kép tiếp theo)
            int endIndex = jsonResponse.indexOf("\"", startIndex);
            if (endIndex != -1) {
                // Trích xuất token
                return jsonResponse.substring(startIndex, endIndex);
            }
        }
        
        // Thử format 2: "access_token": "value" (có khoảng trắng sau dấu :)
        tokenKey = "\"access_token\":";
        startIndex = jsonResponse.indexOf(tokenKey);
        if (startIndex != -1) {
            startIndex += tokenKey.length();
            // Bỏ qua khoảng trắng (nếu có)
            while (startIndex < jsonResponse.length() && Character.isWhitespace(jsonResponse.charAt(startIndex))) {
                startIndex++;
            }
            // Kiểm tra xem value có bắt đầu bằng dấu nháy kép không
            if (startIndex < jsonResponse.length() && jsonResponse.charAt(startIndex) == '"') {
                startIndex++; // Bỏ qua dấu nháy kép mở
                // Tìm dấu nháy kép đóng
                int endIndex = jsonResponse.indexOf("\"", startIndex);
                if (endIndex != -1) {
                    // Trích xuất token
                    return jsonResponse.substring(startIndex, endIndex);
                }
            }
        }
        
        // Không tìm thấy access_token trong response
        throw new RuntimeException("Access token not found in response: " + jsonResponse);
    }
    
    /**
     * Trích xuất email của user từ JSON response của userinfo API
     * 
     * Logic parse:
     * 1. Thử các format JSON khác nhau: "email":"value", "email": "value", "email":value
     * 2. Tìm key "email" trong JSON
     * 3. Bỏ qua khoảng trắng (nếu có)
     * 4. Trích xuất value (có thể có hoặc không có dấu nháy kép)
     * 
     * @param jsonResponse JSON response từ Google userinfo API
     * @return Email của user, hoặc null nếu không tìm thấy
     */
    public static String extractUserEmail(String jsonResponse) {
        System.out.println("Extracting email from: " + jsonResponse);
        
        // Thử các format JSON khác nhau
        // Format 1: "email":"value"
        // Format 2: "email": "value" (có khoảng trắng)
        // Format 3: "email":value (không có dấu nháy kép)
        String[] emailKeys = {"\"email\":\"", "\"email\":", "\"email\":"};
        
        for (String emailKey : emailKeys) {
            int startIndex = jsonResponse.indexOf(emailKey);
            if (startIndex != -1) {
                // Tìm thấy key, tính vị trí bắt đầu của value
                startIndex += emailKey.length();
                
                // Bỏ qua khoảng trắng (nếu có)
                while (startIndex < jsonResponse.length() && Character.isWhitespace(jsonResponse.charAt(startIndex))) {
                    startIndex++;
                }
                
                // Xử lý value có dấu nháy kép
                if (startIndex < jsonResponse.length() && jsonResponse.charAt(startIndex) == '"') {
                    startIndex++; // Bỏ qua dấu nháy kép mở
                    // Tìm dấu nháy kép đóng
                    int endIndex = jsonResponse.indexOf("\"", startIndex);
                    if (endIndex != -1) {
                        String email = jsonResponse.substring(startIndex, endIndex);
                        System.out.println("Found email: " + email);
                        return email;
                    }
                }
            }
        }
        
        // Không tìm thấy email
        System.out.println("Email not found in response");
        return null;
    }
    
    /**
     * Trích xuất tên của user từ JSON response của userinfo API
     * 
     * Logic tương tự extractUserEmail, tìm key "name" trong JSON
     * 
     * @param jsonResponse JSON response từ Google userinfo API
     * @return Tên của user, hoặc null nếu không tìm thấy
     */
    public static String extractUserName(String jsonResponse) {
        System.out.println("Extracting name from: " + jsonResponse);
        
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
                
                // Xử lý value có dấu nháy kép
                if (startIndex < jsonResponse.length() && jsonResponse.charAt(startIndex) == '"') {
                    startIndex++; // Bỏ qua dấu nháy kép mở
                    int endIndex = jsonResponse.indexOf("\"", startIndex);
                    if (endIndex != -1) {
                        String name = jsonResponse.substring(startIndex, endIndex);
                        System.out.println("Found name: " + name);
                        return name;
                    }
                }
            }
        }
        
        // Không tìm thấy name
        System.out.println("Name not found in response");
        return null;
    }
    
    /**
     * Trích xuất Google User ID từ JSON response của userinfo API
     * 
     * Google User ID là ID duy nhất của user trong hệ thống Google
     * 
     * @param jsonResponse JSON response từ Google userinfo API
     * @return Google User ID, hoặc null nếu không tìm thấy
     */
    public static String extractUserId(String jsonResponse) {
        // Tìm key "id" trong JSON
        String idKey = "\"id\":\"";
        int startIndex = jsonResponse.indexOf(idKey);
        if (startIndex != -1) {
            startIndex += idKey.length();
            // Tìm dấu nháy kép đóng
            int endIndex = jsonResponse.indexOf("\"", startIndex);
            if (endIndex != -1) {
                return jsonResponse.substring(startIndex, endIndex);
            }
        }
        return null;
    }
}

