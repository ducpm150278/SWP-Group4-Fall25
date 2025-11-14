<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Trang Quản Lý (Staff)</title>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
        <style>
            .quick-access-card {
                display: block; padding: 2rem; border-radius: 0.5rem;
                background-color: #f8f9fa; border: 1px solid #dee2e6;
                color: #212529; text-decoration: none;
                transition: all 0.3s ease; height: 100%;
            }
            .quick-access-card:hover {
                background-color: #e9ecef; border-color: #0d6efd;
                transform: translateY(-5px); box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            }
            .quick-access-card .icon { font-size: 2.5rem; color: #0d6efd; margin-bottom: 1rem; }
            .quick-access-card h4 { font-size: 1.25rem; font-weight: 600; margin-bottom: 0.5rem; }
            .quick-access-card p { font-size: 0.9rem; color: #495057; }
        </style>
    </head>
    <body class="sb-nav-fixed">
        <nav class="sb-topnav navbar navbar-expand navbar-dark bg-dark">
            <%@ include file="view/admin/header.jsp" %>
        </nav>

        <div id="layoutSidenav">
            <%@ include file="menu-staff.jsp" %>
            <div id="layoutSidenav_content">
                <main class="p-4">
                    <div class="container-fluid">
                        <h2 class="mb-4">👋 Chào mừng, ${sessionScope.userName}!</h2>
                        <p class="text-muted mb-4">Đây là trang điều khiển dành cho Nhân viên. Chọn một tác vụ để bắt đầu.</p>
                        
                        <hr class="my-4">
                        
                        <h4 class="mb-3">Lối Tắt Nhanh (Chức Năng Staff)</h4>
                        
                        <div class="row g-4">
                            <div class="col-lg-4 col-md-6">
                                <a href="${pageContext.request.contextPath}/staff-check-in" class="quick-access-card">
                                    <div class="icon"><i class="fas fa-qrcode"></i></div>
                                    <h4>Quản lý Vé / Check-in</h4>
                                    <p>Tìm và check-in vé (đã thanh toán hoặc thu tiền tại quầy).</p>
                                </a>
                            </div>
                            
                            <div class="col-lg-4 col-md-6">
                                <a href="${pageContext.request.contextPath}/list-refunds" class="quick-access-card">
                                    <div class="icon"><i class="fas fa-hand-holding-usd"></i></div>
                                    <h4>Quản lý Hoàn tiền</h4>
                                    <p>Duyệt hoặc từ chối các yêu cầu hủy vé/hoàn tiền của khách.</p>
                                </a>
                            </div>
                            
                            <div class="col-lg-4 col-md-6">
                                <a href="${pageContext.request.contextPath}/staff-support" class="quick-access-card">
                                    <div class="icon"><i class="fas fa-headset"></i></div>
                                    <h4>Hỗ trợ Khách hàng</h4>
                                    <p>Xem và phản hồi các ticket hỗ trợ từ khách hàng.</p>
                                </a>
                            </div>
                            
                        </div>
                        
                    </div>
                </main>
            </div>
        </div>
        
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>