<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>


<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Quản lý lịch chiếu</title>
        <meta name="viewport" content="width=device-width, initial-scale=1">

        <!-- Bootstrap -->
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

                        <!-- Tiêu đề -->
                        <h2 class="mb-4">🎬 Quản lý lịch chiếu</h2>
                        <c:if test="${param.addSuccess == '1'}">
                            <div class="alert alert-success alert-dismissible fade show" role="alert">
                                Thêm lịch chiếu mới thành công!
                                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                            </div>
                        </c:if>

                        <c:if test="${param.addFail == '1'}">
                            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                Có lỗi xảy ra khi thêm lịch chiếu. Vui lòng thử lại!
                                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                            </div>
                        </c:if>
                        <c:if test="${param.success == '1'}">
                            <div class="alert alert-success" role="alert">
                                Cập nhật lịch chiếu thành công!
                            </div>
                        </c:if>

                        <c:if test="${param.error == '1'}">
                            <div class="alert alert-danger" role="alert">
                                Cập nhật thất bại! Vui lòng thử lại.
                            </div>
                        </c:if>
                        <c:if test="${param.cancelSuccess == '1'}">
                            <div class="alert alert-success">Đã hủy lịch chiếu thành công!</div>
                        </c:if>

                        <c:if test="${param.cancelFail == '1'}">
                            <div class="alert alert-danger">Không thể hủy lịch chiếu. Vui lòng thử lại.</div>
                        </c:if>

                        <!-- Thanh filter -->
                        <!-- Form tìm kiếm và lọc -->
                        <form action="listScreening" method="get" class="mb-4">

                            <!-- Hàng 1: Thanh tìm kiếm theo tên phim -->
                            <div class="row mb-3 align-items-end">
                                <div class="col-md-6">

                                    <div class="input-group shadow-sm rounded-3">
                                        <input type="text" 
                                               class="form-control rounded-start" 
                                               id="keyword" 
                                               name="keyword"
                                               placeholder="Nhập tên phim cần tìm..."
                                               value="${param.keyword}">
                                        <button type="submit" class="btn btn-primary rounded-end">
                                            <i class="bi bi-search"></i> Tìm kiếm
                                        </button>
                                    </div>
                                </div>
                            </div>

                            <!-- Hàng 2: Ngày bắt đầu / kết thúc / Trạng thái -->
                            <div class="row g-3 align-items-end">

                                <!-- Ngày bắt đầu -->
                                <div class="col-md-3">
                                    <label for="from" class="form-label fw-semibold">Từ ngày</label>
                                    <input type="date" 
                                           class="form-control shadow-sm rounded-3" 
                                           id="from" 
                                           name="from" 
                                           value="${from}">
                                </div>

                                <!-- Ngày kết thúc -->
                                <div class="col-md-3">
                                    <label for="to" class="form-label fw-semibold">Đến ngày</label>
                                    <input type="date" 
                                           class="form-control shadow-sm rounded-3" 
                                           id="to" 
                                           name="to" 
                                           value="${to}">
                                </div>
                                <!-- Khung giờ chiếu -->
                                <div class="col-md-3">
                                    <label for="showtime" class="form-label fw-semibold">Khung giờ chiếu</label>
                                    <select name="showtime" id="showtime" class="form-select shadow-sm rounded-3">
                                        <option value="">Tất cả</option>
                                        <option value="08:00-10:00" ${param.showtime == '08:00-10:00' ? 'selected' : ''}>08:00 - 10:00</option>
                                        <option value="10:15-12:15" ${param.showtime == '10:15-12:15' ? 'selected' : ''}>10:15 - 12:15</option>
                                        <option value="12:30-14:30" ${param.showtime == '12:30-14:30' ? 'selected' : ''}>12:30 - 14:30</option>
                                        <option value="14:45-16:45" ${param.showtime == '14:45-16:45' ? 'selected' : ''}>14:45 - 16:45</option>
                                        <option value="17:00-19:00" ${param.showtime == '17:00-19:00' ? 'selected' : ''}>17:00 - 19:00</option>
                                        <option value="19:15-21:15" ${param.showtime == '19:15-21:15' ? 'selected' : ''}>19:15 - 21:15</option>
                                        <option value="21:30-23:30" ${param.showtime == '21:30-23:30' ? 'selected' : ''}>21:30 - 23:30</option>
                                    </select>
                                </div>

                                <!-- Trạng thái -->
                                <div class="col-md-3">
                                    <label for="status" class="form-label fw-semibold">Trạng thái</label>
                                    <select name="status" id="status" class="form-select shadow-sm rounded-3">
                                        <option value="">Tất cả</option>
                                        <option value="Active" ${status == 'Active' ? 'selected' : ''}>Active</option>
                                        <option value="Inactive" ${status == 'Inactive' ? 'selected' : ''}>Inactive</option>
                                        <option value="Upcoming" ${status == 'Upcoming' ? 'selected' : ''}>Upcoming</option>
                                        <option value="Upcoming" ${status == 'Cancelled' ? 'selected' : ''}>Cancelled</option>
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
                        <a href="addScreening" class="btn btn-success mb-3">➕ Thêm lịch chiếu</a>

                        <!-- Bảng dữ liệu -->
                        <div class="table-responsive">
                            <table class="table table-bordered table-hover align-middle">
                                <thead class="table-dark text-center">
                                    <tr>
                                        <th>Tên phim</th>
                                        <th>Rạp chiếu</th>
                                        <th>Tên phòng</th>
                                        <th>Ngày chiếu</th>
                                        <th>Khung giờ</th>
                                        <th>Trạng thái</th>
                                        <th>Thao tác</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="sc" items="${screenings}" varStatus="loop">
                                        <tr>
                                            <td>${sc.movieTitle}</td>
                                            <td>${sc.cinemaName}</td>
                                            <td>${sc.roomName}</td>
                                            <td class="text-center">${sc.formattedScreeningDate}</td>
                                            <td class="text-center">${sc.showtime}</td>

                                            <td class="text-center">
                                                <span class="badge bg-${sc.movieStatus == 'Active' ? 'success' 
                                                                        : (sc.movieStatus == 'Upcoming' ? 'warning' 
                                                                        : 'secondary')}">
                                                          ${sc.movieStatus}
                                                      </span>
                                                </td>
                                                <td class="text-center">
                                                    <a href="${pageContext.request.contextPath}/viewScreening?screeningID=${sc.screeningID}" 
                                                       class="btn btn-sm btn-info">Xem</a>

                                                    <a href="${pageContext.request.contextPath}/editScreening?screeningID=${sc.screeningID}" 
                                                       class="btn btn-sm btn-warning">Sửa</a>
                                                    <a href="${pageContext.request.contextPath}/cancelScreening?screeningID=${sc.screeningID}" 
                                                       class="btn btn-sm btn-danger"
                                                       onclick="return confirm('Bạn có chắc muốn hủy lịch chiếu này?');">
                                                        Hủy
                                                    </a>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                                 <!-- Phân trang -->
                                <div class="d-flex justify-content-center mt-3">
                                    <ul class="pagination">
                                        <c:if test="${currentPage > 1}">
                                            <li class="page-item">
                                                <a class="page-link"
                                                   href="listScreening?page=${currentPage - 1}&keyword=${keyword}&from=${from}&to=${to}&status=${status}&showtime=${showtime}">
                                                    « Trước
                                                </a>
                                            </li>
                                        </c:if>

                                        <c:forEach begin="1" end="${totalPages}" var="i">
                                            <li class="page-item ${i == currentPage ? 'active' : ''}">
                                                <a class="page-link"
                                                   href="listScreening?page=${i}&keyword=${keyword}&from=${from}&to=${to}&status=${status}&showtime=${showtime}">
                                                    ${i}
                                                </a>
                                            </li>
                                        </c:forEach>

                                        <c:if test="${currentPage < totalPages}">
                                            <li class="page-item">
                                                <a class="page-link"
                                                   href="listScreening?page=${currentPage + 1}&keyword=${keyword}&from=${from}&to=${to}&status=${status}&showtime=${showtime}">
                                                    Sau »
                                                </a>
                                            </li>
                                        </c:if>
                                    </ul>
                                </div>

                            </div>


                        </div>
                    </main>
                </div>
            </div>

            <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        </body>
    </html>
