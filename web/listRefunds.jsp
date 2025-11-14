<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="java.text.SimpleDateFormat" %> 
<%@ page import="entity.BookingDetailDTO" %> 
<%
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Quản lý Yêu Cầu Hoàn Tiền</title>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
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

                        <h2 class="mb-4">💸 Quản lý Yêu Cầu Hoàn Tiền</h2>

                        <c:if test="${not empty message}">
                            <div class="alert alert-success">${message}</div>
                        </c:if>
                        <c:if test="${not empty error}">
                            <div class="alert alert-danger">${error}</div>
                        </c:if>

                        <div class="table-responsive">
                            <table class="table table-bordered table-hover align-middle">
                                <thead class="table-dark text-center">
                                    <tr>
                                        <th>Mã Đơn Hàng (Vé)</th>
                                        <th>Tên Khách Hàng</th>
                                        <th>Thời Gian Yêu Cầu</th>
                                        <th>Trạng Thái</th>
                                        <th>Phê Duyệt?</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${not empty refundRequests}">
                                            <c:forEach var="booking" items="${refundRequests}">
                                                <jsp:useBean id="booking" scope="page" type="entity.BookingDetailDTO" />
                                                <tr>
                                                    <td class="text-center">
                                                        <a href="${pageContext.request.contextPath}/view-booking?id=${booking.bookingID}">
                                                            ${booking.bookingCode}
                                                        </a>
                                                    </td>
                                                    <td>${booking.customerName}</td>

                                                    <td class="text-center">
                                                        <%= dateFormat.format(java.sql.Timestamp.valueOf(booking.getBookingDate())) %>
                                                    </td>
                                                    <td class="text-center">
                                                        <span class="badge bg-warning text-dark">
                                                            ${booking.status}
                                                        </span>
                                                    </td>
                                                    <td class="text-center" style="min-width: 200px;">
                                                        <form action="list-refunds" method="post" style="display: inline-block;">
                                                            <input type="hidden" name="action" value="approve">
                                                            <input type="hidden" name="bookingID" value="${booking.bookingID}">
                                                            <button type="submit" class="btn btn-sm btn-success">
                                                                Duyệt
                                                            </button>
                                                        </form>

                                                        <form action="list-refunds" method="post" style="display: inline-block;">
                                                            <input type="hidden" name="action" value="deny">
                                                            <input type="hidden" name="bookingID" value="${booking.bookingID}">
                                                            <button type="submit" class="btn btn-sm btn-danger">
                                                                Từ chối
                                                            </button>
                                                        </form>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <tr>
                                                <td colspan="5" class="text-center p-4">
                                                    Không có yêu cầu hoàn tiền nào đang chờ xử lý.
                                                </td>
                                            </tr>
                                        </c:otherwise>
                                    </c:choose>
                                </tbody>
                            </table>
                        </div>

                    </div>
                </main>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>