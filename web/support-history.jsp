<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page import="java.text.SimpleDateFormat" %> 
<%@ page import="entity.SupportTicket" %>
<%
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Trung Tâm Hỗ Trợ</title>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
        <link href="${pageContext.request.contextPath}/css/cinema-dark-theme.css" rel="stylesheet">
        <style>
            .status-badge {
                padding: 5px 12px;
                border-radius: 15px;
                font-size: 0.8rem;
                font-weight: 600;
            }
            .status-new {
                background: #0d6efd;
                color: white;
            }
            .status-in-progress {
                background: #ffc107;
                color: #000;
            }
            .status-answered {
                background: #198754;
                color: white;
            }
            .status-closed {
                background: #6c757d;
                color: white;
            }
            
            .btn-light-outline {
            background: #ffffff !important; /* Nền trắng */
            color: var(--primary-red, #e50914) !important; /* Chữ đỏ */
            border: 2px solid #ffffff;
            font-weight: 600;
            transition: all 0.3s ease;
        }
        
        .btn-light-outline:hover {
            background: #f0f0f0 !important; /* Hơi xám khi hover */
            color: var(--dark-red, #b20710) !important; /* Chữ đỏ đậm hơn */
            border-color: #f0f0f0;
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(255, 255, 255, 0.2);
        }
        </style>
    </head>
    <body>
        <jsp:include page="/components/navbar.jsp" />
        <div class="container-medium" style="margin-top: 30px;">
            <div class="card-cinema">
                <div class="card-header-cinema" style="display: flex; justify-content: space-between; align-items: center;">
                    <div>
                        <h1><i class="fas fa-headset"></i> Yêu Cầu Hỗ Trợ Của Bạn</h1>
                        <p>Theo dõi các yêu cầu đã gửi</p>
                    </div>
                    <a href="${pageContext.request.contextPath}/support?action=new" class="btn-light-outline btn-cinema">
                        <i class="fas fa-plus"></i> Tạo Yêu Cầu Mới
                    </a>
                </div>

                <div style="padding: 30px;">
                    <div class="table-responsive">
                        <table class="table table-dark table-hover align-middle">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Tiêu Đề</th>
                                    <th>Loại Hỗ Trợ</th>
                                    <th>Trạng Thái</th>
                                    <th>Cập nhật lần cuối</th>
                                    <th>Hành động</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${not empty tickets}">
                                        <c:forEach var="ticket" items="${tickets}">

                                            <jsp:useBean id="ticket" scope="page" type="entity.SupportTicket" />

                                            <tr>
                                                <td class="text-center">#${ticket.ticketID}</td>
                                                <td>${ticket.title}</td>
                                                <td>${ticket.supportType}</td>
                                                <td class="text-center">
                                                    <span class="status-badge status-${ticket.status.toLowerCase().replace(' ', '-')}">
                                                        ${ticket.status}
                                                    </span>
                                                </td>

                                                <td class="text-center">
                                                    <%= dateFormat.format(java.sql.Timestamp.valueOf(ticket.getLastActivityDate())) %>
                                                </td>

                                                <td class="text-center">
                                                    <a href="${pageContext.request.contextPath}/support?action=view&id=${ticket.ticketID}" class="btn-secondary-cinema btn-cinema btn-sm">
                                                        <i class="fas fa-eye"></i> Xem
                                                    </a>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="6" class="text-center p-4">
                                                Bạn chưa có yêu cầu hỗ trợ nào.
                                            </td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>
                    <div class="text-center mt-4">
                        <a href="${pageContext.request.contextPath}/CustomerProfile" class="btn-secondary-cinema btn-cinema">
                            <i class="fas fa-arrow-left"></i> Quay lại Profile
                        </a>
                    </div>
                </div>
            </div>
        </div>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>