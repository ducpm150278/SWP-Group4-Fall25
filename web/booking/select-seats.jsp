<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>
<%@page import="entity.Seat"%>
<%@page import="entity.Screening"%>
<%@page import="entity.BookingSession"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chọn Ghế - Cinema Booking</title>
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
        
        .step-label {
            font-size: 12px;
            color: #8b92a7;
        }
        
        .step.active .step-label,
        .step.completed .step-label {
            color: #fff;
            font-weight: 600;
        }
        
        /* Main Container */
        .main-container {
            max-width: 1400px;
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
        
        /* Info Section */
        .info-section {
            background: #1a1d24;
            border-radius: 12px;
            padding: 25px;
            margin-bottom: 25px;
            border: 1px solid #2a2d35;
        }
        
        .section-title {
            font-size: 18px;
            font-weight: 600;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
            color: #fff;
        }
        
        .section-title i {
            color: #e50914;
        }
        
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
        }
        
        .info-item {
            background: #2a2d35;
            padding: 15px;
            border-radius: 8px;
            border-left: 3px solid #e50914;
        }
        
        .info-label {
            font-size: 12px;
            color: #8b92a7;
            margin-bottom: 5px;
        }
        
        .info-value {
            font-size: 16px;
            font-weight: 600;
            color: #fff;
        }
        
        /* Timer */
        .timer-section {
            background: linear-gradient(135deg, rgba(229, 9, 20, 0.1) 0%, rgba(229, 9, 20, 0.05) 100%);
            border: 2px solid #e50914;
            border-radius: 12px;
            padding: 20px;
            text-align: center;
            margin-bottom: 25px;
            animation: pulse-border 2s infinite;
        }
        
        @keyframes pulse-border {
            0%, 100% { border-color: #e50914; }
            50% { border-color: #ff2030; }
        }
        
        .timer-icon {
            font-size: 32px;
            color: #e50914;
            margin-bottom: 10px;
        }
        
        .timer-value {
            font-size: 36px;
            font-weight: 700;
            color: #e50914;
            margin-bottom: 5px;
        }
        
        .timer-label {
            font-size: 14px;
            color: #8b92a7;
        }
        
        .timer-section.warning {
            background: linear-gradient(135deg, rgba(255, 149, 0, 0.1) 0%, rgba(255, 149, 0, 0.05) 100%);
            border-color: #ff9500;
        }
        
        .timer-section.warning .timer-icon,
        .timer-section.warning .timer-value {
            color: #ff9500;
        }
        
        .timer-section.critical {
            background: linear-gradient(135deg, rgba(255, 59, 48, 0.1) 0%, rgba(255, 59, 48, 0.05) 100%);
            border-color: #ff3b30;
        }
        
        .timer-section.critical .timer-icon,
        .timer-section.critical .timer-value {
            color: #ff3b30;
        }
        
        /* Screen */
        .screen-section {
            background: #1a1d24;
            border-radius: 12px;
            padding: 30px;
            margin-bottom: 25px;
            border: 1px solid #2a2d35;
            text-align: center;
        }
        
        .screen-label {
            font-size: 14px;
            color: #8b92a7;
            letter-spacing: 4px;
            margin-bottom: 20px;
            font-weight: 600;
        }
        
        .screen {
            background: linear-gradient(180deg, #e50914 0%, #b20710 100%);
            height: 8px;
            border-radius: 0 0 50% 50%;
            margin: 0 auto 10px;
            max-width: 70%;
            box-shadow: 0 10px 40px rgba(229, 9, 20, 0.5);
            position: relative;
        }
        
        .screen::after {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255,255,255,0.3), transparent);
            animation: screen-shine 3s infinite;
        }
        
        @keyframes screen-shine {
            0%, 100% { transform: translateX(-100%); }
            50% { transform: translateX(100%); }
        }
        
        /* Seat Map */
        .seat-map-section {
            background: #1a1d24;
            border-radius: 12px;
            padding: 30px;
            margin-bottom: 25px;
            border: 1px solid #2a2d35;
        }
        
        .seat-grid-container {
            max-width: 900px;
            margin: 0 auto;
            display: flex;
            gap: 20px;
        }
        
        .row-labels {
            display: flex;
            flex-direction: column;
            gap: 10px;
        }
        
        .row-label {
            width: 40px;
            height: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            color: #e50914;
            background: #2a2d35;
            border-radius: 6px;
            font-size: 16px;
        }
        
        .seat-map {
            display: grid;
            grid-template-columns: repeat(10, 1fr);
            gap: 10px;
            flex: 1;
        }
        
        .seat {
            width: 100%;
            height: 40px;
            border: 2px solid transparent;
            border-radius: 6px;
            background: #2ea043;
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            font-size: 12px;
            font-weight: 600;
            transition: all 0.3s ease;
            position: relative;
        }
        
        .seat:hover:not(.booked):not(.reserved) {
            transform: translateY(-5px);
            box-shadow: 0 10px 25px rgba(46, 160, 67, 0.4);
            border-color: #2ea043;
        }
        
        .seat.selected {
            background: #e50914;
            border-color: #e50914;
            box-shadow: 0 5px 20px rgba(229, 9, 20, 0.4);
        }
        
        .seat.selected:hover {
            box-shadow: 0 10px 30px rgba(229, 9, 20, 0.6);
        }
        
        .seat.booked {
            background: #6c757d;
            cursor: not-allowed;
            opacity: 0.5;
        }
        
        .seat.reserved {
            background: #ff9500;
            cursor: not-allowed;
            opacity: 0.7;
        }
        
        .seat.vip {
            box-shadow: 0 0 0 2px #ffd700;
        }
        
        .seat.vip.selected {
            box-shadow: 0 0 0 2px #ffd700, 0 5px 20px rgba(229, 9, 20, 0.4);
        }
        
        .seat.couple {
            grid-column: span 2;
        }
        
        /* Legend */
        .legend-section {
            display: flex;
            justify-content: center;
            flex-wrap: wrap;
            gap: 20px;
            margin-top: 30px;
            padding: 20px;
            background: #2a2d35;
            border-radius: 8px;
        }
        
        .legend-item {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .legend-box {
            width: 32px;
            height: 32px;
            border-radius: 4px;
            border: 2px solid transparent;
        }
        
        .legend-text {
            font-size: 14px;
            color: #fff;
        }
        
        /* Summary Section */
        .summary-section {
            background: #1a1d24;
            border-radius: 12px;
            padding: 25px;
            margin-bottom: 25px;
            border: 1px solid #2a2d35;
        }
        
        .summary-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 20px;
            border-bottom: 1px solid #2a2d35;
        }
        
        .summary-count {
            font-size: 24px;
            font-weight: 700;
            color: #e50914;
        }
        
        .seat-tags-container {
            min-height: 60px;
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            align-items: center;
            justify-content: center;
            margin-bottom: 20px;
            padding: 20px;
            background: #2a2d35;
            border-radius: 8px;
        }
        
        .seat-tag {
            background: #e50914;
            color: white;
            padding: 8px 16px;
            border-radius: 20px;
            font-weight: 600;
            font-size: 14px;
            animation: seat-tag-appear 0.3s ease;
        }
        
        @keyframes seat-tag-appear {
            from {
                opacity: 0;
                transform: scale(0.5);
            }
            to {
                opacity: 1;
                transform: scale(1);
            }
        }
        
        .empty-selection {
            color: #8b92a7;
            font-size: 14px;
        }
        
        .total-section {
            background: linear-gradient(135deg, #e50914 0%, #b20710 100%);
            padding: 25px;
            border-radius: 8px;
            text-align: center;
            box-shadow: 0 10px 30px rgba(229, 9, 20, 0.3);
        }
        
        .total-label {
            font-size: 14px;
            color: rgba(255,255,255,0.9);
            margin-bottom: 10px;
            letter-spacing: 2px;
        }
        
        .total-amount {
            font-size: 40px;
            font-weight: 700;
            color: white;
            transition: transform 0.3s ease;
        }
        
        /* Action Buttons */
        .action-section {
            display: flex;
            gap: 15px;
            justify-content: center;
        }
        
        .btn-action {
            padding: 16px 40px;
            font-size: 16px;
            font-weight: 600;
            border-radius: 8px;
            border: none;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 10px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .btn-reset {
            background: #6c757d;
            color: white;
        }
        
        .btn-reset:hover {
            background: #5a6268;
            transform: translateY(-2px);
            box-shadow: 0 10px 25px rgba(108, 117, 125, 0.3);
        }
        
        .btn-continue {
            background: #e50914;
            color: white;
        }
        
        .btn-continue:hover:not(:disabled) {
            background: #b20710;
            transform: translateY(-2px);
            box-shadow: 0 10px 30px rgba(229, 9, 20, 0.4);
        }
        
        .btn-continue:disabled {
            background: #2a2d35;
            color: #8b92a7;
            cursor: not-allowed;
        }
        
        /* Alert */
        .alert {
            border-radius: 8px;
            margin-bottom: 20px;
            border: none;
        }
        
        .alert-danger {
            background: rgba(229, 9, 20, 0.2);
            color: #ff6b6b;
            border-left: 4px solid #e50914;
        }
        
        /* Loading Overlay */
        .loading-overlay {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(15, 16, 20, 0.95);
            display: none;
            align-items: center;
            justify-content: center;
            z-index: 9999;
        }
        
        .loading-spinner {
            width: 60px;
            height: 60px;
            border: 5px solid #2a2d35;
            border-top: 5px solid #e50914;
            border-radius: 50%;
            animation: spin 1s linear infinite;
        }
        
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        
        /* Responsive */
        @media (max-width: 768px) {
            .seat-map {
                grid-template-columns: repeat(8, 1fr);
                gap: 8px;
            }
            
            .seat, .row-label {
                height: 35px;
                width: 35px;
                font-size: 11px;
            }
            
            .action-section {
                flex-direction: column;
            }
            
            .btn-action {
                width: 100%;
                justify-content: center;
            }
            
            .step-label {
                display: none;
            }
        }
    </style>
</head>
<body>
    <%
        Screening screening = (Screening) request.getAttribute("screening");
        BookingSession bookingSession = (BookingSession) request.getAttribute("bookingSession");
        List<Seat> allSeats = (List<Seat>) request.getAttribute("allSeats");
        List<Integer> bookedSeatIDs = (List<Integer>) request.getAttribute("bookedSeatIDs");
        List<Integer> reservedSeatIDs = (List<Integer>) request.getAttribute("reservedSeatIDs");
    %>
    
    <!-- Loading Overlay -->
    <div class="loading-overlay" id="loadingOverlay">
        <div class="loading-spinner"></div>
    </div>
    
    <!-- Progress Steps -->
    <div class="progress-container">
        <div class="progress-steps">
            <div class="step completed">
                <div class="step-circle"><i class="fas fa-check"></i></div>
                <div class="step-label">Chọn Suất</div>
            </div>
            <div class="step active">
                <div class="step-circle">2</div>
                <div class="step-label">Chọn Ghế</div>
            </div>
            <div class="step">
                <div class="step-circle">3</div>
                <div class="step-label">Đồ Ăn & Nước</div>
            </div>
            <div class="step">
                <div class="step-circle">4</div>
                <div class="step-label">Thanh Toán</div>
            </div>
        </div>
    </div>
    
    <!-- Main Content -->
    <div class="main-container">
        <div class="page-header">
            <h1><i class="fas fa-couch"></i> Chọn Ghế Ngồi</h1>
            <p>Chọn từ 1 đến 8 ghế để tiếp tục đặt vé</p>
        </div>
        
        <!-- Booking Info -->
        <div class="info-section">
            <div class="section-title">
                <i class="fas fa-info-circle"></i>
                <span>Thông Tin Suất Chiếu</span>
            </div>
            <div class="info-grid">
                <div class="info-item">
                    <div class="info-label">Phim</div>
                    <div class="info-value"><%= bookingSession.getMovieTitle() %></div>
                </div>
                <div class="info-item">
                    <div class="info-label">Rạp</div>
                    <div class="info-value"><%= bookingSession.getCinemaName() %></div>
                </div>
                <div class="info-item">
                    <div class="info-label">Phòng</div>
                    <div class="info-value"><%= bookingSession.getRoomName() %></div>
                </div>
                <div class="info-item">
                    <div class="info-label">Giá vé</div>
                    <div class="info-value"><%= String.format("%,.0f VNĐ", bookingSession.getTicketPrice()) %></div>
                </div>
            </div>
        </div>
        
        <!-- Timer -->
        <div class="timer-section" id="timerSection">
            <div class="timer-icon">
                <i class="fas fa-clock"></i>
            </div>
            <div class="timer-value" id="timerValue">15:00</div>
            <div class="timer-label">Thời gian giữ ghế còn lại</div>
        </div>
        
        <!-- Error Message -->
        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-danger" role="alert">
                <i class="fas fa-exclamation-circle"></i>
                <%= request.getAttribute("error") %>
            </div>
        <% } %>
        
        <!-- Screen -->
        <div class="screen-section">
            <div class="screen-label">MÀN HÌNH</div>
            <div class="screen"></div>
        </div>
        
        <!-- Seat Map -->
        <div class="seat-map-section">
            <form method="post" action="${pageContext.request.contextPath}/booking/select-seats" id="seatForm">
                <div class="seat-grid-container">
                    <!-- Row Labels -->
                    <div class="row-labels">
                        <%
                            java.util.Set<String> uniqueRows = new java.util.TreeSet<>();
                            if (allSeats != null) {
                                for (Seat seat : allSeats) {
                                    uniqueRows.add(seat.getSeatRow());
                                }
                                for (String row : uniqueRows) {
                        %>
                                    <div class="row-label"><%= row %></div>
                        <%
                                }
                            }
                        %>
                    </div>
                    
                    <!-- Seat Grid -->
                    <div class="seat-map" id="seatMap">
                        <%
                            if (allSeats != null) {
                                for (Seat seat : allSeats) {
                                    String seatClass = "seat";
                                    boolean isBooked = bookedSeatIDs != null && bookedSeatIDs.contains(seat.getSeatID());
                                    boolean isReserved = reservedSeatIDs != null && reservedSeatIDs.contains(seat.getSeatID());
                                    boolean isSelected = bookingSession.getSelectedSeatIDs() != null && 
                                                       bookingSession.getSelectedSeatIDs().contains(seat.getSeatID());
                                    
                                    if (isBooked) {
                                        seatClass += " booked";
                                    } else if (isReserved) {
                                        seatClass += " reserved";
                                    } else if (isSelected) {
                                        seatClass += " selected";
                                    }
                                    
                                    String seatType = seat.getSeatType();
                                    if ("VIP".equals(seatType)) {
                                        seatClass += " vip";
                                    } else if ("Couple".equals(seatType)) {
                                        seatClass += " couple";
                                    }
                        %>
                            <div class="<%= seatClass %>" 
                                 data-seat-id="<%= seat.getSeatID() %>"
                                 data-seat-label="<%= seat.getSeatRow() %><%= seat.getSeatNumber() %>"
                                 data-available="<%= !isBooked && !isReserved %>"
                                 data-price-multiplier="<%= seat.getPriceMultiplier() %>">
                                <%= seat.getSeatNumber() %>
                            </div>
                        <%
                                }
                            }
                        %>
                    </div>
                </div>
                
                <!-- Legend -->
                <div class="legend-section">
                    <div class="legend-item">
                        <div class="legend-box" style="background: #2ea043;"></div>
                        <span class="legend-text">Còn trống</span>
                    </div>
                    <div class="legend-item">
                        <div class="legend-box" style="background: #e50914;"></div>
                        <span class="legend-text">Đang chọn</span>
                    </div>
                    <div class="legend-item">
                        <div class="legend-box" style="background: #6c757d; opacity: 0.5;"></div>
                        <span class="legend-text">Đã đặt</span>
                    </div>
                    <div class="legend-item">
                        <div class="legend-box" style="background: #ff9500; opacity: 0.7;"></div>
                        <span class="legend-text">Đang giữ</span>
                    </div>
                    <div class="legend-item">
                        <div class="legend-box" style="background: #2ea043; box-shadow: 0 0 0 2px #ffd700;"></div>
                        <span class="legend-text">VIP</span>
                    </div>
                </div>
            </form>
        </div>
        
        <!-- Summary -->
        <div class="summary-section">
            <div class="summary-header">
                <h3 class="section-title">
                    <i class="fas fa-chair"></i>
                    <span>Ghế Đã Chọn</span>
                </h3>
                <div class="summary-count">
                    <span id="selectedCount">0</span>/8
                </div>
            </div>
            
            <div class="seat-tags-container" id="seatTagsContainer">
                <span class="empty-selection">Chưa chọn ghế nào</span>
            </div>
            
            <div class="total-section">
                <div class="total-label">TỔNG THANH TOÁN</div>
                <div class="total-amount" id="totalAmount">0 VNĐ</div>
            </div>
        </div>
        
        <!-- Actions -->
        <div class="action-section">
            <button type="button" class="btn-action btn-reset" onclick="resetSeats()">
                <i class="fas fa-redo"></i>
                Đặt Lại
            </button>
            <button type="button" class="btn-action btn-continue" id="continueBtn" disabled onclick="submitForm()">
                <i class="fas fa-arrow-right"></i>
                Tiếp Tục
            </button>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        const ticketPrice = <%= bookingSession.getTicketPrice() %>;
        const selectedSeatsData = new Map();
        const maxSeats = 8;
        let timeLeft = <%= request.getAttribute("remainingSeconds") != null ? request.getAttribute("remainingSeconds") : 900 %>;
        
        // Initialize
        document.addEventListener('DOMContentLoaded', function() {
            initializeSeats();
            startCountdown();
            startAutoRefresh();
        });
        
        function initializeSeats() {
            document.querySelectorAll('.seat').forEach(seat => {
                seat.addEventListener('click', function() {
                    toggleSeat(this);
                });
            });
            updateSummary();
        }
        
        function toggleSeat(element) {
            if (element.dataset.available !== 'true') {
                return;
            }
            
            const seatId = element.dataset.seatId;
            const seatLabel = element.dataset.seatLabel;
            const priceMultiplier = parseFloat(element.dataset.priceMultiplier) || 1.0;
            
            if (selectedSeatsData.has(seatId)) {
                selectedSeatsData.delete(seatId);
                element.classList.remove('selected');
            } else {
                if (selectedSeatsData.size >= maxSeats) {
                    showNotification('Bạn chỉ có thể chọn tối đa ' + maxSeats + ' ghế!', 'warning');
                    return;
                }
                
                selectedSeatsData.set(seatId, {
                    label: seatLabel,
                    multiplier: priceMultiplier
                });
                element.classList.add('selected');
            }
            
            updateSummary();
        }
        
        function updateSummary() {
            const count = selectedSeatsData.size;
            document.getElementById('selectedCount').textContent = count;
            
            const container = document.getElementById('seatTagsContainer');
            if (count === 0) {
                container.innerHTML = '<span class="empty-selection">Chưa chọn ghế nào</span>';
            } else {
                container.innerHTML = '';
                selectedSeatsData.forEach(function(data, id) {
                    const tag = document.createElement('span');
                    tag.className = 'seat-tag';
                    tag.textContent = data.label;
                    container.appendChild(tag);
                });
            }
            
            let total = 0;
            selectedSeatsData.forEach(function(data) {
                total += ticketPrice * data.multiplier;
            });
            
            const totalElement = document.getElementById('totalAmount');
            totalElement.style.transform = 'scale(1.1)';
            setTimeout(function() {
                totalElement.textContent = total.toLocaleString('vi-VN') + ' VNĐ';
                totalElement.style.transform = 'scale(1)';
            }, 150);
            
            document.getElementById('continueBtn').disabled = count === 0;
        }
        
        function resetSeats() {
            if (selectedSeatsData.size === 0) return;
            
            if (confirm('Bạn có chắc muốn bỏ chọn tất cả ghế?')) {
                selectedSeatsData.clear();
                document.querySelectorAll('.seat.selected').forEach(function(seat) {
                    seat.classList.remove('selected');
                });
                updateSummary();
            }
        }
        
        function submitForm() {
            if (selectedSeatsData.size === 0) {
                showNotification('Vui lòng chọn ít nhất một ghế!', 'warning');
                return;
            }
            
            document.getElementById('loadingOverlay').style.display = 'flex';
            
            const form = document.getElementById('seatForm');
            selectedSeatsData.forEach(function(data, seatId) {
                const input = document.createElement('input');
                input.type = 'hidden';
                input.name = 'seatIDs';
                input.value = seatId;
                form.appendChild(input);
            });
            
            setTimeout(function() {
                form.submit();
            }, 500);
        }
        
        function startCountdown() {
            updateTimer();
            setInterval(updateTimer, 1000);
        }
        
        function updateTimer() {
            const minutes = Math.floor(timeLeft / 60);
            const seconds = timeLeft % 60;
            document.getElementById('timerValue').textContent = 
                String(minutes).padStart(2, '0') + ':' + String(seconds).padStart(2, '0');
            
            const timerSection = document.getElementById('timerSection');
            if (timeLeft <= 60) {
                timerSection.className = 'timer-section critical';
            } else if (timeLeft <= 180) {
                timerSection.className = 'timer-section warning';
            }
            
            if (timeLeft <= 0) {
                showNotification('Hết thời gian! Đang chuyển hướng...', 'error');
                setTimeout(function() {
                    window.location.href = '${pageContext.request.contextPath}/booking/select-screening';
                }, 2000);
                return;
            }
            
            timeLeft--;
        }
        
        function startAutoRefresh() {
            setInterval(function() {
                refreshSeatAvailability();
            }, 5000);
        }
        
        function refreshSeatAvailability() {
            fetch('${pageContext.request.contextPath}/booking/select-seats?ajax=true&screeningID=<%= bookingSession.getScreeningID() %>')
                .then(response => response.json())
                .then(data => {
                    if (data.bookedSeats || data.reservedSeats) {
                        updateSeatStatus(data.bookedSeats, data.reservedSeats);
                    }
                })
                .catch(error => console.log('Auto-refresh error:', error));
        }
        
        function updateSeatStatus(bookedSeats, reservedSeats) {
            let hasChanges = false;
            
            document.querySelectorAll('.seat').forEach(function(seat) {
                const seatId = parseInt(seat.dataset.seatId);
                
                if (bookedSeats.includes(seatId)) {
                    if (!seat.classList.contains('booked')) {
                        seat.classList.remove('selected', 'reserved');
                        seat.classList.add('booked');
                        seat.dataset.available = 'false';
                        
                        if (selectedSeatsData.has(String(seatId))) {
                            selectedSeatsData.delete(String(seatId));
                            hasChanges = true;
                        }
                    }
                } else if (reservedSeats.includes(seatId)) {
                    if (!seat.classList.contains('reserved') && !seat.classList.contains('selected')) {
                        seat.classList.add('reserved');
                        seat.dataset.available = 'false';
                    }
                } else if (seat.classList.contains('reserved') && !seat.classList.contains('selected')) {
                    seat.classList.remove('reserved');
                    seat.dataset.available = 'true';
                }
            });
            
            if (hasChanges) {
                updateSummary();
                showNotification('Một số ghế đã bị người khác đặt!', 'warning');
            }
        }
        
        function showNotification(message, type) {
            const alertClass = type === 'warning' ? 'alert-warning' : 
                              type === 'error' ? 'alert-danger' : 'alert-info';
            
            const notification = document.createElement('div');
            notification.className = 'alert ' + alertClass;
            notification.style.cssText = 'position: fixed; top: 20px; right: 20px; z-index: 10000; min-width: 300px; animation: slideIn 0.3s ease;';
            notification.innerHTML = '<i class="fas fa-exclamation-circle"></i> ' + message;
            
            document.body.appendChild(notification);
            
            setTimeout(function() {
                notification.remove();
            }, 3000);
        }
        
        const style = document.createElement('style');
        style.textContent = '@keyframes slideIn { from { transform: translateX(100%); opacity: 0; } to { transform: translateX(0); opacity: 1; } }';
        document.head.appendChild(style);
    </script>
</body>
</html>
