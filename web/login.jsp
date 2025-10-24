<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Cinema Management System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/modern-theme.css" rel="stylesheet">
    <style>
        body {
            background: var(--secondary-color);
            min-height: 100vh;
            font-family: var(--font-family-primary);
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .login-container {
            background: rgba(44, 62, 80, 0.9);
            backdrop-filter: blur(20px);
            border-radius: 32px;
            box-shadow: 0 32px 64px rgba(0,0,0,0.4), 0 0 0 1px rgba(255,255,255,0.1);
            overflow: hidden;
            max-width: 400px;
            width: 100%;
            border: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        .login-header {
            background: linear-gradient(135deg, var(--secondary-color) 0%, var(--bg-tertiary) 50%, var(--secondary-dark) 100%);
            color: var(--text-white);
            padding: 40px;
            text-align: center;
        }
        
        .login-header h1 {
            margin: 0;
            font-size: 2rem;
            font-weight: 300;
        }
        
        .login-header p {
            margin: 10px 0 0 0;
            opacity: 0.9;
        }
        
        .login-content {
            padding: 40px;
            background: linear-gradient(180deg, rgba(255,255,255,0.05) 0%, rgba(255,255,255,0.02) 100%);
        }
        
        .login-content label {
            color: var(--accent-color);
            font-weight: 600;
        }
        
        .login-content .form-control {
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(247, 239, 231, 0.084);
            color: var(--accent-color);
            border-radius: 12px;
        }
        
        .login-content .form-control:focus {
            background: rgba(255, 255, 255, 0.15);
            border-color: var(rgba(247, 239, 231, 0.084));
            box-shadow: 0 0 0 3px rgba(247, 239, 231, 0.084);
            color: var(--accent-color);
        }
        
        .login-content .form-control::placeholder {
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
        
        .form-control {
            background: #f7efe7;
            border: 2px solid #f7efe7;
            color: #333;
            border-radius: 10px;
            padding: 12px 15px;
            font-size: 16px;
            transition: all 0.3s ease;
            font-family: 'Inter', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        
        .form-control:focus {
            border-color: #f7efe7;
            box-shadow: 0 0 0 0.2rem rgba(102, 126, 234, 0.25);
        }
        
        .btn-login {
            background: linear-gradient(135deg, var(--primary-color) 0%, var(--primary-color) 100%);
            border: 2px solid var(--primary-color);
            border-radius: 16px;
            padding: 12px 30px;
            font-size: 16px;
            font-weight: 600;
            color: var(--text-white);
            width: 100%;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            box-shadow: 0 0 0;
        }
        
        .btn-login:hover {
            transform: translateY(-4px) scale(1.02);
            box-shadow: 0 8px 24px rgba(92, 190, 143, 0.4);
            color: var(--text-white);
        }
        
        .btn-google {
            background: linear-gradient(135deg, #e74c3c 0%, #c0392b 100%);
            border: 2px solid #e74c3c;
            border-radius: 16px;
            padding: 12px 30px;
            font-size: 16px;
            font-weight: 600;
            color: var(--text-white);
            width: 100%;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            box-shadow: 0 0 0;
            margin-top: 10px;
        }
        
        .btn-google:hover {
            background: linear-gradient(135deg, #c0392b 0%, #a93226 100%);
            transform: translateY(-4px) scale(1.02);
            box-shadow: 0 8px 24px rgba(231, 76, 60, 0.4);
            color: var(--text-white);
        }
        
        .divider {
            position: relative;
            text-align: center;
            margin: 20px 0;
        }
        
        .divider::before {
            content: '';
            position: absolute;
            top: 50%;
            left: 0;
            right: 0;
            height: 1px;
            background: #e1e5e9;
        }
        
        .divider-text {
            background: white;
            padding: 0 20px;
            color: #666;
            font-weight: 500;
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
            color: var(--accent-color);
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
            color: var(--primary-color);
            background: rgba(92, 190, 143, 0.1);
            border-color: var(--primary-color);
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(92, 190, 143, 0.2);
        }
    </style>
</head>
<body>
    <div class="login-container">
        <div class="login-header">
            <h1><i class="fas fa-sign-in-alt"></i> Login</h1>
            <p>Welcome back to Cinema Management</p>
        </div>
        
        <div class="login-content">
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
            
            <form method="POST" action="${pageContext.request.contextPath}/auth/login">
                <div class="form-group">
                    <label for="email" class="form-label">
                        <i class="fas fa-envelope"></i> Email Address
                    </label>
                    <input type="email" class="form-control" id="email" name="email" 
                           placeholder="Enter your email" required>
                </div>
                
                <div class="form-group">
                    <label for="password" class="form-label">
                        <i class="fas fa-lock"></i> Password
                    </label>
                    <input type="password" class="form-control" id="password" name="password" 
                           placeholder="Enter your password" required>
                </div>
                
                <button type="submit" class="btn btn-login">
                    <i class="fas fa-sign-in-alt"></i> Login
                </button>
            </form>
            
            
            <a href="${pageContext.request.contextPath}/auth/google?action=login" class="btn btn-google">
                <i class="fab fa-google"></i> Continue with Google
            </a>
            
            <div class="links">
                <a href="${pageContext.request.contextPath}/auth/forgot-password">Forgot Password?</a>
                <br>
                <a href="${pageContext.request.contextPath}/auth/signup">Don't have an account? Sign up</a>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
