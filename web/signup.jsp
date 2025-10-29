<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng Ký - Cinema Booking</title>
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
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 30px 15px;
        }
        
        .signup-container {
            background: #1a1d24;
            border-radius: 16px;
            border: 1px solid #2a2d35;
            overflow-y: auto;
            max-width: 750px;
            max-height: 95vh;
            width: 100%;
            box-shadow: 0 20px 60px rgba(0,0,0,0.5);
        }
        
        
        
        .signup-header {
            background: linear-gradient(135deg, #e50914 0%, #b20710 100%);
            padding: 35px 30px;
            text-align: center;
        }
        
        .signup-header h1 {
            margin: 0;
            font-size: 28px;
            font-weight: 700;
            color: #fff;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
        }
        
        .signup-header p {
            margin: 10px 0 0 0;
            opacity: 0.95;
            color: #fff;
            font-size: 15px;
        }
        
        .signup-content {
            padding: 30px;
        }
        
        .form-group {
            margin-bottom: 18px;
        }
        
        .form-label {
            font-weight: 600;
            color: #fff;
            margin-bottom: 8px;
            font-size: 14px;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .form-label i {
            color: #e50914;
        }
        
        .form-control,
        .form-select {
            background: #2a2d35;
            border: 1px solid #3a3d45;
            color: #fff;
            border-radius: 8px;
            padding: 12px 15px;
            font-size: 15px;
            transition: all 0.3s ease;
        }
        
        .form-control:focus,
        .form-select:focus {
            background: #2a2d35;
            border-color: #e50914;
            color: #fff;
            box-shadow: 0 0 0 0.2rem rgba(229, 9, 20, 0.25);
            outline: none;
        }
        
        .form-control::placeholder {
            color: #8b92a7;
        }
        
        .form-select {
            color: #8b92a7;
        }
        
        .form-select:valid {
            color: #fff;
        }
        
        .form-select option {
            background: #2a2d35;
            color: #fff;
        }
        
        .form-select option:first-child {
            color: #8b92a7;
        }
        
        .btn-signup {
            background: linear-gradient(135deg, #e50914 0%, #b20710 100%);
            border: none;
            border-radius: 8px;
            padding: 14px 30px;
            font-size: 16px;
            font-weight: 600;
            color: #fff;
            width: 100%;
            transition: all 0.3s ease;
            margin-top: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
        }
        
        .btn-signup:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 30px rgba(229, 9, 20, 0.4);
        }
        
        .divider {
            position: relative;
            text-align: center;
            margin: 25px 0;
        }
        
        .divider::before {
            content: '';
            position: absolute;
            top: 50%;
            left: 0;
            right: 0;
            height: 1px;
            background: #2a2d35;
        }
        
        .divider-text {
            background: #1a1d24;
            padding: 0 15px;
            color: #8b92a7;
            font-weight: 500;
            position: relative;
            font-size: 13px;
        }
        
        .btn-google {
            background: #fff;
            border: 1px solid #2a2d35;
            border-radius: 8px;
            padding: 12px 30px;
            font-size: 15px;
            font-weight: 600;
            color: #333;
            width: 100%;
            transition: all 0.3s ease;
            text-decoration: none;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
        }
        
        .btn-google:hover {
            background: #f8f9fa;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
            color: #333;
        }
        
        .btn-google i {
            color: #4285f4;
        }
        
        .alert {
            border-radius: 8px;
            border: none;
            padding: 12px 15px;
            margin-bottom: 20px;
            font-size: 14px;
        }
        
        .alert-danger {
            background: rgba(229, 9, 20, 0.2);
            color: #ff6b6b;
            border-left: 4px solid #e50914;
        }
        
        .alert-success {
            background: rgba(46, 160, 67, 0.2);
            color: #3fb950;
            border-left: 4px solid #2ea043;
        }
        
        .links {
            text-align: center;
            margin-top: 20px;
        }
        
        .links a {
            color: #e50914;
            text-decoration: none;
            font-weight: 500;
            transition: all 0.3s ease;
            display: inline-block;
            font-size: 14px;
        }
        
        .links a:hover {
            color: #ff2030;
            text-decoration: underline;
        }
        
        .row {
            margin: 0 -10px;
        }
        
        .col-md-6 {
            padding: 0 10px;
        }
        
        @media (max-width: 768px) {
            .signup-header h1 {
                font-size: 24px;
            }
            
            .signup-content {
                padding: 25px 20px;
            }
            
            .col-md-6 {
                padding: 0;
            }
        }
        
        /* Hide Scrollbar */
        ::-webkit-scrollbar {
            display: none;
        }
        
        /* Hide scrollbar for IE, Edge and Firefox */
        html, body {
            -ms-overflow-style: none;  /* IE and Edge */
            scrollbar-width: none;  /* Firefox */
        }
        
        .signup-container::-webkit-scrollbar {
            display: none;
        }
    </style>
</head>
<body>
    <div class="signup-container">
        <div class="signup-header">
            <h1><i class="fas fa-user-plus"></i> Đăng Ký</h1>
            <p>Tạo tài khoản Cinema Booking của bạn</p>
        </div>
        
        <div class="signup-content">
            <% 
                String error = (String) request.getAttribute("error");
                String success = (String) request.getAttribute("success");
            %>
            
            <% if (error != null) { %>
                <div class="alert alert-danger">
                    <i class="fas fa-exclamation-circle"></i> <%= error %>
                </div>
            <% } %>
            
            <% if (success != null) { %>
                <div class="alert alert-success">
                    <i class="fas fa-check-circle"></i> <%= success %>
                </div>
            <% } %>
            
            <form method="POST" action="${pageContext.request.contextPath}/auth/signup">
                <div class="row">
                    <div class="col-md-6">
                        <div class="form-group">
                            <label for="fullName" class="form-label">
                                <i class="fas fa-user"></i> Họ và tên *
                            </label>
                            <input type="text" class="form-control" id="fullName" name="fullName" 
                                   placeholder="Nhập họ và tên" required>
                        </div>
                    </div>
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
                
                <div class="row">
                    <div class="col-md-6">
                        <div class="form-group">
                            <label for="phoneNumber" class="form-label">
                                <i class="fas fa-phone"></i> Số điện thoại
                            </label>
                            <input type="tel" class="form-control" id="phoneNumber" name="phoneNumber" 
                                   placeholder="Nhập số điện thoại">
                        </div>
                    </div>
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
                
                <div class="form-group">
                    <label for="address" class="form-label">
                        <i class="fas fa-map-marker-alt"></i> Địa chỉ
                    </label>
                    <input type="text" class="form-control" id="address" name="address" 
                           placeholder="Nhập địa chỉ của bạn">
                </div>
                
                <div class="form-group">
                    <label for="dateOfBirth" class="form-label">
                        <i class="fas fa-calendar"></i> Ngày sinh
                    </label>
                    <input type="date" class="form-control" id="dateOfBirth" name="dateOfBirth">
                </div>
                
                <div class="row">
                    <div class="col-md-6">
                        <div class="form-group">
                            <label for="password" class="form-label">
                                <i class="fas fa-lock"></i> Mật khẩu *
                            </label>
                            <input type="password" class="form-control" id="password" name="password" 
                                   placeholder="Nhập mật khẩu" required>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="form-group">
                            <label for="confirmPassword" class="form-label">
                                <i class="fas fa-lock"></i> Xác nhận mật khẩu *
                            </label>
                            <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" 
                                   placeholder="Nhập lại mật khẩu" required>
                        </div>
                    </div>
                </div>
                
                <button type="submit" class="btn btn-signup">
                    <i class="fas fa-user-plus"></i> Tạo Tài Khoản
                </button>
            </form>
            
            <div class="divider">
                <span class="divider-text">HOẶC</span>
            </div>
            
            <a href="${pageContext.request.contextPath}/auth/google?action=signup" class="btn btn-google">
                <i class="fab fa-google"></i> Đăng ký với Google
            </a>
            
            <div class="links">
                <a href="${pageContext.request.contextPath}/auth/login">Đã có tài khoản? Đăng nhập ngay</a>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
