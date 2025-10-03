<%-- 
    Document   : addMovie
    Created on : 29 thg 9, 2025, 18:40:38
    Author     : admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Thêm phim mới</title>
        <!-- Bootstrap CSS -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    </head>
    <body class="bg-light">

        <div class="container py-5">
            <div class="row justify-content-center">
                <div class="col-lg-8">
                    <div class="card shadow-lg border-0 rounded-4">
                        <div class="card-header bg-primary text-white text-center">
                            <h3 class="mb-0">Thêm phim mới</h3>
                        </div>
                        <div class="card-body p-4">

                            <!-- Hiển thị lỗi nếu có -->
                            <c:if test="${not empty error}">
                                <div class="alert alert-danger">${error}</div>
                            </c:if>

                            <form action="add" method="post" class="needs-validation" novalidate>
                                <div class="mb-3">
                                    <label class="form-label">Tiêu đề</label>
                                    <input type="text" name="title" class="form-control" required>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label">Thể loại</label>
                                    <input type="text" name="genre" class="form-control" required>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label">Tóm tắt</label>
                                    <textarea name="summary" class="form-control" rows="4"></textarea>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label">Trailer URL</label>
                                    <input type="url" name="trailerURL" class="form-control">
                                </div>

                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label">Dàn diễn viên</label>
                                        <input type="text" name="cast" class="form-control">
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label">Đạo diễn</label>
                                        <input type="text" name="director" class="form-control">
                                    </div>
                                </div>

                                <div class="row">
                                    <div class="col-md-4 mb-3">
                                        <label class="form-label">Thời lượng (phút)</label>
                                        <input type="number" name="duration" min="1" class="form-control" required>
                                    </div>
                                    <div class="col-md-4 mb-3">
                                        <label class="form-label">Ngày công chiếu</label>
                                        <input type="date" name="releasedDate" class="form-control" required>
                                    </div>
                                    <div class="col-md-4 mb-3">
                                        <label class="form-label">Trạng thái</label>
                                        <select name="status" class="form-select" required>
                                            <option value="Active">Active</option>
                                            <option value="Inactive">Inactive</option>
                                            <option value="Upcoming">Upcoming</option>
                                            <option value="Cancelled">Cancelled</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Ngôn ngữ</label>
                                    <select name="languageName" class="form-select" required>
                                        <c:forEach var="lang" items="${listLanguage}">
                                            <option value="${lang.languageID}">${lang.languageName}</option>
                                        </c:forEach>

                                    </select>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Poster URL</label>
                                    <input type="url" name="posterURL" class="form-control">
                                </div>

                                <div class="d-flex justify-content-between">
                                    <button type="submit" class="btn btn-success px-4">Thêm phim</button>
                                    <button type="reset" class="btn btn-secondary px-4">Nhập lại</button>
                                    <a href="list" class="btn btn-secondary">Hủy</a>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Bootstrap JS -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

    </body>
</html>
