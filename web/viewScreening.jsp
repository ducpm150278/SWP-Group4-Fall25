<%@page contentType="text/html;charset=UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.TreeMap" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.Comparator" %>
<%@ page import="entity.Seat" %>
<%@ page import="entity.Screening" %>
<%@ page import="entity.BookingSession" %>
<%
    // Kiểm tra đăng nhập và quyền truy cập
    Object userObj = session.getAttribute("user");
    String userRole = (String) session.getAttribute("userRole");

    if (userObj == null) {
        // Nếu chưa đăng nhập, quay về trang đăng nhập
        response.sendRedirect("login.jsp");
        return;
    }

    if (!"admin".equalsIgnoreCase(userRole)) {
        // Nếu không phải admin, quay lại trang chủ
        response.sendRedirect("index.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Chi tiết lịch chiếu</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <style>
            .seat {
                width: 35px;
                height: 35px;
                margin: 4px;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                border-radius: 5px;
                color: white;
                font-weight: bold;
            }
            .available {
                background-color: #28a745;
            }
            .booked {
                background-color: #dc3545;
            }
            .maintenance {
                background-color: #ffc107;
                color: black;
            }
            .unavailable {
                background-color: #6c757d;
            }
            .seat-row-container {
                display: flex;
                align-items: center;
                margin-bottom: 8px;
            }
            .row-label {
                width: 30px;
                font-weight: bold;
                text-align: center;
            }
            .screen-section {
                text-align: center;
                margin: 20px 0;
            }
            .screen {
                height: 5px;
                background: #333;
                width: 70%;
                margin: 0 auto 10px;
                border-radius: 3px;
            }
        </style>
        <style>
            #seatMap {
                display: flex;
                flex-direction: column;
                align-items: center; /* căn giữa theo chiều ngang */
                justify-content: center;
                text-align: center;
                margin-top: 20px;
            }
            .seat-row-container {
                display: flex;
                justify-content: center;
                margin: 5px 0;
            }
        </style>
    </head>
    <body class="bg-light">

        <div class="container mt-5">
            <div class="card shadow-sm mx-auto" style="max-width: 900px;">
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
                            <tr><th>Giá vé</th><td>${detail.baseTicketPrice} VNĐ</td></tr>
                            <tr><th>Số ghế trống</th><td>${availableCount}/${totalSeats}</td></tr>
                            <tr><th>Đã đặt</th><td>${bookedCount}</td></tr>
                        </table>

                        <!-- SƠ ĐỒ GHẾ -->
                        <div class="screen-section">
                            <div class="screen-label fw-bold">MÀN HÌNH</div>
                            <div class="screen"></div>
                        </div>

                        <div id="seatMap" class="text-center">
                            <%
                                if (request.getAttribute("allSeats") != null) {
                                    List<Seat> allSeats = (List<Seat>) request.getAttribute("allSeats");
                                    List<Integer> bookedSeatIDs = (List<Integer>) request.getAttribute("bookedSeatIDs");

                                    Map<String, java.util.List<Seat>> seatsByRow = new java.util.TreeMap<>();
                                    for (Seat seat : allSeats) {
                                        seatsByRow.computeIfAbsent(seat.getSeatRow(), k -> new java.util.ArrayList<>()).add(seat);
                                    }

                                    for (Map.Entry<String, java.util.List<Seat>> entry : seatsByRow.entrySet()) {
                                        String rowLabel = entry.getKey();
                                        java.util.List<Seat> rowSeats = entry.getValue();
                                        java.util.Collections.sort(rowSeats, Comparator.comparing(Seat::getSeatNumber));
                            %>
                            <div class="seat-row-container">
                                <div class="row-label"><%= rowLabel %></div>
                                <div>
                                    <%
                                        for (Seat seat : rowSeats) {
                                            String seatClass = "seat available";
                                            if (bookedSeatIDs.contains(seat.getSeatID())) seatClass = "seat booked";
                                            else if ("Maintenance".equals(seat.getStatus())) seatClass = "seat maintenance";
                                            else if ("Unavailable".equals(seat.getStatus())) seatClass = "seat unavailable";
                                    %>
                                    <div class="<%= seatClass %>"><%= seat.getSeatNumber() %></div>
                                    <%
                                        }
                                    %>
                                </div>
                            </div>
                            <%
                                    }
                                }
                            %>
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

