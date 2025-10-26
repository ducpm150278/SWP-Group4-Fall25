<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="entity.BookingSession"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thanh Toán - Cinema Booking</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        body { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; }
        .payment-container { max-width: 900px; margin: 30px auto; padding: 30px; background: white; border-radius: 15px; }
        .summary-box { background: #f8f9fa; padding: 20px; border-radius: 10px; margin-bottom: 20px; }
        .price-row { display: flex; justify-content: space-between; padding: 10px 0; border-bottom: 1px solid #dee2e6; }
        .total-row { font-size: 1.5em; font-weight: bold; color: #667eea; }
    </style>
</head>
<body>
    <%
        BookingSession bookingSession = (BookingSession) request.getAttribute("bookingSession");
    %>
    
    <div class="payment-container">
        <div class="text-center mb-4">
            <h2><i class="fas fa-credit-card"></i> Thanh Toán</h2>
        </div>
        
        <!-- Timer -->
        <div class="alert alert-warning text-center">
            <i class="fas fa-clock"></i> Thời gian còn lại: <span id="countdown">00:00</span>
        </div>
        
        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-danger"><%= request.getAttribute("error") %></div>
        <% } %>
        
        <% if (request.getAttribute("success") != null) { %>
            <div class="alert alert-success"><%= request.getAttribute("success") %></div>
        <% } %>
        
        <!-- Order Summary -->
        <div class="summary-box">
            <h4 class="mb-3">Chi Tiết Đơn Hàng</h4>
            
            <div class="price-row">
                <span><i class="fas fa-film"></i> Phim:</span>
                <strong><%= bookingSession.getMovieTitle() %></strong>
            </div>
            
            <div class="price-row">
                <span><i class="fas fa-building"></i> Rạp:</span>
                <span><%= bookingSession.getCinemaName() %> - <%= bookingSession.getRoomName() %></span>
            </div>
            
            <div class="price-row">
                <span><i class="fas fa-couch"></i> Ghế:</span>
                <span><%= String.join(", ", bookingSession.getSelectedSeatLabels()) %></span>
            </div>
            
            <div class="price-row">
                <span>Vé (<%= bookingSession.getSeatCount() %> ghế × <%= String.format("%,.0f", bookingSession.getTicketPrice()) %>)</span>
                <strong><%= String.format("%,.0f VNĐ", bookingSession.getTicketSubtotal()) %></strong>
            </div>
            
            <% if (bookingSession.getFoodSubtotal() > 0) { %>
            <div class="price-row">
                <span><i class="fas fa-utensils"></i> Đồ ăn & nước</span>
                <strong><%= String.format("%,.0f VNĐ", bookingSession.getFoodSubtotal()) %></strong>
            </div>
            <% } %>
            
            <% if (bookingSession.getDiscountAmount() > 0) { %>
            <div class="price-row text-success">
                <span><i class="fas fa-tag"></i> Giảm giá (<%= bookingSession.getDiscountCode() %>)</span>
                <strong>-<%= String.format("%,.0f VNĐ", bookingSession.getDiscountAmount()) %></strong>
            </div>
            <% } %>
            
            <div class="price-row total-row">
                <span>TỔNG CỘNG</span>
                <span><%= String.format("%,.0f VNĐ", bookingSession.getTotalAmount()) %></span>
            </div>
        </div>
        
        <!-- Payment Form -->
        <form method="post" action="${pageContext.request.contextPath}/booking/payment" id="paymentForm">
            <!-- Discount Code -->
            <div class="card mb-3">
                <div class="card-body">
                    <h5><i class="fas fa-ticket-alt"></i> Mã Giảm Giá</h5>
                    <div class="input-group">
                        <input type="text" class="form-control" name="discountCode" 
                               placeholder="Nhập mã giảm giá" value="<%= bookingSession.getDiscountCode() != null ? bookingSession.getDiscountCode() : "" %>">
                        <button type="submit" name="action" value="applyDiscount" class="btn btn-outline-primary">Áp Dụng</button>
                    </div>
                </div>
            </div>
            
            <!-- Payment Method -->
            <div class="card mb-3">
                <div class="card-body">
                    <h5><i class="fas fa-wallet"></i> Phương Thức Thanh Toán</h5>
                    <select class="form-select" name="paymentMethod" required>
                        <option value="VNPay" selected>VNPay (Khuyến nghị)</option>
                        <option value="Cash">Tiền mặt tại quầy</option>
                        <option value="Credit Card">Thẻ tín dụng</option>
                    </select>
                </div>
            </div>
            
            <!-- Terms -->
            <div class="form-check mb-3">
                <input type="checkbox" class="form-check-input" id="agreeTerms" name="agreeTerms" required>
                <label class="form-check-label" for="agreeTerms">
                    Tôi đồng ý với <a href="#" target="_blank">Điều khoản và điều kiện</a> khi mua vé
                </label>
            </div>
            
            <!-- Submit Button -->
            <div class="text-center">
                <button type="submit" name="action" value="payment" class="btn btn-primary btn-lg">
                    <i class="fas fa-lock"></i> Thanh Toán <%= String.format("%,.0f VNĐ", bookingSession.getTotalAmount()) %>
                </button>
            </div>
        </form>
    </div>
    
    <script>
        let timeLeft = <%= request.getAttribute("remainingSeconds") %>;
        
        function updateCountdown() {
            const minutes = Math.floor(timeLeft / 60);
            const seconds = timeLeft % 60;
            document.getElementById('countdown').textContent = 
                String(minutes).padStart(2, '0') + ':' + String(seconds).padStart(2, '0');
            
            if (timeLeft <= 0) {
                alert('Hết thời gian giữ chỗ!');
                window.location.href = '${pageContext.request.contextPath}/booking/select-screening';
            }
            timeLeft--;
        }
        
        setInterval(updateCountdown, 1000);
    </script>
</body>
</html>

