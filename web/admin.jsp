<%-- 
    Document   : admin
    Created on : 29 thg 9, 2025, 19:15:08
    Author     : admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Admin Dashboard</title>
    <style>
        body {
            font-family: "Segoe UI", Arial, sans-serif;
            background-color: #f4f6f9;
            margin: 0;
            padding: 0;
            color: #333;
        }

        /* Header */
        .header {
            background-color: #2c3e50;
            color: white;
            padding: 15px 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 2px 6px rgba(0,0,0,0.15);
        }

        .header h1 {
            margin: 0;
            font-size: 24px;
        }

        .logout-btn {
            background: #e74c3c;
            border: none;
            padding: 8px 16px;
            color: white;
            border-radius: 20px;
            cursor: pointer;
            font-size: 14px;
            transition: background 0.3s;
        }

        .logout-btn:hover {
            background: #c0392b;
        }

        /* Container */
        .container {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 20px;
            padding: 40px;
        }

        /* Card */
        .card {
            background-color: white;
            padding: 30px 20px;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            text-align: center;
            transition: transform 0.2s, box-shadow 0.2s;
        }

        .card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 18px rgba(0,0,0,0.2);
        }

        .card a {
            text-decoration: none;
            color: #2c3e50;
            font-weight: bold;
            font-size: 18px;
            display: block;
        }
    </style>
</head>
<body>

<div class="header">
    <h1>Admin Dashboard</h1>
    <form action="${pageContext.request.contextPath}/auth/logout" method="post">
        <button type="submit" class="logout-btn">Logout</button>
    </form>
</div>

<div class="container">
    <div class="card">
        <a href="accountManager.jsp">Manage Account</a>
    </div>
    <div class="card">
        <a href="list">Manage Film</a>
    </div>
    <div class="card">
        <a href="cinemaManager.jsp">Manage Cinema</a>
    </div>
    <div class="card">
        <a href="roomManager.jsp">Manage Room</a>
    </div>
    <div class="card">
        <a href="promotionManager.jsp">Manage Promotion</a>
    </div>
    <div class="card">
        <a href="revenueManager.jsp">Manage Revenue</a>
    </div>
</div>

</body>
</html>