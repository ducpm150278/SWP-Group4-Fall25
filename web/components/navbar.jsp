<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Get user information from session
    String userName = (String) session.getAttribute("userName");
    String userRole = (String) session.getAttribute("userRole");
    Object userObj = session.getAttribute("user");
    
    // Check if user is logged in by checking if user object exists in session
    boolean isLoggedIn = (userObj != null) || (userName != null);
    boolean isAdmin = "admin".equalsIgnoreCase(userRole);
%>

<link href="${pageContext.request.contextPath}/css/cinema-dark-theme.css" rel="stylesheet">
<style>
    /* Navbar Specific Styling */
    .navbar-cinema {
        background: var(--bg-secondary);
        border-bottom: 1px solid var(--border-primary);
        padding: 15px 0;
        box-shadow: 0 2px 10px rgba(0,0,0,0.3);
        position: sticky;
        top: 0;
        z-index: 1000;
    }
    
    .navbar-container {
        max-width: 1400px;
        margin: 0 auto;
        padding: 0 20px;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }
    
    .navbar-brand-cinema {
        color: var(--accent-red) !important;
        font-weight: 700;
        font-size: 1.5rem;
        transition: var(--transition-normal);
        text-decoration: none;
        display: flex;
        align-items: center;
        gap: 10px;
    }
    
    .navbar-brand-cinema:hover {
        color: var(--accent-red-light) !important;
        transform: translateX(5px);
    }
    
    .navbar-brand-cinema i {
        color: var(--accent-red);
    }
    
    .navbar-nav-cinema {
        display: flex;
        align-items: center;
        gap: 10px;
    }
    
    .nav-link-cinema {
        color: var(--text-secondary) !important;
        font-weight: 500;
        padding: 8px 16px;
        border-radius: 6px;
        transition: var(--transition-normal);
        text-decoration: none;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    
    .nav-link-cinema:hover {
        color: var(--text-primary) !important;
        background: var(--bg-tertiary);
    }
    
    .navbar-text-cinema {
        color: var(--text-primary) !important;
        font-weight: 500;
        font-size: 0.95rem;
        padding: 8px 16px;
        background: var(--bg-tertiary);
        border-radius: 6px;
    }
    
    .navbar-text-cinema i {
        color: var(--accent-red);
        margin-right: 6px;
    }
    
    .logout-btn-cinema {
        background: linear-gradient(135deg, var(--accent-red) 0%, var(--accent-red-dark) 100%);
        border: none;
        border-radius: 8px;
        padding: 10px 20px;
        color: white;
        font-weight: 600;
        transition: var(--transition-normal);
        text-decoration: none;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    
    .logout-btn-cinema:hover {
        background: linear-gradient(135deg, var(--accent-red-dark) 0%, var(--accent-red) 100%);
        transform: translateY(-2px);
        box-shadow: var(--shadow-red);
        color: white;
        text-decoration: none;
    }
    
    .login-btn-cinema {
        background: linear-gradient(135deg, var(--accent-red) 0%, var(--accent-red-dark) 100%);
        border: none;
        border-radius: 8px;
        padding: 10px 24px;
        color: white;
        font-weight: 600;
        transition: var(--transition-normal);
        text-decoration: none;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    
    .login-btn-cinema:hover {
        transform: translateY(-2px);
        box-shadow: var(--shadow-red);
        color: white;
    }
    
    /* Mobile Menu Toggle */
    .mobile-menu-toggle {
        display: none;
        background: var(--bg-tertiary);
        border: 1px solid var(--border-secondary);
        border-radius: 6px;
        padding: 8px 12px;
        color: var(--text-primary);
        cursor: pointer;
    }
    
    /* Responsive */
    @media (max-width: 768px) {
        .navbar-nav-cinema {
            display: none;
            position: absolute;
            top: 100%;
            left: 0;
            right: 0;
            background: var(--bg-secondary);
            flex-direction: column;
            padding: 20px;
            border-top: 1px solid var(--border-primary);
            gap: 10px;
        }
        
        .navbar-nav-cinema.active {
            display: flex;
        }
        
        .mobile-menu-toggle {
            display: block;
        }
        
        .nav-link-cinema,
        .logout-btn-cinema,
        .login-btn-cinema {
            width: 100%;
            justify-content: center;
        }
    }
</style>

<nav class="navbar-cinema">
    <div class="navbar-container">
        <a class="navbar-brand-cinema" href="${pageContext.request.contextPath}/index.jsp">
            <i class="fas fa-film"></i> Cinema
        </a>
        
        <button class="mobile-menu-toggle" onclick="toggleMobileMenu()">
            <i class="fas fa-bars"></i>
        </button>
        
        <div class="navbar-nav-cinema" id="navbarNav">
            <% if (isLoggedIn) { %>
                <!-- Logged-in Navigation -->
                <a href="${pageContext.request.contextPath}/guest-movies" class="nav-link-cinema">
                    <i class="fas fa-film"></i> Phim
                </a>
                <a href="${pageContext.request.contextPath}/booking/select-screening" class="nav-link-cinema">
                    <i class="fas fa-ticket-alt"></i> Đặt Vé
                </a>
                <a href="${pageContext.request.contextPath}/booking-history" class="nav-link-cinema">
                    <i class="fas fa-history"></i> Lịch Sử
                </a>
                <% if (isAdmin) { %>
                    <a href="${pageContext.request.contextPath}/admin.jsp" class="nav-link-cinema">
                        <i class="fas fa-cog"></i> Quản Lý
                    </a>
                <% } %>
                <a href="${pageContext.request.contextPath}/profile" class="nav-link-cinema">
                    <i class="fas fa-user"></i> Hồ Sơ
                </a>
                <span class="navbar-text-cinema">
                    <i class="fas fa-user-circle"></i> <%= userName != null ? userName : "Customer" %>
                </span>
                <a href="${pageContext.request.contextPath}/logout" class="logout-btn-cinema">
                    <i class="fas fa-sign-out-alt"></i> Đăng Xuất
                </a>
            <% } else { %>
                <!-- Guest Navigation -->
                <a href="${pageContext.request.contextPath}/guest-movies" class="nav-link-cinema">
                    <i class="fas fa-film"></i> Phim
                </a>
                <a href="${pageContext.request.contextPath}/auth/login" class="nav-link-cinema">
                    <i class="fas fa-user-circle"></i> Tài Khoản
                </a>
                <a href="${pageContext.request.contextPath}/auth/login" class="login-btn-cinema">
                    <i class="fas fa-sign-in-alt"></i> Đăng Nhập
                </a>
            <% } %>
        </div>
    </div>
</nav>

<script>
    function toggleMobileMenu() {
        const navbarNav = document.getElementById('navbarNav');
        navbarNav.classList.toggle('active');
    }
    
    // Close mobile menu when clicking outside
    document.addEventListener('click', function(event) {
        const navbar = document.querySelector('.navbar-cinema');
        const toggle = document.querySelector('.mobile-menu-toggle');
        const navbarNav = document.getElementById('navbarNav');
        
        if (!navbar.contains(event.target) && navbarNav.classList.contains('active')) {
            navbarNav.classList.remove('active');
        }
    });
</script>
