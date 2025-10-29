<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="entity.Combo"%>
<%@page import="entity.Food"%>
<%@page import="entity.BookingSession"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chọn Đồ Ăn - Cinema Booking</title>
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
            max-width: 1200px;
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
        
        @keyframes pulse {
            0%, 100% { 
                transform: scale(1);
                color: #e50914;
            }
            50% { 
                transform: scale(1.05);
                color: #ff2030;
            }
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
        
        /* Tab Navigation */
        .custom-tabs {
            display: flex;
            gap: 10px;
            margin-bottom: 30px;
            border-bottom: 2px solid #2a2d35;
        }
        
        .custom-tab {
            padding: 15px 30px;
            background: transparent;
            border: none;
            color: #8b92a7;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            border-bottom: 3px solid transparent;
            transition: all 0.3s;
            position: relative;
            top: 2px;
        }
        
        .custom-tab:hover {
            color: #fff;
        }
        
        .custom-tab.active {
            color: #fff;
            border-bottom-color: #e50914;
        }
        
        .custom-tab i {
            margin-right: 8px;
        }
        
        /* Food Items Grid */
        .food-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .food-card {
            background: #1a1d24;
            border-radius: 12px;
            border: 1px solid #2a2d35;
            overflow: hidden;
            transition: all 0.3s;
            position: relative;
        }
        
        .food-card:hover {
            border-color: #e50914;
            box-shadow: 0 8px 24px rgba(229, 9, 20, 0.15);
            transform: translateY(-2px);
        }
        
        .food-card-body {
            padding: 20px;
        }
        
        .food-name {
            font-size: 18px;
            font-weight: 600;
            color: #fff;
            margin-bottom: 8px;
        }
        
        .food-description {
            font-size: 14px;
            color: #8b92a7;
            margin-bottom: 15px;
            min-height: 40px;
        }
        
        .food-price {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 15px;
        }
        
        .price-original {
            font-size: 14px;
            color: #8b92a7;
            text-decoration: line-through;
        }
        
        .price-current {
            font-size: 20px;
            font-weight: 700;
            color: #e50914;
        }
        
        .price-badge {
            background: #e50914;
            color: #fff;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 11px;
            font-weight: 600;
            margin-left: auto;
        }
        
        /* Quantity Controls */
        .quantity-section {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding-top: 15px;
            border-top: 1px solid #2a2d35;
        }
        
        .quantity-label {
            font-size: 13px;
            color: #8b92a7;
            font-weight: 500;
        }
        
        .quantity-control {
            display: flex;
            align-items: center;
            gap: 12px;
        }
        
        .quantity-btn {
            width: 36px;
            height: 36px;
            border: 2px solid #2a2d35;
            background: #2a2d35;
            color: #fff;
            border-radius: 8px;
            font-weight: bold;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.2s;
            font-size: 18px;
        }
        
        .quantity-btn:hover:not(:disabled) {
            background: #e50914;
            border-color: #e50914;
            transform: scale(1.05);
        }
        
        .quantity-btn:disabled {
            opacity: 0.3;
            cursor: not-allowed;
        }
        
        .quantity-input {
            width: 50px;
            height: 36px;
            text-align: center;
            border: 1px solid #2a2d35;
            background: #2a2d35;
            color: #fff;
            border-radius: 8px;
            font-weight: 600;
            font-size: 16px;
        }
        
        .quantity-input:focus {
            outline: none;
            border-color: #e50914;
        }
        
        /* Summary Section */
        .summary-section {
            background: #1a1d24;
            border-radius: 12px;
            border: 1px solid #2a2d35;
            padding: 25px;
            margin-bottom: 25px;
        }
        
        .summary-title {
            font-size: 18px;
            font-weight: 600;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .summary-title i {
            color: #e50914;
        }
        
        .summary-row {
            display: flex;
            justify-content: space-between;
            padding: 12px 0;
            border-bottom: 1px solid #2a2d35;
        }
        
        .summary-row:last-child {
            border-bottom: none;
            padding-top: 20px;
            margin-top: 10px;
            border-top: 2px solid #2a2d35;
        }
        
        .summary-label {
            color: #8b92a7;
            font-size: 15px;
        }
        
        .summary-value {
            font-weight: 600;
            color: #fff;
            font-size: 15px;
        }
        
        .summary-row:last-child .summary-label {
            font-size: 18px;
            color: #fff;
            font-weight: 600;
        }
        
        .summary-row:last-child .summary-value {
            font-size: 24px;
            color: #e50914;
        }
        
        /* Action Buttons */
        .action-buttons {
            display: flex;
            gap: 15px;
            flex-wrap: wrap;
        }
        
        .btn-custom {
            flex: 1;
            min-width: 150px;
            padding: 15px 30px;
            font-size: 16px;
            font-weight: 600;
            border-radius: 8px;
            border: none;
            cursor: pointer;
            transition: all 0.3s;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
        }
        
        .btn-skip {
            background: #2a2d35;
            color: #fff;
        }
        
        .btn-skip:hover {
            background: #3a3d45;
        }
        
        .btn-reset {
            background: transparent;
            color: #8b92a7;
            border: 2px solid #2a2d35;
        }
        
        .btn-reset:hover {
            border-color: #fff;
            color: #fff;
        }
        
        .btn-confirm {
            background: #e50914;
            color: #fff;
            flex: 2;
        }
        
        .btn-confirm:hover {
            background: #ff2030;
            box-shadow: 0 4px 20px rgba(229, 9, 20, 0.4);
            transform: translateY(-2px);
        }
        
        /* Empty State */
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #8b92a7;
        }
        
        .empty-state i {
            font-size: 64px;
            margin-bottom: 20px;
            opacity: 0.5;
        }
        
        .empty-state p {
            font-size: 16px;
        }
        
        /* Responsive */
        @media (max-width: 768px) {
            .food-grid {
                grid-template-columns: 1fr;
            }
            
            .action-buttons {
                flex-direction: column;
            }
            
            .btn-custom {
                width: 100%;
            }
        }
    </style>
</head>
<body>
    <%
        BookingSession bookingSession = (BookingSession) request.getAttribute("bookingSession");
        List<Combo> combos = (List<Combo>) request.getAttribute("combos");
        List<Food> foods = (List<Food>) request.getAttribute("foods");
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
            <div class="step active">
                <div class="step-circle"><i class="fas fa-utensils"></i></div>
                <span class="step-label">Đồ Ăn</span>
            </div>
            <div class="step">
                <div class="step-circle"><i class="fas fa-credit-card"></i></div>
                <span class="step-label">Thanh Toán</span>
            </div>
        </div>
    </div>
    
    <div class="main-container">
        <!-- Page Header -->
        <div class="page-header">
            <h1><i class="fas fa-utensils"></i> Chọn Đồ Ăn & Thức Uống</h1>
            <p>Thêm món ăn yêu thích để trải nghiệm phim tốt hơn (có thể bỏ qua)</p>
        </div>
        
        <!-- Compact Timer -->
        <div class="timer-compact" id="timerCompact">
            <div class="timer-compact-icon">
                <i class="fas fa-clock"></i>
            </div>
            <div class="timer-compact-value" id="countdown">00:00</div>
        </div>
        
        <form method="post" action="${pageContext.request.contextPath}/booking/select-food" id="foodForm">
            <!-- Custom Tabs -->
            <div class="custom-tabs">
                <button type="button" class="custom-tab active" onclick="switchTab('combos', this)">
                    <i class="fas fa-box"></i> Combo Tiết Kiệm
                </button>
                <button type="button" class="custom-tab" onclick="switchTab('foods', this)">
                    <i class="fas fa-hamburger"></i> Đồ Ăn Riêng Lẻ
                </button>
            </div>
            
            <!-- Combos Tab -->
            <div id="combos-content" class="tab-content-area">
                <% if (combos != null && !combos.isEmpty()) { %>
                    <div class="food-grid">
                    <% for (Combo combo : combos) { %>
                        <div class="food-card">
                            <div class="food-card-body">
                                <div class="food-name"><%= combo.getComboName() %></div>
                                <div class="food-description"><%= combo.getDescription() %></div>
                                
                                <div class="food-price">
                                    <% if (combo.getDiscountPrice() != null) { %>
                                        <span class="price-original"><%= String.format("%,.0f đ", combo.getTotalPrice()) %></span>
                                        <span class="price-current"><%= String.format("%,.0f đ", combo.getDiscountPrice()) %></span>
                                        <span class="price-badge">
                                            -<%= Math.round((1 - combo.getDiscountPrice().doubleValue() / combo.getTotalPrice().doubleValue()) * 100) %>%
                                        </span>
                                    <% } else { %>
                                        <span class="price-current"><%= String.format("%,.0f đ", combo.getTotalPrice()) %></span>
                                    <% } %>
                                </div>
                                
                                <div class="quantity-section">
                                    <span class="quantity-label">Số lượng</span>
                                    <div class="quantity-control">
                                        <button type="button" class="quantity-btn" onclick="decreaseQuantity('combo-<%= combo.getComboID() %>')" id="btn-dec-combo-<%= combo.getComboID() %>">
                                            <i class="fas fa-minus"></i>
                                        </button>
                                        <input type="number" class="quantity-input" id="combo-<%= combo.getComboID() %>" 
                                               name="combo-<%= combo.getComboID() %>" value="0" min="0" max="10" readonly
                                               onchange="updateTotal()">
                                        <button type="button" class="quantity-btn" onclick="increaseQuantity('combo-<%= combo.getComboID() %>')" id="btn-inc-combo-<%= combo.getComboID() %>">
                                            <i class="fas fa-plus"></i>
                                        </button>
                                    </div>
                                </div>
                                
                                <input type="hidden" name="comboIDs" value="<%= combo.getComboID() %>">
                                <input type="hidden" name="comboQuantities" value="0" id="combo-<%= combo.getComboID() %>-hidden">
                                <input type="hidden" name="comboPrice-<%= combo.getComboID() %>" 
                                       value="<%= combo.getDiscountPrice() != null ? combo.getDiscountPrice() : combo.getTotalPrice() %>">
                            </div>
                        </div>
                    <% } %>
                    </div>
                <% } else { %>
                    <div class="empty-state">
                        <i class="fas fa-box-open"></i>
                        <p>Hiện tại chưa có combo nào</p>
                    </div>
                <% } %>
            </div>
            
            <!-- Individual Foods Tab -->
            <div id="foods-content" class="tab-content-area" style="display: none;">
                <% if (foods != null && !foods.isEmpty()) { %>
                    <div class="food-grid">
                    <% for (Food food : foods) { %>
                        <div class="food-card">
                            <div class="food-card-body">
                                <div class="food-name"><%= food.getFoodName() %></div>
                                <div class="food-description"><%= food.getDescription() %></div>
                                
                                <div class="food-price">
                                    <span class="price-current"><%= String.format("%,.0f đ", food.getPrice()) %></span>
                                </div>
                                
                                <div class="quantity-section">
                                    <span class="quantity-label">Số lượng</span>
                                    <div class="quantity-control">
                                        <button type="button" class="quantity-btn" onclick="decreaseQuantity('food-<%= food.getFoodID() %>')" id="btn-dec-food-<%= food.getFoodID() %>">
                                            <i class="fas fa-minus"></i>
                                        </button>
                                        <input type="number" class="quantity-input" id="food-<%= food.getFoodID() %>" 
                                               name="food-<%= food.getFoodID() %>" value="0" min="0" max="10" readonly
                                               onchange="updateTotal()">
                                        <button type="button" class="quantity-btn" onclick="increaseQuantity('food-<%= food.getFoodID() %>')" id="btn-inc-food-<%= food.getFoodID() %>">
                                            <i class="fas fa-plus"></i>
                                        </button>
                                    </div>
                                </div>
                                
                                <input type="hidden" name="foodIDs" value="<%= food.getFoodID() %>">
                                <input type="hidden" name="foodQuantities" value="0" id="food-<%= food.getFoodID() %>-hidden">
                                <input type="hidden" name="foodPrice-<%= food.getFoodID() %>" value="<%= food.getPrice() %>">
                            </div>
                        </div>
                    <% } %>
                    </div>
                <% } else { %>
                    <div class="empty-state">
                        <i class="fas fa-utensils"></i>
                        <p>Hiện tại chưa có đồ ăn nào</p>
                    </div>
                <% } %>
            </div>
            
            <!-- Summary Section -->
            <div class="summary-section">
                <div class="summary-title">
                    <i class="fas fa-receipt"></i>
                    Tổng Kết Đơn Hàng
                </div>
                <div class="summary-row">
                    <span class="summary-label">Tiền vé</span>
                    <span class="summary-value"><%= String.format("%,.0f đ", bookingSession.getTicketSubtotal()) %></span>
                </div>
                <div class="summary-row">
                    <span class="summary-label">Tiền đồ ăn</span>
                    <span class="summary-value" id="foodTotal">0 đ</span>
                </div>
                <div class="summary-row">
                    <span class="summary-label">Tổng thanh toán</span>
                    <span class="summary-value" id="grandTotal"><%= String.format("%,.0f đ", bookingSession.getTicketSubtotal()) %></span>
                </div>
            </div>
            
            <!-- Action Buttons -->
            <div class="action-buttons">
                <button type="submit" name="action" value="skip" class="btn-custom btn-skip">
                    <i class="fas fa-forward"></i> Bỏ Qua
                </button>
                <button type="button" class="btn-custom btn-reset" onclick="resetFood()">
                    <i class="fas fa-redo"></i> Đặt Lại
                </button>
                <button type="submit" name="action" value="confirm" class="btn-custom btn-confirm">
                    Tiếp Tục <i class="fas fa-arrow-right"></i>
                </button>
            </div>
        </form>
    </div>
    
    <script>
        const ticketTotal = <%= bookingSession.getTicketSubtotal() %>;
        
        // Tab Switching
        function switchTab(tabName, element) {
            // Hide all tab contents
            document.getElementById('combos-content').style.display = 'none';
            document.getElementById('foods-content').style.display = 'none';
            
            // Remove active class from all tabs
            document.querySelectorAll('.custom-tab').forEach(tab => {
                tab.classList.remove('active');
            });
            
            // Show selected tab content
            document.getElementById(tabName + '-content').style.display = 'block';
            
            // Add active class to clicked tab
            element.classList.add('active');
        }
        
        // Quantity Controls
        function increaseQuantity(id) {
            const input = document.getElementById(id);
            const currentValue = parseInt(input.value) || 0;
            
            if (currentValue < 10) {
                input.value = currentValue + 1;
                updateButtonStates(id);
                updateTotal();
            }
        }
        
        function decreaseQuantity(id) {
            const input = document.getElementById(id);
            const currentValue = parseInt(input.value) || 0;
            
            if (currentValue > 0) {
                input.value = currentValue - 1;
                updateButtonStates(id);
                updateTotal();
            }
        }
        
        function updateButtonStates(id) {
            const input = document.getElementById(id);
            const value = parseInt(input.value) || 0;
            const decBtn = document.getElementById('btn-dec-' + id);
            const incBtn = document.getElementById('btn-inc-' + id);
            
            // Disable/enable decrease button
            if (value <= 0) {
                decBtn.disabled = true;
            } else {
                decBtn.disabled = false;
            }
            
            // Disable/enable increase button
            if (value >= 10) {
                incBtn.disabled = true;
            } else {
                incBtn.disabled = false;
            }
        }
        
        function updateTotal() {
            let foodTotal = 0;
            
            // Calculate combo total
            document.querySelectorAll('[id^="combo-"]').forEach(input => {
                if (!input.id.includes('-hidden') && input.type === 'number') {
                    const quantity = parseInt(input.value) || 0;
                    const comboID = input.id.replace('combo-', '');
                    const priceElement = document.querySelector('[name="comboPrice-' + comboID + '"]');
                    
                    if (priceElement) {
                        const price = parseFloat(priceElement.value);
                        foodTotal += quantity * price;
                        
                        // Update hidden input
                        const hiddenInput = document.getElementById(input.id + '-hidden');
                        if (hiddenInput) {
                            hiddenInput.value = quantity;
                        }
                    }
                }
            });
            
            // Calculate food total
            document.querySelectorAll('[id^="food-"]').forEach(input => {
                if (!input.id.includes('-hidden') && input.type === 'number') {
                    const quantity = parseInt(input.value) || 0;
                    const foodID = input.id.replace('food-', '');
                    const priceElement = document.querySelector('[name="foodPrice-' + foodID + '"]');
                    
                    if (priceElement) {
                        const price = parseFloat(priceElement.value);
                        foodTotal += quantity * price;
                        
                        // Update hidden input
                        const hiddenInput = document.getElementById(input.id + '-hidden');
                        if (hiddenInput) {
                            hiddenInput.value = quantity;
                        }
                    }
                }
            });
            
            // Update display
            document.getElementById('foodTotal').textContent = foodTotal.toLocaleString('vi-VN') + ' đ';
            const grandTotal = ticketTotal + foodTotal;
            document.getElementById('grandTotal').textContent = grandTotal.toLocaleString('vi-VN') + ' đ';
        }
        
        function resetFood() {
            document.querySelectorAll('.quantity-input').forEach(input => {
                input.value = 0;
                updateButtonStates(input.id);
            });
            updateTotal();
        }
        
        // Countdown timer
        let timeLeft = <%= request.getAttribute("remainingSeconds") %>;
        
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
        
        // Initialize
        document.addEventListener('DOMContentLoaded', function() {
            // Update countdown immediately
            updateCountdown();
            
            // Then update every second
            setInterval(updateCountdown, 1000);
            
            // Initialize all button states
            document.querySelectorAll('.quantity-input').forEach(input => {
                updateButtonStates(input.id);
            });
        });
    </script>
</body>
</html>

