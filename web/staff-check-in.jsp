<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="entity.BookingDetailDTO" %>
<%
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    SimpleDateFormat dateOnlyFormat = new SimpleDateFormat("EEEE, dd/MM/yyyy", new java.util.Locale("vi", "VN"));
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Quản lý Vé / Check-in</title>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
        <style>
            .info-item {
                background: #f8f9fa;
                padding: 12px;
                border-radius: 8px;
                border: 1px solid #dee2e6;
            }
            .info-label {
                font-size: 0.8rem;
                color: #6c757d;
                margin-bottom: 5px;
            }
            .info-value {
                font-size: 1rem;
                color: #212529;
                font-weight: 500;
            }
            .ticket-list {
                display: flex;
                flex-wrap: wrap;
                gap: 8px;
                margin-top: 10px;
            }
            .ticket-item {
                background: linear-gradient(135deg, #0d6efd 0%, #0a58ca 100%);
                color: white;
                padding: 8px 16px;
                border-radius: 8px;
                font-weight: 600;
            }
            .status-badge {
                padding: 5px 12px;
                border-radius: 15px;
                font-size: 0.8rem;
                font-weight: 600;
            }
            .status-pending {
                background: #ffc107;
                color: #000;
            }
            .status-confirmed {
                background: #198754;
                color: white;
            }
        </style>
    </head>
    <body class="sb-nav-fixed">
        <nav class="sb-topnav navbar navbar-expand navbar-dark bg-dark">
            <%@ include file="view/admin/header.jsp" %>  
        </nav>
        <div id="layoutSidenav">
            <%@ include file="view/admin/menu-manager.jsp" %>  

            <div id="layoutSidenav_content">
                <main class="p-4">
                    <div class="container-fluid">
                        <h2 class="mb-4">🔍 Quản lý Vé / Check-in</h2>
                        <p class="text-muted mb-4">Tìm vé theo Mã Đặt Vé, SĐT hoặc Email của khách hàng.</p>

                        <div class="card mb-4">
                            <div class="card-body">
                                <form action="staff-check-in" method="GET">
                                    <div class="input-group">
                                        <input type="text" class="form-control form-control-lg" 
                                               name="searchTerm" 
                                               placeholder="Nhập Mã vé, SĐT, hoặc Email..." 
                                               value="${param.searchTerm}" 
                                               required>
                                        <button class="btn btn-primary" type="submit">
                                            <i class="fas fa-search"></i> Tìm Kiếm
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>

                        <c:if test="${not empty message}">
                            <div class="alert alert-success">${message}</div>
                        </c:if>
                        <c:if test="${not empty error}">
                            <div class="alert alert-danger">${error}</div>
                        </c:if>

                        <c:forEach var="booking" items="${bookings}">

                            <jsp:useBean id="booking" scope="page" type="entity.BookingDetailDTO" />

                            <div class="card mb-4"> 
                                <div class="card-header fs-5 fw-bold bg-light">
                                    Kết Quả Tìm Kiếm: ${booking.bookingCode}
                                </div>
                                <div class="card-body">
                                    <div class="row">
                                        <div class="col-md-8">
                                            <h4>${booking.movieTitle}</h4>
                                            <p class="text-muted">
                                                <i class="fas fa-calendar-alt"></i> 
                                                <%= dateOnlyFormat.format(java.sql.Timestamp.valueOf(booking.getScreeningTime())) %>
                                                lúc 
                                                <%= new SimpleDateFormat("HH:mm").format(java.sql.Timestamp.valueOf(booking.getScreeningTime())) %>
                                                <br>
                                                <i class="fas fa-map-marker-alt"></i> 
                                                ${booking.cinemaName} - ${booking.roomName}
                                            </p>

                                            <hr>

                                            <div class="row">
                                                <div class="col-md-6">
                                                    <div class="info-item mb-3">
                                                        <div class="info-label">Tên khách hàng</div>
                                                        <div class="info-value">${booking.customerName}</div>
                                                    </div>
                                                </div>
                                                <div class="col-md-6">
                                                    <div class="info-item mb-3">
                                                        <div class="info-label">Số điện thoại</div>
                                                        <div class="info-value">${booking.customerPhone}</div>
                                                    </div>
                                                </div>
                                            </div>

                                            <div class="info-item">
                                                <div class="info-label">Ghế đã đặt (${booking.ticketCount} ghế)</div>
                                                <div class="ticket-list">
                                                    <c:forEach var="seat" items="${booking.seatLabels}">
                                                        <div class="ticket-item">${seat}</div>
                                                    </c:forEach>
                                                </div>
                                            </div>
                                        </div>

                                        <div class="col-md-4 border-start">
                                            <h5 class="text-center">Trạng Thái Thanh Toán</h5>

                                            <c:choose>
                                                <c:when test="${booking.status == 'Confirmed' && booking.paymentStatus == 'Completed'}">
                                                    <div class="alert alert-success text-center">
                                                        <i class="fas fa-check-circle fa-2x mb-2"></i><br>
                                                        <strong>ĐÃ THANH TOÁN</strong><br>
                                                        (Tổng: <fmt:formatNumber value="${booking.finalAmount}" type="number" pattern="#,###" />₫)
                                                    </div>
                                                    <form action="staff-check-in" method="POST" class="d-grid">
                                                        <input type="hidden" name="action" value="check-in-paid">
                                                        <input type="hidden" name="bookingID" value="${booking.bookingID}">
                                                        <button type="submit" class="btn btn-success btn-lg">
                                                            <i class="fas fa-qrcode"></i> Check-in Ngay
                                                        </button>
                                                    </form>
                                                </c:when>

                                                <c:when test="${booking.status == 'Pending' && booking.paymentStatus == 'Pending'}">
                                                    <div class="alert alert-warning text-center">
                                                        <i class="fas fa-hourglass-half fa-2x mb-2"></i><br>
                                                        <strong>CHỜ THANH TOÁN TẠI QUẦY</strong><br>
                                                        (Tổng: <fmt:formatNumber value="${booking.finalAmount}" type="number" pattern="#,###" />₫)
                                                    </div>
                                                    <form action="staff-check-in" method="POST" class="d-grid">
                                                        <input type="hidden" name="action" value="collect-cash">
                                                        <input type="hidden" name="bookingID" value="${booking.bookingID}">
                                                        <button type="submit" class="btn btn-warning btn-lg">
                                                            <i class="fas fa-cash-register"></i> Thu Tiền Mặt & Check-in
                                                        </button>
                                                    </form>
                                                </c:when>

                                                <c:otherwise>
                                                    <div class="alert alert-secondary text-center">
                                                        <i class="fas fa-info-circle fa-2x mb-2"></i><br>
                                                        <strong>Trạng thái: ${booking.status}</strong><br>
                                                        (Không thể check-in)
                                                    </div>
                                                    <button class="btn btn-secondary btn-lg" disabled>Đã xử lý</button>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </c:forEach> 

                    </div>
                </main>
            </div>
        </div>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>