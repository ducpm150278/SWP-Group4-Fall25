package com.cinema.utils;


import jakarta.servlet.http.HttpServletRequest;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.text.SimpleDateFormat;
import java.util.*;

/**
 * Lớp tiện ích cho tích hợp thanh toán VNPay
 * Xử lý tạo URL thanh toán, xác thực chữ ký, format số tiền, v.v.
 */
public class VNPayUtils {
    
    /**
     * Xây dựng URL thanh toán VNPay với signature
     * Flow: Sắp xếp parameters -> Build query string -> Tạo signature -> Append signature -> Trả về URL
     * 
     * @param params Map chứa các parameters cần gửi đến VNPay
     * @return URL thanh toán VNPay đầy đủ với signature
     * @throws UnsupportedEncodingException nếu encoding không được hỗ trợ
     */
    public static String buildPaymentUrl(Map<String, String> params) throws UnsupportedEncodingException {
        // Bước 1: Sắp xếp parameters theo thứ tự alphabet
        // VNPay yêu cầu parameters phải được sắp xếp để tạo signature đúng
        List<String> fieldNames = new ArrayList<>(params.keySet());
        Collections.sort(fieldNames);
        
        StringBuilder hashData = new StringBuilder();  // Dùng để tạo signature
        StringBuilder query = new StringBuilder();     // Dùng để build query string
        
        // Bước 2: Duyệt qua từng parameter đã sắp xếp
        Iterator<String> itr = fieldNames.iterator();
        while (itr.hasNext()) {
            String fieldName = itr.next();
            String fieldValue = params.get(fieldName);
            
            // Chỉ xử lý các parameter có giá trị
            if (fieldValue != null && fieldValue.length() > 0) {
                // Build hash data để tạo signature
                hashData.append(fieldName);
                hashData.append('=');
                hashData.append(URLEncoder.encode(fieldValue, StandardCharsets.US_ASCII.toString()));
                
                // Build query string cho URL
                query.append(URLEncoder.encode(fieldName, StandardCharsets.US_ASCII.toString()));
                query.append('=');
                query.append(URLEncoder.encode(fieldValue, StandardCharsets.US_ASCII.toString()));
                
                // Thêm dấu & nếu không phải parameter cuối cùng
                if (itr.hasNext()) {
                    query.append('&');
                    hashData.append('&');
                }
            }
        }
        
        // Bước 3: Tạo signature bằng HMAC SHA512
        String queryUrl = query.toString();
        String vnpSecureHash = hmacSHA512(VNPayConfig.VNP_HASH_SECRET, hashData.toString());
        
        // Bước 4: Append signature vào query string
        queryUrl += "&vnp_SecureHash=" + vnpSecureHash;
        
        // Bước 5: Trả về URL đầy đủ
        return VNPayConfig.VNP_URL + "?" + queryUrl;
    }
    
    /**
     * Tạo payment parameters với return URL động
     * Tạo Map chứa tất cả parameters cần thiết để gửi đến VNPay
     * 
     * @param orderId Mã đơn hàng (unique)
     * @param amount Số tiền thanh toán (đơn vị: VNĐ)
     * @param orderInfo Thông tin đơn hàng
     * @param ipAddress IP address của client
     * @param request HttpServletRequest để lấy return URL động
     * @return Map chứa các parameters VNPay
     */
    public static Map<String, String> createPaymentParams(String orderId, long amount, 
                                                          String orderInfo, String ipAddress, 
                                                          HttpServletRequest request) {
        Map<String, String> vnpParams = new HashMap<>();
        
        // Các thông tin cấu hình cơ bản
        vnpParams.put("vnp_Version", VNPayConfig.VNP_VERSION);        // Phiên bản API VNPay
        vnpParams.put("vnp_Command", VNPayConfig.VNP_COMMAND);       // Lệnh thanh toán
        vnpParams.put("vnp_TmnCode", VNPayConfig.VNP_TMN_CODE);      // Mã merchant
        vnpParams.put("vnp_Amount", String.valueOf(amount * 100));   // Số tiền (VNPay dùng đơn vị nhỏ nhất - nhân 100)
        vnpParams.put("vnp_CurrCode", VNPayConfig.VNP_CURR_CODE);    // Mã tiền tệ (VND)
        vnpParams.put("vnp_TxnRef", orderId);                         // Mã đơn hàng
        vnpParams.put("vnp_OrderInfo", orderInfo);                   // Thông tin đơn hàng
        vnpParams.put("vnp_OrderType", VNPayConfig.VNP_ORDER_TYPE); // Loại đơn hàng
        vnpParams.put("vnp_Locale", VNPayConfig.VNP_LOCALE);         // Ngôn ngữ (vn/en)
        vnpParams.put("vnp_ReturnUrl", VNPayConfig.getReturnUrl(request)); // URL callback sau khi thanh toán
        vnpParams.put("vnp_IpAddr", ipAddress);                      // IP address của client
        
        // Thời gian tạo giao dịch (timezone GMT+7 - giờ Việt Nam)
        Calendar cld = Calendar.getInstance(TimeZone.getTimeZone("Etc/GMT+7"));
        SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMddHHmmss");
        String vnpCreateDate = formatter.format(cld.getTime());
        vnpParams.put("vnp_CreateDate", vnpCreateDate);
        
        // Thời gian hết hạn giao dịch (thêm PAYMENT_TIMEOUT_MINUTES phút)
        cld.add(Calendar.MINUTE, VNPayConfig.PAYMENT_TIMEOUT_MINUTES);
        String vnpExpireDate = formatter.format(cld.getTime());
        vnpParams.put("vnp_ExpireDate", vnpExpireDate);
        
        return vnpParams;
    }
    
    /**
     * Xác thực chữ ký từ VNPay callback
     * So sánh signature từ VNPay với signature tính toán để đảm bảo request không bị giả mạo
     * 
     * @param params Map chứa các parameters từ VNPay callback
     * @param secureHash Signature từ VNPay
     * @return true nếu signature hợp lệ, false nếu không
     */
    public static boolean validateSignature(Map<String, String> params, String secureHash) {
        // Bước 1: Loại bỏ hash và hash type khỏi params
        // Không tính hash của chính nó vào signature
        params.remove("vnp_SecureHash");
        params.remove("vnp_SecureHashType");
        
        // Bước 2: Sắp xếp parameters theo thứ tự alphabet
        // Phải giống với cách tạo signature khi build URL
        List<String> fieldNames = new ArrayList<>(params.keySet());
        Collections.sort(fieldNames);
        
        // Bước 3: Build hash data từ parameters đã sắp xếp
        StringBuilder hashData = new StringBuilder();
        Iterator<String> itr = fieldNames.iterator();
        
        while (itr.hasNext()) {
            String fieldName = itr.next();
            String fieldValue = params.get(fieldName);
            
            // Chỉ xử lý các parameter có giá trị
            if (fieldValue != null && fieldValue.length() > 0) {
                hashData.append(fieldName);
                hashData.append('=');
                try {
                    // URL encode giá trị (giống như khi build URL)
                    hashData.append(URLEncoder.encode(fieldValue, StandardCharsets.US_ASCII.toString()));
                } catch (UnsupportedEncodingException e) {
                    // US_ASCII encoding should always be supported
                }
                
                // Thêm dấu & nếu không phải parameter cuối cùng
                if (itr.hasNext()) {
                    hashData.append('&');
                }
            }
        }
        
        // Bước 4: Tính signature từ hash data
        String calculatedHash = hmacSHA512(VNPayConfig.VNP_HASH_SECRET, hashData.toString());
        
        // Bước 5: So sánh signature tính toán với signature từ VNPay
        return calculatedHash.equals(secureHash);
    }
    
    /**
     * Tạo HMAC SHA512 hash
     * Sử dụng thuật toán HMAC SHA512 để tạo signature cho VNPay
     * 
     * @param key Secret key từ VNPayConfig
     * @param data Dữ liệu cần hash (query string đã sắp xếp)
     * @return Hash string (hexadecimal)
     */
    public static String hmacSHA512(String key, String data) {
        try {
            // Khởi tạo Mac với thuật toán HMAC SHA512
            Mac hmac512 = Mac.getInstance("HmacSHA512");
            SecretKeySpec secretKey = new SecretKeySpec(key.getBytes(StandardCharsets.UTF_8), "HmacSHA512");
            hmac512.init(secretKey);
            
            // Tính hash
            byte[] hashBytes = hmac512.doFinal(data.getBytes(StandardCharsets.UTF_8));
            
            // Chuyển đổi byte array sang hexadecimal string
            StringBuilder hash = new StringBuilder();
            for (byte b : hashBytes) {
                String hex = Integer.toHexString(0xff & b);
                // Đảm bảo mỗi byte được biểu diễn bằng 2 ký tự hex
                if (hex.length() == 1) {
                    hash.append('0');
                }
                hash.append(hex);
            }
            
            return hash.toString();
            
        } catch (Exception e) {
            throw new RuntimeException("Failed to generate HMAC SHA512", e);
        }
    }
    
    /**
     * Tạo transaction reference duy nhất
     * Sử dụng timestamp để đảm bảo tính duy nhất
     * 
     * @return Transaction reference string (timestamp)
     */
    public static String generateTxnRef() {
        return String.valueOf(System.currentTimeMillis());
    }
    
    /**
     * Lấy IP address của client từ request
     * Kiểm tra header X-FORWARDED-FOR trước (nếu có proxy/load balancer)
     * Nếu không có thì lấy từ request.getRemoteAddr()
     * 
     * @param request HttpServletRequest
     * @return IP address của client
     */
    public static String getIpAddress(HttpServletRequest request) {
        // Kiểm tra X-FORWARDED-FOR header (khi có proxy/load balancer)
        String ipAddress = request.getHeader("X-FORWARDED-FOR");
        if (ipAddress == null || ipAddress.isEmpty()) {
            // Không có proxy - lấy IP trực tiếp từ request
            ipAddress = request.getRemoteAddr();
        }
        return ipAddress;
    }
    
    /**
     * Format số tiền để hiển thị
     * Format với dấu phẩy phân cách hàng nghìn và thêm " VNĐ"
     * 
     * @param amount Số tiền cần format
     * @return Chuỗi đã format (ví dụ: "150,000 VNĐ")
     */
    public static String formatAmount(double amount) {
        return String.format("%,.0f", amount) + " VNĐ";
    }
    
    /**
     * Chuyển đổi VNPay response code thành thông báo tiếng Việt
     * Mỗi response code có ý nghĩa khác nhau, cần hiển thị thông báo phù hợp
     * 
     * @param responseCode Response code từ VNPay
     * @return Thông báo tương ứng với response code
     */
    public static String getResponseMessage(String responseCode) {
        switch (responseCode) {
            case "00":
                return "Giao dịch thành công";
            case "07":
                return "Trừ tiền thành công. Giao dịch bị nghi ngờ (liên quan tới lừa đảo, giao dịch bất thường).";
            case "09":
                return "Giao dịch không thành công do: Thẻ/Tài khoản của khách hàng chưa đăng ký dịch vụ InternetBanking tại ngân hàng.";
            case "10":
                return "Giao dịch không thành công do: Khách hàng xác thực thông tin thẻ/tài khoản không đúng quá 3 lần";
            case "11":
                return "Giao dịch không thành công do: Đã hết hạn chờ thanh toán. Xin quý khách vui lòng thực hiện lại giao dịch.";
            case "12":
                return "Giao dịch không thành công do: Thẻ/Tài khoản của khách hàng bị khóa.";
            case "13":
                return "Giao dịch không thành công do Quý khách nhập sai mật khẩu xác thực giao dịch (OTP). Xin quý khách vui lòng thực hiện lại giao dịch.";
            case "24":
                return "Giao dịch không thành công do: Khách hàng hủy giao dịch";
            case "51":
                return "Giao dịch không thành công do: Tài khoản của quý khách không đủ số dư để thực hiện giao dịch.";
            case "65":
                return "Giao dịch không thành công do: Tài khoản của Quý khách đã vượt quá hạn mức giao dịch trong ngày.";
            case "75":
                return "Ngân hàng thanh toán đang bảo trì.";
            case "79":
                return "Giao dịch không thành công do: KH nhập sai mật khẩu thanh toán quá số lần quy định. Xin quý khách vui lòng thực hiện lại giao dịch";
            default:
                return "Giao dịch thất bại";
        }
    }
}

