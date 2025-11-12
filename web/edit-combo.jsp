<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="entity.Combo" %>
<%@ page import="java.math.BigDecimal" %>
<%
    Combo combo = (Combo) request.getAttribute("combo");
    if (combo == null) {
        response.sendRedirect("combo-management?error=Combo+not+found");
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Combo - Combo Management</title>
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
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
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
            border-color: #9b59b6;
            box-shadow: 0 0 0 3px rgba(155, 89, 182, 0.2);
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

        .btn-primary {
            background: linear-gradient(135deg, #9b59b6, #8e44ad);
            color: white;
        }

        .btn-primary:hover {
            background: linear-gradient(135deg, #8e44ad, #7d3c98);
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
            from { opacity: 0; transform: translateX(-10px); }
            to { opacity: 1; transform: translateX(0); }
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
            border-left: 4px solid #9b59b6;
            animation: slideUp 0.5s ease-out;
        }

        @keyframes slideUp {
            from { opacity: 0; transform: translateY(15px); }
            to { opacity: 1; transform: translateY(0); }
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
            content: "📦";
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
            background: linear-gradient(135deg, #9b59b6, #2c3e50);
            border-radius: 10px;
            color: white;
            box-shadow: 0 4px 15px rgba(155, 89, 182, 0.3);
        }

        .form-header h2 {
            font-size: 1.5rem;
            margin-bottom: 5px;
        }

        .form-header p {
            opacity: 0.9;
            font-size: 0.9rem;
        }

        .price-container {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }

        .savings-display {
            background: linear-gradient(135deg, #fff3e0, #ffecb3);
            padding: 15px;
            border-radius: 8px;
            margin-top: 10px;
            text-align: center;
            font-weight: 600;
            color: #ef6c00;
            display: none;
            border: 2px dashed #ffb74d;
            animation: pulse 2s infinite;
        }

        @keyframes pulse {
            0% { transform: scale(1); }
            50% { transform: scale(1.02); }
            100% { transform: scale(1); }
        }

        .savings-display.show {
            display: block;
            animation: slideIn 0.5s ease-out;
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
            transform: translateY(-1px);
        }

        @media (max-width: 768px) {
            .price-container {
                grid-template-columns: 1fr;
            }
            
            .form-actions {
                flex-direction: column;
            }
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
                ✅ Combo updated successfully!
            </div>
        <%
            }
            
            if (error != null) {
        %>
            <div class="alert alert-error">
                ❌ Error updating combo: <%= error %>
            </div>
        <%
            }
        %>

        <form action="combo-management" method="POST" id="comboForm">
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="comboID" value="<%= combo.getComboID() %>">

            <div class="form-header">
                <h2>Update Combo Information</h2>
                <p>Modify the details below and click Update to save changes</p>
            </div>

            <div class="form-section">
                <h2 class="form-section-title">Combo Details</h2>
                
                <div class="form-group">
                    <label for="comboName" class="required">Combo Name</label>
                    <input type="text" id="comboName" name="comboName" 
                           value="<%= combo.getComboName() != null ? combo.getComboName() : "" %>" 
                           required placeholder="Enter combo name" maxlength="100">
                </div>

                <div class="form-group">
                    <label for="description">Description</label>
                    <textarea id="description" name="description" 
                             placeholder="Enter combo description (optional)" maxlength="500"><%= combo.getDescription() != null ? combo.getDescription() : "" %></textarea>
                </div>

                <div class="price-container">
                    <div class="form-group">
                        <label for="totalPrice" class="required">Total Price (VND)</label>
                        <div class="price-input">
                            <input type="number" id="totalPrice" name="totalPrice" 
                                  step="1000" min="0" required 
                                  value="<%= combo.getTotalPrice() != null ? combo.getTotalPrice().intValue() : "" %>"
                                  placeholder="Enter total price">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="discountPrice">Discount Price (VND)</label>
                        <div class="price-input">
                            <input type="number" id="discountPrice" name="discountPrice" 
                                  step="1000" min="0"
                                  value="<%= combo.getDiscountPrice() != null ? combo.getDiscountPrice().intValue() : "" %>"
                                  placeholder="Enter discount price (optional)">
                        </div>
                    </div>
                </div>

                <div id="savingsDisplay" class="savings-display">
                    🎉 You save: <span id="savingsAmount">0</span> VND
                </div>

                <div class="form-group">
                    <label for="comboImage">Combo Image URL</label>
                    <div class="url-input-group">
                        <input type="url" id="comboImage" name="comboImage" 
                              value="<%= combo.getComboImage() != null ? combo.getComboImage() : "" %>"
                              placeholder="https://example.com/combo.jpg (optional)">
                        <button type="button" class="test-btn" onclick="testImageURL()">Test</button>
                    </div>
                    <div class="image-preview" id="imagePreview">
                        <img src="" alt="Combo preview" id="previewImage">
                        <p style="margin-top: 5px; font-size: 12px; color: #6c757d;">Image preview</p>
                    </div>
                </div>

                <div class="form-group">
                    <div class="checkbox-group">
                        <input type="checkbox" id="isAvailable" name="isAvailable" value="true" 
                              <%= combo.getIsAvailable() != null && combo.getIsAvailable() ? "checked" : "" %>>
                        <label for="isAvailable" style="margin: 0;">Available for sale</label>
                    </div>
                </div>
            </div>

            <div class="form-actions">
                <button type="submit" class="btn btn-warning">Update Combo</button>
                <a href="combo-management" class="btn btn-secondary">Cancel</a>
                <button type="button" class="btn btn-primary" onclick="manageComboFood()">Manage Food Items</button>
            </div>
        </form>
    </div>

    <script>
        // Calculate and display savings
        function calculateSavings() {
            const totalPrice = parseInt(document.getElementById('totalPrice').value) || 0;
            const discountPrice = parseInt(document.getElementById('discountPrice').value) || 0;
            
            if (discountPrice > 0 && discountPrice < totalPrice) {
                const savings = totalPrice - discountPrice;
                const savingsPercentage = ((savings / totalPrice) * 100).toFixed(1);
                document.getElementById('savingsAmount').textContent = savings.toLocaleString() + ` (${savingsPercentage}%)`;
                document.getElementById('savingsDisplay').classList.add('show');
            } else {
                document.getElementById('savingsDisplay').classList.remove('show');
            }
        }

        // Image URL preview functionality
        const comboImage = document.getElementById('comboImage');
        const imagePreview = document.getElementById('imagePreview');
        const previewImage = document.getElementById('previewImage');

        function testImageURL() {
            const url = comboImage.value.trim();
            if (url) {
                previewImage.src = url;
                previewImage.onload = function() {
                    imagePreview.classList.add('active');
                };
                previewImage.onerror = function() {
                    alert('Cannot load image from the provided URL. Please check the URL and try again.');
                    imagePreview.classList.remove('active');
                };
            } else {
                alert('Please enter an image URL first.');
            }
        }

        // Auto-preview when URL loses focus
        comboImage.addEventListener('blur', function() {
            const url = this.value.trim();
            if (url) {
                previewImage.src = url;
                previewImage.onload = function() {
                    imagePreview.classList.add('active');
                };
                previewImage.onerror = function() {
                    imagePreview.classList.remove('active');
                };
            } else {
                imagePreview.classList.remove('active');
            }
        });

        // Initialize savings calculation
        document.addEventListener('DOMContentLoaded', function() {
            calculateSavings();
            
            // Add event listeners for price changes
            document.getElementById('totalPrice').addEventListener('input', calculateSavings);
            document.getElementById('discountPrice').addEventListener('input', calculateSavings);
        });

        document.getElementById('comboForm').addEventListener('submit', function(e) {
            const comboName = document.getElementById('comboName').value.trim();
            const totalPrice = document.getElementById('totalPrice').value;
            const discountPrice = document.getElementById('discountPrice').value;

            // Basic validation
            if (!comboName) {
                alert('Please enter combo name');
                e.preventDefault();
                return;
            }

            if (!totalPrice || totalPrice < 0) {
                alert('Please enter a valid total price');
                e.preventDefault();
                return;
            }

            // Validate discount price
            if (discountPrice && (discountPrice < 0 || parseInt(discountPrice) > parseInt(totalPrice))) {
                alert('Discount price must be between 0 and total price');
                e.preventDefault();
                return;
            }
        });

        // Format price display
        document.getElementById('totalPrice').addEventListener('blur', function() {
            const value = parseInt(this.value);
            if (!isNaN(value) && value >= 0) {
                this.value = value;
                calculateSavings();
            }
        });

        document.getElementById('discountPrice').addEventListener('blur', function() {
            const value = this.value ? parseInt(this.value) : 0;
            if (!isNaN(value) && value >= 0) {
                this.value = value;
                calculateSavings();
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
        window.addEventListener('load', function() {
            const initialURL = comboImage.value.trim();
            if (initialURL) {
                previewImage.src = initialURL;
                previewImage.onload = function() {
                    imagePreview.classList.add('active');
                };
            }
        });

        function manageComboFood() {
            const comboId = <%= combo.getComboID() %>;
            if (comboId === 0) {
                alert('Invalid combo ID');
                return;
            }
            alert('Manage Combo Food functionality for Combo ID: ' + comboId + ' will be implemented');
            // window.location.href = 'combo-food-management?comboId=' + comboId;
        }
    </script>
</body>
</html>