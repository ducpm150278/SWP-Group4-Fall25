<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Check if user is logged in
    Object userObj = session.getAttribute("user");
    String userName = (String) session.getAttribute("userName");
    String userRole = (String) session.getAttribute("userRole");
    boolean isLoggedIn = (userObj != null);
    boolean isAdmin = "admin".equalsIgnoreCase(userRole);
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cinema - Trải Nghiệm Điện Ảnh Đỉnh Cao</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://unpkg.com/aos@2.3.1/dist/aos.css">
    <style>
        :root {
            --primary-red: #e50914;
            --dark-red: #b20710;
            --light-red: #ff3838;
            --bg-dark: #0a0a0a;
            --bg-secondary: #141414;
            --bg-card: #1a1a1a;
            --text-primary: #ffffff;
            --text-secondary: #b3b3b3;
        }
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            background: var(--bg-dark);
            min-height: 100vh;
            font-family: 'Poppins', sans-serif;
            color: var(--text-primary);
            overflow-x: hidden;
        }
        
        /* Animated Background */
        .animated-bg {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: -1;
            background: linear-gradient(135deg, #0a0a0a 0%, #1a0a0f 50%, #0a0a0a 100%);
        }
        
        .animated-bg::before {
            content: '';
            position: absolute;
            width: 200%;
            height: 200%;
            background: radial-gradient(circle, rgba(229, 9, 20, 0.1) 1px, transparent 1px);
            background-size: 50px 50px;
            animation: moveBackground 20s linear infinite;
        }
        
        @keyframes moveBackground {
            0% { transform: translate(0, 0); }
            100% { transform: translate(50px, 50px); }
        }
        
        /* Hero Section - Completely Redesigned */
        .hero-section {
            position: relative;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
            background: linear-gradient(135deg, rgba(229, 9, 20, 0.9) 0%, rgba(10, 10, 10, 0.95) 100%),
                        url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 600"><rect fill="%23141414" width="1200" height="600"/><g fill-opacity="0.1"><circle fill="%23e50914" cx="200" cy="100" r="80"/><circle fill="%23e50914" cx="800" cy="400" r="120"/><circle fill="%23e50914" cx="1000" cy="200" r="60"/></g></svg>');
            background-size: cover;
            background-position: center;
        }
        
        .hero-particles {
            position: absolute;
            width: 100%;
            height: 100%;
            top: 0;
            left: 0;
        }
        
        .particle {
            position: absolute;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 50%;
            animation: float 15s infinite ease-in-out;
        }
        
        @keyframes float {
            0%, 100% { transform: translateY(0) translateX(0) scale(1); opacity: 0; }
            25% { opacity: 0.3; }
            50% { transform: translateY(-100px) translateX(50px) scale(1.2); opacity: 0.5; }
            75% { opacity: 0.3; }
        }
        
        .hero-content {
            position: relative;
            z-index: 2;
            text-align: center;
            padding: 40px 20px;
            max-width: 1200px;
        }
        
        .hero-badge {
            display: inline-block;
            background: rgba(229, 9, 20, 0.2);
            border: 2px solid var(--primary-red);
            color: #fff;
            padding: 8px 24px;
            border-radius: 50px;
            font-weight: 600;
            font-size: 0.9rem;
            margin-bottom: 30px;
            text-transform: uppercase;
            letter-spacing: 2px;
            animation: pulse 2s infinite;
        }
        
        @keyframes pulse {
            0%, 100% { transform: scale(1); box-shadow: 0 0 0 0 rgba(229, 9, 20, 0.4); }
            50% { transform: scale(1.05); box-shadow: 0 0 20px 10px rgba(229, 9, 20, 0); }
        }
        
        .hero-section h1 {
            font-size: clamp(2.5rem, 8vw, 5.5rem);
            font-weight: 900;
            margin-bottom: 25px;
            color: #fff;
            line-height: 1.1;
            text-shadow: 0 4px 30px rgba(0, 0, 0, 0.7);
            animation: fadeInUp 0.8s ease-out;
        }
        
        .hero-section h1 .highlight {
            background: linear-gradient(135deg, var(--primary-red), var(--light-red));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }
        
        .hero-section h1 .cinema-highlight {
            color: #fff;
            font-weight: 900;
            position: relative;
            display: inline-block;
            letter-spacing: 2px;
            padding: 8px 20px;
            margin-top: 8px;
            border-radius: 12px;
            background: linear-gradient(135deg, rgba(229, 9, 20, 0.25), rgba(229, 9, 20, 0.15));
            backdrop-filter: blur(10px);
            border-left: 4px solid var(--primary-red);
            box-shadow: 0 4px 15px rgba(229, 9, 20, 0.3), 
                        inset 0 1px 0 rgba(255, 255, 255, 0.1);
            vertical-align: baseline;
            opacity: 0;
            transform: scale(0.95) translateY(10px);
            animation: elegantAppear 0.6s cubic-bezier(0.25, 0.46, 0.45, 0.94) 0.5s forwards;
            overflow: hidden;
        }
        
        @keyframes elegantAppear {
            from {
                opacity: 0;
                transform: scale(0.95) translateY(10px);
                filter: blur(4px);
            }
            to {
                opacity: 1;
                transform: scale(1) translateY(0);
                filter: blur(0);
            }
        }
        
        .hero-section h1 .cinema-highlight::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            border-radius: 12px;
            background: linear-gradient(135deg, var(--primary-red), var(--light-red));
            opacity: 0;
            transition: opacity 0.3s ease;
            z-index: -1;
        }
        
        .hero-section h1 .cinema-highlight:hover::before {
            opacity: 0.15;
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
        
        .hero-section p {
            font-size: clamp(1rem, 2vw, 1.4rem);
            color: rgba(255, 255, 255, 0.9);
            margin-bottom: 40px;
            max-width: 700px;
            margin-left: auto;
            margin-right: auto;
            line-height: 1.8;
            animation: fadeInUp 0.8s ease-out 0.2s both;
        }
        
        .hero-buttons {
            display: flex;
            gap: 20px;
            justify-content: center;
            flex-wrap: wrap;
            animation: fadeInUp 0.8s ease-out 0.4s both;
        }
        
        .hero-btn {
            padding: 16px 40px;
            border-radius: 50px;
            font-weight: 700;
            font-size: 1.1rem;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 12px;
            transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            position: relative;
            overflow: hidden;
        }
        
        .hero-btn-primary {
            background: linear-gradient(135deg, var(--primary-red), var(--dark-red));
            color: white;
            box-shadow: 0 10px 40px rgba(229, 9, 20, 0.4);
        }
        
        .hero-btn-primary::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.3), transparent);
            transition: left 0.5s;
        }
        
        .hero-btn-primary:hover::before {
            left: 100%;
        }
        
        .hero-btn-primary:hover {
            transform: translateY(-5px) scale(1.05);
            box-shadow: 0 15px 50px rgba(229, 9, 20, 0.6);
            color: white;
        }
        
        .hero-btn-secondary {
            background: rgba(255, 255, 255, 0.1);
            color: white;
            border: 2px solid rgba(255, 255, 255, 0.3);
            backdrop-filter: blur(10px);
        }
        
        .hero-btn-secondary:hover {
            background: rgba(255, 255, 255, 0.2);
            border-color: white;
            transform: translateY(-5px) scale(1.05);
            color: white;
        }
        
        .scroll-indicator {
            position: absolute;
            bottom: 40px;
            left: 50%;
            transform: translateX(-50%);
            animation: bounce 2s infinite;
        }
        
        .scroll-indicator i {
            font-size: 2rem;
            color: rgba(255, 255, 255, 0.6);
        }
        
        @keyframes bounce {
            0%, 100% { transform: translateX(-50%) translateY(0); }
            50% { transform: translateX(-50%) translateY(10px); }
        }
        
        /* Main Container */
        .main-container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 80px 20px;
        }
        
        /* Section Headers */
        .section-header {
            text-align: center;
            margin-bottom: 60px;
        }
        
        .section-subtitle {
            color: var(--primary-red);
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 3px;
            font-size: 0.9rem;
            margin-bottom: 15px;
        }
        
        .section-title {
            font-size: clamp(2rem, 4vw, 3.5rem);
            font-weight: 800;
            margin-bottom: 20px;
            background: linear-gradient(135deg, #ffffff, #b3b3b3);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }
        
        /* Statistics Section */
        .stats-section {
            background: linear-gradient(135deg, var(--bg-card), var(--bg-secondary));
            border-radius: 30px;
            padding: 60px 40px;
            margin-bottom: 80px;
            border: 1px solid rgba(229, 9, 20, 0.2);
            position: relative;
            overflow: hidden;
        }
        
        .stats-section::before {
            content: '';
            position: absolute;
            top: -50%;
            right: -50%;
            width: 100%;
            height: 100%;
            background: radial-gradient(circle, rgba(229, 9, 20, 0.1) 0%, transparent 70%);
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 40px;
            position: relative;
            z-index: 1;
        }
        
        .stat-item {
            text-align: center;
        }
        
        .stat-number {
            font-size: clamp(2.5rem, 5vw, 4rem);
            font-weight: 900;
            background: linear-gradient(135deg, var(--primary-red), var(--light-red));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            margin-bottom: 10px;
            display: block;
        }
        
        .stat-label {
            color: var(--text-secondary);
            font-size: 1rem;
            font-weight: 500;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        
        /* Feature Grid */
        .feature-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 30px;
            margin-bottom: 80px;
        }
        
        .feature-card {
            background: linear-gradient(135deg, var(--bg-card), rgba(26, 26, 26, 0.6));
            border-radius: 24px;
            padding: 45px 35px;
            text-align: center;
            transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            border: 1px solid rgba(255, 255, 255, 0.05);
            text-decoration: none;
            color: inherit;
            display: block;
            position: relative;
            overflow: hidden;
            backdrop-filter: blur(10px);
        }
        
        .feature-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: linear-gradient(135deg, rgba(229, 9, 20, 0.1), transparent);
            opacity: 0;
            transition: opacity 0.4s;
        }
        
        .feature-card:hover::before {
            opacity: 1;
        }
        
        .feature-card:hover {
            transform: translateY(-12px) scale(1.02);
            box-shadow: 0 30px 80px rgba(229, 9, 20, 0.3);
            border-color: var(--primary-red);
            color: inherit;
        }
        
        .feature-icon {
            width: 90px;
            height: 90px;
            border-radius: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 25px;
            font-size: 2.2rem;
            color: #fff;
            transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            position: relative;
            z-index: 1;
        }
        
        .feature-card:hover .feature-icon {
            transform: scale(1.15) rotate(-5deg);
        }
        
        .icon-movies {
            background: linear-gradient(135deg, #e50914 0%, #b20710 100%);
            box-shadow: 0 10px 30px rgba(229, 9, 20, 0.4);
        }
        
        .icon-booking {
            background: linear-gradient(135deg, #2ea043 0%, #238636 100%);
            box-shadow: 0 10px 30px rgba(46, 160, 67, 0.4);
        }
        
        .icon-profile {
            background: linear-gradient(135deg, #58a6ff 0%, #1f6feb 100%);
            box-shadow: 0 10px 30px rgba(88, 166, 255, 0.4);
        }
        
        .icon-admin {
            background: linear-gradient(135deg, #ff9500 0%, #ff7b00 100%);
            box-shadow: 0 10px 30px rgba(255, 149, 0, 0.4);
        }
        
        .feature-title {
            font-size: 1.5rem;
            font-weight: 700;
            color: #fff;
            margin-bottom: 15px;
            position: relative;
            z-index: 1;
        }
        
        .feature-desc {
            color: var(--text-secondary);
            line-height: 1.7;
            font-size: 1rem;
            position: relative;
            z-index: 1;
        }
        
        /* CTA Section */
        .cta-section {
            background: linear-gradient(135deg, var(--primary-red), var(--dark-red));
            border-radius: 30px;
            padding: 80px 40px;
            text-align: center;
            position: relative;
            overflow: hidden;
            margin-bottom: 80px;
            border: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        .cta-section::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(45deg, transparent 30%, rgba(255, 255, 255, 0.15) 50%, transparent 70%);
            animation: shimmer 3s infinite;
        }
        
        .cta-section::after {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            width: 300px;
            height: 300px;
            background: radial-gradient(circle, rgba(229, 9, 20, 0.3), transparent);
            transform: translate(-50%, -50%);
            border-radius: 50%;
            filter: blur(80px);
        }
        
        .cta-section h2 {
            font-size: clamp(2rem, 5vw, 3.5rem);
            font-weight: 900;
            margin-bottom: 20px;
            color: #fff;
            position: relative;
            z-index: 1;
            text-shadow: 0 2px 20px rgba(0, 0, 0, 0.3);
        }
        
        .cta-section p {
            font-size: clamp(1rem, 2vw, 1.3rem);
            margin-bottom: 40px;
            color: rgba(255, 255, 255, 0.95);
            position: relative;
            z-index: 1;
            max-width: 600px;
            margin-left: auto;
            margin-right: auto;
        }
        
        .cta-buttons {
            display: flex;
            gap: 20px;
            justify-content: center;
            flex-wrap: wrap;
            position: relative;
            z-index: 1;
        }
        
        .cta-button {
            background: #fff;
            color: var(--primary-red);
            padding: 18px 45px;
            border-radius: 50px;
            font-weight: 700;
            font-size: 1.1rem;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 12px;
            transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            position: relative;
            overflow: hidden;
        }
        
        .cta-button::before {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            width: 0;
            height: 0;
            background: rgba(229, 9, 20, 0.1);
            border-radius: 50%;
            transform: translate(-50%, -50%);
            transition: width 0.5s, height 0.5s;
        }
        
        .cta-button:hover::before {
            width: 300px;
            height: 300px;
        }
        
        .cta-button:hover {
            transform: translateY(-5px) scale(1.05);
            box-shadow: 0 15px 40px rgba(0, 0, 0, 0.4);
            color: var(--dark-red);
        }
        
        .cta-button i,
        .cta-button span {
            position: relative;
            z-index: 1;
        }
        
        /* Info Section */
        .info-section {
            background: linear-gradient(135deg, var(--bg-card), var(--bg-secondary));
            border-radius: 30px;
            padding: 60px 40px;
            border: 1px solid rgba(255, 255, 255, 0.05);
            position: relative;
            overflow: hidden;
        }
        
        .info-section::before {
            content: '';
            position: absolute;
            top: -50%;
            left: -50%;
            width: 100%;
            height: 100%;
            background: radial-gradient(circle, rgba(229, 9, 20, 0.05) 0%, transparent 70%);
        }
        
        .info-section h3 {
            text-align: center;
            margin-bottom: 50px;
            font-size: clamp(1.8rem, 3vw, 2.5rem);
            font-weight: 800;
            position: relative;
            z-index: 1;
        }
        
        .info-section h3 i {
            color: var(--primary-red);
            margin-right: 15px;
        }
        
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 40px;
            position: relative;
            z-index: 1;
        }
        
        .info-item {
            text-align: center;
            padding: 30px 20px;
            border-radius: 20px;
            transition: all 0.3s;
            background: rgba(255, 255, 255, 0.02);
        }
        
        .info-item:hover {
            background: rgba(255, 255, 255, 0.05);
            transform: translateY(-5px);
        }
        
        .info-item i {
            font-size: 3rem;
            margin-bottom: 20px;
            display: inline-block;
            transition: transform 0.3s;
        }
        
        .info-item:hover i {
            transform: scale(1.1) rotate(5deg);
        }
        
        .info-item h5 {
            color: #fff;
            margin-bottom: 12px;
            font-weight: 700;
            font-size: 1.2rem;
        }
        
        .info-item p {
            color: var(--text-secondary);
            line-height: 1.7;
            font-size: 0.95rem;
        }
        
        /* Responsive */
        @media (max-width: 992px) {
            .stats-grid {
                grid-template-columns: repeat(2, 1fr);
            }
        }
        
        @media (max-width: 768px) {
            .hero-section {
                min-height: 80vh;
                padding: 80px 20px 40px;
            }
            
            .hero-badge {
                font-size: 0.75rem;
                padding: 6px 18px;
            }
            
            .feature-grid {
                grid-template-columns: 1fr;
            }
            
            .stats-section,
            .cta-section,
            .info-section {
                padding: 40px 25px;
            }
            
            .stats-grid {
                grid-template-columns: 1fr;
                gap: 30px;
            }
            
            .hero-buttons,
            .cta-buttons {
                flex-direction: column;
                gap: 15px;
            }
            
            .hero-btn,
            .cta-button {
                width: 100%;
                justify-content: center;
            }
            
            .scroll-indicator {
                bottom: 20px;
            }
        }
        
        /* Smooth Scrolling */
        html {
            scroll-behavior: smooth;
        }
        
        /* Hide Scrollbar */
        ::-webkit-scrollbar {
            display: none;
        }
        
        /* Hide scrollbar for IE, Edge and Firefox */
        body {
            -ms-overflow-style: none;  /* IE and Edge */
            scrollbar-width: none;  /* Firefox */
        }
    </style>
</head>
<body>
    <!-- Animated Background -->
    <div class="animated-bg"></div>
    
    <!-- Include Navbar -->
    <jsp:include page="/components/navbar.jsp" />

    <!-- Hero Section -->
    <div class="hero-section">
        <!-- Floating Particles -->
        <div class="hero-particles">
            <div class="particle" style="width: 10px; height: 10px; top: 20%; left: 10%; animation-delay: 0s;"></div>
            <div class="particle" style="width: 15px; height: 15px; top: 40%; left: 80%; animation-delay: 2s;"></div>
            <div class="particle" style="width: 8px; height: 8px; top: 60%; left: 20%; animation-delay: 4s;"></div>
            <div class="particle" style="width: 12px; height: 12px; top: 80%; left: 70%; animation-delay: 1s;"></div>
            <div class="particle" style="width: 20px; height: 20px; top: 30%; left: 50%; animation-delay: 3s;"></div>
        </div>
        
        <!-- Hero Content -->
        <div class="hero-content">
            <div class="hero-badge">
                <i class="fas fa-star"></i> Trải Nghiệm Điện Ảnh #1
            </div>
            
            <h1>
                <% if (isLoggedIn) { %>
                    Xin chào, <span class="cinema-highlight"><%= userName != null ? userName : "Customer" %></span>
                <% } else { %>
                    Chào mừng đến <span class="cinema-highlight">Cinema</span>
                <% } %>
            </h1>
            
            <p>
                Trải nghiệm đặt vé xem phim <strong>hiện đại</strong>, <strong>nhanh chóng</strong> 
                và <strong>tiện lợi</strong> với công nghệ tiên tiến nhất
            </p>
            
            <div class="hero-buttons">
                <% if (isLoggedIn) { %>
                    <a href="${pageContext.request.contextPath}/booking/select-screening" class="hero-btn hero-btn-primary">
                        <i class="fas fa-ticket-alt"></i>
                        <span>Đặt Vé Ngay</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/guest-movies" class="hero-btn hero-btn-secondary">
                        <i class="fas fa-film"></i>
                        <span>Khám Phá Phim</span>
                    </a>
                <% } else { %>
                    <a href="${pageContext.request.contextPath}/auth/signup" class="hero-btn hero-btn-primary">
                        <i class="fas fa-user-plus"></i>
                        <span>Đăng Ký Ngay</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/guest-movies" class="hero-btn hero-btn-secondary">
                        <i class="fas fa-film"></i>
                        <span>Xem Phim</span>
                    </a>
                <% } %>
            </div>
        </div>
        
        <!-- Scroll Indicator -->
        <div class="scroll-indicator">
            <i class="fas fa-chevron-down"></i>
        </div>
    </div>

    <!-- Main Container -->
    <div class="main-container">
        <!-- Statistics Section -->
        <div class="stats-section" data-aos="fade-up" data-aos-duration="1000">
            <div class="stats-grid">
                <div class="stat-item" data-aos="zoom-in" data-aos-delay="100">
                    <span class="stat-number" data-count="50000">0</span>
                    <div class="stat-label">Khách Hàng</div>
                </div>
                <div class="stat-item" data-aos="zoom-in" data-aos-delay="200">
                    <span class="stat-number" data-count="1000">0</span>
                    <div class="stat-label">Phim Đã Chiếu</div>
                </div>
                <div class="stat-item" data-aos="zoom-in" data-aos-delay="300">
                    <span class="stat-number" data-count="100">0</span>
                    <div class="stat-label">Rạp Chiếu</div>
                </div>
                <div class="stat-item" data-aos="zoom-in" data-aos-delay="400">
                    <span class="stat-number" data-count="98">0</span>
                    <div class="stat-label">Hài Lòng (%)</div>
                </div>
            </div>
        </div>
        
        <!-- Section Header -->
        <div class="section-header" data-aos="fade-up">
            <div class="section-subtitle">Dịch Vụ Của Chúng Tôi</div>
            <h2 class="section-title">Khám Phá Các Tính Năng</h2>
        </div>
        
        <!-- Features Grid -->
        <div class="feature-grid">
            <!-- Browse Movies -->
            <a href="${pageContext.request.contextPath}/guest-movies" class="feature-card" data-aos="fade-up" data-aos-delay="100">
                <div class="feature-icon icon-movies">
                    <i class="fas fa-film"></i>
                </div>
                <h3 class="feature-title">Danh Sách Phim</h3>
                <p class="feature-desc">
                    Khám phá hàng trăm bộ phim đang chiếu và sắp chiếu với chất lượng hình ảnh tuyệt vời
                </p>
            </a>

            <% if (isLoggedIn) { %>
                <!-- Book Tickets -->
                <a href="${pageContext.request.contextPath}/booking/select-screening" class="feature-card" data-aos="fade-up" data-aos-delay="200">
                    <div class="feature-icon icon-booking">
                        <i class="fas fa-ticket-alt"></i>
                    </div>
                    <h3 class="feature-title">Đặt Vé Nhanh Chóng</h3>
                    <p class="feature-desc">
                        Chọn suất chiếu, ghế ngồi yêu thích và combo ăn uống chỉ với vài thao tác đơn giản
                    </p>
                </a>

                <!-- User Profile -->
                <a href="${pageContext.request.contextPath}/CustomerProfile" class="feature-card" data-aos="fade-up" data-aos-delay="300">
                    <div class="feature-icon icon-profile">
                        <i class="fas fa-user-circle"></i>
                    </div>
                    <h3 class="feature-title">Hồ Sơ Cá Nhân</h3>
                    <p class="feature-desc">
                        Quản lý thông tin tài khoản và theo dõi lịch sử giao dịch của bạn
                    </p>
                </a>

                <% if (isAdmin) { %>
                    <!-- Admin Panel -->
                    <a href="${pageContext.request.contextPath}/admin.jsp" class="feature-card" data-aos="fade-up" data-aos-delay="400">
                        <div class="feature-icon icon-admin">
                            <i class="fas fa-tools"></i>
                        </div>
                        <h3 class="feature-title">Quản Lý Hệ Thống</h3>
                        <p class="feature-desc">
                            Quản lý toàn bộ phim, rạp, suất chiếu và người dùng một cách hiệu quả
                        </p>
                    </a>
                <% } %>
            <% } %>
        </div>

        <% if (!isLoggedIn) { %>
            <!-- Call to Action for Guest Users -->
            <div class="cta-section" data-aos="zoom-in" data-aos-duration="800">
                <h2>Bắt Đầu Hành Trình Điện Ảnh!</h2>
                <p>Đăng ký tài khoản ngay để trải nghiệm dịch vụ đặt vé tốt nhất và nhận nhiều ưu đãi hấp dẫn</p>
                <div class="cta-buttons">
                    <a href="${pageContext.request.contextPath}/auth/signup" class="cta-button">
                        <i class="fas fa-user-plus"></i>
                        <span>Đăng Ký Ngay</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/auth/login" class="cta-button">
                        <i class="fas fa-sign-in-alt"></i>
                        <span>Đã Có Tài Khoản?</span>
                    </a>
                </div>
            </div>
        <% } else { %>
            <!-- Call to Action for Logged-in Users -->
            <div class="cta-section" data-aos="zoom-in" data-aos-duration="800">
                <h2>Sẵn Sàng Cho Trải Nghiệm Điện Ảnh?</h2>
                <p>Chọn bộ phim yêu thích và đặt vé ngay hôm nay để không bỏ lỡ những suất chiếu đặc biệt!</p>
                <div class="cta-buttons">
                    <a href="${pageContext.request.contextPath}/booking/select-screening" class="cta-button">
                        <i class="fas fa-ticket-alt"></i>
                        <span>Đặt Vé Ngay</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/guest-movies" class="cta-button">
                        <i class="fas fa-film"></i>
                        <span>Khám Phá Thêm</span>
                    </a>
                </div>
            </div>
        <% } %>

        <!-- Info Section -->
        <div class="info-section" data-aos="fade-up" data-aos-duration="1000">
            <h3>
                <i class="fas fa-heart"></i> Tại Sao Hàng Ngàn Khách Hàng Tin Chọn Chúng Tôi?
            </h3>
            <div class="info-grid">
                <div class="info-item" data-aos="flip-left" data-aos-delay="100">
                    <i class="fas fa-bolt" style="color: #e50914;"></i>
                    <h5>Đặt Vé Siêu Nhanh</h5>
                    <p>Quy trình đặt vé chỉ mất 60 giây với giao diện tối ưu và thao tác đơn giản</p>
                </div>
                <div class="info-item" data-aos="flip-left" data-aos-delay="200">
                    <i class="fas fa-shield-alt" style="color: #2ea043;"></i>
                    <h5>An Toàn & Bảo Mật</h5>
                    <p>Thanh toán trực tuyến an toàn 100% qua cổng VNPay được chứng nhận quốc tế</p>
                </div>
                <div class="info-item" data-aos="flip-left" data-aos-delay="400">
                    <i class="fas fa-headset" style="color: #58a6ff;"></i>
                    <h5>Hỗ Trợ 24/7</h5>
                    <p>Đội ngũ chăm sóc khách hàng chuyên nghiệp sẵn sàng hỗ trợ bạn mọi lúc mọi nơi</p>
                </div>
                <div class="info-item" data-aos="flip-left" data-aos-delay="500">
                    <i class="fas fa-gift" style="color: #ff9500;"></i>
                    <h5>Ưu Đãi Đặc Biệt</h5>
                    <p>Chương trình khuyến mãi hấp dẫn và tích điểm thành viên với nhiều quyền lợi</p>
                </div>
            </div>
        </div>
    </div>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://unpkg.com/aos@2.3.1/dist/aos.js"></script>
    
    <script>
        // Initialize AOS (Animate On Scroll)
        AOS.init({
            duration: 800,
            easing: 'ease-in-out',
            once: true,
            offset: 100
        });
        
        // Animated Counter
        function animateCounter(element) {
            const target = parseInt(element.getAttribute('data-count'));
            const duration = 2000;
            const increment = target / (duration / 16);
            let current = 0;
            
            const timer = setInterval(() => {
                current += increment;
                if (current >= target) {
                    current = target;
                    clearInterval(timer);
                }
                element.textContent = Math.floor(current).toLocaleString('vi-VN');
            }, 16);
        }
        
        // Intersection Observer for counters
        const observerOptions = {
            threshold: 0.5,
            rootMargin: '0px'
        };
        
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    const counters = entry.target.querySelectorAll('.stat-number');
                    counters.forEach(counter => {
                        if (counter.textContent === '0') {
                            animateCounter(counter);
                        }
                    });
                    observer.unobserve(entry.target);
                }
            });
        }, observerOptions);
        
        // Observe stats section
        const statsSection = document.querySelector('.stats-section');
        if (statsSection) {
            observer.observe(statsSection);
        }
        
        // Smooth scroll for scroll indicator
        const scrollIndicator = document.querySelector('.scroll-indicator');
        if (scrollIndicator) {
            scrollIndicator.addEventListener('click', () => {
                const mainContainer = document.querySelector('.main-container');
                if (mainContainer) {
                    mainContainer.scrollIntoView({ behavior: 'smooth' });
                }
            });
        }
        
        // Add parallax effect to hero section
        window.addEventListener('scroll', () => {
            const scrolled = window.pageYOffset;
            const heroSection = document.querySelector('.hero-section');
            if (heroSection && scrolled < heroSection.offsetHeight) {
                heroSection.style.transform = `translateY(${scrolled * 0.5}px)`;
                heroSection.style.opacity = 1 - (scrolled / heroSection.offsetHeight) * 0.5;
            }
        });
    </script>
</body>
</html>
