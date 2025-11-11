<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="entity.Food" %>
<%@ page import="java.math.BigDecimal" %>
<%
    Food food = (Food) request.getAttribute("food");
    if (food == null) {
        response.sendRedirect("food-management?error=Food+not+found");
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Food - Food Management</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        body {
            background-color: #f5f7fa;
            padding: 20px;
        }

        .container {
            max-width: 800px;
            margin: 0 auto;
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }

        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            padding-bottom: 15px;
            border-bottom: 2px solid #f39c12;
        }

        .header h1 {
            color: #2c3e50;
            font-size: 1.8rem;
        }

        .back-btn {
            padding: 10px 20px;
            background-color: #95a5a6;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            transition: background-color 0.3s;
        }

        .back-btn:hover {
            background-color: #7f8c8d;
        }

        .form-group {
            margin-bottom: 20px;
        }

        label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: #2c3e50;
        }

        input, select, textarea {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
            transition: border-color 0.3s;
        }

        input:focus, select:focus, textarea:focus {
            outline: none;
            border-color: #3498db;
            box-shadow: 0 0 5px rgba(52, 152, 219, 0.3);
        }

        textarea {
            resize: vertical;
            min-height: 80px;
        }

        .checkbox-group {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .checkbox-group input {
            width: auto;
        }

        .form-actions {
            display: flex;
            gap: 15px;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #eee;
        }

        .btn {
            padding: 12px 30px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 14px;
            font-weight: 600;
            transition: all 0.3s;
            text-decoration: none;
            display: inline-block;
            text-align: center;
        }

        .btn-primary {
            background-color: #3498db;
            color: white;
        }

        .btn-primary:hover {
            background-color: #2980b9;
        }

        .btn-warning {
            background-color: #f39c12;
            color: white;
        }

        .btn-warning:hover {
            background-color: #e67e22;
        }

        .btn-secondary {
            background-color: #95a5a6;
            color: white;
        }

        .btn-secondary:hover {
            background-color: #7f8c8d;
        }

        .price-input {
            position: relative;
        }

        .price-input::after {
            content: "VND";
            position: absolute;
            right: 12px;
            top: 50%;
            transform: translateY(-50%);
            color: #7f8c8d;
            font-weight: 500;
        }

        .alert {
            padding: 12px 15px;
            border-radius: 5px;
            margin-bottom: 20px;
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

        .food-info {
            background-color: #f8f9fa;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
            border-left: 4px solid #3498db;
        }

        .food-info p {
            margin: 5px 0;
            color: #2c3e50;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Edit Food</h1>
            <a href="food-management" class="back-btn">← Back to Food List</a>
        </div>

        <div class="food-info">
            <p><strong>Food ID:</strong> <%= food.getFoodID() %></p>
            <p><strong>Created:</strong> <%= food.getCreatedDate() != null ? food.getCreatedDate() : "N/A" %></p>
            <p><strong>Last Modified:</strong> <%= food.getLastModifiedDate() != null ? food.getLastModifiedDate() : "N/A" %></p>
        </div>

        <%-- Display success/error messages --%>
        <%
            String success = request.getParameter("success");
            String error = request.getParameter("error");
            
            if (success != null) {
        %>
            <div class="alert alert-success">
                ✅ Food item updated successfully!
            </div>
        <%
            }
            
            if (error != null) {
        %>
            <div class="alert alert-error">
                ❌ Error updating food item: <%= error %>
            </div>
        <%
            }
        %>

        <form action="food-management" method="POST" id="foodForm">
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="foodID" value="<%= food.getFoodID() %>">

            <div class="form-group">
                <label for="foodName">Food Name *</label>
                <input type="text" id="foodName" name="foodName" 
                       value="<%= food.getFoodName() != null ? food.getFoodName() : "" %>" 
                       required placeholder="Enter food name" maxlength="100">
            </div>

            <div class="form-group">
                <label for="description">Description</label>
                <textarea id="description" name="description" 
                         placeholder="Enter food description (optional)" maxlength="500"><%= food.getDescription() != null ? food.getDescription() : "" %></textarea>
            </div>

            <div class="form-group">
                <label for="price">Price (VND) *</label>
                <div class="price-input">
                    <input type="number" id="price" name="price" 
                          step="1000" min="0" required 
                          value="<%= food.getPrice() != null ? food.getPrice().intValue() : "" %>"
                          placeholder="Enter price">
                </div>
            </div>

            <div class="form-group">
                <label for="foodType">Food Type *</label>
                <select id="foodType" name="foodType" required>
                    <option value="">Select food type</option>
                    <option value="Snack" <%= "Snack".equals(food.getFoodType()) ? "selected" : "" %>>Snack</option>
                    <option value="Drink" <%= "Drink".equals(food.getFoodType()) ? "selected" : "" %>>Drink</option>
                    <option value="Dessert" <%= "Dessert".equals(food.getFoodType()) ? "selected" : "" %>>Dessert</option>
                </select>
            </div>

            <div class="form-group">
                <label for="imageURL">Image URL</label>
                <input type="url" id="imageURL" name="imageURL" 
                      value="<%= food.getImageURL() != null ? food.getImageURL() : "" %>"
                      placeholder="https://example.com/image.jpg (optional)">
            </div>

            <div class="form-group">
                <div class="checkbox-group">
                    <input type="checkbox" id="isAvailable" name="isAvailable" value="true" 
                          <%= food.getIsAvailable() != null && food.getIsAvailable() ? "checked" : "" %>>
                    <label for="isAvailable" style="margin: 0;">Available for sale</label>
                </div>
            </div>

            <div class="form-actions">
                <button type="submit" class="btn btn-warning">Update Food</button>
                <a href="food-management" class="btn btn-secondary">Cancel</a>
            </div>
        </form>
    </div>

    <script>
        document.getElementById('foodForm').addEventListener('submit', function(e) {
            const foodName = document.getElementById('foodName').value.trim();
            const price = document.getElementById('price').value;
            const foodType = document.getElementById('foodType').value;

            // Basic validation
            if (!foodName) {
                alert('Please enter food name');
                e.preventDefault();
                return;
            }

            if (!price || price < 0) {
                alert('Please enter a valid price');
                e.preventDefault();
                return;
            }

            if (!foodType) {
                alert('Please select food type');
                e.preventDefault();
                return;
            }
        });

        // Format price display
        document.getElementById('price').addEventListener('blur', function() {
            const value = parseInt(this.value);
            if (!isNaN(value) && value >= 0) {
                this.value = value;
            }
        });

        // Show image preview if URL is provided
        document.getElementById('imageURL').addEventListener('blur', function() {
            const url = this.value.trim();
            if (url) {
                // You can add image preview functionality here
                console.log('Image URL:', url);
            }
        });
    </script>
</body>
</html>