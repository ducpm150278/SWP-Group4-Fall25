<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
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
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
        }
        
        .booking-container {
            max-width: 1200px;
            margin: 30px auto;
            padding: 30px;
            background: white;
            border-radius: 15px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
        }
        
        .screen {
            background: #333;
            height: 8px;
            border-radius: 0 0 50% 50%;
            margin: 30px auto;
            max-width: 600px;
            box-shadow: 0 3px 10px rgba(0,0,0,0.5);
        }
        
        .seat-map {
            display: grid;
            grid-template-columns: repeat(10, 1fr);
            gap: 10px;
            max-width: 700px;
            margin: 30px auto;
        }
        
        .seat {
            width: 100%;
            aspect-ratio: 1;
            border: 2px solid #ddd;
            border-radius: 8px;
            background: #4CAF50;
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            font-size: 12px;
            font-weight: bold;
            transition: all 0.3s;
        }
        
        .seat:hover:not(.booked):not(.reserved) {
            transform: scale(1.1);
            box-shadow: 0 4px 8px rgba(0,0,0,0.2);
        }
        
        .seat.selected {
            background: #2196F3;
            border-color: #1976D2;
        }
        
        .seat.booked {
            background: #f44336;
            border-color: #d32f2f;
            cursor: not-allowed;
        }
        
        .seat.reserved {
            background: #FF9800;
            border-color: #F57C00;
            cursor: not-allowed;
        }
        
        .seat.vip {
            background: #9C27B0;
        }
        
        .legend {
            display: flex;
            justify-content: center;
            gap: 30px;
            margin: 30px 0;
            flex-wrap: wrap;
        }
        
        .legend-item {
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .legend-box {
            width: 30px;
            height: 30px;
            border: 2px solid #ddd;
            border-radius: 5px;
        }
        
        .timer {
            background: #fff3cd;
            border: 2px solid #ffc107;
            border-radius: 10px;
            padding: 15px;
            text-align: center;
            font-size: 18px;
            font-weight: bold;
            color: #856404;
            margin-bottom: 20px;
        }
        
        .booking-info {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 20px;
        }
        
        .btn-group-custom {
            display: flex;
            gap: 15px;
            justify-content: center;
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
    
    <div class="booking-container">
        <div class="text-center mb-4">
            <h2><i class="fas fa-couch"></i> Chọn Ghế Ngồi</h2>
            <p class="text-muted">Chọn từ 1 đến 8 ghế</p>
        </div>
        
        <!-- Booking Info -->
        <div class="booking-info">
            <div class="row">
                <div class="col-md-6">
                    <strong><i class="fas fa-film"></i> Phim:</strong> <%= bookingSession.getMovieTitle() %><br>
                    <strong><i class="fas fa-building"></i> Rạp:</strong> <%= bookingSession.getCinemaName() %>
                </div>
                <div class="col-md-6">
                    <strong><i class="fas fa-door-open"></i> Phòng:</strong> <%= bookingSession.getRoomName() %><br>
                    <strong><i class="fas fa-money-bill"></i> Giá vé:</strong> <%= String.format("%,.0f VNĐ", bookingSession.getTicketPrice()) %>
                </div>
            </div>
        </div>
        
        <!-- Timer -->
        <div class="timer">
            <i class="fas fa-clock"></i> Thời gian còn lại: <span id="countdown">15:00</span>
        </div>
        
        <!-- Error Message -->
        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-danger" role="alert">
                <%= request.getAttribute("error") %>
            </div>
        <% } %>
        
        <!-- Screen -->
        <div class="text-center mb-3">
            <small class="text-muted">MÀN HÌNH</small>
        </div>
        <div class="screen"></div>
        
        <!-- Seat Map -->
        <form method="post" action="${pageContext.request.contextPath}/booking/select-seats" id="seatForm">
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
                            
                            if ("VIP".equals(seat.getSeatType())) {
                                seatClass += " vip";
                            }
                %>
                    <div class="<%= seatClass %>" 
                         data-seat-id="<%= seat.getSeatID() %>"
                         data-available="<%= !isBooked && !isReserved %>"
                         onclick="toggleSeat(this)">
                        <%= seat.getSeatLabel() %>
                    </div>
                <%
                        }
                    }
                %>
            </div>
            
            <input type="hidden" name="seatIDs" id="selectedSeats">
            
            <!-- Legend -->
            <div class="legend">
                <div class="legend-item">
                    <div class="legend-box" style="background: #4CAF50;"></div>
                    <span>Còn trống</span>
                </div>
                <div class="legend-item">
                    <div class="legend-box" style="background: #2196F3;"></div>
                    <span>Đang chọn</span>
                </div>
                <div class="legend-item">
                    <div class="legend-box" style="background: #f44336;"></div>
                    <span>Đã đặt</span>
                </div>
                <div class="legend-item">
                    <div class="legend-box" style="background: #FF9800;"></div>
                    <span>Đang giữ</span>
                </div>
            </div>
            
            <!-- Selected Info -->
            <div class="text-center mb-4">
                <h5>Ghế đã chọn: <span id="selectedCount">0</span>/8</h5>
                <div id="selectedSeatsList" class="text-muted"></div>
                <h4 class="mt-3">Tổng tiền: <span id="totalAmount">0 VNĐ</span></h4>
            </div>
            
            <!-- Action Buttons -->
            <div class="btn-group-custom">
                <button type="button" class="btn btn-secondary" onclick="resetSeats()">
                    <i class="fas fa-redo"></i> Đặt Lại
                </button>
                <button type="submit" class="btn btn-primary btn-lg" id="confirmBtn" disabled>
                    <i class="fas fa-arrow-right"></i> Xác Nhận
                </button>
            </div>
        </form>
    </div>
    
    <script>
        const ticketPrice = <%= bookingSession.getTicketPrice() %>;
        const selectedSeats = new Set();
        const maxSeats = 8;
        
        function toggleSeat(element) {
            if (element.dataset.available !== 'true') {
                return;
            }
            
            const seatId = element.dataset.seatId;
            
            if (selectedSeats.has(seatId)) {
                selectedSeats.delete(seatId);
                element.classList.remove('selected');
            } else {
                if (selectedSeats.size >= maxSeats) {
                    alert('Bạn chỉ có thể chọn tối đa ' + maxSeats + ' ghế!');
                    return;
                }
                selectedSeats.add(seatId);
                element.classList.add('selected');
            }
            
            updateSelection();
        }
        
        function updateSelection() {
            const count = selectedSeats.size;
            document.getElementById('selectedCount').textContent = count;
            
            // Update seat list
            const seatLabels = Array.from(selectedSeats).map(id => {
                return document.querySelector(`[data-seat-id="${id}"]`).textContent;
            });
            document.getElementById('selectedSeatsList').textContent = seatLabels.join(', ');
            
            // Update total amount
            const total = count * ticketPrice;
            document.getElementById('totalAmount').textContent = total.toLocaleString('vi-VN') + ' VNĐ';
            
            // Update hidden input
            document.getElementById('selectedSeats').value = Array.from(selectedSeats).join(',');
            
            // Enable/disable confirm button
            document.getElementById('confirmBtn').disabled = count === 0;
        }
        
        function resetSeats() {
            selectedSeats.clear();
            document.querySelectorAll('.seat.selected').forEach(seat => {
                seat.classList.remove('selected');
            });
            updateSelection();
        }
        
        // Countdown timer
        let timeLeft = <%= request.getAttribute("remainingSeconds") != null ? request.getAttribute("remainingSeconds") : 900 %>;
        
        function updateCountdown() {
            const minutes = Math.floor(timeLeft / 60);
            const seconds = timeLeft % 60;
            document.getElementById('countdown').textContent = 
                String(minutes).padStart(2, '0') + ':' + String(seconds).padStart(2, '0');
            
            if (timeLeft <= 0) {
                alert('Hết thời gian giữ chỗ! Vui lòng đặt lại.');
                window.location.href = '${pageContext.request.contextPath}/booking/select-screening';
            }
            
            timeLeft--;
        }
        
        setInterval(updateCountdown, 1000);
        
        // Form submission
        document.getElementById('seatForm').addEventListener('submit', function(e) {
            if (selectedSeats.size === 0) {
                e.preventDefault();
                alert('Vui lòng chọn ít nhất một ghế!');
                return false;
            }
            
            // Split seat IDs into multiple inputs
            const form = this;
            selectedSeats.forEach(seatId => {
                const input = document.createElement('input');
                input.type = 'hidden';
                input.name = 'seatIDs';
                input.value = seatId;
                form.appendChild(input);
            });
        });
    </script>
</body>
</html>

