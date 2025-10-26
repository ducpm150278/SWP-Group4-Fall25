<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thanh Toán Thành Công</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        body { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; display: flex; align-items: center; }
        .success-container { max-width: 600px; margin: auto; padding: 40px; background: white; border-radius: 15px; text-align: center; }
        .success-icon { font-size: 80px; color: #4CAF50; margin-bottom: 20px; }
    </style>
</head>
<body>
    <div class="success-container">
        <div class="success-icon">
            <i class="fas fa-check-circle"></i>
        </div>
        
        <h2 class="text-success mb-4">Thanh Toán Thành Công!</h2>
        
        <p class="lead">Cảm ơn bạn đã đặt vé. Vui lòng kiểm tra email để nhận thông tin vé.</p>
        
        <div class="alert alert-info my-4">
            <strong>Mã đơn hàng:</strong> <%= request.getAttribute("orderID") %><br>
            <strong>Mã giao dịch:</strong> <%= request.getAttribute("transactionNo") %>
        </div>
        
        <div class="d-grid gap-2">
            <a href="${pageContext.request.contextPath}/profile" class="btn btn-primary btn-lg">
                <i class="fas fa-ticket-alt"></i> Xem Vé Của Tôi
            </a>
            <a href="${pageContext.request.contextPath}/index.jsp" class="btn btn-outline-secondary">
                <i class="fas fa-home"></i> Về Trang Chủ
            </a>
        </div>
    </div>
</body>
</html>

