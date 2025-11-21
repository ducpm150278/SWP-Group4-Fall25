<!--
================================================================================
FILE: select-seats.jsp
MÔ TẢ: Trang chọn ghế ngồi trong hệ thống đặt vé rạp chiếu phim
CHỨC NĂNG:
    - Hiển thị sơ đồ ghế của phòng chiếu với layout chính xác
    - Cho phép người dùng chọn từ 1-8 ghế
    - Hiển thị trạng thái ghế: trống, đã đặt, đang giữ, bảo trì
    - Phân biệt loại ghế: Thường, VIP, Đôi
    - Tính tổng tiền dựa theo loại ghế đã chọn
    - Tự động cập nhật trạng thái ghế theo thời gian thực (mỗi 5 giây)
    - Giữ chỗ tạm thời (5 phút) khi người dùng chọn ghế
================================================================================
-->
<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@page import="java.util.List" %>
<%@page import="java.util.Map" %>
<%@page import="java.util.HashMap" %>
<%@page import="entity.Seat" %>
<%@page import="entity.Screening" %>
<%@page import="entity.BookingSession" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <!-- Meta tags cho encoding và responsive -->
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chọn Ghế - Cinema Booking</title>

    <!-- Import CSS frameworks và custom styles -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
        rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css"
        rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/select-seats.css">
</head>

<body>
    <!-- 
    =================================================================================
    PHẦN 1: LẤY DỮ LIỆU TỪ REQUEST
    =================================================================================
    Lấy các dữ liệu từ request attributes:
    - screening: Thông tin suất chiếu đã chọn
    - bookingSession: Phiên đặt vé hiện tại
    - allSeats: Danh sách tất cả ghế trong phòng chiếu
    - bookedSeatIDs: Danh sách ID ghế đã được đặt (confirmed)
    - reservedSeatIDs: Danh sách ID ghế đang được giữ tạm (reserved)
    -->
    <%
    Screening screening = (Screening) request.getAttribute("screening");
    BookingSession bookingSession = (BookingSession) request.getAttribute("bookingSession");
    List<Seat> allSeats = (List<Seat>) request.getAttribute("allSeats");
    List<Integer> bookedSeatIDs = (List<Integer>) request.getAttribute("bookedSeatIDs");
    List<Integer> reservedSeatIDs = (List<Integer>) request.getAttribute("reservedSeatIDs");
    @SuppressWarnings("unchecked")
    List<Integer> unavailableStatusSeatIDs = (List<Integer>) request.getAttribute("unavailableStatusSeatIDs");
    %>

    <!-- Loading overlay - Hiển thị khi đang xử lý -->
    <div class="loading-overlay" id="loadingOverlay">
        <div class="loading-spinner"></div>
    </div>

    <!-- 
    =================================================================================
    PHẦN 2: THANH TIẾN TRÌNH ĐẶT VÉ
    =================================================================================
    Thanh tiến trình hiển thị 4 bước đặt vé:
    1. Chọn suất chiếu (đã hoàn thành)
    2. Chọn ghế (đang thực hiện)
    3. Chọn đồ ăn (chưa thực hiện)
    4. Thanh toán (chưa thực hiện)
    -->
    <div class="progress-container">
        <div class="progress-steps">
            <!-- Bước 1: Chọn suất chiếu (đã hoàn thành) -->
            <div class="step completed"
                onclick="window.location.href='${pageContext.request.contextPath}/booking/select-screening'"
                title="Quay lại chọn suất chiếu">
                <div class="step-circle">
                    <i class="fas fa-film"></i>
                </div>
                <span class="step-label">Chọn Suất</span>
            </div>

            <!-- Bước 2: Chọn ghế (đang thực hiện - bước hiện tại) -->
            <div class="step active">
                <div class="step-circle">
                    <i class="fas fa-couch"></i>
                </div>
                <span class="step-label">Chọn Ghế</span>
            </div>

            <!-- Bước 3: Chọn đồ ăn (chưa thực hiện) -->
            <div class="step">
                <div class="step-circle">
                    <i class="fas fa-utensils"></i>
                </div>
                <span class="step-label">Đồ Ăn</span>
            </div>

            <!-- Bước 4: Thanh toán (chưa thực hiện) -->
            <div class="step">
                <div class="step-circle">
                    <i class="fas fa-credit-card"></i>
                </div>
                <span class="step-label">Thanh Toán</span>
            </div>
        </div>
    </div>

    <!-- 
    =================================================================================
    PHẦN 3: NỘI DUNG CHÍNH
    =================================================================================
    -->
    <div class="main-container">
        <!-- Header trang với tiêu đề và hướng dẫn -->
        <div class="page-header">
            <h1><i class="fas fa-couch"></i> Chọn Ghế Ngồi</h1>
            <p>Chọn từ 1 đến 8 ghế để tiếp tục đặt vé</p>
        </div>

    <!-- 
    =================================================================================
    PHẦN 4: THÔNG TIN SUẤT CHIẾU
    =================================================================================
    Hiển thị các thông tin chi tiết về suất chiếu đã chọn
    -->
    <div class="info-section">
        <div class="section-title">
            <i class="fas fa-info-circle"></i>
            <span>Thông Tin Suất Chiếu</span>
        </div>
        <div class="info-grid">
            <!-- Tên phim -->
            <div class="info-item">
                <div class="info-label">Phim</div>
                <div class="info-value">
                    <%= bookingSession.getMovieTitle() %>
                </div>
            </div>

            <!-- Tên rạp -->
            <div class="info-item">
                <div class="info-label">Rạp</div>
                <div class="info-value">
                    <%= bookingSession.getCinemaName() %>
                </div>
            </div>

            <!-- Tên phòng chiếu -->
            <div class="info-item">
                <div class="info-label">Phòng</div>
                <div class="info-value">
                    <%= bookingSession.getRoomName() %>
                </div>
            </div>

            <!-- Giờ chiếu (bắt đầu - kết thúc) -->
            <%
                String timeDisplay = "";
                if (screening != null && screening.getStartTime() != null) {
                    java.time.format.DateTimeFormatter timeFormatter =
                        java.time.format.DateTimeFormatter.ofPattern("HH:mm");
                    String startTime = screening.getStartTime().format(timeFormatter);
                    String endTime = screening.getEndTime() != null
                        ? screening.getEndTime().format(timeFormatter)
                        : "";
                    timeDisplay = endTime.isEmpty() ? startTime : startTime + " - " + endTime;
                }
            %>
                <div class="info-item">
                    <div class="info-label">Giờ chiếu</div>
                    <div class="info-value">
                        <%= timeDisplay %>
                    </div>
                </div>

                <!-- Giá vé cơ bản -->
                <div class="info-item">
                    <div class="info-label">Giá vé</div>
                    <div class="info-value">
                        <%= String.format("%,.0fVNĐ",bookingSession.getTicketPrice())%>
                    </div>
                </div>
        </div>

        <!-- Hiển thị thông báo lỗi (nếu có) -->
        <% if (request.getAttribute("error") != null) { %>
        <div class="alert alert-danger" role="alert">
            <i class="fas fa-exclamation-circle"></i>
            <%= request.getAttribute("error") %>
        </div>
        <% } %>

        <!-- 
        =================================================================================
        PHẦN 5: HIỂN THỊ MÀN HÌNH CHIẾU
        =================================================================================
        Thể hiện vị trí màn hình chiếu phim trong rạp
        -->
        <div class="screen-section">
            <div class="screen-label">MÀN HÌNH</div>
            <div class="screen"></div>
        </div>

        <!-- 
        =================================================================================
        PHẦN 6: SƠ ĐỒ GHẾ
        =================================================================================
        Sơ đồ ghế chính với các tính năng:
        - Ghế được nhóm theo hàng (A, B, C...)
        - Sắp xếp theo số ghế trong mỗi hàng
        - Lối đi ở giữa cho hàng có > 6 ghế
        - Hiển thị trạng thái: trống, đã đặt, đang giữ, bảo trì
        - Phân loại: Thường, VIP, Đôi
        -->
        <div class="seat-map-section">
            <form method="post"
                action="${pageContext.request.contextPath}/booking/select-seats"
                id="seatForm">
                <div class="seat-grid-container" id="seatMap">
                    <%
                        if (allSeats != null && !allSeats.isEmpty()) {
                            Map<String, java.util.List<Seat>> seatsByRow = new java.util.TreeMap<>();

                            for (Seat seat : allSeats) {
                                String row = seat.getSeatRow();
                                seatsByRow.computeIfAbsent(row, key -> new java.util.ArrayList<>()).add(seat);
                            }

                            for (Map.Entry<String, java.util.List<Seat>> entry : seatsByRow.entrySet()) {
                                String rowLabel = entry.getKey();
                                java.util.List<Seat> rowSeats = entry.getValue();

                                java.util.Collections.sort(rowSeats, new java.util.Comparator<Seat>() {
                                    @Override
                                    public int compare(Seat s1, Seat s2) {
                                        try {
                                            int num1 = Integer.parseInt(s1.getSeatNumber());
                                            int num2 = Integer.parseInt(s2.getSeatNumber());
                                            return Integer.compare(num1, num2);
                                        } catch (NumberFormatException e) {
                                            return s1.getSeatNumber().compareTo(s2.getSeatNumber());
                                        }
                                    }
                                });

                                int totalSeats = rowSeats.size();
                                int halfPoint = (totalSeats + 1) / 2;
                    %>
                    <div class="seat-row-container">
                        <div class="row-label">
                            <%= rowLabel.trim() %>
                        </div>

                        <div class="seat-row">
                            <%
                                for (int i = 0; i < rowSeats.size(); i++) {
                                    Seat seat = rowSeats.get(i);

                                    if (i == halfPoint && totalSeats > 6) {
                            %>
                            <div class="seat-aisle"></div>
                            <%
                                    }

                                    String seatClass = "seat";
                                    boolean isBooked = bookedSeatIDs != null && bookedSeatIDs.contains(seat.getSeatID());
                                    boolean isReserved = reservedSeatIDs != null && reservedSeatIDs.contains(seat.getSeatID());
                                    boolean isSelected = bookingSession.getSelectedSeatIDs() != null
                                        && bookingSession.getSelectedSeatIDs().contains(seat.getSeatID());
                                    boolean isMaintenance = "Maintenance".equals(seat.getStatus());
                                    boolean isUnavailable = "Unavailable".equals(seat.getStatus());

                                    if (unavailableStatusSeatIDs != null && unavailableStatusSeatIDs.contains(seat.getSeatID())) {
                                        isUnavailable = true;
                                    }

                                    if (isMaintenance) {
                                        seatClass += " maintenance";
                                    } else if (isUnavailable) {
                                        seatClass += " unavailable";
                                    } else if (isBooked) {
                                        seatClass += " booked";
                                    } else if (isReserved) {
                                        seatClass += " reserved";
                                    } else if (isSelected) {
                                        seatClass += " selected";
                                    }

                                    String seatType = seat.getSeatType();
                                    if ("VIP".equals(seatType)) {
                                        seatClass += " vip";
                                    } else if ("Couple".equals(seatType)) {
                                        seatClass += " couple";
                                    }

                                    boolean isSelectable = !isBooked && !isReserved && !isMaintenance && !isUnavailable;
                            %>
                            <div class="<%= seatClass %>"
                                data-seat-id="<%= seat.getSeatID() %>"
                                data-seat-label="<%= seat.getSeatRow().trim() %><%= seat.getSeatNumber() %>"
                                data-available="<%= isSelectable %>"
                                data-price-multiplier="<%= seat.getPriceMultiplier() %>"
                                data-seat-type="<%= seatType %>">
                                <%= seat.getSeatNumber() %>
                            </div>
                            <%
                                } // end seat loop
                            %>
                        </div>
                    </div>
                    <%
                            } // end row loop
                        } else {
                    %>
                    <div class="text-center text-muted py-4">
                        Không có dữ liệu ghế cho suất chiếu này.
                    </div>
                    <%
                        } // end allSeats check
                    %>
                </div>

                <!-- 
                =================================================================================
                PHẦN 7: CHÚ THÍCH GHẾ
                =================================================================================
                Chú thích màu sắc giải thích các loại ghế và trạng thái
                -->
                <div class="legend-section">
                    <!-- Ghế thường -->
                    <div class="legend-item">
                        <div class="legend-box"
                            style="background: #2a2d35; border: 1px solid #3a3d45;">
                        </div>
                        <span class="legend-text">Ghế
                            thường</span>
                    </div>

                    <!-- Ghế VIP -->
                    <div class="legend-item">
                        <div class="legend-box"
                            style="background: #2f2d2a; border: 1px solid #6b5d3f;">
                        </div>
                        <span class="legend-text">Ghế
                            VIP</span>
                    </div>

                    <!-- Ghế đôi -->
                    <div class="legend-item">
                        <div class="legend-box"
                            style="background: #2d2a2d; border: 1px solid #4a3d45; width: 50px;">
                        </div>
                        <span class="legend-text">Ghế
                            đôi</span>
                    </div>

                    <!-- Ghế đang chọn -->
                    <div class="legend-item">
                        <div class="legend-box"
                            style="background: #e50914; border: 2px solid #e50914;">
                        </div>
                        <span class="legend-text">Đang
                            chọn</span>
                    </div>

                    <!-- Ghế đã đặt -->
                    <div class="legend-item">
                        <div class="legend-box"
                            style="background: #1a1d24; border: 1px solid #1a1d24; opacity: 0.3;">
                        </div>
                        <span class="legend-text">Đã
                            đặt</span>
                    </div>

                    <!-- Ghế đang giữ tạm thời -->
                    <div class="legend-item">
                        <div class="legend-box" style="background: linear-gradient(135deg, #ff9500 0%, #ff7b00 100%); 
                        border: 2px solid #ff9500; position: relative; 
                        display: flex; align-items: center; justify-content: center; 
                        font-family: 'Font Awesome 5 Free'; font-weight: 400;">
                            <span style="color: rgba(255, 255, 255, 0.9); font-size: 12px;">&#xf017;</span>
                        </div>
                        <span class="legend-text">Đang
                            giữ</span>
                    </div>
                </div>
            </form>
        </div>

        <!-- 
        =================================================================================
        PHẦN 8: TỔNG KẾT ĐẶT VÉ
        =================================================================================
        Hiển thị danh sách ghế đã chọn và tổng tiền
        -->
        <div class="summary-section">
            <div class="summary-header">
                <h3 class="section-title">
                    <i class="fas fa-chair"></i>
                    <span>Ghế Đã Chọn</span>
                </h3>
                <!-- Số ghế đã chọn (hiện tại/tối đa) -->
                <div class="summary-count">
                    <span id="selectedCount">0</span>/8
                </div>
            </div>

            <!-- Container hiển thị các tag ghế đã chọn -->
            <div class="seat-tags-container" id="seatTagsContainer">
                <span class="empty-selection">Chưa chọn ghế
                    nào</span>
            </div>

            <!-- Tổng số tiền thanh toán -->
            <div class="total-section">
                <div class="total-label">TỔNG THANH TOÁN
                </div>
                <div class="total-amount" id="totalAmount">0
                    VNĐ</div>
            </div>
        </div>

        <!-- 
        =================================================================================
        PHẦN 9: CÁC NÚT HÀNH ĐỘNG
        =================================================================================
        -->
    <div class="action-section">
        <!-- Nút đặt lại - Xóa tất cả ghế đã chọn -->
        <button type="button" class="btn-action btn-reset"
            onclick="resetSeats()">
            <i class="fas fa-redo"></i> Đặt Lại
        </button>

        <!-- Nút tiếp tục - Chuyển sang trang chọn đồ ăn (vô hiệu hóa khi chưa chọn ghế) -->
        <button type="button" class="btn-action btn-continue"
            id="continueBtn" disabled onclick="submitForm()">
            <i class="fas fa-arrow-right"></i> Tiếp Tục
        </button>
    </div>
</div>

<!-- Import Bootstrap JavaScript -->
<script
    src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<script>
    /*
    =================================================================================
    JAVASCRIPT - LOGIC CHỌN GHẾ
    =================================================================================
    Script này xử lý:
    1. Chọn/bỏ chọn ghế với giới hạn tối đa
    2. Tính toán giá theo thời gian thực dựa trên loại ghế
    3. Tự động cập nhật trạng thái ghế (mỗi 5 giây)
    4. Submit form với dữ liệu ghế đã chọn
    5. Hiển thị thông báo cho người dùng
    =================================================================================
    */

    // ===== HẰNG SỐ =====
    const ticketPrice = Number('<%= bookingSession.getTicketPrice() %>');  // Giá vé cơ bản
    const selectedSeatsData = new Map();  // Map lưu ghế đã chọn {seatId: {label, multiplier}}
    const maxSeats = 8;  // Số ghế tối đa được phép chọn mỗi lần đặt

    // ===== KHỞI TẠO =====
    /**
     * Khởi tạo trang khi DOM đã load xong
     */
    document.addEventListener('DOMContentLoaded', function () {
        initializeSeats();      // Gắn event listeners cho các ghế
        startAutoRefresh();     // Bắt đầu tự động cập nhật trạng thái ghế
    });

    /**
     * Khởi tạo event listeners cho tất cả các ghế
     */
    function initializeSeats() {
        document.querySelectorAll('.seat').forEach(seat => {
            seat.addEventListener('click', function () {
                toggleSeat(this);
            });
        });
        updateSummary();  // Cập nhật hiển thị tổng kết ban đầu
    }

    // ===== XỬ LÝ CHỌN GHẾ =====
    /**
     * Xử lý chọn/bỏ chọn ghế
     * @param {HTMLElement} element - Phần tử ghế được click
     */
    function toggleSeat(element) {
        // Kiểm tra ghế có thể chọn không
        if (element.dataset.available !== 'true') {
            return;
        }

        const seatId = element.dataset.seatId;
        const seatLabel = element.dataset.seatLabel;
        const priceMultiplier = parseFloat(element.dataset.priceMultiplier) || 1.0;

        // Nếu ghế đã được chọn -> bỏ chọn
        if (selectedSeatsData.has(seatId)) {
            selectedSeatsData.delete(seatId);
            element.classList.remove('selected');
        } else {
            // Kiểm tra giới hạn số ghế trước khi chọn
            if (selectedSeatsData.size >= maxSeats) {
                showNotification('Bạn chỉ có thể chọn tối đa ' + maxSeats + ' ghế!', 'warning');
                return;
            }

            // Thêm ghế vào danh sách đã chọn
            selectedSeatsData.set(seatId, {
                label: seatLabel,
                multiplier: priceMultiplier
            });
            element.classList.add('selected');
        }

        updateSummary();  // Cập nhật tổng kết sau khi thay đổi
    }

    // ===== CẬP NHẬT TỔNG KẾT =====
    /**
     * Cập nhật phần tổng kết (số ghế đã chọn, danh sách ghế, tổng tiền)
     */
    function updateSummary() {
        const count = selectedSeatsData.size;
        document.getElementById('selectedCount').textContent = count;

        // Cập nhật danh sách ghế đã chọn
        const container = document.getElementById('seatTagsContainer');
        if (count === 0) {
            container.innerHTML = '<span class="empty-selection">Chưa chọn ghế nào</span>';
        } else {
            container.innerHTML = '';
            selectedSeatsData.forEach(function (data, id) {
                const tag = document.createElement('span');
                tag.className = 'seat-tag';
                tag.textContent = data.label;
                container.appendChild(tag);
            });
        }

        // Tính tổng tiền dựa trên loại ghế
        // Ghế VIP có hệ số 1.5x, ghế Đôi có hệ số 2.0x
        let total = 0;
        selectedSeatsData.forEach(function (data) {
            total += ticketPrice * data.multiplier;
        });

        // Cập nhật tổng tiền với hiệu ứng animation
        const totalElement = document.getElementById('totalAmount');
        totalElement.style.transform = 'scale(1.1)';
        setTimeout(function () {
            totalElement.textContent = total.toLocaleString('vi-VN') + ' VNĐ';
            totalElement.style.transform = 'scale(1)';
        }, 150);

        // Bật/tắt nút tiếp tục
        document.getElementById('continueBtn').disabled = count === 0;
    }

    // ===== CÁC HÀNH ĐỘNG =====
    /**
     * Đặt lại tất cả ghế đã chọn
     */
    function resetSeats() {
        if (selectedSeatsData.size === 0) return;

        if (confirm('Bạn có chắc muốn bỏ chọn tất cả ghế?')) {
            selectedSeatsData.clear();
            document.querySelectorAll('.seat.selected').forEach(function (seat) {
                seat.classList.remove('selected');
            });
            updateSummary();
        }
    }

    /**
     * Submit form để chuyển sang trang chọn đồ ăn
     */
    function submitForm() {
        if (selectedSeatsData.size === 0) {
            showNotification('Vui lòng chọn ít nhất một ghế!', 'warning');
            return;
        }

        // Hiển thị loading overlay
        document.getElementById('loadingOverlay').style.display = 'flex';

        // Thêm các ID ghế đã chọn vào form
        const form = document.getElementById('seatForm');
        selectedSeatsData.forEach(function (data, seatId) {
            const input = document.createElement('input');
            input.type = 'hidden';
            input.name = 'seatIDs';
            input.value = seatId;
            form.appendChild(input);
        });

        // Delay 500ms để hiển thị loading animation
        setTimeout(function () {
            form.submit();
        }, 500);
    }

    // ===== TỰ ĐỘNG CẬP NHẬT =====
    /**
     * Bắt đầu tự động cập nhật trạng thái ghế mỗi 5 giây
     */
    function startAutoRefresh() {
        setInterval(function () {
            refreshSeatAvailability();
        }, 5000);
    }

    /**
     * Gọi API để lấy trạng thái ghế mới nhất từ server
     */
    function refreshSeatAvailability() {
        fetch('${pageContext.request.contextPath}/booking/select-seats?ajax=true&screeningID=<%= bookingSession.getScreeningID() %>')
            .then(response => response.json())
            .then(data => {
                if (data.bookedSeats || data.reservedSeats) {
                    updateSeatStatus(data.bookedSeats, data.reservedSeats);
                }
            })
            .catch(error => console.log('Auto-refresh error:', error));
    }

    /**
     * Cập nhật trạng thái ghế dựa trên dữ liệu từ server
     * @param {Array} bookedSeats - Danh sách ID ghế đã đặt
     * @param {Array} reservedSeats - Danh sách ID ghế đang giữ
     */
    function updateSeatStatus(bookedSeats, reservedSeats) {
        let hasChanges = false;

        document.querySelectorAll('.seat').forEach(function (seat) {
            const seatId = parseInt(seat.dataset.seatId);

            // Ghế đã được đặt (confirmed)
            if (bookedSeats.includes(seatId)) {
                if (!seat.classList.contains('booked')) {
                    seat.classList.remove('selected', 'reserved');
                    seat.classList.add('booked');
                    seat.dataset.available = 'false';

                    // Nếu ghế này đang được user chọn -> xóa khỏi danh sách
                    if (selectedSeatsData.has(String(seatId))) {
                        selectedSeatsData.delete(String(seatId));
                        hasChanges = true;
                    }
                }
            }
            // Ghế đang được giữ tạm (reserved)
            else if (reservedSeats.includes(seatId)) {
                if (!seat.classList.contains('reserved') && !seat.classList.contains('selected')) {
                    seat.classList.add('reserved');
                    seat.dataset.available = 'false';
                }
            }
            // Ghế hết hạn giữ chỗ -> trở về trạng thái trống
            else if (seat.classList.contains('reserved') && !seat.classList.contains('selected')) {
                seat.classList.remove('reserved');
                seat.dataset.available = 'true';
            }
        });

        // Nếu có ghế bị người khác đặt -> cập nhật lại và thông báo
        if (hasChanges) {
            updateSummary();
            showNotification('Một số ghế đã bị người khác đặt!', 'warning');
        }
    }

    // ===== THÔNG BÁO =====
    /**
     * Hiển thị thông báo tạm thời
     * @param {string} message - Nội dung thông báo
     * @param {string} type - Loại thông báo (warning, error, info)
     */
    function showNotification(message, type) {
        const alertClass = type === 'warning' ? 'alert-warning' :
            type === 'error' ? 'alert-danger' : 'alert-info';

        const notification = document.createElement('div');
        notification.className = 'alert ' + alertClass;
        notification.style.cssText = 'position: fixed; top: 20px; right: 20px; z-index: 10000; min-width: 300px; animation: slideIn 0.3s ease;';
        notification.innerHTML = '<i class="fas fa-exclamation-circle"></i> ' + message;

        document.body.appendChild(notification);

        // Tự động ẩn sau 3 giây
        setTimeout(function () {
            notification.remove();
        }, 3000);
    }

    // Thêm CSS animation cho notification
    const style = document.createElement('style');
    style.textContent = '@keyframes slideIn { from { transform: translateX(100%); opacity: 0; } to { transform: translateX(0); opacity: 1; } }';
    document.head.appendChild(style);
</script>
</body>

</html>