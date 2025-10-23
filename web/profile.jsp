<%-- 
    Document   : profile
    Created on : Oct 6, 2025, 9:46:41 PM
    Author     : leanh
--%>

<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Thông tin cá nhân</title>
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
            
            .logout-btn {
                background: #dc3545;
                border: none;
                border-radius: 8px;
                padding: 10px 20px;
                color: white;
                font-weight: 600;
                transition: all 0.3s ease;
            }

            .logout-btn:hover {
                background: #c82333;
                transform: translateY(-2px);
            }
            
            .profile-card {
                max-width: 700px;
                margin: 40px auto;
                border-radius: 15px;
            }
            .profile-image {
                width: 120px;
                height: 120px;
                object-fit: cover;
                border-radius: 50%;
                margin-bottom: 15px;
            }
        </style>
    </head>
    <body>

        <nav class="navbar navbar-expand-lg navbar-light">
            <div class="container">
                <a class="navbar-brand" href="index.jsp">
                    <i class="fas fa-film"></i> Cinema Management
                </a>
                <div class="navbar-nav ms-auto">
                    <span class="navbar-text me-3">
                        Welcome, ${not empty sessionScope.user.fullName ? sessionScope.user.fullName : 'Customer'}!
                    </span>
                    <a href="${pageContext.request.contextPath}/logout" class="logout-btn">
                        <i class="fas fa-sign-out-alt"></i> Logout
                    </a>
                </div>
            </div>
        </nav>

        <div class="container">
            <div class="card shadow-sm profile-card p-4">
                <div class="text-center">
                    <h4 class="mt-2">Thông tin cá nhân</h4>
                    <c:if test="${not empty message}">
                        <div class="alert alert-success mt-2">${message}</div>
                    </c:if>
                    <c:if test="${not empty error}">
                        <div class="alert alert-danger mt-2">${error}</div>
                    </c:if>
                </div>

                <form action="${pageContext.request.contextPath}/CustomerProfile" method="post" class="mt-3">
                    <input type="hidden" name="userId" value="${sessionScope.user.userID}">
                    
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label">Họ tên</label>
                            <input type="text" name="fullName" class="form-control" value="${user.fullName}">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Số điện thoại</label>
                            <input type="text" name="phone" class="form-control" value="${user.phoneNumber}">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Giới tính</label>
                            <select name="gender" class="form-select">
                                <option value="Male" ${user.gender eq 'Male' ? 'selected' : ''}>Nam</option>
                                <option value="Female" ${user.gender eq 'Female' ? 'selected' : ''}>Nữ</option>
                            </select>

                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Ngày sinh</label>
                            <input type="date" name="birthdate" class="form-control" value="${user.dateOfBirth}">
                        </div>
<div class="col-md-12">
                        <label class="form-label">Địa chỉ</label>
                        <input type="text" name="address" class="form-control" value="${user.address}">
                    </div>
                    <p>
                        <a href="${pageContext.request.contextPath}/ChangePassword">Đổi mật khẩu?</a>
                        <br>
                        <a href="${pageContext.request.contextPath}/VerifyEmail">Liên kết email</a>
                    </p>
                    <div class="text-center mt-4">
                        <button type="submit" class="btn btn-primary px-4">Lưu</button>
                        <a href="${pageContext.request.contextPath}/CustomerProfile" class="btn btn-secondary px-4">Hủy</a>
                    </div>
                </form>
            </div>
        </div>
        
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>