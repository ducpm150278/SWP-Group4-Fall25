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
                color: #333;
            }

            .container {
                max-width: 800px;
                margin: 0 auto;
                background: white;
                padding: 30px;
                border-radius: 10px;
                box-shadow: 0 2px 20px rgba(0,0,0,0.1);
            }

            .header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 30px;
                padding-bottom: 20px;
                border-bottom: 2px solid #3498db;
            }

            .header h1 {
                color: #2c3e50;
                font-size: 2rem;
                font-weight: 600;
            }

            .back-btn {
                padding: 10px 20px;
                background-color: #95a5a6;
                color: white;
                text-decoration: none;
                border-radius: 6px;
                transition: all 0.3s;
                font-weight: 500;
                display: flex;
                align-items: center;
                gap: 8px;
            }

            .back-btn:hover {
                background-color: #7f8c8d;
                transform: translateY(-2px);
                box-shadow: 0 4px 8px rgba(0,0,0,0.1);
            }

            .form-group {
                margin-bottom: 25px;
            }

            label {
                display: block;
                margin-bottom: 8px;
                font-weight: 600;
                color: #2c3e50;
                font-size: 0.95rem;
            }

            .required::after {
                content: " *";
                color: #e74c3c;
            }

            input, select, textarea {
                width: 100%;
                padding: 12px 15px;
                border: 1px solid #ddd;
                border-radius: 6px;
                font-size: 14px;
                transition: all 0.3s;
                background-color: #fff;
            }

            input:focus, select:focus, textarea:focus {
                outline: none;
                border-color: #3498db;
                box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.1);
            }

            textarea {
                resize: vertical;
                min-height: 100px;
                line-height: 1.5;
            }

            .checkbox-group {
                display: flex;
                align-items: center;
                gap: 12px;
                padding: 15px;
                background-color: #f8f9fa;
                border-radius: 6px;
                border: 1px solid #e9ecef;
            }

            .checkbox-group input {
                width: 18px;
                height: 18px;
                cursor: pointer;
            }

            .checkbox-group label {
                margin-bottom: 0;
                cursor: pointer;
                color: #2c3e50;
            }

            .price-container {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 20px;
            }

            @media (max-width: 768px) {
                .price-container {
                    grid-template-columns: 1fr;
                }
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
                font-weight: 500;
            }

            .price-input input {
                padding-right: 60px;
            }

            .form-actions {
                display: flex;
                gap: 15px;
                margin-top: 40px;
                padding-top: 20px;
                border-top: 1px solid #e9ecef;
            }

            .btn {
                padding: 14px 30px;
                border: none;
                border-radius: 6px;
                cursor: pointer;
                font-size: 14px;
                font-weight: 600;
                transition: all 0.3s;
                text-decoration: none;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                gap: 8px;
                min-width: 120px;
            }

            .btn-primary {
                background-color: #3498db;
                color: white;
            }

            .btn-primary:hover {
                background-color: #2980b9;
                transform: translateY(-2px);
                box-shadow: 0 4px 12px rgba(52, 152, 219, 0.3);
            }

            .btn-secondary {
                background-color: #95a5a6;
                color: white;
            }

            .btn-secondary:hover {
                background-color: #7f8c8d;
                transform: translateY(-2px);
                box-shadow: 0 4px 12px rgba(149, 165, 166, 0.3);
            }

            .alert {
                padding: 15px 20px;
                border-radius: 6px;
                margin-bottom: 25px;
                border: 1px solid transparent;
                font-weight: 500;
            }

            .alert-success {
                background-color: #d4edda;
                color: #155724;
                border-color: #c3e6cb;
            }

            .alert-error {
                background-color: #f8d7da;
                color: #721c24;
                border-color: #f5c6cb;
            }

            .form-help {
                font-size: 0.85rem;
                color: #6c757d;
                margin-top: 5px;
                font-style: italic;
            }

            .image-url-group {
                margin-bottom: 25px;
            }

            .image-preview {
                margin-top: 10px;
                display: none;
            }

            .image-preview img {
                max-width: 200px;
                max-height: 150px;
                border-radius: 6px;
                border: 2px solid #e9ecef;
                box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            }

            .image-preview-placeholder {
                width: 200px;
                height: 150px;
                background: linear-gradient(135deg, #f5f5f5 0%, #e8e8e8 100%);
                border: 2px dashed #ddd;
                border-radius: 6px;
                display: flex;
                align-items: center;
                justify-content: center;
                color: #999;
                font-size: 0.9rem;
                text-align: center;
                padding: 20px;
            }

            /* Loading animation */
            .loading {
                display: inline-block;
                width: 20px;
                height: 20px;
                border: 3px solid #f3f3f3;
                border-top: 3px solid #3498db;
                border-radius: 50%;
                animation: spin 1s linear infinite;
            }

            @keyframes spin {
                0% {
                    transform: rotate(0deg);
                }
                100% {
                    transform: rotate(360deg);
                }
            }

            /* Validation styles */
            input:invalid, select:invalid, textarea:invalid {
                border-color: #e74c3c;
            }

            input:valid, select:valid, textarea:valid {
                border-color: #27ae60;
            }

            .validation-message {
                color: #e74c3c;
                font-size: 0.85rem;
                margin-top: 5px;
                display: none;
            }

            input:invalid + .validation-message {
                display: block;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>Add New Combo</h1>
            </div>

            <%
                String success = request.getParameter("success");
                String error = request.getParameter("error");
            
                if (success != null) {
            %>
            <div class="alert alert-success">
                ✅ Combo created successfully!
            </div>
            <%
                }
                if (error != null) {
            %>
            <div class="alert alert-error">
                ❌ Error: <%= error %>
            </div>
            <%
                }
            %>

            <form action="combo-management" method="POST" id="comboForm">
                <input type="hidden" name="action" value="create">

                <div class="form-group">
                    <label for="comboName" class="required">Combo Name</label>
                    <input type="text" id="comboName" name="comboName" required 
                           placeholder="Enter combo name (e.g., Family Combo, Couple Combo)"
                           maxlength="100">
                    <div class="validation-message">Please enter a combo name</div>
                </div>

                <div class="form-group">
                    <label for="description">Description</label>
                    <textarea id="description" name="description" 
                              placeholder="Enter description about this combo (optional)"
                              maxlength="500"></textarea>
                    <div class="form-help">Maximum 500 characters</div>
                </div>

                <div class="form-group image-url-group">
                    <label for="comboImage">Image URL</label>
                    <input type="url" id="comboImage" name="comboImage" 
                           placeholder="https://example.com/image.jpg (optional)"
                           pattern="https?://.+" 
                           onblur="previewImage()">
                    <div class="form-help">Enter a valid image URL (http:// or https://)</div>
                    <div class="image-preview" id="imagePreview">
                        <div class="image-preview-placeholder" id="imagePlaceholder">
                            Image preview will appear here
                        </div>
                        <img id="previewImage" style="display: none;" alt="Combo image preview">
                    </div>
                </div>

                <div class="price-container">
                    <div class="form-group price-input">
                        <label for="totalPrice" class="required">Total Price</label>
                        <input type="number" id="totalPrice" name="totalPrice" 
                               step="1000" min="1000" required 
                               placeholder="0">
                        <div class="validation-message">Please enter a valid price (minimum 1,000 VND)</div>
                    </div>

                    <div class="form-group price-input">
                        <label for="discountPrice">Discount Price</label>
                        <input type="number" id="discountPrice" name="discountPrice" 
                               step="1000" min="0" 
                               placeholder="0 (optional)"
                               oninput="validateDiscountPrice()">
                        <div class="form-help">Leave empty if no discount</div>
                    </div>
                </div>

                <div class="form-group">
                    <div class="checkbox-group">
                        <input type="checkbox" id="isAvailable" name="isAvailable" value="true" checked>
                        <label for="isAvailable">Available for sale</label>
                    </div>
                    <div class="form-help">Uncheck to make this combo unavailable</div>
                </div>

                <div class="form-actions">
                    <button type="submit" class="btn btn-primary" id="submitBtn">
                        <span id="submitText">Create Combo</span>
                        <span id="submitLoading" class="loading" style="display: none;"></span>
                    </button>
                    <a href="combo-management" class="btn btn-secondary">Cancel</a>
                </div>
            </form>
        </div>

        <script>
            // Form validation and enhancement
            document.addEventListener('DOMContentLoaded', function () {
                const form = document.getElementById('comboForm');
                const submitBtn = document.getElementById('submitBtn');
                const submitText = document.getElementById('submitText');
                const submitLoading = document.getElementById('submitLoading');

                // Price validation
                const totalPriceInput = document.getElementById('totalPrice');
                const discountPriceInput = document.getElementById('discountPrice');

                // Form submission handler
                form.addEventListener('submit', function (e) {
                    const comboName = document.getElementById('comboName').value.trim();
                    const totalPrice = totalPriceInput.value;

                    if (!comboName) {
                        e.preventDefault();
                        showError('Please enter combo name');
                        return;
                    }

                    if (!totalPrice || parseInt(totalPrice) < 1000) {
                        e.preventDefault();
                        showError('Please enter a valid total price (minimum 1,000 VND)');
                        return;
                    }

                    // Validate discount price
                    if (discountPriceInput.value) {
                        const discountPrice = parseInt(discountPriceInput.value);
                        const total = parseInt(totalPrice);

                        if (discountPrice >= total) {
                            e.preventDefault();
                            showError('Discount price must be less than total price');
                            return;
                        }
                    }

                    // Show loading state
                    submitText.textContent = 'Creating...';
                    submitLoading.style.display = 'inline-block';
                    submitBtn.disabled = true;
                });

                // Real-time validation for discount price
                if (discountPriceInput) {
                    discountPriceInput.addEventListener('input', validateDiscountPrice);
                }

                // Auto-format price inputs
                [totalPriceInput, discountPriceInput].forEach(input => {
                    input.addEventListener('blur', function () {
                        if (this.value) {
                            this.value = parseInt(this.value).toString();
                        }
                    });
                });
            });

            function validateDiscountPrice() {
                const discountInput = document.getElementById('discountPrice');
                const totalInput = document.getElementById('totalPrice');
                const discountPrice = parseInt(discountInput.value);
                const totalPrice = parseInt(totalInput.value);

                if (discountInput.value && totalInput.value) {
                    if (discountPrice >= totalPrice) {
                        discountInput.style.borderColor = '#e74c3c';
                        discountInput.style.boxShadow = '0 0 0 3px rgba(231, 76, 60, 0.1)';
                    } else {
                        discountInput.style.borderColor = '#27ae60';
                        discountInput.style.boxShadow = '0 0 0 3px rgba(39, 174, 96, 0.1)';
                    }
                } else {
                    discountInput.style.borderColor = '';
                    discountInput.style.boxShadow = '';
                }
            }

            function previewImage() {
                const imageUrl = document.getElementById('comboImage').value;
                const preview = document.getElementById('previewImage');
                const placeholder = document.getElementById('imagePlaceholder');
                const imagePreview = document.getElementById('imagePreview');

                if (imageUrl) {
                    // Validate URL format
                    if (!imageUrl.match(/^https?:\/\/.+\..+$/)) {
                        placeholder.innerHTML = 'Invalid URL format';
                        placeholder.style.display = 'flex';
                        preview.style.display = 'none';
                        imagePreview.style.display = 'block';
                        return;
                    }

                    preview.src = imageUrl;
                    preview.style.display = 'block';
                    placeholder.style.display = 'none';
                    imagePreview.style.display = 'block';

                    // Handle image load error
                    preview.onerror = function () {
                        preview.style.display = 'none';
                        placeholder.innerHTML = 'Failed to load image<br><small>Please check the URL</small>';
                        placeholder.style.display = 'flex';
                    };

                    // Handle image load success
                    preview.onload = function () {
                        preview.style.display = 'block';
                        placeholder.style.display = 'none';
                    };
                } else {
                    imagePreview.style.display = 'none';
                }
            }

            function showError(message) {
                alert('❌ ' + message);
            }

            // Input formatting
            function formatPrice(input) {
                if (input.value) {
                    // Remove any non-numeric characters
                    let value = input.value.replace(/[^\d]/g, '');

                    // Format with commas
                    if (value.length > 0) {
                        value = parseInt(value).toLocaleString('vi-VN');
                    }

                    input.value = value;
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