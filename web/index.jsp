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
    <title>Trang Chủ - Cinema Booking</title>
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
        }
        
        /* Hero Section */
        .hero-section {
            background: linear-gradient(135deg, #e50914 0%, #b20710 100%);
            padding: 80px 40px;
            text-align: center;
            position: relative;
            overflow: hidden;
        }
        
        .hero-section::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(45deg, transparent 30%, rgba(255, 255, 255, 0.1) 50%, transparent 70%);
            animation: shimmer 3s infinite;
        }
        
        @keyframes shimmer {
            0% { transform: translateX(-100%); }
            100% { transform: translateX(100%); }
        }
        
        .hero-section h1 {
            font-size: 3.5rem;
            font-weight: 800;
            margin-bottom: 20px;
            color: #fff;
            position: relative;
            z-index: 1;
        }
        
        .hero-section p {
            font-size: 1.4rem;
            opacity: 0.95;
            color: #fff;
            position: relative;
            z-index: 1;
        }
        
        /* Main Container */
        .main-container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 50px 20px;
        }
        
        /* Feature Grid */
        .feature-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 30px;
            margin-bottom: 60px;
        }
        
        .feature-card {
            background: #1a1d24;
            border-radius: 16px;
            padding: 40px 30px;
            text-align: center;
            transition: all 0.3s;
            border: 1px solid #2a2d35;
            text-decoration: none;
            color: inherit;
            display: block;
        }
        
        .feature-card:hover {
            transform: translateY(-8px);
            box-shadow: 0 20px 60px rgba(0,0,0,0.5);
            border-color: #e50914;
            color: inherit;
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
            color: #fff;
            transition: all 0.3s;
        }
        
        .feature-card:hover .feature-icon {
            transform: scale(1.1) rotate(5deg);
        }
        
        .icon-movies {
            background: linear-gradient(135deg, #e50914 0%, #b20710 100%);
        }
        
        .icon-booking {
            background: linear-gradient(135deg, #2ea043 0%, #238636 100%);
        }
        
        .icon-profile {
            background: linear-gradient(135deg, #58a6ff 0%, #1f6feb 100%);
        }
        
        .icon-admin {
            background: linear-gradient(135deg, #ff9500 0%, #ff7b00 100%);
        }
        
        .feature-title {
            font-size: 1.4rem;
            font-weight: 700;
            color: #fff;
            margin-bottom: 12px;
        }
        
        .feature-desc {
            color: #8b92a7;
            line-height: 1.6;
            font-size: 0.95rem;
        }
        
        /* CTA Section */
        .cta-section {
            background: linear-gradient(135deg, #e50914 0%, #b20710 100%);
            border-radius: 16px;
            padding: 60px 40px;
            text-align: center;
            position: relative;
            overflow: hidden;
            margin-bottom: 60px;
        }
        
        .cta-section::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(45deg, transparent 30%, rgba(255, 255, 255, 0.1) 50%, transparent 70%);
            animation: shimmer 3s infinite;
        }
        
        .cta-section h2 {
            font-size: 2.5rem;
            font-weight: 800;
            margin-bottom: 20px;
            color: #fff;
            position: relative;
            z-index: 1;
        }
        
        .cta-section p {
            font-size: 1.2rem;
            margin-bottom: 30px;
            color: rgba(255, 255, 255, 0.95);
            position: relative;
            z-index: 1;
        }
        
        .cta-button {
            background: #fff;
            color: #e50914;
            padding: 16px 40px;
            border-radius: 10px;
            font-weight: 700;
            font-size: 1.1rem;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 10px;
            transition: all 0.3s;
            position: relative;
            z-index: 1;
            margin: 0 10px;
        }
        
        .cta-button:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
            color: #e50914;
        }
        
        /* Info Cards */
        .info-section {
            background: #1a1d24;
            border-radius: 16px;
            padding: 40px;
            border: 1px solid #2a2d35;
        }
        
        .info-section h3 {
            text-align: center;
            margin-bottom: 40px;
            color: #e50914;
            font-size: 1.8rem;
            font-weight: 700;
        }
        
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 30px;
        }
        
        .info-item {
            text-align: center;
        }
        
        .info-item i {
            font-size: 2.5rem;
            margin-bottom: 15px;
        }
        
        .info-item h5 {
            color: #fff;
            margin-bottom: 10px;
            font-weight: 600;
        }
        
        .info-item p {
            color: #8b92a7;
            line-height: 1.6;
        }
        
        /* Responsive */
        @media (max-width: 768px) {
            .hero-section h1 {
                font-size: 2rem;
            }
            
            .hero-section p {
                font-size: 1rem;
            }
            
            .feature-grid {
                grid-template-columns: 1fr;
            }
            
            .cta-section h2 {
                font-size: 1.8rem;
            }
            
            .cta-button {
                display: flex;
                margin: 10px 0;
            }
        }
    </style>
</head>
<body>
    <!-- Include Navbar -->
    <jsp:include page="/components/navbar.jsp" />

    <!-- Hero Section -->
    <div class="hero-section">
        <h1>
            <% if (isLoggedIn) { %>
                Chào mừng trở lại, <%= userName != null ? userName : "Customer" %>!
            <% } else { %>
                Chào mừng đến Cinema Booking
            <% } %>
        </h1>
        <p>Trải nghiệm đặt vé xem phim hiện đại và tiện lợi</p>
    </div>

    <!-- Main Container -->
    <div class="main-container">
        <!-- Features Grid -->
        <div class="feature-grid">
            <!-- Browse Movies -->
            <a href="${pageContext.request.contextPath}/guest-movies" class="feature-card">
                <div class="feature-icon icon-movies">
                    <i class="fas fa-film"></i>
                </div>
                <h3 class="feature-title">Danh Sách Phim</h3>
                <p class="feature-desc">
                    Khám phá các bộ phim đang chiếu và sắp chiếu tại rạp
                </p>
            </a>

            <% if (isLoggedIn) { %>
                <!-- Book Tickets -->
                <a href="${pageContext.request.contextPath}/booking/select-screening" class="feature-card">
                    <div class="feature-icon icon-booking">
                        <i class="fas fa-ticket-alt"></i>
                    </div>
                    <h3 class="feature-title">Đặt Vé Ngay</h3>
                    <p class="feature-desc">
                        Chọn suất chiếu, ghế ngồi và đồ ăn chỉ với vài bước đơn giản
                    </p>
                </a>

                <!-- User Profile -->
                <a href="${pageContext.request.contextPath}/profile" class="feature-card">
                    <div class="feature-icon icon-profile">
                        <i class="fas fa-user"></i>
                    </div>
                    <h3 class="feature-title">Hồ Sơ Của Tôi</h3>
                    <p class="feature-desc">
                        Quản lý thông tin cá nhân và lịch sử đặt vé
                    </p>
                </a>

                <% if (isAdmin) { %>
                    <!-- Admin Panel -->
                    <a href="${pageContext.request.contextPath}/admin.jsp" class="feature-card">
                        <div class="feature-icon icon-admin">
                            <i class="fas fa-cog"></i>
                        </div>
                        <h3 class="feature-title">Quản Lý Hệ Thống</h3>
                        <p class="feature-desc">
                            Quản lý phim, rạp, suất chiếu và người dùng
                        </p>
                    </a>
                <% } %>
            <% } %>
        </div>

        <% if (!isLoggedIn) { %>
            <!-- Call to Action for Guest Users -->
            <div class="cta-section">
                <h2>Bắt Đầu Đặt Vé Ngay!</h2>
                <p>Đăng nhập hoặc tạo tài khoản để trải nghiệm dịch vụ đặt vé tốt nhất</p>
                <a href="${pageContext.request.contextPath}/auth/login" class="cta-button">
                    <i class="fas fa-sign-in-alt"></i> Đăng Nhập Ngay
                </a>
                <a href="${pageContext.request.contextPath}/auth/signup" class="cta-button">
                    <i class="fas fa-user-plus"></i> Đăng Ký Tài Khoản
                </a>
            </div>
        <% } else { %>
            <!-- Call to Action for Logged-in Users -->
            <div class="cta-section">
                <h2>Sẵn Sàng Xem Phim?</h2>
                <p>Chọn bộ phim yêu thích và đặt vé ngay hôm nay!</p>
                <a href="${pageContext.request.contextPath}/booking/select-screening" class="cta-button">
                    <i class="fas fa-ticket-alt"></i> Đặt Vé Ngay
                </a>
            </div>
        <% } %>

        <!-- Info Section -->
        <div class="info-section">
            <h3>
                <i class="fas fa-info-circle"></i> Tại Sao Chọn Chúng Tôi?
            </h3>
            <div class="info-grid">
                <div class="info-item">
                    <i class="fas fa-clock" style="color: #e50914;"></i>
                    <h5>Đặt Vé Nhanh Chóng</h5>
                    <p>Quy trình đặt vé đơn giản, tiết kiệm thời gian</p>
                </div>
                <div class="info-item">
                    <i class="fas fa-shield-alt" style="color: #2ea043;"></i>
                    <h5>An Toàn & Bảo Mật</h5>
                    <p>Thanh toán an toàn qua VNPay</p>
                </div>
                <div class="info-item">
                    <i class="fas fa-star" style="color: #ff9500;"></i>
                    <h5>Trải Nghiệm Tốt Nhất</h5>
                    <p>Giao diện hiện đại, dễ sử dụng</p>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
