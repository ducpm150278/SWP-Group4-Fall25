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
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
        }
        
        .booking-container {
            max-width: 1000px;
            margin: 30px auto;
            padding: 30px;
            background: white;
            border-radius: 15px;
        }
        
        .food-item {
            border: 2px solid #e0e0e0;
            border-radius: 10px;
            padding: 15px;
            margin-bottom: 15px;
            transition: all 0.3s;
        }
        
        .food-item:hover {
            border-color: #667eea;
            box-shadow: 0 4px 12px rgba(102, 126, 234, 0.2);
        }
        
        .quantity-control {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .quantity-btn {
            width: 35px;
            height: 35px;
            border: 2px solid #667eea;
            background: white;
            color: #667eea;
            border-radius: 50%;
            font-weight: bold;
            cursor: pointer;
        }
        
        .quantity-btn:hover {
            background: #667eea;
            color: white;
        }
        
        .quantity-input {
            width: 60px;
            text-align: center;
            border: 2px solid #e0e0e0;
            border-radius: 5px;
        }
    </style>
</head>
<body>
    <%
        BookingSession bookingSession = (BookingSession) request.getAttribute("bookingSession");
        List<Combo> combos = (List<Combo>) request.getAttribute("combos");
        List<Food> foods = (List<Food>) request.getAttribute("foods");
    %>
    
    <div class="booking-container">
        <div class="text-center mb-4">
            <h2><i class="fas fa-utensils"></i> Chọn Đồ Ăn & Thức Uống</h2>
            <p class="text-muted">Bạn có thể bỏ qua bước này</p>
        </div>
        
        <!-- Timer -->
        <div class="alert alert-warning text-center">
            <i class="fas fa-clock"></i> Thời gian còn lại: <span id="countdown">00:00</span>
        </div>
        
        <form method="post" action="${pageContext.request.contextPath}/booking/select-food" id="foodForm">
            <!-- Nav tabs -->
            <ul class="nav nav-tabs mb-4" role="tablist">
                <li class="nav-item">
                    <a class="nav-link active" data-bs-toggle="tab" href="#combos">
                        <i class="fas fa-box"></i> Combo
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" data-bs-toggle="tab" href="#foods">
                        <i class="fas fa-hamburger"></i> Đồ Ăn Riêng
                    </a>
                </li>
            </ul>
            
            <!-- Tab content -->
            <div class="tab-content">
                <!-- Combos -->
                <div id="combos" class="tab-pane fade show active">
                    <% if (combos != null && !combos.isEmpty()) {
                        for (Combo combo : combos) { %>
                        <div class="food-item">
                            <div class="row align-items-center">
                                <div class="col-md-6">
                                    <h5><%= combo.getComboName() %></h5>
                                    <p class="text-muted"><%= combo.getDescription() %></p>
                                    <% if (combo.getDiscountPrice() != null) { %>
                                        <span class="text-decoration-line-through text-muted">
                                            <%= String.format("%,.0f VNĐ", combo.getTotalPrice()) %>
                                        </span>
                                        <strong class="text-danger ms-2">
                                            <%= String.format("%,.0f VNĐ", combo.getDiscountPrice()) %>
                                        </strong>
                                    <% } else { %>
                                        <strong><%= String.format("%,.0f VNĐ", combo.getTotalPrice()) %></strong>
                                    <% } %>
                                </div>
                                <div class="col-md-6 text-end">
                                    <div class="quantity-control d-inline-flex">
                                        <button type="button" class="quantity-btn" onclick="decreaseQuantity('combo-<%= combo.getComboID() %>')">-</button>
                                        <input type="number" class="quantity-input" id="combo-<%= combo.getComboID() %>" 
                                               name="combo-<%= combo.getComboID() %>" value="0" min="0" max="10"
                                               onchange="updateTotal()">
                                        <button type="button" class="quantity-btn" onclick="increaseQuantity('combo-<%= combo.getComboID() %>')">+</button>
                                    </div>
                                    <input type="hidden" name="comboIDs" value="<%= combo.getComboID() %>">
                                    <input type="hidden" name="comboQuantities" value="0" id="combo-<%= combo.getComboID() %>-hidden">
                                    <input type="hidden" name="comboPrice-<%= combo.getComboID() %>" 
                                           value="<%= combo.getDiscountPrice() != null ? combo.getDiscountPrice() : combo.getTotalPrice() %>">
                                </div>
                            </div>
                        </div>
                    <% }
                    } else { %>
                        <p class="text-center text-muted">Không có combo nào</p>
                    <% } %>
                </div>
                
                <!-- Individual Foods -->
                <div id="foods" class="tab-pane fade">
                    <% if (foods != null && !foods.isEmpty()) {
                        for (Food food : foods) { %>
                        <div class="food-item">
                            <div class="row align-items-center">
                                <div class="col-md-6">
                                    <h5><%= food.getFoodName() %></h5>
                                    <p class="text-muted"><%= food.getDescription() %></p>
                                    <strong><%= String.format("%,.0f VNĐ", food.getPrice()) %></strong>
                                </div>
                                <div class="col-md-6 text-end">
                                    <div class="quantity-control d-inline-flex">
                                        <button type="button" class="quantity-btn" onclick="decreaseQuantity('food-<%= food.getFoodID() %>')">-</button>
                                        <input type="number" class="quantity-input" id="food-<%= food.getFoodID() %>" 
                                               name="food-<%= food.getFoodID() %>" value="0" min="0" max="10"
                                               onchange="updateTotal()">
                                        <button type="button" class="quantity-btn" onclick="increaseQuantity('food-<%= food.getFoodID() %>')">+</button>
                                    </div>
                                    <input type="hidden" name="foodIDs" value="<%= food.getFoodID() %>">
                                    <input type="hidden" name="foodQuantities" value="0" id="food-<%= food.getFoodID() %>-hidden">
                                    <input type="hidden" name="foodPrice-<%= food.getFoodID() %>" value="<%= food.getPrice() %>">
                                </div>
                            </div>
                        </div>
                    <% }
                    } else { %>
                        <p class="text-center text-muted">Không có đồ ăn nào</p>
                    <% } %>
                </div>
            </div>
            
            <!-- Total -->
            <div class="text-center my-4">
                <h4>Tổng tiền đồ ăn: <span id="foodTotal">0 VNĐ</span></h4>
                <h5>Tổng vé: <%= String.format("%,.0f VNĐ", bookingSession.getTicketSubtotal()) %></h5>
                <h3 class="text-primary">Tổng cộng: <span id="grandTotal"><%= String.format("%,.0f VNĐ", bookingSession.getTicketSubtotal()) %></span></h3>
            </div>
            
            <!-- Buttons -->
            <div class="d-flex gap-3 justify-content-center">
                <button type="submit" name="action" value="skip" class="btn btn-secondary">
                    <i class="fas fa-forward"></i> Bỏ Qua
                </button>
                <button type="button" class="btn btn-outline-primary" onclick="resetFood()">
                    <i class="fas fa-redo"></i> Đặt Lại
                </button>
                <button type="submit" name="action" value="confirm" class="btn btn-primary btn-lg">
                    <i class="fas fa-arrow-right"></i> Xác Nhận
                </button>
            </div>
        </form>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        const ticketTotal = <%= bookingSession.getTicketSubtotal() %>;
        
        function increaseQuantity(id) {
            const input = document.getElementById(id);
            if (parseInt(input.value) < 10) {
                input.value = parseInt(input.value) + 1;
                updateTotal();
            }
        }
        
        function decreaseQuantity(id) {
            const input = document.getElementById(id);
            if (parseInt(input.value) > 0) {
                input.value = parseInt(input.value) - 1;
                updateTotal();
            }
        }
        
        function updateTotal() {
            let foodTotal = 0;
            
            // Calculate combo total
            document.querySelectorAll('[id^="combo-"]').forEach(input => {
                if (!input.id.includes('-hidden')) {
                    const quantity = parseInt(input.value) || 0;
                    const comboID = input.id.replace('combo-', '');
                    const price = parseFloat(document.querySelector('[name="comboPrice-' + comboID + '"]').value);
                    foodTotal += quantity * price;
                    
                    // Update hidden input
                    document.getElementById(input.id + '-hidden').value = quantity;
                }
            });
            
            // Calculate food total
            document.querySelectorAll('[id^="food-"]').forEach(input => {
                if (!input.id.includes('-hidden')) {
                    const quantity = parseInt(input.value) || 0;
                    const foodID = input.id.replace('food-', '');
                    const price = parseFloat(document.querySelector('[name="foodPrice-' + foodID + '"]').value);
                    foodTotal += quantity * price;
                    
                    // Update hidden input
                    document.getElementById(input.id + '-hidden').value = quantity;
                }
            });
            
            document.getElementById('foodTotal').textContent = foodTotal.toLocaleString('vi-VN') + ' VNĐ';
            const grandTotal = ticketTotal + foodTotal;
            document.getElementById('grandTotal').textContent = grandTotal.toLocaleString('vi-VN') + ' VNĐ';
        }
        
        function resetFood() {
            document.querySelectorAll('.quantity-input').forEach(input => {
                input.value = 0;
            });
            updateTotal();
        }
        
        // Countdown timer
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

