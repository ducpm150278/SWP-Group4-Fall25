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
                background: linear-gradient(135deg, #f5f7fa 0%, #e4efe9 100%);
                padding: 20px;
                min-height: 100vh;
                display: flex;
                align-items: center;
                justify-content: center;
            }

            .container {
                max-width: 800px;
                width: 100%;
                background: white;
                padding: 30px;
                border-radius: 15px;
                box-shadow: 0 10px 30px rgba(0,0,0,0.1);
                animation: fadeIn 0.5s ease-out;
            }

            @keyframes fadeIn {
                from {
                    opacity: 0;
                    transform: translateY(10px);
                }
                to {
                    opacity: 1;
                    transform: translateY(0);
                }
            }

            .form-group {
                margin-bottom: 25px;
                position: relative;
            }

            label {
                display: block;
                margin-bottom: 8px;
                font-weight: 600;
                color: #2c3e50;
                font-size: 14px;
                text-transform: uppercase;
                letter-spacing: 0.5px;
            }

            input, select, textarea {
                width: 100%;
                padding: 14px;
                border: 1px solid #ddd;
                border-radius: 8px;
                font-size: 15px;
                transition: all 0.3s;
                background-color: #f8f9fa;
            }

            input:focus, select:focus, textarea:focus {
                outline: none;
                border-color: #3498db;
                box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.2);
                background-color: white;
                transform: translateY(-2px);
            }

            textarea {
                resize: vertical;
                min-height: 100px;
            }

            .checkbox-group {
                display: flex;
                align-items: center;
                gap: 10px;
                background-color: #f8f9fa;
                padding: 15px;
                border-radius: 8px;
                transition: all 0.3s;
            }

            .checkbox-group:hover {
                background-color: #edf2f7;
            }

            .checkbox-group input {
                width: auto;
                transform: scale(1.2);
            }

            .form-actions {
                display: flex;
                gap: 15px;
                margin-top: 30px;
                padding-top: 20px;
                border-top: 1px solid #eee;
            }

            .btn {
                padding: 14px 30px;
                border: none;
                border-radius: 8px;
                cursor: pointer;
                font-size: 15px;
                font-weight: 600;
                transition: all 0.3s;
                text-decoration: none;
                display: inline-block;
                text-align: center;
                flex: 1;
                box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            }

            .btn:hover {
                transform: translateY(-3px);
                box-shadow: 0 6px 8px rgba(0,0,0,0.15);
            }

            .btn-warning {
                background: linear-gradient(135deg, #f39c12, #e67e22);
                color: white;
            }

            .btn-warning:hover {
                background: linear-gradient(135deg, #e67e22, #d35400);
            }

            .btn-secondary {
                background: linear-gradient(135deg, #95a5a6, #7f8c8d);
                color: white;
            }

            .btn-secondary:hover {
                background: linear-gradient(135deg, #7f8c8d, #6c7b7d);
            }

            .price-input {
                position: relative;
            }

            .price-input::after {
                content: "VND";
                position: absolute;
                right: 15px;
                top: 50%;
                transform: translateY(-50%);
                color: #7f8c8d;
                font-weight: 600;
                background: #e9ecef;
                padding: 2px 8px;
                border-radius: 4px;
            }

            .alert {
                padding: 15px;
                border-radius: 8px;
                margin-bottom: 20px;
                animation: slideIn 0.5s ease-out;
                display: flex;
                align-items: center;
                gap: 10px;
            }

            @keyframes slideIn {
                from {
                    opacity: 0;
                    transform: translateX(-10px);
                }
                to {
                    opacity: 1;
                    transform: translateX(0);
                }
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

            .form-section {
                margin-bottom: 30px;
                padding: 25px;
                background: #f8f9fa;
                border-radius: 12px;
                box-shadow: 0 4px 6px rgba(0,0,0,0.05);
                border-left: 4px solid #3498db;
                animation: slideUp 0.5s ease-out;
            }

            @keyframes slideUp {
                from {
                    opacity: 0;
                    transform: translateY(15px);
                }
                to {
                    opacity: 1;
                    transform: translateY(0);
                }
            }

            .form-section-title {
                font-size: 18px;
                color: #2c3e50;
                margin-bottom: 20px;
                padding-bottom: 10px;
                border-bottom: 2px solid #e9ecef;
                display: flex;
                align-items: center;
                gap: 10px;
            }

            .form-section-title::before {
                content: "📝";
                font-size: 20px;
            }

            .required::after {
                content: " *";
                color: #e74c3c;
            }

            .form-header {
                text-align: center;
                margin-bottom: 30px;
                padding: 20px;
                background: linear-gradient(135deg, #3498db, #2c3e50);
                border-radius: 10px;
                color: white;
                box-shadow: 0 4px 15px rgba(52, 152, 219, 0.3);
            }

            .form-header h2 {
                font-size: 1.5rem;
                margin-bottom: 5px;
            }

            .form-header p {
                opacity: 0.9;
                font-size: 0.9rem;
            }

            .image-preview {
                margin-top: 10px;
                text-align: center;
                display: none;
            }

            .image-preview img {
                max-width: 200px;
                max-height: 150px;
                border-radius: 8px;
                box-shadow: 0 4px 8px rgba(0,0,0,0.1);
                border: 2px solid #e9ecef;
            }

            .image-preview.active {
                display: block;
                animation: fadeIn 0.5s ease-out;
            }

            .url-input-group {
                display: flex;
                gap: 10px;
                align-items: center;
            }

            .url-input-group input {
                flex: 1;
            }

            .test-btn {
                padding: 10px 15px;
                background: #95a5a6;
                color: white;
                border: none;
                border-radius: 5px;
                cursor: pointer;
                font-size: 12px;
                transition: all 0.3s;
            }

            .test-btn:hover {
                background: #7f8c8d;
            }
        </style>
    </head>
    <body>
        <div class="container">
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

                <div class="form-header">
                    <h2>Update Food Information</h2>
                    <p>Modify the details below and click Update to save changes</p>
                </div>

                <div class="form-section">
                    <h2 class="form-section-title">Food Details</h2>

                    <div class="form-group">
                        <label for="foodName" class="required">Food Name</label>
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
                        <label for="price" class="required">Price (VND)</label>
                        <div class="price-input">
                            <input type="number" id="price" name="price" 
                                   step="1000" min="0" required 
                                   value="<%= food.getPrice() != null ? food.getPrice().intValue() : "" %>"
                                   placeholder="Enter price">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="foodType" class="required">Food Type</label>
                        <select id="foodType" name="foodType" required>
                            <option value="">Select food type</option>
                            <option value="Snack" <%= "Snack".equals(food.getFoodType()) ? "selected" : "" %>>Snack</option>
                            <option value="Drink" <%= "Drink".equals(food.getFoodType()) ? "selected" : "" %>>Drink</option>
                            <option value="Dessert" <%= "Dessert".equals(food.getFoodType()) ? "selected" : "" %>>Dessert</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="imageURL">Image URL</label>
                        <div class="url-input-group">
                            <input type="url" id="imageURL" name="imageURL" 
                                   value="<%= food.getImageURL() != null ? food.getImageURL() : "" %>"
                                   placeholder="https://example.com/image.jpg (optional)">
                            <button type="button" class="test-btn" onclick="testImageURL()">Test</button>
                        </div>
                        <div class="image-preview" id="imagePreview">
                            <img src="" alt="Image preview" id="previewImage">
                            <p style="margin-top: 5px; font-size: 12px; color: #6c757d;">Image preview</p>
                        </div>
                    </div>

                    <div class="form-group">
                        <div class="checkbox-group">
                            <input type="checkbox" id="isAvailable" name="isAvailable" value="true" 
                                   <%= food.getIsAvailable() != null && food.getIsAvailable() ? "checked" : "" %>>
                            <label for="isAvailable" style="margin: 0;">Available for sale</label>
                        </div>
                    </div>
                </div>

                <div class="form-actions">
                    <button type="submit" class="btn btn-warning">Update Food</button>
                    <a href="food-management" class="btn btn-secondary">Cancel</a>
                </div>
            </form>
        </div>

        <script>
            document.getElementById('foodForm').addEventListener('submit', function (e) {
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
            document.getElementById('price').addEventListener('blur', function () {
                const value = parseInt(this.value);
                if (!isNaN(value) && value >= 0) {
                    this.value = value;
                }
            });

            // Image URL preview functionality
            const imageURL = document.getElementById('imageURL');
            const imagePreview = document.getElementById('imagePreview');
            const previewImage = document.getElementById('previewImage');

            function testImageURL() {
                const url = imageURL.value.trim();
                if (url) {
                    previewImage.src = url;
                    previewImage.onload = function () {
                        imagePreview.classList.add('active');
                    };
                    previewImage.onerror = function () {
                        alert('Cannot load image from the provided URL. Please check the URL and try again.');
                        imagePreview.classList.remove('active');
                    };
                } else {
                    alert('Please enter an image URL first.');
                }
            }

            // Auto-preview when URL loses focus
            imageURL.addEventListener('blur', function () {
                const url = this.value.trim();
                if (url) {
                    previewImage.src = url;
                    previewImage.onload = function () {
                        imagePreview.classList.add('active');
                    };
                    previewImage.onerror = function () {
                        imagePreview.classList.remove('active');
                    };
                } else {
                    imagePreview.classList.remove('active');
                }
            });

            // Add character counter for description
            const description = document.getElementById('description');
            const descriptionCounter = document.createElement('div');
            descriptionCounter.style.textAlign = 'right';
            descriptionCounter.style.fontSize = '12px';
            descriptionCounter.style.color = '#6c757d';
            descriptionCounter.style.marginTop = '5px';
            description.parentNode.appendChild(descriptionCounter);

            function updateDescriptionCounter() {
                const count = description.value.length;
                descriptionCounter.textContent = `${count}/500 characters`;
            }

            description.addEventListener('input', updateDescriptionCounter);
            updateDescriptionCounter(); // Initialize counter

            // Initialize image preview if URL exists on page load
            window.addEventListener('load', function () {
                const initialURL = imageURL.value.trim();
                if (initialURL) {
                    previewImage.src = initialURL;
                    previewImage.onload = function () {
                        imagePreview.classList.add('active');
                    };
                }
            });
        </script>
    </body>
</html>