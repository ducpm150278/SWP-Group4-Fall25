<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<div id="screening-room-management-content">
    <!-- Header -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h2 class="mb-1">
                <c:choose>
                    <c:when test="${param.action == 'view'}">Room Details</c:when>
                    <c:when test="${param.action == 'edit'}">Edit Room</c:when>
                    <c:when test="${param.action == 'create'}">Create New Room</c:when>
                </c:choose>
            </h2>
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb">
                    <li class="breadcrumb-item"><a href="dashboard?section=screening-room-management">Screening Rooms</a></li>
                        <c:if test="${param.action != 'create'}">
                        <li class="breadcrumb-item">
                            <a href="dashboard?section=screening-room-management&action=edit&id=${viewRoom.roomID}">
                                ${viewRoom.roomName}
                            </a>
                        </li>
                    </c:if>
                    <li class="breadcrumb-item active">
                        <c:choose>
                            <c:when test="${param.action == 'view'}">View</c:when>
                            <c:when test="${param.action == 'edit'}">Edit</c:when>
                            <c:when test="${param.action == 'create'}">Create</c:when>
                        </c:choose>
                    </li>
                </ol>
            </nav>
        </div>
        <a href="dashboard?section=screening-room-management" class="btn btn-outline-secondary">
            <i class="bi bi-arrow-left"></i> Back to List
        </a>
    </div>

    <div class="row">
        <!-- Basic Information Form -->
        <div class="col-md-6">
            <div class="card">
                <div class="card-header">
                    <h5 class="card-title mb-0">
                        <i class="bi bi-info-circle"></i> Basic Information
                    </h5>
                </div>
                <div class="card-body">
                    <form id="roomForm" action="dashboard" method="POST">
                        <input type="hidden" name="action" value="${param.action == 'create' ? 'create' : 'update'}">
                        <input type="hidden" name="section" value="screening-room-management">
                        <c:if test="${param.action != 'create'}">
                            <input type="hidden" name="roomId" value="${viewRoom.roomID}">
                        </c:if>

                        <div class="mb-3">
                            <label class="form-label">Cinema</label>
                            <c:choose>
                                <c:when test="${param.action == 'create'}">
                                    <input type="hidden" name="cinemaId" value="${param.cinemaId}">
                                    <input type="text" class="form-control" value="${cinema.cinemaName} - ${cinema.location}" readonly>
                                </c:when>
                                <c:otherwise>
                                    <input type="text" class="form-control" value="${viewRoom.cinema.cinemaName} - ${viewRoom.cinema.location}" readonly>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Room Name <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" name="roomName" 
                                   value="${viewRoom.roomName}" 
                                   ${param.action == 'view' ? 'readonly' : ''} 
                                   required 
                                   maxlength="50"
                                   placeholder="Enter room name">
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Room Type <span class="text-danger">*</span></label>
                            <c:choose>
                                <c:when test="${param.action == 'view'}">
                                    <input type="text" class="form-control" value="${viewRoom.roomType}" readonly>
                                </c:when>
                                <c:otherwise>
                                    <select class="form-select" name="roomType" required>
                                        <option value="">Select Room Type</option>
                                        <option value="Standard" ${viewRoom.roomType == 'Standard' ? 'selected' : ''}>Standard</option>
                                        <option value="IMAX" ${viewRoom.roomType == 'IMAX' ? 'selected' : ''}>IMAX</option>
                                        <option value="3D" ${viewRoom.roomType == '3D' ? 'selected' : ''}>3D</option>
                                        <option value="VIP" ${viewRoom.roomType == 'VIP' ? 'selected' : ''}>VIP</option>
                                    </select>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Seat Capacity <span class="text-danger">*</span></label>
                            <input type="number" class="form-control" name="seatCapacity" 
                                   value="${viewRoom.seatCapacity}" 
                                   ${param.action == 'view' ? 'readonly' : ''} 
                                   required 
                                   min="1" 
                                   max="500"
                                   placeholder="Enter seat capacity">
                            <c:if test="${param.action != 'view'}">
                                <div class="form-text">
                                    Actual capacity will be updated after generating seats
                                </div>
                            </c:if>
                        </div>

                        <c:if test="${param.action != 'create'}">
                            <div class="mb-3">
                                <label class="form-label">Status</label>
                                <c:choose>
                                    <c:when test="${param.action == 'view'}">
                                        <input type="text" class="form-control" 
                                               value="${viewRoom.active ? 'Active' : 'Inactive'}" readonly>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="form-check form-switch">
                                            <input class="form-check-input" type="checkbox" name="isActive" 
                                                   id="isActiveSwitch" ${viewRoom.active ? 'checked' : ''}>
                                            <label class="form-check-label" for="isActiveSwitch">
                                                Active Room
                                            </label>
                                        </div>
                                        <div class="form-text">
                                            Inactive rooms cannot be used for screenings
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </c:if>

                        <c:if test="${param.action != 'view'}">
                            <div class="d-grid gap-2">
                                <button type="submit" class="btn btn-primary">
                                    <c:choose>
                                        <c:when test="${param.action == 'create'}">
                                            <i class="bi bi-plus-circle"></i> Create Room
                                        </c:when>
                                        <c:otherwise>
                                            <i class="bi bi-check-lg"></i> Update Room
                                        </c:otherwise>
                                    </c:choose>
                                </button>
                            </div>
                        </c:if>
                    </form>

                    <!-- Delete button for edit mode -->
                    <c:if test="${param.action == 'edit'}">
                        <div class="mt-3 pt-3 border-top">
                            <button class="btn btn-outline-danger w-100" 
                                    onclick="showDeleteModal(${viewRoom.roomID}, '${viewRoom.roomName}')">
                                <i class="bi bi-trash"></i> Delete Room
                            </button>
                        </div>
                    </c:if>
                </div>
            </div>
        </div>

        <!-- Seat Layout Section -->
        <div class="col-md-6">
            <div class="card">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <h5 class="card-title mb-0">
                        <i class="bi bi-grid-3x3-gap"></i> Seat Layout
                        <c:if test="${not empty seats}">
                            <span class="badge bg-primary ms-2">${seats.size()} seats</span>
                        </c:if>
                    </h5>
                    <div>
                        <c:if test="${param.action == 'edit' && (empty seats || seats.size() == 0)}">
                            <a href="dashboard?section=screening-room-management&action=generateSeats&roomId=${viewRoom.roomID}" 
                               class="btn btn-primary btn-sm" 
                               onclick="return confirm('Generate default seat layout? This will create seats based on room type.')">
                                <i class="bi bi-magic"></i> Generate Seats
                            </a>
                        </c:if>
                        <c:if test="${param.action == 'edit' && not empty seats && seats.size() > 0}">
                            <a href="dashboard?section=screening-room-management&action=generateSeats&roomId=${viewRoom.roomID}" 
                               class="btn btn-outline-warning btn-sm" 
                               onclick="return confirm('WARNING: This will replace all existing seats and delete any booking history. Continue?')">
                                <i class="bi bi-arrow-repeat"></i> Regenerate Seats
                            </a>
                        </c:if>
                    </div>
                </div>
                <div class="card-body">
                    <c:choose>
                        <c:when test="${param.action == 'create'}">
                            <div class="text-center py-4">
                                <i class="bi bi-grid-3x3-gap display-4 text-muted"></i>
                                <p class="mt-3 text-muted">Seat layout configuration will be available after creating the room</p>
                            </div>
                        </c:when>
                        <c:when test="${empty viewRoom}">
                            <div class="alert alert-warning">
                                <i class="bi bi-exclamation-triangle"></i> Room information not available.
                            </div>
                        </c:when>
                        <c:otherwise>
                            <!-- Seat layout visualization -->
                            <div id="seatLayout" class="text-center">
                                <div class="screen mb-4">
                                    <div class="screen-bar">SCREEN</div>
                                </div>

                                <c:choose>
                                    <c:when test="${not empty seats && seats.size() > 0}">
                                        <!-- Seat Legend -->
                                        <div class="seat-legend mb-3">
                                            <div class="legend-item">
                                                <div class="legend-color" style="background-color: #6c757d;"></div>
                                                <span>Standard</span>
                                            </div>
                                            <div class="legend-item">
                                                <div class="legend-color" style="background-color: #ffc107;"></div>
                                                <span>VIP</span>
                                            </div>
                                            <div class="legend-item">
                                                <div class="legend-color" style="background-color: #e83e8c;"></div>
                                                <span>Couple</span>
                                            </div>
                                            <div class="legend-item">
                                                <div class="legend-color" style="background-color: #17a2b8;"></div>
                                                <span>Disabled</span>
                                            </div>
                                        </div>

                                        <!-- Thay thế phần seats-container hiện tại -->
                                        <div class="seats-container">
                                            <c:forEach var="seat" items="${seats}">
                                                <c:choose>
                                                    <c:when test="${param.action == 'edit'}">
                                                        <!-- Trong chế độ edit, ghế có thể click -->
                                                        <a href="dashboard?section=screening-room-management&action=editSeat&seatId=${seat.seatID}&roomId=${viewRoom.roomID}&mode=edit" 
                                                           class="seat ${seat.seatType.toLowerCase()} ${seat.status.toLowerCase()} seat-clickable"
                                                           data-bs-toggle="tooltip" 
                                                           title="Click to edit - Row ${seat.seatRow}, Number ${seat.seatNumber}&#10;Type: ${seat.seatType}&#10;Status: ${seat.status}">
                                                            ${seat.seatRow}${seat.seatNumber}
                                                        </a>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <!-- Trong chế độ view, ghế chỉ hiển thị -->
                                                        <div class="seat ${seat.seatType.toLowerCase()} ${seat.status.toLowerCase()}"
                                                             data-bs-toggle="tooltip" 
                                                             title="Row ${seat.seatRow}, Number ${seat.seatNumber}&#10;Type: ${seat.seatType}&#10;Status: ${seat.status}">
                                                            ${seat.seatRow}${seat.seatNumber}
                                                        </div>
                                                    </c:otherwise>
                                                </c:choose>
                                            </c:forEach>
                                        </div>

                                        <!-- Seat Statistics -->
                                        <div class="seat-statistics mt-4 p-3 border rounded bg-light">
                                            <h6 class="mb-3">
                                                <i class="bi bi-bar-chart"></i> Seat Statistics
                                            </h6>
                                            <div class="row text-center">
                                                <div class="col-3">
                                                    <div class="text-primary fw-bold fs-5">${seats.size()}</div>
                                                    <small class="text-muted">Total</small>
                                                </div>
                                                <div class="col-3">
                                                    <c:set var="availableCount" value="0"/>
                                                    <c:forEach var="seat" items="${seats}">
                                                        <c:if test="${seat.status == 'Available'}">
                                                            <c:set var="availableCount" value="${availableCount + 1}"/>
                                                        </c:if>
                                                    </c:forEach>
                                                    <div class="text-success fw-bold fs-5">${availableCount}</div>
                                                    <small class="text-muted">Available</small>
                                                </div>
                                                <div class="col-3">
                                                    <c:set var="vipCount" value="0"/>
                                                    <c:forEach var="seat" items="${seats}">
                                                        <c:if test="${seat.seatType == 'VIP'}">
                                                            <c:set var="vipCount" value="${vipCount + 1}"/>
                                                        </c:if>
                                                    </c:forEach>
                                                    <div class="text-warning fw-bold fs-5">${vipCount}</div>
                                                    <small class="text-muted">VIP</small>
                                                </div>
                                                <div class="col-3">
                                                    <c:set var="maintenanceCount" value="0"/>
                                                    <c:forEach var="seat" items="${seats}">
                                                        <c:if test="${seat.status == 'Maintenance'}">
                                                            <c:set var="maintenanceCount" value="${maintenanceCount + 1}"/>
                                                        </c:if>
                                                    </c:forEach>
                                                    <div class="text-danger fw-bold fs-5">${maintenanceCount}</div>
                                                    <small class="text-muted">Maintenance</small>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- Manage Seats Section -->
                                        <c:if test="${param.action == 'edit'}">
                                            <div class="manage-seats mt-4 p-3 border rounded bg-light">
                                                <h6 class="mb-3">
                                                    <i class="bi bi-gear"></i> Manage Seats
                                                </h6>
                                                <div class="d-grid gap-2">
                                                    <a href="dashboard?section=seat-management&roomId=${viewRoom.roomID}" 
                                                       class="btn btn-outline-primary btn-sm">
                                                        <i class="bi bi-pencil-square"></i> Edit Seats Layout
                                                    </a>
                                                    <small class="text-muted text-center">
                                                        Advanced seat configuration available in Seat Management
                                                    </small>
                                                </div>
                                            </div>
                                        </c:if>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="text-center py-4">
                                            <i class="bi bi-inbox display-4 text-muted"></i>
                                            <p class="mt-3 text-muted">No seats configured for this room</p>
                                            <c:if test="${param.action == 'edit'}">
                                                <a href="dashboard?section=screening-room-management&action=generateSeats&roomId=${viewRoom.roomID}" 
                                                   class="btn btn-primary" 
                                                   onclick="return confirm('Generate default seat layout? This will create seats based on room type.')">
                                                    <i class="bi bi-magic"></i> Generate Default Seats
                                                </a>
                                            </c:if>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Delete Confirm Modal -->
<div class="modal fade" id="deleteConfirmModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Confirm Deletion</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <p>Are you sure you want to delete the following screening room?</p>
                <div class="card">
                    <div class="card-body">
                        <p class="mb-1"><strong>Room Name:</strong> <span id="deleteRoomName"></span></p>
                        <p class="mb-1"><strong>Cinema:</strong> <span id="deleteCinemaName"></span></p>
                        <p class="mb-0"><strong>Seat Capacity:</strong> <span id="deleteSeatCapacity"></span></p>
                    </div>
                </div>
                <div class="alert alert-warning mt-3">
                    <i class="bi bi-exclamation-triangle-fill"></i> 
                    This action cannot be undone. All related seats and any associated screening schedules will also be deleted.
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                <form id="deleteRoomForm" method="POST" action="dashboard">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="section" value="screening-room-management">
                    <input type="hidden" name="id" id="deleteRoomId">
                    <button type="submit" class="btn btn-danger">
                        <i class="bi bi-trash"></i> Delete
                    </button>
                </form>
            </div>
        </div>
    </div>
</div>

<style>
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
    .seats-container {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(35px, 1fr));
        gap: 6px;
        padding: 15px;
        justify-items: center;
    }
    .seat {
        width: 35px;
        height: 35px;
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
    }
    .seat-clickable {
        cursor: pointer;
        text-decoration: none;
        transition: all 0.3s ease;
        transform: scale(1);
    }

    .seat-clickable:hover {
        transform: scale(1.1);
        box-shadow: 0 0 8px rgba(0,0,0,0.3);
        z-index: 10;
        position: relative;
    }

    /* Đảm bảo màu chữ hiển thị đúng trên link */
    .seat-clickable.standard {
        color: white !important;
    }
    .seat-clickable.vip {
        color: black !important;
    }
    .seat-clickable.couple {
        color: white !important;
    }
    .seat-clickable.disabled {
        color: white !important;
    }
    /* Seat type colors */
    .seat.standard {
        background-color: #6c757d;
    }
    .seat.vip {
        background-color: #ffc107;
        color: black;
    }
    .seat.couple {
        background-color: #e83e8c;
    }
    .seat.disabled {
        background-color: #17a2b8;
    }

    /* Seat status styles */
    .seat.available {
        opacity: 1;
    }
    .seat.maintenance {
        background-color: #fd7e14 !important;
    }
    .seat.unavailable {
        opacity: 0.5;
    }

    /* Seat legend */
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
</style>

<script>
    // Delete modal function
    function showDeleteModal(roomId, roomName) {
        // Find the room details from the table
        const roomRow = document.querySelector(`tr:has(button[onclick="showDeleteModal(${roomId}, '${roomName}')"])`);
        if (roomRow) {
            const cinemaName = roomRow.cells[2].textContent;
            const seatCapacity = roomRow.cells[4].textContent;

            document.getElementById('deleteRoomName').textContent = roomName;
            document.getElementById('deleteCinemaName').textContent = cinemaName;
            document.getElementById('deleteSeatCapacity').textContent = seatCapacity;
        } else {
            // If not in table (from edit page), use current room data
            document.getElementById('deleteRoomName').textContent = roomName;
            document.getElementById('deleteCinemaName').textContent = '${viewRoom.cinema.cinemaName}';
            document.getElementById('deleteSeatCapacity').textContent = '${viewRoom.seatCapacity}';
        }

        document.getElementById('deleteRoomId').value = roomId;

        const deleteModal = new bootstrap.Modal(document.getElementById('deleteConfirmModal'));
        deleteModal.show();
    }

    // Initialize tooltips
    document.addEventListener('DOMContentLoaded', function () {
        var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
        var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
            return new bootstrap.Tooltip(tooltipTriggerEl);
        });

        // Form validation
        const roomForm = document.getElementById('roomForm');
        if (roomForm) {
            roomForm.addEventListener('submit', function (e) {
                const roomName = this.querySelector('input[name="roomName"]');
                const seatCapacity = this.querySelector('input[name="seatCapacity"]');

                if (roomName && roomName.value.trim() === '') {
                    e.preventDefault();
                    alert('Please enter a room name');
                    roomName.focus();
                    return;
                }

                if (seatCapacity && (seatCapacity.value < 1 || seatCapacity.value > 500)) {
                    e.preventDefault();
                    alert('Seat capacity must be between 1 and 500');
                    seatCapacity.focus();
                    return;
                }
            });
        }
    });
</script>