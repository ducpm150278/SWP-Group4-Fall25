<%-- 
    Document   : addDiscount
    Created on : 23 thg 10, 2025, 23:29:16
    Author     : admin
--%>
<%@page contentType="text/html;charset=UTF-8"%>
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
                                <input type="text" name="code" class="form-control" required>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Trạng thái</label>
                                <select name="status" class="form-select" required>
                                    <option value="Active">Active</option>
                                    <option value="Inactive">Inactive</option>
                                    <option value="Expired">Expired</option>
                                </select>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Ngày bắt đầu</label>
                                <input type="date" name="startDate" class="form-control" required>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Ngày kết thúc</label>
                                <input type="date" name="endDate" class="form-control" required>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Số lần sử dụng tối đa (Max Usage)</label>
                                <input type="number" name="maxUsage" min="1" class="form-control" required>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Đã sử dụng (Usage Count)</label>
                                <input type="number" name="usageCount" min="0" class="form-control" value="0" required>
                            </div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Phần trăm giảm giá (%)</label>
                            <input type="number" name="discountPercentage" class="form-control" min="0" max="100" required>
                        </div>

                        <div class="d-flex justify-content-between">
                            <button type="submit" class="btn btn-success px-4">Thêm CTKM mới</button>
                            <a href="listDiscount" class="btn btn-secondary px-4">Hủy bỏ</a>
                        </div>
                    </form>

                </div>
            </div>
        </div>
    </div>
</div>

</body>
</html>

