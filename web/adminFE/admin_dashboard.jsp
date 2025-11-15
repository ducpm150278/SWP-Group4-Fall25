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
            /* Layout container */
            #layoutSidenav {
                display: flex;
                min-height: 100vh;
            }

            /* Sidebar cố định */
            #layoutSidenav_nav {
                position: fixed;
                top: 0;
                left: 0;
                width: 250px;
                height: 100vh;
                overflow-y: auto;
                z-index: 1000;
                background: linear-gradient(180deg, #2c3e50 0%, #34495e 100%);
                box-shadow: 2px 0 10px rgba(0,0,0,0.1);
            }

            /* Nội dung chính */
            #layoutSidenav_content {
                margin-left: 250px;
                width: calc(100% - 250px);
                padding: 20px;
                background-color: #f8f9fa;
                min-height: 100vh;
                position: relative;
                z-index: 1;
            }

            /* CHỈ áp dụng các style sau cho sidebar */
            #layoutSidenav_nav .sb-sidenav {
                background: transparent !important;
            }

            #layoutSidenav_nav .sb-sidenav-dark {
                background: linear-gradient(180deg, #2c3e50 0%, #34495e 100%) !important;
            }

            #layoutSidenav_nav .sb-sidenav-menu {
                padding: 1rem 0;
            }

            #layoutSidenav_nav .sb-sidenav-menu-heading {
                padding: 0.75rem 1.5rem;
                font-size: 0.75rem;
                font-weight: 700;
                text-transform: uppercase;
                letter-spacing: 0.5px;
                color: #bdc3c7 !important;
                margin-top: 1rem;
            }

            #layoutSidenav_nav .nav-link {
                display: flex;
                align-items: center;
                padding: 0.75rem 1.5rem;
                color: #ecf0f1 !important;
                text-decoration: none;
                transition: all 0.3s ease;
                border: none;
                background: transparent;
                width: 100%;
                font-size: 0.9rem;
            }

            #layoutSidenav_nav .nav-link:hover {
                background-color: rgba(255,255,255,0.1) !important;
                color: #ffffff !important;
                transform: translateX(5px);
            }

            #layoutSidenav_nav .nav-link.active {
                background: linear-gradient(90deg, #3498db 0%, #2980b9 100%) !important;
                color: white !important;
                border-right: 3px solid #ffffff;
                box-shadow: inset 0 0 10px rgba(0,0,0,0.1);
            }

            #layoutSidenav_nav .nav-link.active i {
                color: white !important;
            }

            #layoutSidenav_nav .sb-nav-link-icon {
                margin-right: 0.75rem;
                font-size: 1rem;
                width: 20px;
                text-align: center;
                color: #bdc3c7;
            }

            #layoutSidenav_nav .nav-link.active .sb-nav-link-icon {
                color: white !important;
            }

            #layoutSidenav_nav .nav-link:hover .sb-nav-link-icon {
                color: #3498db;
            }

            /* Text danger cho logout */
            #layoutSidenav_nav .nav-link.text-danger {
                color: #e74c3c !important;
            }

            #layoutSidenav_nav .nav-link.text-danger:hover {
                background-color: rgba(231, 76, 60, 0.1) !important;
                color: #c0392b !important;
            }

            /* Scrollbar styling chỉ cho sidebar */
            #layoutSidenav_nav::-webkit-scrollbar {
                width: 6px;
            }

            #layoutSidenav_nav::-webkit-scrollbar-track {
                background: #34495e;
            }

            #layoutSidenav_nav::-webkit-scrollbar-thumb {
                background: #3498db;
                border-radius: 3px;
            }

            /* Responsive adjustments */
            @media (max-width: 768px) {
                #layoutSidenav_nav {
                    width: 70px;
                }

                #layoutSidenav_content {
                    margin-left: 70px;
                    width: calc(100% - 70px);
                }

                #layoutSidenav_nav .sb-sidenav-menu-heading,
                #layoutSidenav_nav .nav-link span {
                    display: none;
                }

                #layoutSidenav_nav .sb-nav-link-icon {
                    margin-right: 0;
                    font-size: 1.2rem;
                }

                #layoutSidenav_nav .nav-link {
                    justify-content: center;
                    padding: 1rem 0.5rem;
                }
            }

            /* GIỮ LẠI TẤT CẢ CÁC STYLE CŨ CHO CONTENT - KHÔNG THAY ĐỔI */
            #user-management-content .readonly {
                background-color: #A8A8A8;
                border: none;
            }
            /* CSS cho password field và toggle button */
            #user-management-content .password-container {
                position: relative;
            }

            #user-management-content .password-toggle-btn {
                position: absolute;
                right: 0;
                top: 50%;
                transform: translateY(-50%);
                background: none;
                border: none;
                padding: 0 10px;
                padding-top: 22px;
                cursor: pointer;
            }

            #user-management-content .password-toggle-btn:hover {
                background: none;
            }

            #user-management-content .password-toggle-btn:focus {
                outline: none;
                box-shadow: none;
            }

            /* Đảm bảo input password có padding-right để không bị chữ đè lên button */
            #user-management-content #passwordField {
                padding-right: 40px;
            }

            /* CSS cho dropdown menu */
            #user-management-content .dropdown-menu {
                border: 1px solid #e9ecef;
                box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.1);
                padding: 0.25rem 0;
                min-width: 12rem;
            }

            /* CSS cho các item trong dropdown khi bình thường */
            #user-management-content .dropdown-menu li {
                transition: all 0.2s ease;
            }

            /* CSS cho các item trong dropdown khi hover */
            #user-management-content .dropdown-menu li:hover {
                background-color: #f8f9fa;
            }

            /* CSS cho các link trong dropdown */
            #user-management-content .dropdown-menu li a.dropdown-item {
                padding: 0.5rem 1.5rem;
                color: #212529;
                font-size: 0.875rem;
                display: block;
                clear: both;
                font-weight: 400;
                text-decoration: none;
                white-space: nowrap;
                transition: all 0.2s ease;
            }

            /* CSS cho link khi hover */
            #user-management-content .dropdown-menu li a.dropdown-item:hover {
                background-color: #f1f3f5;
                color: #0d6efd;
            }

            /* CSS cho divider */
            #user-management-content .dropdown-menu li .dropdown-divider {
                margin: 0.25rem 0;
                border-top: 1px solid #e9ecef;
            }

            /* CSS cho icon trong dropdown item */
            #user-management-content .dropdown-menu li a.dropdown-item i.bi {
                margin-right: 0.5rem;
                width: 1em;
                text-align: center;
            }

            /* Empty state container */
            #user-management-content .empty-state-container {
                background-color: #f8f9fa;
                border-radius: 12px;
                border: 1px dashed #dee2e6;
                margin: 2rem 0;
                padding: 3rem !important;
                animation: fadeIn 0.5s ease;
            }

            #user-management-content .empty-state-image {
                opacity: 0.7;
                filter: grayscale(30%);
            }

            #user-management-content .empty-state-title {
                font-size: 1.5rem;
                font-weight: 500;
            }

            #user-management-content .empty-state-title i {
                font-size: 1.8rem;
                vertical-align: middle;
                margin-right: 0.5rem;
            }

            #user-management-content .empty-state-description {
                font-size: 1.05rem;
                line-height: 1.6;
                max-width: 500px;
                margin-left: auto;
                margin-right: auto;
            }

            @keyframes fadeIn {
                from {
                    opacity: 0;
                    transform: translateY(20px);
                }
                to {
                    opacity: 1;
                    transform: translateY(0);
                }
            }

            /* Responsive adjustments */
            @media (max-width: 576px) {
                #user-management-content .empty-state-image {
                    width: 120px;
                }
                #user-management-content .empty-state-title {
                    font-size: 1.3rem;
                }
                #user-management-content .d-flex {
                    flex-direction: column;
                    gap: 1rem !important;
                }
            }

            #user-management-content .btn-primary:hover {
                transform: translateY(-2px);
                box-shadow: 0 4px 8px rgba(0, 123, 255, 0.2);
                transition: all 0.3s ease;
            }

            /* CSS cho các trường readonly trong modal edit */
            #user-management-content .form-control[readonly] {
                background-color: #f8f9fa !important;
                border-color: #e9ecef !important;
                color: #6c757d !important;
                cursor: not-allowed !important;
                opacity: 0.8 !important;
            }

            #user-management-content .form-control:not([readonly]) {
                background-color: #ffffff !important;
                border-color: #ced4da !important;
                color: #212529 !important;
            }

            /* Đảm bảo select box khi disabled cũng có style tương tự */
            #user-management-content .form-select:disabled {
                background-color: #f8f9fa !important;
                border-color: #e9ecef !important;
                color: #6c757d !important;
                cursor: not-allowed !important;
                opacity: 0.8 !important;
            }

            #user-management-content .form-select:not(:disabled) {
                background-color: #ffffff !important;
                border-color: #ced4da !important;
                color: #212529 !important;
            }

            /* Style cho textarea readonly */
            #user-management-content textarea.form-control[readonly] {
                background-color: #f8f9fa !important;
                border-color: #e9ecef !important;
                color: #6c757d !important;
                resize: none !important;
            }

            /* Hiệu ứng chuyển tiếp mượt mà khi chuyển giữa edit và view mode */
            #user-management-content .form-control,
            #user-management-content .form-select {
                transition: all 0.3s ease-in-out;
            }

            /* Label style để phân biệt rõ hơn */
            #user-management-content .modal-body label {
                font-weight: 600;
                margin-bottom: 0.5rem;
                color: #495057;
            }

            /* Style đặc biệt cho password field */
            #user-management-content #passwordField[readonly] {
                background-color: #f8f9fa !important;
                border-color: #e9ecef !important;
                color: #6c757d !important;
                font-family: 'Courier New', monospace;
            }

            /* Đảm bảo button toggle password vẫn hoạt động tốt */
            #user-management-content .password-toggle-btn {
                z-index: 5;
            }

            /* Khi ở chế độ edit, các field có thể edit sẽ có border highlight */
            #user-management-content .form-select:not(:disabled) {
                border-color: #86b7fe !important;
                box-shadow: 0 0 0 0.25rem rgba(13, 110, 253, 0.25) !important;
            }

            /* Responsive adjustments */
            @media (max-width: 576px) {
                #user-management-content .modal-body .form-control,
                #user-management-content .modal-body .form-select {
                    font-size: 14px;
                }
            }

            /* Cinema Management Styles */
            #cinema-management-content .address-cell {
                max-width: 200px;
                overflow: hidden;
                text-overflow: ellipsis;
                white-space: nowrap;
            }

            #cinema-management-content .is-invalid {
                border-color: #dc3545 !important;
            }

            #cinema-management-content .invalid-feedback {
                display: none;
                width: 100%;
                margin-top: 0.25rem;
                font-size: 0.875em;
                color: #dc3545;
            }

            #cinema-management-content .is-invalid ~ .invalid-feedback {
                display: block;
            }

            #cinema-management-content .form-control[readonly] {
                background-color: #f8f9fa !important;
                border-color: #e9ecef !important;
                color: #6c757d !important;
                cursor: not-allowed !important;
                opacity: 0.8 !important;
            }

            #cinema-management-content .form-select:disabled {
                background-color: #f8f9fa !important;
                border-color: #e9ecef !important;
                color: #6c757d !important;
                cursor: not-allowed !important;
                opacity: 0.8 !important;
            }

            #cinema-management-content textarea.form-control[readonly] {
                background-color: #f8f9fa !important;
                border-color: #e9ecef !important;
                color: #6c757d !important;
                resize: none !important;
            }

            /* Responsive adjustments for cinema management */
            @media (max-width: 768px) {
                #cinema-management-content .table-responsive {
                    font-size: 0.875rem;
                }

                #cinema-management-content .address-cell {
                    max-width: 150px;
                }

                #cinema-management-content .btn-sm {
                    padding: 0.25rem 0.5rem;
                    font-size: 0.775rem;
                }
            }
        </style>
        <%
            String uri = request.getRequestURI().toLowerCase();
            boolean isFood = uri.contains("managerfood") || uri.contains("managerorder");
            boolean isBlog = uri.contains("listpost") || uri.contains("addpost");
            boolean isPromo = uri.contains("promotion-list") || uri.contains("add-promotion");
        %>
    </head>
    <body>
        <div id="layoutSidenav">
            <!-- Sidebar -->
            <div id="layoutSidenav_nav">
                <nav class="sb-sidenav accordion sb-sidenav-dark" id="sidenavAccordion">
                    <div class="sb-sidenav-menu">
                        <div class="nav">
                            <div class="sb-sidenav-menu-heading">Thống kê</div>
                            <a class="<%= uri.contains("chart") ? "nav-link active" : "nav-link" %>" href="list">
                                <div class="sb-nav-link-icon"><i class="fas fa-chart-line"></i></div>
                                Thống kê
                            </a>

                            <div class="sb-sidenav-menu-heading">Quản lý</div>
                            <a class="<%= uri.equals("/adminFE/dashboard?section=user-management") ? "nav-link active" : "nav-link" %>" href="dashboard?section=user-management">
                                <div class="sb-nav-link-icon"><i class="fas fa-user-shield"></i></div>
                                Quản lý tài khoản
                            </a>
                            <a class="<%= uri.equals("/swp-group4-fall25/listmovie.jsp") ? "nav-link active" : "nav-link" %>" href="/SWP-Group4-Fall25/list">
                                <div class="sb-nav-link-icon"><i class="fas fa-film"></i></div>
                                Quản lý phim
                            </a>

                            <a class="<%= uri.contains("/adminFE/dashboard?section=cinema-management") ? "nav-link active" : "nav-link" %>" href="dashboard?section=cinema-management">
                                <div class="sb-nav-link-icon"><i class="fas fa-building"></i></div>
                                Quản lý rạp chiếu
                            </a>

                            <a class="<%= uri.contains("/adminFE/dashboard?section=screening-room-management") ? "nav-link active" : "nav-link" %>" href="dashboard?section=screening-room-management">
                                <div class="sb-nav-link-icon"><i class="fas fa-video""></i></div>
                                Quản lý phòng chiếu
                            </a>
                            <a class="<%= uri.equals("/swp-group4-fall25/listscreening.jsp") ? "nav-link active" : "nav-link" %>" href="/SWP-Group4-Fall25/listScreening">
                                <div class="sb-nav-link-icon"><i class="fas fa-film"></i></div>
                                Quản lý lịch chiếu
                            </a>

                            <a class="<%= uri.contains("/swp-group4-fall25/listdiscount.jsp") ? "nav-link active" : "nav-link" %>" href="/SWP-Group4-Fall25/listDiscount">
                                <div class="sb-nav-link-icon"><i class="fas fa-tags"></i></div>
                                Quản lý khuyến mại
                            </a>

                            <!-- Quản lý đồ ăn -->
                            <a class="<%= uri.contains("approve-booking.jsp") ? "nav-link active" : "nav-link" %>" href="/SWP-Group4-Fall25/food-management">
                                <div class="sb-nav-link-icon"><i class="fas fa-utensils"></i></div>
                                Quản lý đồ ăn
                            </a>

                            <!-- Tài khoản -->
                            <div class="sb-sidenav-menu-heading">Tài khoản</div>
                            <a class="nav-link text-danger" href="/SWP-Group4-Fall25/logout">
                                <div class="sb-nav-link-icon"><i class="fas fa-sign-out-alt"></i></div>
                                Đăng xuất
                            </a>
                        </div>
                    </div>
                </nav>
            </div>

            <!-- Content Area - PHẢI NẰM TRONG CÙNG #layoutSidenav -->
            <div id="layoutSidenav_content">
                <div class="container-fluid py-4">
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
                            <!-- Default section or dashboard home -->
                            <div class="text-center py-5">
                                <h3>Welcome to Admin Dashboard</h3>
                                <p>Select a section from the sidebar to get started.</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div> <!-- Đóng #layoutSidenav ở đây -->

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js" crossorigin="anonymous"></script>
        <script src="js/scripts.js"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.8.0/Chart.min.js" crossorigin="anonymous"></script>
        <script src="assets/demo/chart-area-demo.js"></script>
        <script src="assets/demo/chart-bar-demo.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/simple-datatables@latest" crossorigin="anonymous"></script>
        <script src="js/datatables-simple-demo.js"></script>
    </body>
</html>