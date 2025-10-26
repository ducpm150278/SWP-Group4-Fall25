<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thanh Toán Thất Bại</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        body { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; display: flex; align-items: center; }
        .failed-container { max-width: 600px; margin: auto; padding: 40px; background: white; border-radius: 15px; text-align: center; }
        .failed-icon { font-size: 80px; color: #f44336; margin-bottom: 20px; }
    </style>
</head>
<body>
    <div class="failed-container">
        <div class="failed-icon">
            <i class="fas fa-times-circle"></i>
        </div>
        
        <h2 class="text-danger mb-4">Thanh Toán Thất Bại!</h2>
        
        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-danger">
                <%= request.getAttribute("error") %>
            </div>
        <% } %>
        
        <p class="lead mb-4">Đã có lỗi xảy ra trong quá trình thanh toán. Vui lòng thử lại.</p>
        
        <div class="d-grid gap-2">
            <a href="${pageContext.request.contextPath}/booking/payment" class="btn btn-primary btn-lg">
                <i class="fas fa-redo"></i> Thử Lại
            </a>
            <a href="${pageContext.request.contextPath}/booking/select-screening" class="btn btn-outline-secondary">
                <i class="fas fa-arrow-left"></i> Đặt Vé Mới
            </a>
            <a href="${pageContext.request.contextPath}/index.jsp" class="btn btn-outline-secondary">
                <i class="fas fa-home"></i> Về Trang Chủ
            </a>
        </div>
    </div>
</body>
</html>

