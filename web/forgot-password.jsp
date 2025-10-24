<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Forgot Password - Cinema Management System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/modern-theme.css" rel="stylesheet">
    <style>
        body {
            background: #334457;
            min-height: 100vh;
            font-family: 'Inter', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .forgot-container {
            background: rgba(44, 62, 80, 0.9);
            backdrop-filter: blur(20px);
            border-radius: 32px;
            box-shadow: 0 32px 64px rgba(0,0,0,0.4), 0 0 0 1px rgba(255,255,255,0.1);
            overflow: hidden;
            max-width: 400px;
            width: 100%;
            border: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        .forgot-header {
            background: linear-gradient(135deg, #334457 0%, #4a5a6b 50%, #2a3744 100%);
            color: #ffffff;
            padding: 40px;
            text-align: center;
        }
        
        .forgot-header h1 {
            margin: 0;
            font-size: 2rem;
            font-weight: 300;
        }
        
        .forgot-header p {
            margin: 10px 0 0 0;
            opacity: 0.9;
        }
        
        .forgot-content {
            padding: 40px;
            background: linear-gradient(180deg, rgba(255,255,255,0.05) 0%, rgba(255,255,255,0.02) 100%);
        }
        
        .forgot-content label {
            color: #f7efe7;
            font-weight: 600;
            font-family: 'Inter', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        
        .forgot-content .form-control {
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(247, 239, 231, 0.084);
            color: #f7efe7;
            border-radius: 12px;
        }
        
        .forgot-content .form-control:focus {
            background: rgba(255, 255, 255, 0.15);
            border-color: rgba(247, 239, 231, 0.084);
            box-shadow: 0 0 0 3px rgba(247, 239, 231, 0.084);
            color: #f7efe7;
        }
        
        .forgot-content .form-control::placeholder {
            color: rgba(247, 239, 231, 0.6);
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-label {
            font-weight: 600;
            color: #f7efe7;
            margin-bottom: 8px;
            font-family: 'Inter', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        
        .btn-reset {
            background: linear-gradient(135deg, #5cbe8f 0%, #5cbe8f 100%);
            border: 2px solid #5cbe8f;
            border-radius: 16px;
            padding: 12px 30px;
            font-size: 16px;
            font-weight: 600;
            color: #ffffff;
            width: 100%;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            box-shadow: 0 0 0;
        }
        
        .btn-reset:hover {
            transform: translateY(-4px) scale(1.02);
            box-shadow: 0 8px 24px rgba(92, 190, 143, 0.4);
            color: #ffffff;
        }
        
        .alert {
            border-radius: 10px;
            border: none;
            padding: 15px;
            margin-bottom: 20px;
        }
        
        .alert-danger {
            background: #f8d7da;
            color: #721c24;
        }
        
        .alert-success {
            background: #d4edda;
            color: #155724;
        }
        
        .links {
            text-align: center;
            margin-top: 20px;
        }
        
        .links a {
            color: #f7efe7;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s ease;
            display: inline-block;
            margin: 5px 0;
            padding: 8px 16px;
            border-radius: 8px;
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        .links a:hover {
            color: #5cbe8f;
            background: rgba(92, 190, 143, 0.1);
            border-color: #5cbe8f;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(92, 190, 143, 0.2);
        }
        
        .info-box {
            background: rgba(255, 255, 255, 0.08);
            border-radius: 12px;
            padding: 20px;
            margin-bottom: 20px;
            border-left: 4px solid #5cbe8f;
        }
        
        .info-box {
            color: #f7efe7;
        }
        
        .info-box i {
            color: #5cbe8f;
            margin-right: 10px;
        }
        
        .info-box strong {
            color: #f7efe7;
        }
    </style>
</head>
<body>
    <div class="forgot-container">
        <div class="forgot-header">
            <h1><i class="fas fa-key"></i> Forgot Password</h1>
            <p>Reset your password</p>
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
                <strong>How it works:</strong> Enter your email address and we'll send you a link to reset your password.
            </div>
            
            <form method="POST" action="${pageContext.request.contextPath}/auth/forgot-password">
                <div class="form-group">
                    <label for="email" class="form-label">
                        <i class="fas fa-envelope"></i> Email Address
                    </label>
                    <input type="email" class="form-control" id="email" name="email" 
                           placeholder="Enter your email address" required>
                </div>
                
                <button type="submit" class="btn btn-reset">
                    <i class="fas fa-paper-plane"></i> Send Reset Link
                </button>
            </form>
            
            <div class="links">
                <a href="${pageContext.request.contextPath}/auth/login">Back to Login</a>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
