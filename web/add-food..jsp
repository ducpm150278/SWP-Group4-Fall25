<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add New Food - Food Management</title>
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
            border-bottom: 2px solid #3498db;
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
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Add New Food</h1>
            <a href="food-management" class="back-btn">← Back to Food List</a>
        </div>

        <%-- Display success/error messages --%>
        <%
            String success = request.getParameter("success");
            String error = request.getParameter("error");
            
            if (success != null) {
        %>
            <div class="alert alert-success">
                ✅ Food item added successfully!
            </div>
        <%
            }
            
            if (error != null) {
        %>
            <div class="alert alert-error">
                ❌ Error adding food item: <%= error %>
            </div>
        <%
            }
        %>

        <form action="food-management" method="POST" id="foodForm">
            <input type="hidden" name="action" value="create">

            <div class="form-group">
                <label for="foodName">Food Name *</label>
                <input type="text" id="foodName" name="foodName" required 
                       placeholder="Enter food name" maxlength="100">
            </div>

            <div class="form-group">
                <label for="description">Description</label>
                <textarea id="description" name="description" 
                         placeholder="Enter food description (optional)" maxlength="500"></textarea>
            </div>

            <div class="form-group">
                <label for="price">Price (VND) *</label>
                <div class="price-input">
                    <input type="number" id="price" name="price" 
                          step="1000" min="0" required 
                          placeholder="Enter price">
                </div>
            </div>

            <div class="form-group">
                <label for="foodType">Food Type *</label>
                <select id="foodType" name="foodType" required>
                    <option value="">Select food type</option>
                    <option value="Snack">Snack</option>
                    <option value="Drink">Drink</option>
                    <option value="Dessert">Dessert</option>
                    <option value="Combo">Combo</option>
                </select>
            </div>

            <div class="form-group">
                <label for="imageURL">Image URL</label>
                <input type="url" id="imageURL" name="imageURL" 
                      placeholder="https://example.com/image.jpg (optional)">
            </div>

            <div class="form-group">
                <div class="checkbox-group">
                    <input type="checkbox" id="isAvailable" name="isAvailable" value="true" checked>
                    <label for="isAvailable" style="margin: 0;">Available for sale</label>
                </div>
            </div>

            <div class="form-actions">
                <button type="submit" class="btn btn-primary">Add Food</button>
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
    </script>
</body>
</html>