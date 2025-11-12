<%-- 
    Document   : combo
    Created on : Oct 11, 2025, 11:59:38 PM
    Author     : minhd
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="entity.Combo" %>
<%@ page import="java.util.List" %>
<%@ page import="java.math.BigDecimal" %>
<%
    List<Combo> comboList = (List<Combo>) request.getAttribute("comboList");
    
    // Pagination parameters
    int currentPage = 1;
    int pageSize = 10;
    int totalItems = comboList != null ? comboList.size() : 0;
    int totalPages = (int) Math.ceil((double) totalItems / pageSize);
    
    // Get current page from request parameter
    String pageParam = request.getParameter("page");
    if (pageParam != null && !pageParam.isEmpty()) {
        try {
            currentPage = Integer.parseInt(pageParam);
            if (currentPage < 1) currentPage = 1;
            if (currentPage > totalPages) currentPage = totalPages;
        } catch (NumberFormatException e) {
            currentPage = 1;
        }
    }
    
    // Calculate start and end index for current page
    int startIndex = (currentPage - 1) * pageSize;
    int endIndex = Math.min(startIndex + pageSize, totalItems);
    
    // Get sublist for current page
    List<Combo> currentPageComboList = null;
    if (comboList != null && !comboList.isEmpty()) {
        currentPageComboList = comboList.subList(startIndex, endIndex);
    }
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Combo Management</title>
        <style>
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            }

            body {
                display: flex;
                min-height: 100vh;
                background-color: #f5f7fa;
                color: #333;
            }

            /* Sidebar Styles */
            .sidebar {
                width: 23%;
                background-color: #2c3e50;
                color: white;
                padding: 20px 0;
                display: flex;
                flex-direction: column;
                box-shadow: 2px 0 10px rgba(0, 0, 0, 0.1);
            }

            .logo {
                padding: 0 20px 20px;
                border-bottom: 1px solid #34495e;
                margin-bottom: 20px;
            }

            .logo h1 {
                font-size: 1.5rem;
                font-weight: 600;
            }

            .nav-menu {
                flex-grow: 1;
            }

            .nav-item {
                padding: 15px 20px;
                display: flex;
                align-items: center;
                cursor: pointer;
                transition: background-color 0.3s;
                text-decoration: none;
                color: white;
            }

            .nav-item:hover {
                background-color: #34495e;
            }

            .nav-item.active {
                background-color: #3498db;
            }

            .nav-item i {
                margin-right: 10px;
                font-size: 1.2rem;
            }

            .user-info {
                padding: 15px 20px;
                border-top: 1px solid #34495e;
                display: flex;
                align-items: center;
            }

            .user-avatar {
                width: 40px;
                height: 40px;
                border-radius: 50%;
                background-color: #3498db;
                display: flex;
                align-items: center;
                justify-content: center;
                margin-right: 10px;
                font-weight: bold;
            }

            /* Main Content Styles */
            .main-content {
                flex-grow: 1;
                padding: 30px;
                overflow-y: auto;
            }

            .header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 30px;
            }

            .header h2 {
                font-size: 1.8rem;
                color: #2c3e50;
            }

            .header-controls {
                display: flex;
                gap: 15px;
                align-items: center;
            }

            .btn {
                padding: 12px 20px;
                border: none;
                border-radius: 6px;
                cursor: pointer;
                font-weight: 500;
                transition: all 0.3s;
                text-decoration: none;
                display: inline-flex;
                align-items: center;
                gap: 8px;
            }

            .btn-primary {
                background-color: #3498db;
                color: white;
            }

            .btn-primary:hover {
                background-color: #2980b9;
            }

            .search-container {
                position: relative;
                width: 300px;
            }

            .search-container input {
                width: 100%;
                padding: 12px 15px 12px 40px;
                border: 1px solid #ddd;
                border-radius: 4px;
                font-size: 0.9rem;
                transition: border-color 0.3s;
            }

            .search-container input:focus {
                outline: none;
                border-color: #3498db;
            }

            .search-icon {
                position: absolute;
                left: 15px;
                top: 50%;
                transform: translateY(-50%);
                color: #7f8c8d;
            }

            /* Filter Container Styles */
            .filter-container {
                display: flex;
                gap: 15px;
                align-items: center;
            }

            .filter-group {
                position: relative;
            }

            .filter-group label {
                display: block;
                font-size: 0.8rem;
                color: #7f8c8d;
                margin-bottom: 5px;
                font-weight: 500;
            }

            .filter-group select {
                padding: 12px 15px;
                border: 1px solid #ddd;
                border-radius: 4px;
                font-size: 0.9rem;
                background-color: white;
                cursor: pointer;
                min-width: 150px;
                transition: border-color 0.3s;
            }

            .filter-group select:focus {
                outline: none;
                border-color: #3498db;
            }

            /* Table Styles */
            .table-container {
                background-color: white;
                border-radius: 8px;
                box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
                overflow: hidden;
            }

            table {
                width: 100%;
                border-collapse: collapse;
            }

            thead {
                background-color: #f8f9fa;
            }

            th {
                padding: 15px;
                text-align: left;
                font-weight: 600;
                color: #2c3e50;
                border-bottom: 1px solid #e9ecef;
            }

            td {
                padding: 15px;
                border-bottom: 1px solid #e9ecef;
            }

            tbody tr:hover {
                background-color: #f8f9fa;
            }

            .status {
                display: inline-block;
                padding: 5px 10px;
                border-radius: 20px;
                font-size: 0.8rem;
                font-weight: 500;
            }

            .status.available {
                background-color: #e8f5e9;
                color: #2e7d32;
            }

            .status.unavailable {
                background-color: #ffebee;
                color: #c62828;
            }

            .price {
                font-weight: 600;
                color: #2c3e50;
            }

            .discount-price {
                color: #e74c3c;
                font-weight: 600;
            }

            .original-price {
                text-decoration: line-through;
                color: #7f8c8d;
                font-size: 0.9rem;
            }

            .action-btn {
                background-color: #3498db;
                color: white;
                border: none;
                padding: 8px 15px;
                border-radius: 4px;
                cursor: pointer;
                font-size: 0.85rem;
                transition: background-color 0.3s;
                margin-right: 5px;
                margin-bottom: 5px;
            }

            .action-btn:hover {
                background-color: #2980b9;
            }

            .action-btn.view {
                background-color: #3498db;
            }

            .action-btn.view:hover {
                background-color: #2980b9;
            }

            .action-btn.edit {
                background-color: #f39c12;
            }

            .action-btn.edit:hover {
                background-color: #e67e22;
            }

            .action-btn.manage {
                background-color: #27ae60;
            }

            .action-btn.manage:hover {
                background-color: #219653;
            }

            .action-btn.delete {
                background-color: #e74c3c;
            }

            .action-btn.delete:hover {
                background-color: #c0392b;
            }

            /* Pagination Styles */
            .pagination-container {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-top: 20px;
                padding: 20px;
                background-color: white;
                border-radius: 8px;
                box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
            }

            .pagination-info {
                color: #6c757d;
                font-size: 0.9rem;
                font-weight: 500;
            }

            .pagination {
                display: flex;
                gap: 8px;
                align-items: center;
            }

            .page-btn {
                padding: 8px 16px;
                border: 1px solid #dee2e6;
                background-color: white;
                color: #3498db;
                cursor: pointer;
                border-radius: 6px;
                font-size: 0.9rem;
                font-weight: 500;
                transition: all 0.3s;
                min-width: 40px;
                text-align: center;
            }

            .page-btn:hover {
                background-color: #e9ecef;
                border-color: #3498db;
            }

            .page-btn.active {
                background-color: #3498db;
                color: white;
                border-color: #3498db;
            }

            .page-btn.disabled {
                color: #6c757d;
                cursor: not-allowed;
                background-color: #f8f9fa;
                border-color: #dee2e6;
            }

            .page-btn.disabled:hover {
                background-color: #f8f9fa;
                border-color: #dee2e6;
            }

            .page-dots {
                padding: 8px 5px;
                color: #6c757d;
                font-weight: 500;
            }

            /* Modal Styles */
            .modal {
                display: none;
                position: fixed;
                z-index: 1000;
                left: 0;
                top: 0;
                width: 100%;
                height: 100%;
                background-color: rgba(0,0,0,0.5);
            }

            .modal-content {
                background-color: #fefefe;
                margin: 5% auto;
                padding: 25px;
                border: 1px solid #888;
                width: 70%;
                border-radius: 8px;
                box-shadow: 0 4px 8px rgba(0,0,0,0.1);
                max-height: 80vh;
                overflow-y: auto;
            }

            .view-modal-content {
                max-width: 900px;
            }

            .close {
                color: #aaa;
                float: right;
                font-size: 28px;
                font-weight: bold;
                cursor: pointer;
            }

            .close:hover {
                color: black;
            }

            /* View Modal Specific Styles */
            .view-modal-columns {
                display: flex;
                gap: 30px;
                margin-top: 20px;
            }

            .view-column {
                flex: 1;
            }

            .view-column-left {
                flex: 1;
            }

            .view-column-right {
                flex: 1;
            }

            .view-field {
                margin-bottom: 15px;
                padding-bottom: 15px;
                border-bottom: 1px solid #eee;
            }

            .view-label {
                font-weight: 600;
                color: #2c3e50;
                margin-bottom: 5px;
                font-size: 0.9rem;
            }

            .view-value {
                color: #555;
                word-break: break-word;
            }

            .modal-actions {
                display: flex;
                gap: 10px;
                margin-top: 20px;
                justify-content: flex-end;
            }

            /* Food List Styles */
            .food-list {
                margin-top: 10px;
                max-height: 300px;
                overflow-y: auto;
                border: 1px solid #e9ecef;
                border-radius: 4px;
                padding: 10px;
                background-color: #f8f9fa;
            }

            .food-item {
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding: 10px 12px;
                margin-bottom: 8px;
                background-color: white;
                border-radius: 4px;
                border: 1px solid #dee2e6;
                transition: all 0.3s;
            }

            .food-item:hover {
                box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            }

            .food-item:last-child {
                margin-bottom: 0;
            }

            .food-info {
                flex: 1;
            }

            .food-name {
                font-weight: 500;
                color: #2c3e50;
                display: flex;
                align-items: center;
                gap: 8px;
            }

            .food-details {
                font-size: 0.8rem;
                color: #6c757d;
                margin-top: 4px;
            }

            .food-quantity {
                background-color: #3498db;
                color: white;
                padding: 6px 12px;
                border-radius: 20px;
                font-size: 0.8rem;
                font-weight: 500;
                min-width: 40px;
                text-align: center;
            }

            .no-food {
                text-align: center;
                color: #6c757d;
                font-style: italic;
                padding: 30px;
            }

            .food-type {
                display: inline-block;
                padding: 3px 8px;
                border-radius: 4px;
                font-size: 0.7rem;
                font-weight: 500;
            }

            .food-type.snack {
                background-color: #fff3e0;
                color: #ef6c00;
            }

            .food-type.drink {
                background-color: #e3f2fd;
                color: #1565c0;
            }

            .food-type.dessert {
                background-color: #f3e5f5;
                color: #7b1fa2;
            }

            .savings-badge {
                background-color: #27ae60;
                color: white;
                padding: 3px 8px;
                border-radius: 4px;
                font-size: 0.7rem;
                font-weight: 500;
                margin-left: 8px;
            }

            /* Responsive Design */
            @media (max-width: 1024px) {
                .sidebar {
                    width: 30%;
                }

                .view-modal-columns {
                    flex-direction: column;
                    gap: 20px;
                }
            }

            @media (max-width: 768px) {
                body {
                    flex-direction: column;
                }

                .sidebar {
                    width: 100%;
                    padding: 10px 0;
                }

                .nav-menu {
                    display: flex;
                    overflow-x: auto;
                }

                .nav-item {
                    flex-shrink: 0;
                }

                .user-info {
                    display: none;
                }

                .header {
                    flex-direction: column;
                    gap: 15px;
                    align-items: flex-start;
                }

                .header-controls {
                    width: 100%;
                    flex-direction: column;
                }

                .search-container {
                    width: 100%;
                }

                .filter-container {
                    width: 100%;
                    flex-direction: column;
                    align-items: flex-start;
                }

                .filter-group {
                    width: 100%;
                }

                .filter-group select {
                    width: 100%;
                }

                .action-btn {
                    display: block;
                    width: 100%;
                    margin-right: 0;
                }

                .modal-content {
                    width: 95%;
                    margin: 5% auto;
                }

                .pagination-container {
                    flex-direction: column;
                    gap: 15px;
                    align-items: stretch;
                    text-align: center;
                }

                .pagination {
                    justify-content: center;
                    flex-wrap: wrap;
                }

                .view-modal-columns {
                    flex-direction: column;
                    gap: 15px;
                }

                .food-item {
                    flex-direction: column;
                    align-items: flex-start;
                    gap: 8px;
                }

                .food-quantity {
                    align-self: flex-end;
                }
            }

            .combo-image {
                width: 60px;
                height: 60px;
                object-fit: cover;
                border-radius: 4px;
                border: 1px solid #ddd;
            }

            .combo-image-placeholder {
                width: 60px;
                height: 60px;
                background-color: #f5f5f5;
                display: flex;
                align-items: center;
                justify-content: center;
                border-radius: 4px;
                border: 1px solid #ddd;
                color: #999;
                font-size: 0.8rem;
                text-align: center;
            }

            /* Image URL Styles */
            #viewImageUrl {
                word-break: break-all;
                background-color: #f8f9fa;
                padding: 8px 12px;
                border-radius: 4px;
                border: 1px solid #e9ecef;
                font-family: 'Courier New', monospace;
                font-size: 0.85rem;
                color: #2c3e50;
                max-height: 80px;
                overflow-y: auto;
                transition: all 0.3s ease;
            }

            #viewImageUrl:hover {
                background-color: #e9ecef;
                border-color: #3498db;
            }

            /* Food List Styles */
            .food-list {
                margin-top: 10px;
                max-height: 300px;
                overflow-y: auto;
                border: 1px solid #e9ecef;
                border-radius: 4px;
                padding: 10px;
                background-color: #f8f9fa;
            }

            /* Responsive Design for Modal */
            @media (max-width: 1024px) {
                .view-modal-columns {
                    flex-direction: column;
                    gap: 20px;
                }

                .view-column-left,
                .view-column-right {
                    flex: 1;
                }
            }

            @media (max-width: 768px) {
                .view-modal-columns {
                    gap: 15px;
                }

                #viewImageUrl {
                    font-size: 0.8rem;
                    max-height: 60px;
                }
            }

            #copyNotification {
                position: fixed;
                top: 20px;
                right: 20px;
                padding: 12px 20px;
                border-radius: 6px;
                color: white;
                font-weight: 500;
                z-index: 10000;
                box-shadow: 0 4px 12px rgba(0,0,0,0.15);
                transition: all 0.3s ease;
                transform: translateX(100%);
            }

            /* Image URL Hover Effects */
            #viewImageUrl[style*="cursor: pointer"]:hover {
                background-color: #3498db !important;
                color: white !important;
                border-color: #2980b9 !important;
            }

            /* Loading States */
            .food-list .no-food {
                text-align: center;
                color: #6c757d;
                font-style: italic;
                padding: 30px;
                background-color: #f8f9fa;
                border-radius: 4px;
            }
        </style>
    </head>
    <body>
        <!-- Sidebar -->
        <div class="sidebar">
            <div class="logo">
                <h1>Admin Dashboard</h1>
            </div>
            <div class="nav-menu">
                <a href="users.jsp" class="nav-item">
                    <i>👥</i> User Management
                </a>
                <a href="food-management" class="nav-item">
                    <i>🍿</i> Food Management
                </a>
                <a href="combo-management" class="nav-item active">
                    <i>📦</i> Combo Management
                </a>
                <a href="movies.jsp" class="nav-item">
                    <i>🎬</i> Movie Management
                </a>
                <a href="reports.jsp" class="nav-item">
                    <i>📊</i> Reports
                </a>
                <a href="settings.jsp" class="nav-item">
                    <i>⚙️</i> Settings
                </a>
            </div>
            <div class="user-info">
                <div class="user-avatar">AD</div>
                <div>
                    <div>Admin User</div>
                    <div style="font-size: 0.8rem; color: #bdc3c7;">Administrator</div>
                </div>
            </div>
        </div>

        <!-- Main Content -->
        <div class="main-content">
            <div class="header">
                <h2>Combo Management</h2>
                <div class="header-controls">
                    <div class="search-container">
                        <span class="search-icon">🔍</span>
                        <input type="text" id="searchInput" placeholder="Search combos..." onkeyup="searchCombo()">
                    </div>

                    <div class="filter-container">
                        <div class="filter-group">
                            <select id="statusFilter" onchange="filterCombo()">
                                <option value="all">All Status</option>
                                <option value="available">Available</option>
                                <option value="unavailable">Unavailable</option>
                            </select>
                        </div>
                    </div>

                    <button class="btn btn-primary" onclick="openAddComboModal()">
                        <i>➕</i> Add New Combo
                    </button>
                </div>
            </div>

            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Combo Image</th> 
                            <th>Combo Name</th>
                            <th>Description</th>
                            <th>Prices</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="comboTableBody">
                        <% if (currentPageComboList != null && !currentPageComboList.isEmpty()) { 
                            for (Combo combo : currentPageComboList) { 
                                BigDecimal savings = null;
                                if (combo.getDiscountPrice() != null && combo.getTotalPrice() != null) {
                                    savings = combo.getTotalPrice().subtract(combo.getDiscountPrice());
                                }
                        %>
                        <tr data-combo-id="<%= combo.getComboID() != null ? combo.getComboID() : 0 %>">
                            <td><%= combo.getComboID() != null ? combo.getComboID() : "N/A" %></td>
                            <td>
                                <% if (combo.getComboImage() != null && !combo.getComboImage().isEmpty()) { %>
                                <img src="<%= combo.getComboImage() %>" 
                                     alt="<%= combo.getComboName() != null ? combo.getComboName() : "Combo Image" %>" 
                                     style="width: 60px; height: 60px; object-fit: cover; border-radius: 4px; border: 1px solid #ddd;">
                                <% } else { %>
                                <div style="width: 60px; height: 60px; background-color: #f5f5f5; display: flex; align-items: center; justify-content: center; border-radius: 4px; border: 1px solid #ddd; color: #999;">
                                    No Image
                                </div>
                                <% } %>
                            </td>
                            <td><%= combo.getComboName() != null ? combo.getComboName() : "N/A" %></td>
                            <td><%= combo.getDescription() != null ? combo.getDescription() : "N/A" %></td>
                            <td>
                                <% if (combo.getDiscountPrice() != null) { %>
                                <div class="discount-price"><%= formatPrice(combo.getDiscountPrice()) %></div>
                                <div class="original-price"><%= formatPrice(combo.getTotalPrice()) %></div>
                                <% if (savings != null && savings.compareTo(BigDecimal.ZERO) > 0) { %>
                                <div style="font-size: 0.8rem; color: #27ae60;">
                                    Save <%= formatPrice(savings) %>
                                </div>
                                <% } %>
                                <% } else { %>
                                <div class="price"><%= formatPrice(combo.getTotalPrice()) %></div>
                                <% } %>
                            </td>
                            <td>
                                <span class="status <%= combo.getIsAvailable() != null && combo.getIsAvailable() ? "available" : "unavailable" %>">
                                    <%= combo.getIsAvailable() != null && combo.getIsAvailable() ? "Available" : "Unavailable" %>
                                </span>
                            </td>
                            <td>
                                <button class="action-btn view" onclick="viewCombo(<%= combo.getComboID() != null ? combo.getComboID() : 0 %>)">
                                    View
                                </button>
                                <button class="action-btn manage" onclick="manageComboFood(<%= combo.getComboID() != null ? combo.getComboID() : 0 %>)">
                                    Manage Food
                                </button>
                                <button class="action-btn delete" onclick="deleteCombo(<%= combo.getComboID() != null ? combo.getComboID() : 0 %>)">
                                    Delete
                                </button>
                            </td>
                        </tr>
                        <% } 
    } else { %>
                        <tr>
                            <td colspan="7" style="text-align: center; padding: 40px;">
                                <div style="color: #7f8c8d; font-size: 1.1rem;">
                                    <% if (comboList != null && !comboList.isEmpty()) { %>
                                    No combos found on this page.
                                    <% } else { %>
                                    No combos found.
                                    <% } %>
                                </div>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>

            <!-- Pagination Controls -->
            <% if (totalPages > 0) { %>
            <div class="pagination-container">
                <div class="pagination-info">
                    Showing <%= startIndex + 1 %> to <%= endIndex %> of <%= totalItems %> entries
                </div>
                <div class="pagination">
                    <%-- Previous button --%>
                    <% if (currentPage > 1) { %>
                    <button class="page-btn" onclick="goToPage(<%= currentPage - 1 %>)">
                        ‹
                    </button>
                    <% } else { %>
                    <button class="page-btn disabled">‹</button>
                    <% } %>

                    <%-- Page numbers --%>
                    <% 
                        int startPage = Math.max(1, currentPage - 1);
                        int endPage = Math.min(totalPages, currentPage + 1);
                    
                        // Always show first page
                        if (startPage > 1) { 
                    %>
                    <button class="page-btn <%= 1 == currentPage ? "active" : "" %>" onclick="goToPage(1)">1</button>
                    <% if (startPage > 2) { %>
                    <span class="page-dots">...</span>
                    <% } %>
                    <% } %>

                    <% for (int i = startPage; i <= endPage; i++) { %>
                    <button class="page-btn <%= i == currentPage ? "active" : "" %>" onclick="goToPage(<%= i %>)"><%= i %></button>
                    <% } %>

                    <%-- Always show last page if needed --%>
                    <% if (endPage < totalPages) { %>
                    <% if (endPage < totalPages - 1) { %>
                    <span class="page-dots">...</span>
                    <% } %>
                    <button class="page-btn <%= totalPages == currentPage ? "active" : "" %>" onclick="goToPage(<%= totalPages %>)"><%= totalPages %></button>
                    <% } %>

                    <%-- Next button --%>
                    <% if (currentPage < totalPages) { %>
                    <button class="page-btn" onclick="goToPage(<%= currentPage + 1 %>)">›</button>
                    <% } else { %>
                    <button class="page-btn disabled">›</button>
                    <% } %>
                </div>
            </div>
            <% } %>
        </div>

        <!-- Modal View Combo -->
        <div id="viewComboModal" class="modal">
            <div class="modal-content view-modal-content">
                <span class="close" onclick="closeViewComboModal()">&times;</span>
                <h3 style="margin-bottom: 20px; color: #2c3e50;">Combo Details</h3>

                <div class="view-modal-columns">
                    <!-- Column 1: Combo Information -->
                    <div class="view-column view-column-left">
                        <div class="view-field">
                            <div class="view-label">Combo ID</div>
                            <div class="view-value" id="viewComboId">N/A</div>
                        </div>

                        <div class="view-field">
                            <div class="view-label">Combo Name</div>
                            <div class="view-value" id="viewComboName">N/A</div>
                        </div>

                        <div class="view-field">
                            <div class="view-label">Description</div>
                            <div class="view-value" id="viewDescription">N/A</div>
                        </div>

                        <div class="view-field">
                            <div class="view-label">Total Price</div>
                            <div class="view-value" id="viewTotalPrice">N/A</div>
                        </div>

                        <div class="view-field">
                            <div class="view-label">Discount Price</div>
                            <div class="view-value" id="viewDiscountPrice">N/A</div>
                        </div>

                        <div class="view-field">
                            <div class="view-label">Savings</div>
                            <div class="view-value" id="viewSavings">N/A</div>
                        </div>

                        <div class="view-field">
                            <div class="view-label">Status</div>
                            <div class="view-value" id="viewStatus">N/A</div>
                        </div>

                        <div class="view-field">
                            <div class="view-label">Image URL</div>
                            <div class="view-value">
                                <div id="viewImageUrl" style="word-break: break-all; background-color: #f8f9fa; padding: 8px 12px; border-radius: 4px; border: 1px solid #e9ecef; font-family: monospace; font-size: 0.85rem;">
                                    No image URL available
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Column 2: Food Items -->
                    <div class="view-column view-column-right">
                        <div class="view-field">
                            <div class="view-label">Food Items in Combo</div>
                            <div class="view-value">
                                <div class="food-list" id="viewFoodList">
                                    <div class="no-food">Loading food items...</div>
                                </div>
                            </div>
                        </div>

                        <div class="view-field">
                            <div class="view-label">Total Food Items</div>
                            <div class="view-value" id="viewTotalFoodItems">0 items</div>
                        </div>
                    </div>
                </div>

                <div class="modal-actions">
                    <button type="button" class="btn btn-primary" id="editComboBtn">Edit</button>
                    <button type="button" class="btn" onclick="closeViewComboModal()" 
                            style="background-color: #95a5a6; color: white;">Cancel</button>
                </div>
            </div>
        </div>

        <script>
            // Check for success/error messages from URL parameters
            window.addEventListener('DOMContentLoaded', function () {
                const urlParams = new URLSearchParams(window.location.search);
                const success = urlParams.get('success');
                const error = urlParams.get('error');

                if (success) {
                    alert('Operation successful: ' + success);
                    window.history.replaceState({}, document.title, window.location.pathname);
                }

                if (error) {
                    alert('Operation failed: ' + error);
                    window.history.replaceState({}, document.title, window.location.pathname);
                }

                // Setup event listener for edit button
                document.getElementById('editComboBtn').addEventListener('click', function () {
                    if (currentComboId !== 0) {
                        window.location.href = 'combo-management?action=getById&id=' + currentComboId;
                    } else {
                        alert('No combo selected');
                    }
                });
            });

            // Global variable to store current combo ID
            let currentComboId = 0;

            // Pagination function
            function goToPage(page) {
                const urlParams = new URLSearchParams(window.location.search);
                urlParams.set('page', page);
                window.location.href = window.location.pathname + '?' + urlParams.toString();
            }

            // Modal functions
            function openAddComboModal() {
                window.location.href = 'combo-management?action=showAddForm';
            }

            // View Combo Modal functions
            function viewCombo(comboId) {
                if (comboId === 0) {
                    alert('Invalid combo ID');
                    return;
                }

                currentComboId = comboId;

                const allRows = document.querySelectorAll('#comboTableBody tr');
                let targetRow = null;

                for (let row of allRows) {
                    const rowComboId = row.getAttribute('data-combo-id');
                    if (rowComboId && parseInt(rowComboId) === comboId) {
                        targetRow = row;
                        break;
                    }
                }

                if (!targetRow) {
                    alert('Combo not found in table. ComboId: ' + comboId);
                    return;
                }

                const cells = targetRow.cells;

                const comboData = {
                    id: cells[0].textContent,
                    name: cells[2].textContent,
                    description: cells[3].textContent,
                    prices: cells[4].innerHTML,
                    status: cells[5].querySelector('.status').textContent
                };

                // Extract image information
                const imageCell = cells[1];
                let imageUrl = '';
                const imgElement = imageCell.querySelector('img');
                if (imgElement) {
                    imageUrl = imgElement.src;
                }

                // Extract price information
                const discountPriceElement = cells[4].querySelector('.discount-price');
                const originalPriceElement = cells[4].querySelector('.original-price');
                const priceElement = cells[4].querySelector('.price');
                const savingsElement = cells[4].querySelector('div[style*="color: #27ae60"]');

                let totalPrice = 'N/A';
                let discountPrice = 'N/A';
                let savings = 'N/A';

                if (discountPriceElement && originalPriceElement) {
                    // Has discount
                    totalPrice = originalPriceElement.textContent.trim();
                    discountPrice = discountPriceElement.textContent.trim();

                    // Calculate savings
                    const totalPriceNum = parseFloat(totalPrice.replace(/[^0-9.]/g, ''));
                    const discountPriceNum = parseFloat(discountPrice.replace(/[^0-9.]/g, ''));
                    if (!isNaN(totalPriceNum) && !isNaN(discountPriceNum)) {
                        const savingsNum = totalPriceNum - discountPriceNum;
                        savings = formatPriceDisplay(savingsNum);
                    } else if (savingsElement) {
                        savings = savingsElement.textContent.replace('Save', '').trim();
                    }
                } else if (priceElement) {
                    // No discount
                    totalPrice = priceElement.textContent.trim();
                    discountPrice = 'No discount';
                    savings = 'No savings';
                }

                // Update modal content - Basic Information
                document.getElementById('viewComboId').textContent = comboData.id;
                document.getElementById('viewComboName').textContent = comboData.name;
                document.getElementById('viewDescription').textContent = comboData.description;
                document.getElementById('viewTotalPrice').textContent = totalPrice;
                document.getElementById('viewDiscountPrice').textContent = discountPrice;
                document.getElementById('viewSavings').textContent = savings;
                document.getElementById('viewStatus').textContent = comboData.status;

                // Update image URL
                const imageUrlElement = document.getElementById('viewImageUrl');

                if (imageUrl && imageUrl !== '') {
                    imageUrlElement.textContent = imageUrl;
                    imageUrlElement.style.color = '#2c3e50';
                    imageUrlElement.style.cursor = 'pointer';

                    // Thêm tooltip và click để copy URL
                    imageUrlElement.title = 'Click to copy URL';
                    imageUrlElement.onclick = function () {
                        copyToClipboard(imageUrl);
                    };
                } else {
                    imageUrlElement.textContent = 'No image URL available';
                    imageUrlElement.style.color = '#999';
                    imageUrlElement.style.cursor = 'default';
                    imageUrlElement.onclick = null;
                    imageUrlElement.title = '';
                }

                console.log('Modal content updated:', {
                    id: comboData.id,
                    name: comboData.name,
                    description: comboData.description,
                    totalPrice: totalPrice,
                    discountPrice: discountPrice,
                    savings: savings,
                    status: comboData.status,
                    imageUrl: imageUrl
                });

                // Reset food list trước khi load mới
                const foodListContainer = document.getElementById('viewFoodList');
                const totalItemsElement = document.getElementById('viewTotalFoodItems');
                foodListContainer.innerHTML = '<div class="no-food">Loading food items...</div>';
                totalItemsElement.textContent = 'Loading...';

                // Load food items for this combo
                loadComboFoodItems(comboId);

                // Hiển thị modal
                document.getElementById('viewComboModal').style.display = 'block';
                console.log('Modal displayed for combo ID:', comboId);
            }

            function closeViewComboModal() {
                document.getElementById('viewComboModal').style.display = 'none';
                currentComboId = 0;
            }

            // Load Combo Food Items
            function loadComboFoodItems(comboId) {
                console.log('Loading food items for combo:', comboId);

                const foodListContainer = document.getElementById('viewFoodList');
                foodListContainer.innerHTML = '<div class="no-food">Loading food items...</div>';

                fetch('combo-management?action=getComboFoods&comboId=' + comboId)
                        .then(response => {
                            console.log('Response status:', response.status);
                            if (!response.ok) {
                                throw new Error('Network response was not ok: ' + response.statusText);
                            }
                            return response.text();
                        })
                        .then(text => {
                            console.log('Raw response text:', text);
                            try {
                                const foodItems = JSON.parse(text);
                                console.log('Parsed food items:', foodItems);
                                displayFoodItems(foodItems);
                            } catch (e) {
                                console.error('Error parsing JSON:', e);
                                console.error('Raw text that failed to parse:', text);
                                displayFoodItems([]);
                            }
                        })
                        .catch(error => {
                            console.error('Error loading food items:', error);
                            foodListContainer.innerHTML = '<div class="no-food">Error loading food items: ' + error.message + '</div>';
                        });
            }

            // Display Food Items
            function displayFoodItems(foodItems) {
                const foodListContainer = document.getElementById('viewFoodList');
                const totalItemsElement = document.getElementById('viewTotalFoodItems');

                console.log('Displaying food items:', foodItems);

                if (!foodItems || foodItems.length === 0) {
                    foodListContainer.innerHTML = '<div class="no-food">No food items in this combo</div>';
                    totalItemsElement.textContent = '0 items';
                    return;
                }

                let foodListHTML = '';
                let totalQuantity = 0;
                let uniqueItems = foodItems.length;

                foodItems.forEach((food, index) => {
                    console.log(`Processing food item ${index}:`, food);

                    // Đảm bảo các biến có giá trị
                    const foodName = String(food.foodName || 'Unknown Food');
                    const foodType = String(food.foodType || 'Unknown');
                    const description = String(food.description || 'No description available');
                    const quantity = Number(food.quantity) || 1;

                    const foodTypeClass = foodType.toLowerCase().replace(/\s+/g, '-');
                    totalQuantity += quantity;

                    // Format price
                    let priceDisplay = 'N/A';
                    try {
                        if (food.price !== null && food.price !== undefined) {
                            let priceValue;
                            if (typeof food.price === 'number') {
                                priceValue = food.price;
                            } else if (typeof food.price === 'string') {
                                priceValue = parseFloat(food.price);
                            } else {
                                priceValue = parseFloat(food.price);
                            }

                            if (!isNaN(priceValue)) {
                                priceDisplay = priceValue.toLocaleString('vi-VN') + ' VND';
                            }
                        }
                    } catch (e) {
                        console.error('Error formatting price:', e);
                    }

                    // Tạo HTML cho food item
                    foodListHTML +=
                            '<div class="food-item">' +
                            '<div class="food-info">' +
                            '<div class="food-name">' +
                            escapeHtml(foodName) +
                            '<span class="food-type ' + foodTypeClass + '">' +
                            escapeHtml(foodType) +
                            '</span>' +
                            '</div>' +
                            '<div class="food-details">' +
                            escapeHtml(description) + ' | ' + escapeHtml(priceDisplay) +
                            '</div>' +
                            '</div>' +
                            '<div class="food-quantity" title="Quantity">' +
                            quantity +
                            '</div>' +
                            '</div>';
                });

                console.log('Final food list HTML:', foodListHTML);
                foodListContainer.innerHTML = foodListHTML;
                totalItemsElement.textContent = uniqueItems + ' items (' + totalQuantity + ' total pieces)';

                // Kiểm tra xem HTML có được chèn đúng không
                console.log('Food list container innerHTML:', foodListContainer.innerHTML);
            }

            // Helper function to escape HTML
            function escapeHtml(text) {
                if (text === null || text === undefined) {
                    return '';
                }
                const div = document.createElement('div');
                div.textContent = text;
                return div.innerHTML;
            }

            // Helper function to format price
            function formatPriceDisplay(price) {
                if (typeof price === 'number') {
                    return price.toLocaleString('vi-VN') + ' VND';
                } else if (typeof price === 'string') {
                    // If it's already formatted, return as is
                    if (price.includes('VND')) {
                        return price;
                    }
                    // Try to parse and format
                    const num = parseFloat(price.replace(/[^0-9.]/g, ''));
                    if (!isNaN(num)) {
                        return num.toLocaleString('vi-VN') + ' VND';
                    }
                }
                return 'N/A';
            }

            // Copy to clipboard function
            function copyToClipboard(text) {
                navigator.clipboard.writeText(text).then(function () {
                    showNotification('URL copied to clipboard!', '#27ae60');
                }, function (err) {
                    console.error('Could not copy text: ', err);
                    showNotification('Failed to copy URL', '#e74c3c');
                });
            }

            // Show notification function
            function showNotification(message, color) {
                const notification = document.createElement('div');
                notification.id = 'copyNotification';
                notification.textContent = message;
                notification.style.backgroundColor = color;
                notification.style.transform = 'translateX(0)';

                document.body.appendChild(notification);

                setTimeout(function () {
                    notification.style.transform = 'translateX(100%)';
                    setTimeout(function () {
                        if (notification.parentNode) {
                            notification.parentNode.removeChild(notification);
                        }
                    }, 300);
                }, 2000);
            }

            // Close modal when clicking outside
            window.onclick = function (event) {
                const viewModal = document.getElementById('viewComboModal');
                if (event.target === viewModal) {
                    closeViewComboModal();
                }
            }

            // Search functionality
            function searchCombo() {
                applyFilters();
            }

            // Filter functionality
            function filterCombo() {
                applyFilters();
            }

            // Combined search and filter function
            function applyFilters() {
                const searchInput = document.getElementById('searchInput');
                const statusFilter = document.getElementById('statusFilter');

                const searchTerm = searchInput.value.toLowerCase();
                const statusValue = statusFilter.value;

                const rows = document.querySelectorAll('#comboTableBody tr');

                rows.forEach(row => {
                    if (row.cells.length < 6)
                        return;

                    const comboName = row.cells[2].textContent.toLowerCase();
                    const description = row.cells[3].textContent.toLowerCase();
                    const status = row.cells[5].textContent.toLowerCase();

                    const matchesSearch = searchTerm === '' ||
                            comboName.includes(searchTerm) ||
                            description.includes(searchTerm);

                    let matchesStatus = true;
                    if (statusValue !== 'all') {
                        matchesStatus = status.includes(statusValue.toLowerCase());
                    }

                    row.style.display = (matchesSearch && matchesStatus) ? '' : 'none';
                });
            }

            function editCombo(comboId) {
                if (comboId === 0) {
                    alert('Invalid combo ID');
                    return;
                }
                window.location.href = 'combo-management?action=getById&id=' + comboId;
            }

            function manageComboFood(comboId) {
                if (comboId === 0) {
                    alert('Invalid combo ID');
                    return;
                }
                console.log('Managing combo food for ID:', comboId);
                window.location.href = 'combo-food-management?action=view&comboId=' + comboId;
            }

            function deleteCombo(comboId) {
                if (comboId === 0) {
                    alert('Invalid combo ID');
                    return;
                }

                if (confirm('Are you sure you want to delete this combo? This will also remove all food items from the combo.')) {
                    fetch('combo-management?action=delete&comboID=' + comboId, {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/x-www-form-urlencoded',
                        }
                    })
                            .then(response => {
                                if (response.ok) {
                                    location.reload();
                                } else {
                                    response.text().then(text => {
                                        alert('Error deleting combo: ' + text);
                                    });
                                }
                            })
                            .catch(error => {
                                console.error('Error:', error);
                                alert('Error deleting combo: ' + error.message);
                            });
                }
            }
        </script>
    </body>
</html>

<%!
    private String formatPrice(BigDecimal price) {
        if (price == null) return "N/A";
        try {
            return String.format("%,d VND", price.intValue());
        } catch (Exception e) {
            return "N/A";
        }
    }
%>