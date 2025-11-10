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
                                    <input type="text" name="title" class="form-control" value="${title}" required>
                                    <c:if test="${not empty errors.errorTitle}">
                                        <div class="text-danger mt-1">${errors.errorTitle}</div>
                                    </c:if>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label">Thể loại</label>
                                    <input type="text" name="genre" class="form-control" value="${genre}" required>
                                    <c:if test="${not empty errors.errorGenre}">
                                        <div class="text-danger mt-1">${errors.errorGenre}</div>
                                    </c:if>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label">Tóm tắt</label>
                                    <textarea name="summary" class="form-control" rows="4">${summary}</textarea>
                                    <c:if test="${not empty errors.errorSummary}">
                                        <div class="text-danger mt-1">${errors.errorSummary}</div>
                                    </c:if>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label">Trailer URL</label>
                                    <input type="url" name="trailerURL" class="form-control" value="${trailerURL}">
                                    <c:if test="${not empty errors.errorTrailer}">
                                        <div class="text-danger mt-1">${errors.errorTrailer}</div>
                                    </c:if>
                                </div>

                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label">Dàn diễn viên</label>
                                        <input type="text" name="cast" class="form-control" value="${cast}">
                                        <c:if test="${not empty errors.errorCast}">
                                            <div class="text-danger mt-1">${errors.errorCast}</div>
                                        </c:if>
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label">Đạo diễn</label>
                                        <input type="text" name="director" class="form-control" value="${director}">
                                        <c:if test="${not empty errors.errorDirector}">
                                            <div class="text-danger mt-1">${errors.errorDirector}</div>
                                        </c:if>
                                    </div>
                                </div>

                                <div class="row">
                                    <div class="col-md-4 mb-3">
                                        <label class="form-label">Thời lượng (phút)</label>
                                        <input type="number" name="duration" min="1" class="form-control" 
                                               value="${duration}" required>
                                        <c:if test="${not empty errorDuration}">
                                            <div class="text-danger mt-1">${errorDuration}</div>
                                        </c:if>
                                    </div>

                                    <div class="col-md-4 mb-3">
                                        <label class="form-label">Ngày công chiếu</label>
                                        <input type="date" name="releasedDate" id="releasedDate" class="form-control" 
                                               value="${releasedDate}" required>

                                    </div>
                                    <div class="col-md-3 mb-3">
                                        <label class="form-label">Ngày kết thúc</label>
                                        <input type="date" name="endDate" class="form-control" 
                                               value="${endDate}" required>
                                        <c:if test="${not empty errorDate}">
                                            <div class="text-danger mt-1">${errorDate}</div>
                                        </c:if>
                                    </div>

                                    <div class="col-md-4 mb-3">
                                        <label class="form-label">Trạng thái</label>
                                        <select name="status" class="form-select" required>
                                            <option value="Active" ${status == 'Active' ? 'selected' : ''}>Active</option>
                                            <option value="Inactive" ${status == 'Inactive' ? 'selected' : ''}>Inactive</option>
                                            <option value="Upcoming" ${status == 'Upcoming' ? 'selected' : ''}>Upcoming</option>
                                            <option value="Cancelled" ${status == 'Cancelled' ? 'selected' : ''}>Cancelled</option>
                                        </select>
                                    </div>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label">Ngôn ngữ</label>
                                    <select name="languageName" class="form-select" required>
                                        <c:forEach var="lang" items="${listLanguage}">
                                            <option value="${lang.languageID}" 
                                                    ${selectedLanguage == lang.languageID ? 'selected' : ''}>
                                                ${lang.languageName}
                                            </option>
                                        </c:forEach>
                                    </select>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label">Poster URL</label>
                                    <input type="url" name="posterURL" class="form-control" value="${posterURL}">
                                    <c:if test="${not empty errors.errorPoster}">
                                        <div class="text-danger mt-1">${errors.errorPoster}</div>
                                    </c:if>
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
        <script>
            // Lấy ngày hiện tại (theo local timezone)
            const today = new Date().toISOString().split("T")[0];
            document.getElementById("releasedDate").setAttribute("min", today);
        </script>

    </body>
</html>
