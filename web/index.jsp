<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Check if user is logged in
    Object userObj = session.getAttribute("user");
    String userName = (String) session.getAttribute("userName");
    String userRole = (String) session.getAttribute("userRole");
    boolean isLoggedIn = (userObj != null);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customer Dashboard - Cinema Management System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        
        .navbar {
            background: rgba(255, 255, 255, 0.95) !important;
            backdrop-filter: blur(10px);
            box-shadow: 0 2px 20px rgba(0,0,0,0.1);
        }
        
        .navbar-brand {
            font-weight: 700;
            color: #667eea !important;
        }
        
        .welcome-section {
            padding: 60px 0;
            text-align: center;
            color: white;
        }
        
        .welcome-section h1 {
            font-size: 3.5rem;
            font-weight: 300;
            margin-bottom: 20px;
        }
        
        .welcome-section p {
            font-size: 1.3rem;
            opacity: 0.9;
            margin-bottom: 40px;
        }
        
        .dashboard-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 20px;
        }
        
        .feature-card {
            background: white;
            border-radius: 15px;
            padding: 30px;
            margin-bottom: 30px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            transition: all 0.3s ease;
            text-decoration: none;
            color: inherit;
            display: block;
        }
        
        .feature-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 20px 40px rgba(0,0,0,0.15);
            color: inherit;
            text-decoration: none;
        }
        
        .feature-icon {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 20px;
            font-size: 2rem;
            color: white;
        }
        
        .feature-icon.movies {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        
        .feature-icon.profile {
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
        }
        
        .feature-icon.food {
            background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
        }
        
        .feature-icon.bookings {
            background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);
        }
        
        .feature-card h3 {
            color: #333;
            margin-bottom: 15px;
            font-weight: 600;
        }
        
        .feature-card p {
            color: #666;
            margin-bottom: 0;
        }
        
        .user-info {
            background: rgba(255, 255, 255, 0.1);
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 30px;
            color: white;
        }
        
        .user-info h4 {
            margin-bottom: 10px;
        }
        
        .user-info p {
            margin-bottom: 5px;
            opacity: 0.9;
        }
        
        .logout-btn {
            background: #dc3545;
            border: none;
            border-radius: 8px;
            padding: 10px 20px;
            color: white;
            font-weight: 600;
            transition: all 0.3s ease;
        }
        
        .logout-btn:hover {
            background: #c82333;
            transform: translateY(-2px);
        }
        
        .quick-actions {
            background: white;
            border-radius: 15px;
            padding: 30px;
            margin-bottom: 30px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
        }
        
        .quick-actions h3 {
            color: #333;
            margin-bottom: 20px;
            text-align: center;
        }
        
        .action-btn {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border: none;
            border-radius: 10px;
            padding: 15px 25px;
            color: white;
            font-weight: 600;
            text-decoration: none;
            display: inline-block;
            margin: 5px;
            transition: all 0.3s ease;
        }
        
        .action-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 25px rgba(102, 126, 234, 0.3);
            color: white;
            text-decoration: none;
        }
        
        .action-btn.secondary {
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
        }
        
        .action-btn.success {
            background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);
        }
        
        .stats-section {
            background: white;
            border-radius: 15px;
            padding: 30px;
            margin-bottom: 30px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
        }
        
        .stat-item {
            text-align: center;
            padding: 20px;
        }
        
        .stat-number {
            font-size: 2.5rem;
            font-weight: 700;
            color: #667eea;
            margin-bottom: 10px;
        }
        
        .stat-label {
            color: #666;
            font-weight: 500;
        }
        
        /* Non-logged-in user styles */
        .hero-container {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        
        .hero-card {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            overflow: hidden;
            max-width: 600px;
            width: 100%;
            text-align: center;
        }
        
        .hero-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 60px 40px;
        }
        
        .hero-header h1 {
            margin: 0;
            font-size: 3rem;
            font-weight: 300;
        }
        
        .hero-header p {
            margin: 20px 0 0 0;
            opacity: 0.9;
            font-size: 1.2rem;
        }
        
        .hero-content {
            padding: 60px 40px;
        }
        
        .btn-hero {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border: none;
            border-radius: 10px;
            padding: 15px 30px;
            font-size: 18px;
            font-weight: 600;
            color: white;
            margin: 10px;
            transition: all 0.3s ease;
            text-decoration: none;
            display: inline-block;
        }
        
        .btn-hero:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 25px rgba(102, 126, 234, 0.3);
            color: white;
        }
        
        .btn-outline {
            background: transparent;
            border: 2px solid #667eea;
            color: #667eea;
        }
        
        .btn-outline:hover {
            background: #667eea;
            color: white;
        }
        
        .features {
            margin-top: 40px;
        }
        
        .feature-item {
            margin: 20px 0;
            padding: 20px;
            border-radius: 10px;
            background: #f8f9fa;
        }
        
        .feature-item i {
            color: #667eea;
            font-size: 2rem;
            margin-bottom: 15px;
        }
        
        .btn-google {
            background: #4285f4;
            border: none;
            border-radius: 10px;
            padding: 15px 30px;
            font-size: 18px;
            font-weight: 600;
            color: white;
            transition: all 0.3s ease;
            text-decoration: none;
            display: inline-block;
        }
        
        .btn-google:hover {
            background: #3367d6;
            transform: translateY(-2px);
            box-shadow: 0 10px 25px rgba(66, 133, 244, 0.3);
            color: white;
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
    </style>
</head>
<body>
    <% if (isLoggedIn) { %>
        <!-- Logged-in User Experience -->
        <!-- Navigation -->
        <nav class="navbar navbar-expand-lg navbar-light">
            <div class="container">
                <a class="navbar-brand" href="index.jsp">
                    <i class="fas fa-film"></i> Cinema Management
                </a>
                <div class="navbar-nav ms-auto">
                    <span class="navbar-text me-3">
                        Welcome, <%= userName != null ? userName : "Customer" %>!
                    </span>
                    <a href="${pageContext.request.contextPath}/logout" class="logout-btn">
                        <i class="fas fa-sign-out-alt"></i> Logout
                    </a>
                </div>
            </div>
        </nav>

        <!-- Welcome Section -->
        <div class="welcome-section">
            <div class="container">
                <h1><i class="fas fa-home"></i> Customer Dashboard</h1>
                <p>Welcome to your cinema experience hub! Browse movies, manage your bookings, and enjoy the show.</p>
            </div>
        </div>

        <!-- Main Dashboard -->
        <div class="dashboard-container">
            <!-- User Info -->
            <div class="user-info">
                <h4><i class="fas fa-user-circle"></i> Account Information</h4>
                <p><strong>Name:</strong> <%= userName != null ? userName : "Customer" %></p>
                <p><strong>Email:</strong> <%= session.getAttribute("userEmail") != null ? session.getAttribute("userEmail") : "N/A" %></p>
                <p><strong>Role:</strong> <%= userRole != null ? userRole : "Customer" %></p>
            </div>

            <!-- Quick Actions -->
            <div class="quick-actions">
                <h3><i class="fas fa-bolt"></i> Quick Actions</h3>
                <div class="text-center">
                    <a href="${pageContext.request.contextPath}/list" class="action-btn">
                        <i class="fas fa-film"></i> Browse Movies
                    </a>
                    <a href="${pageContext.request.contextPath}/CustomerProfile" class="action-btn secondary">
                        <i class="fas fa-user"></i> My Profile
                    </a>
                    <a href="${pageContext.request.contextPath}/food-management" class="action-btn success">
                        <i class="fas fa-utensils"></i> Food & Drinks
                    </a>
                </div>
            </div>

            <!-- Main Features Grid -->
            <div class="row">
                <div class="col-lg-6 col-md-6 mb-4">
                    <a href="${pageContext.request.contextPath}/list" class="feature-card">
                        <div class="feature-icon movies">
                            <i class="fas fa-film"></i>
                        </div>
                        <h3>Browse Movies</h3>
                        <p>Discover the latest movies, check showtimes, and book your tickets. Find your perfect movie experience.</p>
                    </a>
                </div>
                
                <div class="col-lg-6 col-md-6 mb-4">
                        <a href="${pageContext.request.contextPath}/CustomerProfile" class="feature-card">
                        <div class="feature-icon profile">
                            <i class="fas fa-user"></i>
                        </div>
                        <h3>My Profile</h3>
                        <p>Manage your account settings, view booking history, and update your personal information.</p>
                    </a>
                </div>
                
                <div class="col-lg-6 col-md-6 mb-4">
                    <a href="${pageContext.request.contextPath}/food-management" class="feature-card">
                        <div class="feature-icon food">
                            <i class="fas fa-utensils"></i>
                        </div>
                        <h3>Food & Drinks</h3>
                        <p>Browse our delicious food and beverage options. Order snacks and drinks for your movie experience.</p>
                    </a>
                </div>
                
                <div class="col-lg-6 col-md-6 mb-4">
                    <a href="${pageContext.request.contextPath}/CustomerProfile" class="feature-card">
                        <div class="feature-icon bookings">
                            <i class="fas fa-ticket-alt"></i>
                        </div>
                        <h3>My Bookings</h3>
                        <p>View your current and past bookings, manage reservations, and check your ticket details.</p>
                    </a>
                </div>
            </div>

            <!-- Statistics Section -->
            <div class="stats-section">
                <h3 class="text-center mb-4"><i class="fas fa-chart-bar"></i> Your Activity</h3>
                <div class="row">
                    <div class="col-md-4">
                        <div class="stat-item">
                            <div class="stat-number">0</div>
                            <div class="stat-label">Movies Watched</div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="stat-item">
                            <div class="stat-number">0</div>
                            <div class="stat-label">Tickets Booked</div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="stat-item">
                            <div class="stat-number">0</div>
                            <div class="stat-label">Total Spent</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    <% } else { %>
        <!-- Non-logged-in User Experience -->
        <div class="hero-container">
            <div class="hero-card">
                <div class="hero-header">
                    <h1><i class="fas fa-film"></i> Cinema Management</h1>
                    <p>Your gateway to movie ticket booking and cinema management</p>
                </div>
                
                <div class="hero-content">
                    <h3>Welcome to Our Cinema System</h3>
                    <p class="text-muted">Book movie tickets, manage your account, and enjoy the best cinema experience.</p>
                    
                    <div class="d-flex flex-column flex-md-row justify-content-center">
                        <a href="${pageContext.request.contextPath}/login.jsp" class="btn btn-hero">
                            <i class="fas fa-sign-in-alt"></i> Sign In
                        </a>
                        <a href="${pageContext.request.contextPath}/signup.jsp" class="btn btn-hero btn-outline">
                            <i class="fas fa-user-plus"></i> Sign Up
                        </a>
                    </div>
                    
                    <div class="text-center mt-4">
                        <div class="divider">
                            <span class="divider-text">OR</span>
                        </div>
                    </div>
                    
                    <div class="d-flex justify-content-center">
                        <a href="${pageContext.request.contextPath}/auth/google?action=login" class="btn btn-google">
                            <i class="fab fa-google"></i> Continue with Google
                        </a>
                    </div>
                    
                    <div class="features">
                        <h4>Features</h4>
                        <div class="row">
                            <div class="col-md-4">
                                <div class="feature-item">
                                    <i class="fas fa-ticket-alt"></i>
                                    <h5>Book Tickets</h5>
                                    <p>Easy movie ticket booking system</p>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="feature-item">
                                    <i class="fas fa-user"></i>
                                    <h5>User Management</h5>
                                    <p>Manage your profile and preferences</p>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="feature-item">
                                    <i class="fas fa-film"></i>
                                    <h5>Movie Catalog</h5>
                                    <p>Browse latest movies and showtimes</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    <% } %>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
