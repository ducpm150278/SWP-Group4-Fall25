/*
 * Google OAuth Helper
 * Handles OAuth 2.0 token exchange and user info retrieval
 */
package utils;

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
     * Exchanges authorization code for access token
     * @param code Authorization code from Google
     * @return Access token
     * @throws IOException if request fails
     */
    public static String exchangeCodeForToken(String code) throws IOException {
        String tokenUrl = GoogleOAuthConfig.getTokenUrl();
        
        // Prepare POST data
        Map<String, String> params = new HashMap<>();
        params.put("client_id", GoogleOAuthConfig.CLIENT_ID);
        params.put("client_secret", GoogleOAuthConfig.CLIENT_SECRET);
        params.put("code", code);
        params.put("grant_type", "authorization_code");
        params.put("redirect_uri", GoogleOAuthConfig.REDIRECT_URI);
        
        // Build POST data string
        StringBuilder postData = new StringBuilder();
        for (Map.Entry<String, String> entry : params.entrySet()) {
            if (postData.length() != 0) {
                postData.append("&");
            }
            postData.append(URLEncoder.encode(entry.getKey(), StandardCharsets.UTF_8));
            postData.append("=");
            postData.append(URLEncoder.encode(entry.getValue(), StandardCharsets.UTF_8));
        }
        
        // Make HTTP POST request
        URL url = new URL(tokenUrl);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setDoOutput(true);
        conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
        
        // Send POST data
        try (OutputStreamWriter writer = new OutputStreamWriter(conn.getOutputStream())) {
            writer.write(postData.toString());
        }
        
        // Read response
        int responseCode = conn.getResponseCode();
        if (responseCode == HttpURLConnection.HTTP_OK) {
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream()))) {
                StringBuilder response = new StringBuilder();
                String line;
                while ((line = reader.readLine()) != null) {
                    response.append(line);
                }
                
                // Parse JSON response to extract access_token
                String jsonResponse = response.toString();
                return extractAccessToken(jsonResponse);
            }
        } else {
            // Read error response for debugging
            StringBuilder errorResponse = new StringBuilder();
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getErrorStream()))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    errorResponse.append(line);
                }
            } catch (Exception e) {
                // Ignore if error stream is not available
            }
            throw new IOException("Token exchange failed with response code: " + responseCode + 
                                ". Error response: " + errorResponse.toString());
        }
    }
    
    /**
     * Retrieves user information from Google
     * @param accessToken Access token
     * @return User information as JSON string
     * @throws IOException if request fails
     */
    public static String getUserInfo(String accessToken) throws IOException {
        String userInfoUrl = GoogleOAuthConfig.getUserInfoUrl() + "?access_token=" + accessToken;
        
        System.out.println("Requesting user info from: " + userInfoUrl);
        
        URL url = new URL(userInfoUrl);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        conn.setRequestProperty("Authorization", "Bearer " + accessToken);
        
        int responseCode = conn.getResponseCode();
        System.out.println("User info response code: " + responseCode);
        
        if (responseCode == HttpURLConnection.HTTP_OK) {
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream()))) {
                StringBuilder response = new StringBuilder();
                String line;
                while ((line = reader.readLine()) != null) {
                    response.append(line);
                }
                String userInfoJson = response.toString();
                System.out.println("User info response: " + userInfoJson);
                return userInfoJson;
            }
        } else {
            // Read error response for debugging
            StringBuilder errorResponse = new StringBuilder();
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getErrorStream()))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    errorResponse.append(line);
                }
            } catch (Exception e) {
                // Ignore if error stream is not available
            }
            throw new IOException("User info request failed with response code: " + responseCode + 
                                ". Error response: " + errorResponse.toString());
        }
    }
    
    /**
     * Extracts access token from JSON response
     * @param jsonResponse JSON response from token exchange
     * @return Access token
     */
    private static String extractAccessToken(String jsonResponse) {
        // Debug: Print the response for troubleshooting
        System.out.println("Token exchange response: " + jsonResponse);
        
        // Simple JSON parsing for access_token
        // In a production environment, use a proper JSON library like Jackson or Gson
        String tokenKey = "\"access_token\":\"";
        int startIndex = jsonResponse.indexOf(tokenKey);
        if (startIndex != -1) {
            startIndex += tokenKey.length();
            int endIndex = jsonResponse.indexOf("\"", startIndex);
            if (endIndex != -1) {
                return jsonResponse.substring(startIndex, endIndex);
            }
        }
        
        // Try alternative parsing for different JSON formats
        tokenKey = "\"access_token\":";
        startIndex = jsonResponse.indexOf(tokenKey);
        if (startIndex != -1) {
            startIndex += tokenKey.length();
            // Skip whitespace
            while (startIndex < jsonResponse.length() && Character.isWhitespace(jsonResponse.charAt(startIndex))) {
                startIndex++;
            }
            if (startIndex < jsonResponse.length() && jsonResponse.charAt(startIndex) == '"') {
                startIndex++; // Skip opening quote
                int endIndex = jsonResponse.indexOf("\"", startIndex);
                if (endIndex != -1) {
                    return jsonResponse.substring(startIndex, endIndex);
                }
            }
        }
        
        throw new RuntimeException("Access token not found in response: " + jsonResponse);
    }
    
    /**
     * Extracts user email from JSON response
     * @param jsonResponse JSON response from user info API
     * @return User email
     */
    public static String extractUserEmail(String jsonResponse) {
        System.out.println("Extracting email from: " + jsonResponse);
        
        // Try different JSON formats
        String[] emailKeys = {"\"email\":\"", "\"email\":", "\"email\":"};
        
        for (String emailKey : emailKeys) {
            int startIndex = jsonResponse.indexOf(emailKey);
            if (startIndex != -1) {
                startIndex += emailKey.length();
                
                // Skip whitespace
                while (startIndex < jsonResponse.length() && Character.isWhitespace(jsonResponse.charAt(startIndex))) {
                    startIndex++;
                }
                
                // Handle quoted values
                if (startIndex < jsonResponse.length() && jsonResponse.charAt(startIndex) == '"') {
                    startIndex++; // Skip opening quote
                    int endIndex = jsonResponse.indexOf("\"", startIndex);
                    if (endIndex != -1) {
                        String email = jsonResponse.substring(startIndex, endIndex);
                        System.out.println("Found email: " + email);
                        return email;
                    }
                }
            }
        }
        
        System.out.println("Email not found in response");
        return null;
    }
    
    /**
     * Extracts user name from JSON response
     * @param jsonResponse JSON response from user info API
     * @return User name
     */
    public static String extractUserName(String jsonResponse) {
        System.out.println("Extracting name from: " + jsonResponse);
        
        // Try different JSON formats
        String[] nameKeys = {"\"name\":\"", "\"name\":", "\"name\":"};
        
        for (String nameKey : nameKeys) {
            int startIndex = jsonResponse.indexOf(nameKey);
            if (startIndex != -1) {
                startIndex += nameKey.length();
                
                // Skip whitespace
                while (startIndex < jsonResponse.length() && Character.isWhitespace(jsonResponse.charAt(startIndex))) {
                    startIndex++;
                }
                
                // Handle quoted values
                if (startIndex < jsonResponse.length() && jsonResponse.charAt(startIndex) == '"') {
                    startIndex++; // Skip opening quote
                    int endIndex = jsonResponse.indexOf("\"", startIndex);
                    if (endIndex != -1) {
                        String name = jsonResponse.substring(startIndex, endIndex);
                        System.out.println("Found name: " + name);
                        return name;
                    }
                }
            }
        }
        
        System.out.println("Name not found in response");
        return null;
    }
    
    /**
     * Extracts user ID from JSON response
     * @param jsonResponse JSON response from user info API
     * @return User ID
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
