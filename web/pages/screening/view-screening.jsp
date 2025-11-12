<%@page contentType="text/html;charset=UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Chi tiết lịch chiếu</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    </head>
    <body class="bg-light">

        <div class="container mt-5">
            <div class="card shadow-sm mx-auto" style="max-width: 800px;">
                <div class="card-header bg-primary text-white text-center">
                    <h4 class="mb-0">Chi tiết lịch chiếu</h4>
                </div>

                <div class="card-body">
                    <c:if test="${not empty detail}">
                        <table class="table table-bordered">
                            <tr><th>Tên phim</th><td>${detail.movieTitle}</td></tr>
                            <tr><th>Rạp chiếu</th><td>${detail.cinemaName}</td></tr>
                            <tr><th>Tên phòng</th><td>${detail.roomName}</td></tr>
                            <tr><th>Loại phòng</th><td>${detail.roomType}</td></tr>
                            <tr><th>Ngày chiếu</th><td>${formattedDate}</td></tr>
                            <tr><th>Khung giờ</th><td>${detail.showtime}</td></tr>
                            <tr><th>Trạng thái</th><td>${detail.movieStatus}</td></tr>
                            <tr><th>Giá vé</th><td>${detail.baseTicketPrice} VNĐ</td></tr>
                        </table>

                        <div class="text-center mt-3">
                            <a href="${pageContext.request.contextPath}/listScreening" class="btn btn-secondary">Quay lại</a>
                        </div>
                    </c:if>
                </div>
            </div>
        </div>

    </body>
</html>
