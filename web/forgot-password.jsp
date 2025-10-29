<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quên Mật Khẩu - Cinema Booking</title>
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
        
        .forgot-container {
            background: #1a1d24;
            border-radius: 16px;
            border: 1px solid #2a2d35;
            overflow: hidden;
            max-width: 450px;
            width: 100%;
            box-shadow: 0 20px 60px rgba(0,0,0,0.5);
        }
        
        .forgot-header {
            background: linear-gradient(135deg, #e50914 0%, #b20710 100%);
            padding: 40px 30px;
            text-align: center;
        }
        
        .forgot-header h1 {
            margin: 0;
            font-size: 28px;
            font-weight: 700;
            color: #fff;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
        }
        
        .forgot-header p {
            margin: 10px 0 0 0;
            opacity: 0.95;
            color: #fff;
            font-size: 15px;
        }
        
        .forgot-content {
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
        
        .btn-reset {
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
        
        .btn-reset:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 30px rgba(229, 9, 20, 0.4);
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
        
        .info-box {
            background: rgba(229, 9, 20, 0.1);
            border-radius: 8px;
            padding: 15px;
            margin-bottom: 20px;
            border-left: 4px solid #e50914;
            font-size: 14px;
        }
        
        .info-box i {
            color: #e50914;
            margin-right: 10px;
        }
        
        .info-box strong {
            color: #fff;
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
            font-size: 14px;
        }
        
        .links a:hover {
            color: #ff2030;
            text-decoration: underline;
        }
        
        @media (max-width: 480px) {
            .forgot-header h1 {
                font-size: 24px;
            }
            
            .forgot-content {
                padding: 25px 20px;
            }
        }
    </style>
</head>
<body>
    <div class="forgot-container">
        <div class="forgot-header">
            <h1><i class="fas fa-key"></i> Quên Mật Khẩu</h1>
            <p>Khôi phục mật khẩu của bạn</p>
        </div>
        
        <div class="forgot-content">
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
            
            <div class="info-box">
                <i class="fas fa-info-circle"></i>
                <strong>Cách hoạt động:</strong> Nhập địa chỉ email của bạn và chúng tôi sẽ gửi cho bạn link để đặt lại mật khẩu.
            </div>
            
            <form method="POST" action="${pageContext.request.contextPath}/auth/forgot-password">
                <div class="form-group">
                    <label for="email" class="form-label">
                        <i class="fas fa-envelope"></i> Địa chỉ Email
                    </label>
                    <input type="email" class="form-control" id="email" name="email" 
                           placeholder="Nhập địa chỉ email của bạn" required>
                </div>
                
                <button type="submit" class="btn btn-reset">
                    <i class="fas fa-paper-plane"></i> Gửi Link Đặt Lại
                </button>
            </form>
            
            <div class="links">
                <a href="${pageContext.request.contextPath}/auth/login">← Quay lại Đăng nhập</a>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
