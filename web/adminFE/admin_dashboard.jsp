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
            :root {
                --sidebar-width: 250px;
                --sidebar-bg: #343a40;
                --sidebar-color: #fff;
                --sidebar-active-bg: #007bff;
                --header-bg: #f8f9fa;
                --content-bg: #f5f5f5;
            }

            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                background-color: var(--content-bg);
                overflow-x: hidden;
            }

            /* Sidebar Styles */
            .sidebar {
                width: var(--sidebar-width);
                height: 100vh;
                position: fixed;
                left: 0;
                top: 0;
                background: var(--sidebar-bg);
                color: var(--sidebar-color);
                transition: all 0.3s;
                z-index: 1000;
            }

            .sidebar-header {
                padding: 20px;
                background: rgba(0, 0, 0, 0.2);
                text-align: center;
            }

            .sidebar-header h3 {
                margin-bottom: 0;
            }

            .sidebar-menu {
                padding: 20px 0;
            }

            .sidebar-menu ul {
                list-style: none;
                padding: 0;
                margin: 0;
            }

            .sidebar-menu li a {
                display: block;
                padding: 12px 20px;
                color: var(--sidebar-color);
                text-decoration: none;
                transition: all 0.3s;
            }

            .sidebar-menu li a:hover {
                background: rgba(255, 255, 255, 0.1);
            }

            .sidebar-menu li a i {
                margin-right: 10px;
                width: 20px;
                text-align: center;
            }

            .sidebar-menu li.active a {
                background: var(--sidebar-active-bg);
            }

            .sidebar-footer {
                position: absolute;
                bottom: 0;
                width: 100%;
                padding: 15px;
                border-top: 1px solid rgba(255, 255, 255, 0.1);
            }

            /* Main Content Styles */
            .main-content {
                margin-left: var(--sidebar-width);
                min-height: 100vh;
                transition: all 0.3s;
            }

            /* Header Styles */
            .header {
                padding: 15px;
                background: var(--header-bg);
                box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
                display: flex;
                justify-content: space-between;
                align-items: center;
            }

            .user-info {
                display: flex;
                align-items: center;
            }

            .user-info img {
                width: 40px;
                height: 40px;
                border-radius: 50%;
                margin-right: 10px;
            }

            /* Card Styles */
            .card {
                border: none;
                border-radius: 10px;
                box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
                margin-bottom: 20px;
                transition: transform 0.3s;
            }

            .card:hover {
                transform: translateY(-5px);
            }

            .card-body {
                padding: 20px;
            }

            .card-icon {
                font-size: 2rem;
                margin-bottom: 15px;
                color: #007bff;
            }

            /* Responsive Styles */
            @media (max-width: 768px) {
                .sidebar {
                    margin-left: -250px;
                }

                .sidebar.active {
                    margin-left: 0;
                }

                .main-content {
                    margin-left: 0;
                }

                .main-content.active {
                    margin-left: 250px;
                }
            }

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
                border: 1px solid #e9ecef; /* viền nhẹ */
                box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.1); /* bóng đổ */
                padding: 0.25rem 0; /* padding cho menu */
                min-width: 12rem; /* chiều rộng tối thiểu */
            }

            /* CSS cho các item trong dropdown khi bình thường */
            #user-management-content .dropdown-menu li {
                transition: all 0.2s ease; /* hiệu ứng mượt khi hover */
            }

            /* CSS cho các item trong dropdown khi hover */
            #user-management-content .dropdown-menu li:hover {
                background-color: #f8f9fa; /* màu nền khi hover */
            }

            /* CSS cho các link trong dropdown */
            #user-management-content .dropdown-menu li a.dropdown-item {
                padding: 0.5rem 1.5rem; /* padding cho item */
                color: #212529; /* màu chữ */
                font-size: 0.875rem; /* cỡ chữ */
                display: block; /* hiển thị dạng block */
                clear: both; /* clear float */
                font-weight: 400; /* độ đậm chữ */
                text-decoration: none; /* bỏ gạch chân */
                white-space: nowrap; /* không xuống dòng */
                transition: all 0.2s ease; /* hiệu ứng mượt */
            }

            /* CSS cho link khi hover */
            #user-management-content .dropdown-menu li a.dropdown-item:hover {
                background-color: #f1f3f5; /* màu nền khi hover */
                color: #0d6efd; /* màu chữ khi hover (màu primary) */
            }

            /* CSS cho divider */
            #user-management-content .dropdown-menu li .dropdown-divider {
                margin: 0.25rem 0; /* khoảng cách trên dưới */
                border-top: 1px solid #e9ecef; /* đường kẻ ngang */
            }

            /* CSS cho icon trong dropdown item */
            #user-management-content .dropdown-menu li a.dropdown-item i.bi {
                margin-right: 0.5rem; /* khoảng cách với text */
                width: 1em; /* chiều rộng icon */
                text-align: center; /* căn giữa icon */
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

            #price-update-content .active-filters {
                display: inline-flex;
                align-items: center;
                flex-wrap: wrap;
                gap: 0.5rem;
            }

            /* Đảm bảo các badge không bị wrap khi không đủ chỗ */
            #price-update-content .active-filters .badge {
                white-space: nowrap;
            }

            #request-management-content .stat-card {
                min-width: 120px;
            }

            #request-management-content .change-comparison {
                max-width: 200px;
                word-break: break-word;
            }

            #request-management-content .view-detail-btn {
                white-space: nowrap;
            }

            /* Sửa lại phần dropdown */
            #request-management-content .dropdown-menu {
                border: none;
                box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.15);
                border-radius: 0.5rem;
                padding: 0.5rem;
                margin-top: 0.5rem;
                min-width: 12rem;
            }

            #request-management-content .dropdown-item {
                border-radius: 0.25rem;
                padding: 0.5rem 1rem;
                margin: 0.125rem 0;
                transition: all 0.2s;
                display: flex;
                align-items: center;
            }

            #request-management-content .dropdown-item:hover,
            #request-management-content .dropdown-item:focus {
                background-color: #f8f9fa;
                color: #0d6efd;
            }

            #request-management-content .dropdown-item.active {
                background-color: #0d6efd;
                color: white;
            }

            #request-management-content .dropdown-divider {
                margin: 0.5rem 0;
                border-color: rgba(0, 0, 0, 0.05);
            }

            /* Date dropdown specific */
            #request-management-content #dateDropdown .dropdown-menu {
                width: 300px;
                padding: 1rem;
            }

            /* Đảm bảo table responsive không chồng lên dropdown */
            #request-management-content .table-responsive {
                position: relative;
                overflow-x: auto;
                -webkit-overflow-scrolling: touch;
            }

            /* Giảm kích thước font của chart */
            #roleChart {
                max-height: 180px;
                width: 100% !important;
            }

            /* Thu nhỏ text trong activity items */
            #statistical-content .recent-activity-item {
                font-size: 0.85rem;
                line-height: 1.3;
            }

            /* Đảm bảo card có chiều cao bằng nhau */
            #statistical-content .equal-height-card {
                display: flex;
                flex-direction: column;
                height: 100%;
            }
            #statistical-content .equal-height-card .card-body {
                flex: 1;
            }
        </style>
    </head>
    <body>
        <!-- Sidebar -->
        <div class="sidebar">
            <div class="sidebar-header">
                <h3>Admin Panel</h3>
            </div>

            <div class="sidebar-menu">
                <ul>
<!--                    <li class="${param.section eq 'statistical' or empty param.section ? 'active' : ''}">
                        <a href="<c:url value='/admin/dashboard?section=statistical'/>">
                            <i class="fas fa-chart-bar"></i>
                            <span>Statistical</span>
                        </a>
                    </li>-->
                    <li class="${param.section eq 'user-management' ? 'active' : ''}">
                        <a href="<c:url value='/adminFE/dashboard?section=user-management'/>">
                            <i class="fas fa-users"></i>
                            <span>User Management</span>
                        </a>
                    </li>
<!--                    <li class="${param.section eq 'price-update' ? 'active' : ''}">
                        <a href="<c:url value='/admin/dashboard?section=price-update'/>">
                            <i class="fas fa-tags"></i>
                            <span>Price Update</span>
                        </a>
                    </li>-->
<!--                    <li class="${param.section eq 'log-history' ? 'active' : ''}">
                        <a href="<c:url value='/admin/dashboard?section=log-history'/>">
                            <i class="fas fa-history"></i>
                            <span>Log History</span>
                        </a>
                    </li>
                    <li class="${param.section eq 'request-management' ? 'active' : ''}">
                        <a href="<c:url value='/admin/dashboard?section=request-management'/>">
                            <i class="fas fa-envelope"></i>
                            <span>Request</span>
                        </a>
                    </li>-->
                </ul>
            </div>

            <div class="sidebar-footer">
                <button class="btn btn-danger btn-block" onclick="logout()">
                    <i class="fas fa-sign-out-alt"></i> Logout
                </button>
            </div>
        </div>

        <!-- Main Content -->
        <div class="main-content">
            <!-- Header -->
            <div class="header">
                <button class="btn btn-primary d-md-none" id="sidebarToggle">
                    <i class="fas fa-bars"></i>
                </button>

                <div class="user-info">
                    <!--<img src="https://via.placeholder.com/40" alt="Admin Avatar">-->
                    <span>Welcome, <c:out value="${sessionScope.admin.name}" default="Admin"/></span>
                </div>
            </div>

            <!-- Content Area -->
            <div class="container-fluid py-4" id="contentArea">
                <c:choose>
                    <c:when test="${param.section eq 'user-management'}">
                        <jsp:include page="user_management.jsp"/>
                    </c:when>
                    <c:when test="${param.section eq 'price-update'}">
                        <jsp:include page="price-update.jsp"/>
                    </c:when>
                    <c:when test="${param.section eq 'log-history'}">
                        <jsp:include page="log-history.jsp"/>
                    </c:when>
                    <c:when test="${param.section eq 'request-management'}">
                        <jsp:include page="request.jsp"/>
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

        <!-- Bootstrap JS and dependencies -->
        <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <!-- Chart.js -->
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

        <script>
                    // Logout function
                    function logout() {
                        if (confirm('Are you sure you want to logout?')) {
                            window.location.href = '<c:url value="/admin/logout"/>';
                        }
                    }
        </script>
    </body>
</html>