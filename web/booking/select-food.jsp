<!--
    File: select-food.jsp
    Mô tả: Trang chọn đồ ăn và thức uống
    Chức năng:
    - Hiển thị danh sách combo tiết kiệm
    - Hiển thị danh sách đồ ăn và nước riêng lẻ
    - Cho phép chọn số lượng (0-10) cho mỗi món
    - Tự động tính tổng tiền (vé + đồ ăn)
    - Countdown timer giữ chỗ
    - Có thể bỏ qua bước này
-->
<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@page import="java.util.List" %>
        <%@page import="entity.Combo" %>
            <%@page import="entity.Food" %>
                <%@page import="entity.BookingSession" %>
                    <!DOCTYPE html>
                    <html lang="vi">

                    <head>
                        <!-- Thiết lập encoding và responsive -->
                        <meta charset="UTF-8">
                        <meta name="viewport" content="width=device-width, initial-scale=1.0">
                        <title>Chọn Đồ Ăn - Cinema Booking</title>

                        <!-- Import CSS frameworks và custom styles -->
                        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
                            rel="stylesheet">
                        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css"
                            rel="stylesheet">
                        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/select-food.css">
                    </head>

                    <body>
                        <!--
        Lấy dữ liệu từ request attributes:
        - bookingSession: Phiên đặt vé hiện tại (đã có thông tin vé)
        - combos: Danh sách combo có sẵn
        - foods: Danh sách đồ ăn riêng lẻ
    -->
                        <% Book ingSession bookingSession=(BookingSession) request.getAttribute("bookingSession");
                            List<Combo> combos = (List<Combo>) request.getAttribute("combos");
                                List<Food> foods = (List<Food>) request.getAttribute("foods");
                                        %>

                                        <!-- Progress Steps - Thanh tiến trình đặt vé -->
                                        <div class="progress-container">
                                            <div class="progress-steps">
                                                <!-- Bước 1: Chọn suất chiếu (đã hoàn thành) -->
                                                <div class="step completed"
                                                    onclick="window.location.href='${pageContext.request.contextPath}/booking/select-screening'"
                                                    title="Quay lại chọn suất chiếu">
                                                    <div class="step-circle"><i class="fas fa-film"></i></div>
                                                    <span class="step-label">Chọn Suất</span>
                                                </div>
                                                <!-- Bước 2: Chọn ghế (đã hoàn thành) -->
                                                <div class="step completed"
                                                    onclick="window.location.href='${pageContext.request.contextPath}/booking/select-seats'"
                                                    title="Quay lại chọn ghế">
                                                    <div class="step-circle"><i class="fas fa-couch"></i></div>
                                                    <span class="step-label">Chọn Ghế</span>
                                                </div>
                                                <!-- Bước 3: Chọn đồ ăn (đang thực hiện) -->
                                                <div class="step active">
                                                    <div class="step-circle"><i class="fas fa-utensils"></i></div>
                                                    <span class="step-label">Đồ Ăn</span>
                                                </div>
                                                <!-- Bước 4: Thanh toán (chưa thực hiện) -->
                                                <div class="step">
                                                    <div class="step-circle"><i class="fas fa-credit-card"></i></div>
                                                    <span class="step-label">Thanh Toán</span>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- Main Container -->
                                        <div class="main-container">
                                            <!-- Page Header -->
                                            <div class="page-header">
                                                <h1><i class="fas fa-utensils"></i> Chọn Đồ Ăn & Thức Uống</h1>
                                                <p>Thêm món ăn yêu thích để trải nghiệm phim tốt hơn (có thể bỏ qua)</p>
                                            </div>

                                            <!-- Compact Timer - Đếm ngược thời gian giữ chỗ -->
                                            <div class="timer-compact" id="timerCompact">
                                                <div class="timer-compact-icon">
                                                    <i class="fas fa-clock"></i>
                                                </div>
                                                <div class="timer-compact-value" id="countdown">00:00</div>
                                            </div>

                                            <!-- Form chọn đồ ăn -->
                                            <form method="post"
                                                action="${pageContext.request.contextPath}/booking/select-food"
                                                id="foodForm">
                                                <!-- Combos Section - Phần hiển thị các combo tiết kiệm -->
                                                <div class="section-header" style="margin-bottom: 20px;">
                                                    <h2
                                                        style="font-size: 22px; font-weight: 700; color: #fff; display: flex; align-items: center; gap: 10px;">
                                                        <i class="fas fa-box" style="color: #e50914;"></i> Combo Tiết
                                                        Kiệm
                                                    </h2>
                                                    <p style="color: #8b92a7; font-size: 14px; margin-top: 5px;">Gói
                                                        combo với giá ưu đãi</p>
                                                </div>

                                                <div id="combos-content" class="tab-content-area">
                                                    <% if (combos !=null && !combos.isEmpty()) { %>
                                                        <div class="food-grid">
                                                            <!-- Lặp qua từng combo để hiển thị -->
                                                            <% for (Combo combo : combos) { %>
                                                                <div class="food-card">
                                                                    <div class="food-card-body">
                                                                        <!-- Tên combo -->
                                                                        <div class="food-name">
                                                                            <%= combo.getComboName() %>
                                                                        </div>
                                                                        <!-- Mô tả combo -->
                                                                        <div class="food-description">
                                                                            <%= combo.getDescription() %>
                                                                        </div>

                                                                        <!-- Giá combo (hiển thị giá gốc và giá giảm nếu có) -->
                                                                        <div class="food-price">
                                                                            <% if (combo.getDiscountPrice() !=null) { %>
                                                                                <span class="price-original">
                                                                                    <%= String.format("%,.0f đ",
                                                                                        combo.getTotalPrice()) %>
                                                                                </span>
                                                                                <span class="price-current">
                                                                                    <%= String.format("%,.0f đ",
                                                                                        combo.getDiscountPrice()) %>
                                                                                </span>
                                                                                <span class="price-badge">
                                                                                    -<%= Math.round((1 -
                                                                                        combo.getDiscountPrice().doubleValue()
                                                                                        /
                                                                                        combo.getTotalPrice().doubleValue())
                                                                                        * 100) %>%
                                                                                </span>
                                                                                <% } else { %>
                                                                                    <span class="price-current">
                                                                                        <%= String.format("%,.0f đ",
                                                                                            combo.getTotalPrice()) %>
                                                                                    </span>
                                                                                    <% } %>
                                                                        </div>

                                                                        <!-- Phần chọn số lượng combo -->
                                                                        <div class="quantity-section">
                                                                            <span class="quantity-label">Số lượng</span>
                                                                            <div class="quantity-control">
                                                                                <!-- Nút giảm số lượng -->
                                                                                <button type="button"
                                                                                    class="quantity-btn"
                                                                                    onclick="decreaseQuantity('combo-<%= combo.getComboID() %>')"
                                                                                    id="btn-dec-combo-<%= combo.getComboID() %>">
                                                                                    <i class="fas fa-minus"></i>
                                                                                </button>
                                                                                <!-- Input hiển thị số lượng (readonly, chỉ thay đổi qua nút +/-) -->
                                                                                <input type="number"
                                                                                    class="quantity-input"
                                                                                    id="combo-<%= combo.getComboID() %>"
                                                                                    name="combo-<%= combo.getComboID() %>"
                                                                                    value="0" min="0" max="10" readonly
                                                                                    onchange="updateTotal()">
                                                                                <!-- Nút tăng số lượng -->
                                                                                <button type="button"
                                                                                    class="quantity-btn"
                                                                                    onclick="increaseQuantity('combo-<%= combo.getComboID() %>')"
                                                                                    id="btn-inc-combo-<%= combo.getComboID() %>">
                                                                                    <i class="fas fa-plus"></i>
                                                                                </button>
                                                                            </div>
                                                                        </div>

                                                                        <!-- Hidden inputs để submit về server -->
                                                                        <input type="hidden" name="comboIDs"
                                                                            value="<%= combo.getComboID() %>">
                                                                        <input type="hidden" name="comboQuantities"
                                                                            value="0"
                                                                            id="combo-<%= combo.getComboID() %>-hidden">
                                                                        <input type="hidden"
                                                                            name="comboPrice-<%= combo.getComboID() %>"
                                                                            value="<%= combo.getDiscountPrice() != null ? combo.getDiscountPrice() : combo.getTotalPrice() %>">
                                                                    </div>
                                                                </div>
                                                                <% } %>
                                                        </div>
                                                        <% } else { %>
                                                            <!-- Hiển thị khi không có combo nào -->
                                                            <div class="empty-state">
                                                                <i class="fas fa-box-open"></i>
                                                                <p>Hiện tại chưa có combo nào</p>
                                                            </div>
                                                            <% } %>
                                                </div>

                                                <!-- Individual Foods Section - Phần đồ ăn riêng lẻ -->
                                                <div class="section-header" style="margin: 40px 0 20px 0;">
                                                    <h2
                                                        style="font-size: 22px; font-weight: 700; color: #fff; display: flex; align-items: center; gap: 10px;">
                                                        <i class="fas fa-hamburger" style="color: #e50914;"></i> Đồ Ăn &
                                                        Nước Uống Riêng Lẻ
                                                    </h2>
                                                    <p style="color: #8b92a7; font-size: 14px; margin-top: 5px;">Tự do
                                                        lựa chọn món yêu thích</p>
                                                </div>

                                                <div id="foods-content" class="tab-content-area">
                                                    <% if (foods !=null && !foods.isEmpty()) { %>
                                                        <div class="food-grid">
                                                            <!-- Lặp qua từng món ăn để hiển thị -->
                                                            <% for (Food food : foods) { %>
                                                                <div class="food-card">
                                                                    <div class="food-card-body">
                                                                        <!-- Tên món ăn -->
                                                                        <div class="food-name">
                                                                            <%= food.getFoodName() %>
                                                                        </div>
                                                                        <!-- Mô tả món ăn -->
                                                                        <div class="food-description">
                                                                            <%= food.getDescription() %>
                                                                        </div>

                                                                        <!-- Giá món ăn -->
                                                                        <div class="food-price">
                                                                            <span class="price-current">
                                                                                <%= String.format("%,.0f đ",
                                                                                    food.getPrice()) %>
                                                                            </span>
                                                                        </div>

                                                                        <!-- Phần chọn số lượng -->
                                                                        <div class="quantity-section">
                                                                            <span class="quantity-label">Số lượng</span>
                                                                            <div class="quantity-control">
                                                                                <button type="button"
                                                                                    class="quantity-btn"
                                                                                    onclick="decreaseQuantity('food-<%= food.getFoodID() %>')"
                                                                                    id="btn-dec-food-<%= food.getFoodID() %>">
                                                                                    <i class="fas fa-minus"></i>
                                                                                </button>
                                                                                <input type="number"
                                                                                    class="quantity-input"
                                                                                    id="food-<%= food.getFoodID() %>"
                                                                                    name="food-<%= food.getFoodID() %>"
                                                                                    value="0" min="0" max="10" readonly
                                                                                    onchange="updateTotal()">
                                                                                <button type=" button"
                                                                                    class="quantity-btn"
                                                                                    onclick="increaseQuantity('food-<%= food.getFoodID() %>')"
                                                                                    id="btn-inc-food-<%= food.getFoodID() %>">
                                                                                    <i class="fas fa-plus"></i>
                                                                                </button>
                                                                            </div>
                                                                        </div>

                                                                        <!-- Hidden inputs để submit về server -->
                                                                        <input type="hidden" name="foodIDs"
                                                                            value="<%= food.getFoodID() %>">
                                                                        <input type="hidden" name="foodQuantities"
                                                                            value="0"
                                                                            id="food-<%= food.getFoodID() %>-hidden">
                                                                        <input type="hidden"
                                                                            name="foodPrice-<%= food.getFoodID() %>"
                                                                            value="<%= food.getPrice() %>">
                                                                    </div>
                                                                </div>
                                                                <% } %>
                                                        </div>
                                                        <% } else { %>
                                                            <!-- Hiển thị khi không có món ăn nào -->
                                                            <div class="empty-state">
                                                                <i class="fas fa-utensils"></i>
                                                                <p>Hiện tại chưa có đồ ăn nào</p>
                                                            </div>
                                                            <% } %>
                                                </div>

                                                <!-- Summary Section - Tổng kết đơn hàng -->
                                                <div class="summary-section">
                                                    <div class="summary-title">
                                                        <i class="fas fa-receipt"></i>
                                                        Tổng Kết Đơn Hàng
                                                    </div>
                                                    <!-- Tiền vé đã chọn từ bước trước -->
                                                    <div class="summary-row">
                                                        <span class="summary-label">Tiền vé</span>
                                                        <span class="summary-value">
                                                            <%= String.format("%,.0f đ",
                                                                bookingSession.getTicketSubtotal()) %>
                                                        </span>
                                                    </div>
                                                    <!-- Tiền đồ ăn (cập nhật real-time bằng JavaScript) -->
                                                    <div class="summary-row">
                                                        <span class="summary-label">Tiền đồ ăn</span>
                                                        <span class="summary-value" id="foodTotal">0 đ</span>
                                                    </div>
                                                    <!-- Tổng thanh toán -->
                                                    <div class="summary-row">
                                                        <span class="summary-label">Tổng thanh toán</span>
                                                        <span class="summary-value" id="grandTotal">
                                                            <%= String.format("%,.0f đ",
                                                                bookingSession.getTicketSubtotal()) %>
                                                        </span>
                                                    </div>
                                                </div>

                                                <!-- Action Buttons -->
                                                <div class="action-buttons">
                                                    <!-- Nút bỏ qua (không chọn đồ ăn) -->
                                                    <button type="submit" name="action" value="skip"
                                                        class="btn-custom btn-skip">
                                                        <i class="fas fa-forward"></i> Bỏ Qua
                                                    </button>
                                                    <!-- Nút đặt lại về 0 -->
                                                    <button type="button" class="btn-custom btn-reset"
                                                        onclick="resetFood()">
                                                        <i class="fas fa-redo"></i> Đặt Lại
                                                    </button>
                                                    <!-- Nút tiếp tục sang trang thanh toán -->
                                                    <button type="submit" name="action" value="confirm"
                                                        class="btn-custom btn-confirm">
                                                        Tiếp Tục <i class="fas fa-arrow-right"></i>
                                                    </button>
                                                </div>
                                            </form>
                                        </div>

                                        <!-- JavaScript Section -->
                                        <script>
                                            // ===== CONSTANTS =====
                                            const ticketTotal = <%= bookingSession.getTicketSubtotal() %>;  // Tổng tiền vé

                                            // ===== QUANTITY CONTROLS =====
                                            /**
                                             * Tăng số lượng món ăn/combo
                                             * @param {string} id - ID của input (vd: 'combo-1', 'food-5')
                                             */
                                            function increaseQuantity(id) {
                                                const input = document.getElementById(id);
                                                const currentValue = parseInt(input.value) || 0;

                                                if (currentValue < 10) {  // Giới hạn tối đa 10
                                                    input.value = currentValue + 1;
                                                    updateButtonStates(id);
                                                    updateTotal();
                                                }
                                            }

                                            /**
                                             * Giảm số lượng món ăn/combo
                                             * @param {string} id - ID của input
                                             */
                                            function decreaseQuantity(id) {
                                                const input = document.getElementById(id);
                                                const currentValue = parseInt(input.value) || 0;

                                                if (currentValue > 0) {  // Không cho giảm xuống âm
                                                    input.value = currentValue - 1;
                                                    updateButtonStates(id);
                                                    updateTotal();
                                                }
                                            }

                                            /**
                                             * Cập nhật trạng thái disabled/enabled cho nút +/-
                                             * @param {string} id - ID của input
                                             */
                                            function updateButtonStates(id) {
                                                const input = document.getElementById(id);
                                                const value = parseInt(input.value) || 0;
                                                const decBtn = document.getElementById('btn-dec-' + id);
                                                const incBtn = document.getElementById('btn-inc-' + id);

                                                // Disable nút giảm khi số lượng = 0
                                                decBtn.disabled = value <= 0;

                                                // Disable nút tăng khi số lượng = 10
                                                incBtn.disabled = value >= 10;
                                            }

                                            // ===== TOTAL CALCULATION =====
                                            /**
                                             * Tính tổng tiền đồ ăn và cập nhật grand total
                                             * Được gọi mỗi khi số lượng thay đổi
                                             */
                                            function updateTotal() {
                                                let foodTotal = 0;

                                                // Tính tổng tiền combo
                                                document.querySelectorAll('[id^="combo-"]').forEach(input => {
                                                    if (!input.id.includes('-hidden') && input.type === 'number') {
                                                        const quantity = parseInt(input.value) || 0;
                                                        const comboID = input.id.replace('combo-', '');
                                                        const priceElement = document.querySelector('[name="comboPrice-' + comboID + '"]');

                                                        if (priceElement) {
                                                            const price = parseFloat(priceElement.value);
                                                            foodTotal += quantity * price;

                                                            // Cập nhật hidden input để submit về server
                                                            const hiddenInput = document.getElementById(input.id + '-hidden');
                                                            if (hiddenInput) {
                                                                hiddenInput.value = quantity;
                                                            }
                                                        }
                                                    }
                                                });

                                                // Tính tổng tiền đồ ăn riêng lẻ
                                                document.querySelectorAll('[id^="food-"]').forEach(input => {
                                                    if (!input.id.includes('-hidden') && input.type === 'number') {
                                                        const quantity = parseInt(input.value) || 0;
                                                        const foodID = input.id.replace('food-', '');
                                                        const priceElement = document.querySelector('[name="foodPrice-' + foodID + '"]');

                                                        if (priceElement) {
                                                            const price = parseFloat(priceElement.value);
                                                            foodTotal += quantity * price;

                                                            // Cập nhật hidden input
                                                            const hiddenInput = document.getElementById(input.id + '-hidden');
                                                            if (hiddenInput) {
                                                                hiddenInput.value = quantity;
                                                            }
                                                        }
                                                    }
                                                });

                                                // Cập nhật hiển thị tổng tiền
                                                document.getElementById('foodTotal').textContent = foodTotal.toLocaleString('vi-VN') + ' đ';
                                                const grandTotal = ticketTotal + foodTotal;
                                                document.getElementById('grandTotal').textContent = grandTotal.toLocaleString('vi-VN') + ' đ';
                                            }

                                            /**
                                             * Reset tất cả số lượng về 0
                                             */
                                            function resetFood() {
                                                document.querySelectorAll('.quantity-input').forEach(input => {
                                                    input.value = 0;
                                                    updateButtonStates(input.id);
                                                });
                                                updateTotal();
                                            }

                                            // ===== COUNTDOWN TIMER =====
                                            let timeLeft = <%= request.getAttribute("remainingSeconds") %>;

                                            /**
                                             * Cập nhật đồng hồ đếm ngược
                                             */
                                            function updateCountdown() {
                                                const minutes = Math.floor(timeLeft / 60);
                                                const seconds = timeLeft % 60;
                                                const countdownElement = document.getElementById('countdown');
                                                const timerCompact = document.getElementById('timerCompact');

                                                // Hiển thị thời gian MM:SS
                                                countdownElement.textContent =
                                                    String(minutes).padStart(2, '0') + ':' + String(seconds).padStart(2, '0');

                                                // Đổi màu cảnh báo theo thời gian còn lại
                                                if (timeLeft <= 60) {
                                                    timerCompact.className = 'timer-compact critical';  // Đỏ khi <= 1 phút
                                                } else if (timeLeft <= 180) {
                                                    timerCompact.className = 'timer-compact warning';  // Vàng khi <= 3 phút
                                                }

                                                // Hết thời gian -> chuyển về trang chọn suất
                                                if (timeLeft <= 0) {
                                                    alert('Hết thời gian giữ chỗ! Bạn sẽ được chuyển về trang chọn suất chiếu.');
                                                    window.location.href = '${pageContext.request.contextPath}/booking/select-screening';
                                                }

                                                timeLeft--;
                                            }

                                            // ===== INITIALIZATION =====
                                            /**
                                             * Khởi tạo trang khi DOM đã load
                                             */
                                            document.addEventListener('DOMContentLoaded', function () {
                                                // Cập nhật countdown ngay lập tức
                                                updateCountdown();

                                                // Cập nhật countdown mỗi giây
                                                setInterval(updateCountdown, 1000);

                                                // Khởi tạo trạng thái nút cho tất cả input
                                                document.querySelectorAll('.quantity-input').forEach(input => {
                                                    updateButtonStates(input.id);
                                                });
                                            });
                                        </script>
                    </body>

                    </html>