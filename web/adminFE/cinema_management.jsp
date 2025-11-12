<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<div id="cinema-management-content">
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
    <!-- Search Bar + Actions (LUÔN HIỆN) -->
    <div class="d-flex justify-content-between align-items-center mb-3">
        <!-- Search Bar -->
        <div class="w-50">
            <form action="dashboard" method="GET" class="input-group">
                <input type="text" name="search" class="form-control" placeholder="Search cinemas by name or address..." 
                       value="${requestScope.search}" aria-label="Search cinemas">
                <input type="hidden" name="page" value="1">
                <input type="hidden" name="section" value="cinema-management">
                <button class="btn btn-outline-secondary" type="submit">
                    <i class="bi bi-search"></i> Search
                </button>
            </form>
        </div>

        <!-- Filter and Action Buttons -->
        <div class="d-flex">
            <!-- Location Filter Dropdown -->
            <div class="dropdown me-2">
                <button class="btn btn-outline-secondary dropdown-toggle" type="button" 
                        data-bs-toggle="dropdown" aria-expanded="false">
                    <c:choose>
                        <c:when test="${not empty requestScope.locationFilter && requestScope.locationFilter != 'all'}">
                            Location: ${requestScope.locationFilter}
                        </c:when>
                        <c:otherwise>
                            Filter by Location
                        </c:otherwise>
                    </c:choose>
                </button>
                <ul class="dropdown-menu">
                    <li><a class="dropdown-item" href="dashboard?section=cinema-management&location=all&status=${requestScope.statusFilter}&search=${requestScope.search}">All Locations</a></li>
                    <li><hr class="dropdown-divider"></li>
                    <c:forEach var="location" items="${requestScope.allLocations}">
                        <li><a class="dropdown-item" href="dashboard?section=cinema-management&location=${location}&status=${requestScope.statusFilter}&search=${requestScope.search}">${location}</a></li>
                    </c:forEach>
                </ul>
            </div>

            <!-- Status Filter Dropdown -->
            <div class="dropdown me-2">
                <button class="btn btn-outline-secondary dropdown-toggle" type="button" 
                        data-bs-toggle="dropdown" aria-expanded="false">
                    <c:choose>
                        <c:when test="${not empty requestScope.statusFilter && requestScope.statusFilter != 'all'}">
                            Status: ${requestScope.statusFilter}
                        </c:when>
                        <c:otherwise>
                            Filter by Status
                        </c:otherwise>
                    </c:choose>
                </button>
                <ul class="dropdown-menu">
                    <li><a class="dropdown-item" href="dashboard?section=cinema-management&status=all&location=${requestScope.locationFilter}&search=${requestScope.search}">All Statuses</a></li>
                    <li><hr class="dropdown-divider"></li>
                    <li><a class="dropdown-item" href="dashboard?section=cinema-management&status=active&location=${requestScope.locationFilter}&search=${requestScope.search}">Active</a></li>
                    <li><a class="dropdown-item" href="dashboard?section=cinema-management&status=inactive&location=${requestScope.locationFilter}&search=${requestScope.search}">Inactive</a></li>
                </ul>
            </div>

            <!-- Actions Dropdown -->
            <div class="dropdown">
                <button class="btn btn-outline-secondary dropdown-toggle" type="button" 
                        data-bs-toggle="dropdown" aria-expanded="false">
                    Actions
                </button>
                <ul class="dropdown-menu">
                    <li><a class="dropdown-item" href="#" data-bs-toggle="modal" data-bs-target="#addCinemaModal">
                            <i class="bi bi-plus-circle"></i> Add New Cinema
                        </a></li>
                    <li><hr class="dropdown-divider"></li>
                    <li><a class="dropdown-item" href="dashboard?section=cinema-management&sort=name_asc&status=${requestScope.statusFilter}&location=${requestScope.locationFilter}&search=${requestScope.search}">
                            <i class="bi bi-sort-alpha-down"></i> Sort by Name A-Z
                        </a></li>
                    <li><a class="dropdown-item" href="dashboard?section=cinema-management&sort=name_desc&status=${requestScope.statusFilter}&location=${requestScope.locationFilter}&search=${requestScope.search}">
                            <i class="bi bi-sort-alpha-down-alt"></i> Sort by Name Z-A
                        </a></li>
                </ul>
            </div>
        </div>
    </div>

    <!-- Active Filters Display -->
    <c:if test="${requestScope.statusFilter != 'all' or requestScope.locationFilter != 'all' or not empty requestScope.search}">
        <div class="active-filters mb-3">
            <span class="badge bg-light text-dark me-2">
                <i class="bi bi-funnel"></i> Current Filters:
            </span>
            <c:if test="${not empty requestScope.search}">
                <span class="badge bg-info me-2">
                    Search: "${requestScope.search}"
                    <a href="dashboard?section=cinema-management&status=${requestScope.statusFilter}&location=${requestScope.locationFilter}" class="text-white ms-1">
                        <i class="bi bi-x"></i>
                    </a>
                </span>
            </c:if>
            <c:if test="${requestScope.statusFilter != 'all'}">
                <span class="badge bg-warning me-2">
                    Status: ${requestScope.statusFilter}
                    <a href="dashboard?section=cinema-management&location=${requestScope.locationFilter}&search=${requestScope.search}" class="text-white ms-1">
                        <i class="bi bi-x"></i>
                    </a>
                </span>
            </c:if>
            <c:if test="${requestScope.locationFilter != 'all'}">
                <span class="badge bg-success me-2">
                    Location: ${requestScope.locationFilter}
                    <a href="dashboard?section=cinema-management&status=${requestScope.statusFilter}&search=${requestScope.search}" class="text-white ms-1">
                        <i class="bi bi-x"></i>
                    </a>
                </span>
            </c:if>
            <a href="dashboard?section=cinema-management" class="btn btn-sm btn-outline-secondary">
                <i class="bi bi-x-circle"></i> Clear All
            </a>
        </div>
    </c:if>

    <!-- Phần hiển thị table - CHỈ HIỆN KHI KHÔNG PHẢI ĐANG VIEW CINEMA -->
    <c:if test="${empty requestScope.viewCinema}">
        <c:choose>
            <c:when test="${not empty listCinemas}">
                <table class="table table-bordered table-hover">
                    <thead class="table-light">
                        <tr>
                            <th>No.</th>
                            <th>Cinema Name</th>
                            <th>Location</th>
                            <th>Address</th>
                            <th>Total Rooms</th>
                            <th>Status</th>
                            <th>Created Date</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="cinema" items="${requestScope.listCinemas}" varStatus="loop">
                            <tr>
                                <td>${(currentPage - 1) * recordsPerPage + loop.index + 1}</td>
                                <td>${cinema.cinemaName}</td>
                                <td>
                                    <span class="badge bg-primary">${cinema.location}</span>
                                </td>
                                <td class="address-cell">${cinema.address}</td>
                                <td>${cinema.totalRooms}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${cinema.active}">
                                            <span class="badge bg-success">Active</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge bg-danger">Inactive</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${not empty cinema.createdDate}">
                                            ${cinema.createdDate}
                                        </c:when>
                                        <c:otherwise>
                                            N/A
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <form action="dashboard" method="GET" style="display:inline;">
                                        <input type="hidden" name="action" value="view"/>
                                        <input type="hidden" name="cinemaId" value="${cinema.cinemaID}"/>
                                        <input type="hidden" name="section" value="cinema-management"/>
                                        <button type="submit" class="btn btn-sm btn-info me-1">View</button>
                                    </form>
                                    <button class="btn btn-sm btn-danger" 
                                            onclick="showDeleteModal(
                                                            '${cinema.cinemaID}',
                                                            '${cinema.cinemaName}',
                                                            '${cinema.location}',
                                                            '${cinema.address}',
                                                            '${cinema.totalRooms}'
                                                            )">Delete</button>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>

                <!-- Phân trang (chỉ hiện khi có dữ liệu) -->
                <nav aria-label="Page navigation">
                    <ul class="pagination justify-content-center" id="pagination">
                        <c:if test="${currentPage > 1}">
                            <li class="page-item">
                                <a class="page-link" href="dashboard?section=cinema-management&page=${currentPage-1}&status=${requestScope.statusFilter}&location=${requestScope.locationFilter}&search=${requestScope.search}" aria-label="Previous">
                                    <span aria-hidden="true">&laquo;</span>
                                </a>
                            </li>
                        </c:if>

                        <c:forEach begin="1" end="${noOfPages}" var="i">
                            <c:choose>
                                <c:when test="${currentPage eq i}">
                                    <li class="page-item active"><a class="page-link" href="#">${i}</a></li>
                                    </c:when>
                                    <c:otherwise>
                                    <li class="page-item"><a class="page-link" href="dashboard?section=cinema-management&page=${i}&status=${requestScope.statusFilter}&location=${requestScope.locationFilter}&search=${requestScope.search}">${i}</a></li>
                                    </c:otherwise>
                                </c:choose>
                            </c:forEach>

                        <c:if test="${currentPage lt noOfPages}">
                            <li class="page-item">
                                <a class="page-link" href="dashboard?section=cinema-management&page=${currentPage+1}&status=${requestScope.statusFilter}&location=${requestScope.locationFilter}&search=${requestScope.search}" aria-label="Next">
                                    <span aria-hidden="true">&raquo;</span>
                                </a>
                            </li>
                        </c:if>
                    </ul>
                </nav>
            </c:when>

            <c:otherwise>
                <div class="empty-state-container text-center py-5">
                    <!-- SVG trực tiếp - Biểu tượng rạp chiếu phim với dấu gạch chéo -->
                    <svg xmlns="http://www.w3.org/2000/svg" width="100" height="100" viewBox="0 0 24 24" fill="none" stroke="#6c757d" stroke-width="1" class="mb-4">
                    <rect x="2" y="4" width="20" height="16" rx="2" ry="2"></rect>
                    <line x1="2" y1="8" x2="22" y2="8"></line>
                    <line x1="2" y1="12" x2="22" y2="12"></line>
                    <line x1="2" y1="16" x2="22" y2="16"></line>
                    <line x1="6" y1="20" x2="18" y2="20"></line>
                    <line x1="3" y1="3" x2="21" y2="21" stroke="#dc3545" stroke-width="1.5"></line>
                    </svg>

                    <!-- Tiêu đề và mô tả -->
                    <div class="empty-state-content">
                        <h3 class="empty-state-title text-muted mb-3">
                            <i class="bi bi-camera-reels text-primary"></i> No Cinemas Found
                        </h3>
                        <p class="empty-state-description text-secondary mb-4">
                            No results match your current filters.<br>
                            Try adjusting your search criteria or add a new cinema.
                        </p>

                        <c:if test="${not empty requestScope.search or requestScope.statusFilter != 'all' or requestScope.locationFilter != 'all'}">
                            <div class="active-filters mb-4">
                                <span class="badge bg-light text-dark me-2">
                                    <i class="bi bi-funnel"></i> Current Filters:
                                </span>
                                <c:if test="${not empty requestScope.search}">
                                    <span class="badge bg-info me-2">
                                        Search: "${requestScope.search}"
                                    </span>
                                </c:if>
                                <c:if test="${requestScope.statusFilter != 'all'}">
                                    <span class="badge bg-warning me-2">
                                        Status: ${requestScope.statusFilter}
                                    </span>
                                </c:if>
                                <c:if test="${requestScope.locationFilter != 'all'}">
                                    <span class="badge bg-success me-2">
                                        Location: ${requestScope.locationFilter}
                                    </span>
                                </c:if>
                            </div>
                        </c:if>

                        <!-- Các action buttons -->
                        <div class="d-flex justify-content-center gap-3">
                            <a href="dashboard?section=cinema-management" class="btn btn-primary">
                                <i class="bi bi-arrow-counterclockwise"></i> Reset Filters
                            </a>
                            <button class="btn btn-outline-primary" data-bs-toggle="modal" data-bs-target="#addCinemaModal">
                                <i class="bi bi-plus-circle"></i> Add New Cinema
                            </button>
                        </div>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
    </c:if>

    <!-- Add Cinema Modal -->
    <div class="modal fade" id="addCinemaModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <form id="addCinemaForm" action="dashboard" method="POST">
                    <input type="hidden" name="action" value="add">
                    <input type="hidden" name="section" value="cinema-management">
                    <div class="modal-header">
                        <h5 class="modal-title">Add New Cinema</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <div class="mb-3">
                            <label class="form-label">Cinema Name <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" name="cinemaName" placeholder="Ex: CGV Vincom Center, Lotte Cinema, etc..." required>
                            <div class="invalid-feedback">Please enter cinema name.</div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Location <span class="text-danger">*</span></label>
                            <select class="form-select" name="location" required>
                                <option value="">Select Location</option>
                                <c:forEach var="location" items="${requestScope.allLocations}">
                                    <option value="${location}">${location}</option>
                                </c:forEach>
                            </select>
                            <div class="invalid-feedback">Please select location.</div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Address <span class="text-danger">*</span></label>
                            <textarea class="form-control" name="address" rows="3" placeholder="Enter detailed address..." required></textarea>
                            <div class="invalid-feedback">Please enter address.</div>
                        </div>
                        <div class="mb-3">
                            <div class="form-check form-switch">
                                <input class="form-check-input" type="checkbox" name="isActive" id="isActiveSwitch" checked>
                                <label class="form-check-label" for="isActiveSwitch">
                                    Active Cinema
                                </label>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary">Add Cinema</button>
                    </div>
                </form>
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
                    <p>Are you sure you want to delete the following cinema?</p>
                    <div class="card">
                        <div class="card-body">
                            <p class="mb-1"><strong>Cinema Name:</strong> <span id="deleteCinemaName"></span></p>
                            <p class="mb-1"><strong>Location:</strong> <span id="deleteCinemaLocation"></span></p>
                            <p class="mb-1"><strong>Address:</strong> <span id="deleteCinemaAddress"></span></p>
                            <p class="mb-1"><strong>Total Rooms:</strong> <span id="deleteCinemaRooms"></span></p>
                        </div>
                    </div>
                    <div class="alert alert-warning mt-3">
                        <i class="bi bi-exclamation-triangle-fill"></i> This action cannot be undone. All related data will be affected.
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <form id="deleteCinemaForm" method="POST" action="dashboard">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="section" value="cinema-management">
                        <input type="hidden" name="cinemaId" id="deleteCinemaIdInput">
                        <button type="submit" class="btn btn-danger">Delete</button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <!-- View Cinema Modal -->
    <div class="modal fade" id="viewCinemaModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Cinema Details</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <form id="cinemaForm" action="dashboard" method="POST">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="section" value="cinema-management">
                    <input type="hidden" name="cinemaId" value="${requestScope.viewCinema.cinemaID}">
                    <div class="modal-body">
                        <div class="row">
                            <div class="col-md-6">
                                <div class="mb-3">
                                    <label class="form-label">Cinema Name <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control" name="cinemaName" value="${requestScope.viewCinema.cinemaName}" ${param.mode != 'edit' ? 'readonly' : ''} required>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Location <span class="text-danger">*</span></label>
                                    <c:choose>
                                        <c:when test="${param.mode == 'edit'}">
                                            <select class="form-select" name="location" ${param.mode != 'edit' ? 'disabled' : ''} required>
                                                <c:forEach var="location" items="${requestScope.allLocations}">
                                                    <option value="${location}" ${requestScope.viewCinema.location == location ? 'selected' : ''}>${location}</option>
                                                </c:forEach>
                                            </select>
                                        </c:when>
                                        <c:otherwise>
                                            <input type="text" class="form-control" value="${requestScope.viewCinema.location}" readonly>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="mb-3">
                                    <label class="form-label">Address <span class="text-danger">*</span></label>
                                    <textarea class="form-control" name="address" ${param.mode != 'edit' ? 'readonly' : ''} required>${requestScope.viewCinema.address}</textarea>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Status</label>
                                    <div class="form-check form-switch">
                                        <input class="form-check-input" type="checkbox" name="isActive" id="viewIsActive" ${requestScope.viewCinema.active ? 'checked' : ''} ${param.mode != 'edit' ? 'disabled' : ''}>
                                        <label class="form-check-label" for="viewIsActive">
                                            ${requestScope.viewCinema.active ? 'Active' : 'Inactive'}
                                        </label>
                                    </div>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Created Date</label>
                                    <input type="text" class="form-control" value="${requestScope.viewCinema.createdDate}" readonly>
                                </div>
                            </div>
                        </div>
                        
                        <!-- DANH SÁCH PHÒNG CHIẾU -->
                        <div class="mt-4">
                            <h6 class="border-bottom pb-2">
                                <i class="bi bi-door-open"></i> Screening Rooms
                                <span class="badge bg-primary ms-2">${requestScope.viewCinema.totalRooms} rooms</span>
                            </h6>
                            
                            <c:choose>
                                <c:when test="${not empty requestScope.screeningRooms}">
                                    <div class="table-responsive">
                                        <table class="table table-sm table-striped">
                                            <thead class="table-light">
                                                <tr>
                                                    <th>Room Name</th>
                                                    <th>Seat Capacity</th>
                                                    <th>Room Type</th>
                                                    <th>Status</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach var="room" items="${requestScope.screeningRooms}">
                                                    <tr>
                                                        <td>${room.roomName}</td>
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
                                                    </tr>
                                                </c:forEach>
                                            </tbody>
                                        </table>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="text-center py-3 text-muted">
                                        <i class="bi bi-door-closed display-4"></i>
                                        <p class="mt-2">No screening rooms found for this cinema.</p>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    <div class="modal-footer justify-content-between">
                        <c:choose>
                            <c:when test="${param.mode == 'edit'}">
                                <button type="submit" class="btn btn-success">Save Changes</button>
                                <a href="dashboard?section=cinema-management&action=view&cinemaId=${requestScope.viewCinema.cinemaID}" class="btn btn-secondary">Cancel</a>
                            </c:when>
                            <c:otherwise>
                                <a href="dashboard?section=cinema-management&action=view&cinemaId=${requestScope.viewCinema.cinemaID}&mode=edit" class="btn btn-warning">Edit</a>
                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Toast Container -->
    <div id="toastContainer" class="position-fixed top-0 end-0 p-3" style="z-index: 1060"></div>

    <!-- JavaScript functions -->
    <script>
        // ===== MAIN INITIALIZATION =====
        document.addEventListener('DOMContentLoaded', function () {
            initializeAddCinemaForm();
            initializeViewCinemaModal();
            showToasts();
        });

        // ===== TOAST SYSTEM =====
        function showToasts() {
            <c:if test="${not empty sessionScope.toastType}">
                <c:choose>
                    <c:when test="${sessionScope.toastType == 'success'}">
                        showToast('✅ ${sessionScope.toastMessage}', 'success');
                    </c:when>
                    <c:when test="${sessionScope.toastType == 'danger'}">
                        showToast('❌ ${sessionScope.toastMessage}', 'danger');
                    </c:when>
                    <c:when test="${sessionScope.toastType == 'warning'}">
                        showToast('⚠️ ${sessionScope.toastMessage}', 'warning');
                    </c:when>
                </c:choose>
                <c:remove var="toastType" scope="session"/>
                <c:remove var="toastMessage" scope="session"/>
            </c:if>
            
            <%-- Giữ lại phần cũ để tương thích ngược --%>
            <c:if test="${not empty sessionScope.showToast}">
                <c:choose>
                    <c:when test="${sessionScope.showToast == 'add_success'}">
                        showToast('✅ Cinema created successfully!', 'success');
                    </c:when>
                    <c:when test="${sessionScope.showToast == 'add_error'}">
                        showToast('❌ Failed to create cinema!', 'danger');
                    </c:when>
                    <c:when test="${sessionScope.showToast == 'add_error_name'}">
                        showToast('❌ Cinema name already exists!', 'danger');
                    </c:when>
                    <c:when test="${sessionScope.showToast == 'update_success'}">
                        showToast('✅ Cinema updated successfully!', 'success');
                    </c:when>
                    <c:when test="${sessionScope.showToast == 'update_error'}">
                        showToast('❌ Failed to update cinema!', 'danger');
                    </c:when>
                    <c:when test="${sessionScope.showToast == 'delete_success'}">
                        showToast('🗑️ Cinema deleted successfully!', 'success');
                    </c:when>
                    <c:when test="${sessionScope.showToast == 'delete_error'}">
                        showToast('❌ Failed to delete cinema!', 'danger');
                    </c:when>
                </c:choose>
                <c:remove var="showToast" scope="session"/>
                <c:remove var="showError" scope="session"/>
            </c:if>
        }

        function showToast(message, type = 'info') {
            const toastContainer = document.getElementById('toastContainer');
            const toastId = 'toast-' + Date.now();
            
            const bgClass = {
                'success': 'text-bg-success',
                'danger': 'text-bg-danger',
                'warning': 'text-bg-warning',
                'info': 'text-bg-info'
            }[type] || 'text-bg-info';

            const toastHTML = `
                <div id="${toastId}" class="toast ${bgClass} border-0 mb-2" role="alert">
                    <div class="d-flex">
                        <div class="toast-body">${message}</div>
                        <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
                    </div>
                </div>
            `;
            
            toastContainer.insertAdjacentHTML('beforeend', toastHTML);
            const toast = new bootstrap.Toast(document.getElementById(toastId), {
                autohide: true,
                delay: 5000
            });
            toast.show();
            
            // Remove from DOM after hide
            document.getElementById(toastId).addEventListener('hidden.bs.toast', function() {
                this.remove();
            });
        }

        // ===== ADD CINEMA FORM =====
        function initializeAddCinemaForm() {
            const form = document.getElementById('addCinemaForm');
            if (!form) return;

            // Real-time validation
            const fields = form.querySelectorAll('input[required], select[required], textarea[required]');
            fields.forEach(field => {
                field.addEventListener('input', function() {
                    this.classList.remove('is-invalid', 'is-valid');
                    if (this.checkValidity()) {
                        this.classList.add('is-valid');
                    }
                });
                
                field.addEventListener('blur', function() {
                    if (!this.checkValidity()) {
                        this.classList.add('is-invalid');
                    }
                });
            });

            // Form submission
            form.addEventListener('submit', function(e) {
                if (!validateForm(this)) {
                    e.preventDefault();
                    showToast('❌ Please fix the validation errors!', 'error');
                }
            });

            // Reset form when modal closes
            const modal = document.getElementById('addCinemaModal');
            if (modal) {
                modal.addEventListener('hidden.bs.modal', function() {
                    form.reset();
                    form.querySelectorAll('.is-valid, .is-invalid').forEach(el => {
                        el.classList.remove('is-valid', 'is-invalid');
                    });
                });
            }
        }

        function validateForm(form) {
            let isValid = true;
            const fields = form.querySelectorAll('input[required], select[required], textarea[required]');
            
            fields.forEach(field => {
                field.classList.remove('is-invalid', 'is-valid');
                if (!field.checkValidity()) {
                    field.classList.add('is-invalid');
                    isValid = false;
                } else {
                    field.classList.add('is-valid');
                }
            });
            
            return isValid;
        }

        // ===== VIEW CINEMA MODAL =====
        function initializeViewCinemaModal() {
            // Auto-show modal if viewCinema exists
            <c:if test="${requestScope.viewCinema != null}">
                const modal = new bootstrap.Modal(document.getElementById('viewCinemaModal'));
                modal.show();
            </c:if>

            // Handle modal close redirect
            const viewModal = document.getElementById('viewCinemaModal');
            if (viewModal) {
                viewModal.addEventListener('hidden.bs.modal', function() {
                    window.location.href = 'dashboard?section=cinema-management&page=${currentPage}';
                });
            }
        }

        // ===== DELETE MODAL =====
        function showDeleteModal(cinemaId, cinemaName, location, address, totalRooms) {
            document.getElementById('deleteCinemaName').textContent = cinemaName;
            document.getElementById('deleteCinemaLocation').textContent = location;
            document.getElementById('deleteCinemaAddress').textContent = address;
            document.getElementById('deleteCinemaRooms').textContent = totalRooms;
            document.getElementById('deleteCinemaIdInput').value = cinemaId;

            const modal = new bootstrap.Modal(document.getElementById('deleteConfirmModal'));
            modal.show();
        }

        // ===== UTILITY FUNCTIONS =====
        function enableEditMode() {
            console.log('Edit mode enabled');
        }
    </script>

    <style>
        /* CSS cho validation */
        .is-invalid {
            border-color: #dc3545 !important;
        }

        .invalid-feedback {
            display: none;
            width: 100%;
            margin-top: 0.25rem;
            font-size: 0.875em;
            color: #dc3545;
        }

        .is-invalid ~ .invalid-feedback {
            display: block;
        }

        /* CSS cho address cell trong bảng */
        .address-cell {
            max-width: 200px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        /* CSS cho các trường readonly trong modal edit */
        .form-control[readonly] {
            background-color: #f8f9fa !important;
            border-color: #e9ecef !important;
            color: #6c757d !important;
            cursor: not-allowed !important;
            opacity: 0.8 !important;
        }

        .form-control:not([readonly]) {
            background-color: #ffffff !important;
            border-color: #ced4da !important;
            color: #212529 !important;
        }

        /* Đảm bảo select box khi disabled cũng có style tương tự */
        .form-select:disabled {
            background-color: #f8f9fa !important;
            border-color: #e9ecef !important;
            color: #6c757d !important;
            cursor: not-allowed !important;
            opacity: 0.8 !important;
        }

        .form-select:not(:disabled) {
            background-color: #ffffff !important;
            border-color: #ced4da !important;
            color: #212529 !important;
        }

        /* Style cho textarea readonly */
        textarea.form-control[readonly] {
            background-color: #f8f9fa !important;
            border-color: #e9ecef !important;
            color: #6c757d !important;
            resize: none !important;
        }

        /* Hiệu ứng chuyển tiếp mượt mà khi chuyển giữa edit và view mode */
        .form-control,
        .form-select {
            transition: all 0.3s ease-in-out;
        }

        /* Label style để phân biệt rõ hơn */
        .modal-body label {
            font-weight: 600;
            margin-bottom: 0.5rem;
            color: #495057;
        }

        /* Khi ở chế độ edit, các field có thể edit sẽ có border highlight */
        .form-select:not(:disabled) {
            border-color: #86b7fe !important;
            box-shadow: 0 0 0 0.25rem rgba(13, 110, 253, 0.25) !important;
        }

        /* Responsive adjustments */
        @media (max-width: 576px) {
            .modal-body .form-control,
            .modal-body .form-select {
                font-size: 14px;
            }
            
            .address-cell {
                max-width: 150px;
            }
        }
    </style>
</div>