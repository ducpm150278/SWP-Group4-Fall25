<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="com.cinema.entity.SupportTicket" %>
<%
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Quản lý Hỗ Trợ Khách Hàng</title>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
        <style>
            .status-badge { padding: 5px 12px; border-radius: 15px; font-size: 0.8rem; font-weight: 600; }
            .status-new { background-color: #0d6efd; color: white; }
            .status-in-progress { background-color: #ffc107; color: #000; }
            .status-answered { background-color: #198754; color: white; }
            .status-closed { background-color: #6c757d; color: white; }
        </style>
    </head>
    <body class="sb-nav-fixed">
        <nav class="sb-topnav navbar navbar-expand navbar-dark bg-dark">
            <%@ include file="../../components/header.jsp" %>  
        </nav>
        <div id="layoutSidenav">
            <%@ include file="../../components/menu-manager.jsp" %>  
            <div id="layoutSidenav_content">
                <main class="p-4">
                    <div class="container-fluid">
                        <h2 class="mb-4">🎧 Quản lý Hỗ Trợ Khách Hàng</h2>
                        
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
                                        <th>Mã Ticket</th>
                                        <th>Tiêu Đề</th>
                                        <th>Tên Khách Hàng</th>
                                        <th>Loại Hỗ Trợ</th>
                                        <th>Trạng Thái</th>
                                        <th>Cập nhật lần cuối</th>
                                        <th>Thao tác</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${not empty tickets}">
                                            <c:forEach var="ticket" items="${tickets}">
                                            
                                                <jsp:useBean id="ticket" scope="page" type="com.cinema.entity.SupportTicket" />
                                            
                                                <tr>
                                                    <td class="text-center">#${ticket.ticketID}</td>
                                                    <td>${ticket.title}</td>
                                                    <td>${ticket.customerName}</td>
                                                    <td class="text-center">${ticket.supportType}</td>
                                                    <td class="text-center">
                                                        <span class="status-badge status-${ticket.status.toLowerCase().replace(' ', '-')}">
                                                            ${ticket.status}
                                                        </span>
                                                    </td>
                                                    
                                                    <td class="text-center">
                                                        <%= dateFormat.format(java.sql.Timestamp.valueOf(ticket.getLastActivityDate())) %>
                                                    </td>
                                                    
                                                    <td class="text-center">
                                                        <a href="${pageContext.request.contextPath}/staff-support-detail?id=${ticket.ticketID}" 
                                                           class="btn btn-sm btn-primary">
                                                            <i class="fas fa-reply"></i> Phản hồi
                                                        </a>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <tr>
                                                <td colspan="7" class="text-center p-4">
                                                    Không có yêu cầu hỗ trợ nào.
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