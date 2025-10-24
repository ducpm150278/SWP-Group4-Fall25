<%-- 
    Document   : listDiscount
    Created on : 23 thg 10, 2025, 22:11:43
    Author     : admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>


<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Danh sách CTKM</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    </head>
    <body class="sb-nav-fixed">
        <!-- Header -->
        <nav class="sb-topnav navbar navbar-expand navbar-dark bg-dark">
            <%@ include file="view/admin/header.jsp" %>  
        </nav>
        <div id="layoutSidenav">
            <%@ include file="view/admin/menu-manager.jsp" %>  
            <div id="layoutSidenav_content">
                <main class="p-4">
                    <div class="container-fluid">
                        <h2 class="mb-4">🎁 Danh sách chương trình khuyến mại</h2>
                        <c:if test="${param.addSuccess == '1'}">
                            <div class="alert alert-success">Thêm chương trình khuyến mãi thành công!</div>
                        </c:if>
                        <c:if test="${param.updateSuccess == '1'}">
                            <div class="alert alert-success">Cập nhật CTKM thành công!</div>
                        </c:if>
                        <c:if test="${param.deleteSuccess == '1'}">
                            <div class="alert alert-success">Đã xóa chương trình khuyến mãi thành công!</div>
                        </c:if>
                        <c:if test="${param.deleteFail == '1'}">
                            <div class="alert alert-danger">Xóa chương trình khuyến mãi thất bại!</div>
                        </c:if>

                        <!-- Thanh tìm kiếm và lọc -->
                        <!-- Form tìm kiếm và lọc -->
                        <form action="listDiscount" method="get" class="mb-4">

                            <!-- Hàng 1: Thanh tìm kiếm theo tên mã -->
                            <div class="row mb-3 align-items-end">
                                <div class="col-md-6">

                                    <div class="input-group shadow-sm rounded-3">
                                        <input type="text" 
                                               class="form-control rounded-start" 
                                               id="keyword" 
                                               name="keyword"
                                               placeholder="Tìm theo mã CTKM..."
                                               value="${param.keyword}">
                                        <button type="submit" class="btn btn-primary rounded-end">
                                            <i class="bi bi-search"></i> Tìm kiếm
                                        </button>
                                    </div>
                                </div>
                            </div>

                            <!-- Hàng 2: Ngày bắt đầu / kết thúc / Trạng thái -->
                            <div class="row g-3 align-items-end">

                                <div class="col-md-3"> 
                                    <label for="status" class="form-label fw-semibold">Thời điểm áp dụng</label>
                                    <input type="date" name="start" class="form-control"> </div>

                                <!-- Trạng thái -->
                                <div class="col-md-3">
                                    <label for="status" class="form-label fw-semibold">Trạng thái</label>
                                    <select name="status" id="status" class="form-select shadow-sm rounded-3">
                                        <option value="">Tất cả</option>
                                        <option value="Active" ${status == 'Active' ? 'selected' : ''}>Active</option>
                                        <option value="Inactive" ${status == 'Inactive' ? 'selected' : ''}>Inactive</option>
                                        <option value="Upcoming" ${status == 'Expired' ? 'selected' : ''}>Expired</option>
                                    </select>
                                </div>

                                <!-- Nút tìm kiếm & quay lại -->
                                <div class="col-md-3 d-flex gap-2">
                                    <!-- Nút tìm kiếm -->
                                    <button type="submit" class="btn btn-primary w-100 shadow-sm rounded-3">
                                        <i class="bi bi-funnel"></i> Lọc
                                    </button>

                                    <!-- Nút quay lại -->
                                    <c:if test="${not empty param.keyword or not empty param.from or not empty param.to or not empty param.status}">
                                        <a href="listScreening" class="btn btn-secondary w-100 shadow-sm rounded-3">
                                            <i class="bi bi-arrow-left"></i> Quay lại
                                        </a>
                                    </c:if>
                                </div>
                            </div>

                        </form>



                        <!-- Nút thêm mới -->
                        <a href="addDiscount" class="btn btn-success mb-3">➕ Thêm Chương Trình Khuyến Mại</a>

                        <!-- Bảng dữ liệu -->
                        <table class="table table-bordered table-hover align-middle">
                            <thead class="table-dark text-center">
                                <tr>
                                    <th>Mã CTKM</th>
                                    <th>Thời điểm áp dụng</th>
                                    <th>Thời lượng (ngày)</th>
                                    <th>Trạng thái</th>
                                    <th>Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="item" items="${discounts}">
                                    <c:set var="d" value="${item.discount}" />
                                    <tr class="text-center">
                                        <td>${d.code}</td>
                                        <td>
                                            <fmt:formatDate value="${item.startDate}" pattern="dd/MM/yyyy" /> →
                                            <fmt:formatDate value="${item.endDate}" pattern="dd/MM/yyyy" />
                                        </td>
                                        <td>${item.duration} ngày</td>
                                        <td>
                                            <span class="badge bg-${d.status == 'Active' ? 'success' : (d.status == 'Inactive' ? 'secondary' : 'danger')}">
                                                ${d.status}
                                            </span>
                                        </td>
                                        <td>
                                            <a href="viewDiscount?discountID=${d.discountID}" class="btn btn-sm btn-info">Xem</a>
                                            <a href="editDiscount?discountID=${d.discountID}" class="btn btn-sm btn-warning">Sửa</a>
                                            <a href="deleteDiscount?discountID=${d.discountID}" 
                                               class="btn btn-sm btn-danger"
                                               onclick="return confirm('Bạn có chắc muốn xóa CTKM này?');">
                                                Xóa
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>

                        </table>


                        <!-- Phân trang -->
                        <div class="d-flex justify-content-center mt-3">
                            <ul class="pagination">
                                <!-- Nút "Trước" -->
                                <c:if test="${currentPage > 1}">
                                    <li class="page-item">
                                        <a class="page-link"
                                           href="listDiscount?page=${currentPage - 1}
                                           &keyword=${param.keyword}
                                           &start=${param.start}
                                           &status=${param.status}">
                                            « Trước
                                        </a>
                                    </li>
                                </c:if>

                                <!-- Hiển thị số trang -->
                                <c:forEach begin="1" end="${totalPages}" var="i">
                                    <li class="page-item ${i == currentPage ? 'active' : ''}">
                                        <a class="page-link"
                                           href="listDiscount?page=${i}
                                           &keyword=${param.keyword}
                                           &start=${param.start}
                                           &status=${param.status}">
                                            ${i}
                                        </a>
                                    </li>
                                </c:forEach>

                                <!-- Nút "Sau" -->
                                <c:if test="${currentPage < totalPages}">
                                    <li class="page-item">
                                        <a class="page-link"
                                           href="listDiscount?page=${currentPage + 1}
                                           &keyword=${param.keyword}
                                           &start=${param.start}
                                           &status=${param.status}">
                                            Sau »
                                        </a>
                                    </li>
                                </c:if>
                            </ul>
                        </div>



                    </div>
                </main>
            </div>
        </div>

    </body>
</html>

