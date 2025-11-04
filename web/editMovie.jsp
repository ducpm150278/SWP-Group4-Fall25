<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Sửa phim</title>
        <!-- Bootstrap 5 CDN -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    </head>
    <body class="bg-light">

        <div class="container py-5">
            <div class="row justify-content-center">
                <div class="col-md-8">
                    <div class="card shadow-sm">
                        <div class="card-header bg-primary text-white">
                            <h4 class="mb-0">Sửa thông tin phim</h4>
                        </div>
                        <div class="card-body">
                            <form action="edit" method="post">
                                <input type="hidden" name="movieID" value="${movie.movieID}">

                                <div class="mb-3">
                                    <label class="form-label">Tiêu đề</label>
                                    <input type="text" name="title" class="form-control" value="${movie.title}" required>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label">Thể loại</label>
                                    <input type="text" name="genre" class="form-control" value="${movie.genre}" required>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label">Tóm tắt</label>
                                    <textarea name="summary" class="form-control" rows="4">${movie.summary}</textarea>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label">Trailer URL</label>
                                    <input type="text" name="trailerURL" class="form-control" value="${movie.trailerURL}">
                                </div>

                                <div class="mb-3">
                                    <label class="form-label">Dàn diễn viên</label>
                                    <input type="text" name="cast" class="form-control" value="${movie.cast}">
                                </div>

                                <div class="mb-3">
                                    <label class="form-label">Đạo diễn</label>
                                    <input type="text" name="director" class="form-control" value="${movie.director}">
                                </div>

                                <div class="mb-3">
                                    <label class="form-label">Thời lượng (phút)</label>
                                    <input type="number" name="duration" min="1" class="form-control"
                                           value="${movie.duration}" required>
                                    <c:if test="${not empty errorDuration}">
                                        <div class="text-danger mt-1">${errorDuration}</div>
                                    </c:if>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label">Ngày công chiếu</label>
                                    <input type="date" name="releasedDate" class="form-control" value="${movie.releasedDate}" required>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Ngày kết thúc</label>
                                    <input type="date" name="endDate" class="form-control"
                                           value="${movie.endDate}" required>
                                    <c:if test="${not empty errorDate}">
                                        <div class="text-danger mt-1">${errorDate}</div>
                                    </c:if>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label">Poster URL</label>
                                    <input type="text" name="posterURL" class="form-control" value="${movie.posterURL}">
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Ngôn ngữ</label>
                                    <select name="languageName" class="form-select" required>
                                        <c:forEach var="lang" items="${listLanguage}">
                                            <option value="${lang.languageID}" 
                                                    ${lang.languageName == movie.languageName ? 'selected="selected"' : ''}>
                                                ${lang.languageName}
                                            </option>
                                        </c:forEach>
                                    </select>
                                </div>


                                <div class="mb-3">
                                    <label class="form-label">Trạng thái</label>
                                    <select name="status" class="form-select" required>
                                        <option value="Active" ${movie.status=='Active'?'selected':''}>Active</option>
                                        <option value="Inactive" ${movie.status=='Inactive'?'selected':''}>Inactive</option>
                                        <option value="Upcoming" ${movie.status=='Upcoming'?'selected':''}>Upcoming</option>
                                        <option value="Cancelled" ${movie.status=='Cancelled'?'selected':''}>Cancelled</option>
                                    </select>
                                </div>

                                <div class="d-flex justify-content-between">
                                    <button type="submit" class="btn btn-success">Cập nhật phim</button>
                                    <a href="list" class="btn btn-secondary">Hủy</a>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Bootstrap JS (optional, for components like dropdowns, modals) -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    </body>
    <script>
        // Lấy ngày hôm nay ở định dạng yyyy-mm-dd
        const today = new Date().toISOString().split("T")[0];
        document.querySelector('input[name="releasedDate"]').setAttribute('min', today);
    </script>

</html>
