<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Admin Dashboard</title>
        <!-- Bootstrap CSS -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
        <!-- Font Awesome -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <!-- Custom CSS -->
        <style>
            /* === RESET & BASE STYLES === */
            * {
                box-sizing: border-box;
            }
            
            body {
                margin: 0;
                padding: 0;
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                background-color: #f8f9fa;
                overflow-x: hidden;
            }

            /* === LAYOUT STRUCTURE === */
            .admin-container {
                display: flex;
                min-height: 100vh;
            }

            /* === SIDEBAR STYLES === */
            .admin-sidebar {
                width: 250px;
                background: linear-gradient(180deg, #2c3e50 0%, #34495e 100%);
                position: fixed;
                top: 0;
                left: 0;
                height: 100vh;
                z-index: 1000;
                box-shadow: 2px 0 10px rgba(0,0,0,0.1);
                transition: all 0.3s ease;
                overflow-y: auto;
            }

            .sidebar-header {
                padding: 1.5rem 1rem;
                border-bottom: 1px solid rgba(255,255,255,0.1);
                text-align: center;
            }

            .sidebar-brand {
                color: #ecf0f1;
                font-size: 1.3rem;
                font-weight: 700;
                text-decoration: none;
                display: flex;
                align-items: center;
                justify-content: center;
                gap: 0.5rem;
            }

            .sidebar-menu {
                padding: 1rem 0;
            }

            .menu-section {
                padding: 0.75rem 1.5rem 0.5rem;
                font-size: 0.75rem;
                font-weight: 700;
                text-transform: uppercase;
                letter-spacing: 0.5px;
                color: #bdc3c7;
                margin-top: 1rem;
            }

            .menu-item {
                display: flex;
                align-items: center;
                padding: 0.75rem 1.5rem;
                color: #ecf0f1;
                text-decoration: none;
                transition: all 0.3s ease;
                border: none;
                background: transparent;
                width: 100%;
                font-size: 0.9rem;
                cursor: pointer;
            }

            .menu-item:hover {
                background-color: rgba(255,255,255,0.1);
                color: #ffffff;
                transform: translateX(5px);
            }

            .menu-item.active {
                background: linear-gradient(90deg, #3498db 0%, #2980b9 100%);
                color: white;
                border-right: 3px solid #ffffff;
                box-shadow: inset 0 0 10px rgba(0,0,0,0.1);
            }

            .menu-icon {
                margin-right: 0.75rem;
                font-size: 1rem;
                width: 20px;
                text-align: center;
                color: #bdc3c7;
            }

            .menu-item.active .menu-icon {
                color: white;
            }

            .menu-item:hover .menu-icon {
                color: #3498db;
            }

            .menu-item.logout {
                color: #e74c3c;
            }

            .menu-item.logout:hover {
                background-color: rgba(231, 76, 60, 0.1);
                color: #c0392b;
            }

            /* === HEADER STYLES === */
            .admin-header {
                background: linear-gradient(135deg, #2c3e50 0%, #34495e 100%);
                box-shadow: 0 2px 10px rgba(0,0,0,0.1);
                border-bottom: 1px solid rgba(255,255,255,0.1);
                height: 60px;
                position: fixed;
                top: 0;
                left: 250px;
                right: 0;
                z-index: 999;
                transition: all 0.3s ease;
            }

            .header-content {
                display: flex;
                align-items: center;
                justify-content: space-between;
                height: 100%;
                padding: 0 1.5rem;
            }

            .header-left {
                display: flex;
                align-items: center;
                gap: 1rem;
            }

            .sidebar-toggle {
                background: transparent;
                border: none;
                color: #ecf0f1;
                font-size: 1.2rem;
                transition: all 0.3s ease;
                padding: 0.5rem;
                border-radius: 4px;
            }

            .sidebar-toggle:hover {
                color: #3498db;
                background: rgba(255,255,255,0.1);
            }

            .header-title {
                color: #ecf0f1;
                font-size: 1.2rem;
                font-weight: 600;
                margin: 0;
            }

            .header-right {
                display: flex;
                align-items: center;
                gap: 1rem;
            }

            .search-box {
                position: relative;
            }

            .search-input {
                background: rgba(255,255,255,0.1);
                border: 1px solid rgba(255,255,255,0.2);
                color: #ecf0f1;
                padding: 0.5rem 1rem;
                border-radius: 20px;
                width: 250px;
                transition: all 0.3s ease;
            }

            .search-input:focus {
                outline: none;
                background: rgba(255,255,255,0.15);
                border-color: #3498db;
                width: 300px;
            }

            .search-input::placeholder {
                color: #bdc3c7;
            }

            .user-menu {
                position: relative;
            }

            .user-btn {
                background: transparent;
                border: none;
                color: #ecf0f1;
                display: flex;
                align-items: center;
                gap: 0.5rem;
                padding: 0.5rem 1rem;
                border-radius: 20px;
                transition: all 0.3s ease;
                cursor: pointer;
            }

            .user-btn:hover {
                background: rgba(255,255,255,0.1);
            }

            .user-avatar {
                width: 32px;
                height: 32px;
                border-radius: 50%;
                background: linear-gradient(45deg, #3498db, #2980b9);
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 0.9rem;
                color: white;
            }

            .dropdown-menu {
                border: none;
                box-shadow: 0 5px 15px rgba(0,0,0,0.1);
                border-radius: 8px;
                overflow: hidden;
                min-width: 200px;
            }

            .dropdown-item {
                padding: 0.75rem 1.5rem;
                transition: all 0.3s ease;
                display: flex;
                align-items: center;
                gap: 0.5rem;
            }

            .dropdown-item:hover {
                background: linear-gradient(135deg, #3498db, #2980b9);
                color: white;
                transform: translateX(5px);
            }

            /* === MAIN CONTENT STYLES === */
            .admin-main {
                flex: 1;
                margin-left: 250px;
                margin-top: 60px;
                padding: 20px;
                background-color: #f8f9fa;
                min-height: calc(100vh - 60px);
                transition: all 0.3s ease;
            }

            .content-header {
                margin-bottom: 2rem;
            }

            .content-title {
                font-size: 1.8rem;
                font-weight: 700;
                color: #2c3e50;
                margin-bottom: 0.5rem;
            }

            .content-subtitle {
                color: #7f8c8d;
                font-size: 1rem;
            }

            .content-card {
                background: white;
                border-radius: 10px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.1);
                padding: 1.5rem;
                margin-bottom: 1.5rem;
            }

            /* === MODAL FIXES === */
            .modal {
                z-index: 1060 !important;
            }

            .modal-backdrop {
                z-index: 1050 !important;
            }

            /* === RESPONSIVE STYLES === */
            @media (max-width: 768px) {
                .admin-sidebar {
                    width: 70px;
                    transform: translateX(0);
                }

                .admin-sidebar.collapsed {
                    transform: translateX(-100%);
                }

                .admin-header {
                    left: 70px;
                }

                .admin-main {
                    margin-left: 70px;
                }

                .sidebar-brand span,
                .menu-item span,
                .menu-section {
                    display: none;
                }

                .menu-icon {
                    margin-right: 0;
                    font-size: 1.2rem;
                }

                .menu-item {
                    justify-content: center;
                    padding: 1rem 0.5rem;
                }

                .search-input {
                    width: 150px;
                }

                .search-input:focus {
                    width: 200px;
                }
            }

            @media (max-width: 576px) {
                .admin-sidebar {
                    width: 100%;
                    transform: translateX(-100%);
                }

                .admin-sidebar.mobile-open {
                    transform: translateX(0);
                }

                .admin-header {
                    left: 0;
                }

                .admin-main {
                    margin-left: 0;
                }

                .search-box {
                    display: none;
                }
            }

            /* === SCROLLBAR STYLING === */
            .admin-sidebar::-webkit-scrollbar {
                width: 6px;
            }

            .admin-sidebar::-webkit-scrollbar-track {
                background: #34495e;
            }

            .admin-sidebar::-webkit-scrollbar-thumb {
                background: #3498db;
                border-radius: 3px;
            }

            /* === ANIMATIONS === */
            @keyframes slideIn {
                from {
                    opacity: 0;
                    transform: translateX(-10px);
                }
                to {
                    opacity: 1;
                    transform: translateX(0);
                }
            }

            .menu-item.active {
                animation: slideIn 0.3s ease;
            }

            /* === CONTENT SPECIFIC STYLES === */
            .table-container {
                background: white;
                border-radius: 10px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.1);
                overflow: hidden;
            }

            .action-buttons {
                display: flex;
                gap: 0.5rem;
            }

            .btn-icon {
                display: flex;
                align-items: center;
                gap: 0.5rem;
            }

            .status-badge {
                padding: 0.25rem 0.75rem;
                border-radius: 20px;
                font-size: 0.75rem;
                font-weight: 600;
            }

            .badge-active {
                background: #d4edda;
                color: #155724;
            }

            .badge-inactive {
                background: #f8d7da;
                color: #721c24;
            }

            .badge-pending {
                background: #fff3cd;
                color: #856404;
            }

            /* === LOADING STATES === */
            .loading {
                opacity: 0.6;
                pointer-events: none;
            }

            .spinner {
                display: inline-block;
                width: 1rem;
                height: 1rem;
                border: 2px solid transparent;
                border-top: 2px solid currentColor;
                border-radius: 50%;
                animation: spin 0.8s linear infinite;
            }

            @keyframes spin {
                to {
                    transform: rotate(360deg);
                }
            }
        </style>
        <%
            String uri = request.getRequestURI().toLowerCase();
            String section = request.getParameter("section");
        %>
    </head>
    <body>
        <div class="admin-container">
            <!-- Sidebar -->
            <aside class="admin-sidebar" id="adminSidebar">
                <div class="sidebar-header">
                    <a href="#" class="sidebar-brand">
                        <i class="fas fa-ticket-alt"></i>
                        <span>MovieTicketAdmin</span>
                    </a>
                </div>
                
                <nav class="sidebar-menu">
                    <div class="menu-section">Thống kê</div>
                    <a href="list" class="menu-item <%= uri.contains("chart") ? "active" : "" %>">
                        <i class="menu-icon fas fa-chart-line"></i>
                        <span>Thống kê</span>
                    </a>

                    <div class="menu-section">Quản lý</div>
                    <a href="dashboard?section=user-management" class="menu-item <%= "user-management".equals(section) ? "active" : "" %>">
                        <i class="menu-icon fas fa-user-shield"></i>
                        <span>Quản lý tài khoản</span>
                    </a>
                    <a href="/SWP-Group4-Fall25/list" class="menu-item <%= uri.contains("listmovie") ? "active" : "" %>">
                        <i class="menu-icon fas fa-film"></i>
                        <span>Quản lý phim</span>
                    </a>
                    <a href="dashboard?section=cinema-management" class="menu-item <%= "cinema-management".equals(section) ? "active" : "" %>">
                        <i class="menu-icon fas fa-building"></i>
                        <span>Quản lý rạp chiếu</span>
                    </a>
                    <a href="dashboard?section=screening-room-management" class="menu-item <%= "screening-room-management".equals(section) ? "active" : "" %>">
                        <i class="menu-icon fas fa-video"></i>
                        <span>Quản lý phòng chiếu</span>
                    </a>
                    <a href="/SWP-Group4-Fall25/listScreening" class="menu-item <%= uri.contains("listscreening") ? "active" : "" %>">
                        <i class="menu-icon fas fa-film"></i>
                        <span>Quản lý lịch chiếu</span>
                    </a>
                    <a href="/SWP-Group4-Fall25/listDiscount" class="menu-item <%= uri.contains("listdiscount") ? "active" : "" %>">
                        <i class="menu-icon fas fa-tags"></i>
                        <span>Quản lý khuyến mại</span>
                    </a>
                    <a href="/SWP-Group4-Fall25/food-management" class="menu-item <%= uri.contains("food") ? "active" : "" %>">
                        <i class="menu-icon fas fa-utensils"></i>
                        <span>Quản lý đồ ăn</span>
                    </a>

                    <div class="menu-section">Tài khoản</div>
                    <a href="logout" class="menu-item logout">
                        <i class="menu-icon fas fa-sign-out-alt"></i>
                        <span>Đăng xuất</span>
                    </a>
                </nav>
            </aside>

            <!-- Main Content -->
            <main class="admin-main" id="adminMain">
                <!-- Header -->
                <header class="admin-header" id="adminHeader">
                    <div class="header-content">
<!--                        <div class="header-left">
                            <button class="sidebar-toggle" id="sidebarToggle">
                                <i class="fas fa-bars"></i>
                            </button>
                            <h1 class="header-title" id="pageTitle">
                                <c:choose>
                                    <c:when test="${param.section eq 'user-management'}">Quản lý tài khoản</c:when>
                                    <c:when test="${param.section eq 'cinema-management'}">Quản lý rạp chiếu</c:when>
                                    <c:when test="${param.section eq 'screening-room-management'}">Quản lý phòng chiếu</c:when>
                                    <c:otherwise>Admin Dashboard</c:otherwise>
                                </c:choose>
                            </h1>
                        </div>-->
                        
<!--                        <div class="header-right">
                            <div class="search-box">
                                <input type="text" class="search-input" placeholder="Tìm kiếm...">
                            </div>
                            
                            <div class="user-menu">
                                <button class="user-btn" id="userMenuButton">
                                    <div class="user-avatar">
                                        <i class="fas fa-user"></i>
                                    </div>
                                    <span>Admin</span>
                                    <i class="fas fa-chevron-down"></i>
                                </button>
                                <ul class="dropdown-menu" aria-labelledby="userMenuButton">
                                    <li><a class="dropdown-item" href="#"><i class="fas fa-user me-2"></i>Hồ sơ</a></li>
                                    <li><a class="dropdown-item" href="#"><i class="fas fa-cog me-2"></i>Cài đặt</a></li>
                                    <li><hr class="dropdown-divider"></li>
                                    <li><a class="dropdown-item" href="logout"><i class="fas fa-sign-out-alt me-2"></i>Đăng xuất</a></li>
                                </ul>
                            </div>
                        </div>-->
                    </div>
                </header>

                <!-- Dynamic Content -->
                <div class="content-area">
                    <div class="content-header">
                        <h2 class="content-title" id="contentTitle">
                            <c:choose>
                                <c:when test="${param.section eq 'user-management'}">User Management</c:when>
                                <c:when test="${param.section eq 'cinema-management'}">Cinema Management</c:when>
                            </c:choose>
                        </h2>
                        <p class="content-subtitle" id="contentSubtitle">
                            <c:choose>
                                <c:when test="${param.section eq 'user-management'}">User information management </c:when>
                                <c:when test="${param.section eq 'cinema-management'}">Cinema information management</c:when>
                            </c:choose>
                        </p>
                    </div>

                    <div class="content-body">
                        <c:choose>
                            <c:when test="${param.section eq 'user-management'}">
                                <jsp:include page="user_management.jsp"/>
                            </c:when>
                            <c:when test="${param.section eq 'cinema-management'}">
                                <jsp:include page="cinema_management.jsp"/>
                            </c:when>
                            <c:when test="${param.section eq 'screening-room-management'}">
                                <jsp:include page="screening_room_management.jsp"/>
                            </c:when>
                            <c:otherwise>
                                <div class="content-card">
                                    <div class="row">
                                        <div class="col-md-3 mb-4">
                                            <div class="card bg-primary text-white">
                                                <div class="card-body">
                                                    <div class="d-flex justify-content-between">
                                                        <div>
                                                            <h4 class="card-title">1,234</h4>
                                                            <p class="card-text">Người dùng</p>
                                                        </div>
                                                        <div class="align-self-center">
                                                            <i class="fas fa-users fa-2x"></i>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="col-md-3 mb-4">
                                            <div class="card bg-success text-white">
                                                <div class="card-body">
                                                    <div class="d-flex justify-content-between">
                                                        <div>
                                                            <h4 class="card-title">45</h4>
                                                            <p class="card-text">Rạp chiếu</p>
                                                        </div>
                                                        <div class="align-self-center">
                                                            <i class="fas fa-building fa-2x"></i>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="col-md-3 mb-4">
                                            <div class="card bg-warning text-white">
                                                <div class="card-body">
                                                    <div class="d-flex justify-content-between">
                                                        <div>
                                                            <h4 class="card-title">128</h4>
                                                            <p class="card-text">Phim đang chiếu</p>
                                                        </div>
                                                        <div class="align-self-center">
                                                            <i class="fas fa-film fa-2x"></i>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="col-md-3 mb-4">
                                            <div class="card bg-info text-white">
                                                <div class="card-body">
                                                    <div class="d-flex justify-content-between">
                                                        <div>
                                                            <h4 class="card-title">5,678</h4>
                                                            <p class="card-text">Đơn hàng</p>
                                                        </div>
                                                        <div class="align-self-center">
                                                            <i class="fas fa-ticket-alt fa-2x"></i>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <div class="text-center py-5">
                                        <h3>Chào mừng đến với Admin Dashboard</h3>
                                        <p class="text-muted">Chọn một mục từ sidebar để bắt đầu</p>
                                    </div>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </main>
        </div>

        <!-- Bootstrap & Custom Scripts -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            // Sidebar Toggle
            document.getElementById('sidebarToggle').addEventListener('click', function() {
                const sidebar = document.getElementById('adminSidebar');
                const main = document.getElementById('adminMain');
                const header = document.getElementById('adminHeader');
                
                if (window.innerWidth >= 768) {
                    // Desktop toggle
                    if (sidebar.style.width === '70px') {
                        sidebar.style.width = '250px';
                        main.style.marginLeft = '250px';
                        header.style.left = '250px';
                    } else {
                        sidebar.style.width = '70px';
                        main.style.marginLeft = '70px';
                        header.style.left = '70px';
                    }
                } else {
                    // Mobile toggle
                    sidebar.classList.toggle('mobile-open');
                }
            });

            // User Menu Dropdown
            const userMenuButton = document.getElementById('userMenuButton');
            const userDropdown = new bootstrap.Dropdown(userMenuButton);

            // Active menu item handling
            document.querySelectorAll('.menu-item').forEach(item => {
                item.addEventListener('click', function() {
                    document.querySelectorAll('.menu-item').forEach(i => i.classList.remove('active'));
                    this.classList.add('active');
                });
            });

            // Search functionality
            const searchInput = document.querySelector('.search-input');
            searchInput.addEventListener('focus', function() {
                this.style.width = '300px';
            });

            searchInput.addEventListener('blur', function() {
                if (window.innerWidth >= 768) {
                    this.style.width = '250px';
                }
            });

            // Responsive handling
            window.addEventListener('resize', function() {
                if (window.innerWidth >= 768) {
                    document.getElementById('adminSidebar').style.transform = 'translateX(0)';
                }
            });

            // Modal z-index fix
            document.addEventListener('DOMContentLoaded', function() {
                const modals = document.querySelectorAll('.modal');
                modals.forEach(modal => {
                    modal.style.zIndex = '1060';
                });
            });

            // Page title update
            function updatePageTitle(title, subtitle) {
                document.getElementById('pageTitle').textContent = title;
                document.getElementById('contentTitle').textContent = title;
                document.getElementById('contentSubtitle').textContent = subtitle;
            }

            // Initialize tooltips
            const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
            const tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
                return new bootstrap.Tooltip(tooltipTriggerEl);
            });
        </script>
    </body>
</html>