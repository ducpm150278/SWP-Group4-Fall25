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
        
        /* Seat Map */
        .seat-map-section {
            background: #1a1d24;
            border-radius: 12px;
            padding: 30px;
            margin-bottom: 25px;
            border: 1px solid #2a2d35;
        }
        
        .seat-grid-container {
            max-width: 1000px;
            margin: 0 auto;
            display: flex;
            flex-direction: column;
            gap: 10px;
        }
        
        .seat-row-container {
            display: flex;
            align-items: center;
            gap: 15px;
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
            flex-shrink: 0;
        }
        
        .seat-row {
            display: flex;
            gap: 8px;
            justify-content: center;
            flex: 1;
            align-items: center;
        }
        
        /* Center aisle spacing */
        .seat-aisle {
            width: 30px;
            flex-shrink: 0;
        }
        
        /* Zone separators */
        .zone-separator {
            height: 15px;
            position: relative;
            margin: 8px 0;
        }
        
        .zone-separator::before {
            content: '';
            position: absolute;
            left: 60px;
            right: 0;
            top: 50%;
            height: 1px;
            background: linear-gradient(90deg, transparent, #2a2d35 20%, #2a2d35 80%, transparent);
        }
        
        .zone-label {
            position: absolute;
            right: 20px;
            top: 50%;
            transform: translateY(-50%);
            background: #0f1014;
            padding: 2px 12px;
            font-size: 11px;
            color: #8b92a7;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        
        .seat {
            min-width: 40px;
            width: 40px;
            height: 40px;
            border: 1px solid #3a3d45;
            border-radius: 4px;
            background: #2a2d35;
            color: #8b92a7;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            font-size: 11px;
            font-weight: 600;
            transition: all 0.2s ease;
            position: relative;
            flex-shrink: 0;
        }
        
        .seat:hover:not(.booked):not(.reserved):not(.maintenance):not(.selected) {
            background: #3a3d45;
            border-color: #4a4d55;
            color: #fff;
            transform: translateY(-2px);
        }
        
        .seat.selected {
            background: #e50914 !important;
            color: white !important;
            border-color: #e50914 !important;
        }
        
        .seat.selected:hover {
            background: #c50812 !important;
        }
        
        .seat.booked {
            background: #1a1d24;
            border-color: #1a1d24;
            color: #555;
            cursor: not-allowed;
            opacity: 0.3;
        }
        
        .seat.reserved {
            background: linear-gradient(135deg, #ff9500 0%, #ff7b00 100%);
            border: 2px solid #ff9500;
            color: transparent;
            cursor: not-allowed;
            position: relative;
            opacity: 1;
        }
        
        .seat.reserved::before {
            content: '\f017';
            font-family: 'Font Awesome 5 Free';
            font-weight: 400;
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            font-size: 12px;
            color: rgba(255, 255, 255, 0.9);
        }
        
        /* VIP seats - Subtle gold accent */
        .seat.vip {
            border-color: #6b5d3f;
            background: #2f2d2a;
        }
        
        .seat.vip:hover:not(.booked):not(.reserved):not(.maintenance):not(.selected) {
            background: #3f3d3a;
            border-color: #8b7d5f;
        }
        
        .seat.vip.selected {
            background: #e50914 !important;
            border-color: #e50914 !important;
        }
        
        .seat.vip.booked {
            background: #1a1d24;
            border-color: #1a1d24;
            color: #555;
        }
        
        /* Couple seats - Wider, subtle styling */
        .seat.couple {
            min-width: 85px;
            width: 85px;
            border-color: #4a3d45;
            background: #2d2a2d;
        }
        
        .seat.couple:hover:not(.booked):not(.reserved):not(.maintenance):not(.selected) {
            background: #3d3a3d;
            border-color: #5a4d55;
        }
        
        .seat.couple.selected {
            background: #e50914 !important;
            border-color: #e50914 !important;
        }
        
        .seat.couple.booked {
            background: #1a1d24;
            border-color: #1a1d24;
            color: #555;
        }
        
        /* Maintenance seats */
        .seat.maintenance {
            background: #1a1d24;
            border-color: #3a3d45;
            border-style: dashed;
            color: #555;
            cursor: not-allowed;
            opacity: 0.3;
        }
        
        /* Legend */
        .legend-section {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 15px;
            margin-top: 30px;
            padding: 20px;
            background: #2a2d35;
            border-radius: 8px;
        }
        
        @media (max-width: 768px) {
            .legend-section {
                grid-template-columns: repeat(2, 1fr);
            }
        }
        
        .legend-item {
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .legend-box {
            width: 28px;
            height: 28px;
            border-radius: 4px;
            border: 2px solid transparent;
            flex-shrink: 0;
        }
        
        .legend-text {
            font-size: 13px;
            color: #fff;
            white-space: nowrap;
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
            <div class="step completed" onclick="window.location.href='${pageContext.request.contextPath}/booking/select-screening'" title="Quay lại chọn suất chiếu">
                <div class="step-circle"><i class="fas fa-film"></i></div>
                <span class="step-label">Chọn Suất</span>
            </div>
            <div class="step active">
                <div class="step-circle"><i class="fas fa-couch"></i></div>
                <span class="step-label">Chọn Ghế</span>
            </div>
            <div class="step">
                <div class="step-circle"><i class="fas fa-utensils"></i></div>
                <span class="step-label">Đồ Ăn</span>
            </div>
            <div class="step">
                <div class="step-circle"><i class="fas fa-credit-card"></i></div>
                <span class="step-label">Thanh Toán</span>
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
                <% if (screening != null && screening.getStartTime() != null) { 
                    java.time.format.DateTimeFormatter timeFormatter = java.time.format.DateTimeFormatter.ofPattern("HH:mm");
                    String startTime = screening.getStartTime().format(timeFormatter);
                    String endTime = screening.getEndTime() != null ? screening.getEndTime().format(timeFormatter) : "";
                    String timeDisplay = endTime.isEmpty() ? startTime : startTime + " - " + endTime;
                %>
                <div class="info-item">
                    <div class="info-label">Giờ chiếu</div>
                    <div class="info-value"><%= timeDisplay %></div>
                </div>
                <% } %>
                <div class="info-item">
                    <div class="info-label">Giá vé</div>
                    <div class="info-value"><%= String.format("%,.0f VNĐ", bookingSession.getTicketPrice()) %></div>
                </div>
            </div>
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
                <div class="seat-grid-container" id="seatMap">
                    <%
                        if (allSeats != null && !allSeats.isEmpty()) {
                            // Group seats by row - normal order A->Z (front to back, screen is above)
                            Map<String, java.util.List<Seat>> seatsByRow = new java.util.TreeMap<>();
                            for (Seat seat : allSeats) {
                                String row = seat.getSeatRow();
                                if (!seatsByRow.containsKey(row)) {
                                    seatsByRow.put(row, new java.util.ArrayList<>());
                                }
                                seatsByRow.get(row).add(seat);
                            }
                            
                            // Render each row
                            for (Map.Entry<String, java.util.List<Seat>> entry : seatsByRow.entrySet()) {
                                String rowLabel = entry.getKey();
                                java.util.List<Seat> rowSeats = entry.getValue();
                                
                                // Sort seats by seat number
                                java.util.Collections.sort(rowSeats, new java.util.Comparator<Seat>() {
                                    public int compare(Seat s1, Seat s2) {
                                        try {
                                            int num1 = Integer.parseInt(s1.getSeatNumber());
                                            int num2 = Integer.parseInt(s2.getSeatNumber());
                                            return Integer.compare(num1, num2);
                                        } catch (NumberFormatException e) {
                                            // Fallback to string comparison if parsing fails
                                            return s1.getSeatNumber().compareTo(s2.getSeatNumber());
                                        }
                                    }
                                });
                                
                                int totalSeats = rowSeats.size();
                                int halfPoint = (totalSeats + 1) / 2; // Calculate center aisle position
                    %>
                                <div class="seat-row-container">
                                    <div class="row-label"><%= rowLabel.trim() %></div>
                                    <div class="seat-row">
                                        <%
                                            for (int i = 0; i < rowSeats.size(); i++) {
                                                Seat seat = rowSeats.get(i);
                                                
                                                // Add center aisle after half the seats
                                                if (i == halfPoint && totalSeats > 6) {
                                        %>
                                                    <div class="seat-aisle"></div>
                                        <%
                                                }
                                                
                                                String seatClass = "seat";
                                                boolean isBooked = bookedSeatIDs != null && bookedSeatIDs.contains(seat.getSeatID());
                                                boolean isReserved = reservedSeatIDs != null && reservedSeatIDs.contains(seat.getSeatID());
                                                boolean isSelected = bookingSession.getSelectedSeatIDs() != null && 
                                                                   bookingSession.getSelectedSeatIDs().contains(seat.getSeatID());
                                                boolean isMaintenance = "Maintenance".equals(seat.getStatus());
                                                
                                                if (isMaintenance) {
                                                    seatClass += " maintenance";
                                                } else if (isBooked) {
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
                                                     data-seat-label="<%= seat.getSeatRow().trim() %><%= seat.getSeatNumber() %>"
                                                     data-available="<%= !isBooked && !isReserved && !isMaintenance %>"
                                                     data-price-multiplier="<%= seat.getPriceMultiplier() %>"
                                                     data-seat-type="<%= seatType %>">
                                                    <%= seat.getSeatNumber() %>
                                                </div>
                                        <%
                                            }
                                        %>
                                    </div>
                                </div>
                    <%
                            }
                        }
                    %>
                </div>
                
                <!-- Legend -->
                <div class="legend-section">
                    <div class="legend-item">
                        <div class="legend-box" style="background: #2a2d35; border: 1px solid #3a3d45;"></div>
                        <span class="legend-text">Ghế thường</span>
                    </div>
                    <div class="legend-item">
                        <div class="legend-box" style="background: #2f2d2a; border: 1px solid #6b5d3f;"></div>
                        <span class="legend-text">Ghế VIP</span>
                    </div>
                    <div class="legend-item">
                        <div class="legend-box" style="background: #2d2a2d; border: 1px solid #4a3d45; width: 50px;"></div>
                        <span class="legend-text">Ghế đôi</span>
                    </div>
                    <div class="legend-item">
                        <div class="legend-box" style="background: #e50914; border: 2px solid #e50914;"></div>
                        <span class="legend-text">Đang chọn</span>
                    </div>
                    <div class="legend-item">
                        <div class="legend-box" style="background: #1a1d24; border: 1px solid #1a1d24; opacity: 0.3;"></div>
                        <span class="legend-text">Đã đặt</span>
                    </div>
                    <div class="legend-item">
                        <div class="legend-box" style="background: linear-gradient(135deg, #ff9500 0%, #ff7b00 100%); border: 2px solid #ff9500; position: relative; display: flex; align-items: center; justify-content: center; font-family: 'Font Awesome 5 Free'; font-weight: 400;">
                            <span style="color: rgba(255, 255, 255, 0.9); font-size: 12px;">&#xf017;</span>
                        </div>
                        <span class="legend-text">Đang giữ</span>
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
        
        // Initialize
        document.addEventListener('DOMContentLoaded', function() {
            initializeSeats();
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
