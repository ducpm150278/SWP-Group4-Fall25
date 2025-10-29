<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="entity.BookingSession"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thanh Toán - Cinema Booking</title>
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
        }
        
        /* Progress Steps */
        .progress-container {
            background: #1a1d24;
            padding: 20px 0;
            border-bottom: 1px solid #2a2d35;
        }
        
        .progress-steps {
            max-width: 800px;
            margin: 0 auto;
            display: flex;
            justify-content: space-between;
            position: relative;
            padding: 0 20px;
        }
        
        .progress-steps::before {
            content: '';
            position: absolute;
            top: 20px;
            left: 15%;
            right: 15%;
            height: 2px;
            background: #2a2d35;
            z-index: 0;
        }
        
        .step {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 10px;
            position: relative;
            z-index: 1;
        }
        
        .step-circle {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: #2a2d35;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
            transition: all 0.3s;
        }
        
        .step.completed .step-circle {
            background: #2ea043;
        }
        
        .step.active .step-circle {
            background: #e50914;
            box-shadow: 0 0 20px rgba(229, 9, 20, 0.5);
        }
        
        .step.completed {
            cursor: pointer;
        }
        
        .step.completed:hover .step-circle {
            background: #3fb950;
            transform: scale(1.1);
        }
        
        .step.completed:hover .step-label {
            color: #3fb950;
        }
        
        .step-label {
            font-size: 12px;
            color: #8b92a7;
            transition: all 0.3s;
        }
        
        .step.active .step-label,
        .step.completed .step-label {
            color: #fff;
            font-weight: 600;
        }
        
        /* Main Container */
        .main-container {
            max-width: 1000px;
            margin: 0 auto;
            padding: 30px 20px;
        }
        
        .page-header {
            margin-bottom: 30px;
        }
        
        .page-header h1 {
            font-size: 28px;
            font-weight: 700;
            margin-bottom: 10px;
        }
        
        .page-header p {
            color: #8b92a7;
            font-size: 16px;
        }
        
        /* Compact Timer - Top Right Corner */
        .timer-compact {
            position: fixed;
            top: 20px;
            right: 20px;
            background: rgba(26, 29, 36, 0.95);
            border-radius: 10px;
            padding: 12px 20px;
            display: flex;
            align-items: center;
            gap: 12px;
            z-index: 1000;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);
        }
        
        .timer-compact-icon {
            font-size: 20px;
            color: #e50914;
        }
        
        .timer-compact-value {
            font-size: 24px;
            font-weight: 700;
            color: #e50914;
            font-variant-numeric: tabular-nums;
        }
        
        .timer-compact.warning .timer-compact-icon,
        .timer-compact.warning .timer-compact-value {
            color: #ff9500;
        }
        
        .timer-compact.critical {
            animation: shake 0.5s infinite;
        }
        
        .timer-compact.critical .timer-compact-icon,
        .timer-compact.critical .timer-compact-value {
            color: #ff3b30;
        }
        
        @keyframes shake {
            0%, 100% { transform: translateX(0); }
            25% { transform: translateX(-5px); }
            75% { transform: translateX(5px); }
        }
        
        /* Summary Box */
        .summary-box {
            background: #1a1d24;
            border: 1px solid #2a2d35;
            padding: 25px;
            border-radius: 12px;
            margin-bottom: 20px;
        }
        
        .summary-box h4 {
            color: #fff;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .summary-box h4 i {
            color: #e50914;
        }
        
        .price-row {
            display: flex;
            justify-content: space-between;
            padding: 12px 0;
            border-bottom: 1px solid #2a2d35;
            color: #8b92a7;
        }
        
        .price-row:last-child {
            border-bottom: none;
        }
        
        .price-row strong {
            color: #fff;
        }
        
        /* Breakdown Sections */
        .breakdown-section {
            background: rgba(42, 45, 53, 0.3);
            border: 1px solid #2a2d35;
            border-radius: 8px;
            padding: 16px;
            margin: 16px 0;
        }
        
        .breakdown-header {
            font-weight: 600;
            font-size: 14px;
            color: #58a6ff;
            margin-bottom: 12px;
            padding-bottom: 8px;
            border-bottom: 1px solid #2a2d35;
        }
        
        .breakdown-header i {
            margin-right: 8px;
        }
        
        .breakdown-item {
            display: flex;
            justify-content: space-between;
            padding: 8px 0;
            font-size: 14px;
            color: #c9d1d9;
        }
        
        .breakdown-total {
            display: flex;
            justify-content: space-between;
            padding: 12px 0 4px 0;
            margin-top: 8px;
            border-top: 1px solid #2a2d35;
            font-size: 15px;
        }
        
        .breakdown-total strong {
            color: #3fb950;
        }
        
        .total-row {
            font-size: 1.3em;
            font-weight: bold;
            color: #fff !important;
            padding-top: 20px;
            margin-top: 10px;
            border-top: 2px solid #2a2d35 !important;
        }
        
        .total-row span:last-child {
            color: #e50914;
            font-size: 1.5em;
        }
        
        /* Cards */
        .card {
            background: #1a1d24;
            border: 1px solid #2a2d35;
            border-radius: 12px;
            margin-bottom: 20px;
        }
        
        .card-body {
            padding: 25px;
        }
        
        .card-body h5 {
            color: #fff;
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .card-body h5 i {
            color: #e50914;
        }
        
        /* Form Controls */
        .form-control {
            background: #2a2d35;
            border: 1px solid #3a3d45;
            color: #fff;
            padding: 12px;
            border-radius: 8px;
        }
        
        .form-control:focus {
            background: #2a2d35;
            border-color: #e50914;
            color: #fff;
            box-shadow: 0 0 0 0.2rem rgba(229, 9, 20, 0.25);
        }
        
        .form-control::placeholder {
            color: #8b92a7;
        }
        
        .form-check-input {
            background: #2a2d35;
            border-color: #3a3d45;
        }
        
        .form-check-input:checked {
            background-color: #e50914;
            border-color: #e50914;
        }
        
        .form-check-label {
            color: #fff;
        }
        
        /* Buttons */
        .btn {
            padding: 12px 30px;
            border-radius: 8px;
            font-weight: 600;
            transition: all 0.3s;
        }
        
        .btn-outline-primary {
            color: #fff;
            border-color: #2a2d35;
            background: #2a2d35;
        }
        
        .btn-outline-primary:hover {
            background: #e50914;
            border-color: #e50914;
            color: #fff;
        }
        
        .btn-primary {
            background: #e50914;
            border-color: #e50914;
            color: #fff;
        }
        
        .btn-primary:hover {
            background: #ff2030;
            border-color: #ff2030;
            box-shadow: 0 4px 20px rgba(229, 9, 20, 0.4);
            transform: translateY(-2px);
        }
        
        /* Alerts */
        .alert {
            border-radius: 12px;
            border: none;
        }
        
        .alert-danger {
            background: rgba(220, 53, 69, 0.1);
            border: 1px solid #dc3545;
            color: #ff6b7a;
        }
        
        .alert-success {
            background: rgba(46, 160, 67, 0.1);
            border: 1px solid #2ea043;
            color: #3fb950;
        }
        
        /* Form Select */
        .form-select {
            background: #2a2d35;
            border: 1px solid #3a3d45;
            color: #fff;
            padding: 12px;
            border-radius: 8px;
        }
        
        .form-select:focus {
            background: #2a2d35;
            border-color: #e50914;
            color: #fff;
            box-shadow: 0 0 0 0.2rem rgba(229, 9, 20, 0.25);
        }
        
        .form-select option {
            background: #2a2d35;
            color: #fff;
        }
        
        /* Input Group */
        .input-group {
            display: flex;
            gap: 10px;
        }
        
        .input-group .form-control {
            flex: 1;
        }
        
        /* Links */
        a {
            color: #e50914;
            text-decoration: none;
        }
        
        a:hover {
            color: #ff2030;
            text-decoration: underline;
        }
        
        /* Payment Method Cards */
        .payment-method-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin-top: 15px;
        }
        
        .payment-option {
            background: #2a2d35;
            border: 2px solid #3a3d45;
            border-radius: 12px;
            padding: 20px;
            cursor: pointer;
            transition: all 0.3s;
            text-align: center;
            position: relative;
        }
        
        .payment-option:hover {
            border-color: #e50914;
            transform: translateY(-2px);
        }
        
        .payment-option.selected {
            border-color: #e50914;
            background: rgba(229, 9, 20, 0.1);
        }
        
        .payment-option input[type="radio"] {
            position: absolute;
            opacity: 0;
        }
        
        .payment-option-icon {
            font-size: 32px;
            margin-bottom: 10px;
            color: #8b92a7;
        }
        
        .payment-option.selected .payment-option-icon {
            color: #e50914;
        }
        
        .payment-option-name {
            font-weight: 600;
            color: #fff;
            margin-bottom: 5px;
        }
        
        .payment-option-desc {
            font-size: 12px;
            color: #8b92a7;
        }
        
        .payment-option-badge {
            position: absolute;
            top: 10px;
            right: 10px;
            background: #e50914;
            color: #fff;
            padding: 3px 8px;
            border-radius: 4px;
            font-size: 10px;
            font-weight: 600;
        }
        
        /* Submit Button */
        .btn-submit-payment {
            width: 100%;
            padding: 18px;
            font-size: 18px;
            font-weight: 700;
            background: linear-gradient(135deg, #e50914 0%, #ff2030 100%);
            border: none;
            border-radius: 12px;
            color: #fff;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            transition: all 0.3s;
            box-shadow: 0 4px 20px rgba(229, 9, 20, 0.3);
        }
        
        .btn-submit-payment:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 30px rgba(229, 9, 20, 0.5);
        }
        
        .btn-submit-payment:active {
            transform: translateY(0);
        }
        
        /* Discount Success */
        .discount-success {
            background: rgba(46, 160, 67, 0.1);
            border: 1px solid #2ea043;
            color: #3fb950;
            padding: 12px;
            border-radius: 8px;
            margin-top: 10px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .discount-success i {
            color: #2ea043;
        }
    </style>
</head>
<body>
    <%
        BookingSession bookingSession = (BookingSession) request.getAttribute("bookingSession");
    %>
    
    <!-- Progress Steps -->
    <div class="progress-container">
        <div class="progress-steps">
            <div class="step completed" onclick="window.location.href='${pageContext.request.contextPath}/booking/select-screening'" title="Quay lại chọn suất chiếu">
                <div class="step-circle"><i class="fas fa-film"></i></div>
                <span class="step-label">Chọn Suất</span>
            </div>
            <div class="step completed" onclick="window.location.href='${pageContext.request.contextPath}/booking/select-seats'" title="Quay lại chọn ghế">
                <div class="step-circle"><i class="fas fa-couch"></i></div>
                <span class="step-label">Chọn Ghế</span>
            </div>
            <div class="step completed" onclick="window.location.href='${pageContext.request.contextPath}/booking/select-food'" title="Quay lại chọn đồ ăn">
                <div class="step-circle"><i class="fas fa-utensils"></i></div>
                <span class="step-label">Đồ Ăn</span>
            </div>
            <div class="step active">
                <div class="step-circle"><i class="fas fa-credit-card"></i></div>
                <span class="step-label">Thanh Toán</span>
            </div>
        </div>
    </div>
    
    <div class="main-container">
        <!-- Page Header -->
        <div class="page-header">
            <h1><i class="fas fa-credit-card"></i> Thanh Toán</h1>
            <p>Hoàn tất thanh toán để xác nhận đặt vé</p>
        </div>
        
        <!-- Compact Timer -->
        <div class="timer-compact" id="timerCompact">
            <div class="timer-compact-icon">
                <i class="fas fa-clock"></i>
            </div>
            <div class="timer-compact-value" id="countdown">00:00</div>
        </div>
        
        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-danger"><%= request.getAttribute("error") %></div>
        <% } %>
        
        <% if (request.getAttribute("success") != null) { %>
            <div class="alert alert-success"><%= request.getAttribute("success") %></div>
        <% } %>
        
        <!-- Order Summary -->
        <div class="summary-box">
            <h4><i class="fas fa-receipt"></i> Chi Tiết Đơn Hàng</h4>
            
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
            
            <!-- Ticket Breakdown -->
            <%
                List<Map<String, Object>> seatDetails = (List<Map<String, Object>>) request.getAttribute("seatDetails");
                if (seatDetails != null && !seatDetails.isEmpty()) {
            %>
            <div class="breakdown-section">
                <div class="breakdown-header">
                    <i class="fas fa-ticket-alt"></i> Chi tiết vé
                </div>
                <% for (Map<String, Object> seat : seatDetails) { 
                    String seatLabel = (String) seat.get("label");
                    String seatType = (String) seat.get("type");
                    double price = (Double) seat.get("price");
                    String typeLabel = "Standard".equals(seatType) ? "Thường" : 
                                     "VIP".equals(seatType) ? "VIP" : 
                                     "Couple".equals(seatType) ? "Đôi" : seatType;
                %>
                <div class="breakdown-item">
                    <span>Ghế <%= seatLabel %> (<%= typeLabel %>)</span>
                    <span><%= String.format("%,.0f đ", price) %></span>
                </div>
                <% } %>
                <div class="breakdown-total">
                    <span>Tổng vé</span>
                    <strong><%= String.format("%,.0f đ", bookingSession.getTicketSubtotal()) %></strong>
                </div>
            </div>
            <% } %>
            
            <!-- Food & Combo Breakdown -->
            <% 
                List<Map<String, Object>> comboDetails = (List<Map<String, Object>>) request.getAttribute("comboDetails");
                List<Map<String, Object>> foodDetails = (List<Map<String, Object>>) request.getAttribute("foodDetails");
                boolean hasFood = (comboDetails != null && !comboDetails.isEmpty()) || 
                                (foodDetails != null && !foodDetails.isEmpty());
                if (hasFood) {
            %>
            <div class="breakdown-section">
                <div class="breakdown-header">
                    <i class="fas fa-utensils"></i> Chi tiết đồ ăn & nước
                </div>
                <% if (comboDetails != null) {
                    for (Map<String, Object> combo : comboDetails) { 
                        String name = (String) combo.get("name");
                        int quantity = (Integer) combo.get("quantity");
                        double price = (Double) combo.get("price");
                        double total = (Double) combo.get("total");
                %>
                <div class="breakdown-item">
                    <span><%= name %> × <%= quantity %></span>
                    <span><%= String.format("%,.0f đ", total) %></span>
                </div>
                <% }} %>
                
                <% if (foodDetails != null) {
                    for (Map<String, Object> food : foodDetails) { 
                        String name = (String) food.get("name");
                        int quantity = (Integer) food.get("quantity");
                        double price = (Double) food.get("price");
                        double total = (Double) food.get("total");
                %>
                <div class="breakdown-item">
                    <span><%= name %> × <%= quantity %></span>
                    <span><%= String.format("%,.0f đ", total) %></span>
                </div>
                <% }} %>
                
                <div class="breakdown-total">
                    <span>Tổng đồ ăn</span>
                    <strong><%= String.format("%,.0f đ", bookingSession.getFoodSubtotal()) %></strong>
                </div>
            </div>
            <% } %>
            
            <% if (bookingSession.getDiscountAmount() > 0) { %>
            <div class="price-row" style="color: #3fb950;">
                <span><i class="fas fa-tag"></i> Giảm giá (<%= bookingSession.getDiscountCode() %>)</span>
                <strong>-<%= String.format("%,.0f đ", bookingSession.getDiscountAmount()) %></strong>
            </div>
            <% } %>
            
            <div class="price-row total-row">
                <span>TỔNG THANH TOÁN</span>
                <span><%= String.format("%,.0f đ", bookingSession.getTotalAmount()) %></span>
            </div>
        </div>
        
        <!-- Payment Form -->
        <form method="post" action="${pageContext.request.contextPath}/booking/payment" id="paymentForm">
            <!-- Discount Code -->
            <div class="card">
                <div class="card-body">
                    <h5><i class="fas fa-ticket-alt"></i> Mã Giảm Giá</h5>
                    <div class="input-group">
                        <input type="text" class="form-control" name="discountCode" id="discountInput"
                               placeholder="Nhập mã giảm giá (nếu có)" value="<%= bookingSession.getDiscountCode() != null ? bookingSession.getDiscountCode() : "" %>">
                        <button type="submit" name="action" value="applyDiscount" class="btn btn-outline-primary">
                            <i class="fas fa-check"></i> Áp Dụng
                        </button>
                    </div>
                    <% if (bookingSession.getDiscountCode() != null && bookingSession.getDiscountAmount() > 0) { %>
                    <div class="discount-success">
                        <i class="fas fa-check-circle"></i>
                        <span>Đã áp dụng mã giảm giá! Bạn tiết kiệm được <%= String.format("%,.0f đ", bookingSession.getDiscountAmount()) %></span>
                    </div>
                    <% } %>
                </div>
            </div>
            
            <!-- Payment Method -->
            <div class="card">
                <div class="card-body">
                    <h5><i class="fas fa-wallet"></i> Phương Thức Thanh Toán</h5>
                    <p style="margin-top: 10px; margin-bottom: 15px; color: #8b949e; font-size: 14px;">
                        <i class="fas fa-info-circle"></i> Hiện tại chúng tôi chỉ hỗ trợ thanh toán online qua VNPay
                    </p>
                    <div class="payment-method-grid">
                        <label class="payment-option selected">
                            <input type="radio" name="paymentMethod" value="VNPay" checked required>
                            <div class="payment-option-badge">Bắt buộc</div>
                            <div class="payment-option-icon">
                                <i class="fas fa-mobile-alt"></i>
                            </div>
                            <div class="payment-option-name">VNPay</div>
                            <div class="payment-option-desc">
                                Thanh toán qua QR Code<br>
                                <small style="color: #58a6ff;">Hỗ trợ tất cả ngân hàng</small>
                            </div>
                        </label>
                    </div>
                    
                    <div style="margin-top: 15px; padding: 12px; background: rgba(88, 166, 255, 0.1); border: 1px solid rgba(88, 166, 255, 0.3); border-radius: 8px;">
                        <p style="margin: 0; color: #58a6ff; font-size: 13px;">
                            <i class="fas fa-shield-alt"></i> <strong>An toàn & bảo mật:</strong><br>
                            Giao dịch được mã hóa và bảo vệ bởi VNPay
                        </p>
                    </div>
                </div>
            </div>
            
            <!-- Terms -->
            <div class="card">
                <div class="card-body">
                    <div class="form-check">
                <input type="checkbox" class="form-check-input" id="agreeTerms" name="agreeTerms">
                <label class="form-check-label" for="agreeTerms">
                            Tôi đã đọc và đồng ý với <a href="#" target="_blank">Điều khoản và điều kiện</a> của rạp
                </label>
                    </div>
                </div>
            </div>
            
            <!-- Submit Button -->
            <button type="submit" name="action" value="payment" class="btn-submit-payment" id="paymentButton">
                <i class="fas fa-lock"></i>
                <span>Thanh Toán <%= String.format("%,.0f đ", bookingSession.getTotalAmount()) %></span>
                <i class="fas fa-arrow-right"></i>
                </button>
        </form>
    </div>
    
    <%
        Long remainingSeconds = (Long) request.getAttribute("remainingSeconds");
        long timeLeftSeconds = remainingSeconds != null ? remainingSeconds : 0;
    %>
    <script>
        let timeLeft = <%= timeLeftSeconds %>;
        
        function updateCountdown() {
            const minutes = Math.floor(timeLeft / 60);
            const seconds = timeLeft % 60;
            const countdownElement = document.getElementById('countdown');
            const timerCompact = document.getElementById('timerCompact');
            
            countdownElement.textContent = 
                String(minutes).padStart(2, '0') + ':' + String(seconds).padStart(2, '0');
            
            // Change color based on time remaining
            if (timeLeft <= 60) {
                timerCompact.className = 'timer-compact critical';
            } else if (timeLeft <= 180) {
                timerCompact.className = 'timer-compact warning';
            }
            
            if (timeLeft <= 0) {
                alert('Hết thời gian giữ chỗ! Bạn sẽ được chuyển về trang chọn suất chiếu.');
                window.location.href = '${pageContext.request.contextPath}/booking/select-screening';
            }
            
            timeLeft--;
        }
        
        // Payment method selection
        document.querySelectorAll('.payment-option').forEach(option => {
            option.addEventListener('click', function() {
                // Remove selected class from all options
                document.querySelectorAll('.payment-option').forEach(opt => {
                    opt.classList.remove('selected');
                });
                
                // Add selected class to clicked option
                this.classList.add('selected');
                
                // Check the radio button
                this.querySelector('input[type="radio"]').checked = true;
            });
        });
        
        // Form validation - only check terms when payment button is clicked
        document.getElementById('paymentForm').addEventListener('submit', function(e) {
            // Find which button was clicked
            const submitter = e.submitter;
            
            // Only validate terms checkbox when payment button is clicked
            if (submitter && submitter.getAttribute('value') === 'payment') {
                const agreeTerms = document.getElementById('agreeTerms');
                if (!agreeTerms.checked) {
                    e.preventDefault();
                    alert('Vui lòng đồng ý với điều khoản và điều kiện để tiếp tục thanh toán.');
                    agreeTerms.focus();
                    return false;
                }
            }
        });
        
        // Initialize countdown
        document.addEventListener('DOMContentLoaded', function() {
            updateCountdown();
        setInterval(updateCountdown, 1000);
        });
    </script>
</body>
</html>

