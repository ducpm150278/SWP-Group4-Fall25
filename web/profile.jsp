<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hồ Sơ Cá Nhân - Cinema Booking</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/cinema-dark-theme.css" rel="stylesheet">
</head>
<body>
    <!-- Include Navbar -->
    <jsp:include page="/components/navbar.jsp" />

    <div class="container-medium">
        <div class="card-cinema">
            <div class="card-header-cinema">
                <h1><i class="fas fa-user-circle"></i> Hồ Sơ Cá Nhân</h1>
                <p>Quản lý thông tin tài khoản của bạn</p>
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

                <form action="${pageContext.request.contextPath}/CustomerProfile" method="post">
                    <input type="hidden" name="userId" value="${sessionScope.user.userID}">
                    
                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group-cinema">
                                <label class="form-label-cinema">
                                    <i class="fas fa-user"></i> Họ và tên
                                </label>
                                <input type="text" name="fullName" class="form-control-cinema" 
                                       value="${user.fullName}" required>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group-cinema">
                                <label class="form-label-cinema">
                                    <i class="fas fa-envelope"></i> Email
                                </label>
                                <input type="email" class="form-control-cinema" 
                                       value="${user.email}" disabled>
                                <small style="color: var(--text-secondary); display: block; margin-top: 5px;">
                                    Email không thể thay đổi
                                </small>
                            </div>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group-cinema">
                                <label class="form-label-cinema">
                                    <i class="fas fa-phone"></i> Số điện thoại
                                </label>
                                <input type="tel" name="phoneNumber" class="form-control-cinema" 
                                       value="${user.phoneNumber}">
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group-cinema">
                                <label class="form-label-cinema">
                                    <i class="fas fa-venus-mars"></i> Giới tính
                                </label>
                                <select name="gender" class="form-select-cinema">
                                    <option value="">Chọn giới tính</option>
                                    <option value="Male" ${user.gender == 'Male' ? 'selected' : ''}>Nam</option>
                                    <option value="Female" ${user.gender == 'Female' ? 'selected' : ''}>Nữ</option>
                                    <option value="Other" ${user.gender == 'Other' ? 'selected' : ''}>Khác</option>
                                </select>
                            </div>
                        </div>
                    </div>

                    <div class="form-group-cinema">
                        <label class="form-label-cinema">
                            <i class="fas fa-map-marker-alt"></i> Địa chỉ
                        </label>
                        <input type="text" name="address" class="form-control-cinema" 
                               value="${user.address}">
                    </div>

                    <div class="form-group-cinema">
                        <label class="form-label-cinema">
                            <i class="fas fa-calendar"></i> Ngày sinh
                        </label>
                        <input type="date" name="dateOfBirth" class="form-control-cinema" 
                               value="${user.dateOfBirth}">
                    </div>

                    <div class="d-flex gap-2 justify-content-between" style="margin-top: 30px;">
                        <div>
                            <a href="${pageContext.request.contextPath}/ChangePassword" 
                               class="btn-secondary-cinema btn-cinema">
                                <i class="fas fa-key"></i> Đổi mật khẩu
                            </a>
                            <a href="${pageContext.request.contextPath}/VerifyEmail" 
                               class="btn-secondary-cinema btn-cinema">
                                <i class="fas fa-envelope-circle-check"></i> Xác minh email
                            </a>
                        </div>
                        <button type="submit" class="btn-primary-cinema btn-cinema">
                            <i class="fas fa-save"></i> Lưu thay đổi
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
