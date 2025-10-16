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
            <%@ include file="view/admin/header.jsp" %>
        </nav>

        <div id="layoutSidenav">
            <!-- Sidebar -->
            <%@ include file="view/admin/menu-manager.jsp" %>

            <!-- Nội dung chính -->
            <div id="layoutSidenav_content">
                <main class="p-4">
                    <div class="container-fluid">
                        <h2 class="mb-4">📽️ Danh sách phim</h2>

                        <!-- Thanh search -->
                        <form action="list" method="get" class="row g-2 mb-3">
                            <div class="col-md-4">
                                <input type="text" name="keyword" class="form-control" 
                                       placeholder="Tìm phim theo tiêu đề" 
                                       value="${keyword != null ? keyword : ''}">
                            </div>
                            <div class="col-md-2">
                                <button type="submit" class="btn btn-primary w-100">Tìm kiếm</button>
                            </div>
                            <div class="col-md-2">
                                <c:if test="${not empty param.keyword}">
                                    <a href="list" class="btn btn-secondary w-100">Quay lại</a>
                                </c:if>
                            </div>
                        </form>

                        <!-- Nút thêm -->
                        <a href="add" class="btn btn-success mb-3">➕ Thêm phim mới</a>

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
                                            <td class="text-center">${m.releasedDate}</td>
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
                                                <a href="edit?movieID=${m.movieID}" class="btn btn-sm btn-warning">Edit</a>
                                                <a href="delete?movieID=${m.movieID}" class="btn btn-sm btn-danger"
                                                   onclick="return confirm('Bạn có chắc muốn xóa phim này?');">Delete</a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </main>
            </div>
        </div>
    </body>

</html>
