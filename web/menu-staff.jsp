<%@page contentType="text/html" pageEncoding="UTF-8"%>
<div id="layoutSidenav_nav">
    <nav class="sb-sidenav accordion sb-sidenav-dark" id="sidenavAccordion">
        <div class="sb-sidenav-menu">
            <div class="nav">
                
                <div class="sb-sidenav-menu-heading">Tác Vụ (Staff)</div>

                <li class="nav-item">
                    <a class="nav-link ${activePage == 'manager-dashboard' ? 'active' : ''}" href="${pageContext.request.contextPath}/manager">
                        <div class="sb-nav-link-icon"><i class="fas fa-tachometer-alt"></i></div>
                        Trang chủ (Dashboard)
                    </a>
                </li>

                <li class="nav-item">
                    <a class="nav-link ${activePage == 'staff-check-in' ? 'active' : ''}" href="${pageContext.request.contextPath}/staff-check-in">
                        <div class="sb-nav-link-icon"><i class="fas fa-qrcode"></i></div>
                        Quản lý vé
                    </a>
                </li>
                
                <li class="nav-item">
                    <a class="nav-link ${activePage == 'list-refunds' ? 'active' : ''}" href="${pageContext.request.contextPath}/list-refunds">
                        <div class="sb-nav-link-icon"><i class="fas fa-hand-holding-usd"></i></div>
                        Quản lý huỷ vé
                    </a>
                </li>

                <li class="nav-item"> 
                    <a class="nav-link ${activePage == 'support-tickets' ? 'active' : ''}" href="${pageContext.request.contextPath}/staff-support">
                        <div class="sb-nav-link-icon"><i class="fas fa-headset"></i></div>
                        Hỗ trợ khách hàng
                    </a>
                </li>
                
                <div class="sb-sidenav-menu-heading">Tài Khoản</div>
                
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/logout">
                        <div class="sb-nav-link-icon"><i class="fas fa-sign-out-alt"></i></div>
                        Đăng xuất
                    </a>
                </li>
                
            </div>
        </div>
        <div class="sb-sidenav-footer">
            <div class="small">Logged in as:</div>
            Staff (${sessionScope.userName})
        </div>
    </nav>
</div>