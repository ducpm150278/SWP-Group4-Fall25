
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
            .nav-link.active {
                background-color: #0d6efd !important;
                color: white !important;
            }
            .nav-link.active i {
                color: white !important;
            }
            .sb-sidenav-menu-nested .nav-link.active {
                background-color: #0d6efd !important;
                color: white !important;
            }
            /* Layout container */
            #layoutSidenav {
                display: flex;
            }

            /* Sidebar cố định */
            #layoutSidenav_nav {
                position: fixed;
                top: 0;
                left: 0;
                width: 250px;     /* chiều rộng sidebar */
                height: 100vh;    /* full chiều cao màn hình */
                overflow-y: auto; /* cuộn riêng nếu dài */
                z-index: 1000;
            }

            /* Nội dung chính */
            #layoutSidenav_content {
                margin-left: 250px;  /* tránh bị sidebar che */
                width: calc(100% - 250px);
                padding: 20px;
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
                            <a class="<%= uri.equals("/hotelrentalmanagement/views/dashboard/room.jsp") ? "nav-link active" : "nav-link" %>" href="listRoom">
                                <div class="sb-nav-link-icon"><i class="fas fa-user-shield"></i></div>
                                Quản lý tài khoản
                            </a>
                            <a class="<%= uri.equals("/swp-group4-fall25/listmovie.jsp") ? "nav-link active" : "nav-link" %>" href="list">
                                <div class="sb-nav-link-icon"><i class="fas fa-film"></i></div>
                                Quản lý phim
                            </a>

                            <a class="<%= uri.contains("feedbackmanager") ? "nav-link active" : "nav-link" %>" href="feedbackmanager">
                                <div class="sb-nav-link-icon"><i class="fas fa-building"></i></div>
                                Quản lý rạp chiếu
                            </a>

                            <a class="<%= uri.contains("management-feedback-room.jsp") ? "nav-link active" : "nav-link" %>" href="feedbackroommanagement">
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
                            <a class="<%= uri.contains("approve-booking.jsp") ? "nav-link active" : "nav-link" %>" href="listapprovebooking">
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
