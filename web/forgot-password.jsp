<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <!DOCTYPE html>
    <html lang="vi">

    <head>
        <!-- ========== META TAGS ========== -->
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Quên Mật Khẩu - Cinema Booking</title>

        <!-- ========== EXTERNAL STYLESHEETS ========== -->
        <!-- Bootstrap 5.3.3 - Framework CSS cho responsive design -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <!-- Font Awesome 6.0.0 - Icon library -->
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
        <!-- Custom CSS file cho trang forgot password -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/forgot-password.css">
    </head>

    <body>
        <!-- ========== MAIN FORGOT PASSWORD CONTAINER ========== -->
        <div class="forgot-container">
            <!-- ========== HEADER SECTION ========== -->
            <!-- Hiển thị tiêu đề và mục đích của trang -->
            <div class="forgot-header">
                <h1><i class="fas fa-key"></i> Quên Mật Khẩu</h1>
                <p>Khôi phục mật khẩu của bạn</p>
            </div>

            <!-- ========== FORGOT PASSWORD CONTENT ========== -->
            <div class="forgot-content">
                <%  //==========XỬ LÝ THÔNG BÁO LỖI & THÀNH CÔNG==========
                    // Lấy thông báo lỗi từ request attribute (ví dụ: email không tồn tại) 
                    String error=(String) request.getAttribute("error"); 
                    // Lấy thông báo thành công (ví dụ: đã gửi email thành công) 
                    String success=(String) request.getAttribute("success"); 
                %>

                    <!-- ========== HIỂN THỊ THÔNG BÁO LỖI ========== -->
                    <!-- Hiển thị khi email không tồn tại hoặc có lỗi xảy ra -->
                    <% if (error !=null) { %>
                        <div class="alert alert-danger">
                            <i class="fas fa-exclamation-circle"></i>
                            <%= error %>
                        </div>
                        <% } %>

                            <!-- ========== HIỂN THỊ THÔNG BÁO THÀNH CÔNG ========== -->
                            <!-- Hiển thị khi email khôi phục đã được gửi thành công -->
                            <% if (success !=null) { %>
                                <div class="alert alert-success">
                                    <i class="fas fa-check-circle"></i>
                                    <%= success %>
                                </div>
                                <% } %>

                                    <!-- ========== INFORMATION BOX ========== -->
                                    <!-- Hướng dẫn cho người dùng về quy trình khôi phục mật khẩu -->
                                    <div class="info-box">
                                        <i class="fas fa-info-circle"></i>
                                        <strong>Cách hoạt động:</strong> Nhập địa chỉ email của bạn và chúng tôi sẽ gửi
                                        cho bạn link để đặt lại mật khẩu.
                                    </div>

                                    <!-- ========== FORGOT PASSWORD FORM ========== -->
                                    <!-- Form gửi POST request đến servlet ForgotPasswordServlet -->
                                    <form method="POST"
                                        action="${pageContext.request.contextPath}/auth/forgot-password">
                                        <!-- Input Email -->
                                        <div class="form-group">
                                            <label for="email" class="form-label">
                                                <i class="fas fa-envelope"></i> Địa chỉ Email
                                            </label>
                                            <input type="email" class="form-control" id="email" name="email"
                                                placeholder="Nhập địa chỉ email của bạn" required>
                                        </div>

                                        <!-- Submit Button - Gửi email khôi phục -->
                                        <button type="submit" class="btn btn-reset">
                                            <i class="fas fa-paper-plane"></i> Gửi Link Đặt Lại
                                        </button>
                                    </form>

                                    <!-- ========== NAVIGATION LINK ========== -->
                                    <!-- Link quay lại trang đăng nhập -->
                                    <div class="links">
                                        <a href="${pageContext.request.contextPath}/auth/login">← Quay lại Đăng nhập</a>
                                    </div>
            </div>
        </div>

        <!-- ========== JAVASCRIPT LIBRARIES ========== -->
        <!-- Bootstrap Bundle JS - Bao gồm Popper.js cho các component -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>

    </html>