<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thanh Toán Thất Bại - Cinema Booking</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            background: #0f1014;
            min-height: 100vh;
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            color: #fff;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        
        .failed-container {
            max-width: 650px;
            width: 100%;
            background: #1a1d24;
            border: 1px solid #2a2d35;
            border-radius: 16px;
            padding: 50px 40px;
            text-align: center;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.4);
        }
        
        .failed-icon {
            width: 100px;
            height: 100px;
            background: linear-gradient(135deg, #f85149 0%, #da3633 100%);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 30px;
            animation: shake 0.5s ease-in-out;
        }
        
        @keyframes shake {
            0%, 100% { transform: translateX(0); }
            10%, 30%, 50%, 70%, 90% { transform: translateX(-10px); }
            20%, 40%, 60%, 80% { transform: translateX(10px); }
        }
        
        .failed-icon i {
            font-size: 50px;
            color: #fff;
        }
        
        h1 {
            font-size: 32px;
            font-weight: 700;
            color: #f85149;
            margin-bottom: 15px;
        }
        
        .subtitle {
            font-size: 16px;
            color: #8b949e;
            margin-bottom: 30px;
        }
        
        .error-box {
            background: rgba(248, 81, 73, 0.1);
            border: 1px solid rgba(248, 81, 73, 0.3);
            border-radius: 12px;
            padding: 20px;
            margin-bottom: 30px;
        }
        
        .error-box p {
            margin: 0;
            color: #f85149;
            font-size: 15px;
            line-height: 1.6;
        }
        
        .error-code {
            display: inline-block;
            background: rgba(248, 81, 73, 0.2);
            padding: 4px 12px;
            border-radius: 6px;
            font-weight: 600;
            margin-top: 10px;
        }
        
        .action-buttons {
            display: flex;
            flex-direction: column;
            gap: 12px;
            margin-top: 30px;
        }
        
        .btn-custom {
            padding: 14px 24px;
            border-radius: 10px;
            font-weight: 600;
            text-decoration: none;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            transition: all 0.3s ease;
            border: none;
            cursor: pointer;
        }
        
        .btn-primary-custom {
            background: linear-gradient(135deg, #58a6ff 0%, #1f6feb 100%);
            color: #fff;
        }
        
        .btn-primary-custom:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(88, 166, 255, 0.3);
            color: #fff;
        }
        
        .btn-secondary-custom {
            background: transparent;
            border: 1px solid #2a2d35;
            color: #c9d1d9;
        }
        
        .btn-secondary-custom:hover {
            background: rgba(42, 45, 53, 0.5);
            border-color: #8b949e;
            color: #fff;
        }
        
        .help-section {
            margin-top: 30px;
            padding: 20px;
            background: rgba(42, 45, 53, 0.3);
            border: 1px solid #2a2d35;
            border-radius: 10px;
            text-align: left;
        }
        
        .help-section h3 {
            font-size: 16px;
            color: #58a6ff;
            margin-bottom: 15px;
        }
        
        .help-section ul {
            list-style: none;
            padding: 0;
            margin: 0;
        }
        
        .help-section li {
            padding: 8px 0;
            color: #8b949e;
            font-size: 14px;
        }
        
        .help-section li i {
            color: #58a6ff;
            margin-right: 8px;
            width: 20px;
        }
        
        @media (max-width: 576px) {
            .failed-container {
                padding: 40px 20px;
            }
            
            h1 {
                font-size: 24px;
            }
        }
    </style>
</head>
<body>
    <%
        String error = (String) request.getAttribute("error");
        String responseCode = (String) request.getAttribute("responseCode");
    %>
    
    <div class="failed-container">
        <div class="failed-icon">
            <i class="fas fa-times"></i>
        </div>
        
        <h1>Thanh Toán Thất Bại!</h1>
        <p class="subtitle">Đã có lỗi xảy ra trong quá trình thanh toán</p>
        
        <% if (error != null) { %>
        <div class="error-box">
            <p><i class="fas fa-exclamation-triangle"></i> <%= error %></p>
            <% if (responseCode != null) { %>
            <span class="error-code">Mã lỗi: <%= responseCode %></span>
            <% } %>
        </div>
        <% } %>
        
        <div class="action-buttons">
            <a href="${pageContext.request.contextPath}/booking/payment" class="btn-custom btn-primary-custom">
                <i class="fas fa-redo"></i> Thử Lại
            </a>
            <a href="${pageContext.request.contextPath}/booking/select-screening" class="btn-custom btn-secondary-custom">
                <i class="fas fa-arrow-left"></i> Đặt Vé Mới
            </a>
            <a href="${pageContext.request.contextPath}/index.jsp" class="btn-custom btn-secondary-custom">
                <i class="fas fa-home"></i> Về Trang Chủ
            </a>
        </div>
        
        <div class="help-section">
            <h3><i class="fas fa-question-circle"></i> Nguyên nhân có thể gây lỗi:</h3>
            <ul>
                <li><i class="fas fa-check-circle"></i> Hủy giao dịch trong quá trình thanh toán</li>
                <li><i class="fas fa-check-circle"></i> Tài khoản không đủ số dư</li>
                <li><i class="fas fa-check-circle"></i> Thông tin xác thực không chính xác</li>
                <li><i class="fas fa-check-circle"></i> Thẻ/tài khoản chưa đăng ký Internet Banking</li>
                <li><i class="fas fa-check-circle"></i> Hết thời gian chờ thanh toán</li>
            </ul>
        </div>
    </div>
</body>
</html>
