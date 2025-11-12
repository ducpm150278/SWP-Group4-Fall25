<%-- 
    Document   : listMovie
    Created on : 29 thg 9, 2025, 18:46:04
    Author     : admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Danh sách phim</title>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <!-- Bootstrap CSS -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    </head>
    <body class="sb-nav-fixed">
        <!-- Top Navbar -->
        <nav class="sb-topnav navbar navbar-expand navbar-dark bg-dark">
            <%@ include file="../../components/header.jsp" %>
        </nav>

        <div id="layoutSidenav">
            <!-- Sidebar -->
            <%@ include file="../../components/menu-manager.jsp" %>

            <!-- Nội dung chính -->
            <div id="layoutSidenav_content">
                <main class="p-4">
                    <div class="container-fluid">
                        <h2 class="mb-4">📽️ Danh sách phim</h2>
                        <c:if test="${param.addSuccess == '1'}">
                            <div class="alert alert-success">Thêm phim mới thành công!</div>
                        </c:if>
                        <c:if test="${param.updateSuccess == '1'}">
                            <div class="alert alert-success">Cập nhật phim thành công!</div>
                        </c:if>
                        <c:if test="${param.deleteSuccess == '1'}">
                            <div class="alert alert-success">Xóa phim thành công!</div>
                        </c:if>

                        <c:if test="${param.deleteFail == '1'}">
                            <div class="alert alert-danger">Không thể xóa phim. Vui lòng thử lại.</div>
                        </c:if>

                         <!-- Thanh search -->
                        <form action="${pageContext.request.contextPath}/list" method="get" class="mb-4">

                            <!-- Hàng 1: Thanh tìm kiếm -->
                            <div class="row mb-3 align-items-end">
                                <div class="col-md-6">
                                    <div class="input-group shadow-sm rounded-3">
                                        <input type="text" 
                                               name="keyword" 
                                               class="form-control rounded-start" 
                                               placeholder="Tìm phim theo tiêu đề..."
                                               value="${param.keyword}">
                                        <button type="submit" class="btn btn-primary rounded-end">
                                            <i class="bi bi-search"></i> Tìm kiếm
                                        </button>
                                    </div>
                                </div>
                            </div>

                            <!-- Hàng 2: Ngày chiếu, Ngày kết thúc, Trạng thái, Lọc + Quay lại -->
                            <div class="row g-3 align-items-end">

                                <!-- Ngày chiếu -->
                                <div class="col-md-3">
                                    <label for="from" class="form-label fw-semibold">Từ ngày</label>
                                    <input type="date" 
                                           class="form-control shadow-sm rounded-3" 
                                           id="from" 
                                           name="from" 
                                           value="${param.from}">
                                </div>

                                <!-- Ngày kết thúc -->
                                <div class="col-md-3">
                                    <label for="to" class="form-label fw-semibold">Đến ngày</label>
                                    <input type="date" 
                                           class="form-control shadow-sm rounded-3" 
                                           id="to" 
                                           name="to" 
                                           value="${param.to}">
                                </div>

                                <!-- Trạng thái -->
                                <div class="col-md-3">
                                    <label for="status" class="form-label fw-semibold">Trạng thái</label>
                                    <select name="status" id="status" class="form-select shadow-sm rounded-3">
                                        <option value="">Tất cả</option>
                                        <option value="Active" ${param.status == 'Active' ? 'selected' : ''}>Active</option>
                                        <option value="Inactive" ${param.status == 'Inactive' ? 'selected' : ''}>Inactive</option>
                                        <option value="Upcoming" ${param.status == 'Upcoming' ? 'selected' : ''}>Upcoming</option>
                                        <option value="Upcoming" ${param.status == 'Cancelled' ? 'selected' : ''}>Cancelled</option>
                                    </select>
                                </div>

                                <!-- Nút Lọc và Quay lại -->
                                <div class="col-md-3 d-flex gap-2">
                                    <button type="submit" class="btn btn-primary w-100 shadow-sm rounded-3">
                                        <i class="bi bi-funnel"></i> Lọc
                                    </button>

                                    <c:if test="${not empty param.keyword or not empty param.from or not empty param.to or not empty param.status}">
                                        <a href="${pageContext.request.contextPath}/list" class="btn btn-secondary w-100 shadow-sm rounded-3">
                                            <i class="bi bi-arrow-left"></i> Quay lại
                                        </a>
                                    </c:if>
                                </div>
                            </div>

                        </form>

                        <!-- Nút thêm -->
                        <a href="${pageContext.request.contextPath}/add" class="btn btn-success mb-3">➕ Thêm phim mới</a>

                        <!-- Bảng phim -->
                        <div class="table-responsive">
                            <table class="table table-bordered table-hover align-middle">
                                <thead class="table-dark text-center">
                                    <tr>

                                        <th>Tiêu đề</th>
                                        <th>Thể loại</th>
                                        <th>Tóm tắt</th>
                                        <th>Trailer</th>
                                        <th>Cast</th>
                                        <th>Đạo diễn</th>
                                        <th>Thời lượng</th>
                                        <th>Ngày chiếu</th>
                                        <th>Ngày kết thúc</th>
                                        <th>Poster</th>
                                        <th>Trạng thái</th>
                                        <th>Ngôn ngữ</th>
                                        <th>Thao tác</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="m" items="${movies}">
                                        <tr>

                                            <td>${m.title}</td>
                                            <td>${m.genre}</td>
                                            <td>${m.summary}</td>
                                            <td class="text-center">
                                                <a href="${m.trailerURL}" target="_blank" class="btn btn-sm btn-outline-info">Xem trailer</a>
                                            </td>
                                            <td>${m.cast}</td>
                                            <td>${m.director}</td>
                                            <td class="text-center">${m.duration} phút</td>
                                            <td class="text-center">${m.formattedReleasedDate}</td>
                                            <td class="text-center">${m.formattedEndDate}</td>
                                            <td class="text-center">
                                                <img src="${m.posterURL}" alt="Poster" width="80" class="rounded shadow-sm">
                                            </td>
                                            <td class="text-center">
                                                <span class="badge bg-${m.status == 'Active' ? 'success' : (m.status == 'Upcoming' ? 'warning' : 'secondary')}">
                                                    ${m.status}
                                                </span>
                                            </td>
                                            <td class="text-center">${m.languageName}</td>
                                            <td class="text-center">
                                                <a href="${pageContext.request.contextPath}/edit?movieID=${m.movieID}" class="btn btn-sm btn-warning">Edit</a>
                                                <a href="${pageContext.request.contextPath}/delete?movieID=${m.movieID}" class="btn btn-sm btn-danger"
                                               onclick="return confirm('Bạn có chắc muốn xóa phim này?');">Delete</a>
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
                                            <a class="page-link" href="${pageContext.request.contextPath}/list?page=${currentPage - 1}&keyword=${keyword}">« Trước</a>
                                        </li>
                                    </c:if>

                                    <c:forEach begin="1" end="${totalPages}" var="i">
                                        <li class="page-item ${i == currentPage ? 'active' : ''}">
                                            <a class="page-link" href="${pageContext.request.contextPath}/list?page=${i}&keyword=${keyword}">${i}</a>
                                        </li>
                                    </c:forEach>

                                    <c:if test="${currentPage < totalPages}">
                                        <li class="page-item">
                                            <a class="page-link" href="${pageContext.request.contextPath}/list?page=${currentPage + 1}&keyword=${keyword}">Sau »</a>
                                        </li>
                                    </c:if>
                                </ul>
                            </div>

                        </div>
                    </div>
                </main>
            </div>
        </div>
    </body>

</html>
