<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<div id="cinema-management-content">
    <!-- Search Bar + Actions (LUÔN HIỆN) -->
    <div class="d-flex justify-content-between align-items-center mb-3">
        <!-- Search Bar -->
        <div class="w-50">
            <form action="dashboard" method="GET" class="input-group">
                <input type="text" name="search" class="form-control" placeholder="Search cinemas by name or location..." 
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
            <!-- Status Filter Dropdown -->
            <div class="dropdown me-2">
                <button class="btn btn-outline-secondary dropdown-toggle" type="button" 
                        data-bs-toggle="dropdown" aria-expanded="false">
                    Filter by Status
                </button>
                <ul class="dropdown-menu">
                    <li><a class="dropdown-item" href="dashboard?section=cinema-management&status=all&search=${requestScope.search}">All Statuses</a></li>
                    <li><hr class="dropdown-divider"></li>
                    <li><a class="dropdown-item" href="dashboard?section=cinema-management&status=active&search=${requestScope.search}">Active</a></li>
                    <li><a class="dropdown-item" href="dashboard?section=cinema-management&status=inactive&search=${requestScope.search}">Inactive</a></li>
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
                    <li><a class="dropdown-item" href="dashboard?section=cinema-management&sort=name_asc&status=${requestScope.statusFilter}&search=${requestScope.search}">
                            <i class="bi bi-sort-alpha-down"></i> Sort by Name A-Z
                        </a></li>
                    <li><a class="dropdown-item" href="dashboard?section=cinema-management&sort=name_desc&status=${requestScope.statusFilter}&search=${requestScope.search}">
                            <i class="bi bi-sort-alpha-down-alt"></i> Sort by Name Z-A
                        </a></li>
                    <li><a class="dropdown-item" href="dashboard?section=cinema-management&sort=rooms_asc&status=${requestScope.statusFilter}&search=${requestScope.search}">
                            <i class="bi bi-sort-numeric-down"></i> Sort by Rooms (Low to High)
                        </a></li>
                    <li><a class="dropdown-item" href="dashboard?section=cinema-management&sort=rooms_desc&status=${requestScope.statusFilter}&search=${requestScope.search}">
                            <i class="bi bi-sort-numeric-down-alt"></i> Sort by Rooms (High to Low)
                        </a></li>
                </ul>
            </div>
        </div>
    </div>

    <!-- Phần hiển thị table - CHỈ HIỆN KHI KHÔNG PHẢI ĐANG VIEW CINEMA -->
    <c:if test="${empty requestScope.viewCinema}">
        <c:choose>
            <c:when test="${not empty listCinemas}">
                <c:if test="${requestScope.statusFilter != 'all'}">
                    <div class="active-filters mb-4">
                        <span class="badge bg-light text-dark me-2">
                            <i class="bi bi-funnel"></i> Current Filters:
                        </span>
                        <c:if test="${requestScope.statusFilter != 'all'}">
                            <span class="badge bg-warning me-2">
                                Status filter: ${requestScope.statusFilter}
                            </span>
                        </c:if>
                    </div>
                </c:if>
                <table class="table table-bordered table-hover">
                    <thead class="table-light">
                        <tr>
                            <th>No.</th>
                            <th>Cinema Name</th>
                            <th>Location</th>
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
                                <td>${cinema.location}</td>
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
                                <a class="page-link" href="dashboard?section=cinema-management&page=${currentPage-1}&status=${requestScope.statusFilter}&search=${requestScope.search}" aria-label="Previous">
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
                                    <li class="page-item"><a class="page-link" href="dashboard?section=cinema-management&page=${i}&status=${requestScope.statusFilter}&search=${requestScope.search}">${i}</a></li>
                                    </c:otherwise>
                                </c:choose>
                            </c:forEach>

                        <c:if test="${currentPage lt noOfPages}">
                            <li class="page-item">
                                <a class="page-link" href="dashboard?section=cinema-management&page=${currentPage+1}&status=${requestScope.statusFilter}&search=${requestScope.search}" aria-label="Next">
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

                        <c:if test="${not empty requestScope.search != null or requestScope.statusFilter != 'all'}">
                            <div class="active-filters mb-4">
                                <span class="badge bg-light text-dark me-2">
                                    <i class="bi bi-funnel"></i> Current Filters:
                                </span>
                                <c:if test="${not empty requestScope.search}">
                                    <span class="badge bg-info me-2">
                                        Search input: "${requestScope.search}"
                                    </span>
                                </c:if>
                                <c:if test="${requestScope.statusFilter != 'all'}">
                                    <span class="badge bg-warning me-2">
                                        Status filter: ${requestScope.statusFilter}
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
                            <label class="form-label">Cinema Name</label>
                            <input type="text" class="form-control" name="cinemaName" placeholder="Ex: CGV Vincom Center, Lotte Cinema, etc..." required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Location</label>
                            <textarea class="form-control" name="location" rows="3" placeholder="Enter full address..." required></textarea>
                        </div>
                        <!-- ĐÃ XÓA TRƯỜNG TOTAL ROOMS KHI TẠO MỚI -->
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

    <!-- View Cinema Modal - ĐÃ THÊM DANH SÁCH PHÒNG CHIẾU -->
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
                                <div class="mb-2">
                                    <label class="form-label">Cinema Name</label>
                                    <input type="text" class="form-control" name="cinemaName" value="${requestScope.viewCinema.cinemaName}" ${param.mode != 'edit' ? 'readonly' : ''}>
                                </div>
                                <div class="mb-2">
                                    <label class="form-label">Location</label>
                                    <textarea class="form-control" name="location" ${param.mode != 'edit' ? 'readonly' : ''}>${requestScope.viewCinema.location}</textarea>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="mb-2">
                                    <label class="form-label">Total Rooms</label>
                                    <input type="text" class="form-control" value="${requestScope.viewCinema.totalRooms}" readonly>
                                </div>
                                <div class="mb-2">
                                    <label class="form-label">Status</label>
                                    <div class="form-check form-switch">
                                        <input class="form-check-input" type="checkbox" name="isActive" id="viewIsActive" ${requestScope.viewCinema.active ? 'checked' : ''} ${param.mode != 'edit' ? 'disabled' : ''}>
                                        <label class="form-check-label" for="viewIsActive">
                                            ${requestScope.viewCinema.active ? 'Active' : 'Inactive'}
                                        </label>
                                    </div>
                                </div>
                                <div class="mb-2">
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

    <!-- Toasts -->
    <div class="position-fixed bottom-0 end-0 p-3" style="z-index: 1055">
        <!-- Add Toast -->
        <div id="successAddToast" class="toast align-items-center text-bg-success border-0 mb-2" role="alert" aria-live="assertive" aria-atomic="true" data-bs-delay="3000">
            <div class="d-flex">
                <div class="toast-body">✅ New cinema has been added successfully!</div>
                <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
            </div>
        </div>
        <div id="errorAddToast" class="toast align-items-center text-bg-danger border-0 mb-2" role="alert" aria-live="assertive" aria-atomic="true" data-bs-delay="3000">
            <div class="d-flex">
                <div class="toast-body">❌ Failed to add cinema! ${sessionScope.showError}</div>
                <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
            </div>
        </div>
        <div id="errorNameAddToast" class="toast align-items-center text-bg-danger border-0 mb-2" role="alert" aria-live="assertive" aria-atomic="true" data-bs-delay="3000">
            <div class="d-flex">
                <div class="toast-body">❌ Failed to add cinema! Cinema name already exists!</div>
                <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
            </div>
        </div>
        
        <!-- Update Toast -->
        <div id="successUpdateToast" class="toast align-items-center text-bg-success border-0" role="alert" aria-live="assertive" aria-atomic="true" data-bs-delay="3000">
            <div class="d-flex">
                <div class="toast-body">✅ Cinema updated successfully!</div>
                <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
            </div>
        </div>
        <div id="errorUpdateToast" class="toast align-items-center text-bg-danger border-0" role="alert" aria-live="assertive" aria-atomic="true" data-bs-delay="3000">
            <div class="d-flex">
                <div class="toast-body">❌ Failed to update cinema! ${sessionScope.showError}</div>
                <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
            </div>
        </div>
        
        <!-- Delete Toast -->
        <div id="successDeleteToast" class="toast align-items-center text-bg-success border-0" role="alert" aria-live="assertive" aria-atomic="true" data-bs-delay="3000">
            <div class="d-flex">
                <div class="toast-body">🗑️ Cinema has been deleted successfully!</div>
                <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
            </div>
        </div>
        <div id="errorDeleteToast" class="toast align-items-center text-bg-danger border-0" role="alert" aria-live="assertive" aria-atomic="true" data-bs-delay="3000">
            <div class="d-flex">
                <div class="toast-body">❌ Failed to delete cinema! ${sessionScope.showError}</div>
                <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
            </div>
        </div>
    </div>

    <!-- JavaScript functions -->
    <script>
        // Show toast
        document.addEventListener('DOMContentLoaded', function () {
            <c:if test="${not empty sessionScope.showToast}">
                <c:choose>
                    <c:when test="${sessionScope.showToast == 'add_success'}">
                        var successToast = new bootstrap.Toast(document.getElementById('successAddToast'));
                        successToast.show();
                    </c:when>
                    <c:when test="${sessionScope.showToast == 'add_error'}">
                        var errorToast = new bootstrap.Toast(document.getElementById('errorAddToast'));
                        errorToast.show();
                    </c:when>
                    <c:when test="${sessionScope.showToast == 'add_error_name'}">
                        var errorToast = new bootstrap.Toast(document.getElementById('errorNameAddToast'));
                        errorToast.show();
                    </c:when>
                    <c:when test="${sessionScope.showToast == 'update_success'}">
                        var successToast = new bootstrap.Toast(document.getElementById('successUpdateToast'));
                        successToast.show();
                    </c:when>
                    <c:when test="${sessionScope.showToast == 'update_error'}">
                        var errorToast = new bootstrap.Toast(document.getElementById('errorUpdateToast'));
                        errorToast.show();
                    </c:when>
                    <c:when test="${sessionScope.showToast == 'delete_success'}">
                        var successToast = new bootstrap.Toast(document.getElementById('successDeleteToast'));
                        successToast.show();
                    </c:when>
                    <c:when test="${sessionScope.showToast == 'delete_error'}">
                        var errorToast = new bootstrap.Toast(document.getElementById('errorDeleteToast'));
                        errorToast.show();
                    </c:when>
                </c:choose>
                <c:remove var="showToast" scope="session"/>
                <c:remove var="showError" scope="session"/>
            </c:if>

            // Hiển thị modal view khi có dữ liệu viewCinema
            <c:if test="${requestScope.viewCinema != null}">
                var viewModal = new bootstrap.Modal(document.getElementById('viewCinemaModal'));
                viewModal.show();
                
                // Ẩn các phần không cần thiết khi đang view
                document.getElementById('cinema-management-content').querySelectorAll('.table, .empty-state-container, .pagination').forEach(function(el) {
                    el.style.display = 'none';
                });
            </c:if>
        });

        // Hàm hiện modal delete với thông tin của cinema
        function showDeleteModal(cinemaId, cinemaName, location, totalRooms) {
            // Set cinema details in the modal
            document.getElementById('deleteCinemaName').textContent = cinemaName;
            document.getElementById('deleteCinemaLocation').textContent = location;
            document.getElementById('deleteCinemaRooms').textContent = totalRooms;
            document.getElementById('deleteCinemaIdInput').value = cinemaId;

            // Show the modal
            const deleteModal = new bootstrap.Modal(document.getElementById('deleteConfirmModal'));
            deleteModal.show();
        }

        // Form validation
        document.getElementById("addCinemaForm").addEventListener('submit', function (e) {
            // Validation logic nếu cần
        });

        // Xử lý khi modal view bị ẩn
        document.getElementById('viewCinemaModal').addEventListener('hidden.bs.modal', function () {
            // Redirect về trang danh sách
            window.location.href = 'dashboard?section=cinema-management&page=${requestScope.currentPage}';
        });
    </script>
</div>