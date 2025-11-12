<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<div id="screening-room-management-content">
    <%
    // Lấy các tham số từ request để back đúng trang
    String locationFilter = request.getParameter("locationFilter");
    String cinemaFilter = request.getParameter("cinemaFilter");
    String roomType = request.getParameter("roomType");
    String status = request.getParameter("status");
    String search = request.getParameter("search");
    String page1 = request.getParameter("page");
    String mode = request.getParameter("mode"); // view hoặc edit
    
    // Tạo URL back với đầy đủ tham số
    StringBuilder backUrl = new StringBuilder("dashboard?section=screening-room-management");
    backUrl.append("&action=").append(mode != null ? mode : "edit");
    backUrl.append("&id=").append(request.getParameter("roomId"));
    
    if (locationFilter != null && !locationFilter.equals("none")) {
        backUrl.append("&locationFilter=").append(locationFilter);
    }
    if (cinemaFilter != null && !cinemaFilter.equals("none")) {
        backUrl.append("&cinemaFilter=").append(cinemaFilter);
    }
    if (roomType != null && !roomType.equals("all")) {
        backUrl.append("&roomType=").append(roomType);
    }
    if (status != null && !status.equals("all")) {
        backUrl.append("&status=").append(status);
    }
    if (search != null && !search.trim().isEmpty()) {
        backUrl.append("&search=").append(java.net.URLEncoder.encode(search, "UTF-8"));
    }
    if (page1 != null && !page1.equals("1")) {
        backUrl.append("&page=").append(page);
    }
    %>

    <!-- Header -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h2 class="mb-1 text-primary">
                <i class="bi bi-pencil-square me-2"></i>Edit Seat
            </h2>
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb">
                    <li class="breadcrumb-item"><a href="dashboard?section=screening-room-management" class="text-decoration-none">Screening Rooms</a></li>
                    <li class="breadcrumb-item">
                        <a href="dashboard?section=screening-room-management&action=edit&id=${viewRoom.roomID}" class="text-decoration-none">
                            ${viewRoom.roomName}
                        </a>
                    </li>
                    <li class="breadcrumb-item active text-dark">Edit Seat (${editSeat.seatRow}${editSeat.seatNumber})</li>
                </ol>
            </nav>
        </div>
        <a href="dashboard?section=screening-room-management&action=edit&id=${viewRoom.roomID}" 
           class="btn btn-outline-primary btn-sm">
            <i class="bi bi-arrow-left me-1"></i>Back to Room
        </a>
    </div>

    <div class="row">
        <!-- Seat Layout Preview - 65% width -->
        <div class="col-lg-8 col-xl-7">
            <div class="card shadow-sm border-0 h-100">
                <div class="card-header bg-light border-0 py-2">
                    <h6 class="card-title mb-0 text-dark">
                        <i class="bi bi-grid-3x3-gap me-2"></i>Seat Layout - ${viewRoom.roomName}
                    </h6>
                </div>
                <div class="card-body p-3">
                    <div class="text-center">
                        <div class="screen mb-4">
                            <div class="screen-bar">SCREEN</div>
                        </div>

                        <!-- Seat Legend với icon -->
                        <div class="seat-legend mb-3">
                            <div class="legend-item">
                                <div class="seat standard" style="width: 20px; height: 20px;"></div>
                                <span>💺 Standard</span>
                            </div>
                            <div class="legend-item">
                                <div class="seat vip" style="width: 20px; height: 20px;"></div>
                                <span>⭐ VIP</span>
                            </div>
                            <div class="legend-item">
                                <div class="seat couple" style="width: 40px; height: 20px;"></div>
                                <span>💑 Couple</span>
                            </div>
                            <div class="legend-item">
                                <div class="seat disabled" style="width: 20px; height: 20px;"></div>
                                <span>♿ Disabled</span>
                            </div>
                        </div>

                        <!-- UPDATED: Sử dụng cấu trúc seat-row giống screening-room-details.jsp -->
                        <c:if test="${not empty seats}">
                            <div class="seats-container">
                                <c:forEach var="row" items="${['A','B','C','D','E','F','G','H','I','J','K','L','M','N']}">
                                    <c:set var="rowSeats" value="${seats.stream().filter(s -> s.seatRow == row).toList()}"/>
                                    <c:if test="${not empty rowSeats}">
                                        <div class="seat-row" data-row="${row}">
                                            <c:forEach var="seat" items="${rowSeats}">
                                                <div class="seat ${seat.seatType.toLowerCase()} ${seat.status.toLowerCase()} 
                                                     <c:if test="${editSeat.seatID == seat.seatID}">selected-seat</c:if>"
                                                     data-bs-toggle="tooltip" 
                                                     title="Row ${seat.seatRow}, Number ${seat.seatNumber}&#10;Type: ${seat.seatType}&#10;Status: ${seat.status}">
                                                    <span class="seat-text">${seat.seatRow}${seat.seatNumber}</span>
                                                </div>
                                            </c:forEach>
                                        </div>
                                    </c:if>
                                </c:forEach>
                            </div>
                        </c:if>
                    </div>

                    <!-- Room Information - Compact -->
                    <div class="room-info mt-4 p-2 bg-light rounded">
                        <div class="row text-center g-2">
                            <div class="col-4">
                                <small class="text-muted d-block">Room Type</small>
                                <span class="fw-semibold">${viewRoom.roomType}</span>
                            </div>
                            <div class="col-4">
                                <small class="text-muted d-block">Total Seats</small>
                                <span class="fw-semibold">${not empty seats ? seats.size() : 0}</span>
                            </div>
                            <div class="col-4">
                                <small class="text-muted d-block">Status</small>
                                <span class="badge ${viewRoom.active ? 'bg-success' : 'bg-secondary'}">
                                    ${viewRoom.active ? 'Active' : 'Inactive'}
                                </span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Seat Edit Form - 35% width -->
        <div class="col-lg-4 col-xl-5">
            <div class="card shadow-sm border-0 h-100">
                <div class="card-header bg-primary text-white border-0 py-2">
                    <h6 class="card-title mb-0">
                        <i class="bi bi-pencil-square me-2"></i>Edit: ${editSeat.seatRow}${editSeat.seatNumber}
                    </h6>
                </div>
                <div class="card-body p-3">
                    <!-- Current Seat Information (Readonly) -->
                    <div class="current-seat-info mb-3 p-2 bg-light rounded">
                        <small class="text-muted d-block mb-1">
                            <i class="bi bi-geo-alt me-1"></i>Seat Position
                        </small>
                        <div class="row g-2">
                            <div class="col-6">
                                <input type="text" class="form-control form-control-sm bg-white" 
                                       value="Row ${editSeat.seatRow}" readonly>
                            </div>
                            <div class="col-6">
                                <input type="text" class="form-control form-control-sm bg-white" 
                                       value="Number ${editSeat.seatNumber}" readonly>
                            </div>
                        </div>
                    </div>

                    <!-- Editable Fields -->
                    <form action="dashboard" method="POST">
                        <input type="hidden" name="section" value="screening-room-management">
                        <input type="hidden" name="action" value="updateSeat">
                        <input type="hidden" name="seatId" value="${editSeat.seatID}">
                        <input type="hidden" name="roomId" value="${viewRoom.roomID}">
                        <input type="hidden" name="mode" value="${param.mode}">

                        <!-- Thêm các hidden fields để giữ filters -->
                        <input type="hidden" name="locationFilter" value="${param.locationFilter}">
                        <input type="hidden" name="cinemaFilter" value="${param.cinemaFilter}">
                        <input type="hidden" name="roomType" value="${param.roomType}">
                        <input type="hidden" name="status" value="${param.status}">
                        <input type="hidden" name="search" value="${param.search}">
                        <input type="hidden" name="page" value="${param.page}">
                        <!-- Seat Type Selection -->
                        <div class="mb-3">
                            <label class="form-label small fw-semibold mb-1">
                                <i class="bi bi-tag me-1"></i>Seat Type
                            </label>
                            <select class="form-select form-select-sm" name="seatType" required>
                                <option value="Standard" ${editSeat.seatType == 'Standard' ? 'selected' : ''}>
                                    🪑 Standard
                                </option>
                                <option value="VIP" ${editSeat.seatType == 'VIP' ? 'selected' : ''}>
                                    ⭐ VIP
                                </option>
                                <option value="Couple" ${editSeat.seatType == 'Couple' ? 'selected' : ''}>
                                    💑 Couple
                                </option>
                                <option value="Disabled" ${editSeat.seatType == 'Disabled' ? 'selected' : ''}>
                                    ♿ Disabled
                                </option>
                            </select>
                        </div>

                        <!-- Status Selection -->
                        <div class="mb-3">
                            <label class="form-label small fw-semibold mb-1">
                                <i class="bi bi-circle-fill me-1"></i>Status
                            </label>
                            <select class="form-select form-select-sm" name="status" required>
                                <option value="Available" ${editSeat.status == 'Available' ? 'selected' : ''}>
                                    🟢 Available
                                </option>
                                <option value="Maintenance" ${editSeat.status == 'Maintenance' ? 'selected' : ''}>
                                    🟠 Maintenance
                                </option>
                                <option value="Unavailable" ${editSeat.status == 'Unavailable' ? 'selected' : ''}>
                                    🔴 Unavailable
                                </option>
                            </select>
                        </div>

                        <!-- Warning message for booked seats -->
                        <c:if test="${!editSeat.canBeModified()}">
                            <div class="alert alert-warning py-2 mt-3">
                                <small>
                                    <i class="bi bi-exclamation-triangle me-1"></i>
                                    This seat has booking history and cannot be modified
                                </small>
                            </div>
                        </c:if>

                        <!-- Action Buttons -->
                        <div class="d-grid gap-2 d-md-flex justify-content-md-end mt-4 pt-3 border-top">
                            <a href="<%= backUrl.toString() %>" 
                               class="btn btn-outline-secondary btn-sm me-md-1 px-3">
                                <i class="bi bi-x-circle me-1"></i>Cancel
                            </a>
                            <button type="submit" class="btn btn-primary btn-sm px-3" 
                                    ${!editSeat.canBeModified() ? 'disabled' : ''}>
                                <i class="bi bi-check-lg me-1"></i>Update Seat
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<style>
    /* Screen Styles - Giống screening-room-details.jsp */
    .screen {
        background: linear-gradient(180deg, #333 0%, #555 100%);
        height: 20px;
        border-radius: 10px;
        margin: 0 20px;
        position: relative;
    }
    .screen-bar {
        color: white;
        font-size: 12px;
        font-weight: bold;
        position: absolute;
        top: -25px;
        left: 0;
        right: 0;
        text-align: center;
    }

    /* Seat Container - Giống screening-room-details.jsp */
    .seats-container {
        display: flex;
        flex-direction: column;
        gap: 8px;
        padding: 15px;
        align-items: center;
    }

    .seat-row {
        display: flex;
        gap: 6px;
        justify-content: center;
        align-items: center;
    }

    /* Base seat style - Giống screening-room-details.jsp */
    .seat {
        border-radius: 5px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 10px;
        font-weight: bold;
        cursor: default;
        transition: all 0.3s ease;
        border: 1px solid #dee2e6;
        color: white;
        position: relative;
        overflow: hidden;
    }

    /* Standard seat size */
    .seat.standard {
        width: 35px;
        height: 35px;
    }

    /* VIP seat size */
    .seat.vip {
        width: 35px;
        height: 35px;
    }

    /* Disabled seat size */
    .seat.disabled {
        width: 35px;
        height: 35px;
    }

    /* COUPLE seat - DOUBLE WIDTH - Giống screening-room-details.jsp */
    .seat.couple {
        width: 70px; /* Double width */
        height: 35px;
        background: linear-gradient(135deg, #e83e8c, #d91a72);
        position: relative;
    }

    /* Seat type colors - Giống screening-room-details.jsp */
    .seat.standard {
        background: linear-gradient(135deg, #6c757d, #5a6268);
    }
    .seat.vip {
        background: linear-gradient(135deg, #ffc107, #e0a800);
        color: black;
    }
    .seat.couple {
        background: linear-gradient(135deg, #e83e8c, #d91a72);
    }
    .seat.disabled {
        background: linear-gradient(135deg, #17a2b8, #138496);
    }

    /* Seat status styles - Giống screening-room-details.jsp */
    .seat.available {
        opacity: 1;
    }
    .seat.maintenance {
        background: linear-gradient(135deg, #fd7e14, #e55a00) !important;
    }
    .seat.unavailable {
        opacity: 0.5;
    }

    /* Icons for seats - Giống screening-room-details.jsp */
    .seat.standard::before {
        content: "💺";
        font-size: 12px;
        margin-right: 2px;
    }

    .seat.vip::before {
        content: "⭐";
        font-size: 12px;
        margin-right: 2px;
    }

    .seat.couple::before {
        content: "💑";
        font-size: 14px;
        margin-right: 4px;
    }

    .seat.disabled::before {
        content: "♿";
        font-size: 12px;
        margin-right: 2px;
    }

    /* Hide text for very small seats, show only icon */
    .seat .seat-text {
        font-size: 9px;
    }

    /* For couple seats, we can show both icon and text nicely */
    .seat.couple .seat-text {
        font-size: 10px;
    }

    /* Seat legend - Giống screening-room-details.jsp */
    .seat-legend {
        display: flex;
        justify-content: center;
        flex-wrap: wrap;
        gap: 15px;
        margin-top: 15px;
        padding: 10px;
        background-color: #f8f9fa;
        border-radius: 5px;
    }
    .legend-item {
        display: flex;
        align-items: center;
        gap: 5px;
        font-size: 12px;
    }
    .legend-color {
        width: 15px;
        height: 15px;
        border-radius: 3px;
    }

    /* NEW: Special styling for couple seats to make them stand out - Giống screening-room-details.jsp */
    .seat.couple {
        border: 2px solid #c2185b;
        box-shadow: 0 2px 4px rgba(232, 62, 140, 0.3);
    }

    .seat.couple::after {
        content: "";
        position: absolute;
        top: 2px;
        left: 2px;
        right: 2px;
        bottom: 2px;
        border: 1px solid rgba(255, 255, 255, 0.3);
        border-radius: 3px;
        pointer-events: none;
    }

    /* Selected Seat Highlight - Giữ lại từ file cũ */
    .selected-seat {
        border: 3px solid #dc3545 !important;
        box-shadow: 0 0 15px rgba(220, 53, 69, 0.6) !important;
        transform: scale(1.1);
        z-index: 10;
        position: relative;
        animation: pulse 2s infinite;
    }

    @keyframes pulse {
        0% {
            box-shadow: 0 0 15px rgba(220, 53, 69, 0.6);
        }
        50% {
            box-shadow: 0 0 20px rgba(220, 53, 69, 0.8);
        }
        100% {
            box-shadow: 0 0 15px rgba(220, 53, 69, 0.6);
        }
    }

    /* Responsive design - Giống screening-room-details.jsp */
    @media (max-width: 768px) {
        .seat.standard, .seat.vip, .seat.disabled {
            width: 30px;
            height: 30px;
            font-size: 9px;
        }
        .seat.couple {
            width: 60px;
            height: 30px;
        }
        .seats-container {
            gap: 6px;
            padding: 10px;
        }
        .seat-row {
            gap: 4px;
        }
        .seat::before {
            font-size: 10px;
            margin-right: 1px;
        }
        .seat.couple::before {
            font-size: 12px;
            margin-right: 2px;
        }
    }

    /* Card Styles - More compact */
    .card {
        border-radius: 8px;
        overflow: hidden;
    }

    .card-header {
        padding: 0.5rem 1rem;
        font-weight: 600;
    }

    /* Form Styles - Smaller */
    .form-select-sm {
        padding: 0.375rem 0.75rem;
        font-size: 0.875rem;
        border-radius: 6px;
    }

    .form-control-sm {
        font-size: 0.875rem;
        padding: 0.375rem 0.75rem;
    }

    /* Button Styles - Smaller */
    .btn-sm {
        padding: 0.375rem 0.75rem;
        font-size: 0.875rem;
        border-radius: 6px;
    }

    /* Room Info Box - Compact */
    .room-info {
        border-left: 3px solid #0d6efd;
        font-size: 0.875rem;
    }

    .current-seat-info {
        border-left: 3px solid #6c757d;
        font-size: 0.875rem;
    }

    /* Alert Styles */
    .alert-warning {
        font-size: 0.875rem;
        padding: 0.5rem 0.75rem;
    }

    /* Text sizes for compact layout */
    .small {
        font-size: 0.875rem;
    }

    .card-title {
        font-size: 1rem;
    }

    /* Ensure proper spacing */
    .mb-1 {
        margin-bottom: 0.25rem !important;
    }

    .mb-2 {
        margin-bottom: 0.5rem !important;
    }

    .mb-3 {
        margin-bottom: 1rem !important;
    }

    /* Compact spacing for form elements */
    .form-label {
        margin-bottom: 0.25rem;
    }
</style>

<script>
// Initialize tooltips
    document.addEventListener('DOMContentLoaded', function () {
        var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
        var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
            return new bootstrap.Tooltip(tooltipTriggerEl);
        });
    });

// Form validation
    document.addEventListener('DOMContentLoaded', function () {
        const form = document.querySelector('form');
        if (form) {
            form.addEventListener('submit', function (e) {
                const seatType = this.querySelector('select[name="seatType"]');
                const status = this.querySelector('select[name="status"]');

                if (!seatType.value || !status.value) {
                    e.preventDefault();
                    alert('Please select both seat type and status');
                    return;
                }
            });
        }
    });

// Add some interactive effects
    document.querySelectorAll('.form-select').forEach(select => {
        select.addEventListener('change', function () {
            this.style.borderColor = '#0d6efd';
            this.style.boxShadow = '0 0 0 0.2rem rgba(13, 110, 253, 0.25)';
        });
    });
</script>