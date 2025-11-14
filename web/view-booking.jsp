<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="entity.BookingDetailDTO" %> 
<%
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
    SimpleDateFormat timeFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm"); 
    SimpleDateFormat dateOnlyFormat = new SimpleDateFormat("EEEE, dd/MM/yyyy", new java.util.Locale("vi", "VN"));
    java.text.DecimalFormat priceFormat = new java.text.DecimalFormat("#,###");
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Chi Tiết Đơn Hàng ${booking.bookingCode}</title>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
        
        <style>
            .invoice-section { margin-bottom: 25px; }
            .invoice-header { display: flex; justify-content: space-between; align-items: start; margin-bottom: 25px; padding-bottom: 20px; border-bottom: 2px solid #dee2e6; }
            .invoice-info h3 { margin: 0 0 10px 0; color: #0d6efd; font-size: 1.5rem; }
            .invoice-meta { text-align: right; }
            .invoice-meta p { margin: 5px 0; color: #6c757d; font-size: 0.9rem; }
            .section-title { font-size: 1.1rem; font-weight: 600; color: #212529; margin-bottom: 15px; display: flex; align-items: center; gap: 10px; }
            .section-title i { color: #0d6efd; }
            .info-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 15px; margin-bottom: 20px; }
            .info-item { background: #f8f9fa; padding: 12px; border-radius: 8px; border: 1px solid #dee2e6; }
            .info-label { font-size: 0.8rem; color: #6c757d; margin-bottom: 5px; }
            .info-value { font-size: 1rem; color: #212529; font-weight: 500; }
            .ticket-list { display: flex; flex-wrap: wrap; gap: 8px; margin-top: 10px; }
            .ticket-item { background: linear-gradient(135deg, #0d6efd 0%, #0a58ca 100%); color: white; padding: 8px 16px; border-radius: 8px; font-weight: 600; }
            .price-table { background: #f8f9fa; border-radius: 8px; padding: 15px; border: 1px solid #dee2e6; }
            .price-table-row { display: flex; justify-content: space-between; padding: 10px 0; border-bottom: 1px solid #dee2e6; }
            .price-table-row:last-child { border-bottom: none; }
            .price-table-row.total { border-top: 2px solid #ced4da; margin-top: 10px; padding-top: 15px; font-size: 1.2rem; font-weight: 700; }
            .status-badge { padding: 5px 12px; border-radius: 15px; font-size: 0.8rem; font-weight: 600; }
            .status-pending { background: #ffc107; color: #000; }
            .status-confirmed { background: #198754; color: white; }
            .status-completed { background: #0d6efd; color: white; }
            .status-cancelled { background: #dc3545; color: white; }
            .status-refundrequested { background: #fd7e14; color: white; }
        </style>
    </head>
    <body class="sb-nav-fixed">
        <nav class="sb-topnav navbar navbar-expand navbar-dark bg-dark">
            <%@ include file="view/admin/header.jsp" %>  
        </nav>
        <div id="layoutSidenav">
            <%@ include file="menu-staff.jsp" %>  
            <div id="layoutSidenav_content">
                <main class="p-4">
                    <div class="container-fluid">

                        <jsp:useBean id="booking" scope="request" type="entity.BookingDetailDTO" />

                        <c:if test="${not empty booking}">
                            <div class="invoice-header">
                                <div class="invoice-info">
                                    <h3>Mã Đơn: ${booking.bookingCode}</h3>
                                    <div class="status-info">
                                        <span class="status-badge status-${booking.status.toLowerCase()}">${booking.status}</span>
                                    </div>
                                </div>
                                <div class="invoice-meta">
                                    <p><strong>Ngày đặt:</strong> 
                                        <%= dateFormat.format(java.sql.Timestamp.valueOf(booking.getBookingDate())) %>
                                    </p>
                                    <c:if test="${booking.paymentDate != null}">
                                        <p><strong>Ngày thanh toán:</strong> 
                                            <%= dateFormat.format(java.sql.Timestamp.valueOf(booking.getPaymentDate())) %>
                                        </p>
                                    </c:if>
                                </div>
                            </div>

                            <div class="invoice-section">
                                <div class="section-title"><i class="fas fa-user"></i><span>Thông Tin Khách Hàng</span></div>
                                <div class="info-grid">
                                    <div class="info-item"><div class="info-label">Tên khách hàng</div><div class="info-value">${booking.customerName}</div></div>
                                    <div class="info-item"><div class="info-label">Email</div><div class="info-value">${booking.customerEmail}</div></div>
                                    <div class="info-item"><div class="info-label">Số điện thoại</div><div class="info-value">${booking.customerPhone}</div></div>
                                </div>
                            </div>
                            
                            <div class="invoice-section">
                                <div class="section-title"><i class="fas fa-film"></i><span>Thông Tin Phim</span></div>
                                <div class="info-grid">
                                    <div class="info-item"><div class="info-label">Tên phim</div><div class="info-value">${booking.movieTitle}</div></div>
                                    <div class="info-item"><div class="info-label">Rạp chiếu</div><div class="info-value">${booking.cinemaName}</div></div>
                                    <div class="info-item"><div class="info-label">Phòng</div><div class="info-value">${booking.roomName}</div></div>
                                    <div class="info-item" style="grid-column: 1 / -1;"><div class="info-label">Suất chiếu</div>
                                        <div class="info-value"><i class="far fa-calendar-alt"></i> 
                                            <%= timeFormat.format(java.sql.Timestamp.valueOf(booking.getScreeningTime())) %>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="invoice-section">
                                <div class="section-title"><i class="fas fa-ticket-alt"></i><span>Vé Đã Đặt (${booking.ticketCount} ghế)</span></div>
                                <div class="ticket-list">
                                    <c:forEach var="seat" items="${booking.seatLabels}">
                                        <div class="ticket-item"><i class="fas fa-couch"></i><span>Ghế ${seat}</span></div>
                                    </c:forEach>
                                </div>
                            </div>
                            
                            <div class="invoice-section">
                                <div class="section-title"><i class="fas fa-money-bill-wave"></i><span>Tổng Kết Thanh Toán</span></div>
                                <div class="price-table">
                                    <div class="price-table-row total">
                                        <span class="label">Tổng Thanh Toán</span>
                                        <span class="value">
                                            <%= priceFormat.format(booking.getFinalAmount()) %>₫
                                        </span>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="text-center mt-4">
                                <a href="${pageContext.request.contextPath}/list-refunds" class="btn btn-secondary">
                                    <i class="fas fa-arrow-left"></i> Quay lại Danh sách
                                </a>
                            </div>

                        </c:if>
                    </div>
                </main>
            </div>
        </div>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>