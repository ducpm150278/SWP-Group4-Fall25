
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge" />
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />
        <meta name="description" content="" />
        <meta name="author" content="" />
        <title>Menu</title>
        <link href="https://cdn.jsdelivr.net/npm/simple-datatables@latest/dist/style.css" rel="stylesheet" />
        <link href="css/style-room.css" rel="stylesheet" type="text/css"/>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/js/all.min.js" crossorigin="anonymous"></script>

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




        </style>

        <%
            String uri = request.getRequestURI().toLowerCase();
            boolean isFood = uri.contains("managerfood") || uri.contains("managerorder");
            boolean isBlog = uri.contains("listpost") || uri.contains("addpost");
            boolean isPromo = uri.contains("promotion-list") || uri.contains("add-promotion");
        %>
        <%
    // Debug
    System.out.println("Current URI: " + uri);
%>

    </head>
    <body>
        <div id="layoutSidenav">
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
                            <a class="<%= uri.equals("/adminFE/dashboard?section=user-management") ? "nav-link active" : "nav-link" %>" href="adminFE/dashboard?section=user-management">
                                <div class="sb-nav-link-icon"><i class="fas fa-user-shield"></i></div>
                                Quản lý tài khoản
                            </a>
                            <a class="<%= uri.equals("/swp-group4-fall25/listmovie.jsp") ? "nav-link active" : "nav-link" %>" href="list">
                                <div class="sb-nav-link-icon"><i class="fas fa-film"></i></div>
                                Quản lý phim
                            </a>

                            <a class="<%= uri.contains("/adminFE/dashboard?section=cinema-management") ? "nav-link active" : "nav-link" %>" href="adminFE/dashboard?section=cinema-management">
                                <div class="sb-nav-link-icon"><i class="fas fa-building"></i></div>
                                Quản lý rạp chiếu
                            </a>

                            <a class="<%= uri.contains("/adminFE/dashboard?section=screening-room-management") ? "nav-link active" : "nav-link" %>" href="adminFE/dashboard?section=screening-room-management">
                                <div class="sb-nav-link-icon"><i class="fas fa-video""></i></div>
                                Quản lý phòng chiếu
                            </a>
                            <a class="<%= uri.equals("/swp-group4-fall25/listscreening.jsp") ? "nav-link active" : "nav-link" %>" href="listScreening">
                                <div class="sb-nav-link-icon"><i class="fas fa-film"></i></div>
                                Quản lý lịch chiếu
                            </a>

                            <a class="<%= uri.contains("/swp-group4-fall25/listdiscount.jsp") ? "nav-link active" : "nav-link" %>" href="listDiscount">
                                <div class="sb-nav-link-icon"><i class="fas fa-tags"></i></div>
                                Quản lý khuyến mại
                            </a>


                            <!-- Quản lý đồ ăn -->
                            <a class="<%= uri.contains("approve-booking.jsp") ? "nav-link active" : "nav-link" %>" href="food-management">
                                <div class="sb-nav-link-icon"><i class="fas fa-utensils"></i></div>
                                Quản lý đồ ăn
                            </a>
                           
                            <!-- Tài khoản -->
                            <div class="sb-sidenav-menu-heading">Tài khoản</div>
                            <a class="nav-link text-danger" href="logout">
                                <div class="sb-nav-link-icon"><i class="fas fa-sign-out-alt"></i></div>
                                Đăng xuất
                            </a>

                        </div>
                    </div>
                </nav>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js" crossorigin="anonymous"></script>
        <script src="js/scripts.js"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.8.0/Chart.min.js" crossorigin="anonymous"></script>
        <script src="assets/demo/chart-area-demo.js"></script>
        <script src="assets/demo/chart-bar-demo.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/simple-datatables@latest" crossorigin="anonymous"></script>
        <script src="js/datatables-simple-demo.js"></script>
    </body>
</html>
