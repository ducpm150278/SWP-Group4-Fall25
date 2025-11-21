<!-- 
    File: payment-success.jsp
    Mô tả: Trang hiển thị thông báo thanh toán thành công
    Chức năng:
    - Hiển thị xác nhận thanh toán thành công
    - Hiển thị thông tin đơn hàng (mã đơn hàng, mã giao dịch VNPay)
    - Hiển thị chi tiết đặt vé (phim, ghế, tổng tiền)
    - Cung cấp link xem vé và quay về trang chủ
    - Thông báo email đã được gửi
-->
<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@page import="entity.BookingSession" %>
        <!DOCTYPE html>
        <html lang="vi">

        <head>
            <!-- Thiết lập encoding và responsive -->
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Thanh Toán Thành Công - Cinema Booking</title>

            <!-- Import CSS frameworks và custom styles -->
            <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
            <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/payment-success.css">
        </head>

        <body>
            <!-- 
        Lấy thông tin thanh toán từ request attributes:
        - bookingSession: Thông tin phiên đặt vé (đã hoàn tất)
        - orderID: Mã đơn hàng của hệ thống
        - transactionNo: Mã giao dịch VNPay
        - amount: Số tiền đã thanh toán (VNĐ)
    -->
            <% BookingSession bookingSession=(BookingSession) request.getAttribute("bookingSession"); 
            String orderID=(String) request.getAttribute("orderID"); 
            String transactionNo=(String) request.getAttribute("transactionNo"); 
            Long amount=(Long) request.getAttribute("amount"); %>

                <!-- Container chính của trang thanh toán thành công -->
                <div class="success-container">
                    <!-- Icon dấu check màu xanh thể hiện thành công -->
                    <div class="success-icon">
                        <i class="fas fa-check"></i>
                    </div>

                    <!-- Tiêu đề và thông báo chúc mừng -->
                    <h1>Thanh Toán Thành Công!</h1>
                    <p class="subtitle">Đặt vé của bạn đã được xác nhận. Vui lòng kiểm tra email để nhận thông tin vé.
                    </p>

                    <!-- Box hiển thị thông tin đơn hàng -->
                    <div class="info-box">
                        <!-- Mã đơn hàng của hệ thống (dùng để nhận vé tại rạp) -->
                        <div class="info-row">
                            <span class="info-label"><i class="fas fa-hashtag"></i> Mã đơn hàng</span>
                            <span class="info-value highlight">
                                <%= orderID !=null ? orderID : "N/A" %>
                            </span>
                        </div>

                        <!-- Mã giao dịch từ VNPay (dùng để đối soát) -->
                        <div class="info-row">
                            <span class="info-label"><i class="fas fa-receipt"></i> Mã giao dịch VNPay</span>
                            <span class="info-value">
                                <%= transactionNo !=null ? transactionNo : "N/A" %>
                            </span>
                        </div>

                        <!-- Tổng số tiền đã thanh toán -->
                        <% if (amount !=null) { %>
                            <div class="info-row">
                                <span class="info-label"><i class="fas fa-money-bill-wave"></i> Tổng thanh toán</span>
                                <span class="info-value highlight">
                                    <%= String.format("%,d đ", amount) %>
                                </span>
                            </div>
                            <% } %>

                                <!-- Hiển thị thông tin đặt vé nếu có bookingSession -->
                                <% if (bookingSession !=null) { %>
                                    <!-- Tên phim đã đặt -->
                                    <div class="info-row">
                                        <span class="info-label"><i class="fas fa-film"></i> Phim</span>
                                        <span class="info-value">
                                            <%= bookingSession.getMovieTitle() %>
                                        </span>
                                    </div>

                                    <!-- Danh sách ghế đã chọn -->
                                    <div class="info-row">
                                        <span class="info-label"><i class="fas fa-couch"></i> Ghế</span>
                                        <span class="info-value">
                                            <%= String.join(", ", bookingSession.getSelectedSeatLabels()) %></span>
            </div>
            <% } %>
        </div>
        
        <!-- Thông báo về email đã được gửi -->
        <div class=" note">
                                                <i class="fas fa-envelope"></i>
                                                <strong>Thông tin vé đã được gửi đến email của bạn.</strong><br>
                                                Vui lòng mang theo mã đơn hàng khi đến rạp.
                                    </div>

                                    <!-- Các nút hành động -->
                                    <div class="action-buttons">
                                        <!-- Nút xem lịch sử đặt vé -->
                                        <a href="${pageContext.request.contextPath}/booking-history"
                                            class="btn-custom btn-primary-custom">
                                            <i class="fas fa-ticket-alt"></i> Xem Vé Của Tôi
                                        </a>

                                        <!-- Nút quay về trang chủ -->
                                        <a href="${pageContext.request.contextPath}/index.jsp"
                                            class="btn-custom btn-secondary-custom">
                                            <i class="fas fa-home"></i> Về Trang Chủ
                                        </a>
                                    </div>
                    </div>
        </body>

        </html>