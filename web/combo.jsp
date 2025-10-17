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

                .action-btn {
                    display: block;
                    width: 100%;
                    margin-right: 0;
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

            .price-container {
                display: flex;
                gap: 15px;
            }

            .price-container .form-group {
                flex: 1;
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
                        <select id="filterSelect" onchange="filterCombo()">
                            <option value="all">All Status</option>
                            <option value="status:available">Status: Available</option>
                            <option value="status:unavailable">Status: Unavailable</option>
                        </select>
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
                            <th>Combo Name</th>
                            <th>Description</th>
                            <th>Prices</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="comboTableBody">
                        <% if (comboList != null && !comboList.isEmpty()) { 
                            for (Combo combo : comboList) { 
                                BigDecimal savings = null;
                                if (combo.getDiscountPrice() != null && combo.getTotalPrice() != null) {
                                    savings = combo.getTotalPrice().subtract(combo.getDiscountPrice());
                                }
                        %>
                        <tr>
                            <td><%= combo.getComboID() != null ? combo.getComboID() : "N/A" %></td>
                            <td><%= combo.getComboName() != null ? combo.getComboName() : "N/A" %></td>
                            <td><%= combo.getDescription() != null ? combo.getDescription() : "N/A" %></td>
                            <td>
                                <% if (combo.getDiscountPrice() != null) { %>
                                <div class="discount-price"><%= formatPrice(combo.getDiscountPrice()) %></div>
                                <div class="original-price"><%= formatPrice(combo.getTotalPrice()) %></div>
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
                                <button class="action-btn edit" onclick="editCombo(<%= combo.getComboID() != null ? combo.getComboID() : 0 %>)">
                                    Edit
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
                            <td colspan="6" style="text-align: center; padding: 40px;">
                                <div style="color: #7f8c8d; font-size: 1.1rem;">
                                    No combos found.
                                </div>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
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
            function openAddComboModal() {
                window.location.href = 'combo-management?action=showAddForm';
            }

            function closeAddComboModal() {
                document.getElementById('addComboModal').style.display = 'none';
            }

            // Close modal when clicking outside
            window.onclick = function (event) {
                const modal = document.getElementById('addComboModal');
                if (event.target === modal) {
                    closeAddComboModal();
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
                const filterSelect = document.getElementById('filterSelect');

                const searchTerm = searchInput.value.toLowerCase();
                const filterValue = filterSelect.value;

                const rows = document.querySelectorAll('#comboTableBody tr');

                rows.forEach(row => {
                    if (row.cells.length < 5)
                        return;

                    const comboName = row.cells[1].textContent.toLowerCase();
                    const description = row.cells[2].textContent.toLowerCase();
                    const status = row.cells[4].textContent.toLowerCase();

                    // Check search term
                    const matchesSearch = searchTerm === '' ||
                            comboName.includes(searchTerm) ||
                            description.includes(searchTerm);

                    // Check filter
                    let matchesFilter = true;
                    if (filterValue !== 'all') {
                        const [filterType, filterValueText] = filterValue.split(':');

                        if (filterType === 'status') {
                            matchesFilter = status.includes(filterValueText.toLowerCase());
                        }
                    }

                    // Show/hide row based on both conditions
                    if (matchesSearch && matchesFilter) {
                        row.style.display = '';
                    } else {
                        row.style.display = 'none';
                    }
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
                console.log('Managing combo food for ID:', comboId); // Debug
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