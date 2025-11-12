<%-- 
    Document   : edit-combo
    Created on : Oct 12, 2025, 8:13:31 AM
    Author     : minhd
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.cinema.entity.Combo" %>
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
            border-bottom: 2px solid #9b59b6;
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
            border-color: #9b59b6;
            box-shadow: 0 0 5px rgba(155, 89, 182, 0.3);
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
            background-color: #9b59b6;
            color: white;
        }

        .btn-primary:hover {
            background-color: #8e44ad;
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

        .combo-info {
            background-color: #f8f9fa;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
            border-left: 4px solid #9b59b6;
        }

        .combo-info p {
            margin: 5px 0;
            color: #2c3e50;
        }

        .price-container {
            display: flex;
            gap: 15px;
        }

        .price-container .form-group {
            flex: 1;
        }

        .savings-display {
            background-color: #fff3e0;
            padding: 10px;
            border-radius: 5px;
            margin-top: 10px;
            text-align: center;
            font-weight: 600;
            color: #ef6c00;
            display: none;
        }

        .savings-display.show {
            display: block;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Edit Combo</h1>
            <a href="${pageContext.request.contextPath}/combo-management" class="back-btn">← Back to Combo List</a>
        </div>

        <div class="combo-info">
            <p><strong>Combo ID:</strong> <%= combo.getComboID() %></p>
            <p><strong>Created:</strong> <%= combo.getCreatedDate() != null ? combo.getCreatedDate() : "N/A" %></p>
            <p><strong>Last Modified:</strong> <%= combo.getLastModifiedDate() != null ? combo.getLastModifiedDate() : "N/A" %></p>
        </div>

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

            <div class="form-group">
                <label for="comboName">Combo Name *</label>
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
                    <label for="totalPrice">Total Price (VND) *</label>
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
                You save: <span id="savingsAmount">0</span> VND
            </div>

            <div class="form-group">
                <label for="comboImage">Combo Image URL</label>
                <input type="url" id="comboImage" name="comboImage" 
                      value="<%= combo.getComboImage() != null ? combo.getComboImage() : "" %>"
                      placeholder="https://example.com/combo.jpg (optional)">
            </div>

            <div class="form-group">
                <div class="checkbox-group">
                    <input type="checkbox" id="isAvailable" name="isAvailable" value="true" 
                          <%= combo.getIsAvailable() != null && combo.getIsAvailable() ? "checked" : "" %>>
                    <label for="isAvailable" style="margin: 0;">Available for sale</label>
                </div>
            </div>

            <div class="form-actions">
                <button type="submit" class="btn btn-warning">Update Combo</button>
                <a href="${pageContext.request.contextPath}/combo-management" class="btn btn-secondary">Cancel</a>
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
                document.getElementById('savingsAmount').textContent = savings.toLocaleString();
                document.getElementById('savingsDisplay').classList.add('show');
            } else {
                document.getElementById('savingsDisplay').classList.remove('show');
            }
        }

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

        // Show image preview if URL is provided
        document.getElementById('comboImage').addEventListener('blur', function() {
            const url = this.value.trim();
            if (url) {
                console.log('Combo Image URL:', url);
                // You can add image preview functionality here
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