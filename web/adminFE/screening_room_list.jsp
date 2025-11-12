<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<div id="screening-room-management-content">
    <!-- Toast Notification -->
    <c:if test="${not empty toastType and not empty toastMessage}">
        <div class="toast-container position-fixed top-0 end-0 p-3" style="z-index: 1060;">
            <div class="toast align-items-center text-white bg-${toastType} border-0 show" role="alert" aria-live="assertive" aria-atomic="true">
                <div class="d-flex">
                    <div class="toast-body">
                        <i class="bi
                           <c:choose>
                               <c:when test="${toastType == 'success'}">bi-check-circle-fill</c:when>
                               <c:when test="${toastType == 'error'}">bi-exclamation-circle-fill</c:when>
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

    <!-- Page Header -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h2 class="h4 mb-1">Screening Room Management</h2>
            <p class="text-muted mb-0">Manage screening rooms for selected cinema</p>
        </div>
        <a href="dashboard?section=screening-room-management" class="btn btn-outline-secondary">
            <i class="bi bi-arrow-clockwise"></i> Reset All
        </a>
    </div>

    <!-- Filter Section -->
    <div class="card mb-4">
        <div class="card-header">
            <h5 class="card-title mb-0">Select Cinema</h5>
        </div>
        <div class="card-body">
            <div class="row g-3">
                <div class="col-md-6">
                    <label class="form-label fw-bold">Location</label>
                    <form id="locationForm" action="dashboard" method="GET">
                        <input type="hidden" name="section" value="screening-room-management">
                        <input type="hidden" name="page" value="1">
                        <select class="form-select" id="locationFilter" name="locationFilter" onchange="this.form.submit()">
                            <option value="none" ${empty param.locationFilter || param.locationFilter == 'none' ? 'selected' : ''}>
                                -- Select Location --
                            </option>
                            <c:forEach var="location" items="${allLocations}">
                                <c:if test="${location != 'none'}">
                                    <option value="${location}" ${param.locationFilter == location ? 'selected' : ''}>
                                        ${location}
                                    </option>
                                </c:if>
                            </c:forEach>
                        </select>
                    </form>
                </div>
                <div class="col-md-6">
                    <label class="form-label fw-bold">Cinema</label>
                    <form id="cinemaForm" action="dashboard" method="GET">
                        <input type="hidden" name="section" value="screening-room-management">
                        <input type="hidden" name="page" value="1">
                        <input type="hidden" name="locationFilter" value="${param.locationFilter}">
                        <select class="form-select" id="cinemaFilter" name="cinemaFilter" 
                                onchange="this.form.submit()" 
                                ${empty param.locationFilter || param.locationFilter == 'none' ? 'disabled' : ''}>
                            <option value="none" ${empty param.cinemaFilter || param.cinemaFilter == 'none' ? 'selected' : ''}>
                                -- Select Cinema --
                            </option>
                            <c:forEach var="cinema" items="${cinemasByLocation}">
                                <c:if test="${cinema.cinemaID != -1}">
                                    <option value="${cinema.cinemaID}" ${param.cinemaFilter == cinema.cinemaID ? 'selected' : ''}>
                                        ${cinema.cinemaName}
                                    </option>
                                </c:if>
                            </c:forEach>
                        </select>
                    </form>
                </div>
            </div>

            <!-- Selected Cinema Info -->
            <c:if test="${not empty param.cinemaFilter && param.cinemaFilter != 'none'}">
                <div class="mt-3 p-3 bg-light rounded">
                    <c:forEach var="cinema" items="${cinemasByLocation}">
                        <c:if test="${cinema.cinemaID == param.cinemaFilter}">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h6 class="mb-1">Selected Cinema: <strong>${cinema.cinemaName}</strong></h6>
                                    <p class="mb-0 text-muted">
                                        <i class="bi bi-geo-alt"></i> ${cinema.location} 
                                        <span class="mx-2">•</span>
                                        <i class="bi bi-house"></i> ${cinema.address}
                                    </p>
                                </div>
                                <span class="badge ${cinema.active ? 'bg-success' : 'bg-secondary'}">
                                    ${cinema.active ? 'Active' : 'Inactive'}
                                </span>
                            </div>
                        </c:if>
                    </c:forEach>
                </div>
            </c:if>
        </div>
    </div>

    <!-- Main Content Area - Only show when both filters are selected -->
    <c:choose>
        <c:when test="${hasValidFilters}">
            <!-- Search and Actions Bar -->
            <div class="card mb-4" style="position: relative; z-index: 100;">
                <div class="card-body">
                    <div class="d-flex justify-content-between align-items-center">
                        <!-- Search Bar -->
                        <div class="w-50 me-3">
                            <form action="dashboard" method="GET" class="input-group">
                                <input type="text" name="search" class="form-control" placeholder="Search rooms by name..." 
                                       value="${param.search}" aria-label="Search rooms">
                                <input type="hidden" name="page" value="1">
                                <input type="hidden" name="section" value="screening-room-management">
                                <input type="hidden" name="locationFilter" value="${param.locationFilter}">
                                <input type="hidden" name="cinemaFilter" value="${param.cinemaFilter}">
                                <input type="hidden" name="roomType" value="${empty param.roomType ? 'all' : param.roomType}">
                                <input type="hidden" name="status" value="${empty param.status ? 'all' : param.status}">
                                <button class="btn btn-outline-primary" type="submit">
                                    <i class="bi bi-search"></i> Search
                                </button>
                            </form>
                        </div>

                        <!-- Action Buttons -->
                        <div class="d-flex align-items-center">
                            <!-- Quick Filters -->
                            <div class="btn-group me-3" style="position: relative; z-index: 1050;">
                                <!-- Room Type Filter -->
                                <div class="dropdown me-2">
                                    <button class="btn btn-outline-secondary dropdown-toggle" type="button" 
                                            data-bs-toggle="dropdown" aria-expanded="false"
                                            style="position: relative; z-index: 1051;">
                                        <i class="bi bi-tag"></i>
                                        <c:choose>
                                            <c:when test="${not empty param.roomType && param.roomType != 'all'}">
                                                ${param.roomType}
                                            </c:when>
                                            <c:otherwise>
                                                All Types
                                            </c:otherwise>
                                        </c:choose>
                                    </button>
                                    <ul class="dropdown-menu" style="z-index: 1060;">
                                        <li><a class="dropdown-item" href="dashboard?section=screening-room-management&roomType=all&status=${empty param.status ? 'all' : param.status}&locationFilter=${param.locationFilter}&cinemaFilter=${param.cinemaFilter}&search=${param.search}">
                                                <i class="bi bi-grid-3x3"></i> All Types
                                            </a></li>
                                        <li><hr class="dropdown-divider"></li>
                                            <c:forEach var="roomType" items="${allRoomTypes}">
                                            <li><a class="dropdown-item" href="dashboard?section=screening-room-management&roomType=${roomType}&status=${empty param.status ? 'all' : param.status}&locationFilter=${param.locationFilter}&cinemaFilter=${param.cinemaFilter}&search=${param.search}">
                                                    <c:choose>
                                                        <c:when test="${roomType == 'VIP'}"><i class="bi bi-star"></i></c:when>
                                                        <c:when test="${roomType == 'IMAX'}"><i class="bi bi-camera-reels"></i></c:when>
                                                        <c:when test="${roomType == '3D'}"><i class="bi bi-three-dots"></i></c:when>
                                                        <c:otherwise><i class="bi bi-display"></i></c:otherwise>
                                                    </c:choose>
                                                    ${roomType}
                                                </a></li>
                                            </c:forEach>
                                    </ul>
                                </div>

                                <!-- Status Filter -->
                                <div class="dropdown">
                                    <button class="btn btn-outline-secondary dropdown-toggle" type="button" 
                                            data-bs-toggle="dropdown" aria-expanded="false"
                                            style="position: relative; z-index: 1051;">
                                        <i class="bi bi-funnel"></i>
                                        <c:choose>
                                            <c:when test="${not empty param.status && param.status != 'all'}">
                                                ${param.status}
                                            </c:when>
                                            <c:otherwise>
                                                All Status
                                            </c:otherwise>
                                        </c:choose>
                                    </button>
                                    <ul class="dropdown-menu" style="z-index: 1060;">
                                        <li><a class="dropdown-item" href="dashboard?section=screening-room-management&status=all&roomType=${empty param.roomType ? 'all' : param.roomType}&locationFilter=${param.locationFilter}&cinemaFilter=${param.cinemaFilter}&search=${param.search}">
                                                <i class="bi bi-grid-3x3"></i> All Status
                                            </a></li>
                                        <li><hr class="dropdown-divider"></li>
                                        <li><a class="dropdown-item" href="dashboard?section=screening-room-management&status=active&roomType=${empty param.roomType ? 'all' : param.roomType}&locationFilter=${param.locationFilter}&cinemaFilter=${param.cinemaFilter}&search=${param.search}">
                                                <i class="bi bi-check-circle text-success"></i> Active
                                            </a></li>
                                        <li><a class="dropdown-item" href="dashboard?section=screening-room-management&status=inactive&roomType=${empty param.roomType ? 'all' : param.roomType}&locationFilter=${param.locationFilter}&cinemaFilter=${param.cinemaFilter}&search=${param.search}">
                                                <i class="bi bi-x-circle text-danger"></i> Inactive
                                            </a></li>
                                    </ul>
                                </div>
                            </div>

                            <!-- Add Room Button -->
                            <a href="dashboard?section=screening-room-management&action=create&cinemaId=${param.cinemaFilter}" 
                               class="btn btn-primary" style="position: relative; z-index: 100;">
                                <i class="bi bi-plus-circle"></i> Add New Room
                            </a>
                        </div>
                    </div>

                    <!-- Active Filters Display - Chỉ hiển thị search, roomType và status -->
                    <c:if test="${not empty param.search || (not empty param.roomType && param.roomType != 'all') || (not empty param.status && param.status != 'all')}">
                        <div class="active-filters mt-3">
                            <small class="text-muted me-2">Active filters:</small>
                            <c:if test="${not empty param.search}">
                                <span class="badge bg-info me-2">
                                    Search: "${param.search}"
                                    <a href="dashboard?section=screening-room-management&locationFilter=${param.locationFilter}&cinemaFilter=${param.cinemaFilter}&roomType=${empty param.roomType ? 'all' : param.roomType}&status=${empty param.status ? 'all' : param.status}" class="text-white ms-1">
                                        <i class="bi bi-x"></i>
                                    </a>
                                </span>
                            </c:if>
                            <c:if test="${not empty param.roomType && param.roomType != 'all'}">
                                <span class="badge bg-warning me-2">
                                    Type: ${param.roomType}
                                    <a href="dashboard?section=screening-room-management&locationFilter=${param.locationFilter}&cinemaFilter=${param.cinemaFilter}&status=${empty param.status ? 'all' : param.status}&search=${param.search}" class="text-white ms-1">
                                        <i class="bi bi-x"></i>
                                    </a>
                                </span>
                            </c:if>
                            <c:if test="${not empty param.status && param.status != 'all'}">
                                <span class="badge bg-success me-2">
                                    Status: ${param.status}
                                    <a href="dashboard?section=screening-room-management&locationFilter=${param.locationFilter}&cinemaFilter=${param.cinemaFilter}&roomType=${empty param.roomType ? 'all' : param.roomType}&search=${param.search}" class="text-white ms-1">
                                        <i class="bi bi-x"></i>
                                    </a>
                                </span>
                            </c:if>
                            <a href="dashboard?section=screening-room-management&locationFilter=${param.locationFilter}&cinemaFilter=${param.cinemaFilter}" class="btn btn-sm btn-outline-secondary">
                                <i class="bi bi-x-circle"></i> Clear Filters
                            </a>
                        </div>
                    </c:if>
                </div>
            </div>

            <!-- Rooms List -->
            <c:choose>
                <c:when test="${not empty listRooms}">
                    <!-- Rooms Table -->
                    <div class="card" style="position: relative; z-index: 1;">
                        <div class="card-header">
                            <h5 class="card-title mb-0">Screening Rooms</h5>
                        </div>
                        <div class="card-body p-0">
                            <div class="table-responsive">
                                <table class="table table-hover mb-0">
                                    <thead class="table-light">
                                        <tr>
                                            <th width="60">No.</th>
                                            <th>Room Name</th>
                                            <th>Type</th>
                                            <th>Seat Capacity</th>
                                            <th>Status</th>
                                            <th width="200">Actions</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="room" items="${listRooms}" varStatus="loop">
                                            <tr>
                                                <td class="text-muted">${(currentPage - 1) * recordsPerPage + loop.index + 1}</td>
                                                <td>
                                                    <div class="d-flex align-items-center">
                                                        <div class="flex-shrink-0">
                                                            <i class="bi bi-door-closed text-primary fs-5"></i>
                                                        </div>
                                                        <div class="flex-grow-1 ms-3">
                                                            <h6 class="mb-0">${room.roomName}</h6>
                                                            <small class="text-muted">${room.cinema.cinemaName}</small>
                                                        </div>
                                                    </div>
                                                </td>
                                                <td>
                                                    <span class="badge
                                                          <c:choose>
                                                              <c:when test="${room.roomType == 'VIP'}">bg-warning</c:when>
                                                              <c:when test="${room.roomType == 'IMAX'}">bg-info</c:when>
                                                              <c:when test="${room.roomType == '3D'}">bg-success</c:when>
                                                              <c:otherwise>bg-secondary</c:otherwise>
                                                          </c:choose>
                                                          ">
                                                        <c:choose>
                                                            <c:when test="${room.roomType == 'VIP'}"><i class="bi bi-star"></i></c:when>
                                                            <c:when test="${room.roomType == 'IMAX'}"><i class="bi bi-camera-reels"></i></c:when>
                                                            <c:when test="${room.roomType == '3D'}"><i class="bi bi-three-dots"></i></c:when>
                                                            <c:otherwise><i class="bi bi-display"></i></c:otherwise>
                                                        </c:choose>
                                                        ${room.roomType}
                                                    </span>
                                                </td>
                                                <td>
                                                    <div class="d-flex align-items-center">
                                                        <i class="bi bi-people text-muted me-2"></i>
                                                        <span class="fw-semibold">${room.seatCapacity}</span>
                                                        <small class="text-muted ms-1">seats</small>
                                                    </div>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${room.active}">
                                                            <span class="badge bg-success">
                                                                <i class="bi bi-check-circle"></i> Active
                                                            </span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge bg-danger">
                                                                <i class="bi bi-x-circle"></i> Inactive
                                                            </span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <div class="btn-group btn-group-sm">
                                                        <a href="dashboard?section=screening-room-management&action=view&id=${room.roomID}&locationFilter=${param.locationFilter}&cinemaFilter=${param.cinemaFilter}&roomType=${empty param.roomType ? 'all' : param.roomType}&status=${empty param.status ? 'all' : param.status}&search=${param.search}&page=${currentPage}" 
                                                           class="btn btn-outline-info" title="View Details">
                                                            <i class="bi bi-eye"></i>
                                                        </a>
                                                        <a href="dashboard?section=screening-room-management&action=edit&id=${room.roomID}&locationFilter=${param.locationFilter}&cinemaFilter=${param.cinemaFilter}&roomType=${empty param.roomType ? 'all' : param.roomType}&status=${empty param.status ? 'all' : param.status}&search=${param.search}&page=${currentPage}" 
                                                           class="btn btn-outline-warning" title="Edit Room">
                                                            <i class="bi bi-pencil"></i>
                                                        </a>
                                                        <button class="btn btn-outline-danger" 
                                                                onclick="showDeleteModal(${room.roomID}, '${room.roomName}')"
                                                                title="Delete Room">
                                                            <i class="bi bi-trash"></i>
                                                        </button>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>

                    <!-- Pagination -->
                    <c:if test="${noOfPages > 1}">
                        <nav aria-label="Page navigation" class="mt-4">
                            <ul class="pagination justify-content-center">
                                <c:if test="${currentPage > 1}">
                                    <li class="page-item">
                                        <a class="page-link" href="dashboard?section=screening-room-management&page=${currentPage-1}&locationFilter=${param.locationFilter}&cinemaFilter=${param.cinemaFilter}&roomType=${empty param.roomType ? 'all' : param.roomType}&status=${empty param.status ? 'all' : param.status}&search=${param.search}">
                                            <i class="bi bi-chevron-left"></i>
                                        </a>
                                    </li>
                                </c:if>

                                <c:forEach begin="1" end="${noOfPages}" var="i">
                                    <c:choose>
                                        <c:when test="${currentPage eq i}">
                                            <li class="page-item active"><a class="page-link" href="#">${i}</a></li>
                                            </c:when>
                                            <c:otherwise>
                                            <li class="page-item">
                                                <a class="page-link" href="dashboard?section=screening-room-management&page=${i}&locationFilter=${param.locationFilter}&cinemaFilter=${param.cinemaFilter}&roomType=${empty param.roomType ? 'all' : param.roomType}&status=${empty param.status ? 'all' : param.status}&search=${param.search}">
                                                    ${i}
                                                </a>
                                            </li>
                                        </c:otherwise>
                                    </c:choose>
                                </c:forEach>

                                <c:if test="${currentPage lt noOfPages}">
                                    <li class="page-item">
                                        <a class="page-link" href="dashboard?section=screening-room-management&page=${currentPage+1}&locationFilter=${param.locationFilter}&cinemaFilter=${param.cinemaFilter}&roomType=${empty param.roomType ? 'all' : param.roomType}&status=${empty param.status ? 'all' : param.status}&search=${param.search}">
                                            <i class="bi bi-chevron-right"></i>
                                        </a>
                                    </li>
                                </c:if>
                            </ul>
                        </nav>
                    </c:if>
                </c:when>
                <c:otherwise>
                    <!-- Empty State when no rooms found -->
                    <div class="text-center py-5">
                        <div class="empty-state-icon mb-4">
                            <i class="bi bi-door-closed display-1 text-muted"></i>
                        </div>
                        <h3 class="h4 text-muted mb-3">No Screening Rooms Found</h3>
                        <p class="text-muted mb-4">
                            <c:choose>
                                <c:when test="${not empty param.search}">
                                    No screening rooms found for search: "<strong>${param.search}</strong>"
                                </c:when>
                                <c:when test="${not empty param.roomType && param.roomType != 'all'}">
                                    No screening rooms found for type: "<strong>${param.roomType}</strong>"
                                </c:when>
                                <c:when test="${not empty param.status && param.status != 'all'}">
                                    No screening rooms found for status: "<strong>${param.status}</strong>"
                                </c:when>
                                <c:otherwise>
                                    There are no screening rooms available for the selected cinema.
                                </c:otherwise>
                            </c:choose>
                        </p>
                        <c:if test="${empty param.search && empty param.roomType && empty param.status}">
                            <a href="dashboard?section=screening-room-management&action=create&cinemaId=${param.cinemaFilter}" 
                               class="btn btn-primary btn-lg">
                                <i class="bi bi-plus-circle"></i> Create First Room
                            </a>
                        </c:if>
                        <c:if test="${not empty param.search || not empty param.roomType || not empty param.status}">
                            <a href="dashboard?section=screening-room-management&locationFilter=${param.locationFilter}&cinemaFilter=${param.cinemaFilter}" 
                               class="btn btn-outline-secondary btn-lg">
                                <i class="bi bi-arrow-clockwise"></i> Clear Filters
                            </a>
                        </c:if>
                    </div>
                </c:otherwise>
            </c:choose>
        </c:when>
        <c:otherwise>
            <!-- Initial State - Before selecting filters -->
            <div class="text-center py-5">
                <div class="empty-state-icon mb-4">
                    <i class="bi bi-building display-1 text-muted"></i>
                </div>
                <h3 class="h4 text-muted mb-3">Select Location and Cinema</h3>
                <p class="text-muted mb-4">
                    Please select both a location and a cinema from the filters above to view and manage screening rooms.
                </p>
                <div class="row justify-content-center">
                    <div class="col-md-6">
                        <div class="card">
                            <div class="card-body">
                                <h5 class="card-title">How it works</h5>
                                <ol class="text-start text-muted">
                                    <li>Select a <strong>Location</strong> from the dropdown</li>
                                    <li>Choose a <strong>Cinema</strong> from the available options</li>
                                    <li>View and manage screening rooms for the selected cinema</li>
                                </ol>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </c:otherwise>
    </c:choose>
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
                <div class="card border-warning">
                    <div class="card-body">
                        <p class="mb-1"><strong>Room Name:</strong> <span id="deleteRoomName" class="fw-bold"></span></p>
                        <p class="mb-1"><strong>Cinema:</strong> <span id="deleteCinemaName"></span></p>
                        <p class="mb-1"><strong>Seat Capacity:</strong> <span id="deleteSeatCapacity"></span></p>
                        <p class="mb-0"><strong>Room Type:</strong> <span id="deleteRoomType"></span></p>
                    </div>
                </div>
                <div class="alert alert-warning mt-3">
                    <i class="bi bi-exclamation-triangle-fill"></i> 
                    <strong>Warning:</strong> This action cannot be undone. All related seats and scheduled screenings will also be deleted.
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                <form id="deleteRoomForm" method="POST" action="dashboard">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="section" value="screening-room-management">
                    <input type="hidden" name="id" id="deleteRoomId">
                    <button type="submit" class="btn btn-danger">
                        <i class="bi bi-trash"></i> Delete Room
                    </button>
                </form>
            </div>
        </div>
    </div>
</div>

<script>
    // Delete modal function
    function showDeleteModal(roomId, roomName) {
        // Find the room details from the table
        const roomRow = document.querySelector(`tr:has(button[onclick="showDeleteModal(${roomId}, '${roomName}')"])`);
        if (roomRow) {
            const cinemaName = roomRow.cells[1].querySelector('small').textContent;
            const seatCapacity = roomRow.cells[3].querySelector('.fw-semibold').textContent;
            const roomType = roomRow.cells[2].querySelector('.badge').textContent.trim();

            document.getElementById('deleteRoomName').textContent = roomName;
            document.getElementById('deleteCinemaName').textContent = cinemaName;
            document.getElementById('deleteSeatCapacity').textContent = seatCapacity + ' seats';
            document.getElementById('deleteRoomType').textContent = roomType;
        } else {
            document.getElementById('deleteRoomName').textContent = roomName;
            document.getElementById('deleteCinemaName').textContent = 'N/A';
            document.getElementById('deleteSeatCapacity').textContent = 'N/A';
            document.getElementById('deleteRoomType').textContent = 'N/A';
        }

        document.getElementById('deleteRoomId').value = roomId;

        const deleteModal = new bootstrap.Modal(document.getElementById('deleteConfirmModal'));
        deleteModal.show();
    }

    // Initialize on page load - disable cinema filter if no location selected
    document.addEventListener('DOMContentLoaded', function () {
        const locationFilter = document.getElementById('locationFilter');
        const cinemaFilter = document.getElementById('cinemaFilter');

        // Auto-enable cinema filter when location is selected
        if (locationFilter && cinemaFilter) {
            locationFilter.addEventListener('change', function () {
                if (this.value && this.value !== 'none') {
                    cinemaFilter.disabled = false;
                } else {
                    cinemaFilter.disabled = true;
                    cinemaFilter.value = 'none';
                }
            });

            // Auto-submit cinema form when cinema is selected
            cinemaFilter.addEventListener('change', function () {
                if (this.value && this.value !== 'none') {
                    this.form.submit();
                }
            });
        }

        // Search form validation
        const searchForm = document.querySelector('form[action="dashboard"]');
        if (searchForm) {
            searchForm.addEventListener('submit', function (e) {
                const searchInput = this.querySelector('input[name="search"]');
                const roomTypeInput = this.querySelector('input[name="roomType"]');
                const statusInput = this.querySelector('input[name="status"]');

                // Ensure roomType and status are set to 'all' if empty
                if (!roomTypeInput.value) {
                    roomTypeInput.value = 'all';
                }
                if (!statusInput.value) {
                    statusInput.value = 'all';
                }

                // If search is empty, still submit the form to clear search
                // but ensure other filters are preserved
                if (searchInput.value.trim() === '' && ('${param.search}' !== '')) {
                    // This will trigger the search with empty string to clear previous search
                    return true;
                }
            });
        }
    });
</script>

<style>
    /* Additional CSS to ensure dropdowns appear above table */
    .dropdown-menu {
        z-index: 1060 !important;
    }

    .btn-group .dropdown {
        position: static;
    }

    .btn-group .dropdown-menu {
        position: absolute !important;
        top: 100% !important;
        left: 0 !important;
        right: auto !important;
    }

    /* Ensure the action bar has higher z-index */
    .card.mb-4 {
        position: relative;
        z-index: 100;
    }

    /* Ensure table has lower z-index */
    .card .table-responsive {
        position: relative;
        z-index: 1;
    }
</style>