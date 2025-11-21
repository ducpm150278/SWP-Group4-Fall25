<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <!DOCTYPE html>
    <html lang="vi">

    <head>
        <!-- ========== META TAGS ========== -->
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Đăng Nhập - Cinema</title>

        <!-- ========== EXTERNAL STYLESHEETS ========== -->
        <!-- Bootstrap 5.3.3 - Framework CSS cho responsive design -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <!-- Font Awesome 6.0.0 - Icon library -->
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
        <!-- Custom CSS file cho trang login -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/login.css">
    </head>

    <body>
        <!-- ========== MAIN LOGIN CONTAINER ========== -->
        <div class="login-container">
            <!-- ========== HEADER SECTION ========== -->
            <!-- Hiển thị tiêu đề và thông điệp chào mừng -->
            <div class="login-header">
                <h1><i class="fas fa-sign-in-alt"></i> Đăng Nhập</h1>
                <p>Chào mừng trở lại Cinema</p>
            </div>

            <!-- ========== LOGIN FORM CONTENT ========== -->
            <div class="login-content">
                <%  //==========XỬ LÝ THÔNG BÁO LỖI & THÀNH CÔNG==========
                    // Lấy thông báo lỗi từ request attribute (do servlet gửi về) 
                    String error=(String) request.getAttribute("error"); 
                    // Lấy thông báo thành công (ví dụ: đăng ký thành công) 
                    String success=(String) request.getAttribute("success"); 
                    // Lấy thông báo lỗi đăng nhập từ session 
                    String loginMessage=(String) session.getAttribute("loginMessage"); 
                    // Nếu có loginMessage trong session, xóa nó sau khi hiển thị 
                    if (loginMessage !=null) {  
                        session.removeAttribute("loginMessage"); 
                    } 
                %>

                    <!-- ========== HIỂN THỊ THÔNG BÁO LỖI TỪ SESSION ========== -->
                    <!-- Ưu tiên hiển thị loginMessage từ session trước -->
                    <% if (loginMessage !=null) { %>
                        <div class="alert alert-danger">
                            <i class="fas fa-exclamation-circle"></i>
                            <%= loginMessage %>
                        </div>
                        <% } else if (error !=null) { %>
                            <!-- Hiển thị lỗi từ request attribute nếu không có loginMessage -->
                            <div class="alert alert-danger">
                                <i class="fas fa-exclamation-circle"></i>
                                <%= error %>
                            </div>
                            <% } %>

                                <!-- ========== HIỂN THỊ THÔNG BÁO THÀNH CÔNG ========== -->
                                <!-- Ví dụ: "Đăng ký thành công, vui lòng đăng nhập" -->
                                <% if (success !=null) { %>
                                    <div class="alert alert-success">
                                        <i class="fas fa-check-circle"></i>
                                        <%= success %>
                                    </div>
                                    <% } %>

                                        <!-- ========== FORM ĐĂNG NHẬP ========== -->
                                        <!-- Form gửi POST request đến servlet LoginServlet -->
                                        <form method="POST" action="${pageContext.request.contextPath}/auth/login">
                                            <!-- Input Email -->
                                            <div class="form-group">
                                                <label for="email" class="form-label">
                                                    <i class="fas fa-envelope"></i> Địa chỉ Email
                                                </label>
                                                <input type="email" class="form-control" id="email" name="email"
                                                    placeholder="Nhập email của bạn" required>
                                            </div>

                                            <!-- Input Password -->
                                            <div class="form-group">
                                                <label for="password" class="form-label">
                                                    <i class="fas fa-lock"></i> Mật khẩu
                                                </label>
                                                <input type="password" class="form-control" id="password"
                                                    name="password" placeholder="Nhập mật khẩu" required>
                                            </div>

                                            <!-- Submit Button -->
                                            <button type="submit" class="btn btn-login">
                                                <i class="fas fa-sign-in-alt"></i> Đăng Nhập
                                            </button>
                                        </form>

                                        <!-- ========== DIVIDER ========== -->
                                        <div class="divider">
                                            <span class="divider-text">HOẶC</span>
                                        </div>

                                        <!-- ========== GOOGLE LOGIN BUTTON ========== -->
                                        <!-- Đăng nhập qua Google OAuth -->
                                        <a href="${pageContext.request.contextPath}/auth/google?action=login"
                                            class="btn btn-google">
                                            <i class="fab fa-google"></i> Tiếp tục với Google
                                        </a>

                                        <!-- ========== NAVIGATION LINKS ========== -->
                                        <!-- Link đến trang quên mật khẩu và đăng ký -->
                                        <div class="links">
                                            <a href="${pageContext.request.contextPath}/auth/forgot-password">Quên mật
                                                khẩu?</a>
                                            |
                                            <a href="${pageContext.request.contextPath}/auth/signup">Đăng ký tài khoản
                                                mới</a>
                                        </div>
            </div>
        </div>

        <!-- ========== JAVASCRIPT LIBRARIES ========== -->
        <!-- Bootstrap Bundle JS - Bao gồm Popper.js cho các component -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>

    </html>