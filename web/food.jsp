<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="entity.Food" %>
<%@ page import="java.util.List" %>
<%@ page import="java.math.BigDecimal" %>
<%
    // This would typically come from your servlet
    List<Food> foodList = (List<Food>) request.getAttribute("foodList");
    
    // Pagination parameters
    int currentPage = 1;
    int pageSize = 10;
    int totalItems = foodList != null ? foodList.size() : 0;
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
    List<Food> currentPageFoodList = null;
    if (foodList != null && !foodList.isEmpty()) {
        currentPageFoodList = foodList.subList(startIndex, endIndex);
    }
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Food Management</title>
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
                position: relative;
            }

            .filter-container select {
                padding: 12px 15px;
                border: 1px solid #ddd;
                border-radius: 4px;
                font-size: 0.9rem;
                background-color: white;
                cursor: pointer;
                min-width: 200px;
                transition: border-color 0.3s;
            }

            .filter-container select:focus {
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

            .food-type {
                display: inline-block;
                padding: 5px 10px;
                border-radius: 4px;
                font-size: 0.8rem;
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

            .food-type.combo {
                background-color: #e8f5e9;
                color: #2e7d32;
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

            .action-btn.delete {
                background-color: #e74c3c;
            }

            .action-btn.delete:hover {
                background-color: #c0392b;
            }

            .price {
                font-weight: 600;
                color: #2c3e50;
            }

            .food-image {
                width: 50px;
                height: 50px;
                object-fit: cover;
                border-radius: 4px;
                border: 1px solid #ddd;
            }

            .food-image-placeholder {
                width: 50px;
                height: 50px;
                background-color: #f8f9fa;
                border: 1px dashed #ddd;
                border-radius: 4px;
                display: flex;
                align-items: center;
                justify-content: center;
                color: #6c757d;
                font-size: 0.7rem;
                text-align: center;
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
                width: 50%;
                border-radius: 8px;
                box-shadow: 0 4px 8px rgba(0,0,0,0.1);
                max-height: 80vh;
                overflow-y: auto;
            }

            .view-modal-content {
                max-width: 600px;
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

            .modal input, .modal select, .modal textarea {
                width: 100%;
                padding: 10px;
                margin: 8px 0;
                border: 1px solid #ddd;
                border-radius: 4px;
                font-size: 14px;
                box-sizing: border-box;
            }

            .modal label {
                font-weight: 500;
                color: #2c3e50;
                display: block;
                margin-bottom: 5px;
            }

            .form-group {
                margin-bottom: 15px;
            }

            /* View Modal Specific Styles */
            .view-field {
                margin-bottom: 15px;
                padding-bottom: 15px;
                border-bottom: 1px solid #eee;
            }

            .view-label {
                font-weight: 600;
                color: #2c3e50;
                margin-bottom: 5px;
            }

            .view-value {
                color: #555;
            }

            .modal-actions {
                display: flex;
                gap: 10px;
                margin-top: 20px;
                justify-content: flex-end;
            }

            /* Pagination Styles - Updated to match image */
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

            /* Responsive Design */
            @media (max-width: 1024px) {
                .sidebar {
                    width: 30%;
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
                }

                .filter-container select {
                    width: 100%;
                }

                .modal-content {
                    width: 90%;
                    margin: 10% auto;
                }

                .food-image, .food-image-placeholder {
                    width: 40px;
                    height: 40px;
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
                <a href="food-management" class="nav-item active">
                    <i>🍿</i> Food Management
                </a>
                <a href="combo-management" class="nav-item">
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
                <h2>Food Management</h2>
                <div class="header-controls">
                    <div class="search-container">
                        <span class="search-icon">🔍</span>
                        <input type="text" id="searchInput" placeholder="Search food items..." onkeyup="searchFood()">
                    </div>

                    <div class="filter-container">
                        <select id="filterSelect" onchange="filterFood()">
                            <option value="all">All Categories & Status</option>
                            <option value="category:Snack">Category: Snack</option>
                            <option value="category:Drink">Category: Drink</option>
                            <option value="category:Dessert">Category: Dessert</option>
                            <option value="status:available">Status: Available</option>
                            <option value="status:unavailable">Status: Unavailable</option>
                        </select>
                    </div>

                    <button class="btn btn-primary" onclick="openAddFoodModal()">
                        <i>➕</i> Add New Food
                    </button>
                </div>
            </div>

            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Image</th>
                            <th>Food Name</th>
                            <th>Description</th>
                            <th>Type</th>
                            <th>Price</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="foodTableBody">
                        <% if (currentPageFoodList != null && !currentPageFoodList.isEmpty()) { 
                            for (Food food : currentPageFoodList) { 
                                String foodTypeClass = food.getFoodType() != null ? food.getFoodType().toLowerCase() : "snack";
                                String imageUrl = food.getImageURL() != null && !food.getImageURL().isEmpty() ? food.getImageURL() : null;
                        %>
                        <tr data-food-id="<%= food.getFoodID() != null ? food.getFoodID() : 0 %>">
                            <td><%= food.getFoodID() != null ? food.getFoodID() : "N/A" %></td>
                            <td>
                                <% if (imageUrl != null) { %>
                                <img src="<%= imageUrl %>" alt="<%= food.getFoodName() %>" class="food-image" 
                                     onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
                                <div class="food-image-placeholder" style="display: none;">No Image</div>
                                <% } else { %>
                                <div class="food-image-placeholder">No Image</div>
                                <% } %>
                            </td>
                            <td><%= food.getFoodName() != null ? food.getFoodName() : "N/A" %></td>
                            <td><%= food.getDescription() != null ? food.getDescription() : "N/A" %></td>
                            <td>
                                <span class="food-type <%= foodTypeClass %>">
                                    <%= food.getFoodType() != null ? food.getFoodType() : "N/A" %>
                                </span>
                            </td>
                            <td class="price"><%= formatPrice(food.getPrice()) %></td>
                            <td>
                                <span class="status <%= food.getIsAvailable() != null && food.getIsAvailable() ? "available" : "unavailable" %>">
                                    <%= food.getIsAvailable() != null && food.getIsAvailable() ? "Available" : "Unavailable" %>
                                </span>
                            </td>
                            <td>
                                <button class="action-btn view" onclick="viewFood(<%= food.getFoodID() != null ? food.getFoodID() : 0 %>)">
                                    View
                                </button>
                                <button class="action-btn delete" onclick="deleteFood(<%= food.getFoodID() != null ? food.getFoodID() : 0 %>)">
                                    Delete
                                </button>
                            </td>
                        </tr>
                        <% } 
                    } else { %>
                        <tr>
                            <td colspan="8" style="text-align: center; padding: 40px;">
                                <div style="color: #7f8c8d; font-size: 1.1rem;">
                                    <% if (foodList != null && !foodList.isEmpty()) { %>
                                    No food items found on this page.
                                    <% } else { %>
                                    No food items found.
                                    <% } %>
                                </div>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>

            <!-- Pagination Controls - Separate container like in the image -->
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

        <!-- Modal Add Food -->
        <div id="addFoodModal" class="modal">
            <div class="modal-content">
                <span class="close" onclick="closeAddFoodModal()">&times;</span>
                <h3 style="margin-bottom: 20px; color: #2c3e50;">Add New Food</h3>
                <form id="addFoodForm" action="food-management" method="POST">
                    <input type="hidden" name="action" value="create">

                    <div class="form-group">
                        <label for="foodName">Food Name:</label>
                        <input type="text" id="foodName" name="foodName" required>
                    </div>

                    <div class="form-group">
                        <label for="description">Description:</label>
                        <textarea id="description" name="description" rows="3"></textarea>
                    </div>

                    <div class="form-group">
                        <label for="price">Price (VND):</label>
                        <input type="number" id="price" name="price" step="1000" min="0" required>
                    </div>

                    <div class="form-group">
                        <label for="foodType">Food Type:</label>
                        <select id="foodType" name="foodType" required>
                            <option value="Snack">Snack</option>
                            <option value="Drink">Drink</option>
                            <option value="Dessert">Dessert</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="imageURL">Image URL:</label>
                        <input type="text" id="imageURL" name="imageURL" placeholder="https://example.com/image.jpg">
                    </div>

                    <div class="form-group">
                        <label style="display: inline-flex; align-items: center;">
                            <input type="checkbox" name="isAvailable" value="true" checked style="width: auto; margin-right: 8px;">
                            Available
                        </label>
                    </div>

                    <div style="display: flex; gap: 10px; margin-top: 20px;">
                        <button type="submit" class="btn btn-primary" style="flex: 1;">Add Food</button>
                        <button type="button" class="btn" onclick="closeAddFoodModal()" 
                                style="flex: 1; background-color: #95a5a6; color: white;">Cancel</button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Modal View Food -->
        <div id="viewFoodModal" class="modal">
            <div class="modal-content view-modal-content">
                <span class="close" onclick="closeViewFoodModal()">&times;</span>
                <h3 style="margin-bottom: 20px; color: #2c3e50;">Food Details</h3>

                <div class="view-field">
                    <div class="view-label">Food ID</div>
                    <div class="view-value" id="viewFoodId">N/A</div>
                </div>

                <div class="view-field">
                    <div class="view-label">Food Name</div>
                    <div class="view-value" id="viewFoodName">N/A</div>
                </div>

                <div class="view-field">
                    <div class="view-label">Description</div>
                    <div class="view-value" id="viewDescription">N/A</div>
                </div>

                <div class="view-field">
                    <div class="view-label">Price</div>
                    <div class="view-value" id="viewPrice">N/A</div>
                </div>

                <div class="view-field">
                    <div class="view-label">Food Type</div>
                    <div class="view-value" id="viewFoodType">N/A</div>
                </div>

                <div class="view-field">
                    <div class="view-label">Status</div>
                    <div class="view-value" id="viewStatus">N/A</div>
                </div>

                <div class="modal-actions">
                    <button type="button" class="btn btn-primary" id="editFoodBtn">Edit</button>
                    <button type="button" class="btn" onclick="closeViewFoodModal()" 
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
                    // Remove success parameter from URL
                    const newUrl = window.location.pathname;
                    window.history.replaceState({}, document.title, newUrl);
                }

                if (error) {
                    alert('Operation failed: ' + error);
                    // Remove error parameter from URL
                    const newUrl = window.location.pathname;
                    window.history.replaceState({}, document.title, newUrl);
                }

                // Setup event listener for edit button
                document.getElementById('editFoodBtn').addEventListener('click', function () {
                    if (currentFoodId !== 0) {
                        // Redirect to edit page through servlet
                        window.location.href = 'food-management?action=edit&id=' + currentFoodId;
                    } else {
                        alert('No food item selected');
                    }
                });
            });

            // Global variable to store current food ID
            let currentFoodId = 0;

            // Pagination function
            function goToPage(page) {
                const urlParams = new URLSearchParams(window.location.search);
                urlParams.set('page', page);
                window.location.href = window.location.pathname + '?' + urlParams.toString();
            }

            // Modal functions
            function openAddFoodModal() {
                document.getElementById('addFoodModal').style.display = 'block';
            }

            function closeAddFoodModal() {
                document.getElementById('addFoodModal').style.display = 'none';
            }

            // View Food Modal functions
            function viewFood(foodId) {
                if (foodId === 0) {
                    alert('Invalid food ID');
                    return;
                }

                currentFoodId = foodId;

                const allRows = document.querySelectorAll('#foodTableBody tr');
                let targetRow = null;

                for (let row of allRows) {
                    const rowFoodId = row.getAttribute('data-food-id');
                    if (rowFoodId && parseInt(rowFoodId) === foodId) {
                        targetRow = row;
                        break;
                    }
                }

                if (!targetRow) {
                    alert('Food item not found in table. FoodId: ' + foodId);
                    return;
                }

                const cells = targetRow.cells;
                const foodData = {
                    id: cells[0].textContent,
                    name: cells[2].textContent,
                    description: cells[3].textContent,
                    type: cells[4].querySelector('.food-type').textContent,
                    price: cells[5].textContent,
                    status: cells[6].querySelector('.status').textContent
                };

                document.getElementById('viewFoodId').textContent = foodData.id;
                document.getElementById('viewFoodName').textContent = foodData.name;
                document.getElementById('viewDescription').textContent = foodData.description;
                document.getElementById('viewPrice').textContent = foodData.price;
                document.getElementById('viewFoodType').textContent = foodData.type;
                document.getElementById('viewStatus').textContent = foodData.status;

                document.getElementById('viewFoodModal').style.display = 'block';
            }

            function closeViewFoodModal() {
                document.getElementById('viewFoodModal').style.display = 'none';
                currentFoodId = 0;
            }

            // Close modal when clicking outside
            window.onclick = function (event) {
                const addModal = document.getElementById('addFoodModal');
                const viewModal = document.getElementById('viewFoodModal');

                if (event.target === addModal) {
                    closeAddFoodModal();
                }

                if (event.target === viewModal) {
                    closeViewFoodModal();
                }
            }

            // Search functionality
            function searchFood() {
                applyFilters();
            }

            // Filter functionality
            function filterFood() {
                applyFilters();
            }

            // Combined search and filter function
            function applyFilters() {
                const searchInput = document.getElementById('searchInput');
                const filterSelect = document.getElementById('filterSelect');

                const searchTerm = searchInput.value.toLowerCase();
                const filterValue = filterSelect.value;

                const rows = document.querySelectorAll('#foodTableBody tr');

                rows.forEach(row => {
                    if (row.cells.length < 7)
                        return;

                    const foodName = row.cells[2].textContent.toLowerCase();
                    const description = row.cells[3].textContent.toLowerCase();
                    const foodType = row.cells[4].textContent.toLowerCase();
                    const status = row.cells[6].textContent.toLowerCase();

                    const matchesSearch = searchTerm === '' ||
                            foodName.includes(searchTerm) ||
                            description.includes(searchTerm) ||
                            foodType.includes(searchTerm);

                    let matchesFilter = true;
                    if (filterValue !== 'all') {
                        const [filterType, filterValueText] = filterValue.split(':');

                        if (filterType === 'category') {
                            matchesFilter = foodType.includes(filterValueText.toLowerCase());
                        } else if (filterType === 'status') {
                            matchesFilter = status.includes(filterValueText.toLowerCase());
                        }
                    }

                    row.style.display = (matchesSearch && matchesFilter) ? '' : 'none';
                });
            }

            function deleteFood(foodId) {
                if (foodId === 0) {
                    alert('Invalid food ID');
                    return;
                }

                if (confirm('Are you sure you want to delete this food item?')) {
                    fetch('food-management?action=delete&foodID=' + foodId, {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/x-www-form-urlencoded',
                        }
                    })
                            .then(response => {
                                if (response.ok) {
                                    alert('Food item deleted successfully!');
                                    location.reload();
                                } else {
                                    return response.text().then(text => {
                                        throw new Error(text || 'Unknown error occurred');
                                    });
                                }
                            })
                            .catch(error => {
                                alert('Error deleting food item: ' + error.message);
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