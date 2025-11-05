<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Xác Minh Email - Cinema</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        body { background: #0f1014; min-height: 100vh; font-family: 'Inter', sans-serif; color: #fff; padding: 20px; }
        .verify-container { background: #1a1d24; border-radius: 16px; border: 1px solid #2a2d35; max-width: 600px; margin: 60px auto; box-shadow: 0 20px 60px rgba(0,0,0,0.5); }
        .verify-header { background: linear-gradient(135deg, #e50914 0%, #b20710 100%); padding: 35px 30px; text-align: center; border-radius: 16px 16px 0 0; }
        .verify-header h1 { margin: 0; font-size: 26px; font-weight: 700; display: flex; align-items: center; justify-content: center; gap: 10px; }
        .verify-header p { margin: 10px 0 0 0; opacity: 0.95; font-size: 14px; }
        .verify-content { padding: 30px; }
        .status-box { background: #2a2d35; border-radius: 8px; padding: 20px; margin-bottom: 25px; border-left: 4px solid #e50914; }
        .status-box .status-item { display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px; font-size: 15px; }
        .status-box .status-item:last-child { margin-bottom: 0; }
        .status-box strong { color: #fff; }
        .status-box .email { color: #8b92a7; }
        .badge { padding: 6px 12px; border-radius: 6px; font-size: 12px; font-weight: 600; }
        .badge-success { background: rgba(46, 160, 67, 0.2); color: #3fb950; }
        .badge-warning { background: rgba(255, 149, 0, 0.2); color: #ff9500; }
        .form-group { margin-bottom: 20px; }
        .form-label { font-weight: 600; color: #fff; margin-bottom: 8px; font-size: 14px; display: block; }
        .form-control { background: #2a2d35; border: 1px solid #3a3d45; color: #fff; border-radius: 8px; padding: 12px 15px; font-size: 15px; width: 100%; }
        .form-control:focus { background: #2a2d35; border-color: #e50914; color: #fff; box-shadow: 0 0 0 0.2rem rgba(229, 9, 20, 0.25); outline: none; }
        .form-control::placeholder { color: #8b92a7; }
        .btn { padding: 12px 30px; border-radius: 8px; font-size: 15px; font-weight: 600; border: none; transition: all 0.3s ease; display: inline-flex; align-items: center; justify-content: center; gap: 8px; cursor: pointer; }
        .btn-primary { background: linear-gradient(135deg, #e50914 0%, #b20710 100%); color: #fff; }
        .btn-primary:hover { transform: translateY(-2px); box-shadow: 0 10px 30px rgba(229, 9, 20, 0.4); }
        .btn-success { background: linear-gradient(135deg, #2ea043 0%, #238636 100%); color: #fff; }
        .btn-success:hover { transform: translateY(-2px); box-shadow: 0 10px 30px rgba(46, 160, 67, 0.4); }
        .btn-secondary { background: #2a2d35; color: #fff; border: 1px solid #3a3d45; }
        .btn-secondary:hover { background: #3a3d45; transform: translateY(-2px); }
        .alert { border-radius: 8px; border: none; padding: 15px; margin-bottom: 20px; font-size: 14px; }
        .alert-info { background: rgba(88, 166, 255, 0.2); color: #58a6ff; border-left: 4px solid #58a6ff; }
        .alert-success { background: rgba(46, 160, 67, 0.2); color: #3fb950; border-left: 4px solid #2ea043; }
        .alert-danger { background: rgba(229, 9, 20, 0.2); color: #ff6b6b; border-left: 4px solid #e50914; }
        .alert-warning { background: rgba(255, 149, 0, 0.2); color: #ff9500; border-left: 4px solid #ff9500; }
        .divider { height: 1px; background: #2a2d35; margin: 25px 0; }
        .text-center { text-align: center; }
    </style>
</head>
<body>
    <div class="verify-container">
        <div class="verify-header">
            <h1><i class="fas fa-envelope-circle-check"></i> Xác Minh Email</h1>
            <p>Xác minh địa chỉ email của bạn</p>
        </div>
        
        <div class="verify-content">
            <div class="status-box">
                <div class="status-item">
                    <strong>Email hiện tại:</strong>
                    <span class="email">${sessionScope.user.email}</span>
                </div>
                <div class="status-item">
                    <strong>Trạng thái:</strong>
                    <c:if test="${sessionScope.user.emailVerified}">
                        <span class="badge badge-success"><i class="fas fa-check-circle"></i> Đã xác minh</span>
                    </c:if>
                    <c:if test="${!sessionScope.user.emailVerified}">
                        <span class="badge badge-warning"><i class="fas fa-exclamation-triangle"></i> Chưa xác minh</span>
                    </c:if>
                </div>
            </div>

            <c:if test="${not empty message}">
                <div class="alert alert-success">
                    <i class="fas fa-check-circle"></i> ${message}
                </div>
            </c:if>
            <c:if test="${not empty error}">
                <div class="alert alert-danger">
                    <i class="fas fa-exclamation-circle"></i> ${error}
                </div>
            </c:if>

            <c:if test="${!sessionScope.user.emailVerified}">
                <div class="divider"></div>

                <c:if test="${empty emailSent}">
                    <p style="margin-bottom: 20px; color: #8b92a7;">
                        Email của bạn chưa được xác minh. Nhấn nút bên dưới để gửi mã về email
                        <strong>${sessionScope.user.email}</strong>.
                    </p>
                    <form action="${pageContext.request.contextPath}/VerifyEmail?action=sendcode" method="post">
                        <div class="text-center">
                            <button type="submit" class="btn btn-primary">
                                <i class="fas fa-paper-plane"></i> Gửi mã xác minh
                            </button>
                        </div>
                    </form>
                </c:if>

                <c:if test="${not empty emailSent}">
                    <div class="alert alert-warning">
                        <i class="fas fa-info-circle"></i>
                        Một mã xác minh đã được gửi đến <strong>${emailSent}</strong>.
                        Vui lòng kiểm tra email và nhập mã vào bên dưới.
                    </div>
                    <form action="${pageContext.request.contextPath}/VerifyEmail?action=verify" method="post">
                        <div class="form-group">
                            <label class="form-label">
                                <i class="fas fa-key"></i> Nhập mã xác minh
                            </label>
                            <input type="text" name="verificationCode" class="form-control" 
                                   placeholder="Nhập mã 6 số" required>
                        </div>
                        <div class="text-center">
                            <button type="submit" class="btn btn-success">
                                <i class="fas fa-check-circle"></i> Xác nhận
                            </button>
                        </div>
                    </form>
                </c:if>
            </c:if>

            <div class="text-center" style="margin-top: 25px;">
                <a href="${pageContext.request.contextPath}/CustomerProfile" class="btn btn-secondary">
                    <i class="fas fa-arrow-left"></i> Trở về profile
                </a>
            </div>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>