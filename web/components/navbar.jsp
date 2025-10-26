<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Get user information from session
    String userName = (String) session.getAttribute("userName");
    Object userObj = session.getAttribute("user");
    
    // Check if user is logged in by checking if user object exists in session
    boolean isLoggedIn = (userObj != null) || (userName != null);
%>

<style>
    /* Navbar Styling */
    .navbar {
        background: linear-gradient(135deg, #334457 0%, #4a5a6b 50%, #2a3744 100%);
        padding: 15px 0;
        box-shadow: 0 2px 10px rgba(0,0,0,0.3);
    }
    
    .navbar-brand {
        color: #f7efe7 !important;
        font-weight: 700;
        font-size: 1.5rem;
        transition: all 0.3s ease;
    }
    
    .navbar-brand:hover {
        color: #5cbe8f !important;
        transform: translateX(5px);
    }
    
    .navbar-brand i {
        color: #5cbe8f;
        margin-right: 8px;
    }
    
    .navbar-text {
        color: #f7efe7 !important;
        font-weight: 500;
        font-size: 1rem;
        display: flex;
        align-items: center;
        margin-right: 20px !important;
    }
    
    .navbar-nav {
        display: flex;
        align-items: center;
    }
    
    .logout-btn {
        background: linear-gradient(135deg, #e74c3c 0%, #c0392b 100%);
        border: 2px solid #e74c3c;
        border-radius: 12px;
        padding: 10px 20px;
        color: white;
        font-weight: 600;
        transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
        box-shadow: 0 0 0;
        text-decoration: none;
        display: inline-block;
    }
    
    .logout-btn:hover {
        background: linear-gradient(135deg, #c0392b 0%, #a93226 100%);
        transform: translateY(-2px) scale(1.02);
        box-shadow: 0 6px 20px rgba(231, 76, 60, 0.4);
        color: white;
        text-decoration: none;
    }
    
    .nav-link {
        color: #f7efe7 !important;
        font-weight: 500;
        margin: 0 10px;
        transition: all 0.3s ease;
    }
    
    .nav-link:hover {
        color: #5cbe8f !important;
    }
</style>

<nav class="navbar navbar-expand-lg navbar-light">
    <div class="container">
        <a class="navbar-brand" href="${pageContext.request.contextPath}/index.jsp">
            <i class="fas fa-film"></i> Cinema Management
        </a>
        
        <% if (isLoggedIn) { %>
            <!-- Logged-in Navigation -->
            <div class="navbar-nav ms-auto">
                <a href="${pageContext.request.contextPath}/booking/select-screening" class="nav-link">
                    <i class="fas fa-ticket-alt"></i> Đặt Vé
                </a>
                <a href="${pageContext.request.contextPath}/profile" class="nav-link">
                    <i class="fas fa-user"></i> Hồ Sơ
                </a>
                <span class="navbar-text">
                    Welcome, <%= userName != null ? userName : "Customer" %>!
                </span>
                <a href="${pageContext.request.contextPath}/logout" class="logout-btn">
                    <i class="fas fa-sign-out-alt"></i> Logout
                </a>
            </div>
        <% } else { %>
            <!-- Guest Navigation -->
            <div class="navbar-nav ms-auto">
                <a href="${pageContext.request.contextPath}/login.jsp" class="nav-link">
                    <i class="fas fa-user-circle"></i> Account
                </a>
                <a href="${pageContext.request.contextPath}/login.jsp" class="logout-btn" style="margin-left: 15px;">
                    <i class="fas fa-sign-in-alt"></i> Login
                </a>
            </div>
        <% } %>
    </div>
</nav>

