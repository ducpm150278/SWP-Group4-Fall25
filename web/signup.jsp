<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <!DOCTYPE html>
    <html lang="vi">

    <head>
        <!-- ========== META TAGS ========== -->
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Đăng Ký - Cinema Booking</title>

        <!-- ========== EXTERNAL STYLESHEETS ========== -->
        <!-- Bootstrap 5.3.3 - Framework CSS cho responsive design và grid system -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <!-- Font Awesome 6.0.0 - Icon library -->
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
        <!-- Custom CSS file cho trang signup -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/signup.css">
    </head>

    <body>
        <!-- ========== MAIN SIGNUP CONTAINER ========== -->
        <div class="signup-container">
            <!-- ========== HEADER SECTION ========== -->
            <!-- Hiển thị tiêu đề và thông điệp chào mừng -->
            <div class="signup-header">
                <h1><i class="fas fa-user-plus"></i> Đăng Ký</h1>
                <p>Tạo tài khoản Cinema Booking của bạn</p>
            </div>

            <!-- ========== SIGNUP FORM CONTENT ========== -->
            <div class="signup-content">
                <%  //==========XỬ LÝ THÔNG BÁO LỖI & THÀNH CÔNG==========
                    // Lấy thông báo lỗi từ request attribute (ví dụ: email đã tồn tại) 
                    String error=(String) request.getAttribute("error");
                    // Lấy thông báo thành công (ví dụ: đăng ký thành công) 
                    String success=(String) request.getAttribute("success"); 
                %>

                    <!-- ========== HIỂN THỊ THÔNG BÁO LỖI ========== -->
                    <!-- Hiển thị nếu có lỗi xảy ra (email trùng, mật khẩu không khớp, v.v.) -->
                    <% if (error !=null) { %>
                        <div class="alert alert-danger">
                            <i class="fas fa-exclamation-circle"></i>
                            <%= error %>
                        </div>
                        <% } %>

                            <!-- ========== HIỂN THỊ THÔNG BÁO THÀNH CÔNG ========== -->
                            <% if (success !=null) { %>
                                <div class="alert alert-success">
                                    <i class="fas fa-check-circle"></i>
                                    <%= success %>
                                </div>
                                <% } %>

                                    <!-- ========== FORM ĐĂNG KÝ ========== -->
                                    <!-- Form gửi POST request đến servlet SignupServlet -->
                                    <form method="POST" action="${pageContext.request.contextPath}/auth/signup">
                                        <!-- ========== HÀNG 1: HỌ TÊN VÀ EMAIL (Required) ========== -->
                                        <div class="row">
                                            <!-- Cột trái: Họ và tên -->
                                            <div class="col-md-6">
                                                <div class="form-group">
                                                    <label for="fullName" class="form-label">
                                                        <i class="fas fa-user"></i> Họ và tên *
                                                    </label>
                                                    <input type="text" class="form-control" id="fullName"
                                                        name="fullName" placeholder="Nhập họ và tên" required>
                                                </div>
                                            </div>
                                            <!-- Cột phải: Email -->
                                            <div class="col-md-6">
                                                <div class="form-group">
                                                    <label for="email" class="form-label">
                                                        <i class="fas fa-envelope"></i> Địa chỉ Email *
                                                    </label>
                                                    <input type="email" class="form-control" id="email" name="email"
                                                        placeholder="Nhập email của bạn" required>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- ========== HÀNG 2: SỐ ĐIỆN THOẠI VÀ GIỚI TÍNH (Optional) ========== -->
                                        <div class="row">
                                            <!-- Cột trái: Số điện thoại -->
                                            <div class="col-md-6">
                                                <div class="form-group">
                                                    <label for="phoneNumber" class="form-label">
                                                        <i class="fas fa-phone"></i> Số điện thoại
                                                    </label>
                                                    <input type="tel" class="form-control" id="phoneNumber"
                                                        name="phoneNumber" placeholder="Nhập số điện thoại">
                                                </div>
                                            </div>
                                            <!-- Cột phải: Giới tính (dropdown select) -->
                                            <div class="col-md-6">
                                                <div class="form-group">
                                                    <label for="gender" class="form-label">
                                                        <i class="fas fa-venus-mars"></i> Giới tính
                                                    </label>
                                                    <select class="form-select" id="gender" name="gender">
                                                        <option value="" disabled selected>Chọn giới tính</option>
                                                        <option value="Male">Nam</option>
                                                        <option value="Female">Nữ</option>
                                                        <option value="Other">Khác</option>
                                                    </select>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- ========== ĐỊA CHỈ (Optional) ========== -->
                                        <div class="form-group">
                                            <label for="address" class="form-label">
                                                <i class="fas fa-map-marker-alt"></i> Địa chỉ
                                            </label>
                                            <input type="text" class="form-control" id="address" name="address"
                                                placeholder="Nhập địa chỉ của bạn">
                                        </div>

                                        <!-- ========== NGÀY SINH (Optional) ========== -->
                                        <div class="form-group">
                                            <label for="dateOfBirth" class="form-label">
                                                <i class="fas fa-calendar"></i> Ngày sinh
                                            </label>
                                            <input type="date" class="form-control" id="dateOfBirth" name="dateOfBirth">
                                        </div>

                                        <!-- ========== HÀNG 3: MẬT KHẨU VÀ XÁC NHẬN MẬT KHẨU (Required) ========== -->
                                        <div class="row">
                                            <!-- Cột trái: Mật khẩu -->
                                            <div class="col-md-6">
                                                <div class="form-group">
                                                    <label for="password" class="form-label">
                                                        <i class="fas fa-lock"></i> Mật khẩu *
                                                    </label>
                                                    <input type="password" class="form-control" id="password"
                                                        name="password" placeholder="Nhập mật khẩu" required>
                                                </div>
                                            </div>
                                            <!-- Cột phải: Xác nhận mật khẩu -->
                                            <div class="col-md-6">
                                                <div class="form-group">
                                                    <label for="confirmPassword" class="form-label">
                                                        <i class="fas fa-lock"></i> Xác nhận mật khẩu *
                                                    </label>
                                                    <input type="password" class="form-control" id="confirmPassword"
                                                        name="confirmPassword" placeholder="Nhập lại mật khẩu" required>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- ========== SUBMIT BUTTON ========== -->
                                        <button type="submit" class="btn btn-signup">
                                            <i class="fas fa-user-plus"></i> Tạo Tài Khoản
                                        </button>
                                    </form>

                                    <!-- ========== DIVIDER ========== -->
                                    <div class="divider">
                                        <span class="divider-text">HOẶC</span>
                                    </div>

                                    <!-- ========== GOOGLE SIGNUP BUTTON ========== -->
                                    <!-- Đăng ký qua Google OAuth -->
                                    <a href="${pageContext.request.contextPath}/auth/google?action=signup"
                                        class="btn btn-google">
                                        <i class="fab fa-google"></i> Đăng ký với Google
                                    </a>

                                    <!-- ========== NAVIGATION LINK ========== -->
                                    <!-- Link quay lại trang đăng nhập nếu đã có tài khoản -->
                                    <div class="links">
                                        <a href="${pageContext.request.contextPath}/auth/login">Đã có tài khoản? Đăng
                                            nhập ngay</a>
                                    </div>
            </div>
        </div>

        <!-- ========== JAVASCRIPT LIBRARIES ========== -->
        <!-- Bootstrap Bundle JS - Bao gồm Popper.js và các component JS -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>

    </html>