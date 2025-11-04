<%-- 
    Document   : editScreening
    Created on : 14 thg 10, 2025, 23:46:25
    Author     : admin
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Chỉnh sửa lịch chiếu</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    </head>
    <body class="bg-light">

        <div class="container mt-5">
            <div class="card shadow-sm mx-auto" style="max-width: 800px;">
                <div class="card-header bg-warning text-white text-center">
                    <h4 class="mb-0">Chỉnh sửa lịch chiếu</h4>
                </div>
                <div class="card-body">

                    <form action="${pageContext.request.contextPath}/editScreening" method="post" class="row g-3">

                        <input type="hidden" name="screeningID" value="${screening.screeningID}"/>

                        <!-- Cột trái -->
                        <div class="col-md-6">
                            <!-- Tên phim -->
                            <div class="mb-3">
                                <label class="form-label">Tên phim</label>
                                <select name="movieID" class="form-select" required>
                                    <option value="">-- Chọn phim --</option>
                                    <c:forEach var="m" items="${movies}">
                                        <option value="${m.movieID}" ${m.movieID == screening.movieID ? 'selected' : ''}>
                                            ${m.title}
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>

                            <!-- Rạp chiếu -->
                            <div class="mb-3">
                                <label class="form-label">Rạp chiếu</label>
                                <select id="cinemaSelect" class="form-select" required>
                                    <option value="">-- Chọn rạp --</option>
                                    <c:forEach var="c" items="${cinemas}">
                                        <option value="${c.cinemaID}" ${c.cinemaName == screening.cinemaName ? 'selected' : ''}>
                                            ${c.cinemaName}
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>

                            <!-- Phòng chiếu -->
                            <div class="mb-3">
                                <label class="form-label">Phòng chiếu</label>
                                <select name="roomID" id="roomSelect" class="form-select" required>
                                    <option value="">-- Chọn phòng --</option>
                                    <c:forEach var="r" items="${rooms}">
                                        <option value="${r.roomID}" 
                                                data-cinemaid="${r.cinemaID}"
                                                ${r.roomID == screening.roomID ? 'selected' : ''}>
                                            ${r.roomName} (Sức chứa: ${r.seatCapacity})
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Trạng thái</label>
                                <select name="status" class="form-select" required>
                                    <option value="Active" ${screening.movieStatus == 'Active' ? 'selected' : ''}>Active</option>
                                    <option value="Upcoming" ${screening.movieStatus == 'Upcoming' ? 'selected' : ''}>Upcoming</option>
                                    <option value="Inactive" ${screening.movieStatus == 'Inactive' ? 'selected' : ''}>Inactive</option>
                                    <option value="Cancelled" ${screening.movieStatus == 'Cancelled' ? 'selected' : ''}>Cancelled</option>
                                </select>
                            </div>
                        </div>

                        <!-- Cột phải -->
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label class="form-label">Ngày chiếu</label>
                                <input type="date" 
                                       name="screeningDate" 
                                       class="form-control" 
                                       value="${screening.screeningDate}">

                            </div>

                            <div class="mb-3">
                                <label class="form-label">Khung giờ chiếu</label>
                                <select name="showtime" class="form-select">
                                    <c:forEach var="time" items="${showtimes}">
                                        <option value="${time}" 
                                                ${screening.showtime == time ? 'selected' : ''}>${time}</option>
                                    </c:forEach>
                                </select>
                            </div>

                            <div class="mb-3">
                                <label class="form-label">Giá vé (VNĐ)</label>
                                <input type="number" 
                                       name="baseTicketPrice" 
                                       class="form-control" 
                                       min="0" 
                                       step="1000"
                                       value="${screening.baseTicketPrice}">
                            </div>




                        </div>

                        <!-- Nút thao tác -->
                        <div class="col-12 mt-3">
                            <button type="submit" class="btn btn-primary px-4">Lưu thay đổi</button>
                            <a href="${pageContext.request.contextPath}/listScreening" class="btn btn-secondary px-4">Quay lại</a>
                        </div>
                    </form>

                </div>
            </div>
        </div>

        <!-- ✅ Script lọc phòng theo rạp -->
        <script>
            document.addEventListener("DOMContentLoaded", function () {
                const cinemaSelect = document.getElementById("cinemaSelect");
                const roomSelect = document.getElementById("roomSelect");
                const allRooms = Array.from(roomSelect.options).filter(opt => opt.value !== "");

                cinemaSelect.addEventListener("change", function () {
                    const selectedCinema = this.value;
                    roomSelect.innerHTML = '<option value="">-- Chọn phòng --</option>';

                    allRooms.forEach(opt => {
                        if (opt.dataset.cinemaid === selectedCinema) {
                            roomSelect.appendChild(opt.cloneNode(true));
                        }
                    });
                });
            });
        </script>
        <script>
            document.querySelector("form").addEventListener("submit", function (e) {
                const startInput = document.getElementById("startTime");
                const endInput = document.getElementById("endTime");
                const startError = document.getElementById("startError");
                const endError = document.getElementById("endError");

                // Xóa lỗi cũ
                startError.textContent = "";
                endError.textContent = "";

                // Lấy giá trị ngày
                const start = new Date(startInput.value);
                const end = new Date(endInput.value);
                let valid = true;

                // Kiểm tra bỏ trống
                if (!startInput.value) {
                    startError.textContent = "Vui lòng chọn thời gian bắt đầu.";
                    valid = false;
                }
                if (!endInput.value) {
                    endError.textContent = "Vui lòng chọn thời gian kết thúc.";
                    valid = false;
                }

                // Kiểm tra logic thời gian
                if (startInput.value && endInput.value && end <= start) {
                    endError.textContent = "Thời gian kết thúc phải sau thời gian bắt đầu.";
                    valid = false;
                }

                // Nếu có lỗi thì chặn submit
                if (!valid) {
                    e.preventDefault();
                }
            });
        </script>
        <script>
            // Giới hạn ngày chiếu chỉ được chọn từ hôm nay trở đi
            document.addEventListener("DOMContentLoaded", function () {
                const dateInput = document.querySelector('input[name="screeningDate"]');
                const today = new Date().toISOString().split("T")[0];
                dateInput.setAttribute("min", today);
            });
        </script>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
