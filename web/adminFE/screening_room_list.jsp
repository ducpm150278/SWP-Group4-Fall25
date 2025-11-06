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

    <!-- Filter Section -->
    <div class="row mb-4">
        <div class="col-md-4">
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
        <div class="col-md-4">
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
        <div class="col-md-4 d-flex align-items-end">
            <a href="dashboard?section=screening-room-management" class="btn btn-outline-secondary w-100">
                <i class="bi bi-arrow-clockwise"></i> Reset All
            </a>
        </div>
    </div>

    <!-- Thêm thông báo khi chưa chọn đủ filter -->
    <c:if test="${not hasValidFilters}">
        <div class="alert alert-info mb-4">
            <div class="d-flex align-items-center">
                <i class="bi bi-info-circle-fill me-3 fs-4"></i>
                <div>
                    <h5 class="alert-heading mb-2">Please Select Location and Cinema</h5>
                    <p class="mb-0">To view screening rooms, please select both a location and a cinema from the filters above.</p>
                </div>
            </div>
        </div>
    </c:if>

    <!-- Search and Actions -->
    <div class="d-flex justify-content-between align-items-center mb-3">
        <!-- Search Bar -->
        <div class="w-50">
            <form action="dashboard" method="GET" class="input-group">
                <input type="text" name="search" class="form-control" placeholder="Search rooms by name..." 
                       value="${param.search}" aria-label="Search rooms">
                <input type="hidden" name="page" value="1">
                <input type="hidden" name="section" value="screening-room-management">
                <input type="hidden" name="locationFilter" value="${param.locationFilter}">
                <input type="hidden" name="cinemaFilter" value="${param.cinemaFilter}">
                <input type="hidden" name="roomType" value="${param.roomType}">
                <input type="hidden" name="status" value="${param.status}">
                <button class="btn btn-outline-secondary" type="submit">
                    <i class="bi bi-search"></i> Search
                </button>
            </form>
        </div>

        <!-- Filter and Action Buttons -->
        <div class="d-flex">
            <!-- Room Type Filter -->
            <div class="dropdown me-2">
                <button class="btn btn-outline-secondary dropdown-toggle" type="button" 
                        data-bs-toggle="dropdown" aria-expanded="false">
                    <c:choose>
                        <c:when test="${not empty param.roomType && param.roomType != 'all'}">
                            Type: ${param.roomType}
                        </c:when>
                        <c:otherwise>
                            All Types
                        </c:otherwise>
                    </c:choose>
                </button>
                <ul class="dropdown-menu">
                    <li><a class="dropdown-item" href="dashboard?section=screening-room-management&roomType=all&status=${param.status}&locationFilter=${param.locationFilter}&cinemaFilter=${param.cinemaFilter}&search=${param.search}">All Types</a></li>
                    <li><hr class="dropdown-divider"></li>
                        <c:forEach var="roomType" items="${allRoomTypes}">
                        <li><a class="dropdown-item" href="dashboard?section=screening-room-management&roomType=${roomType}&status=${param.status}&locationFilter=${param.locationFilter}&cinemaFilter=${param.cinemaFilter}&search=${param.search}">${roomType}</a></li>
                        </c:forEach>
                </ul>
            </div>

            <!-- Status Filter -->
            <div class="dropdown me-2">
                <button class="btn btn-outline-secondary dropdown-toggle" type="button" 
                        data-bs-toggle="dropdown" aria-expanded="false">
                    <c:choose>
                        <c:when test="${not empty param.status && param.status != 'all'}">
                            Status: ${param.status}
                        </c:when>
                        <c:otherwise>
                            All Status
                        </c:otherwise>
                    </c:choose>
                </button>
                <ul class="dropdown-menu">
                    <li><a class="dropdown-item" href="dashboard?section=screening-room-management&status=all&roomType=${param.roomType}&locationFilter=${param.locationFilter}&cinemaFilter=${param.cinemaFilter}&search=${param.search}">All Status</a></li>
                    <li><hr class="dropdown-divider"></li>
                    <li><a class="dropdown-item" href="dashboard?section=screening-room-management&status=active&roomType=${param.roomType}&locationFilter=${param.locationFilter}&cinemaFilter=${param.cinemaFilter}&search=${param.search}">Active</a></li>
                    <li><a class="dropdown-item" href="dashboard?section=screening-room-management&status=inactive&roomType=${param.roomType}&locationFilter=${param.locationFilter}&cinemaFilter=${param.cinemaFilter}&search=${param.search}">Inactive</a></li>
                </ul>
            </div>

            <!-- Add Room Button -->
            <a href="dashboard?section=screening-room-management&action=create&cinemaId=${param.cinemaFilter}" 
               class="btn btn-primary ${empty param.cinemaFilter || param.cinemaFilter == 'none' ? 'disabled' : ''}">
                <i class="bi bi-plus-circle"></i> Add New Room
            </a>
        </div>
    </div>

    <!-- Active Filters Display -->
    <c:if test="${(not empty param.locationFilter && param.locationFilter != 'none') || (not empty param.cinemaFilter && param.cinemaFilter != 'none') || not empty param.roomType && param.roomType != 'all' || not empty param.status && param.status != 'all' || not empty param.search}">
        <div class="active-filters mb-3">
            <span class="badge bg-light text-dark me-2">
                <i class="bi bi-funnel"></i> Active Filters:
            </span>
            <c:if test="${not empty param.search}">
                <span class="badge bg-info me-2">
                    Search: "${param.search}"
                    <a href="dashboard?section=screening-room-management&locationFilter=${param.locationFilter}&cinemaFilter=${param.cinemaFilter}&roomType=${param.roomType}&status=${param.status}" class="text-white ms-1">
                        <i class="bi bi-x"></i>
                    </a>
                </span>
            </c:if>
            <c:if test="${not empty param.locationFilter && param.locationFilter != 'none'}">
                <span class="badge bg-primary me-2">
                    Location: ${param.locationFilter}
                    <a href="dashboard?section=screening-room-management&cinemaFilter=${param.cinemaFilter}&roomType=${param.roomType}&status=${param.status}&search=${param.search}" class="text-white ms-1">
                        <i class="bi bi-x"></i>
                    </a>
                </span>
            </c:if>
            <c:if test="${not empty param.cinemaFilter && param.cinemaFilter != 'none'}">
                <c:forEach var="cinema" items="${cinemasByLocation}">
                    <c:if test="${cinema.cinemaID == param.cinemaFilter}">
                        <span class="badge bg-secondary me-2">
                            Cinema: ${cinema.cinemaName}
                            <a href="dashboard?section=screening-room-management&locationFilter=${param.locationFilter}&roomType=${param.roomType}&status=${param.status}&search=${param.search}" class="text-white ms-1">
                                <i class="bi bi-x"></i>
                            </a>
                        </span>
                    </c:if>
                </c:forEach>
            </c:if>
            <c:if test="${not empty param.roomType && param.roomType != 'all'}">
                <span class="badge bg-warning me-2">
                    Type: ${param.roomType}
                    <a href="dashboard?section=screening-room-management&locationFilter=${param.locationFilter}&cinemaFilter=${param.cinemaFilter}&status=${param.status}&search=${param.search}" class="text-white ms-1">
                        <i class="bi bi-x"></i>
                    </a>
                </span>
            </c:if>
            <c:if test="${not empty param.status && param.status != 'all'}">
                <span class="badge bg-success me-2">
                    Status: ${param.status}
                    <a href="dashboard?section=screening-room-management&locationFilter=${param.locationFilter}&cinemaFilter=${param.cinemaFilter}&roomType=${param.roomType}&search=${param.search}" class="text-white ms-1">
                        <i class="bi bi-x"></i>
                    </a>
                </span>
            </c:if>
            <a href="dashboard?section=screening-room-management" class="btn btn-sm btn-outline-secondary">
                <i class="bi bi-x-circle"></i> Clear All
            </a>
        </div>
    </c:if>

    <!-- Rooms List -->
    <c:choose>
        <c:when test="${not empty listRooms}">
            <div class="table-responsive">
                <table class="table table-bordered table-hover">
                    <thead class="table-light">
                        <tr>
                            <th>No.</th>
                            <th>Room Name</th>
                            <th>Cinema</th>
                            <th>Location</th>
                            <th>Seat Capacity</th>
                            <th>Room Type</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <!-- Cập nhật tất cả các link action để giữ filters -->
                        <c:forEach var="room" items="${listRooms}" varStatus="loop">
                            <tr>
                                <td>${(currentPage - 1) * recordsPerPage + loop.index + 1}</td>
                                <td>${room.roomName}</td>
                                <td>${room.cinema.cinemaName}</td>
                                <td>
                                    <span class="badge bg-primary">${room.cinema.location}</span>
                                </td>
                                <td>${room.seatCapacity}</td>
                                <td>
                                    <span class="badge
                                          <c:choose>
                                              <c:when test="${room.roomType == 'VIP'}">bg-warning</c:when>
                                              <c:when test="${room.roomType == 'IMAX'}">bg-info</c:when>
                                              <c:when test="${room.roomType == '3D'}">bg-success</c:when>
                                              <c:otherwise>bg-secondary</c:otherwise>
                                          </c:choose>
                                          ">${room.roomType}</span>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${room.active}">
                                            <span class="badge bg-success">Active</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge bg-danger">Inactive</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <div class="btn-group btn-group-sm">
                                        <!-- View link với filters -->
                                        <a href="dashboard?section=screening-room-management&action=view&id=${room.roomID}&locationFilter=${param.locationFilter}&cinemaFilter=${param.cinemaFilter}&roomType=${param.roomType}&status=${param.status}&search=${param.search}&page=${currentPage}" 
                                           class="btn btn-info">View</a>
                                        <!-- Edit link với filters -->
                                        <a href="dashboard?section=screening-room-management&action=edit&id=${room.roomID}&locationFilter=${param.locationFilter}&cinemaFilter=${param.cinemaFilter}&roomType=${param.roomType}&status=${param.status}&search=${param.search}&page=${currentPage}" 
                                           class="btn btn-warning">Edit</a>
                                        <button class="btn btn-danger" 
                                                onclick="showDeleteModal(${room.roomID}, '${room.roomName}')">
                                            Delete
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>

            <!-- Pagination với filters -->
            <nav aria-label="Page navigation">
                <ul class="pagination justify-content-center">
                    <c:if test="${currentPage > 1}">
                        <li class="page-item">
                            <a class="page-link" href="dashboard?section=screening-room-management&page=${currentPage-1}&locationFilter=${param.locationFilter}&cinemaFilter=${param.cinemaFilter}&roomType=${param.roomType}&status=${param.status}&search=${param.search}">
                                &laquo;
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
                                    <a class="page-link" href="dashboard?section=screening-room-management&page=${i}&locationFilter=${param.locationFilter}&cinemaFilter=${param.cinemaFilter}&roomType=${param.roomType}&status=${param.status}&search=${param.search}">
                                        ${i}
                                    </a>
                                </li>
                            </c:otherwise>
                        </c:choose>
                    </c:forEach>

                    <c:if test="${currentPage lt noOfPages}">
                        <li class="page-item">
                            <a class="page-link" href="dashboard?section=screening-room-management&page=${currentPage+1}&locationFilter=${param.locationFilter}&cinemaFilter=${param.cinemaFilter}&roomType=${param.roomType}&status=${param.status}&search=${param.search}">
                                &raquo;
                            </a>
                        </li>
                    </c:if>
                </ul>
            </nav>
        </c:when>
        <c:otherwise>
            <div class="empty-state-container text-center py-5">
                <svg xmlns="http://www.w3.org/2000/svg" width="100" height="100" viewBox="0 0 24 24" fill="none" stroke="#6c757d" stroke-width="1" class="mb-4">
                <rect x="2" y="4" width="20" height="16" rx="2" ry="2"></rect>
                <line x1="2" y1="8" x2="22" y2="8"></line>
                <line x1="2" y1="12" x2="22" y2="12"></line>
                <line x1="2" y1="16" x2="22" y2="16"></line>
                <line x1="6" y1="20" x2="18" y2="20"></line>
                </svg>
                <h3 class="text-muted mb-3">
                    <c:choose>
                        <c:when test="${not hasValidFilters}">
                            Select Location and Cinema
                        </c:when>
                        <c:otherwise>
                            No Screening Rooms Found
                        </c:otherwise>
                    </c:choose>
                </h3>
                <p class="text-secondary mb-4">
                    <c:choose>
                        <c:when test="${not hasValidFilters}">
                            Please select both a location and a cinema to view screening rooms.
                        </c:when>
                        <c:when test="${empty param.cinemaFilter || param.cinemaFilter == 'none'}">
                            Please select a cinema to view screening rooms.
                        </c:when>
                        <c:otherwise>
                            No screening rooms found for the selected criteria.
                        </c:otherwise>
                    </c:choose>
                </p>
                <c:if test="${not empty param.cinemaFilter && param.cinemaFilter != 'none'}">
                    <a href="dashboard?section=screening-room-management&action=create&cinemaId=${param.cinemaFilter}" class="btn btn-primary">
                        <i class="bi bi-plus-circle"></i> Add First Room
                    </a>
                </c:if>
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
                <div class="card">
                    <div class="card-body">
                        <p class="mb-1"><strong>Room Name:</strong> <span id="deleteRoomName"></span></p>
                        <p class="mb-1"><strong>Cinema:</strong> <span id="deleteCinemaName"></span></p>
                        <p class="mb-0"><strong>Seat Capacity:</strong> <span id="deleteSeatCapacity"></span></p>
                    </div>
                </div>
                <div class="alert alert-warning mt-3">
                    <i class="bi bi-exclamation-triangle-fill"></i> This action cannot be undone. All related seats will also be deleted.
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                <form id="deleteRoomForm" method="POST" action="dashboard">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="section" value="screening-room-management">
                    <input type="hidden" name="id" id="deleteRoomId">
                    <button type="submit" class="btn btn-danger">Delete</button>
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
            const cinemaName = roomRow.cells[2].textContent;
            const seatCapacity = roomRow.cells[4].textContent;

            document.getElementById('deleteRoomName').textContent = roomName;
            document.getElementById('deleteCinemaName').textContent = cinemaName;
            document.getElementById('deleteSeatCapacity').textContent = seatCapacity;
        } else {
            document.getElementById('deleteRoomName').textContent = roomName;
            document.getElementById('deleteCinemaName').textContent = 'N/A';
            document.getElementById('deleteSeatCapacity').textContent = 'N/A';
        }

        document.getElementById('deleteRoomId').value = roomId;

        const deleteModal = new bootstrap.Modal(document.getElementById('deleteConfirmModal'));
        deleteModal.show();
    }

    // Initialize on page load - disable cinema filter if no location selected
    document.addEventListener('DOMContentLoaded', function () {
        const locationFilter = document.getElementById('locationFilter');
        const cinemaFilter = document.getElementById('cinemaFilter');

        // Disable cinema filter if no location is selected
        if (locationFilter && cinemaFilter) {
            if (!locationFilter.value || locationFilter.value === 'none') {
                cinemaFilter.disabled = true;
            }

            // Auto-enable cinema filter when location is selected
            locationFilter.addEventListener('change', function () {
                if (this.value && this.value !== 'none') {
                    cinemaFilter.disabled = false;
                } else {
                    cinemaFilter.disabled = true;
                    cinemaFilter.value = 'none';
                    // Optionally auto-submit to clear cinema filter
                    this.form.submit();
                }
            });
        }
    });
</script>