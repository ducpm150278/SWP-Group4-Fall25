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
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/modern-theme.css" rel="stylesheet">
    <style>
        /* Enhanced Welcome Section */
        .welcome-section {
            padding: 60px 0 80px 0;
            text-align: center;
            color: #f7efe7;
            position: relative;
            overflow: hidden;
            background: linear-gradient(135deg, #334457 0%, #4a5a6b 50%, #2a3744 100%);
            margin-bottom: 50px;
        }
        
        .welcome-section::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(45deg, transparent 30%, rgba(255, 255, 255, 0.1) 50%, transparent 70%);
            animation: shimmer 3s infinite;
        }
        
        .welcome-section h1 {
            font-size: 4rem;
            font-weight: 800;
            margin-bottom: 20px;
            text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
            animation: fadeInUp 1s ease-out;
            color: #f7efe7;
            position: relative;
            z-index: 1;
        }
        
        .welcome-section p {
            font-size: 1.4rem;
            opacity: 0.95;
            margin-bottom: 0;
            animation: fadeInUp 1s ease-out 0.2s both;
            font-weight: 500;
            color: #f7efe7;
            position: relative;
            z-index: 1;
        }
        
        .dashboard-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 20px 50px 20px;
        }
        
        /* Enhanced Feature Cards */
        .feature-card {
            background: var(--bg-primary);
            border-radius: 24px;
            padding: 45px;
            margin-bottom: 35px;
            box-shadow: var(--shadow-lg);
            transition: var(--transition-normal);
            text-decoration: none;
            color: inherit;
            display: block;
            position: relative;
            overflow: hidden;
            border: 2px solid var(--bg-tertiary);
        }
        
        .feature-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: var(--primary-gradient);
            opacity: 0;
            transition: var(--transition-normal);
            z-index: 1;
        }
        
        .feature-card:hover::before {
            opacity: 0.05;
        }
        
        .feature-card:hover {
            transform: translateY(-4px) scale(1.01);
            box-shadow: var(--shadow-xl);
            border-color: var(--primary-color);
            color: inherit;
            text-decoration: none;
        }
        
        .feature-card-content {
            position: relative;
            z-index: 2;
        }
        
        .feature-icon {
            width: 100px;
            height: 100px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 25px;
            font-size: 2.5rem;
            color: white;
            box-shadow: var(--shadow-md);
            transition: var(--transition-normal);
        }
        
        .feature-card:hover .feature-icon {
            transform: scale(1.1) rotate(5deg);
        }
        
        .feature-icon.movies {
            background: linear-gradient(135deg, #5cbe8f 0%, #4a9b7a 100%);
        }
        
        .feature-icon.profile {
            background: linear-gradient(135deg, #4a5a6b 0%, #5a6e84 100%);
        }
        
        .feature-icon.food {
            background: linear-gradient(135deg, #f8b500 0%, #e09e00 100%);
        }
        
        .feature-icon.combo {
            background: linear-gradient(135deg, #5cbe8f 0%, #4a9b7a 100%);
        }
        
        .feature-icon.admin {
            background: linear-gradient(135deg, #4a5a6b 0%, #5a6e84 100%);
        }
        
        .feature-title {
            font-size: 1.5rem;
            font-weight: 700;
            color: var(--text-primary);
            margin-bottom: 15px;
            text-align: center;
        }

        .feature-description {
            color: var(--text-muted);
            text-align: center;
            line-height: 1.6;
            font-size: 1.1rem;
        }
        
        /* Enhanced Stats Section */
        .stats-section {
            background: var(--bg-secondary);
            border-radius: 24px;
            padding: 40px;
            margin: 40px 0;
            border: 2px solid var(--accent-color);
            box-shadow: var(--shadow-md);
        }
        
        .stat-item {
            text-align: center;
            color: var(--text-primary);
        }
        
        .stat-number {
            font-size: 3rem;
            font-weight: 800;
            margin-bottom: 10px;
            color: var(--primary-color);
        }
        
        .stat-label {
            font-size: 1.2rem;
            color: var(--text-muted);
            font-weight: 500;
        }
        
        /* Enhanced Quick Actions */
        .quick-actions {
            background: var(--bg-primary);
            border-radius: 24px;
            padding: 40px;
            margin: 40px 0;
            box-shadow: var(--shadow-lg);
            border: 2px solid var(--primary-color);
        }
        
        .quick-actions h3 {
            color: var(--text-primary);
            font-weight: 700;
            margin-bottom: 30px;
            text-align: center;
            font-size: 2rem;
        }
        
        .action-btn {
            background: var(--primary-color);
            border: 2px solid var(--primary-color);
            border-radius: 15px;
            padding: 15px 30px;
            color: var(--text-on-primary);
            font-weight: 600;
            font-size: 1.1rem;
            transition: var(--transition-normal);
            text-decoration: none;
            display: inline-block;
            margin: 10px;
            position: relative;
            overflow: hidden;
            box-shadow: var(--shadow-sm);
        }
        
        .action-btn::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
            transition: left 0.5s;
        }
        
        .action-btn:hover::before {
            left: 100%;
        }
        
        .action-btn:hover {
            background: var(--secondary-color);
            border-color: var(--secondary-color);
            transform: translateY(-2px);
            box-shadow: var(--shadow-md);
            color: var(--text-on-secondary);
        }
        
        .action-btn i {
            margin-right: 10px;
        }
        
        /* Enhanced Footer */
        .footer {
            background: rgba(0, 0, 0, 0.1);
            backdrop-filter: blur(20px);
            border-top: 1px solid rgba(255, 255, 255, 0.2);
            padding: 40px 0;
            margin-top: 60px;
            text-align: center;
            color: white;
        }
        
        .footer p {
            margin: 0;
            opacity: 0.8;
            font-size: 1.1rem;
        }
        
        /* Responsive Design */
        @media (max-width: 768px) {
            .welcome-section h1 {
                font-size: 2.5rem;
            }
            
            .welcome-section p {
                font-size: 1.2rem;
            }
            
            .feature-card {
                padding: 30px 20px;
            }
            
            .feature-icon {
                width: 80px;
                height: 80px;
                font-size: 2rem;
            }
            
            .stat-number {
                font-size: 2rem;
            }
            
            .action-btn {
                width: 100%;
                margin: 5px 0;
            }
        }
        
        @media (max-width: 576px) {
            .welcome-section {
                padding: 60px 0;
            }
            
            .welcome-section h1 {
                font-size: 2rem;
            }
            
            .feature-card {
                padding: 25px 15px;
            }
            
            .stats-section {
                padding: 30px 20px;
            }
            
            .quick-actions {
                padding: 30px 20px;
            }
        }
        
        .feature-icon.bookings {
            background: linear-gradient(135deg, #6c63ff 0%, #5a52d5 100%);
        }
        
        .feature-card h3 {
            color: #f7efe7;
            margin-bottom: 15px;
            font-weight: 600;
        }
        
        .feature-card p {
            color: #f7efe7;
            margin-bottom: 0;
            opacity: 0.9;
        }
        
        .navbar-text {
            color: #f7efe7 !important;
            font-weight: 500;
            font-size: 1rem;
            display: flex;
            align-items: center;
            margin-right: 20px !important;
        }
        
        .navbar-nav {
            display: flex;
            align-items: center;
        }
        
        .user-info {
            background: rgba(44, 62, 80, 0.9);
            border-radius: 16px;
            padding: 25px;
            margin-bottom: 30px;
            color: #f7efe7;
            border: 1px solid rgba(255, 255, 255, 0.1);
            box-shadow: 0 8px 24px rgba(0,0,0,0.2);
        }
        
        .user-info h4 {
            margin-bottom: 20px;
            color: #f7efe7;
            font-weight: 600;
        }
        
        .user-info p {
            margin-bottom: 12px;
            opacity: 0.95;
            color: #f7efe7;
        }
        
        .user-info strong {
            color: #5cbe8f;
        }
        
        .logout-btn {
            background: linear-gradient(135deg, #e74c3c 0%, #c0392b 100%);
            border: 2px solid #e74c3c;
            border-radius: 12px;
            padding: 10px 20px;
            color: white;
            font-weight: 600;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            box-shadow: 0 0 0;
            text-decoration: none;
            margin-top: 5px;
        }
        
        .logout-btn:hover {
            background: linear-gradient(135deg, #c0392b 0%, #a93226 100%);
            transform: translateY(-2px) scale(1.02);
            box-shadow: 0 6px 20px rgba(231, 76, 60, 0.4);
            color: white;
        }
        
        .quick-actions {
            background: rgba(44, 62, 80, 0.9);
            border-radius: 20px;
            padding: 40px;
            margin-bottom: 40px;
            box-shadow: 0 16px 40px rgba(0,0,0,0.3);
            border: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        .quick-actions h3 {
            color: #f7efe7;
            margin-bottom: 30px;
            text-align: center;
            font-weight: 700;
        }
        
        .action-btn {
            background: linear-gradient(135deg, #5cbe8f 0%, #5cbe8f 100%);
            border: 2px solid #5cbe8f;
            border-radius: 12px;
            padding: 12px 24px;
            color: white;
            font-weight: 600;
            text-decoration: none;
            display: inline-block;
            margin: 8px;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            box-shadow: 0 0 0;
        }
        
        .action-btn:hover {
            background: linear-gradient(135deg, #4a9b7a 0%, #4a9b7a 100%);
            border-color: #4a9b7a;
            transform: translateY(-2px) scale(1.02);
            box-shadow: 0 8px 24px rgba(92, 190, 143, 0.4);
            color: white !important;
            text-decoration: none;
        }
        
        .action-btn.secondary {
            background: linear-gradient(135deg, #e74c3c 0%, #c0392b 100%);
            border-color: #e74c3c;
        }
        
        .action-btn.secondary:hover {
            background: linear-gradient(135deg, #c0392b 0%, #a93226 100%);
            border-color: #c0392b;
            box-shadow: 0 8px 24px rgba(231, 76, 60, 0.4);
            color: white !important;
        }
        
        .action-btn.success {
            background: linear-gradient(135deg, #5cbe8f 0%, #4a9b7a 100%);
            border-color: #5cbe8f;
        }
        
        .action-btn.success:hover {
            background: linear-gradient(135deg, #4a9b7a 0%, #3d8263 100%);
            border-color: #4a9b7a;
            box-shadow: 0 8px 24px rgba(92, 190, 143, 0.4);
            color: white !important;
        }
        
        .stats-section {
            background: rgba(44, 62, 80, 0.9);
            border-radius: 20px;
            padding: 40px;
            margin-bottom: 40px;
            box-shadow: 0 16px 40px rgba(0,0,0,0.3);
            border: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        .stats-section h3 {
            color: #f7efe7;
            font-weight: 700;
            margin-bottom: 30px;
        }
        
        .stat-item {
            text-align: center;
            padding: 25px 20px;
        }
        
        .stat-number {
            font-size: 2.5rem;
            font-weight: 700;
            color: #5cbe8f;
            margin-bottom: 10px;
        }
        
        .stat-label {
            color: #f7efe7;
            font-weight: 500;
        }
        
        /* Base body styling for all users */
        body {
            background: #334457 !important;
            color: #f7efe7;
        }
        
        /* Non-logged-in user styles */
        .hero-container {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
            background: #334457;
            position: relative;
            overflow: hidden;
        }
        
        .hero-container::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><defs><pattern id="grain" width="100" height="100" patternUnits="userSpaceOnUse"><circle cx="50" cy="50" r="1" fill="white" opacity="0.1"/></pattern></defs><rect width="100" height="100" fill="url(%23grain)"/></svg>');
            animation: float 20s ease-in-out infinite;
        }
        
        .hero-card {
            background: rgba(44, 62, 80, 0.9);
            backdrop-filter: blur(20px);
            border-radius: 32px;
            box-shadow: 0 32px 64px rgba(0,0,0,0.4), 0 0 0 1px rgba(255,255,255,0.1);
            overflow: hidden;
            max-width: 700px;
            width: 100%;
            text-align: center;
            position: relative;
            z-index: 2;
            animation: fadeInUp 1s ease-out;
            border: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        .hero-header {
            background: linear-gradient(135deg, #2c3e50 0%, #34495e 50%, #1a1a2e 100%);
            background-size: 200% 200%;
            animation: gradientShift 8s ease infinite;
            color: white;
            padding: 80px 50px;
            position: relative;
            overflow: hidden;
        }
        
        .hero-header::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(45deg, transparent 30%, rgba(255, 255, 255, 0.1) 50%, transparent 70%);
            animation: shimmer 3s infinite;
        }
        
        .hero-header h1 {
            margin: 0;
            font-size: 3.5rem;
            font-weight: 700;
            text-shadow: 0 4px 8px rgba(0,0,0,0.2);
            animation: fadeInUp 1s ease-out 0.2s both;
            position: relative;
            z-index: 2;
        }
        
        .hero-header p {
            margin: 25px 0 0 0;
            opacity: 0.95;
            font-size: 1.3rem;
            font-weight: 400;
            text-shadow: 0 2px 4px rgba(0,0,0,0.1);
            animation: fadeInUp 1s ease-out 0.4s both;
            position: relative;
            z-index: 2;
        }
        
        .hero-content {
            padding: 70px 50px;
            background: linear-gradient(180deg, rgba(255,255,255,0.05) 0%, rgba(255,255,255,0.02) 100%);
            color: white;
        }
        
        .hero-content h3 {
            color: #f7efe7;
            font-weight: 700;
            margin-bottom: 20px;
            font-size: 2rem;
        }
        
        .hero-content p {
            color: #f7efe7;
            font-size: 1.1rem;
            margin-bottom: 30px;
            line-height: 1.6;
        }
        
        .btn-hero {
            background: linear-gradient(135deg, #5cbe8f 0%, #5cbe8f 100%);
            border: 2px solid #5cbe8f;
            border-radius: 16px;
            padding: 18px 36px;
            font-size: 18px;
            font-weight: 600;
            color: white;
            margin: 12px;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            text-decoration: none;
            display: inline-block;
            position: relative;
            overflow: hidden;
            box-shadow: 0 0 0;
            min-width: 160px;
            text-align: center;
        }
        
        .btn-hero::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.3), transparent);
            transition: left 0.6s;
        }
        
        .btn-hero:hover::before {
            left: 100%;
        }
        
        .btn-hero:hover {
            transform: translateY(-4px) scale(1.05);
            box-shadow: 0 8px 24px rgba(92, 190, 143, 0.4);
            color: white;
            text-decoration: none;
        }
        
        .btn-outline {
            background: linear-gradient(135deg, #5cbe8f 0%, #5cbe8f 100%);
            border: 2px solid #5cbe8f;
            color: white;
            box-shadow: 0 0 0;
            min-width: 160px;
            text-align: center;
        }
        
        .btn-outline:hover {
            background: linear-gradient(135deg, #5cbe8f 0%, #5cbe8f 100%);
            color: white;
            transform: translateY(-4px) scale(1.05);
            box-shadow: 0 8px 24px rgba(92, 190, 143, 0.4);
            border-color: #5cbe8f;
        }
        
        .features {
            margin-top: 50px;
            animation: fadeInUp 1s ease-out 0.6s both;
        }
        
        .features .row {
            display: flex;
            align-items: stretch;
        }
        
        .features .col-md-4 {
            display: flex;
            flex-direction: column;
        }
        
        .features h4 {
            color: #f7efe7;
            font-weight: 700;
            margin-bottom: 40px;
            font-size: 1.8rem;
            text-align: center;
        }
        
        .feature-item {
            margin: 25px 0;
            padding: 30px 25px;
            border-radius: 20px;
            background: linear-gradient(135deg, rgba(44, 62, 80, 0.8) 0%, rgba(52, 73, 94, 0.8) 100%);
            border: 1px solid rgba(255, 255, 255, 0.1);
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
            box-shadow: 0 4px 12px rgba(0,0,0,0.3);
            height: 280px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }
        
        .feature-item::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(135deg, rgba(92, 190, 143, 0.1) 0%, rgba(92, 190, 143, 0.1) 100%);
            opacity: 0;
            transition: opacity 0.4s ease;
        }
        
        .feature-item:hover::before {
            opacity: 1;
        }
        
        .feature-item:hover {
            transform: translateY(-8px);
            box-shadow: 0 12px 24px rgba(0, 0, 0, 0.3);
            border-color: rgba(255, 255, 255, 0.2);
        }
        
        .feature-item i {
            color: #5cbe8f;
            font-size: 2.5rem;
            margin-bottom: 20px;
            transition: all 0.4s ease;
            position: relative;
            z-index: 2;
        }
        
        .feature-item:hover i {
            transform: scale(1.1) rotate(5deg);
            color: #5cbe8f;
        }
        
        .feature-item h5 {
            color: #f7efe7;
            font-weight: 600;
            margin-bottom: 15px;
            font-size: 1.2rem;
            position: relative;
            z-index: 2;
        }
        
        .feature-item p {
            color: #f7efe7;
            margin-bottom: 0;
            line-height: 1.6;
            position: relative;
            z-index: 2;
        }
        
        .btn-google {
            background: linear-gradient(135deg, #e74c3c 0%, #c0392b 100%);
            border: none;
            border-radius: 16px;
            padding: 18px 36px;
            font-size: 18px;
            font-weight: 600;
            color: white;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            text-decoration: none;
            display: inline-block;
            position: relative;
            overflow: hidden;
            box-shadow: 0 8px 24px rgba(231, 76, 60, 0.4);
            border: 2px solid transparent;
            min-width: 200px;
            text-align: center;
        }
        
        .btn-google::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.3), transparent);
            transition: left 0.6s;
        }
        
        .btn-google:hover::before {
            left: 100%;
        }
        
        .btn-google:hover {
            background: linear-gradient(135deg, #c0392b 0%, #a93226 100%);
            transform: translateY(-4px) scale(1.05);
            box-shadow: 0 16px 32px rgba(231, 76, 60, 0.4);
            color: white;
            text-decoration: none;
        }
        
        .divider {
            position: relative;
            text-align: center;
            margin: 30px 0;
            animation: fadeInUp 1s ease-out 0.8s both;
        }
        
        .divider::before {
            content: '';
            position: absolute;
            top: 50%;
            left: 0;
            right: 0;
            height: 2px;
            background: linear-gradient(90deg, transparent, #e1e5e9, transparent);
        }
        
        .divider-text {
            background: rgba(44, 62, 80, 0.9);
            padding: 0 25px;
            color: #bdc3c7;
            font-weight: 600;
            font-size: 1rem;
            position: relative;
            z-index: 2;
        }
        
        /* Additional text styling for better contrast */
        .hero-content .text-muted {
            color: #bdc3c7 !important;
        }
        
        .hero-content .d-flex {
            justify-content: center;
            align-items: center;
            flex-wrap: wrap;
            gap: 10px;
        }
        
        .google-button-container {
            margin-top: 70px !important;
        }
        
        /* Add missing animations */
        @keyframes gradientShift {
            0% { background-position: 0% 50%; }
            50% { background-position: 100% 50%; }
            100% { background-position: 0% 50%; }
        }
        
        @keyframes float {
            0%, 100% { transform: translateY(0px); }
            50% { transform: translateY(-10px); }
        }
        
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        
        @keyframes shimmer {
            0% { transform: translateX(-100%); }
            100% { transform: translateX(100%); }
        }
        
        /* Enhanced Responsive Design for Landing Page */
        @media (max-width: 768px) {
            .hero-container {
                padding: 15px;
            }
            
            .hero-card {
                max-width: 100%;
                border-radius: 24px;
            }
            
            .hero-header {
                padding: 60px 30px;
            }
            
            .hero-header h1 {
                font-size: 2.5rem;
            }
            
            .hero-header p {
                font-size: 1.1rem;
            }
            
            .hero-content {
                padding: 50px 30px;
            }
            
            .btn-hero, .btn-google {
                width: 100%;
                margin: 8px 0;
                padding: 16px 24px;
                font-size: 16px;
            }
            
            .feature-item {
                padding: 25px 20px;
                margin: 20px 0;
            }
            
            .feature-item i {
                font-size: 2rem;
            }
            
            .features h4 {
                font-size: 1.5rem;
                margin-bottom: 30px;
            }
        }
        
        @media (max-width: 576px) {
            .hero-header {
                padding: 50px 25px;
            }
            
            .hero-header h1 {
                font-size: 2rem;
            }
            
            .hero-header p {
                font-size: 1rem;
            }
            
            .hero-content {
                padding: 40px 25px;
            }
            
            .btn-hero, .btn-google {
                padding: 14px 20px;
                font-size: 15px;
            }
            
            .feature-item {
                padding: 20px 15px;
            }
            
            .feature-item i {
                font-size: 1.8rem;
            }
            
            .features h4 {
                font-size: 1.3rem;
            }
        }
    </style>
</head>
<body>
    <% if (isLoggedIn) { %>
        <!-- Logged-in User Experience -->
        <!-- Include Reusable Navbar Component -->
        <jsp:include page="/components/navbar.jsp" />   

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
                    <a href="${pageContext.request.contextPath}/guest-movies" class="action-btn">
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
                    <a href="${pageContext.request.contextPath}/guest-movies" class="feature-card">
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
                        <a href="${pageContext.request.contextPath}/guest-movies" class="btn btn-hero btn-outline">
                            <i class="fas fa-film"></i> Xem phim ngay
                        </a>
                    </div>
                    
                    <div class="text-center mt-4">
                        <div class="divider">
                        </div>
                    </div>
                    
                    <div class="d-flex justify-content-center google-button-container">
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
