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
    <link href="${pageContext.request.contextPath}/css/index.css" rel="stylesheet">
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
                        <span>Đăng Kí Ngay</span>
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
                <p>Đăng nhập hoặc tạo tài khoản ngay để trải nghiệm dịch vụ đặt vé tốt nhất và nhận nhiều ưu đãi hấp dẫn</p>
                <div class="cta-buttons">
                    <a href="${pageContext.request.contextPath}/auth/signup" class="cta-button">
                        <i class="fas fa-user-plus"></i>
                        <span>Đăng Kí Ngay</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/auth/login" class="cta-button">
                        <i class="fas fa-sign-in-alt"></i>
                        <span>Đăng Nhập</span>
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
