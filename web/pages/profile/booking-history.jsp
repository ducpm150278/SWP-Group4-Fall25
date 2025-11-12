<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="com.cinema.entity.BookingDetailDTO" %>
<%
    List<BookingDetailDTO> bookingDetails = (List<BookingDetailDTO>) request.getAttribute("bookingDetails");
    String statusFilter = (String) request.getAttribute("statusFilter");
    String message = (String) request.getAttribute("message");
    String error = (String) request.getAttribute("error");
    
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm");
    SimpleDateFormat dateOnlyFormat = new SimpleDateFormat("EEEE, dd/MM/yyyy");
    DecimalFormat priceFormat = new DecimalFormat("#,###");
    
    if (statusFilter == null) statusFilter = "all";
    
    List<Integer> reviewedMovieIds = (List<Integer>) request.getAttribute("reviewedMovieIds");
    if (reviewedMovieIds == null) reviewedMovieIds = new java.util.ArrayList<Integer>();
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lịch Sử Đặt Vé - Cinema Booking</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="<%= request.getContextPath() %>/css/cinema-dark-theme.css" rel="stylesheet">
    <style>
        .container-compact {
            max-width: 1400px;
            margin: 80px auto 20px;
            padding: 0 20px;
        }
        
        .page-header {
            background: var(--card-bg);
            border-radius: 8px;
            padding: 15px 20px;
            margin-bottom: 15px;
            border: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        .page-header h1 {
            font-size: 1.5rem;
            margin: 0;
            color: var(--text-primary);
        }
        
        .page-header p {
            margin: 5px 0 0 0;
            font-size: 0.85rem;
            color: var(--text-secondary);
        }
        
        .booking-card {
            background: var(--card-bg);
            border-radius: 8px;
            padding: 12px;
            margin-bottom: 10px;
            border: 1px solid rgba(255, 255, 255, 0.1);
            transition: all 0.2s ease;
            display: flex;
            gap: 12px;
            align-items: stretch;
        }
        
        .booking-card:hover {
            border-color: var(--primary-color);
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
        }
        
        .movie-poster {
            width: 60px;
            height: 85px;
            object-fit: cover;
            border-radius: 6px;
            flex-shrink: 0;
        }
        
        .booking-main {
            flex: 1;
            display: flex;
            gap: 15px;
            min-width: 0;
        }
        
        .booking-left {
            flex: 2;
            min-width: 0;
        }
        
        .booking-right {
            flex: 1;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            min-width: 200px;
        }
        
        .booking-header {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 6px;
        }
        
        .booking-code {
            font-size: 0.95rem;
            font-weight: 600;
            color: var(--primary-color);
        }
        
        .booking-date {
            font-size: 0.75rem;
            color: var(--text-secondary);
        }
        
        .movie-title {
            font-size: 1.05rem;
            font-weight: 700;
            color: var(--text-primary);
            margin-bottom: 6px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        
        .screening-info {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
            font-size: 0.8rem;
            color: var(--text-secondary);
            margin-bottom: 6px;
        }
        
        .screening-info-item {
            display: flex;
            align-items: center;
            gap: 5px;
        }
        
        .screening-info-item i {
            color: var(--primary-color);
            font-size: 0.75rem;
        }
        
        .seats-display {
            display: flex;
            flex-wrap: wrap;
            gap: 4px;
            margin-top: 4px;
        }
        
        .seat-badge {
            background: linear-gradient(135deg, var(--primary-color) 0%, var(--accent-color) 100%);
            color: white;
            padding: 2px 8px;
            border-radius: 4px;
            font-size: 0.75rem;
            font-weight: 600;
        }
        
        .price-summary {
            text-align: right;
        }
        
        .price-row {
            display: flex;
            justify-content: space-between;
            font-size: 0.8rem;
            margin-bottom: 4px;
            color: var(--text-secondary);
        }
        
        .total-amount {
            font-size: 1.15rem;
            font-weight: 700;
            color: var(--primary-color);
            margin: 8px 0;
            text-align: right;
        }
        
        .booking-actions {
            display: flex;
            gap: 8px;
            justify-content: flex-end;
            align-items: center;
        }
        
        .status-badge {
            padding: 3px 10px;
            border-radius: 12px;
            font-size: 0.7rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.3px;
            white-space: nowrap;
        }
        
        .status-pending {
            background: linear-gradient(135deg, #ffa500 0%, #ff8c00 100%);
            color: white;
        }
        
        .status-confirmed {
            background: linear-gradient(135deg, #4CAF50 0%, #45a049 100%);
            color: white;
        }
        
        .status-completed {
            background: linear-gradient(135deg, #2196F3 0%, #1976D2 100%);
            color: white;
        }
        
        .status-cancelled {
            background: linear-gradient(135deg, #f44336 0%, #d32f2f 100%);
            color: white;
        }
        
        .payment-badge {
            padding: 2px 8px;
            border-radius: 8px;
            font-size: 0.65rem;
            font-weight: 600;
        }
        
        .payment-completed {
            background: rgba(76, 175, 80, 0.2);
            color: #4CAF50;
            border: 1px solid #4CAF50;
        }
        
        .payment-pending {
            background: rgba(255, 165, 0, 0.2);
            color: #ffa500;
            border: 1px solid #ffa500;
        }
        
        .payment-failed {
            background: rgba(244, 67, 54, 0.2);
            color: #f44336;
            border: 1px solid #f44336;
        }
        
        .filter-tabs {
            display: flex;
            gap: 8px;
            margin-bottom: 12px;
            flex-wrap: wrap;
        }
        
        .filter-tab {
            padding: 6px 14px;
            background: var(--card-bg);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 15px;
            color: var(--text-secondary);
            cursor: pointer;
            transition: all 0.2s ease;
            text-decoration: none;
            font-weight: 500;
            font-size: 0.85rem;
        }
        
        .filter-tab:hover {
            background: rgba(255, 255, 255, 0.05);
            border-color: var(--primary-color);
            color: var(--text-primary);
        }
        
        .filter-tab.active {
            background: linear-gradient(135deg, var(--primary-color) 0%, var(--accent-color) 100%);
            border-color: transparent;
            color: white;
        }
        
        .filter-tab i {
            font-size: 0.75rem;
        }
        
        .empty-state {
            text-align: center;
            padding: 40px 20px;
            color: var(--text-secondary);
        }
        
        .empty-state i {
            font-size: 3rem;
            margin-bottom: 15px;
            opacity: 0.3;
        }
        
        .cancel-btn {
            background: linear-gradient(135deg, #f44336 0%, #d32f2f 100%);
            color: white;
            border: none;
            padding: 4px 10px;
            border-radius: 4px;
            font-size: 0.75rem;
            cursor: pointer;
            transition: all 0.2s ease;
        }
        
        .cancel-btn:hover {
            box-shadow: 0 2px 6px rgba(244, 67, 54, 0.4);
        }
        
        .cancel-btn:disabled {
            background: rgba(255, 255, 255, 0.1);
            color: var(--text-secondary);
            cursor: not-allowed;
        }
        
        .discount-highlight {
            color: #4CAF50;
            font-weight: 600;
        }
        
        .food-items-compact {
            font-size: 0.75rem;
            color: var(--text-secondary);
            margin-top: 4px;
        }
        
        .booking-card {
            cursor: pointer;
            position: relative;
        }
        
        .booking-card::after {
            content: 'Xem chi tiết';
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            background: linear-gradient(135deg, var(--primary-color) 0%, var(--accent-color) 100%);
            color: white;
            padding: 8px 16px;
            border-radius: 6px;
            opacity: 0;
            pointer-events: none;
            transition: opacity 0.3s ease;
            font-size: 0.9rem;
            font-weight: 600;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
            z-index: 10;
        }
        
        .booking-card:hover::after {
            opacity: 0.95;
        }
        
        .booking-card:hover {
            background: linear-gradient(135deg, rgba(37, 40, 54, 0.95) 0%, rgba(37, 40, 54, 0.9) 100%);
        }
        
        /* Modal Styles */
        .modal-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0, 0, 0, 0.8);
            z-index: 9999;
            overflow-y: auto;
            padding: 20px;
        }
        
        .modal-overlay.active {
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .modal-content {
            background: var(--bg-primary);
            border-radius: 12px;
            max-width: 800px;
            width: 100%;
            max-height: 90vh;
            overflow-y: auto;
            position: relative;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.5);
            border: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        .modal-header {
            background: linear-gradient(135deg, var(--primary-color) 0%, var(--accent-color) 100%);
            padding: 20px 25px;
            border-radius: 12px 12px 0 0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .modal-header h2 {
            margin: 0;
            color: white;
            font-size: 1.3rem;
        }
        
        .modal-close {
            background: rgba(255, 255, 255, 0.2);
            border: none;
            color: white;
            width: 35px;
            height: 35px;
            border-radius: 50%;
            cursor: pointer;
            font-size: 1.2rem;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s ease;
        }
        
        .modal-close:hover {
            background: rgba(255, 255, 255, 0.3);
            transform: rotate(90deg);
        }
        
        .modal-body {
            padding: 25px;
        }
        
        .invoice-section {
            margin-bottom: 25px;
        }
        
        .invoice-header {
            display: flex;
            justify-content: space-between;
            align-items: start;
            margin-bottom: 25px;
            padding-bottom: 20px;
            border-bottom: 2px solid rgba(255, 255, 255, 0.1);
        }
        
        .invoice-info h3 {
            margin: 0 0 10px 0;
            color: var(--primary-color);
            font-size: 1.5rem;
        }
        
        .invoice-meta {
            text-align: right;
        }
        
        .invoice-meta p {
            margin: 5px 0;
            color: var(--text-secondary);
            font-size: 0.9rem;
        }
        
        .section-title {
            font-size: 1.1rem;
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .section-title i {
            color: var(--primary-color);
        }
        
        .info-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 15px;
            margin-bottom: 20px;
        }
        
        .info-item {
            background: rgba(255, 255, 255, 0.03);
            padding: 12px;
            border-radius: 8px;
            border: 1px solid rgba(255, 255, 255, 0.05);
        }
        
        .info-label {
            font-size: 0.8rem;
            color: var(--text-secondary);
            margin-bottom: 5px;
        }
        
        .info-value {
            font-size: 1rem;
            color: var(--text-primary);
            font-weight: 500;
        }
        
        .ticket-list {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            margin-top: 10px;
        }
        
        .ticket-item {
            background: linear-gradient(135deg, var(--primary-color) 0%, var(--accent-color) 100%);
            color: white;
            padding: 8px 16px;
            border-radius: 8px;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .food-list {
            margin-top: 15px;
        }
        
        .food-list-item {
            background: rgba(255, 255, 255, 0.03);
            padding: 12px;
            border-radius: 8px;
            margin-bottom: 8px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border: 1px solid rgba(255, 255, 255, 0.05);
        }
        
        .food-list-item .item-name {
            font-weight: 500;
            color: var(--text-primary);
        }
        
        .food-list-item .item-qty {
            color: var(--text-secondary);
            font-size: 0.9rem;
        }
        
        .food-list-item .item-price {
            font-weight: 600;
            color: var(--primary-color);
        }
        
        .price-table {
            background: rgba(255, 255, 255, 0.03);
            border-radius: 8px;
            padding: 15px;
            border: 1px solid rgba(255, 255, 255, 0.05);
        }
        
        .price-table-row {
            display: flex;
            justify-content: space-between;
            padding: 10px 0;
            border-bottom: 1px solid rgba(255, 255, 255, 0.05);
        }
        
        .price-table-row:last-child {
            border-bottom: none;
        }
        
        .price-table-row.total {
            border-top: 2px solid rgba(255, 255, 255, 0.1);
            margin-top: 10px;
            padding-top: 15px;
            font-size: 1.2rem;
            font-weight: 700;
        }
        
        .price-table-row.total .label {
            color: var(--text-primary);
        }
        
        .price-table-row.total .value {
            color: var(--primary-color);
        }
        
        .price-table-row .label {
            color: var(--text-secondary);
        }
        
        .price-table-row .value {
            color: var(--text-primary);
            font-weight: 500;
        }
        
        .discount-row .value {
            color: #4CAF50 !important;
        }
        
        .status-info {
            display: flex;
            gap: 10px;
            margin-top: 15px;
        }
        
        @media (max-width: 992px) {
            .booking-main {
                flex-direction: column;
            }
            .booking-right {
                min-width: unset;
            }
            .info-grid {
                grid-template-columns: 1fr;
            }
        }
        
        @media (max-width: 768px) {
            .booking-card {
                flex-direction: column;
            }
            .movie-poster {
                width: 100%;
                height: 200px;
            }
            .modal-content {
                max-width: 100%;
                margin: 0;
                border-radius: 0;
            }
            .invoice-header {
                flex-direction: column;
                gap: 15px;
            }
            .invoice-meta {
                text-align: left;
            }
        }
    </style>
</head>
<body>
    <!-- Include Navbar -->
    <jsp:include page="/components/navbar.jsp" />
    
    <div class="container-compact">
        <!-- Page Header -->
        <div class="page-header">
            <h1><i class="fas fa-history"></i> Lịch Sử Đặt Vé</h1>
            <p>Quản lý và theo dõi các đơn đặt vé của bạn</p>
        </div>
        
        <!-- Messages -->
        <% if (message != null && !message.isEmpty()) { %>
            <div class="alert-cinema alert-success-cinema" style="margin-bottom: 12px;">
                <i class="fas fa-check-circle"></i> <%= message %>
            </div>
        <% } %>
        <% if (error != null && !error.isEmpty()) { %>
            <div class="alert-cinema alert-danger-cinema" style="margin-bottom: 12px;">
                <i class="fas fa-exclamation-circle"></i> <%= error %>
            </div>
        <% } %>
        
        <!-- Filter Tabs -->
        <div class="filter-tabs">
            <a href="<%= request.getContextPath() %>/booking-history" 
               class="filter-tab <%= "all".equals(statusFilter) ? "active" : "" %>">
                <i class="fas fa-list"></i> Tất cả
            </a>
            <a href="<%= request.getContextPath() %>/booking-history?status=Confirmed" 
               class="filter-tab <%= "Confirmed".equals(statusFilter) ? "active" : "" %>">
                <i class="fas fa-check-circle"></i> Đã xác nhận
            </a>
            <a href="<%= request.getContextPath() %>/booking-history?status=Completed" 
               class="filter-tab <%= "Completed".equals(statusFilter) ? "active" : "" %>">
                <i class="fas fa-calendar-check"></i> Đã hoàn thành
            </a>
            <a href="<%= request.getContextPath() %>/booking-history?status=Cancelled" 
               class="filter-tab <%= "Cancelled".equals(statusFilter) ? "active" : "" %>">
                <i class="fas fa-times-circle"></i> Đã hủy
            </a>
        </div>
                
        <!-- Booking List -->
        <% if (bookingDetails == null || bookingDetails.isEmpty()) { %>
            <div class="empty-state">
                <i class="fas fa-ticket-alt"></i>
                <h3>Chưa có đơn đặt vé nào</h3>
                <p>Hãy đặt vé để xem phim yêu thích của bạn!</p>
                <div style="margin-top: 15px;">
                    <a href="<%= request.getContextPath() %>/booking/select-screening" 
                       class="btn-primary-cinema btn-cinema">
                        Đặt vé ngay
                    </a>
                </div>
            </div>
        <% } else { %>
            <% for (BookingDetailDTO booking : bookingDetails) { %>
                <div class="booking-card" onclick="showBookingDetail(<%= booking.getBookingID() %>)">
                    <!-- Movie Poster -->
                    <% if (booking.getMoviePosterURL() != null && !booking.getMoviePosterURL().isEmpty()) { %>
                        <img src="<%= booking.getMoviePosterURL() %>" alt="<%= booking.getMovieTitle() %>" class="movie-poster">
                    <% } %>
                    
                    <!-- Main Content -->
                    <div class="booking-main">
                        <!-- Left Section -->
                        <div class="booking-left">
                        <div class="booking-header">
                            <span class="booking-code"><%= booking.getBookingCode() %></span>
                            <span class="booking-date">
                                <%= dateFormat.format(java.sql.Timestamp.valueOf(booking.getBookingDate())) %>
                            </span>
                            <% if (!"Completed".equals(booking.getStatus())) { %>
                                <span class="status-badge status-<%= booking.getStatus().toLowerCase() %>">
                                    <%= booking.getStatus() %>
                                </span>
                            <% } %>
                        </div>
                            
                            <div class="movie-title"><%= booking.getMovieTitle() %></div>
                            
                            <div class="screening-info">
                                <div class="screening-info-item">
                                    <i class="fas fa-calendar-alt"></i>
                                    <%= dateOnlyFormat.format(java.sql.Timestamp.valueOf(booking.getScreeningTime())) %>
                                </div>
                                <div class="screening-info-item">
                                    <i class="fas fa-clock"></i>
                                    <%= timeFormat.format(java.sql.Timestamp.valueOf(booking.getScreeningTime())) %>
                                </div>
                                <div class="screening-info-item">
                                    <i class="fas fa-map-marker-alt"></i>
                                    <%= booking.getCinemaName() %> - <%= booking.getRoomName() %>
                                </div>
                            </div>
                            
                            <div class="seats-display">
                                <% for (String seat : booking.getSeatLabels()) { %>
                                    <span class="seat-badge"><%= seat %></span>
                                <% } %>
                            </div>
                            
                            <% if (booking.hasFoodItems()) { %>
                                <div class="food-items-compact">
                                    <i class="fas fa-utensils"></i>
                                    <% 
                                        StringBuilder foodSummary = new StringBuilder();
                                        for (BookingDetailDTO.FoodItemDetail item : booking.getFoodItems()) {
                                            if (foodSummary.length() > 0) foodSummary.append(", ");
                                            foodSummary.append(item.getName()).append(" x").append(item.getQuantity());
                                        }
                                    %>
                                    <%= foodSummary.toString() %>
                                </div>
                            <% } %>
                        </div>
                        
                        <!-- Right Section - Pricing & Actions -->
                        <div class="booking-right">
                            <div class="price-summary">
                                <div class="price-row">
                                    <span>Vé:</span>
                                    <span><%= priceFormat.format(booking.getTicketSubtotal()) %>₫</span>
                                </div>
                                <% if (booking.hasFoodItems()) { %>
                                    <div class="price-row">
                                        <span>Đồ ăn:</span>
                                        <span><%= priceFormat.format(booking.getFoodSubtotal()) %>₫</span>
                                    </div>
                                <% } %>
                                <% if (booking.getDiscountAmount() > 0) { %>
                                    <div class="price-row discount-highlight">
                                        <span>Giảm giá:</span>
                                        <span>-<%= priceFormat.format(booking.getDiscountAmount()) %>₫</span>
                                    </div>
                                <% } %>
                                <div class="total-amount">
                                    <%= priceFormat.format(booking.getFinalAmount()) %>₫
                                </div>
                                <% if (booking.getPaymentMethod() != null && !booking.getPaymentMethod().isEmpty()) { %>
                                    <div class="price-row">
                                        <span style="font-size: 0.7rem;"><i class="fas fa-credit-card"></i> <%= booking.getPaymentMethod() %></span>
                                    </div>
                                <% } %>
                            </div>
                            
                            <div class="booking-actions">
                                <% if (booking.canBeCancelled()) { %>
                                    <form method="post" action="<%= request.getContextPath() %>/booking-history" 
                                          style="display: inline;" 
                                          onsubmit="return confirm('Bạn có chắc chắn muốn hủy đơn đặt vé này?');">
                                        <input type="hidden" name="action" value="cancel">
                                        <input type="hidden" name="bookingID" value="<%= booking.getBookingID() %>">
                                        <button type="submit" class="cancel-btn">
                                            <i class="fas fa-times"></i> Hủy
                                        </button>
                                    </form>
                                <% } %>
                            </div>
                        </div>
                    </div>
                </div>
            <% } %>
        <% } %>
    </div>
    
    <!-- Modal for Booking Details -->
    <div class="modal-overlay" id="bookingModal">
        <div class="modal-content" onclick="event.stopPropagation()">
            <div class="modal-header">
                <h2><i class="fas fa-receipt"></i> Chi Tiết Đơn Đặt Vé</h2>
                <button class="modal-close" onclick="closeModal()">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            <div class="modal-body" id="modalBody">
                <!-- Content will be populated by JavaScript -->
            </div>
        </div>
    </div>
    
    <script>
        // Store booking data for modal
        const bookingsData = {
            <% for (BookingDetailDTO booking : bookingDetails) { %>
                <% boolean isReviewed = reviewedMovieIds.contains(booking.getMovieID()); %>    
                <%= booking.getBookingID() %>: {
                    movieID: <%= booking.getMovieID() %>, 
                    isReviewed: <%= isReviewed %>,
                    
                    bookingID: <%= booking.getBookingID() %>,
                    bookingCode: '<%= booking.getBookingCode() %>',
                    bookingDate: '<%= dateFormat.format(java.sql.Timestamp.valueOf(booking.getBookingDate())) %>',
                    status: '<%= booking.getStatus() %>',
                    paymentStatus: '<%= booking.getPaymentStatus() %>',
                    paymentMethod: '<%= booking.getPaymentMethod() != null ? booking.getPaymentMethod() : "N/A" %>',
                    paymentDate: '<%= booking.getPaymentDate() != null ? dateFormat.format(java.sql.Timestamp.valueOf(booking.getPaymentDate())) : "N/A" %>',
                    movieTitle: '<%= booking.getMovieTitle() %>',
                    moviePosterURL: '<%= booking.getMoviePosterURL() != null ? booking.getMoviePosterURL() : "" %>',
                    movieDuration: <%= booking.getMovieDuration() %>,
                    cinemaName: '<%= booking.getCinemaName() %>',
                    roomName: '<%= booking.getRoomName() %>',
                    screeningTime: '<%= dateOnlyFormat.format(java.sql.Timestamp.valueOf(booking.getScreeningTime())) %> - <%= timeFormat.format(java.sql.Timestamp.valueOf(booking.getScreeningTime())) %>',
                    seats: [<% 
                        boolean first = true;
                        for (String seat : booking.getSeatLabels()) { 
                            if (!first) out.print(", ");
                            out.print("'" + seat + "'");
                            first = false;
                        } 
                    %>],
                    ticketCount: <%= booking.getTicketCount() %>,
                    ticketSubtotal: <%= booking.getTicketSubtotal() %>,
                    foodItems: [
                        <% 
                        boolean firstFood = true;
                        for (BookingDetailDTO.FoodItemDetail item : booking.getFoodItems()) {
                            if (!firstFood) out.print(",");
                        %>
                        {
                            name: '<%= item.getName() %>',
                            quantity: <%= item.getQuantity() %>,
                            unitPrice: <%= item.getUnitPrice() %>,
                            totalPrice: <%= item.getTotalPrice() %>,
                            type: '<%= item.getType() %>'
                        }
                        <%
                            firstFood = false;
                        }
                        %>
                    ],
                    foodSubtotal: <%= booking.getFoodSubtotal() %>,
                    discountAmount: <%= booking.getDiscountAmount() %>,
                    totalAmount: <%= booking.getTotalAmount() %>,
                    finalAmount: <%= booking.getFinalAmount() %>,
                    canBeCancelled: <%= booking.canBeCancelled() %>
                },
            <% } %>
        };
        
        function showBookingDetail(bookingID) {
            const booking = bookingsData[bookingID];
            if (!booking) return;
            
            const modalBody = document.getElementById('modalBody');
            let html = '<div class="invoice-header">';
            html += '<div class="invoice-info">';
            html += '<h3>' + booking.bookingCode + '</h3>';
            html += '<div class="status-info">';
            html += '<span class="status-badge status-' + booking.status.toLowerCase() + '">' + booking.status + '</span>';
            html += '</div></div>';
            html += '<div class="invoice-meta">';
            html += '<p><strong>Ngày đặt:</strong> ' + booking.bookingDate + '</p>';
            if (booking.paymentDate !== 'N/A') {
                html += '<p><strong>Ngày thanh toán:</strong> ' + booking.paymentDate + '</p>';
            }
            html += '</div></div>';
            
            html += '<div class="invoice-section">';
            html += '<div class="section-title"><i class="fas fa-film"></i><span>Thông Tin Phim</span></div>';
            html += '<div class="info-grid">';
            html += '<div class="info-item"><div class="info-label">Tên phim</div><div class="info-value">' + booking.movieTitle + '</div></div>';
            html += '<div class="info-item"><div class="info-label">Thời lượng</div><div class="info-value">' + booking.movieDuration + ' phút</div></div>';
            html += '<div class="info-item"><div class="info-label">Rạp chiếu</div><div class="info-value">' + booking.cinemaName + '</div></div>';
            html += '<div class="info-item"><div class="info-label">Phòng</div><div class="info-value">' + booking.roomName + '</div></div>';
            html += '<div class="info-item" style="grid-column: 1 / -1;"><div class="info-label">Suất chiếu</div>';
            html += '<div class="info-value"><i class="far fa-calendar-alt"></i> ' + booking.screeningTime + '</div></div>';
            html += '</div></div>';
            
            html += '<div class="invoice-section">';
            html += '<div class="section-title"><i class="fas fa-ticket-alt"></i><span>Vé Đã Đặt (' + booking.ticketCount + ' ghế)</span></div>';
            html += '<div class="ticket-list">';
            booking.seats.forEach(function(seat) {
                html += '<div class="ticket-item"><i class="fas fa-couch"></i><span>Ghế ' + seat + '</span></div>';
            });
            html += '</div></div>';
            
            if (booking.foodItems.length > 0) {
                html += '<div class="invoice-section">';
                html += '<div class="section-title"><i class="fas fa-utensils"></i><span>Đồ Ăn & Nước Uống</span></div>';
                html += '<div class="food-list">';
                booking.foodItems.forEach(function(item) {
                    html += '<div class="food-list-item"><div>';
                    html += '<div class="item-name">' + item.name + '</div>';
                    html += '<div class="item-qty">Số lượng: ' + item.quantity + ' × ' + formatPrice(item.unitPrice) + '₫</div>';
                    html += '</div><div class="item-price">' + formatPrice(item.totalPrice) + '₫</div></div>';
                });
                html += '</div></div>';
            }
            
            html += '<div class="invoice-section">';
            html += '<div class="section-title"><i class="fas fa-money-bill-wave"></i><span>Tổng Kết Thanh Toán</span></div>';
            html += '<div class="price-table">';
            html += '<div class="price-table-row">';
            html += '<span class="label">Tổng tiền vé (' + booking.ticketCount + ' ghế)</span>';
            html += '<span class="value">' + formatPrice(booking.ticketSubtotal) + '₫</span></div>';
            
            if (booking.foodSubtotal > 0) {
                html += '<div class="price-table-row">';
                html += '<span class="label">Tổng đồ ăn & nước uống</span>';
                html += '<span class="value">' + formatPrice(booking.foodSubtotal) + '₫</span></div>';
                html += '<div class="price-table-row">';
                html += '<span class="label">Tạm tính</span>';
                html += '<span class="value">' + formatPrice(booking.totalAmount) + '₫</span></div>';
            }
            
            if (booking.discountAmount > 0) {
                html += '<div class="price-table-row discount-row">';
                html += '<span class="label"><i class="fas fa-tags"></i> Giảm giá</span>';
                html += '<span class="value">-' + formatPrice(booking.discountAmount) + '₫</span></div>';
            }
            
            html += '<div class="price-table-row total">';
            html += '<span class="label">Tổng Thanh Toán</span>';
            html += '<span class="value">' + formatPrice(booking.finalAmount) + '₫</span></div>';
            
            if (booking.paymentMethod !== 'N/A') {
                html += '<div class="price-table-row">';
                html += '<span class="label"><i class="fas fa-credit-card"></i> Phương thức thanh toán</span>';
                html += '<span class="value">' + booking.paymentMethod + '</span></div>';
            }
            
            html += '</div></div>';
            
            if (booking.status === 'Completed' && !booking.isReviewed) {
                html += '<div class="invoice-section" style="text-align: center; margin-top: 15px;">';
                html += '<a href="<%= request.getContextPath() %>/writeReview?movieId=' + booking.movieID + '" class="btn-primary-cinema btn-cinema">'; 
                html += '<i class="fas fa-star"></i> Đánh giá phim';
                html += '</a></div>';
            }
            
            if (booking.status === 'Completed' && booking.isReviewed) {
                html += '<div class="invoice-section" style="text-align: center; margin-top: 15px;">';
                html += '<button class="btn-secondary-cinema btn-cinema" disabled style="opacity: 0.7; cursor: not-allowed;">';
                html += '<i class="fas fa-check-circle"></i> Đã đánh giá';
                html += '</button></div>';
            }
            if (booking.canBeCancelled) {
                html += '<div class="invoice-section" style="text-align: right;">';
                html += '<form method="post" action="<%= request.getContextPath() %>/booking-history" style="display: inline;" ';
                html += 'onsubmit="return confirm(\'Bạn có chắc chắn muốn hủy đơn đặt vé này?\');">';
                html += '<input type="hidden" name="action" value="cancel">';
                html += '<input type="hidden" name="bookingID" value="' + booking.bookingID + '">';
                html += '<button type="submit" class="cancel-btn" style="padding: 10px 20px; font-size: 0.9rem;">';
                html += '<i class="fas fa-times"></i> Hủy Đơn Đặt Vé</button></form></div>';
            }
            
            modalBody.innerHTML = html;
            document.getElementById('bookingModal').classList.add('active');
            document.body.style.overflow = 'hidden';
        }
        
        function closeModal() {
            document.getElementById('bookingModal').classList.remove('active');
            document.body.style.overflow = 'auto';
        }
        
        function formatPrice(price) {
            return price.toLocaleString('vi-VN');
        }
        
        // Close modal when clicking outside
        document.getElementById('bookingModal').addEventListener('click', function(e) {
            if (e.target === this) {
                closeModal();
            }
        });
        
        // Close modal with ESC key
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                closeModal();
            }
        });
    </script>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
