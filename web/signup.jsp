<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign Up - Cinema Management System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            padding: 20px 0;
        }
        
        .signup-container {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            overflow: hidden;
            max-width: 500px;
            width: 100%;
            margin: 0 auto;
        }
        
        .signup-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 40px;
            text-align: center;
        }
        
        .signup-header h1 {
            margin: 0;
            font-size: 2rem;
            font-weight: 300;
        }
        
        .signup-header p {
            margin: 10px 0 0 0;
            opacity: 0.9;
        }
        
        .signup-content {
            padding: 40px;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-label {
            font-weight: 600;
            color: #333;
            margin-bottom: 8px;
        }
        
        .form-control {
            border: 2px solid #e1e5e9;
            border-radius: 10px;
            padding: 12px 15px;
            font-size: 16px;
            transition: all 0.3s ease;
        }
        
        .form-control:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 0.2rem rgba(102, 126, 234, 0.25);
        }
        
        .form-select {
            border: 2px solid #e1e5e9;
            border-radius: 10px;
            padding: 12px 15px;
            font-size: 16px;
            transition: all 0.3s ease;
        }
        
        .form-select:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 0.2rem rgba(102, 126, 234, 0.25);
        }
        
        .btn-signup {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border: none;
            border-radius: 10px;
            padding: 12px 30px;
            font-size: 16px;
            font-weight: 600;
            color: white;
            width: 100%;
            transition: all 0.3s ease;
        }
        
        .btn-signup:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 25px rgba(102, 126, 234, 0.3);
        }
        
        .btn-google {
            background: #4285f4;
            border: none;
            border-radius: 10px;
            padding: 12px 30px;
            font-size: 16px;
            font-weight: 600;
            color: white;
            width: 100%;
            transition: all 0.3s ease;
            margin-top: 10px;
        }
        
        .btn-google:hover {
            background: #3367d6;
            transform: translateY(-2px);
            box-shadow: 0 10px 25px rgba(66, 133, 244, 0.3);
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
            color: #667eea;
            text-decoration: none;
            font-weight: 500;
        }
        
        .links a:hover {
            text-decoration: underline;
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
                                <option value="Other">Select Gender</option>
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
            
            <div class="divider">
                <span class="divider-text">OR</span>
            </div>
            
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
