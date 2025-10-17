<%-- 
    Document   : add-combo
    Created on : Oct 15, 2025, 6:37:59 AM
    Author     : minhd
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="entity.Food" %>
<%@ page import="java.util.List" %>
<%@ page import="java.math.BigDecimal" %>
<%
    List<Food> availableFood = (List<Food>) request.getAttribute("availableFood");
    String contextPath = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Add New Combo</title>
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
                max-width: 1200px;
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
            .btn-secondary {
                background-color: #95a5a6;
                color: white;
            }
            .btn-secondary:hover {
                background-color: #7f8c8d;
            }
            .price-container {
                display: flex;
                gap: 15px;
            }
            .price-container .form-group {
                flex: 1;
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
                <h1>Add New Combo</h1>
                <a href="combo-management" class="back-btn">← Back</a>
            </div>

            <%
                String success = request.getParameter("success");
                String error = request.getParameter("error");
            
                if (success != null) {
            %>
            <div class="alert alert-success">✅ Combo created successfully!</div>
            <%
                }
                if (error != null) {
            %>
            <div class="alert alert-error">❌ Error: <%= error %></div>
            <%
                }
            %>

            <form action="combo-management" method="POST" id="comboForm">
                <input type="hidden" name="action" value="create">

                <div class="form-group">
                    <label for="comboName">Combo Name *</label>
                    <input type="text" id="comboName" name="comboName" required placeholder="Enter combo name">
                </div>

                <div class="form-group">
                    <label for="description">Description</label>
                    <textarea id="description" name="description" placeholder="Enter description (optional)"></textarea>
                </div>

                <div class="price-container">
                    <div class="form-group">
                        <label for="totalPrice">Total Price (VND) *</label>
                        <input type="number" id="totalPrice" name="totalPrice" step="1000" min="0" required>
                    </div>
                    <div class="form-group">
                        <label for="discountPrice">Discount Price (VND)</label>
                        <input type="number" id="discountPrice" name="discountPrice" step="1000" min="0">
                    </div>
                </div>

                <div class="form-group checkbox-group">
                    <input type="checkbox" id="isAvailable" name="isAvailable" value="true" checked>
                    <label for="isAvailable">Available for sale</label>
                </div>

                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">Create Combo</button>
                    <a href="combo-management" class="btn btn-secondary">Cancel</a>
                </div>
            </form>
        </div>

        <script>
            // Form validation
            const comboForm = document.getElementById('comboForm');
            if (comboForm) {
                comboForm.addEventListener('submit', function (e) {
                    const comboName = document.getElementById('comboName').value.trim();
                    if (!comboName) {
                        alert('Please enter combo name');
                        e.preventDefault();
                        return;
                    }

                    const totalPrice = document.getElementById('totalPrice').value;
                    if (!totalPrice || parseInt(totalPrice) <= 0) {
                        alert('Please enter a valid total price');
                        e.preventDefault();
                        return;
                    }
                });
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