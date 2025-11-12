<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="com.cinema.entity.SupportTicket" %>
<%@ page import="com.cinema.entity.SupportMessage" %>
<%@ page import="java.util.List" %>
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
        <link href="${pageContext.request.contextPath}/css/cinema-dark-theme.css" rel="stylesheet">
    <head>
        <link href="${pageContext.request.contextPath}/css/cinema-dark-theme.css" rel="stylesheet">


        <style>
            .chat-container {
                max-height: 500px;
                overflow-y: auto;
                background: rgba(0,0,0,0.2);
                padding: 20px;
                border-radius: 8px;
                margin-bottom: 25px;
                border: 1px solid var(--border-color);
            }
            .chat-message {
                margin-bottom: 15px;
                padding: 15px;
                border-radius: 12px;
                max-width: 80%;
                position: relative;
            }
            .chat-message .sender-name {
                font-weight: 700;
                font-size: 0.9rem;
                margin-bottom: 5px;
            }
            .chat-message .message-time {
                font-size: 0.75rem;
                color: var(--text-secondary);
                margin-top: 8px;
                display: block;
            }

            .message-customer {
                background: #2a2d35;
                color: #fff;
                margin-right: auto;
                margin-left: 0;
                border-bottom-left-radius: 0;
                border-bottom-right-radius: 12px;
                border: 1px solid #3a3d45;
            }
            .message-customer .sender-name {
                color: #58a6ff;
            }
            .message-staff {
                background: #0d6efd;
                color: #fff;
                margin-left: auto;
                margin-right: 0;
                border-bottom-right-radius: 0;
                border-bottom-left-radius: 12px;
                border: none;
            }
            .message-staff .sender-name {
                color: #fff;
            }
            .message-staff .message-time {
                color: rgba(255,255,255,0.8);
            }
        </style>
    </head>
</head>
<body>
    <jsp:include page="/components/navbar.jsp" />
    <div class="container-medium" style="margin-top: 30px;">
        <div class="card-cinema">

            <jsp:useBean id="ticket" scope="request" type="com.cinema.entity.SupportTicket" />
            <jsp:useBean id="messages" scope="request" type="java.util.List" /> 

            <div class="card-header-cinema">
                <h1><i class="fas fa-ticket-alt"></i> Chi Tiết Ticket #${ticket.ticketID}</h1>
                <p>${ticket.title}</p>
            </div>

            <div style="padding: 30px;">
                <div class="chat-container" id="chatContainer">
                    <c:forEach var="msg" items="${messages}">

                        <jsp:useBean id="msg" scope="page" type="com.cinema.entity.SupportMessage" />

                        <c:set var="messageClass" value="message-staff" />
                        <c:if test="${msg.senderUserID == sessionScope.userId}">
                            <c:set var="messageClass" value="message-customer" />
                        </c:if>

                        <div class="chat-message ${messageClass}">
                            <div class="sender-name">
                                ${msg.senderName} 
                                <c:if test="${msg.senderRole != 'Customer'}">
                                    <span style="color: #8b92a7; font-weight: 400;">(${msg.senderRole})</span>
                                </c:if>
                            </div>
                            <div class="message-content">
                                ${msg.messageContent}
                            </div>
                            <span class="message-time">
                                <%= dateFormat.format(java.sql.Timestamp.valueOf(msg.getSentDate())) %>
                            </span>
                        </div>
                    </c:forEach>
                </div>

                <c:if test="${ticket.status != 'Closed'}">
                    <form action="${pageContext.request.contextPath}/support?action=reply" method="post">
                        <input type="hidden" name="ticketId" value="${ticket.ticketID}">
                        <div class="form-group-cinema">
                            <label class="form-label-cinema" for="replyComment">
                                <i class="fas fa-reply"></i> Gửi Phản Hồi
                            </label>
                            <textarea class="form-control-cinema" 
                                      id="replyComment" 
                                      name="replyComment" 
                                      rows="5" 
                                      placeholder="Nhập nội dung phản hồi của bạn..." 
                                      required></textarea>
                        </div>
                        <div class="d-flex gap-2 justify-content-between" style="margin-top: 30px;">
                            <a href="${pageContext.request.contextPath}/support" class="btn-secondary-cinema btn-cinema">
                                <i class="fas fa-arrow-left"></i> Quay lại
                            </a>
                            <button type="submit" class="btn-primary-cinema btn-cinema">
                                <i class="fas fa-paper-plane"></i> Gửi
                            </button>
                        </div>
                    </form>
                </c:if>

                <c:if test="${ticket.status == 'Closed'}">
                    <div class="alert-cinema alert-danger-cinema text-center">
                        <i class="fas fa-lock"></i> Yêu cầu hỗ trợ này đã được đóng.
                    </div>
                    <div class="text-center mt-4">
                        <a href="${pageContext.request.contextPath}/support" class="btn-secondary-cinema btn-cinema">
                            <i class="fas fa-arrow-left"></i> Quay lại
                        </a>
                    </div>
                </c:if>
            </div>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Tự động cuộn xuống tin nhắn mới nhất
        var chatContainer = document.getElementById("chatContainer");
        if (chatContainer) {
            chatContainer.scrollTop = chatContainer.scrollHeight;
        }
    </script>
</body>
</html>