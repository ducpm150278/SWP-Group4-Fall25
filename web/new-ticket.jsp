<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Tạo Yêu Cầu Hỗ Trợ Mới</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/cinema-dark-theme.css" rel="stylesheet">
</head>
<body>
    <jsp:include page="/components/navbar.jsp" />
    <div class="container-medium" style="margin-top: 30px;">
        <div class="card-cinema">
            <div class="card-header-cinema">
                <h1><i class="fas fa-plus-circle"></i> Tạo Yêu Cầu Hỗ Trợ Mới</h1>
                <p>Mô tả vấn đề bạn đang gặp phải</p>
            </div>
            
            <div style="padding: 30px;">
                <c:if test="${not empty error}">
                    <div class="alert-cinema alert-danger-cinema">
                        <i class="fas fa-exclamation-circle"></i> ${error}
                    </div>
                </c:if>

                <form action="${pageContext.request.contextPath}/support?action=create" method="post">
                    
                    <div class="form-group-cinema">
                        <label class="form-label-cinema" for="title">
                            <i class="fas fa-heading"></i> Tiêu đề
                        </label>
                        <input type="text" name="title" id="title" class="form-control-cinema" 
                               placeholder="VD: Bị trừ tiền 2 lần cho đơn BK123..." required>
                    </div>
                    
                    <div class="form-group-cinema">
                        <label class="form-label-cinema" for="supportType">
                            <i class="fas fa-info-circle"></i> Loại hỗ trợ
                        </label>
                        <select name="supportType" id="supportType" class="form-select-cinema" required>
                            <option value="">-- Chọn loại vấn đề --</option>
                            <option value="Payment">Vấn đề Thanh toán / Hoàn tiền</option>
                            <option value="Booking">Vấn đề Đặt vé / Hủy vé</option>
                            <option value="Technical">Lỗi Kỹ thuật / Lỗi Web</option>
                            <option value="Account">Vấn đề Tài khoản</option>
                            <option value="Other">Khác</option>
                        </select>
                    </div>

                    <div class="form-group-cinema">
                        <label class="form-label-cinema" for="comment">
                            <i class="fas fa-comment"></i> Mô tả chi tiết vấn đề
                        </label>
                        <textarea class="form-control-cinema" 
                                  id="comment" 
                                  name="comment" 
                                  rows="8" 
                                  placeholder="Vui lòng cung cấp càng nhiều chi tiết càng tốt..." 
                                  required></textarea>
                    </div>

                    <div class="d-flex gap-2 justify-content-between" style="margin-top: 30px;">
                        <a href="${pageContext.request.contextPath}/support" class="btn-secondary-cinema btn-cinema">
                            <i class="fas fa-arrow-left"></i> Hủy
                        </a>
                        <button type="submit" class="btn-primary-cinema btn-cinema">
                            <i class="fas fa-paper-plane"></i> Gửi Yêu Cầu
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>