<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng Nhập - Cinema</title>
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
            padding: 20px;
        }
        
        .login-container {
            background: #1a1d24;
            border-radius: 16px;
            border: 1px solid #2a2d35;
            overflow: hidden;
            max-width: 450px;
            width: 100%;
            box-shadow: 0 20px 60px rgba(0,0,0,0.5);
        }
        
        .login-header {
            background: linear-gradient(135deg, #e50914 0%, #b20710 100%);
            padding: 40px 30px;
            text-align: center;
        }
        
        .login-header h1 {
            margin: 0;
            font-size: 28px;
            font-weight: 700;
            color: #fff;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
        }
        
        .login-header p {
            margin: 10px 0 0 0;
            opacity: 0.95;
            color: #fff;
            font-size: 15px;
        }
        
        .login-content {
            padding: 35px 30px;
        }
        
        .form-group {
            margin-bottom: 20px;
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
        
        .form-control {
            background: #2a2d35;
            border: 1px solid #3a3d45;
            color: #fff;
            border-radius: 8px;
            padding: 12px 15px;
            font-size: 15px;
            transition: all 0.3s ease;
        }
        
        .form-control:focus {
            background: #2a2d35;
            border-color: #e50914;
            color: #fff;
            box-shadow: 0 0 0 0.2rem rgba(229, 9, 20, 0.25);
            outline: none;
        }
        
        .form-control::placeholder {
            color: #8b92a7;
        }
        
        .btn-login {
            background: linear-gradient(135deg, #e50914 0%, #b20710 100%);
            border: none;
            border-radius: 8px;
            padding: 14px 30px;
            font-size: 16px;
            font-weight: 600;
            color: #fff;
            width: 100%;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
        }
        
        .btn-login:hover {
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
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            text-decoration: none;
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
            margin-top: 25px;
        }
        
        .links a {
            color: #e50914;
            text-decoration: none;
            font-weight: 500;
            transition: all 0.3s ease;
            display: inline-block;
            margin: 5px 10px;
            font-size: 14px;
        }
        
        .links a:hover {
            color: #ff2030;
            text-decoration: underline;
        }
        
        @media (max-width: 480px) {
            .login-header h1 {
                font-size: 24px;
            }
            
            .login-content {
                padding: 25px 20px;
            }
        }
    </style>
</head>
<body>
    <div class="login-container">
        <div class="login-header">
            <h1><i class="fas fa-sign-in-alt"></i> Đăng Nhập</h1>
            <p>Chào mừng trở lại Cinema</p>
        </div>
        
        <div class="login-content">
            <% 
                String error = (String) request.getAttribute("error");
                String success = (String) request.getAttribute("success");
                String loginMessage = (String) session.getAttribute("loginMessage");
                if (loginMessage != null) {
                    session.removeAttribute("loginMessage");
                }
            %>
            
            <% if (loginMessage != null) { %>
                <div class="alert alert-danger">
                    <i class="fas fa-exclamation-circle"></i> <%= loginMessage %>
                </div>
            <% } else if (error != null) { %>
                <div class="alert alert-danger">
                    <i class="fas fa-exclamation-circle"></i> <%= error %>
                </div>
            <% } %>
            
            <% if (success != null) { %>
                <div class="alert alert-success">
                    <i class="fas fa-check-circle"></i> <%= success %>
                </div>
            <% } %>
            
            <form method="POST" action="${pageContext.request.contextPath}/auth/login">
                <div class="form-group">
                    <label for="email" class="form-label">
                        <i class="fas fa-envelope"></i> Địa chỉ Email
                    </label>
                    <input type="email" class="form-control" id="email" name="email" 
                           placeholder="Nhập email của bạn" required>
                </div>
                
                <div class="form-group">
                    <label for="password" class="form-label">
                        <i class="fas fa-lock"></i> Mật khẩu
                    </label>
                    <input type="password" class="form-control" id="password" name="password" 
                           placeholder="Nhập mật khẩu" required>
                </div>
                
                <button type="submit" class="btn btn-login">
                    <i class="fas fa-sign-in-alt"></i> Đăng Nhập
                </button>
            </form>
            
            <div class="divider">
                <span class="divider-text">HOẶC</span>
            </div>
            
            <a href="${pageContext.request.contextPath}/auth/google?action=login" class="btn btn-google">
                <i class="fab fa-google"></i> Tiếp tục với Google
            </a>
            
            <div class="links">
                <a href="${pageContext.request.contextPath}/auth/forgot-password">Quên mật khẩu?</a>
                |
                <a href="${pageContext.request.contextPath}/auth/signup">Đăng ký tài khoản mới</a>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
