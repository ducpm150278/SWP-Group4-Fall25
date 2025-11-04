<%@page contentType="text/html;charset=UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Chi tiết lịch chiếu</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <style>
            /* Container chung cho sơ đồ ghế */
            .seat-map {
                display: flex;
                flex-direction: column;
                align-items: center;
                justify-content: center;
                margin-top: 20px;
            }

            /* Hàng ghế */
            .seat-row {
                display: flex;
                justify-content: center;
                gap: 8px;
                margin-bottom: 8px;
            }

            /* Ghế */
            .seat {
                width: 30px;
                height: 30px;
                border-radius: 6px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 12px;
                font-weight: bold;
                color: #fff;
                transition: transform 0.2s;
            }

            .seat.available {
                background-color: #dee2e6;
                color: #000;
            }

            .seat.booked {
                background-color: #28a745;
            }

            .seat:hover {
                transform: scale(1.1);
            }

            /* Thanh màn hình phía trên */
            .screen {
                width: 80%;
                height: 20px;
                background-color: #ccc;
                text-align: center;
                border-radius: 8px;
                margin-bottom: 20px;
                font-weight: bold;
                color: #333;
            }

            /* Chú thích */
            .seat-legend {
                display: flex;
                justify-content: center;
                align-items: center;
                gap: 25px;
                margin-top: 20px;
            }

            .seat-legend .seat {
                width: 25px;
                height: 25px;
                margin-right: 5px;
            }
        </style>

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
                            <tr><th>Số ghế khả dụng</th><td>${availableSeats}</td></tr>
                            <tr><th>Số ghế đã bán</th><td>${soldSeats}</td></tr>
                        </table>
                        <h5 class="text-center mt-4 mb-3">Sơ đồ ghế</h5>
                        <div class="seat-map">
                            <div class="screen">MÀN HÌNH</div>
                            <c:forEach var="i" begin="0" end="${rows - 1}">
                                <div class="seat-row">
                                    <c:forEach var="j" begin="0" end="${cols - 1}">
                                        <c:set var="index" value="${i * cols + j}" />
                                        <c:if test="${index < seatLabels.size()}">
                                            <div class="seat available">
                                                ${seatLabels[index]}
                                            </div>
                                        </c:if>
                                    </c:forEach>
                                </div>
                            </c:forEach>

                            <div class="seat-legend">
                                <div class="d-flex align-items-center">
                                    <span class="seat available"></span> Còn trống
                                </div>
                                <div class="d-flex align-items-center">
                                    <span class="seat booked"></span> Đã đặt
                                </div>
                            </div>
                        </div>





                        <div class="text-center mt-3">
                            <a href="${pageContext.request.contextPath}/listScreening" class="btn btn-secondary">Quay lại</a>
                        </div>
                    </c:if>
                </div>
            </div>
        </div>

    </body>
</html>
