<!-- 
    File: payment-failed.jsp
    Mô tả: Trang hiển thị thông báo thanh toán thất bại
    Chức năng:
    - Hiển thị thông báo lỗi thanh toán
    - Hiển thị mã lỗi từ VNPay (nếu có)
    - Cung cấp các tùy chọn: Thử lại, Đặt vé mới, Về trang chủ
    - Liệt kê các nguyên nhân có thể gây lỗi thanh toán
-->
<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <!DOCTYPE html>
    <html lang="vi">

    <head>
        <!-- Thiết lập encoding và responsive -->
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Thanh Toán Thất Bại - Cinema Booking</title>

        <!-- Import CSS frameworks và custom styles -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/payment-failed.css">
    </head>

    <body>
        <!-- 
        Lấy thông tin lỗi từ request attributes:
        - error: Thông báo lỗi chi tiết từ servlet
        - responseCode: Mã lỗi trả về từ VNPay
    -->
        <% String error=(String) request.getAttribute("error"); String responseCode=(String)
            request.getAttribute("responseCode"); %>

            <!-- Container chính của trang thanh toán thất bại -->
            <div class="failed-container">
                <!-- Icon dấu X màu đỏ thể hiện thất bại -->
                <div class="failed-icon">
                    <i class="fas fa-times"></i>
                </div>

                <!-- Tiêu đề và mô tả lỗi -->
                <h1>Thanh Toán Thất Bại!</h1>
                <p class="subtitle">Đã có lỗi xảy ra trong quá trình thanh toán</p>

                <!-- Hiển thị box thông báo lỗi nếu có -->
                <% if (error !=null) { %>
                    <div class="error-box">
                        <!-- Thông báo lỗi với icon cảnh báo -->
                        <p><i class="fas fa-exclamation-triangle"></i>
                            <%= error %>
                        </p>

                        <!-- Hiển thị mã lỗi từ VNPay nếu có -->
                        <% if (responseCode !=null) { %>
                            <span class="error-code">Mã lỗi: <%= responseCode %></span>
                            <% } %>
                    </div>
                    <% } %>

                        <!-- Các nút hành động cho người dùng -->
                        <div class="action-buttons">
                            <!-- Nút thử lại thanh toán (quay về trang payment) -->
                            <a href="${pageContext.request.contextPath}/booking/payment"
                                class="btn-custom btn-primary-custom">
                                <i class="fas fa-redo"></i> Thử Lại
                            </a>

                            <!-- Nút đặt vé mới (bắt đầu lại từ đầu) -->
                            <a href="${pageContext.request.contextPath}/booking/select-screening"
                                class="btn-custom btn-secondary-custom">
                                <i class="fas fa-arrow-left"></i> Đặt Vé Mới
                            </a>

                            <!-- Nút quay về trang chủ -->
                            <a href="${pageContext.request.contextPath}/index.jsp"
                                class="btn-custom btn-secondary-custom">
                                <i class="fas fa-home"></i> Về Trang Chủ
                            </a>
                        </div>

                        <!-- Phần hướng dẫn liệt kê các nguyên nhân có thể gây lỗi -->
                        <div class="help-section">
                            <h3><i class="fas fa-question-circle"></i> Nguyên nhân có thể gây lỗi:</h3>
                            <ul>
                                <!-- Liệt kê các lý do phổ biến khiến thanh toán thất bại -->
                                <li><i class="fas fa-check-circle"></i> Hủy giao dịch trong quá trình thanh toán</li>
                                <li><i class="fas fa-check-circle"></i> Tài khoản không đủ số dư</li>
                                <li><i class="fas fa-check-circle"></i> Thông tin xác thực không chính xác</li>
                                <li><i class="fas fa-check-circle"></i> Thẻ/tài khoản chưa đăng ký Internet Banking</li>
                                <li><i class="fas fa-check-circle"></i> Hết thời gian chờ thanh toán</li>
                            </ul>
                        </div>
            </div>
    </body>

    </html>