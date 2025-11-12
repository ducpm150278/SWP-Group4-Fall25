<%-- 
    Document   : editDiscount
    Created on : 23 thg 10, 2025, 23:51:20
    Author     : admin
--%>
<%@page contentType="text/html;charset=UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Chỉnh sửa CTKM</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    </head>
    <body class="bg-light">

        <div class="container py-5">
            <div class="row justify-content-center">
                <div class="col-lg-8">
                    <div class="card shadow-lg border-0 rounded-4">
                        <div class="card-header bg-warning text-white text-center">
                            <h3 class="mb-0">Chỉnh sửa chương trình khuyến mãi</h3>
                        </div>
                        <div class="card-body p-4">

                            <!-- Thông báo lỗi chung -->
                            <c:if test="${not empty error}">
                                <div class="alert alert-danger">${error}</div>
                            </c:if>

                            <form action="editDiscount" method="post">
                                <input type="hidden" name="discountID" value="${discount.discountID}">

                                <!-- Code + Status -->
                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label">Mã CTKM (Code)</label>
                                        <input type="text" name="code" class="form-control" value="${discount.code}" required>
                                        <c:if test="${not empty errorCode}">
                                            <small class="text-danger">${errorCode}</small>
                                        </c:if>
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label">Trạng thái</label>
                                        <select name="status" class="form-select" required>
                                            <option value="Active" ${discount.status == 'Active' ? 'selected' : ''}>Active</option>
                                            <option value="Inactive" ${discount.status == 'Inactive' ? 'selected' : ''}>Inactive</option>
                                            <option value="Expired" ${discount.status == 'Expired' ? 'selected' : ''}>Expired</option>
                                        </select>
                                    </div>
                                </div>

                                <!-- Ngày bắt đầu - kết thúc -->
                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label">Ngày bắt đầu</label>
                                        <input type="date" id="startDate" name="startDate" class="form-control"
                                               value="${startDateFormatted}" required>
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label">Ngày kết thúc</label>
                                        <input type="date" id="endDate" name="endDate" class="form-control"
                                               value="${endDateFormatted}" required>
                                        <c:if test="${not empty errorStartEnd}">
                                            <small class="text-danger">${errorStartEnd}</small>
                                        </c:if>
                                    </div>
                                </div>




                                <!-- MaxUsage - UsageCount -->
                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label">Số lần sử dụng tối đa</label>
                                        <input type="number" name="maxUsage" class="form-control" value="${discount.maxUsage}" min="1" required>
                                        <c:if test="${not empty errorMaxUsage}">
                                            <small class="text-danger">${errorMaxUsage}</small>
                                        </c:if>
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label">Đã sử dụng</label>
                                        <input type="number" name="usageCount" class="form-control" value="${discount.usageCount}" min="0" required>
                                        <c:if test="${not empty errorUsageCount}">
                                            <small class="text-danger">${errorUsageCount}</small>
                                        </c:if>
                                    </div>
                                </div>

                                <!-- Discount % -->
                                <div class="mb-3">
                                    <label class="form-label">Phần trăm giảm giá (%)</label>
                                    <input type="number" name="discountPercentage" class="form-control" 
                                           value="${discount.discountPercentage}" min="0" max="100" required>
                                    <c:if test="${not empty errorDiscount}">
                                        <small class="text-danger">${errorDiscount}</small>
                                    </c:if>
                                </div>

                                <!-- Nút -->
                                <div class="d-flex justify-content-between">
                                    <button type="submit" class="btn btn-warning px-4">Lưu thay đổi</button>
                                    <a href="${pageContext.request.contextPath}/listDiscount" class="btn btn-secondary px-4">Hủy bỏ</a>
                                </div>
                            </form>

                        </div>
                    </div>
                </div>
            </div>
        </div>
        <script>
// Giới hạn ngày bắt đầu và kết thúc chỉ được chọn từ hôm nay trở đi
            const today = new Date().toISOString().split("T")[0];
            document.getElementById("startDate").setAttribute("min", today);
            document.getElementById("endDate").setAttribute("min", today);

// (Tùy chọn) Nếu muốn đảm bảo ngày kết thúc >= ngày bắt đầu
            const startInput = document.getElementById("startDate");
            const endInput = document.getElementById("endDate");

            startInput.addEventListener("change", () => {
                endInput.min = startInput.value || today;
            });
        </script>


    </body>
</html>


