<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="entity.Combo" %>
<%@ page import="entity.Food" %>
<%@ page import="java.util.List" %>
<%@ page import="java.math.BigDecimal" %>
<%
    Combo combo = (Combo) request.getAttribute("combo");
    List<Food> selectedFoods = (List<Food>) request.getAttribute("selectedFoods");
    List<Food> availableFoods = (List<Food>) request.getAttribute("availableFoods");
    
    // Debug information
    System.out.println("JSP - Combo: " + combo);
    System.out.println("JSP - Selected foods: " + (selectedFoods != null ? selectedFoods.size() : "null"));
    System.out.println("JSP - Available foods: " + (availableFoods != null ? availableFoods.size() : "null"));
    
    // Get messages from URL parameters
    String error = request.getParameter("error");
    String success = request.getParameter("success");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Combo Food</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        body {
            background-color: #f5f7fa;
            color: #333;
            padding: 20px;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            overflow: hidden;
        }

        .header {
            background: linear-gradient(135deg, #2c3e50, #3498db);
            color: white;
            padding: 25px 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .header h1 {
            font-size: 1.8rem;
            font-weight: 600;
        }

        .back-btn {
            background-color: rgba(255,255,255,0.2);
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 5px;
            cursor: pointer;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: background-color 0.3s;
        }

        .back-btn:hover {
            background-color: rgba(255,255,255,0.3);
        }

        .combo-info {
            padding: 25px 30px;
            background-color: #f8f9fa;
            border-bottom: 1px solid #e9ecef;
        }

        .combo-details {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
        }

        .detail-item {
            display: flex;
            flex-direction: column;
            gap: 5px;
        }

        .detail-label {
            font-weight: 600;
            color: #2c3e50;
            font-size: 0.9rem;
        }

        .detail-value {
            color: #555;
            font-size: 1rem;
        }

        .alert {
            padding: 15px 20px;
            border-radius: 6px;
            margin: 20px 30px;
        }

        .alert-success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }

        .alert-error {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }

        .content {
            padding: 30px;
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 30px;
        }

        @media (max-width: 768px) {
            .content {
                grid-template-columns: 1fr;
            }
        }

        .section {
            background: white;
            border: 1px solid #e9ecef;
            border-radius: 8px;
            overflow: hidden;
        }

        .section-header {
            background-color: #f8f9fa;
            padding: 15px 20px;
            border-bottom: 1px solid #e9ecef;
        }

        .section-header h3 {
            color: #2c3e50;
            font-size: 1.2rem;
            font-weight: 600;
        }

        .section-body {
            padding: 20px;
            max-height: 500px;
            overflow-y: auto;
        }

        .food-list {
            display: flex;
            flex-direction: column;
            gap: 15px;
        }

        .food-item {
            display: flex;
            align-items: center;
            gap: 15px;
            padding: 15px;
            border: 1px solid #e9ecef;
            border-radius: 6px;
        }

        .food-image {
            width: 60px;
            height: 60px;
            border-radius: 6px;
            object-fit: cover;
            background-color: #f8f9fa;
        }

        .food-info {
            flex: 1;
        }

        .food-name {
            font-weight: 600;
            color: #2c3e50;
            margin-bottom: 5px;
        }

        .food-description {
            color: #666;
            font-size: 0.9rem;
            margin-bottom: 5px;
        }

        .food-price {
            color: #e74c3c;
            font-weight: 600;
        }

        .food-actions {
            display: flex;
            gap: 10px;
        }

        .btn {
            padding: 8px 16px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-weight: 500;
            transition: all 0.3s;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 5px;
            font-size: 0.85rem;
        }

        .btn-danger {
            background-color: #e74c3c;
            color: white;
        }

        .btn-danger:hover {
            background-color: #c0392b;
        }

        .btn-success {
            background-color: #27ae60;
            color: white;
        }

        .btn-success:hover {
            background-color: #219653;
        }

        .empty-state {
            text-align: center;
            padding: 40px 20px;
            color: #7f8c8d;
        }

        .quantity-input {
            width: 60px;
            padding: 5px;
            border: 1px solid #ddd;
            border-radius: 4px;
            text-align: center;
        }

        .action-buttons {
            display: flex;
            gap: 10px;
            align-items: center;
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- Header -->
        <div class="header">
            <h1>
                <% if (combo != null) { %>
                    Manage Food - <%= combo.getComboName() %>
                <% } else { %>
                    Manage Combo Food
                <% } %>
            </h1>
            <a href="combo-management" class="back-btn">
                ← Back to Combos
            </a>
        </div>

        <!-- Combo Information -->
        <% if (combo != null) { %>
        <div class="combo-info">
            <div class="combo-details">
                <div class="detail-item">
                    <span class="detail-label">Combo ID</span>
                    <span class="detail-value">#<%= combo.getComboID() %></span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Description</span>
                    <span class="detail-value"><%= combo.getDescription() != null ? combo.getDescription() : "No description" %></span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Price</span>
                    <span class="detail-value">
                        <% if (combo.getDiscountPrice() != null) { %>
                            <span style="color: #e74c3c; font-weight: 600;"><%= formatPrice(combo.getDiscountPrice()) %></span>
                            <span style="text-decoration: line-through; color: #7f8c8d; margin-left: 8px;"><%= formatPrice(combo.getTotalPrice()) %></span>
                        <% } else { %>
                            <span style="font-weight: 600;"><%= formatPrice(combo.getTotalPrice()) %></span>
                        <% } %>
                    </span>
                </div>
            </div>
        </div>
        <% } %>

        <!-- Messages -->
        <% if (success != null) { %>
            <div class="alert alert-success">
                ✅ <%= success %>
            </div>
        <% } %>
        
        <% if (error != null) { %>
            <div class="alert alert-error">
                ❌ <%= error %>
            </div>
        <% } %>

        <!-- Content -->
        <div class="content">
            <!-- Selected Food Items -->
            <div class="section">
                <div class="section-header">
                    <h3>Food in Combo (<%= selectedFoods != null ? selectedFoods.size() : 0 %>)</h3>
                </div>
                <div class="section-body">
                    <% if (selectedFoods != null && !selectedFoods.isEmpty()) { %>
                        <div class="food-list">
                            <% for (Food food : selectedFoods) { %>
                            <div class="food-item">
                                <div class="food-image" style="background-color: #e9ecef; display: flex; align-items: center; justify-content: center;">
                                    <span style="color: #7f8c8d; font-size: 0.8rem;">🍕</span>
                                </div>
                                <div class="food-info">
                                    <div class="food-name"><%= food.getFoodName() %></div>
                                    <% if (food.getDescription() != null && !food.getDescription().isEmpty()) { %>
                                        <div class="food-description"><%= food.getDescription() %></div>
                                    <% } %>
                                    <div class="food-price"><%= formatPrice(food.getPrice()) %></div>
                                </div>
                                <div class="food-actions">
                                    <form action="combo-food-management" method="POST" style="display: inline;">
                                        <input type="hidden" name="action" value="remove">
                                        <input type="hidden" name="comboId" value="<%= combo.getComboID() %>">
                                        <input type="hidden" name="foodId" value="<%= food.getFoodID() %>">
                                        <button type="submit" class="btn btn-danger" onclick="return confirm('Remove this food from combo?')">
                                            Remove
                                        </button>
                                    </form>
                                </div>
                            </div>
                            <% } %>
                        </div>
                    <% } else { %>
                        <div class="empty-state">
                            <div style="font-size: 3rem; margin-bottom: 15px;">🍽️</div>
                            <h3>No Food Items</h3>
                            <p>This combo doesn't have any food items yet.</p>
                        </div>
                    <% } %>
                </div>
            </div>

            <!-- Available Food Items -->
            <div class="section">
                <div class="section-header">
                    <h3>Available Food (<%= availableFoods != null ? availableFoods.size() : 0 %>)</h3>
                </div>
                <div class="section-body">
                    <% if (availableFoods != null && !availableFoods.isEmpty()) { %>
                        <div class="food-list">
                            <% for (Food food : availableFoods) { %>
                            <div class="food-item">
                                <div class="food-image" style="background-color: #e9ecef; display: flex; align-items: center; justify-content: center;">
                                    <span style="color: #7f8c8d; font-size: 0.8rem;">🍕</span>
                                </div>
                                <div class="food-info">
                                    <div class="food-name"><%= food.getFoodName() %></div>
                                    <% if (food.getDescription() != null && !food.getDescription().isEmpty()) { %>
                                        <div class="food-description"><%= food.getDescription() %></div>
                                    <% } %>
                                    <div class="food-price"><%= formatPrice(food.getPrice()) %></div>
                                </div>
                                <div class="food-actions">
                                    <form action="combo-food-management" method="POST" style="display: inline;">
                                        <input type="hidden" name="action" value="add">
                                        <input type="hidden" name="comboId" value="<%= combo.getComboID() %>">
                                        <input type="hidden" name="foodId" value="<%= food.getFoodID() %>">
                                        <div class="action-buttons">
                                            <input type="number" name="quantity" value="1" min="1" max="10" class="quantity-input">
                                            <button type="submit" class="btn btn-success">
                                                Add
                                            </button>
                                        </div>
                                    </form>
                                </div>
                            </div>
                            <% } %>
                        </div>
                    <% } else { %>
                        <div class="empty-state">
                            <div style="font-size: 3rem; margin-bottom: 15px;">📦</div>
                            <h3>No Available Food</h3>
                            <p>All food items are already in this combo.</p>
                        </div>
                    <% } %>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Auto-hide messages after 5 seconds
        setTimeout(function() {
            const alerts = document.querySelectorAll('.alert');
            alerts.forEach(alert => {
                alert.style.opacity = '0';
                alert.style.transition = 'opacity 0.5s';
                setTimeout(() => alert.remove(), 500);
            });
        }, 5000);
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