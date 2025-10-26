package utils;

/**
 * VNPay configuration for sandbox environment
 */
public class VNPayConfig {
    
    // VNPay Sandbox Credentials
    public static final String VNP_TMN_CODE = "2CID2N6X"; // VNPay Terminal ID
    public static final String VNP_HASH_SECRET = "DGK9R5KTIS4DVFOXOZ49YQB3CODCD8SO"; // VNPay Hash Secret
    public static final String VNP_URL = "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html";
    public static final String VNP_RETURN_URL = "https://unslated-snugging-kellie.ngrok-free.dev/SWP-Group4-Fall25/vnpay-callback";
    
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
     * Get VNPay IPN URL (for payment confirmation callback)
     */
    public static String getIpnUrl() {
        return "https://unslated-snugging-kellie.ngrok-free.dev/SWP-Group4-Fall25/vnpay-ipn";
    }
}

