<!--
    File: payment.jsp
    Mô tả: Trang thanh toán - Bước cuối cùng trong flow đặt vé
    Chức năng:
    - Hiển thị tổng kết đơn hàng (vé + đồ ăn)
    - Cho phép nhập mã giảm giá
    - Chọn phương thức thanh toán (VNPay)
    - Countdown timer giữ chỗ
    - Submit form để thanh toán
-->
<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@page import="entity.BookingSession" %>
        <%@page import="java.util.List" %>
            <%@page import="java.util.Map" %>
                <!DOCTYPE html>
                <html lang="vi">

                <head>
                    <!-- Thiết lập encoding và responsive -->
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Thanh Toán - Cinema Booking</title>

                    <!-- Import CSS frameworks và custom styles -->
                    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
                        rel="stylesheet">
                    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css"
                        rel="stylesheet">
                    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/payment.css">
                </head>

                <body>
                    <!--
        Lấy thông tin booking session từ request attribute
        BookingSession chứa tất cả thông tin đã chọn: phim, rạp, ghế, đồ ăn, giá
    -->
                    <% BookingSession bookingSession=(BookingSession) request.getAttribute("bookingSession"); %>

                        <!-- Progress Steps - Thanh tiến trình 4 bước đặt vé -->
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
                                <!-- Bước 3: Chọn đồ ăn (đã hoàn thành) -->
                                <div class="step completed"
                                    onclick="window.location.href='${pageContext.request.contextPath}/booking/select-food'"
                                    title="Quay lại chọn đồ ăn">
                                    <div class="step-circle"><i class="fas fa-utensils"></i></div>
                                    <span class="step-label">Đồ Ăn</span>
                                </div>
                                <!-- Bước 4: Thanh toán (đang thực hiện) -->
                                <div class="step active">
                                    <div class="step-circle"><i class="fas fa-credit-card"></i></div>
                                    <span class="step-label">Thanh Toán</span>
                                </div>
                            </div>
                        </div>

                        <!-- Main Container -->
                        <div class="main-container">
                            <!-- Page Header -->
                            <div class="page-header">
                                <h1><i class="fas fa-credit-card"></i> Thanh Toán</h1>
                                <p>Hoàn tất thanh toán để xác nhận đặt vé</p>
                            </div>

                            <!-- Compact Timer - Đếm ngược thời gian giữ chỗ -->
                            <div class="timer-compact" id="timerCompact">
                                <div class="timer-compact-icon">
                                    <i class="fas fa-clock"></i>
                                </div>
                                <div class="timer-compact-value" id="countdown">00:00</div>
                            </div>

                            <!-- Hiển thị thông báo lỗi nếu có -->
                            <% if (request.getAttribute("error") !=null) { %>
                                <div class="alert alert-danger">
                                    <%= request.getAttribute("error") %>
                                </div>
                                <% } %>

                                    <!-- Hiển thị thông báo thành công nếu có -->
                                    <% if (request.getAttribute("success") !=null) { %>
                                        <div class="alert alert-success">
                                            <%= request.getAttribute("success") %>
                                        </div>
                                        <% } %>

                                            <!-- Order Summary - Tổng kết đơn hàng -->
                                            <div class="summary-box">
                                                <h4><i class="fas fa-receipt"></i> Chi Tiết Đơn Hàng</h4>

                                                <!-- Thông tin phim đã chọn -->
                                                <div class="price-row">
                                                    <span><i class="fas fa-film"></i> Phim:</span>
                                                    <strong>
                                                        <%= bookingSession.getMovieTitle() %>
                                                    </strong>
                                                </div>

                                                <!-- Thông tin rạp và phòng chiếu -->
                                                <div class="price-row">
                                                    <span><i class="fas fa-building"></i> Rạp:</span>
                                                    <span>
                                                        <%= bookingSession.getCinemaName() %> - <%=
                                                                bookingSession.getRoomName() %>
                                                    </span>
                                                </div>

                                                <!-- Danh sách ghế đã chọn -->
                                                <div class="price-row">
                                                    <span><i class="fas fa-couch"></i> Ghế:</span>
                                                    <span>
                                                        <%= String.join(", ", bookingSession.getSelectedSeatLabels()) %></span>
            </div>
            
            <!-- Ticket Breakdown - Chi tiết giá vé theo từng ghế -->
            <%
                List<Map<String, Object>> seatDetails = (List<Map<String, Object>>) request.getAttribute("
                                                            seatDetails"); if (seatDetails !=null &&
                                                            !seatDetails.isEmpty()) { %>
                                                            <div class="breakdown-section">
                                                                <div class="breakdown-header">
                                                                    <i class="fas fa-ticket-alt"></i> Chi tiết vé
                                                                </div>
                                                                <!-- Lặp qua từng ghế để hiển thị loại ghế và giá -->
                                                                <% for (Map<String, Object> seat : seatDetails) {
                                                                    String seatLabel = (String) seat.get("label");
                                                                    String seatType = (String) seat.get("type");
                                                                    double price = (Double) seat.get("price");
                                                                    String typeLabel = "Standard".equals(seatType) ?
                                                                    "Thường" :
                                                                    "VIP".equals(seatType) ? "VIP" :
                                                                    "Couple".equals(seatType) ? "Đôi" : seatType;
                                                                    %>
                                                                    <div class="breakdown-item">
                                                                        <span>Ghế <%= seatLabel %> (<%= typeLabel %>
                                                                                    )</span>
                                                                        <span>
                                                                            <%= String.format("%,.0f đ", price) %>
                                                                        </span>
                                                                    </div>
                                                                    <% } %>
                                                                        <div class="breakdown-total">
                                                                            <span>Tổng vé</span>
                                                                            <strong>
                                                                                <%= String.format("%,.0f đ",
                                                                                    bookingSession.getTicketSubtotal())
                                                                                    %>
                                                                            </strong>
                                                                        </div>
                                                            </div>
                                                            <% } %>

                                                                <!-- Food & Combo Breakdown - Chi tiết đồ ăn và combo -->
                                                                <% List<Map<String, Object>> comboDetails = (List
                                                                    <Map<String, Object>>)
                                                                        request.getAttribute("comboDetails");
                                                                        List<Map<String, Object>> foodDetails = (List
                                                                            <Map<String, Object>>)
                                                                                request.getAttribute("foodDetails");
                                                                                boolean hasFood = (comboDetails != null
                                                                                && !comboDetails.isEmpty()) ||
                                                                                (foodDetails != null &&
                                                                                !foodDetails.isEmpty());
                                                                                if (hasFood) {
                                                                                %>
                                                                                <div class="breakdown-section">
                                                                                    <div class="breakdown-header">
                                                                                        <i class="fas fa-utensils"></i>
                                                                                        Chi tiết đồ ăn & nước
                                                                                    </div>
                                                                                    <!-- Hiển thị danh sách combo đã chọn -->
                                                                                    <% if (comboDetails !=null) { for
                                                                                        (Map<String, Object> combo :
                                                                                        comboDetails) {
                                                                                        String name = (String)
                                                                                        combo.get("name");
                                                                                        int quantity = (Integer)
                                                                                        combo.get("quantity");
                                                                                        double price = (Double)
                                                                                        combo.get("price");
                                                                                        double total = (Double)
                                                                                        combo.get("total");
                                                                                        %>
                                                                                        <div class="breakdown-item">
                                                                                            <span>
                                                                                                <%= name %> × <%=
                                                                                                        quantity %>
                                                                                            </span>
                                                                                            <span>
                                                                                                <%= String.format("%,.0f
                                                                                                    đ", total) %>
                                                                                            </span>
                                                                                        </div>
                                                                                        <% }} %>

                                                                                            <!-- Hiển thị danh sách đồ ăn riêng lẻ đã chọn -->
                                                                                            <% if (foodDetails !=null) {
                                                                                                for (Map<String, Object>
                                                                                                food : foodDetails) {
                                                                                                String name = (String)
                                                                                                food.get("name");
                                                                                                int quantity = (Integer)
                                                                                                food.get("quantity");
                                                                                                double price = (Double)
                                                                                                food.get("price");
                                                                                                double total = (Double)
                                                                                                food.get("total");
                                                                                                %>
                                                                                                <div
                                                                                                    class="breakdown-item">
                                                                                                    <span>
                                                                                                        <%= name %> ×
                                                                                                            <%= quantity
                                                                                                                %>
                                                                                                    </span>
                                                                                                    <span>
                                                                                                        <%= String.format("%,.0f
                                                                                                            đ", total)
                                                                                                            %>
                                                                                                    </span>
                                                                                                </div>
                                                                                                <% }} %>

                                                                                                    <div
                                                                                                        class="breakdown-total">
                                                                                                        <span>Tổng đồ
                                                                                                            ăn</span>
                                                                                                        <strong>
                                                                                                            <%= String.format("%,.0f
                                                                                                                đ",
                                                                                                                bookingSession.getFoodSubtotal())
                                                                                                                %>
                                                                                                        </strong>
                                                                                                    </div>
                                                                                </div>
                                                                                <% } %>

                                                                                    <!-- Hiển thị giảm giá nếu có áp dụng mã -->
                                                                                    <% if
                                                                                        (bookingSession.getDiscountAmount()>
                                                                                        0) { %>
                                                                                        <div class="price-row"
                                                                                            style="color: #3fb950;">
                                                                                            <span><i
                                                                                                    class="fas fa-tag"></i>
                                                                                                Giảm giá (<%=
                                                                                                    bookingSession.getDiscountCode()
                                                                                                    %>)</span>
                                                                                            <strong>-<%=
                                                                                                    String.format("%,.0f
                                                                                                    đ",
                                                                                                    bookingSession.getDiscountAmount())
                                                                                                    %></strong>
                                                                                        </div>
                                                                                        <% } %>

                                                                                            <!-- Tổng thanh toán cuối cùng -->
                                                                                            <div
                                                                                                class="price-row total-row">
                                                                                                <span>TỔNG THANH
                                                                                                    TOÁN</span>
                                                                                                <span>
                                                                                                    <%= String.format("%,.0f
                                                                                                        đ",
                                                                                                        bookingSession.getTotalAmount())
                                                                                                        %>
                                                                                                </span>
                                                                                            </div>
                                                </div>

                                                <!-- Payment Form -->
                                                <form method="post"
                                                    action="${pageContext.request.contextPath}/booking/payment"
                                                    id="paymentForm">
                                                    <!-- Discount Code Section - Phần nhập mã giảm giá -->
                                                    <div class="card">
                                                        <div class="card-body">
                                                            <h5><i class="fas fa-ticket-alt"></i> Mã Giảm Giá</h5>
                                                            <div class="input-group">
                                                                <input type="text" class="form-control"
                                                                    name="discountCode" id="discountInput"
                                                                    placeholder="Nhập mã giảm giá (nếu có)"
                                                                    value="<%= bookingSession.getDiscountCode() != null ? bookingSession.getDiscountCode() : "" %>">
                                                                <button type="submit" name="action"
                                                                    value="applyDiscount"
                                                                    class="btn btn-outline-primary">
                                                                    <i class="fas fa-check"></i> Áp Dụng
                                                                </button>
                                                            </div>
                                                            <!-- Hiển thị thông báo khi áp dụng mã thành công -->
                                                            <% if (bookingSession.getDiscountCode() !=null &&
                                                                bookingSession.getDiscountAmount()> 0) { %>
                                                                <div class="discount-success">
                                                                    <i class="fas fa-check-circle"></i>
                                                                    <span>Đã áp dụng mã giảm giá! Bạn tiết kiệm được <%=
                                                                            String.format("%,.0f đ",
                                                                            bookingSession.getDiscountAmount()) %>
                                                                            </span>
                                                                </div>
                                                                <% } %>
                                                        </div>
                                                    </div>

                                                    <!-- Payment Method Section - Chọn phương thức thanh toán -->
                                                    <div class="card">
                                                        <div class="card-body">
                                                            <h5><i class="fas fa-wallet"></i> Phương Thức Thanh Toán
                                                            </h5>
                                                            <p
                                                                style="margin-top: 10px; margin-bottom: 15px; color: #8b949e; font-size: 14px;">
                                                                <i class="fas fa-info-circle"></i> Hiện tại chúng tôi
                                                                chỉ hỗ trợ thanh toán online qua VNPay
                                                            </p>
                                                            <div class="payment-method-grid">
                                                                <!-- VNPay - Phương thức thanh toán duy nhất hiện tại -->
                                                                <label class="payment-option selected">
                                                                    <input type="radio" name="paymentMethod"
                                                                        value="VNPay" checked required>
                                                                    <div class="payment-option-badge">Bắt buộc</div>
                                                                    <div class="payment-option-icon">
                                                                        <i class="fas fa-mobile-alt"></i>
                                                                    </div>
                                                                    <div class="payment-option-name">VNPay</div>
                                                                    <div class="payment-option-desc">
                                                                        Thanh toán qua QR Code<br>
                                                                        <small style="color: #58a6ff;">Hỗ trợ tất cả
                                                                            ngân hàng</small>
                                                                    </div>
                                                                </label>
                                                            </div>

                                                            <!-- Thông báo về bảo mật thanh toán -->
                                                            <div
                                                                style="margin-top: 15px; padding: 12px; background: rgba(88, 166, 255, 0.1); border: 1px solid rgba(88, 166, 255, 0.3); border-radius: 8px;">
                                                                <p style="margin: 0; color: #58a6ff; font-size: 13px;">
                                                                    <i class="fas fa-shield-alt"></i> <strong>An toàn &
                                                                        bảo mật:</strong><br>
                                                                    Giao dịch được mã hóa và bảo vệ bởi VNPay
                                                                </p>
                                                            </div>
                                                        </div>
                                                    </div>

                                                    <!-- Terms & Conditions - Điều khoản sử dụng -->
                                                    <div class="card">
                                                        <div class="card-body">
                                                            <div class="form-check">
                                                                <input type="checkbox" class="form-check-input"
                                                                    id="agreeTerms" name="agreeTerms">
                                                                <label class="form-check-label" for="agreeTerms">
                                                                    Tôi đã đọc và đồng ý với <a href="#"
                                                                        target="_blank">Điều khoản và điều kiện</a> của
                                                                    rạp
                                                                </label>
                                                            </div>
                                                        </div>
                                                    </div>

                                                    <!-- Submit Button - Nút thanh toán -->
                                                    <button type="submit" name="action" value="payment"
                                                        class="btn-submit-payment" id="paymentButton">
                                                        <i class="fas fa-lock"></i>
                                                        <span>Thanh Toán <%= String.format("%,.0f đ",
                                                                bookingSession.getTotalAmount()) %></span>
                                                        <i class="fas fa-arrow-right"></i>
                                                    </button>
                                                </form>
                                            </div>

                                            <!-- JavaScript Section -->
                                            <% Long remainingSeconds=(Long) request.getAttribute("remainingSeconds");
                                                long timeLeftSeconds=remainingSeconds !=null ? remainingSeconds : 0; %>
                                                <script>
                                                    // ===== COUNTDOWN TIMER =====
                                                    let timeLeft = <%= timeLeftSeconds %>;

                                                    /**
                                                     * Cập nhật đồng hồ đếm ngược
                                                     * Đổi màu cảnh báo khi còn ít thời gian
                                                     */
                                                    function updateCountdown() {
                                                        const minutes = Math.floor(timeLeft / 60);
                                                        const seconds = timeLeft % 60;
                                                        const countdownElement = document.getElementById('countdown');
                                                        const timerCompact = document.getElementById('timerCompact');

                                                        // Hiển thị thời gian dạng MM:SS
                                                        countdownElement.textContent =
                                                            String(minutes).padStart(2, '0') + ':' + String(seconds).padStart(2, '0');

                                                        // Đổi màu timer theo thời gian còn lại
                                                        if (timeLeft <= 60) {
                                                            timerCompact.className = 'timer-compact critical';  // Đỏ khi <= 1 phút
                                                        } else if (timeLeft <= 180) {
                                                            timerCompact.className = 'timer-compact warning';   // Vàng khi <= 3 phút
                                                        }

                                                        // Hết thời gian -> chuyển về trang chọn suất
                                                        if (timeLeft <= 0) {
                                                            alert('Hết thời gian giữ chỗ! Bạn sẽ được chuyển về trang chọn suất chiếu.');
                                                            window.location.href = '${pageContext.request.contextPath}/booking/select-screening';
                                                        }

                                                        timeLeft--;
                                                    }

                                                    // ===== PAYMENT METHOD SELECTION =====
                                                    /**
                                                     * Xử lý chọn phương thức thanh toán
                                                     * (Hiện tại chỉ có VNPay nhưng code sẵn cho tương lai)
                                                     */
                                                    document.querySelectorAll('.payment-option').forEach(option => {
                                                        option.addEventListener('click', function () {
                                                            // Bỏ class selected khỏi tất cả options
                                                            document.querySelectorAll('.payment-option').forEach(opt => {
                                                                opt.classList.remove('selected');
                                                            });

                                                            // Thêm class selected cho option được click
                                                            this.classList.add('selected');

                                                            // Check radio button tương ứng
                                                            this.querySelector('input[type="radio"]').checked = true;
                                                        });
                                                    });

                                                    // ===== FORM VALIDATION =====
                                                    /**
                                                     * Validate form khi submit
                                                     * Chỉ kiểm tra checkbox điều khoản khi click nút payment
                                                     */
                                                    document.getElementById('paymentForm').addEventListener('submit', function (e) {
                                                        // Xác định nút nào được click
                                                        const submitter = e.submitter;

                                                        // Chỉ validate terms khi click nút payment (không validate khi áp dụng mã giảm giá)
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

                                                    // ===== INITIALIZATION =====
                                                    /**
                                                     * Khởi tạo countdown khi trang load
                                                     */
                                                    document.addEventListener('DOMContentLoaded', function () {
                                                        updateCountdown();  // Cập nhật ngay lập tức
                                                        setInterval(updateCountdown, 1000);  // Cập nhật mỗi giây
                                                    });
                                                </script>
                </body>

                </html>