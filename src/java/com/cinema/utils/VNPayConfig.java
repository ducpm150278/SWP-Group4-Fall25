package com.cinema.utils;


import jakarta.servlet.http.HttpServletRequest;

/**
 * Cấu hình VNPay cho môi trường sandbox
 * Chứa thông tin credentials, URL endpoints và các cấu hình thanh toán
 * 
 * Lưu ý: Đây là cấu hình cho môi trường sandbox (test)
 * Khi deploy production, cần thay đổi:
 * - VNP_TMN_CODE: Mã merchant thật từ VNPay
 * - VNP_HASH_SECRET: Secret key thật từ VNPay
 * - VNP_URL: URL production của VNPay
 */
public class VNPayConfig {
    
    // ========== VNPay Sandbox Credentials ==========
    // Thông tin xác thực cho môi trường sandbox (test)
    public static final String VNP_TMN_CODE = "2CID2N6X"; // VNPay Terminal ID (mã merchant)
    public static final String VNP_HASH_SECRET = "DGK9R5KTIS4DVFOXOZ49YQB3CODCD8SO"; // VNPay Hash Secret (dùng để tạo signature)
    public static final String VNP_URL = "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html"; // URL thanh toán VNPay sandbox
    
    // ========== VNPay API Configuration ==========
    // Cấu hình phiên bản API và các thông tin cơ bản
    public static final String VNP_VERSION = "2.1.0";      // Phiên bản API VNPay
    public static final String VNP_COMMAND = "pay";        // Lệnh thanh toán
    public static final String VNP_CURR_CODE = "VND";      // Mã tiền tệ (Việt Nam Đồng)
    public static final String VNP_LOCALE = "vn";          // Ngôn ngữ giao diện (vn = tiếng Việt, en = tiếng Anh)
    
    // ========== Order Configuration ==========
    // Cấu hình loại đơn hàng
    public static final String VNP_ORDER_TYPE = "billpayment"; // Loại đơn hàng (thanh toán hóa đơn)
    
    // ========== Payment Timeout ==========
    // Thời gian hết hạn thanh toán (tính bằng phút)
    // Sau thời gian này, giao dịch sẽ tự động hết hạn nếu chưa thanh toán
    public static final int PAYMENT_TIMEOUT_MINUTES = 15;
    
    // ========== Response Codes ==========
    // Các mã phản hồi từ VNPay
    public static final String RESPONSE_CODE_SUCCESS = "00";  // Giao dịch thành công
    public static final String RESPONSE_CODE_PENDING = "01";  // Giao dịch đang chờ xử lý
    public static final String RESPONSE_CODE_ERROR = "99";    // Giao dịch thất bại
    
    /**
     * Xây dựng return URL động dựa trên request hiện tại
     * URL này là nơi VNPay sẽ redirect về sau khi người dùng thanh toán xong
     * 
     * Lợi ích của URL động:
     * - Hoạt động với localhost (development)
     * - Hoạt động với ngrok (testing với mobile/webhook)
     * - Hoạt động với domain thật (production)
     * - Tự động xử lý port (80 cho http, 443 cho https)
     * 
     * @param request HttpServletRequest để lấy thông tin scheme, hostname, port, context path
     * @return Return URL đầy đủ (ví dụ: http://localhost:8080/SWP-Group4-Fall25/vnpay-callback)
     */
    public static String getReturnUrl(HttpServletRequest request) {
        // Bước 1: Lấy các thông tin cơ bản từ request
        String scheme = request.getScheme();           // http hoặc https
        String serverName = request.getServerName();   // hostname (localhost, domain, v.v.)
        int serverPort = request.getServerPort();      // port number
        String contextPath = request.getContextPath(); // context path (ví dụ: /SWP-Group4-Fall25)
        
        // Bước 2: Xây dựng URL từ các thành phần
        StringBuilder returnUrl = new StringBuilder();
        returnUrl.append(scheme).append("://").append(serverName);
        
        // Bước 3: Chỉ thêm port nếu không phải port mặc định
        // Port mặc định: 80 cho http, 443 cho https
        // Nếu dùng port khác (ví dụ: 8080) thì phải thêm vào URL
        if ((scheme.equals("http") && serverPort != 80) || 
            (scheme.equals("https") && serverPort != 443)) {
            returnUrl.append(":").append(serverPort);
        }
        
        // Bước 4: Thêm context path và endpoint callback
        returnUrl.append(contextPath).append("/vnpay-callback");
        
        return returnUrl.toString();
    }
    
    /**
     * Lấy IPN URL động (Instant Payment Notification)
     * IPN URL là nơi VNPay gửi callback để xác nhận thanh toán (server-to-server)
     * Khác với return URL (redirect về browser), IPN là callback từ server VNPay
     * 
     * Lưu ý: IPN URL thường được cấu hình trong VNPay merchant portal
     * Nhưng có thể dùng method này để build URL động nếu cần
     * 
     * @param request HttpServletRequest để lấy thông tin scheme, hostname, port, context path
     * @return IPN URL đầy đủ (ví dụ: http://localhost:8080/SWP-Group4-Fall25/vnpay-ipn)
     */
    public static String getIpnUrl(HttpServletRequest request) {
        // Bước 1: Lấy các thông tin cơ bản từ request
        String scheme = request.getScheme();           // http hoặc https
        String serverName = request.getServerName();   // hostname
        int serverPort = request.getServerPort();      // port number
        String contextPath = request.getContextPath(); // context path
        
        // Bước 2: Xây dựng URL từ các thành phần
        StringBuilder ipnUrl = new StringBuilder();
        ipnUrl.append(scheme).append("://").append(serverName);
        
        // Bước 3: Chỉ thêm port nếu không phải port mặc định
        if ((scheme.equals("http") && serverPort != 80) || 
            (scheme.equals("https") && serverPort != 443)) {
            ipnUrl.append(":").append(serverPort);
        }
        
        // Bước 4: Thêm context path và endpoint IPN
        ipnUrl.append(contextPath).append("/vnpay-ipn");
        
        return ipnUrl.toString();
    }
}

