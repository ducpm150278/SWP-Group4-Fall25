<%-- 
    Document   : verifyEmail
    Created on : Oct 11, 2025, 9:54:42 PM
    Author     : leanh
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Xác minh Email</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
        
        <style>
            body {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                min-height: 100vh;
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            }
            .navbar {
                background: rgba(255, 255, 255, 0.95) !important;
                backdrop-filter: blur(10px);
                box-shadow: 0 2px 20px rgba(0,0,0,0.1);
            }
            .navbar-brand {
                font-weight: 700;
                color: #667eea !important;
            }
            .verify-card {
                max-width: 550px;
                margin: 40px auto;
                border-radius: 15px;
            }
        </style>
    </head>
    <body>
        
        <nav class="navbar navbar-expand-lg navbar-light">
            <div class="container">
                <a class="navbar-brand" href="index.jsp">
                    <i class="fas fa-film"></i> Cinema Management
                </a>
            </div>
        </nav>

        <div class="container mt-5">
            <div class="card shadow-sm p-4 verify-card">
                <h4 class="text-center mb-3">Xác minh và Liên kết Email</h4>

                <div class="alert alert-info">
                    <strong>Email hiện tại:</strong> ${sessionScope.user.email}
                    <br>
                    <strong>Trạng thái:</strong> 
                    <c:if test="${sessionScope.user.isEmailVerified}">
                        <span class="badge bg-success">Đã xác minh</span>
                    </c:if>
                    <c:if test="${!sessionScope.user.isEmailVerified}">
                        <span class="badge bg-warning text-dark">Chưa xác minh</span>
                    </c:if>
                </div>

                <c:if test="${not empty message}">
                    <div class="alert alert-success">${message}</div>
                </c:if>
                <c:if test="${not empty error}">
                    <div class="alert alert-danger">${error}</div>
                </c:if>

                <hr>

                <c:if test="${empty emailSent}">
                    <p>Nhập email mới bạn muốn liên kết. Chúng tôi sẽ gửi một mã xác minh đến email này.</p>
                    <form action="${pageContext.request.contextPath}/VerifyEmail?action=sendcode" method="post">
                        <div class="mb-3">
                            <label class="form-label">Nhập email liên kết mới</label>
                            <input type="email" name="newEmail" class="form-control" required>
                        </div>
                        <div class="text-center">
                            <button type="submit" class="btn btn-primary px-4">
                                <i class="fas fa-paper-plane"></i> Gửi mã xác minh
                            </button>
                        </div>
                    </form>
                </c:if>

                <c:if test="${not empty emailSent}">
                    <div class="alert alert-warning">
                        Một mã xác minh đã được gửi đến <strong>${emailSent}</strong>.
                        Vui lòng kiểm tra email và nhập mã vào bên dưới.
                    </div>
                    <form action="${pageContext.request.contextPath}/VerifyEmail?action=verify" method="post">
                        <div class="mb-3">
                            <label class="form-label">Nhập mã xác minh</g:label>
                            <input type="text" name="verificationCode" class="form-control" required>
                        </div>
                        <div class="text-center">
                            <button type="submit" class="btn btn-success px-4">
                                <i class="fas fa-check-circle"></i> Xác nhận
                            </button>
                        </div>
                    </form>
                </c:if>

                <div class="text-center mt-4">
                    <a href="${pageContext.request.contextPath}/CustomerProfile" class="btn btn-secondary px-4">
                        Trở về profile
                    </a>
                </div>
            </div>
        </div>
        
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>