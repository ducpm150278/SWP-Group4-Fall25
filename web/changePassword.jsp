<%-- 
    Document   : changePassword
    Created on : Oct 11, 2025, 9:24:00 PM
    Author     : leanh
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Đổi mật khẩu</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    </head>
    <body class="bg-light">
        <div class="container mt-5">
            <div class="card shadow-sm p-4" style="max-width:500px;margin:auto;">
                <h4 class="text-center mb-3">Đổi mật khẩu</h4>

                <!-- Display success or error messages -->
                <c:if test="${not empty message}">
                    <p style="color: green;">${message}</p>
                </c:if>
                <c:if test="${not empty error}">
                    <p style="color: red;">${error}</p>
                </c:if>

                <form action="${pageContext.request.contextPath}/ChangePassword" method="post">
                    <div class="mb-3">
                        <label class="form-label">Mật khẩu cũ</label>
                        <input type="password" name="oldPassword" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Mật khẩu mới</label>
                        <input type="password" name="newPassword" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Xác nhận mật khẩu mới</label>
                        <input type="password" name="confirmPassword" class="form-control" required>
                    </div>
                    <div class="text-center">
                        <button type="submit" class="btn btn-primary px-4">Thay đổi mật khẩu</button>
                    </div>
                </form>
            </div>
        </div>
    </body>
</html>