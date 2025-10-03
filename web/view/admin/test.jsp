<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%--<%@ page import="model.Room" %>
<%@ page import="dal.RoomDAO" %>--%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge" />
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />
        <meta name="description" content="" />
        <meta name="author" content="" />
        <title>Tiện nghi phòng</title>
        <link href="https://cdn.jsdelivr.net/npm/simple-datatables@latest/dist/style.css" rel="stylesheet" />
        <link href="css/style-room.css" rel="stylesheet" type="text/css"/>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/js/all.min.js" crossorigin="anonymous"></script>
    </head>
    <body class="sb-nav-fixed">
        <nav class="sb-topnav navbar navbar-expand navbar-dark bg-dark">
            <%@ include file="header.jsp" %>  
        </nav>

        <div id="layoutSidenav">
            <%@ include file="menu-manager.jsp" %>  

            <div id="layoutSidenav_content">
                <main class="container-fluid p-4 bg-light min-vh-100">
                    <h2 class="mb-4">Thông tin loại phòng</h2>

                    <div class="card mb-4 shadow-sm border-0 rounded-3">
                        <div class="card-body">
                            <!-- Tên loại phòng -->
                            <h4 class="card-title">${roomType.typeName}</h4>

                            <!-- Giá cơ bản -->
                            <h6 class="card-subtitle mb-2 text-muted">
                                Giá cơ bản:
                                <strong>
                                    <fmt:formatNumber value="${roomType.basePrice}" type="number" groupingUsed="true" /> VND
                                </strong>
                            </h6>

                            <p class="card-text">${roomType.description}</p>

                            <h6 class="mt-4">Tiện ích hiện tại:</h6>
                            <ul class="list-inline">
                                <c:forEach var="amenity" items="${roomType.amenities}">
                                    <li class="list-inline-item mb-1">
                                        <span class="badge bg-secondary">${amenity}</span>
                                    </li>
                                </c:forEach>
                                <c:if test="${empty roomType.amenities}">
                                    <li><span class="text-muted">Không có tiện ích nào</span></li>
                                    </c:if>
                            </ul>

                            <h6 class="mt-4">Phòng thuộc loại này:</h6>
                            <ul class="list-inline">
                                <c:forEach var="room" items="${roomType.rooms}">
                                    <li class="list-inline-item mb-1">
                                        <span class="badge bg-info text-dark">Phòng số ${room.roomNumber}</span>
                                    </li>
                                </c:forEach>
                                <c:if test="${empty roomType.rooms}">
                                    <li><span class="text-muted">Chưa có phòng nào</span></li>
                                    </c:if>
                            </ul>

                            <h6 class="mt-4">Thêm tiện ích mới:</h6>
                            <form action="createRoomAmenity" method="get" class="row g-3 mt-2">
                                <input type="hidden" name="roomTypeId" value="${roomType.roomTypeId}" />
                                <div class="col-auto">
                                    <input type="text" name="amenity" class="form-control" placeholder="Tên tiện ích" required />
                                </div>
                                <div class="col-auto">
                                    <button type="submit" class="btn btn-primary">Thêm</button>
                                </div>
                            </form>

                            <c:if test="${not empty error}">
                                <div class="mt-3 text-danger">${error}</div>
                            </c:if>
                        </div>
                    </div>
                </main>



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
