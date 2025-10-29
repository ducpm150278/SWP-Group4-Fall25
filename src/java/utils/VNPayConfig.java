package utils;

import jakarta.servlet.http.HttpServletRequest;

/**
 * VNPay configuration for sandbox environment
 */
public class VNPayConfig {
    
    // VNPay Sandbox Credentials
    public static final String VNP_TMN_CODE = "2CID2N6X"; // VNPay Terminal ID
    public static final String VNP_HASH_SECRET = "DGK9R5KTIS4DVFOXOZ49YQB3CODCD8SO"; // VNPay Hash Secret
    public static final String VNP_URL = "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html";
    
    // VNPay API Version
    public static final String VNP_VERSION = "2.1.0";
    public static final String VNP_COMMAND = "pay";
    public static final String VNP_CURR_CODE = "VND";
    public static final String VNP_LOCALE = "vn"; // vn or en
    
    // Order type
    public static final String VNP_ORDER_TYPE = "billpayment";
    
    // Timeout for payment (minutes)
    public static final int PAYMENT_TIMEOUT_MINUTES = 15;
    
    // Response codes
    public static final String RESPONSE_CODE_SUCCESS = "00";
    public static final String RESPONSE_CODE_PENDING = "01";
    public static final String RESPONSE_CODE_ERROR = "99";
    
    /**
     * Builds the VNPay return URL dynamically based on the current request
     * This allows the application to work with localhost, ngrok, or any domain
     * @param request HttpServletRequest to extract the base URL from
     * @return Dynamic return URL
     */
    public static String getReturnUrl(HttpServletRequest request) {
        String scheme = request.getScheme(); // http or https
        String serverName = request.getServerName(); // hostname
        int serverPort = request.getServerPort(); // port
        String contextPath = request.getContextPath(); // /SWP-Group4-Fall25
        
        StringBuilder returnUrl = new StringBuilder();
        returnUrl.append(scheme).append("://").append(serverName);
        
        // Only add port if it's not the default port for the scheme
        if ((scheme.equals("http") && serverPort != 80) || 
            (scheme.equals("https") && serverPort != 443)) {
            returnUrl.append(":").append(serverPort);
        }
        
        returnUrl.append(contextPath).append("/vnpay-callback");
        
        return returnUrl.toString();
    }
    
    /**
     * Get VNPay IPN URL (for payment confirmation callback) dynamically
     * @param request HttpServletRequest to extract the base URL from
     * @return Dynamic IPN URL
     */
    public static String getIpnUrl(HttpServletRequest request) {
        String scheme = request.getScheme();
        String serverName = request.getServerName();
        int serverPort = request.getServerPort();
        String contextPath = request.getContextPath();
        
        StringBuilder ipnUrl = new StringBuilder();
        ipnUrl.append(scheme).append("://").append(serverName);
        
        // Only add port if it's not the default port for the scheme
        if ((scheme.equals("http") && serverPort != 80) || 
            (scheme.equals("https") && serverPort != 443)) {
            ipnUrl.append(":").append(serverPort);
        }
        
        ipnUrl.append(contextPath).append("/vnpay-ipn");
        
        return ipnUrl.toString();
    }
}

