<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="entity.SupportTicket" %>
<%@ page import="entity.SupportMessage" %>
<%
    SimpleDateFormat dateFormat = new SimpleDateFormat("HH:mm, dd/MM/yyyy");
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Chi Tiết Hỗ Trợ #${ticket.ticketID}</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .chat-container { max-height: 500px; overflow-y: auto; background: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 25px; border: 1px solid #dee2e6; }
        .chat-message { margin-bottom: 15px; padding: 15px; border-radius: 12px; max-width: 80%; position: relative; }
        .chat-message .sender-name { font-weight: 700; font-size: 0.9rem; margin-bottom: 5px; }
        .chat-message .message-time { font-size: 0.75rem; color: #6c757d; margin-top: 8px; display: block; }
        .message-customer { background: #0d6efd; color: #fff; margin-left: auto; border-bottom-right-radius: 0; }
        .message-customer .sender-name { color: #fff; }
        .message-customer .message-time { color: rgba(255,255,255,0.8); }
        .message-staff { background: #fff; color: #212529; margin-right: auto; border-bottom-left-radius: 0; border: 1px solid #dee2e6; }
        .message-staff .sender-name { color: #198754; }
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
                    
                    <jsp:useBean id="ticket" scope="request" type="entity.SupportTicket" />
                    <jsp:useBean id="messages" scope="request" type="java.util.List" /> 
                    
                    <h2 class="mb-4">Phản Hồi Ticket #${ticket.ticketID}</h2>
                    <p class="text-muted">Chủ đề: ${ticket.title} (Khách hàng: ${ticket.customerName})</p>
                    
                    <div class="card">
                        <div class="card-header">
                            Lịch sử trao đổi
                        </div>
                        <div class="card-body">
                            <div class="chat-container" id="chatContainer">
                                <c:forEach var="msg" items="${messages}">
                                    
                                    <jsp:useBean id="msg" scope="page" type="entity.SupportMessage" />

                                    <c:if test="${msg.senderRole == 'Customer'}">
                                        <div class="chat-message message-customer">
                                            <div class="sender-name">${msg.senderName} (Khách hàng)</div>
                                            <div class="message-content">${msg.messageContent}</div>
                                            <span class="message-time">
                                                <%= dateFormat.format(java.sql.Timestamp.valueOf(msg.getSentDate())) %>
                                            </span>
                                        </div>
                                    </c:if>
                                    <c:if test="${msg.senderRole != 'Customer'}">
                                        <div class="chat-message message-staff">
                                            <div class="sender-name">${msg.senderName} (Nhân viên)</div>
                                            <div class="message-content">${msg.messageContent}</div>
                                            <span class="message-time">
                                                <%= dateFormat.format(java.sql.Timestamp.valueOf(msg.getSentDate())) %>
                                            </span>
                                        </div>
                                    </c:if>
                                </c:forEach>
                            </div>

                            <hr>
                            <h4 class="mt-4">Gửi Phản Hồi Mới</h4>
                            <form action="${pageContext.request.contextPath}/staff-support-detail" method="post">
                                <input type="hidden" name="ticketId" value="${ticket.ticketID}">
                                
                                <div class="mb-3">
                                    <label for="replyComment" class="form-label fw-semibold">Nội dung phản hồi:</label>
                                    <textarea class="form-control" 
                                              id="replyComment" 
                                              name="replyComment" 
                                              rows="5" 
                                              placeholder="Nhập nội dung phản hồi cho khách hàng..." 
                                              required></textarea>
                                </div>
                                
                                <div class="mb-3">
                                    <label for="newStatus" class="form-label fw-semibold">Cập nhật trạng thái ticket:</label>
                                    <select name="newStatus" id="newStatus" class="form-select" required>
                                        <option value="Answered" ${ticket.status == 'Answered' ? 'selected' : ''}>Đã Trả Lời (Đợi khách)</option>
                                        <option value="Closed" ${ticket.status == 'Closed' ? 'selected' : ''}>Đóng (Đã giải quyết xong)</option>
                                        <option value="In Progress" ${ticket.status == 'In Progress' ? 'selected' : ''}>Đang xử lý</option>
                                        <option value="New" ${ticket.status == 'New' ? 'selected' : ''}>Mới</option>
                                    </select>
                                </div>

                                <div class="d-flex gap-2 justify-content-end" style="margin-top: 20px;">
                                    <a href="${pageContext.request.contextPath}/staff-support" class="btn btn-secondary">
                                        Hủy bỏ
                                    </a>
                                    <button type="submit" class="btn btn-primary">
                                        <i class="fas fa-paper-plane"></i> Gửi Phản Hồi
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </main>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Tự động cuộn xuống tin nhắn mới nhất
        var chatContainer = document.getElementById("chatContainer");
        if(chatContainer) {
            chatContainer.scrollTop = chatContainer.scrollHeight;
        }
    </script>
</body>
</html>