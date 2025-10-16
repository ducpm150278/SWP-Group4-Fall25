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
        <style>
            body {
                background-color: #f8f9fa;
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
                        <p><a href="changePassword.jsp">Đổi mật khẩu?</a></p>

                        <!--                <div class="col-md-6">
                                            <label class="form-label">CMND / CCCD</label>
                                            <input type="text" name="cmnd" class="form-control" value="">
                                        </div>-->
                        <!--                <div class="col-md-6">
                                            <label class="form-label">Thành phố</label>
                                            <input type="text" name="city" class="form-control" value="">
                                        </div>-->
                        <!--                <div class="col-md-6">
                                            <label class="form-label">Quận / Huyện</label>
                                            <input type="text" name="district" class="form-control" value="">
                                        </div>-->
                    </div>
                    <div class="text-center mt-4">
                        <button type="submit" class="btn btn-primary px-4">Lưu</button>
                        <a href="${pageContext.request.contextPath}/CustomerProfile" class="btn btn-secondary px-4">Hủy</a>
                    </div>
                </form>
            </div>
        </div>

    </body>
</html>

