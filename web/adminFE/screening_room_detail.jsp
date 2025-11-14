<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<div id="screening-room-management-content">
    <!-- Toast Notification -->
    <c:if test="${not empty toastType and not empty toastMessage}">
        <div class="toast-container position-fixed top-0 end-0 p-3">
            <div class="toast align-items-center text-white bg-${toastType} border-0 show" role="alert" aria-live="assertive" aria-atomic="true">
                <div class="d-flex">
                    <div class="toast-body">
                        <i class="bi
                           <c:choose>
                               <c:when test="${toastType == 'success'}">bi-check-circle-fill</c:when>
                               <c:when test="${toastType == 'danger'}">bi-exclamation-circle-fill</c:when>
                               <c:when test="${toastType == 'warning'}">bi-exclamation-triangle-fill</c:when>
                               <c:otherwise>bi-info-circle-fill</c:otherwise>
                           </c:choose>
                           me-2"></i>
                        ${toastMessage}
                    </div>
                    <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
                </div>
            </div>
        </div>
    </c:if>

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
        <!-- Back to List button with preserved filters -->
        <c:set var="backUrl" value="dashboard?section=screening-room-management"/>
        <c:if test="${not empty param.locationFilter && param.locationFilter != 'none'}">
            <c:set var="backUrl" value="${backUrl}&locationFilter=${param.locationFilter}"/>
        </c:if>
        <c:if test="${not empty param.cinemaFilter && param.cinemaFilter != 'none'}">
            <c:set var="backUrl" value="${backUrl}&cinemaFilter=${param.cinemaFilter}"/>
        </c:if>
        <c:if test="${not empty param.roomType && param.roomType != 'all'}">
            <c:set var="backUrl" value="${backUrl}&roomType=${param.roomType}"/>
        </c:if>
        <c:if test="${not empty param.status && param.status != 'all'}">
            <c:set var="backUrl" value="${backUrl}&status=${param.status}"/>
        </c:if>
        <c:if test="${not empty param.search}">
            <c:set var="backUrl" value="${backUrl}&search=${param.search}"/>
        </c:if>
        <c:if test="${not empty param.page && param.page != '1'}">
            <c:set var="backUrl" value="${backUrl}&page=${param.page}"/>
        </c:if>

        <a href="${backUrl}" class="btn btn-outline-secondary">
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
                        
                        <!-- Preserve filter parameters in form -->
                        <c:if test="${not empty param.locationFilter && param.locationFilter != 'none'}">
                            <input type="hidden" name="locationFilter" value="${param.locationFilter}">
                        </c:if>
                        <c:if test="${not empty param.cinemaFilter && param.cinemaFilter != 'none'}">
                            <input type="hidden" name="cinemaFilter" value="${param.cinemaFilter}">
                        </c:if>
                        <c:if test="${not empty param.roomType && param.roomType != 'all'}">
                            <input type="hidden" name="roomType" value="${param.roomType}">
                        </c:if>
                        <c:if test="${not empty param.status && param.status != 'all'}">
                            <input type="hidden" name="status" value="${param.status}">
                        </c:if>
                        <c:if test="${not empty param.search}">
                            <input type="hidden" name="search" value="${param.search}">
                        </c:if>
                        <c:if test="${not empty param.page && param.page != '1'}">
                            <input type="hidden" name="page" value="${param.page}">
                        </c:if>
                        
                        <c:if test="${param.action != 'create'}">
                            <input type="hidden" name="roomId" value="${viewRoom.roomID}">
                        </c:if>
                        <c:if test="${param.action == 'create'}">
                            <input type="hidden" name="cinemaId" value="${param.cinemaId}">
                        </c:if>

                        <div class="mb-3">
                            <label class="form-label">Cinema</label>
                            <c:choose>
                                <c:when test="${param.action == 'create'}">
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

                        <!-- REMOVED Seat Capacity field for create mode -->
                        <c:if test="${param.action != 'create'}">
                            <div class="mb-3">
                                <label class="form-label">Seat Capacity</label>
                                <input type="number" class="form-control" 
                                       value="${viewRoom.seatCapacity}" 
                                       readonly>
                                <div class="form-text">
                                    Capacity is automatically calculated from seat layout
                                </div>
                            </div>
                        </c:if>

                        <!-- ADDED Status field for create mode -->
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
                                               id="isActiveSwitch" ${viewRoom.active ? 'checked' : (param.action == 'create' ? 'checked' : '')}>
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
                            <button type="button" class="btn btn-primary btn-sm" 
                                    onclick="showGenerateSeatsModal(${viewRoom.roomID}, 'generate')">
                                <i class="bi bi-magic"></i> Generate Seats
                            </button>
                        </c:if>
                        <c:if test="${param.action == 'edit' && not empty seats && seats.size() > 0}">
                            <button type="button" class="btn btn-outline-warning btn-sm" 
                                    onclick="showGenerateSeatsModal(${viewRoom.roomID}, 'regenerate')">
                                <i class="bi bi-arrow-repeat"></i> Regenerate Seats
                            </button>
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
<!--                                            <div class="legend-item">
                                                <div class="seat disabled" style="width: 20px; height: 20px;"></div>
                                                <span>♿ Disabled</span>
                                            </div>-->
                                        </div>

                                        <!-- UPDATED seats-container với icon và cấu trúc HTML cho ghế -->
                                        <div class="seats-container">
                                            <c:forEach var="row" items="${['A','B','C','D','E','F','G','H','I','J','K','L','M','N']}">
                                                <c:set var="rowSeats" value="${seats.stream().filter(s -> s.seatRow == row).toList()}"/>
                                                <c:if test="${not empty rowSeats}">
                                                    <div class="seat-row" data-row="${row}">
                                                        <c:forEach var="seat" items="${rowSeats}">
                                                            <c:choose>
                                                                <c:when test="${param.action == 'edit'}">
                                                                    <a href="dashboard?section=screening-room-management&action=editSeat&seatId=${seat.seatID}&roomId=${viewRoom.roomID}" 
                                                                       class="seat ${seat.seatType.toLowerCase()} ${seat.status.toLowerCase()} seat-clickable"
                                                                       data-bs-toggle="tooltip" 
                                                                       title="Click to edit - Row ${seat.seatRow}, Number ${seat.seatNumber}&#10;Type: ${seat.seatType}&#10;Status: ${seat.status}">
                                                                        <span class="seat-text">${seat.seatRow}${seat.seatNumber}</span>
                                                                    </a>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <div class="seat ${seat.seatType.toLowerCase()} ${seat.status.toLowerCase()}"
                                                                         data-bs-toggle="tooltip" 
                                                                         title="Row ${seat.seatRow}, Number ${seat.seatNumber}&#10;Type: ${seat.seatType}&#10;Status: ${seat.status}">
                                                                        <span class="seat-text">${seat.seatRow}${seat.seatNumber}</span>
                                                                    </div>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </c:forEach>
                                                    </div>
                                                </c:if>
                                            </c:forEach>
                                        </div>

                                        <!-- Seat Statistics với đầy đủ thống kê -->
                                        <div class="seat-statistics mt-4 p-3 border rounded bg-light">
                                            <h6 class="mb-3">
                                                <i class="bi bi-bar-chart"></i> Seat Statistics
                                            </h6>
                                            <div class="row text-center">
                                                <!-- Total -->
                                                <div class="col-3 col-sm-2">
                                                    <div class="text-primary fw-bold fs-5">${seats.size()}</div>
                                                    <small class="text-muted">Total</small>
                                                </div>
                                                <!-- Available -->
                                                <div class="col-3 col-sm-2">
                                                    <c:set var="availableCount" value="0"/>
                                                    <c:forEach var="seat" items="${seats}">
                                                        <c:if test="${seat.status == 'Available'}">
                                                            <c:set var="availableCount" value="${availableCount + 1}"/>
                                                        </c:if>
                                                    </c:forEach>
                                                    <div class="text-success fw-bold fs-5">${availableCount}</div>
                                                    <small class="text-muted">Available</small>
                                                </div>
                                                <!-- Standard Seats -->
                                                <div class="col-3 col-sm-2">
                                                    <c:set var="standardCount" value="0"/>
                                                    <c:forEach var="seat" items="${seats}">
                                                        <c:if test="${seat.seatType == 'Standard'}">
                                                            <c:set var="standardCount" value="${standardCount + 1}"/>
                                                        </c:if>
                                                    </c:forEach>
                                                    <div class="text-secondary fw-bold fs-5">${standardCount}</div>
                                                    <small class="text-muted">
                                                        <i class="bi bi-person"></i> Standard
                                                    </small>
                                                </div>
                                                <!-- VIP Seats -->
                                                <div class="col-3 col-sm-2">
                                                    <c:set var="vipCount" value="0"/>
                                                    <c:forEach var="seat" items="${seats}">
                                                        <c:if test="${seat.seatType == 'VIP'}">
                                                            <c:set var="vipCount" value="${vipCount + 1}"/>
                                                        </c:if>
                                                    </c:forEach>
                                                    <div class="text-warning fw-bold fs-5">${vipCount}</div>
                                                    <small class="text-muted">
                                                        <i class="bi bi-star"></i> VIP
                                                    </small>
                                                </div>
                                                <!-- Couple Seats -->
                                                <div class="col-3 col-sm-2">
                                                    <c:set var="coupleCount" value="0"/>
                                                    <c:forEach var="seat" items="${seats}">
                                                        <c:if test="${seat.seatType == 'Couple'}">
                                                            <c:set var="coupleCount" value="${coupleCount + 1}"/>
                                                        </c:if>
                                                    </c:forEach>
                                                    <div class="text-pink fw-bold fs-5">${coupleCount}</div>
                                                    <small class="text-muted">
                                                        <i class="bi bi-heart"></i> Couple
                                                    </small>
                                                </div>
                                                <!-- Disabled Seats -->
<!--                                                <div class="col-3 col-sm-2">
                                                    <c:set var="disabledCount" value="0"/>
                                                    <c:forEach var="seat" items="${seats}">
                                                        <c:if test="${seat.seatType == 'Disabled'}">
                                                            <c:set var="disabledCount" value="${disabledCount + 1}"/>
                                                        </c:if>
                                                    </c:forEach>
                                                    <div class="text-info fw-bold fs-5">${disabledCount}</div>
                                                    <small class="text-muted">
                                                        <i class="bi bi-wheelchair"></i> Disabled
                                                    </small>
                                                </div>-->
                                            </div>

                                            <!-- Additional Status Statistics -->
                                            <div class="row text-center mt-3 pt-3 border-top">
                                                <!-- Maintenance -->
                                                <div class="col-4">
                                                    <c:set var="maintenanceCount" value="0"/>
                                                    <c:forEach var="seat" items="${seats}">
                                                        <c:if test="${seat.status == 'Maintenance'}">
                                                            <c:set var="maintenanceCount" value="${maintenanceCount + 1}"/>
                                                        </c:if>
                                                    </c:forEach>
                                                    <div class="text-danger fw-bold fs-6">${maintenanceCount}</div>
                                                    <small class="text-muted">
                                                        <i class="bi bi-tools"></i> Maintenance
                                                    </small>
                                                </div>
                                                <!-- Unavailable -->
                                                <div class="col-4">
                                                    <c:set var="unavailableCount" value="0"/>
                                                    <c:forEach var="seat" items="${seats}">
                                                        <c:if test="${seat.status == 'Unavailable'}">
                                                            <c:set var="unavailableCount" value="${unavailableCount + 1}"/>
                                                        </c:if>
                                                    </c:forEach>
                                                    <div class="text-muted fw-bold fs-6">${unavailableCount}</div>
                                                    <small class="text-muted">
                                                        <i class="bi bi-slash-circle"></i> Unavailable
                                                    </small>
                                                </div>
<!--                                                 Booked 
                                                <div class="col-4">
                                                    <c:set var="bookedCount" value="0"/>
                                                    <c:forEach var="seat" items="${seats}">
                                                        <c:if test="${seat.status == 'Booked'}">
                                                            <c:set var="bookedCount" value="${bookedCount + 1}"/>
                                                        </c:if>
                                                    </c:forEach>
                                                    <div class="text-warning fw-bold fs-6">${bookedCount}</div>
                                                    <small class="text-muted">
                                                        <i class="bi bi-ticket-perforated"></i> Booked
                                                    </small>
                                                </div>-->
                                            </div>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="text-center py-4">
                                            <i class="bi bi-inbox display-4 text-muted"></i>
                                            <p class="mt-3 text-muted">No seats configured for this room</p>
                                            <c:if test="${param.action == 'edit'}">
                                                <button type="button" class="btn btn-primary" 
                                                        onclick="showGenerateSeatsModal(${viewRoom.roomID}, 'generate')">
                                                    <i class="bi bi-magic"></i> Generate Default Seats
                                                </button>
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
                    <!-- Preserve filter parameters in delete form -->
                    <c:if test="${not empty param.locationFilter && param.locationFilter != 'none'}">
                        <input type="hidden" name="locationFilter" value="${param.locationFilter}">
                    </c:if>
                    <c:if test="${not empty param.cinemaFilter && param.cinemaFilter != 'none'}">
                        <input type="hidden" name="cinemaFilter" value="${param.cinemaFilter}">
                    </c:if>
                    <c:if test="${not empty param.roomType && param.roomType != 'all'}">
                        <input type="hidden" name="roomType" value="${param.roomType}">
                    </c:if>
                    <c:if test="${not empty param.status && param.status != 'all'}">
                        <input type="hidden" name="status" value="${param.status}">
                    </c:if>
                    <c:if test="${not empty param.search}">
                        <input type="hidden" name="search" value="${param.search}">
                    </c:if>
                    <c:if test="${not empty param.page && param.page != '1'}">
                        <input type="hidden" name="page" value="${param.page}">
                    </c:if>
                    <input type="hidden" name="id" id="deleteRoomId">
                    <button type="submit" class="btn btn-danger">
                        <i class="bi bi-trash"></i> Delete
                    </button>
                </form>
            </div>
        </div>
    </div>
</div>

<!-- Generate Seats Confirm Modal -->
<div class="modal fade" id="generateSeatsModal" tabindex="-1" aria-labelledby="generateSeatsModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="generateSeatsModalLabel">Generate Seats</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div id="generateSeatsContent">
                    <!-- Content will be dynamically filled by JavaScript -->
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-primary" id="confirmGenerateSeats">
                    <i class="bi bi-check-lg"></i> <span id="confirmButtonText">Confirm</span>
                </button>
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

    /* Base seat style */
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

/*     Disabled seat size 
    .seat.disabled {
        width: 35px;
        height: 35px;
    }*/

    /* COUPLE seat */
    .seat.couple {
        width: 70px; /* Double width */
        height: 35px;
        background: linear-gradient(135deg, #e83e8c, #d91a72);
        position: relative;
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

    /* Seat type colors */
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

    /* Seat status styles */
    .seat.available {
        opacity: 1;
    }
    .seat.maintenance {
        background: linear-gradient(135deg, #fd7e14, #e55a00) !important;
    }
    .seat.unavailable {
        opacity: 0.5;
    }

    /* Icons for seats */
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

/*    .seat.disabled::before {
        content: "♿";
        font-size: 12px;
        margin-right: 2px;
    }*/

    /* Hide text for very small seats, show only icon */
    .seat .seat-text {
        font-size: 9px;
    }

    /* For couple seats, we can show both icon and text nicely */
    .seat.couple .seat-text {
        font-size: 10px;
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

    /* Gap indicator between seat groups */
    .seat-gap {
        width: 20px;
        height: 35px;
        display: flex;
        align-items: center;
        justify-content: center;
    }

    /* NEW: Special styling for couple seats to make them stand out */
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

    /* Responsive design */
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
    /* Additional colors for statistics */
    .text-pink {
        color: #e83e8c !important;
    }

    .bg-pink {
        background-color: #e83e8c !important;
    }

    /* Progress bar styles for visual statistics */
    .seat-type-progress {
        height: 8px;
        border-radius: 4px;
        margin-top: 5px;
    }

    .progress-standard {
        background-color: #6c757d;
    }

    .progress-vip {
        background-color: #ffc107;
    }

    .progress-couple {
        background-color: #e83e8c;
    }

    .progress-disabled {
        background-color: #17a2b8;
    }
</style>

<script>
    // Debug info
    console.log('Room details page loaded');
    console.log('viewRoom roomID:', ${viewRoom.roomID});
    console.log('viewRoom roomName:', '${viewRoom.roomName}');
    console.log('viewRoom roomType:', '${viewRoom.roomType}');
    console.log('action:', '${param.action}');
    console.log('seats count:', ${empty seats ? 0 : seats.size()});

    // Delete modal function
    function showDeleteModal(roomId, roomName) {
        console.log('showDeleteModal called with:', roomId, roomName);

        // If not in table (from edit page), use current room data
        document.getElementById('deleteRoomName').textContent = roomName;
        document.getElementById('deleteCinemaName').textContent = '${viewRoom.cinema.cinemaName}';
        document.getElementById('deleteSeatCapacity').textContent = '${viewRoom.seatCapacity}';

        document.getElementById('deleteRoomId').value = roomId;

        const deleteModal = new bootstrap.Modal(document.getElementById('deleteConfirmModal'));
        deleteModal.show();
    }

    // Generate seats modal function
    function showGenerateSeatsModal(roomId, actionType) {
        console.log('showGenerateSeatsModal called with:', roomId, actionType);

        const modal = document.getElementById('generateSeatsModal');
        const modalTitle = document.getElementById('generateSeatsModalLabel');
        const modalContent = document.getElementById('generateSeatsContent');
        const confirmButton = document.getElementById('confirmGenerateSeats');
        const confirmButtonText = document.getElementById('confirmButtonText');

        // Get room info from JSP variables
        const roomName = '${viewRoom.roomName}';
        const roomType = '${viewRoom.roomType}';
        const seatCapacity = '${viewRoom.seatCapacity}';
        const currentSeatsCount = '${empty seats ? 0 : seats.size()}';

        let title = '';
        let message = '';
        let confirmText = '';

        if (actionType === 'generate') {
            title = 'Generate Seats';
            message = `
                <p>Are you sure you want to generate default seat layout for this room?</p>
                <div class="alert alert-info">
                    <i class="bi bi-info-circle"></i> 
                    This will create seats based on the room type (<strong>${roomType}</strong>).
                </div>
                <div class="card">
                    <div class="card-body">
                        <p class="mb-1"><strong>Room:</strong> ${roomName}</p>
                        <p class="mb-1"><strong>Type:</strong> ${roomType}</p>
                        <p class="mb-0"><strong>Capacity:</strong> ${seatCapacity} seats</p>
                    </div>
                </div>
            `;
            confirmText = 'Generate Seats';
        } else {
            title = 'Regenerate Seats';
            message = `
                <div class="alert alert-warning">
                    <i class="bi bi-exclamation-triangle-fill"></i>
                    <strong>Warning: This action cannot be undone!</strong>
                </div>
                <p>Are you sure you want to regenerate all seats for this room?</p>
                <div class="alert alert-danger">
                    <h6><i class="bi bi-x-octagon-fill"></i> Critical Consequences:</h6>
                    <ul class="mb-0">
                        <li>All existing seats will be deleted</li>
                        <li>Any booking history for these seats will be lost</li>
                        <li>New seats will be generated based on current room type</li>
                    </ul>
                </div>
                <div class="card">
                    <div class="card-body">
                        <p class="mb-1"><strong>Room:</strong> ${roomName}</p>
                        <p class="mb-1"><strong>Current Seats:</strong> ${currentSeatsCount}</p>
                        <p class="mb-0"><strong>New Layout:</strong> Based on <strong>${roomType}</strong> type</p>
                    </div>
                </div>
            `;
            confirmText = 'Regenerate Seats';
        }

        modalTitle.textContent = title;
        modalContent.innerHTML = message;
        confirmButtonText.textContent = confirmText;

        // Remove any existing event listeners
        const newConfirmButton = confirmButton.cloneNode(true);
        confirmButton.parentNode.replaceChild(newConfirmButton, confirmButton);

        // Add new event listener
        newConfirmButton.addEventListener('click', function () {
            console.log('Modal confirm clicked, redirecting for room:', roomId);
            window.location.href = 'dashboard?section=screening-room-management&action=generateSeats&roomId=' + roomId;
        });

        // Initialize and show modal
        const generateModal = new bootstrap.Modal(modal);
        generateModal.show();

        console.log('Modal shown successfully');
    }

    // Backup function using confirm dialog
    function generateSeatsSimple(roomId, isRegenerate) {
        console.log('generateSeatsSimple called with:', roomId, isRegenerate);

        let message = 'Generate default seat layout for this room?';

        if (isRegenerate) {
            message = 'WARNING: This will delete all existing seats and create new ones. Continue?';
        }

        if (confirm(message)) {
            console.log('Redirecting to generate seats for room:', roomId);
            window.location.href = 'dashboard?section=screening-room-management&action=generateSeats&roomId=' + roomId;
        }
    }

    // Initialize when DOM is loaded
    document.addEventListener('DOMContentLoaded', function () {
        console.log('DOM loaded - initializing components');

        // Initialize tooltips
        const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
        const tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
            return new bootstrap.Tooltip(tooltipTriggerEl);
        });

        // Form validation
        const roomForm = document.getElementById('roomForm');
        if (roomForm) {
            roomForm.addEventListener('submit', function (e) {
                const roomName = this.querySelector('input[name="roomName"]');
                const roomType = this.querySelector('select[name="roomType"]');

                if (roomName && roomName.value.trim() === '') {
                    e.preventDefault();
                    alert('Please enter a room name');
                    roomName.focus();
                    return;
                }

                if (roomType && roomType.value === '') {
                    e.preventDefault();
                    alert('Please select a room type');
                    roomType.focus();
                    return;
                }
            });
        }

        // Auto-hide toast after 5 seconds
        const toastEl = document.querySelector('.toast');
        if (toastEl) {
            const toast = new bootstrap.Toast(toastEl, {delay: 5000});
            toast.show();
        }

        // Test modal elements
        const modal = document.getElementById('generateSeatsModal');
        if (modal) {
            console.log('✅ Generate seats modal element found');
        } else {
            console.error('❌ Generate seats modal element NOT found');
        }
    });
</script>