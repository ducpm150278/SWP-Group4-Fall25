<%-- 
    Document   : addDiscount
    Created on : 23 thg 10, 2025, 23:29:16
    Author     : admin
--%>
<%@page contentType="text/html;charset=UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Thêm chương trình khuyến mãi</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    </head>
    <body class="bg-light">

        <div class="container py-5">
            <div class="row justify-content-center">
                <div class="col-lg-8">
                    <div class="card shadow-lg border-0 rounded-4">
                        <div class="card-header bg-primary text-white text-center">
                            <h3 class="mb-0">Thêm chương trình khuyến mãi</h3>
                        </div>
                        <div class="card-body p-4">
                            <form action="addDiscount" method="post">
                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label">Mã CTKM (Code)</label>
                                        <input type="text" name="code" value="${code}" class="form-control" required>
                                        <c:if test="${not empty errors.codeError}">
                                            <div class="text-danger small mt-1">${errors.codeError}</div>
                                        </c:if>
                                    </div>

                                    <div class="col-md-6 mb-3">
                                        <label class="form-label">Trạng thái</label>
                                        <select name="status" class="form-select" required>
                                            <option value="Active" ${status == 'Active' ? 'selected' : ''}>Active</option>
                                            <option value="Inactive" ${status == 'Inactive' ? 'selected' : ''}>Inactive</option>
                                            <option value="Expired" ${status == 'Expired' ? 'selected' : ''}>Expired</option>
                                        </select>
                                    </div>
                                </div>

                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label">Ngày bắt đầu</label>
                                        <input type="date" id="startDate" name="startDate" value="${startDate}" class="form-control" required>
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label">Ngày kết thúc</label>
                                        <input type="date" id="endDate" name="endDate" value="${endDate}" class="form-control" required>
                                        <c:if test="${not empty errors.dateError}">
                                            <div class="text-danger small mt-1">${errors.dateError}</div>
                                        </c:if>
                                    </div>
                                </div>


                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label">Số lần sử dụng tối đa</label>
                                        <input type="number" name="maxUsage" min="0" value="${maxUsage}" class="form-control" required>
                                        <c:if test="${not empty errors.maxUsageError}">
                                            <div class="text-danger small mt-1">${errors.maxUsageError}</div>
                                        </c:if>
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label">Đã sử dụng</label>
                                        <input type="number" name="usageCount" min="0" value="${usageCount}" class="form-control" required>
                                        <c:if test="${not empty errors.usageCountError}">
                                            <div class="text-danger small mt-1">${errors.usageCountError}</div>
                                        </c:if>
                                    </div>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label">Phần trăm giảm giá (%)</label>
                                    <input type="number" name="discountPercentage" min="0" max="100"
                                           value="${discountPercentage}" class="form-control" required>
                                    <c:if test="${not empty errors.discountError}">
                                        <div class="text-danger small mt-1">${errors.discountError}</div>
                                    </c:if>
                                </div>

                                <div class="d-flex justify-content-between">
                                    <button type="submit" class="btn btn-success px-4">Thêm CTKM mới</button>
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
        </script>

    </body>
</html>


