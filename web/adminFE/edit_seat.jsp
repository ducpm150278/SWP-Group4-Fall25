<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<div id="screening-room-management-content">
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
                        
                        <c:if test="${not empty seats}">
                            <div class="seats-container">
                                <c:forEach var="seat" items="${seats}">
                                    <div class="seat ${seat.seatType.toLowerCase()} ${seat.status.toLowerCase()} 
                                         <c:if test="${editSeat.seatID == seat.seatID}">selected-seat</c:if>"
                                         data-bs-toggle="tooltip" 
                                         title="Row ${seat.seatRow}, Number ${seat.seatNumber} - ${seat.seatType} - ${seat.status}">
                                        ${seat.seatRow}${seat.seatNumber}
                                    </div>
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
                        <input type="hidden" name="mode" value="edit">
                        <input type="hidden" name="seatRow" value="${editSeat.seatRow}">
                        <input type="hidden" name="seatNumber" value="${editSeat.seatNumber}">

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

                        <!-- Action Buttons -->
                        <div class="d-grid gap-2 d-md-flex justify-content-md-end mt-4 pt-3 border-top">
                            <a href="dashboard?section=screening-room-management&action=edit&id=${viewRoom.roomID}" 
                               class="btn btn-outline-secondary btn-sm me-md-1 px-3">
                                <i class="bi bi-x-circle me-1"></i>Cancel
                            </a>
                            <button type="submit" class="btn btn-primary btn-sm px-3">
                                <i class="bi bi-check-lg me-1"></i>Update
                            </button>
                            <a href="dashboard?section=screening-room-management&action=deleteSeat&seatId=${editSeat.seatID}&roomId=${viewRoom.roomID}&mode=edit" 
                               class="btn btn-danger btn-sm ms-md-1 px-3" 
                               onclick="return confirm('Delete seat ${editSeat.seatRow}${editSeat.seatNumber}?')">
                                <i class="bi bi-trash me-1"></i>Delete
                            </a>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<style>
/* Screen Styles */
.screen {
    background: linear-gradient(180deg, #2c3e50 0%, #34495e 100%);
    height: 20px;
    border-radius: 8px;
    margin: 0 20px;
    position: relative;
    box-shadow: 0 2px 4px rgba(0,0,0,0.2);
}
.screen-bar {
    color: #ecf0f1;
    font-size: 12px;
    font-weight: bold;
    position: absolute;
    top: -22px;
    left: 0;
    right: 0;
    text-align: center;
}

/* Seat Container - Optimized for full layout display */
.seats-container {
    display: grid;
    grid-template-columns: repeat(12, 1fr);
    gap: 6px;
    padding: 15px;
    justify-items: center;
    max-width: 100%;
    overflow: visible;
}

/* Base Seat Styles - Slightly smaller */
.seat {
    width: 32px;
    height: 32px;
    border-radius: 6px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 10px;
    font-weight: bold;
    border: 2px solid transparent;
    transition: all 0.3s ease;
    cursor: default;
}

/* Seat Type Colors */
.seat.standard { 
    background: linear-gradient(135deg, #6c757d, #5a6268);
    color: white;
    border-color: #495057;
}
.seat.vip { 
    background: linear-gradient(135deg, #ffc107, #e0a800);
    color: #000;
    border-color: #d39e00;
}
.seat.couple { 
    background: linear-gradient(135deg, #e83e8c, #d91a72);
    color: white;
    border-color: #c2185b;
}
.seat.disabled { 
    background: linear-gradient(135deg, #17a2b8, #138496);
    color: white;
    border-color: #117a8b;
}

/* Status Indicators */
.seat.available { 
    opacity: 1;
}
.seat.maintenance { 
    background: linear-gradient(135deg, #fd7e14, #e55a00) !important;
    color: white !important;
    border-color: #dc6500 !important;
}
.seat.unavailable { 
    background: linear-gradient(135deg, #6c757d, #5a6268) !important;
    opacity: 0.4;
    color: white !important;
}

/* Selected Seat Highlight */
.selected-seat {
    border: 3px solid #dc3545 !important;
    box-shadow: 0 0 15px rgba(220, 53, 69, 0.6) !important;
    transform: scale(1.1);
    z-index: 10;
    position: relative;
    animation: pulse 2s infinite;
}

@keyframes pulse {
    0% { box-shadow: 0 0 15px rgba(220, 53, 69, 0.6); }
    50% { box-shadow: 0 0 20px rgba(220, 53, 69, 0.8); }
    100% { box-shadow: 0 0 15px rgba(220, 53, 69, 0.6); }
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

/* Responsive Design */
@media (max-width: 992px) {
    .seats-container {
        grid-template-columns: repeat(10, 1fr);
        gap: 5px;
        padding: 10px;
    }
    
    .seat {
        width: 28px;
        height: 28px;
        font-size: 9px;
    }
}

@media (max-width: 768px) {
    .seats-container {
        grid-template-columns: repeat(8, 1fr);
    }
    
    .seat {
        width: 26px;
        height: 26px;
        font-size: 8px;
    }
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
document.addEventListener('DOMContentLoaded', function() {
    var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
    var tooltipList = tooltipTriggerList.map(function(tooltipTriggerEl) {
        return new bootstrap.Tooltip(tooltipTriggerEl);
    });
});

// Add some interactive effects
document.querySelectorAll('.form-select').forEach(select => {
    select.addEventListener('change', function() {
        this.style.borderColor = '#0d6efd';
        this.style.boxShadow = '0 0 0 0.2rem rgba(13, 110, 253, 0.25)';
    });
});
</script>