<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign Up - Cinema Management System</title>
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
            padding: 15px 0;
        }
        
        .signup-container {
            background: rgba(44, 62, 80, 0.9);
            backdrop-filter: blur(20px);
            border-radius: 24px;
            box-shadow: 0 32px 64px rgba(0,0,0,0.4), 0 0 0 1px rgba(255,255,255,0.1);
            overflow-y: auto;
            max-width: 700px;
            max-height: 95vh;
            width: 100%;
            border: 1px solid rgba(255, 255, 255, 0.1);
            scrollbar-width: thin;
            scrollbar-color: rgba(92, 190, 143, 0.5) rgba(255, 255, 255, 0.1);
        }
        
        .signup-container::-webkit-scrollbar {
            width: 8px;
        }
        
        .signup-container::-webkit-scrollbar-track {
            background: rgba(255, 255, 255, 0.05);
            border-radius: 10px;
        }
        
        .signup-container::-webkit-scrollbar-thumb {
            background: rgba(92, 190, 143, 0.5);
            border-radius: 10px;
        }
        
        .signup-container::-webkit-scrollbar-thumb:hover {
            background: rgba(92, 190, 143, 0.7);
        }
        
        .signup-header {
            background: linear-gradient(135deg, #334457 0%, #4a5a6b 50%, #2a3744 100%);
            color: #ffffff;
            padding: 25px 30px;
            text-align: center;
        }
        
        .signup-header h1 {
            margin: 0;
            font-size: 1.6rem;
            font-weight: 300;
        }
        
        .signup-header p {
            margin: 8px 0 0 0;
            opacity: 0.9;
            font-size: 0.9rem;
        }
        
        .signup-content {
            padding: 25px 30px;
            background: linear-gradient(180deg, rgba(255,255,255,0.05) 0%, rgba(255,255,255,0.02) 100%);
        }
        
        .signup-content label {
            color: #f7efe7;
            font-weight: 600;
            font-family: 'Inter', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        
        .signup-content .form-control {
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(247, 239, 231, 0.084);
            color: #f7efe7;
            border-radius: 12px;
            padding: 12px 15px;
            font-size: 16px;
            font-family: 'Inter', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            transition: all 0.3s ease;
        }
        
        .signup-content .form-control:focus {
            background: rgba(255, 255, 255, 0.15);
            border-color: rgba(247, 239, 231, 0.084);
            box-shadow: 0 0 0 3px rgba(247, 239, 231, 0.084);
            color: #f7efe7;
        }
        
        .signup-content .form-control::placeholder {
            color: rgba(247, 239, 231, 0.6);
        }
        
        .signup-content .form-select {
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(247, 239, 231, 0.084);
            color: rgba(247, 239, 231, 0.6);
            border-radius: 12px;
            padding: 12px 15px;
            font-size: 16px;
            font-family: 'Inter', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            transition: all 0.3s ease;
        }
        
        .signup-content .form-select:valid {
            color: #f7efe7;
        }
        
        .signup-content .form-select:focus {
            background: rgba(255, 255, 255, 0.15);
            border-color: rgba(247, 239, 231, 0.084);
            box-shadow: 0 0 0 3px rgba(247, 239, 231, 0.084);
            color: #f7efe7;
        }
        
        .signup-content .form-select option {
            color: #333;
            background: white;
        }
        
        .signup-content .form-select option:first-child {
            color: #999;
        }
        
        .form-group {
            margin-bottom: 12px;
        }
        
        .form-label {
            font-weight: 600;
            color: #f7efe7;
            margin-bottom: 5px;
            font-size: 0.9rem;
            font-family: 'Inter', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        
        
        .btn-signup {
            background: linear-gradient(135deg, #5cbe8f 0%, #5cbe8f 100%);
            border: 2px solid #5cbe8f;
            border-radius: 12px;
            padding: 10px 24px;
            font-size: 15px;
            font-weight: 600;
            color: #ffffff;
            width: 100%;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            box-shadow: 0 0 0;
            margin-top: 8px;
        }
        
        .btn-signup:hover {
            transform: translateY(-2px) scale(1.01);
            box-shadow: 0 6px 20px rgba(92, 190, 143, 0.4);
            color: #ffffff;
        }
        
        .btn-google {
            background: linear-gradient(135deg, #e74c3c 0%, #c0392b 100%);
            border: 2px solid #e74c3c;
            border-radius: 12px;
            padding: 10px 24px;
            font-size: 15px;
            font-weight: 600;
            color: #ffffff;
            width: 100%;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            box-shadow: 0 0 0;
            margin-top: 8px;
            text-decoration: none;
            display: block;
            text-align: center;
        }
        
        .btn-google:hover {
            background: linear-gradient(135deg, #c0392b 0%, #a93226 100%);
            transform: translateY(-2px) scale(1.01);
            box-shadow: 0 6px 20px rgba(231, 76, 60, 0.4);
            color: #ffffff;
            text-decoration: none;
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
            margin-top: 12px;
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
        
        .row {
            margin: 0 -10px;
        }
        
        .col-md-6 {
            padding: 0 10px;
        }
    </style>
</head>
<body>
    <div class="signup-container">
        <div class="signup-header">
            <h1><i class="fas fa-user-plus"></i> Sign Up</h1>
            <p>Create your Cinema Management account</p>
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
                                <i class="fas fa-user"></i> Full Name *
                            </label>
                            <input type="text" class="form-control" id="fullName" name="fullName" 
                                   placeholder="Enter your full name" required>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="form-group">
                            <label for="email" class="form-label">
                                <i class="fas fa-envelope"></i> Email Address *
                            </label>
                            <input type="email" class="form-control" id="email" name="email" 
                                   placeholder="Enter your email" required>
                        </div>
                    </div>
                </div>
                
                <div class="row">
                    <div class="col-md-6">
                        <div class="form-group">
                            <label for="phoneNumber" class="form-label">
                                <i class="fas fa-phone"></i> Phone Number
                            </label>
                            <input type="tel" class="form-control" id="phoneNumber" name="phoneNumber" 
                                   placeholder="Enter your phone number">
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="form-group">
                            <label for="gender" class="form-label">
                                <i class="fas fa-venus-mars"></i> Gender
                            </label>
                            <select class="form-select" id="gender" name="gender">
                                <option value="" disabled selected style="color: #999;">Select Gender</option>
                                <option value="Male">Male</option>
                                <option value="Female">Female</option>
                                <option value="Other">Other</option>
                            </select>
                        </div>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="address" class="form-label">
                        <i class="fas fa-map-marker-alt"></i> Address
                    </label>
                    <input type="text" class="form-control" id="address" name="address" 
                           placeholder="Enter your address">
                </div>
                
                <div class="form-group">
                    <label for="dateOfBirth" class="form-label">
                        <i class="fas fa-calendar"></i> Date of Birth
                    </label>
                    <input type="date" class="form-control" id="dateOfBirth" name="dateOfBirth">
                </div>
                
                <div class="row">
                    <div class="col-md-6">
                        <div class="form-group">
                            <label for="password" class="form-label">
                                <i class="fas fa-lock"></i> Password *
                            </label>
                            <input type="password" class="form-control" id="password" name="password" 
                                   placeholder="Enter password" required>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="form-group">
                            <label for="confirmPassword" class="form-label">
                                <i class="fas fa-lock"></i> Confirm Password *
                            </label>
                            <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" 
                                   placeholder="Confirm password" required>
                        </div>
                    </div>
                </div>
                
                <button type="submit" class="btn btn-signup">
                    <i class="fas fa-user-plus"></i> Create Account
                </button>
            </form>
            
            
            <a href="${pageContext.request.contextPath}/auth/google?action=signup" class="btn btn-google">
                <i class="fab fa-google"></i> Sign up with Google
            </a>
            
            <div class="links">
                <a href="${pageContext.request.contextPath}/auth/login">Already have an account? Login</a>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
