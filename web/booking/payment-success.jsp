<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="entity.BookingSession"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thanh Toán Thành Công - Cinema Booking</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            background: #0f1014;
            min-height: 100vh;
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            color: #fff;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        
        .success-container {
            max-width: 700px;
            width: 100%;
            background: #1a1d24;
            border: 1px solid #2a2d35;
            border-radius: 16px;
            padding: 50px 40px;
            text-align: center;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.4);
        }
        
        .success-icon {
            width: 100px;
            height: 100px;
            background: linear-gradient(135deg, #3fb950 0%, #2ea043 100%);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 30px;
            animation: scaleIn 0.5s ease-out;
        }
        
        @keyframes scaleIn {
            from {
                transform: scale(0);
                opacity: 0;
            }
            to {
                transform: scale(1);
                opacity: 1;
            }
        }
        
        .success-icon i {
            font-size: 50px;
            color: #fff;
        }
        
        h1 {
            font-size: 32px;
            font-weight: 700;
            color: #3fb950;
            margin-bottom: 15px;
        }
        
        .subtitle {
            font-size: 16px;
            color: #8b949e;
            margin-bottom: 40px;
        }
        
        .info-box {
            background: rgba(42, 45, 53, 0.5);
            border: 1px solid #2a2d35;
            border-radius: 12px;
            padding: 25px;
            margin-bottom: 30px;
            text-align: left;
        }
        
        .info-row {
            display: flex;
            justify-content: space-between;
            padding: 12px 0;
            border-bottom: 1px solid #2a2d35;
        }
        
        .info-row:last-child {
            border-bottom: none;
        }
        
        .info-label {
            color: #8b949e;
            font-size: 14px;
        }
        
        .info-value {
            color: #fff;
            font-weight: 600;
            font-size: 14px;
        }
        
        .info-value.highlight {
            color: #58a6ff;
        }
        
        .action-buttons {
            display: flex;
            gap: 15px;
            margin-top: 30px;
        }
        
        .btn-custom {
            flex: 1;
            padding: 14px 24px;
            border-radius: 10px;
            font-weight: 600;
            text-decoration: none;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            transition: all 0.3s ease;
            border: none;
            cursor: pointer;
        }
        
        .btn-primary-custom {
            background: linear-gradient(135deg, #58a6ff 0%, #1f6feb 100%);
            color: #fff;
        }
        
        .btn-primary-custom:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(88, 166, 255, 0.3);
            color: #fff;
        }
        
        .btn-secondary-custom {
            background: transparent;
            border: 1px solid #2a2d35;
            color: #c9d1d9;
        }
        
        .btn-secondary-custom:hover {
            background: rgba(42, 45, 53, 0.5);
            border-color: #58a6ff;
            color: #58a6ff;
        }
        
        .note {
            margin-top: 30px;
            padding: 15px;
            background: rgba(88, 166, 255, 0.1);
            border: 1px solid rgba(88, 166, 255, 0.3);
            border-radius: 10px;
            color: #58a6ff;
            font-size: 14px;
        }
        
        @media (max-width: 576px) {
            .success-container {
                padding: 40px 20px;
            }
            
            h1 {
                font-size: 24px;
            }
            
            .action-buttons {
                flex-direction: column;
            }
        }
    </style>
</head>
<body>
    <%
        BookingSession bookingSession = (BookingSession) request.getAttribute("bookingSession");
        String orderID = (String) request.getAttribute("orderID");
        String transactionNo = (String) request.getAttribute("transactionNo");
        Long amount = (Long) request.getAttribute("amount");
    %>
    
    <div class="success-container">
        <div class="success-icon">
            <i class="fas fa-check"></i>
        </div>
        
        <h1>Thanh Toán Thành Công!</h1>
        <p class="subtitle">Đặt vé của bạn đã được xác nhận. Vui lòng kiểm tra email để nhận thông tin vé.</p>
        
        <div class="info-box">
            <div class="info-row">
                <span class="info-label"><i class="fas fa-hashtag"></i> Mã đơn hàng</span>
                <span class="info-value highlight"><%= orderID != null ? orderID : "N/A" %></span>
            </div>
            <div class="info-row">
                <span class="info-label"><i class="fas fa-receipt"></i> Mã giao dịch VNPay</span>
                <span class="info-value"><%= transactionNo != null ? transactionNo : "N/A" %></span>
            </div>
            <% if (amount != null) { %>
            <div class="info-row">
                <span class="info-label"><i class="fas fa-money-bill-wave"></i> Tổng thanh toán</span>
                <span class="info-value highlight"><%= String.format("%,d đ", amount) %></span>
            </div>
            <% } %>
            <% if (bookingSession != null) { %>
            <div class="info-row">
                <span class="info-label"><i class="fas fa-film"></i> Phim</span>
                <span class="info-value"><%= bookingSession.getMovieTitle() %></span>
            </div>
            <div class="info-row">
                <span class="info-label"><i class="fas fa-couch"></i> Ghế</span>
                <span class="info-value"><%= String.join(", ", bookingSession.getSelectedSeatLabels()) %></span>
            </div>
            <% } %>
        </div>
        
        <div class="note">
            <i class="fas fa-envelope"></i> 
            <strong>Thông tin vé đã được gửi đến email của bạn.</strong><br>
            Vui lòng mang theo mã đơn hàng khi đến rạp.
        </div>
        
        <div class="action-buttons">
            <a href="${pageContext.request.contextPath}/profile" class="btn-custom btn-primary-custom">
                <i class="fas fa-ticket-alt"></i> Xem Vé Của Tôi
            </a>
            <a href="${pageContext.request.contextPath}/index.jsp" class="btn-custom btn-secondary-custom">
                <i class="fas fa-home"></i> Về Trang Chủ
            </a>
        </div>
    </div>
</body>
</html>
