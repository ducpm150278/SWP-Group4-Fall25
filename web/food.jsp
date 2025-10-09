<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="entity.Food" %>
<%@ page import="java.util.List" %>
<%@ page import="java.math.BigDecimal" %>
<%
    // This would typically come from your servlet
    List<Food> foodList = (List<Food>) request.getAttribute("foodList");
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

            .action-buttons {
                display: flex;
                gap: 15px;
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

            .btn-success {
                background-color: #27ae60;
                color: white;
            }

            .btn-success:hover {
                background-color: #219a52;
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

                .search-container {
                    width: 100%;
                }

                .action-buttons {
                    width: 100%;
                    justify-content: space-between;
                }
            }

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
                <a href="food.jsp" class="nav-item active">
                    <i>🍿</i> Food Management
                </a>
                <a href="combo.jsp" class="nav-item">
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
                <div class="action-buttons">
                    <div class="search-container">
                        <span class="search-icon">🔍</span>
                        <input type="text" placeholder="Search food items..." onkeyup="searchFood()">
                    </div>
                    <button class="btn btn-primary" onclick="openAddFoodModal()">
                        <i>➕</i> Add New Food
                    </button>
                    <button class="btn btn-success" onclick="exportFoodData()">
                        <i>📥</i> Export Data
                    </button>
                </div>
            </div>

            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Food Name</th>
                            <th>Description</th>
                            <th>Type</th>
                            <th>Price</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="foodTableBody">
                        <% if (foodList != null && !foodList.isEmpty()) { 
                            for (Food food : foodList) { 
                                String foodTypeClass = food.getFoodType() != null ? food.getFoodType().toLowerCase() : "snack";
                        %>
                        <tr>
                            <td><%= food.getFoodID() != null ? food.getFoodID() : "N/A" %></td>
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
                                <button class="action-btn edit" onclick="editFood(<%= food.getFoodID() != null ? food.getFoodID() : 0 %>)">
                                    Edit
                                </button>
                                <button class="action-btn delete" onclick="deleteFood(<%= food.getFoodID() != null ? food.getFoodID() : 0 %>)">
                                    Delete
                                </button>
                            </td>
                        </tr>
                        <% } 
    } else { %>
                        <tr>
                            <td colspan="7" style="text-align: center; padding: 40px;">
                                <div style="color: #7f8c8d; font-size: 1.1rem;">
                                    No food items found.
                                </div>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
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
                            <option value="Combo">Combo</option>
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
            });

            // Modal functions
            function openAddFoodModal() {
                document.getElementById('addFoodModal').style.display = 'block';
            }

            function closeAddFoodModal() {
                document.getElementById('addFoodModal').style.display = 'none';
            }

            // Close modal when clicking outside
            window.onclick = function (event) {
                const modal = document.getElementById('addFoodModal');
                if (event.target === modal) {
                    closeAddFoodModal();
                }
            }

            // Search functionality (giữ nguyên)
            function searchFood() {
                const input = document.querySelector('.search-container input');
                const filter = input.value.toLowerCase();
                const rows = document.querySelectorAll('#foodTableBody tr');

                rows.forEach(row => {
                    if (row.cells.length < 2)
                        return;

                    const foodName = row.cells[1].textContent.toLowerCase();
                    const description = row.cells[2].textContent.toLowerCase();
                    const foodType = row.cells[3].textContent.toLowerCase();

                    if (foodName.includes(filter) || description.includes(filter) || foodType.includes(filter)) {
                        row.style.display = '';
                    } else {
                        row.style.display = 'none';
                    }
                });
            }

            function exportFoodData() {
                alert('Export functionality will be implemented');
            }

            function editFood(foodId) {
                if (foodId === 0) {
                    alert('Invalid food ID');
                    return;
                }
                // Sửa thành: gửi qua servlet
                window.location.href = 'food-management?action=getById&id=' + foodId;
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
                                    location.reload();
                                } else {
                                    response.text().then(text => {
                                        alert('Error deleting food item: ' + text);
                                    });
                                }
                            })
                            .catch(error => {
                                console.error('Error:', error);
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