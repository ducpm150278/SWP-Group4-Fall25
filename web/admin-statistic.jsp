<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Thống Kê Doanh Thu</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
</head>
<body class="sb-nav-fixed">
    <nav class="sb-topnav navbar navbar-expand navbar-dark bg-dark">
        <%@ include file="view/admin/header.jsp" %>  
    </nav>
    <div id="layoutSidenav">
        <%@ include file="view/admin/menu-manager.jsp" %>  
        
        <div id="layoutSidenav_content">
            <main class="p-4">
                <div class="container-fluid">

                    <h2 class="mb-4">📊 Thống Kê Doanh Thu</h2>

                    <div class="row">
                        <div class="col-xl-4 col-md-6">
                            <div class="card bg-primary text-white mb-4">
                                <div class="card-body">
                                    <h4>Tổng Doanh Thu</h4>
                                    <h2><fmt:formatNumber value="${stats.totalRevenue}" type="number" pattern="#,###" />₫</h2>
                                </div>
                                <div class="card-footer d-flex align-items-center justify-content-between">
                                    <span class="small">30 ngày qua</span>
                                </div>
                            </div>
                        </div>
                        <div class="col-xl-4 col-md-6">
                            <div class="card bg-success text-white mb-4">
                                <div class="card-body">
                                    <h4>Tổng Vé Đã Bán</h4>
                                    <h2><fmt:formatNumber value="${stats.totalTicketsSold}" type="number" pattern="#,###" /> vé</h2>
                                </div>
                                <div class="card-footer d-flex align-items-center justify-content-between">
                                    <span class="small">30 ngày qua</span>
                                </div>
                            </div>
                        </div>
                        <div class="col-xl-4 col-md-6">
                            <div class="card bg-warning text-dark mb-4">
                                <div class="card-body">
                                    <h4>Đơn Hàng Hoàn Thành</h4>
                                    <h2><fmt:formatNumber value="${stats.totalBookings}" type="number" pattern="#,###" /> đơn</h2>
                                </div>
                                <div class="card-footer d-flex align-items-center justify-content-between">
                                    <span class="small">30 ngày qua</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="card mb-4">
                        <div class="card-header">
                            <i class="fas fa-chart-area me-1"></i>
                            Biểu Đồ Doanh Thu (Theo bộ lọc)
                        </div>
                        <div class="card-body">
                            
                            <form action="admin-statistic" method="GET">
                                <div class="row g-3 mb-3">
                                    <div class="col-md-3">
                                        <label for="filterFrom" class="form-label">Từ ngày</label>
                                        <input type="date" class="form-control" id="filterFrom" name="from" 
                                               value="${selectedFrom}">
                                    </div>
                                    <div class="col-md-3">
                                        <label for="filterTo" class="form-label">Đến ngày</label>
                                        <input type="date" class="form-control" id="filterTo" name="to" 
                                               value="${selectedTo}">
                                    </div>
                                    <div class="col-md-3">
                                        <label for="filterMovie" class="form-label">Phim</label>
                                        <select id="filterMovie" name="movieId" class="form-select">
                                            <option value="0" ${selectedMovieId == 0 ? 'selected' : ''}>Tất cả phim</option>
                                            <c:forEach var="movie" items="${filterMovies}">
                                                <option value="${movie.movieID}" ${selectedMovieId == movie.movieID ? 'selected' : ''}>
                                                    ${movie.title}
                                                </option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                    <div class="col-md-3">
                                        <label for="filterCinema" class="form-label">Rạp</label>
                                        <select id="filterCinema" name="cinemaId" class="form-select">
                                            <option value="0" ${selectedCinemaId == 0 ? 'selected' : ''}>Tất cả rạp</option>
                                             <c:forEach var="cinema" items="${filterCinemas}">
                                                <option value="${cinema.cinemaID}" ${selectedCinemaId == cinema.cinemaID ? 'selected' : ''}>
                                                    ${cinema.cinemaName}
                                                </option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                </div>
                                <button type="submit" class="btn btn-primary mb-3">
                                    <i class="fas fa-filter"></i> Lọc
                                </button>
                            </form>

                            <canvas id="revenueChart" width="100%" height="40"></canvas>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-lg-6">
                            <div class="card mb-4">
                                <div class="card-header">
                                    <i class="fas fa-trophy me-1"></i>
                                    Top 5 Phim (Theo bộ lọc)
                                </div>
                                <div class="card-body">
                                    <table class="table table-hover" id="topMoviesTable">
                                        <thead>
                                            <tr>
                                                <th>Phim</th>
                                                <th>Số vé</th>
                                                <th>Doanh thu</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="item" items="${topMovies}">
                                                <tr>
                                                    <td>${item.name}</td>
                                                    <td><fmt:formatNumber value="${item.ticketCount}" pattern="#,###" /></td>
                                                    <td><fmt:formatNumber value="${item.totalRevenue}" pattern="#,###" />₫</td>
                                                </tr>
                                            </c:forEach>
                                            <c:if test="${empty topMovies}">
                                                <tr><td colspan="3" class="text-center">Không có dữ liệu</td></tr>
                                            </c:if>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                        <div class="col-lg-6">
                            <div class="card mb-4">
                                <div class="card-header">
                                    <i class="fas fa-store me-1"></i>
                                    Top 5 Rạp (Theo bộ lọc)
                                </div>
                                <div class="card-body">
                                    <table class="table table-hover" id="topCinemasTable">
                                        <thead>
                                            <tr>
                                                <th>Rạp</th>
                                                <th>Số vé</th>
                                                <th>Doanh thu</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="item" items="${topCinemas}">
                                                <tr>
                                                    <td>${item.name}</td>
                                                    <td><fmt:formatNumber value="${item.ticketCount}" pattern="#,###" /></td>
                                                    <td><fmt:formatNumber value="${item.totalRevenue}" pattern="#,###" />₫</td>
                                                </tr>
                                            </c:forEach>
                                            <c:if test="${empty topCinemas}">
                                                <tr><td colspan="3" class="text-center">Không có dữ liệu</td></tr>
                                            </c:if>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>

                </div>
            </main>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/chart.js@3.7.1/dist/chart.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    
    <script>
        let myChart; 
        const currencyFormatter = new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' });
        function renderChart(chartData) {
            const ctx = document.getElementById('revenueChart').getContext('2d');
            if (myChart) myChart.destroy();
            
            if (!chartData || chartData.length === 0) {
                return;
            }
            
            const labels = chartData.map(d => d.date);
            const data = chartData.map(d => d.revenue);

            myChart = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: labels,
                    datasets: [{
                        label: 'Doanh thu',
                        data: data,
                        borderColor: 'rgba(229, 9, 20, 1)',
                        backgroundColor: 'rgba(229, 9, 20, 0.1)',
                        fill: true,
                        tension: 0.1
                    }]
                },
                options: {
                    scales: { y: { beginAtZero: true, ticks: { callback: value => currencyFormatter.format(value) } } },
                    plugins: { tooltip: { callbacks: { label: context => 'Doanh thu: ' + currencyFormatter.format(context.parsed.y) } } }
                }
            });
        }
        
        document.addEventListener('DOMContentLoaded', function () {
                        
            const chartDataJson = '${chartDataJson}';
            
            try {
                const chartData = JSON.parse(chartDataJson);
                renderChart(chartData); 
            } catch (e) {
                console.error("Không thể parse dữ liệu biểu đồ:", e, chartDataJson);
                renderChart([]); 
            }
        });
    </script>
</body>
</html>