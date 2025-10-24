<%-- 
    Document   : addScreening
    Created on : 8 thg 10, 2025, 18:21:39
    Author     : admin
--%>
<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="utf-8"/>
        <title>Thêm lịch chiếu</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    </head>
    <body class="bg-light">
        <div class="container d-flex justify-content-center align-items-center" style="min-height: 70vh;">
            <div class="card shadow-sm w-100" style="max-width: 900px;">
                <div class="card shadow-sm">
                    <div class="card-header bg-primary text-white text-center">
                        <h4 class="mb-0">Thêm lịch chiếu mới</h4>
                    </div>
                    <div class="card-body">
                        <!-- form -->
                        <form action="${pageContext.request.contextPath}/addScreening" method="post" class="row g-3">

                            <!-- Cột 1: Tên phim, Rạp chiếu, Tên phòng -->
                            <div class="col-md-6">
                                <!-- Tên phim -->
                                <div class="mb-3">
                                    <label class="form-label">Tên phim</label>
                                    <select name="movieID" id="movieSelect" class="form-select" required>
                                        <option value="">-- Chọn phim --</option>
                                        <c:forEach var="m" items="${movies}">
                                            <option value="${m.movieID}" data-status="${m.status}">
                                                ${m.title}
                                            </option>
                                        </c:forEach>
                                    </select>
                                </div>

                                <!-- Rạp chiếu -->
                                <div class="mb-3">
                                    <label class="form-label">Rạp chiếu</label>
                                    <select name="cinemaID" id="cinemaSelect" class="form-select" required>
                                        <option value="">-- Chọn rạp --</option>
                                        <c:forEach var="c" items="${cinemas}">
                                            <option value="${c.cinemaID}">${c.cinemaName}</option>
                                        </c:forEach>
                                    </select>
                                </div>

                                <!-- Tên phòng -->
                                <div class="mb-3">
                                    <label class="form-label">Tên phòng</label>
                                    <select name="roomID" id="roomSelect" class="form-select" required>
                                        <option value="">-- Chọn phòng --</option>
                                        <c:forEach var="r" items="${rooms}">
                                            <option value="${r.roomID}" data-cinemaid="${r.cinemaID}">
                                                ${r.roomName} (Sức chứa: ${r.seatCapacity})
                                            </option>
                                        </c:forEach>
                                    </select>
                                </div>
                            </div>

                            <!-- Cột 2: Thời gian bắt đầu/kết thúc + Trạng thái -->
                            <div class="col-md-6">
                                <!-- Thời gian bắt đầu -->
                                <div class="mb-3">
                                    <label class="form-label">Thời gian bắt đầu</label>
                                    <input type="datetime-local" name="startTime" id="startTime" class="form-control" required>
                                </div>

                                <!-- Thời gian kết thúc -->
                                <div class="mb-3">
                                    <label class="form-label">Thời gian kết thúc</label>
                                    <input type="datetime-local" name="endTime" id="endTime" class="form-control" required>
                                </div>

                                <!-- Trạng thái -->
                                <div class="mb-3">
                                    <label class="form-label">Trạng thái</label>
                                    <select name="status" id="statusSelect" class="form-select" required>
                                        <option value="">-- Chọn phim trước --</option>
                                        <option value="Active">Active</option>
                                        <option value="Upcoming">Upcoming</option>
                                        <option value="Inactive">Inactive</option>
                                        <option value="Cancelled">Cancelled</option>
                                    </select>
                                </div>
                            </div>

                            <!-- Buttons -->
                            <div class="col-12 mt-3">
                                <button type="submit" class="btn btn-success">Thêm lịch chiếu mới</button>
                                <a href="${pageContext.request.contextPath}/listScreening" class="btn btn-secondary">Hủy bỏ</a>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <!-- JS -->
        <script>
            (function () {
                const cinemaSelect = document.getElementById('cinemaSelect');
                const roomSelect = document.getElementById('roomSelect');
                const movieSelect = document.getElementById('movieSelect');
                const statusSelect = document.getElementById('statusSelect');

                // 🔹 Lưu danh sách phòng gốc
                const allRooms = Array.from(roomSelect.options);

                // 🏢 Khi chọn rạp → chỉ hiển thị phòng thuộc rạp đó
                function filterRooms() {
                    const cinemaId = cinemaSelect.value;

                    // Xoá tất cả options hiện tại
                    roomSelect.innerHTML = '<option value="">-- Chọn phòng --</option>';

                    // Nếu có chọn rạp thì thêm các phòng thuộc rạp đó
                    if (cinemaId) {
                        allRooms.forEach(opt => {
                            if (opt.dataset.cinemaid === cinemaId) {
                                roomSelect.appendChild(opt.cloneNode(true));
                            }
                        });
                    }
                }

                // 🎬 Cập nhật trạng thái khi chọn phim
                function updateStatus() {
                    const opt = movieSelect.options[movieSelect.selectedIndex];
                    if (!opt || !opt.dataset) {
                        statusSelect.value = "";
                        return;
                    }
                    const st = opt.dataset.status || "";
                    statusSelect.value = st;
                }

                // Gắn sự kiện
                cinemaSelect.addEventListener('change', filterRooms);
                movieSelect.addEventListener('change', updateStatus);

                // Gọi init
                filterRooms();
                updateStatus();
            })();
        </script>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
