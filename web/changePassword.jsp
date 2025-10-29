<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đổi Mật Khẩu - Cinema Booking</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/cinema-dark-theme.css" rel="stylesheet">
    <style>
        body {
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            padding: 20px;
        }
    </style>
</head>
<body>
    <div class="container-small">
        <div class="card-cinema">
            <div class="card-header-cinema">
                <h1><i class="fas fa-key"></i> Đổi Mật Khẩu</h1>
                <p>Thay đổi mật khẩu tài khoản của bạn</p>
            </div>

            <div style="padding: 30px;">
                <c:if test="${not empty message}">
                    <div class="alert-cinema alert-success-cinema">
                        <i class="fas fa-check-circle"></i> ${message}
                    </div>
                </c:if>
                <c:if test="${not empty error}">
                    <div class="alert-cinema alert-danger-cinema">
                        <i class="fas fa-exclamation-circle"></i> ${error}
                    </div>
                </c:if>

                <form action="${pageContext.request.contextPath}/ChangePassword" method="post">
                    <div class="form-group-cinema">
                        <label class="form-label-cinema">
                            <i class="fas fa-lock"></i> Mật khẩu cũ
                        </label>
                        <input type="password" name="oldPassword" class="form-control-cinema" 
                               placeholder="Nhập mật khẩu hiện tại" required>
                    </div>

                    <div class="form-group-cinema">
                        <label class="form-label-cinema">
                            <i class="fas fa-lock"></i> Mật khẩu mới
                        </label>
                        <input type="password" name="newPassword" class="form-control-cinema" 
                               placeholder="Nhập mật khẩu mới" required>
                    </div>

                    <div class="form-group-cinema">
                        <label class="form-label-cinema">
                            <i class="fas fa-lock"></i> Xác nhận mật khẩu mới
                        </label>
                        <input type="password" name="confirmPassword" class="form-control-cinema" 
                               placeholder="Nhập lại mật khẩu mới" required>
                    </div>

                    <div class="d-flex gap-2 justify-content-center" style="margin-top: 30px;">
                        <a href="${pageContext.request.contextPath}/CustomerProfile" 
                           class="btn-secondary-cinema btn-cinema">
                            <i class="fas fa-arrow-left"></i> Quay lại
                        </a>
                        <button type="submit" class="btn-primary-cinema btn-cinema">
                            <i class="fas fa-save"></i> Đổi mật khẩu
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
