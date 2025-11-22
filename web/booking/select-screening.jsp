<!-- 
    JSP Directives - Cấu hình trang JSP
    - contentType: Định dạng HTML với encoding UTF-8
    - import: Import các class cần thiết từ Java
-->
<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@page import="java.util.List" %>
<%@page import="entity.Cinema" %>
<%@page import="entity.Movie" %>

<!DOCTYPE html>
<html lang="vi">

<head>
    <!-- Meta tags cho encoding và cache control -->
    <meta charset="UTF-8">
    <!-- Disable cache để đảm bảo dữ liệu luôn được cập nhật -->
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <meta http-equiv="Pragma" content="no-cache">
    <meta http-equiv="Expires" content="0">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chọn Suất Chiếu - Cinema Booking</title>
    
    <!-- Thư viện CSS bên ngoài -->
    <!-- Bootstrap 5.3.3 cho styling và responsive design -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome 6.0.0 cho icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <!-- Custom CSS cho trang select-screening -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/select-screening.css">
</head>

<body>
    <!-- 
        Progress Steps Indicator
        Hiển thị tiến trình đặt vé qua 4 bước:
        1. Chọn Suất (active) - Bước hiện tại
        2. Chọn Ghế
        3. Đồ Ăn
        4. Thanh Toán
    -->
    <div class="progress-container">
        <div class="progress-steps">
            <div class="step active">
                <div class="step-circle"><i class="fas fa-film"></i></div>
                <span class="step-label">Chọn Suất</span>
            </div>
            <div class="step">
                <div class="step-circle"><i class="fas fa-couch"></i></div>
                <span class="step-label">Chọn Ghế</span>
            </div>
            <div class="step">
                <div class="step-circle"><i class="fas fa-utensils"></i></div>
                <span class="step-label">Đồ Ăn</span>
            </div>
            <div class="step">
                <div class="step-circle"><i class="fas fa-credit-card"></i></div>
                <span class="step-label">Thanh Toán</span>
            </div>
        </div>
    </div>

    <!-- Main Content Container -->
    <div class="main-container">
        <!-- Header Section - Tiêu đề và mô tả trang -->
        <div class="movie-header">
            <h1><i class="fas fa-film"></i> Chọn Suất Chiếu</h1>
            <p>Chọn phim, rạp, ngày và giờ chiếu phù hợp với bạn</p>
        </div>

        <!-- 
            Alert Messages Section
            Hiển thị thông báo lỗi hoặc thành công từ server
            - error: Thông báo lỗi (màu đỏ)
            - success: Thông báo thành công (màu xanh)
        -->
        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-danger" role="alert">
                <i class="fas fa-exclamation-circle"></i>
                <%= request.getAttribute("error") %>
            </div>
        <% } %>

        <% if (request.getAttribute("success") != null) { %>
            <div class="alert alert-info" role="alert">
                <i class="fas fa-check-circle"></i>
                <%= request.getAttribute("success") %>
            </div>
        <% } %>

        <!-- 
            Movie Selection Section
            Hiển thị danh sách phim đang chiếu dưới dạng grid
            Mỗi movie card chứa:
            - data-movie-id: ID của phim (dùng cho JavaScript)
            - data-movie-name: Tên phim (dùng cho JavaScript)
            - Icon, tên phim và thời lượng
        -->
        <div class="selection-section">
            <div class="section-title">
                <i class="fas fa-film"></i>
                <span>Chọn Phim</span>
            </div>
            <div class="movie-grid" id="movieGrid">
                <% 
                    // Lấy danh sách phim từ request attribute (được set bởi servlet)
                    List<Movie> movies = (List<Movie>) request.getAttribute("movies");
                    if (movies != null && !movies.isEmpty()) {
                        // Render từng phim trong danh sách
                        for (Movie movie : movies) {
                %>
                <div class="movie-card"
                    data-movie-id="<%= movie.getMovieID() %>"
                    data-movie-name="<%= movie.getTitle() %>">
                    <div class="movie-icon">🎬</div>
                    <div class="movie-name">
                        <%= movie.getTitle() %>
                    </div>
                    <div class="movie-duration">
                        <%= movie.getDuration() %> phút
                    </div>
                </div>
                <% 
                        } 
                    } else { 
                        // Hiển thị thông báo nếu không có phim nào
                %>
                <div class="empty-state">
                    <i class="fas fa-film"></i>
                    <p>Không có phim nào đang chiếu</p>
                </div>
                <% } %>
            </div>
        </div>

        <!-- 
            Cinema Selection Section
            Hiển thị danh sách rạp chiếu phim dưới dạng chips
            Mỗi cinema chip chứa:
            - data-cinema-id: ID của rạp (dùng cho JavaScript)
            - data-cinema-name: Tên rạp (dùng cho JavaScript)
        -->
        <div class="selection-section">
            <div class="section-title">
                <i class="fas fa-building"></i>
                <span>Chọn Rạp</span>
            </div>
            <div class="cinema-chips" id="cinemaChips">
                <% 
                    // Lấy danh sách rạp từ request attribute (được set bởi servlet)
                    List<Cinema> cinemas = (List<Cinema>) request.getAttribute("cinemas");
                    if (cinemas != null && !cinemas.isEmpty()) {
                        // Render từng rạp trong danh sách
                        for (Cinema cinema : cinemas) {
                %>
                <div class="cinema-chip"
                    data-cinema-id="<%= cinema.getCinemaID() %>"
                    data-cinema-name="<%= cinema.getCinemaName() %>">
                    <i class="fas fa-map-marker-alt"></i>
                    <%= cinema.getCinemaName() %>
                </div>
                <% 
                        } 
                    } else { 
                        // Hiển thị thông báo nếu không có rạp nào
                %>
                <div class="empty-state">
                    <i class="fas fa-building"></i>
                    <p>Không có rạp nào khả dụng</p>
                </div>
                <% } %>
            </div>
        </div>

        <!-- 
            Date Selection Section
            Hiển thị 7 ngày kể từ hôm nay để người dùng chọn
            Date cards sẽ được tạo động bởi JavaScript (hàm generateDates())
        -->
        <div class="selection-section">
            <div class="section-title">
                <i class="fas fa-calendar-alt"></i>
                <span>Chọn Ngày</span>
            </div>
            <div class="date-scroll" id="dateScroll">
                <!-- Date cards sẽ được generate bởi JavaScript khi trang load -->
            </div>
        </div>

        <!-- 
            Showtimes Section
            Hiển thị danh sách suất chiếu dựa trên:
            - Phim đã chọn
            - Rạp đã chọn
            - Ngày đã chọn
            Dữ liệu được load từ API endpoint /api/load-screenings
        -->
        <div class="selection-section showtime-container" id="showtimeContainer">
            <div class="section-title">
                <i class="fas fa-clock"></i>
                <span>Chọn Giờ Chiếu</span>
            </div>
            <div id="showtimeContent">
                <!-- Loading state - hiển thị khi đang tải suất chiếu -->
                <div class="loading">
                    <i class="fas fa-spinner"></i>
                    <p>Đang tải suất chiếu...</p>
                </div>
            </div>
        </div>

        <!-- 
            Continue Button Section
            Bao gồm:
            1. Selection Summary: Tóm tắt các lựa chọn (phim, rạp, ngày, giờ)
            2. Form submit: Gửi screeningID đến servlet để tiếp tục bước chọn ghế
        -->
        <div class="continue-section">
            <!-- Summary hiển thị các lựa chọn đã chọn (ẩn mặc định) -->
            <div class="selection-summary" id="selectionSummary" style="display: none;">
                <div class="summary-item">
                    <span class="summary-label">Phim:</span>
                    <span class="summary-value" id="summaryMovie">-</span>
                </div>
                <div class="summary-item">
                    <span class="summary-label">Rạp:</span>
                    <span class="summary-value" id="summaryCinema">-</span>
                </div>
                <div class="summary-item">
                    <span class="summary-label">Ngày:</span>
                    <span class="summary-value" id="summaryDate">-</span>
                </div>
                <div class="summary-item">
                    <span class="summary-label">Giờ:</span>
                    <span class="summary-value" id="summaryTime">-</span>
                </div>
            </div>
            
            <!-- Form để submit screeningID đến servlet -->
            <form method="post"
                action="${pageContext.request.contextPath}/booking/select-screening"
                id="screeningForm">
                <!-- Hidden input chứa screeningID được chọn -->
                <input type="hidden" name="screeningID" id="screeningIDInput">
                <!-- Button tiếp tục - disabled cho đến khi chọn đủ thông tin -->
                <button type="submit" class="continue-btn" id="continueBtn" disabled>
                    <i class="fas fa-arrow-right"></i> Tiếp Tục Chọn Ghế
                </button>
            </form>
        </div>
    </div>

    <!-- Bootstrap JavaScript Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    
    <script>
        /* 
            ============================================
            STATE MANAGEMENT
            ============================================
            Quản lý trạng thái các lựa chọn của người dùng:
            - selectedMovie: ID của phim đã chọn
            - selectedMovieName: Tên phim đã chọn
            - selectedCinema: ID của rạp đã chọn
            - selectedCinemaName: Tên rạp đã chọn
            - selectedDate: Ngày đã chọn (format: YYYY-MM-DD)
            - selectedScreening: ID của suất chiếu đã chọn
            - selectedTime: Giờ chiếu đã chọn
        */
        let selectedMovie = null;
        let selectedMovieName = '';
        let selectedCinema = null;
        let selectedCinemaName = '';
        let selectedDate = null; // Sẽ được set bởi generateDates()
        let selectedScreening = null;
        let selectedTime = '';

        /* 
            ============================================
            HELPER FUNCTION: ensureValidDate()
            ============================================
            Đảm bảo selectedDate luôn có giá trị hợp lệ (format: YYYY-MM-DD)
            
            Logic:
            1. Kiểm tra nếu selectedDate null/invalid → tạo từ ngày hôm nay
            2. Validate các thành phần (year, month, day) có trong khoảng hợp lệ
            3. Kiểm tra format YYYY-MM-DD
            4. Nếu format sai → reset và tạo lại
            
            Return: 
            - String date hợp lệ (YYYY-MM-DD) hoặc null nếu không thể tạo
        */
        function ensureValidDate() {
            // Kiểm tra nếu selectedDate không hợp lệ hoặc rỗng
            if (!selectedDate || selectedDate === '--' || selectedDate === 'null' || selectedDate === 'undefined' ||
                (typeof selectedDate === 'string' && selectedDate.trim() === '')) {

                // Tạo date từ ngày hôm nay
                const today = new Date();
                const year = today.getFullYear();
                const monthNum = today.getMonth() + 1;
                const dayNum = today.getDate();

                // Validate các giá trị trước khi tạo date string
                if (!year || isNaN(year) || year < 2000 || year > 2100) {
                    console.error('ensureValidDate(): Invalid year:', year);
                    return null;
                }
                if (!monthNum || isNaN(monthNum) || monthNum < 1 || monthNum > 12) {
                    console.error('ensureValidDate(): Invalid month:', monthNum);
                    return null;
                }
                if (!dayNum || isNaN(dayNum) || dayNum < 1 || dayNum > 31) {
                    console.error('ensureValidDate(): Invalid day:', dayNum);
                    return null;
                }

                // Format thành YYYY-MM-DD
                const month = String(monthNum).padStart(2, '0');
                const day = String(dayNum).padStart(2, '0');
                const newDate = year + '-' + month + '-' + day;

                // Validate format cuối cùng
                if (!newDate || newDate === '--' || !/^\d{4}-\d{2}-\d{2}$/.test(newDate)) {
                    console.error('ensureValidDate(): Generated invalid date string:', newDate);
                    return null;
                }

                selectedDate = newDate;
                console.log('ensureValidDate(): Force-set selectedDate to:', selectedDate, '(from today:', year, month, day + ')');
                return selectedDate;
            }

            // Validate format nếu date đã tồn tại
            if (typeof selectedDate === 'string' && !/^\d{4}-\d{2}-\d{2}$/.test(selectedDate)) {
                console.warn('ensureValidDate(): Invalid date format detected:', selectedDate);
                // Gọi đệ quy để fix
                const originalDate = selectedDate;
                selectedDate = null;
                return ensureValidDate();
            }

            return selectedDate;
        }

        /* 
            ============================================
            FUNCTION: generateDates()
            ============================================
            Tạo các date cards cho 7 ngày kể từ hôm nay
            
            Flow:
            1. Tìm element dateScroll trong DOM
            2. Tạo mảng 7 ngày (hôm nay + 6 ngày tiếp theo)
            3. Với mỗi ngày:
               - Validate date object
               - Format thành YYYY-MM-DD
               - Tạo date card với thông tin: thứ, ngày, tháng
               - Thêm event listener cho click
               - Append vào dateScroll
            4. Set selectedDate = ngày đầu tiên (hôm nay)
            5. Force visibility để đảm bảo hiển thị
            
            Error handling:
            - Retry nếu không tìm thấy element
            - Skip date card nếu date invalid
            - Fallback về ngày hôm nay nếu có lỗi
        */
function generateDates() {
    try {
        console.log('=== generateDates() START ===');
        console.log('document.readyState:', document.readyState);
        console.log('document.body exists?', !!document.body);

        // Tìm element chứa date cards
        let dateScroll = document.getElementById('dateScroll');

        // Thử nhiều cách để tìm element (fallback)
        if (!dateScroll) {
            console.warn('dateScroll not found by ID, trying by class...');
            dateScroll = document.querySelector('.date-scroll');
        }

        // Nếu vẫn không tìm thấy → retry sau 200ms
        if (!dateScroll) {
            console.error('dateScroll element not found! Will retry...');
            setTimeout(() => {
                console.log('Retrying generateDates() after delay...');
                generateDates();
            }, 200);
            return;
        }

        console.log('Found dateScroll element:', dateScroll);
        console.log('dateScroll parent:', dateScroll.parentElement);
        console.log('dateScroll offsetParent:', dateScroll.offsetParent);

        // Xóa các date cards cũ (nếu có)
        dateScroll.innerHTML = '';

        // Đảm bảo section cha hiển thị
        let dateSection = dateScroll.closest('.selection-section');
        if (dateSection) {
            dateSection.style.display = 'block';
        }
        dateScroll.style.display = 'flex';

        console.log('Generating dates for dateScroll element:', dateScroll);
        console.log('dateScroll parent:', dateScroll.parentElement);
        console.log('dateScroll visible?', dateScroll.offsetParent !== null);

        // Tạo mảng 7 ngày: hôm nay + 6 ngày tiếp theo
        const todayDate = new Date();
        const dates = [];

        for (let i = 0; i < 7; i++) {
            const date = new Date(todayDate);
            date.setDate(todayDate.getDate() + i);
            dates.push(date);
        }

        console.log('Generated dates array:', dates.map(d => d.toISOString().split('T')[0]));

        // Mảng tên thứ và tháng (tiếng Việt)
        const dayNames = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
        const monthNames = ['Th1', 'Th2', 'Th3', 'Th4', 'Th5', 'Th6', 'Th7', 'Th8', 'Th9', 'Th10', 'Th11', 'Th12'];

        let firstValidDate = null;

        dates.forEach((date, index) => {
            // Validate date object first
            if (!date || isNaN(date.getTime())) {
                console.error('Invalid date object at index:', index, date);
                return; // Skip this date card
            }

            const dateCard = document.createElement('div');
            dateCard.className = 'date-card' + (index === 0 ? ' selected' : '');

            // Định dạng ngày thành YYYY-MM-DD sử dụng múi giờ địa phương (không phải UTC)
            let year, month, day;
            try {
                year = date.getFullYear();
                month = date.getMonth() + 1;
                day = date.getDate();
            } catch (e) {
                console.error('Error getting date components:', e, 'for date:', date);
                return; // Skip this date card
            }

            // Validate date components are numbers
            if (typeof year !== 'number' || typeof month !== 'number' || typeof day !== 'number') {
                console.error('Date components not numbers - year:', year, 'month:', month, 'day:', day, 'types:', {
                    yearType: typeof year,
                    monthType: typeof month,
                    dayType: typeof day
                }, 'for date:', date);
                return; // Skip this date card
            }

            // Validate date component ranges
            if (isNaN(year) || isNaN(month) || isNaN(day) ||
                year < 1900 || year > 2100 ||
                month < 1 || month > 12 ||
                day < 1 || day > 31) {
                console.error('Invalid date component ranges - year:', year, 'month:', month, 'day:', day, 'for date:', date);
                return; // Skip this date card
            }

            // Xây dựng chuỗi ngày một cách rõ ràng để tránh vấn đề với template literal
            const monthStr = (month < 10 ? '0' : '') + month;
            const dayStr = (day < 10 ? '0' : '') + day;
            const dateStr = year + '-' + monthStr + '-' + dayStr;

            // Kiểm tra tính hợp lệ của chuỗi ngày trước khi gán
            if (!dateStr || dateStr.length !== 10 || !/^\d{4}-\d{2}-\d{2}$/.test(dateStr)) {
                console.error('Invalid date string generated:', dateStr, 'length:', dateStr ? dateStr.length : 0, 'for date:', date, 'components:', { year, month, day });
                return; // Bỏ qua date card này
            }

            // Ghi log debug khi tạo chuỗi ngày thành công
            console.log('Successfully created dateStr:', dateStr, 'for date:', date.toISOString());

            dateCard.dataset.date = dateStr;

            // Lưu ngày hợp lệ đầu tiên
            if (index === 0 && !firstValidDate) {
                firstValidDate = dateStr;
            }

            const dayName = dayNames[date.getDay()];
            const dayNum = date.getDate();
            const monthName = monthNames[date.getMonth()];

            // Tạo các phần tử bên trong date card
            const dayNameDiv = document.createElement('div');
            dayNameDiv.className = 'day-name';
            dayNameDiv.textContent = dayName;

            const dayNumDiv = document.createElement('div');
            dayNumDiv.className = 'day-num';
            dayNumDiv.textContent = dayNum;

            const monthDiv = document.createElement('div');
            monthDiv.className = 'month';
            monthDiv.textContent = monthName;

            // Thêm các phần tử vào date card
            dateCard.appendChild(dayNameDiv);
            dateCard.appendChild(dayNumDiv);
            dateCard.appendChild(monthDiv);

            // Thêm event listener cho click
            dateCard.addEventListener('click', function () {
                selectDate(this);
            });
            // Thêm date card vào dateScroll
            dateScroll.appendChild(dateCard);

            console.log('Created date card:', dayName, dayNum, monthName, 'with date:', dateStr);
            console.log('Date card appended to dateScroll. dateScroll children count:', dateScroll.children.length);
        });

        console.log('Generated', dates.length, 'date cards');
        console.log('Final dateScroll children count:', dateScroll.children.length);
        console.log('Final dateScroll innerHTML length:', dateScroll.innerHTML.length);

        // Buộc hiển thị date scroll và phần tử cha
        if (dateScroll) {
            dateScroll.style.display = 'flex';
            dateScroll.style.visibility = 'visible';
            dateScroll.style.opacity = '1';
        }

        // Tái sử dụng biến dateSection (đã khai báo trước đó trong hàm)
        dateSection = dateScroll?.closest('.selection-section');
        if (dateSection) {
            dateSection.style.display = 'block';
            dateSection.style.visibility = 'visible';
        }

        // Đặt selectedDate từ ngày hợp lệ đầu tiên
        if (firstValidDate) {
            selectedDate = firstValidDate;
            console.log('Auto-selected first date:', selectedDate);
        } else {
            // Dự phòng: lấy từ date card đầu tiên trong DOM
            const firstDateCard = document.querySelector('.date-card[data-date]');
            if (firstDateCard && firstDateCard.dataset.date) {
                selectedDate = firstDateCard.dataset.date;
                console.log('Fallback: Set selectedDate from first date card:', selectedDate);
            } else {
                // Phương án cuối: tạo từ ngày hôm nay
                const today = new Date();
                const year = today.getFullYear();
                const month = String(today.getMonth() + 1).padStart(2, '0');
                const day = String(today.getDate()).padStart(2, '0');
                selectedDate = `${year}-${month}-${day}`;
                console.log('Last resort: Generated selectedDate:', selectedDate);
            }
        }

        console.log('Final selectedDate after generation:', selectedDate);

        // Kiểm tra cuối cùng để đảm bảo date cards đã có trong DOM
        const finalDateCards = document.querySelectorAll('.date-card');
        console.log('Final verification - Date cards in DOM:', finalDateCards.length);
        if (finalDateCards.length === 0) {
            console.error('CRITICAL: No date cards found in DOM after generation!');
            console.error('dateScroll element:', dateScroll);
            console.error('dateScroll.innerHTML preview:', dateScroll.innerHTML.substring(0, 200));
        } else {
            console.log('SUCCESS: Date cards are in DOM!');
            console.log('First date card:', finalDateCards[0]);
            console.log('Date scroll computed style display:', window.getComputedStyle(dateScroll).display);
            console.log('Date scroll computed style visibility:', window.getComputedStyle(dateScroll).visibility);

            // Buộc hiển thị một lần nữa
            dateScroll.style.display = 'flex';
            dateScroll.style.visibility = 'visible';
            dateScroll.style.opacity = '1';

            // Buộc reflow để đảm bảo render
            void dateScroll.offsetHeight;

            // Ghi log từng date card để debug
            finalDateCards.forEach((card, idx) => {
                console.log(`Date card ${idx}:`, card.textContent, 'data-date:', card.dataset.date, 'visible:', card.offsetParent !== null);
            });
        }

        console.log('=== generateDates() END ===');
        return true; // Báo hiệu thành công

        } catch (error) {
            console.error('Error in generateDates():', error);
            // Phương án cuối: tạo từ ngày hôm nay
            const today = new Date();
            const year = today.getFullYear();
            const month = String(today.getMonth() + 1).padStart(2, '0');
            const day = String(today.getDate()).padStart(2, '0');
            selectedDate = `${year}-${month}-${day}`;
            console.log('Error recovery: Generated selectedDate:', selectedDate);
        }
    }

                /* 
                    ============================================
                    FUNCTION: selectMovie()
                    ============================================
                    Xử lý khi người dùng chọn phim
                    
                    Flow:
                    1. Validate movie card và lấy ID, tên phim
                    2. Xóa selection cũ, thêm selection mới
                    3. Reset screening selection
                    4. Disable continue button
                    5. Kiểm tra và đảm bảo selectedDate hợp lệ
                    6. Load showtimes nếu đã chọn đủ (phim, rạp, ngày)
                    7. Update summary
                */
                function selectMovie(movieCard) {
                    try {
                        console.log('selectMovie called with:', movieCard);

                        if (!movieCard) {
                            console.error('Movie card is null or undefined');
                            return;
                        }

                        const movieId = parseInt(movieCard.dataset.movieId);
                        const movieName = movieCard.dataset.movieName;

                        // Kiểm tra NaN rõ ràng - cho phép ID = 0 là hợp lệ
                        if (isNaN(movieId) || movieCard.dataset.movieId === undefined) {
                            console.error('Invalid movie ID:', movieCard.dataset.movieId);
                            return;
                        }

                        console.log('Selecting movie:', movieId, movieName);

                        // Xóa selection trước đó
                        document.querySelectorAll('.movie-card').forEach(card => {
                            card.classList.remove('selected');
                        });

                        // Thêm selection vào card được click
                        movieCard.classList.add('selected');

                        selectedMovie = movieId;
                        selectedMovieName = movieName;

                        // Reset screening selection khi phim thay đổi
                        selectedScreening = null;
                        selectedTime = '';

                        const continueBtn = document.getElementById('continueBtn');
                        if (continueBtn) {
                            continueBtn.disabled = true;
                        }

                        // Đảm bảo selectedDate hợp lệ trước khi kiểm tra
                        const validDate = ensureValidDate();
                        if (!validDate) {
                            console.error('Cannot ensure valid date in selectMovie!');
                            const content = document.getElementById('showtimeContent');
                            if (content) {
                                content.innerHTML = '<div class="empty-state"><p>Lỗi: Không thể xác định ngày. Vui lòng tải lại trang.</p></div>';
                            }
                            updateSummary();
                            return;
                        }

                        // Chỉ load showtimes nếu đã chọn đủ VÀ selectedDate hợp lệ
                        if (selectedCinema && selectedDate && selectedDate !== '--' && selectedDate !== 'null' &&
                            /^\d{4}-\d{2}-\d{2}$/.test(selectedDate)) {
                            loadShowtimes();
                        } else {
                            // Xóa showtimes nếu phim thay đổi nhưng rạp hoặc ngày chưa được chọn/hợp lệ
                            const content = document.getElementById('showtimeContent');
                            if (content) {
                                content.innerHTML = '';
                            }
                            if (!selectedDate || selectedDate === '--' || selectedDate === 'null') {
                                console.warn('Cannot load showtimes after movie selection - selectedDate is invalid:', selectedDate);
                            }
                        }
                        updateSummary();

                        console.log('Movie selected successfully:', movieId);
                    } catch (error) {
                        console.error('Error in selectMovie:', error);
                    }
                }

                /* 
                    ============================================
                    FUNCTION: selectCinema()
                    ============================================
                    Xử lý khi người dùng chọn rạp chiếu phim
                    
                    Flow:
                    1. Lấy ID và tên rạp từ cinema chip
                    2. Xóa selection cũ, thêm selection mới
                    3. Reset screening selection
                    4. Disable continue button
                    5. Kiểm tra và đảm bảo selectedDate hợp lệ
                    6. Load showtimes nếu đã chọn đủ (phim, rạp, ngày)
                    7. Update summary
                */
                function selectCinema(cinemaChip) {
                    const cinemaId = parseInt(cinemaChip.dataset.cinemaId);
                    const cinemaName = cinemaChip.dataset.cinemaName;

                    // Xóa selection trước đó
                    document.querySelectorAll('.cinema-chip').forEach(chip => {
                        chip.classList.remove('selected');
                    });

                    // Thêm selection vào chip được click
                    cinemaChip.classList.add('selected');

                    selectedCinema = cinemaId;
                    selectedCinemaName = cinemaName;

                    // Reset screening selection khi rạp thay đổi
                    selectedScreening = null;
                    selectedTime = '';
                    document.getElementById('continueBtn').disabled = true;

                    // Đảm bảo selectedDate hợp lệ trước khi kiểm tra
                    const validDate = ensureValidDate();
                    if (!validDate) {
                        console.error('Cannot ensure valid date!');
                        const content = document.getElementById('showtimeContent');
                        if (content) {
                            content.innerHTML = '<div class="empty-state"><p>Lỗi: Không thể xác định ngày. Vui lòng tải lại trang.</p></div>';
                        }
                        return;
                    }

                    // Chỉ load showtimes nếu đã chọn đủ VÀ selectedDate hợp lệ - cho phép movie ID = 0
                    if (selectedMovie !== null && selectedMovie !== undefined &&
                        selectedDate && selectedDate !== '--' && selectedDate !== 'null' &&
                        /^\d{4}-\d{2}-\d{2}$/.test(selectedDate)) {
                        loadShowtimes();
                    } else {
                        // Xóa showtimes nếu rạp thay đổi nhưng phim hoặc ngày chưa được chọn/hợp lệ
                        const content = document.getElementById('showtimeContent');
                        if (content) {
                            content.innerHTML = '';
                        }
                        if (!selectedDate || selectedDate === '--' || selectedDate === 'null') {
                            console.warn('Cannot load showtimes - selectedDate is invalid:', selectedDate);
                        }
                    }
                    updateSummary();
                }

                /* 
                    ============================================
                    FUNCTION: selectDate()
                    ============================================
                    Xử lý khi người dùng chọn ngày chiếu
                    
                    Flow:
                    1. Validate date string từ date card
                    2. Xóa selection cũ, thêm selection mới
                    3. Reset screening selection
                    4. Disable continue button
                    5. Load showtimes nếu đã chọn đủ (phim, rạp)
                    6. Update summary
                */
                function selectDate(dateCard) {
                    const dateStr = dateCard.dataset.date;

                    // Kiểm tra tính hợp lệ của chuỗi ngày
                    if (!dateStr || dateStr === '--' || dateStr === 'null' || dateStr.trim() === '') {
                        console.error('Invalid date string from date card:', dateStr);
                        return;
                    }

                    // Kiểm tra format ngày
                    const dateRegex = /^\d{4}-\d{2}-\d{2}$/;
                    if (!dateRegex.test(dateStr)) {
                        console.error('Invalid date format from date card:', dateStr);
                        return;
                    }

                    console.log('Date selected:', dateStr);

                    // Xóa selection trước đó
                    document.querySelectorAll('.date-card').forEach(card => {
                        card.classList.remove('selected');
                    });

                    // Thêm selection
                    dateCard.classList.add('selected');
                    selectedDate = dateStr;

                    // Reset screening selection khi ngày thay đổi
                    selectedScreening = null;
                    selectedTime = '';
                    document.getElementById('continueBtn').disabled = true;

                    // Chỉ load showtimes nếu đã chọn đủ - cho phép movie ID = 0
                    if (selectedMovie !== null && selectedMovie !== undefined && selectedCinema) {
                        loadShowtimes();
                    }
                    updateSummary();
                }

                /* 
                    ============================================
                    FUNCTION: selectShowtime()
                    ============================================
                    Xử lý khi người dùng chọn suất chiếu
                    
                    Flow:
                    1. Lấy screening ID, thời gian, phòng từ showtime button
                    2. Xóa selection cũ, thêm selection mới
                    3. Cập nhật form với screening ID
                    4. Enable continue button
                    5. Update summary
                */
                function selectShowtime(showtimeBtn) {
                    const screeningId = parseInt(showtimeBtn.dataset.screeningId);
                    const time = showtimeBtn.dataset.time;
                    const room = showtimeBtn.dataset.room;

                    // Xóa selection trước đó
                    document.querySelectorAll('.showtime-btn').forEach(btn => {
                        btn.classList.remove('selected');
                    });

                    // Thêm selection
                    showtimeBtn.classList.add('selected');

                    selectedScreening = screeningId;
                    selectedTime = time;

                    // Cập nhật form
                    document.getElementById('screeningIDInput').value = screeningId;
                    document.getElementById('continueBtn').disabled = false;

                    updateSummary();
                }

                /* 
                    ============================================
                    FUNCTION: loadShowtimes()
                    ============================================
                    Load danh sách suất chiếu từ API dựa trên phim, rạp và ngày đã chọn
                    
                    Flow:
                    1. Validate tất cả các lựa chọn bắt buộc
                    2. Validate giá trị và format của selectedDate
                    3. Hiển thị loading state
                    4. Gọi API /api/load-screenings với các tham số
                    5. Xử lý response:
                        - Nếu có suất chiếu: tạo showtime buttons
                        - Nếu không có: hiển thị empty state
                        - Nếu lỗi: hiển thị error message
                    
                    Error handling:
                    - Validate input trước khi gọi API
                    - Xử lý network errors
                    - Xử lý API errors
                */
                function loadShowtimes() {
                    console.log('loadShowtimes called with:', {
                        movie: selectedMovie,
                        cinema: selectedCinema,
                        date: selectedDate,
                        dateType: typeof selectedDate
                    });

                    // Kiểm tra tất cả các lựa chọn bắt buộc - cho phép movie ID = 0
                    if (selectedMovie === null || selectedMovie === undefined ||
                        selectedCinema === null || selectedCinema === undefined ||
                        !selectedDate) {
                        console.log('Cannot load showtimes - missing selection:', {
                            movie: selectedMovie,
                            cinema: selectedCinema,
                            date: selectedDate
                        });
                        return;
                    }

                    // Kiểm tra bổ sung cho các giá trị ngày không hợp lệ
                    if (selectedDate === '--' || selectedDate === 'null' || selectedDate === 'undefined' ||
                        selectedDate === null || selectedDate === undefined ||
                        (typeof selectedDate === 'string' && selectedDate.trim() === '')) {
                        console.error('Invalid date value:', selectedDate);
                        const content = document.getElementById('showtimeContent');
                        if (content) {
                            content.innerHTML = '<div class="empty-state"><p>Vui lòng chọn ngày hợp lệ</p></div>';
                        }
                        return;
                    }

                    // Kiểm tra format ngày (YYYY-MM-DD)
                    const dateRegex = /^\d{4}-\d{2}-\d{2}$/;
                    if (!dateRegex.test(selectedDate)) {
                        console.error('Invalid date format:', selectedDate, 'Type:', typeof selectedDate);
                        const content = document.getElementById('showtimeContent');
                        if (content) {
                            content.innerHTML = '<div class="empty-state"><p>Vui lòng chọn ngày hợp lệ (Format: YYYY-MM-DD)</p></div>';
                        }
                        return;
                    }

                    const container = document.getElementById('showtimeContainer');
                    const content = document.getElementById('showtimeContent');

                    if (!container || !content) {
                        console.error('Showtime container or content element not found');
                        return;
                    }

                    // Hiển thị loading state
                    container.classList.add('visible');
                    content.innerHTML = '<div class="loading"><i class="fas fa-spinner"></i><p>Đang tải suất chiếu...</p></div>';

                    console.log('Loading showtimes for:', {
                        cinemaID: selectedCinema,
                        movieID: selectedMovie,
                        date: selectedDate
                    });

                    // Tạo URL với các tham số và timestamp để tránh cache
                    const url = '${pageContext.request.contextPath}/api/load-screenings?' +
                        'cinemaID=' + encodeURIComponent(selectedCinema) +
                        '&movieID=' + encodeURIComponent(selectedMovie) +
                        '&date=' + encodeURIComponent(selectedDate) +
                        '&_=' + new Date().getTime();

                    fetch(url)
                        .then(response => {
                            if (!response.ok) {
                                throw new Error('Network response was not ok: ' + response.status);
                            }
                            return response.json();
                        })
                        .then(data => {
                            if (!data.success) {
                                console.error('API error:', data.message);
                                content.innerHTML = '<div class="empty-state"><p>' + (data.message || 'Có lỗi xảy ra') + '</p></div>';
                                return;
                            }

                            // Xử lý response thành công
                            if (data.success && data.screenings && data.screenings.length > 0) {
                                // Xóa nội dung cũ
                                content.innerHTML = '';

                                // Tạo container grid cho showtimes
                                const showtimeGrid = document.createElement('div');
                                showtimeGrid.className = 'showtime-grid';

                                // Tạo showtime button cho mỗi suất chiếu
                                data.screenings.forEach(screening => {
                                    const seats = screening.availableSeats || 0;
                                    const limited = seats < 20 && seats > 0; // Ghế còn ít (< 20)
                                    const soldOut = seats === 0; // Hết chỗ

                                    let seatClass = '';
                                    let seatText = seats + ' ghế trống';

                                    // Xác định class và text dựa trên số ghế còn lại
                                    if (soldOut) {
                                        seatClass = 'sold-out';
                                        seatText = 'Hết chỗ';
                                    } else if (limited) {
                                        seatClass = 'limited';
                                    }

                                    // Tạo showtime button
                                    const showtimeBtn = document.createElement('div');
                                    showtimeBtn.className = 'showtime-btn ' + seatClass;
                                    showtimeBtn.dataset.screeningId = screening.screeningID;
                                    showtimeBtn.dataset.time = screening.startTime;
                                    showtimeBtn.dataset.room = screening.roomName;

                                    // Tạo phần tử hiển thị thời gian
                                    const timeDiv = document.createElement('div');
                                    timeDiv.className = 'time';
                                    const timeText = screening.endTime ?
                                        screening.startTime + ' - ' + screening.endTime :
                                        screening.startTime;
                                    timeDiv.textContent = timeText;

                                    // Tạo phần tử hiển thị tên phòng
                                    const roomDiv = document.createElement('div');
                                    roomDiv.className = 'room';
                                    roomDiv.textContent = screening.roomName;

                                    // Tạo phần tử hiển thị số ghế
                                    const seatsDiv = document.createElement('div');
                                    seatsDiv.className = 'seats';

                                    const chairIcon = document.createElement('i');
                                    chairIcon.className = 'fas fa-chair';
                                    seatsDiv.appendChild(chairIcon);

                                    const seatsText = document.createTextNode(' ' + seatText);
                                    seatsDiv.appendChild(seatsText);

                                    // Thêm tất cả phần tử vào button
                                    showtimeBtn.appendChild(timeDiv);
                                    showtimeBtn.appendChild(roomDiv);
                                    showtimeBtn.appendChild(seatsDiv);

                                    // Thêm event listener cho click
                                    showtimeBtn.addEventListener('click', function (e) {
                                        e.preventDefault();
                                        e.stopPropagation();
                                        // Chỉ cho phép chọn nếu chưa hết chỗ
                                        if (!this.classList.contains('sold-out')) {
                                            selectShowtime(this);
                                        }
                                    });

                                    // Thêm vào grid
                                    showtimeGrid.appendChild(showtimeBtn);

                                    console.log('Created showtime:', screening.startTime, screening.roomName, 'Available seats:', seats);
                                });

                                // Thêm grid vào content
                                content.appendChild(showtimeGrid);
                                console.log('Loaded', data.screenings.length, 'showtimes');
                                console.log('Showtime grid appended to content. Content children:', content.children.length);
                                console.log('Container visible?', container.classList.contains('visible'));

                                // Buộc hiển thị container
                                container.classList.add('visible');
                                container.style.display = 'block';
                            } else {
                                // Hiển thị empty state nếu không có suất chiếu
                                content.innerHTML = '';
                                const emptyDiv = document.createElement('div');
                                emptyDiv.className = 'empty-state';

                                const icon = document.createElement('i');
                                icon.className = 'fas fa-calendar-times';

                                const text = document.createElement('p');
                                text.textContent = 'Không có suất chiếu nào cho lựa chọn này';

                                emptyDiv.appendChild(icon);
                                emptyDiv.appendChild(text);
                                content.appendChild(emptyDiv);
                            }
                        })
                        .catch(error => {
                            console.error('Error loading showtimes:', error);
                            content.innerHTML = '';
                            const emptyDiv = document.createElement('div');
                            emptyDiv.className = 'empty-state';

                            const icon = document.createElement('i');
                            icon.className = 'fas fa-exclamation-triangle';

                            const text = document.createElement('p');
                            text.textContent = 'Lỗi khi tải suất chiếu. Vui lòng thử lại!';

                            emptyDiv.appendChild(icon);
                            emptyDiv.appendChild(text);
                            content.appendChild(emptyDiv);
                        });
                }

                /* 
                    ============================================
                    FUNCTION: updateSummary()
                    ============================================
                    Cập nhật phần tóm tắt lựa chọn (summary) ở cuối trang
                    
                    Flow:
                    1. Kiểm tra nếu đã chọn đủ (phim, rạp, ngày, suất chiếu)
                    2. Hiển thị summary và cập nhật các giá trị:
                        - Tên phim
                        - Tên rạp
                        - Ngày (format: "Thứ X, DD/MM/YYYY")
                        - Giờ chiếu
                    3. Nếu chưa đủ → ẩn summary
                */
                function updateSummary() {
                    const summary = document.getElementById('selectionSummary');

                    // Cho phép movie ID = 0
                    if (selectedMovie !== null && selectedMovie !== undefined &&
                        selectedCinema && selectedDate && selectedScreening) {
                        summary.style.display = 'block';

                        // Cập nhật tên phim và rạp
                        document.getElementById('summaryMovie').textContent = selectedMovieName;
                        document.getElementById('summaryCinema').textContent = selectedCinemaName;

                        // Định dạng ngày - kiểm tra tính hợp lệ trước
                        if (selectedDate && selectedDate !== '--' && selectedDate !== 'null') {
                            try {
                                // Thêm thời gian để tránh vấn đề timezone
                                const dateObj = new Date(selectedDate + 'T00:00:00');
                                if (!isNaN(dateObj.getTime())) {
                                    const dayNames = ['Chủ Nhật', 'Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7'];
                                    const formattedDate = dayNames[dateObj.getDay()] + ', ' +
                                        dateObj.getDate() + '/' +
                                        (dateObj.getMonth() + 1) + '/' +
                                        dateObj.getFullYear();
                                    document.getElementById('summaryDate').textContent = formattedDate;
                                } else {
                                    document.getElementById('summaryDate').textContent = selectedDate;
                                }
                            } catch (e) {
                                console.error('Error formatting date:', e, selectedDate);
                                document.getElementById('summaryDate').textContent = selectedDate;
                            }
                        } else {
                            document.getElementById('summaryDate').textContent = '-';
                        }

                        // Cập nhật giờ chiếu
                        document.getElementById('summaryTime').textContent = selectedTime;
                    } else {
                        // Ẩn summary nếu chưa chọn đủ
                        if (summary) {
                            summary.style.display = 'none';
                        }
                    }
                }

                /* 
                    ============================================
                    FUNCTION: initializePage()
                    ============================================
                    Khởi tạo trang khi load
                    
                    Flow:
                    1. Đảm bảo date selection section hiển thị
                    2. Tìm dateScroll element
                    3. Gọi generateDates() để tạo date cards
                    4. Verify dates đã được tạo thành công
                */
                function initializePage() {
                    console.log('=== initializePage() START ===');
                    console.log('Initializing page...');
                    console.log('selectedDate before generateDates:', selectedDate);

                    // Đảm bảo date selection section hiển thị
                    const dateSection = document.querySelector('#dateScroll')?.closest('.selection-section');
                    if (dateSection) {
                        dateSection.style.display = 'block';
                        dateSection.style.visibility = 'visible';
                    }

                    const dateScroll = document.getElementById('dateScroll');
                    console.log('dateScroll element exists?', dateScroll !== null);
                    if (dateScroll) {
                        dateScroll.style.display = 'flex';
                        dateScroll.style.visibility = 'visible';
                    }

                    // Tạo dates - retry nếu không tìm thấy element
                    if (!dateScroll) {
                        console.warn('dateScroll not found immediately, retrying in 100ms...');
                        setTimeout(() => {
                            generateDates();
                            verifyDatesCreated();
                        }, 100);
                    } else {
                        generateDates();
                    }

                    // Verify sau một khoảng thời gian ngắn để đảm bảo DOM đã được cập nhật
                    setTimeout(() => {
                        verifyDatesCreated();
                    }, 200);
                }

                /* 
                    ============================================
                    FUNCTION: verifyDatesCreated()
                    ============================================
                    Kiểm tra và xác minh date cards đã được tạo thành công
                    
                    Flow:
                    1. Kiểm tra số lượng date cards trong DOM
                    2. Nếu không có → retry generateDates()
                    3. Kiểm tra selectedDate hợp lệ
                    4. Nếu không hợp lệ → force set từ ngày hôm nay
                */
                function verifyDatesCreated() {
                    console.log('Verifying dates created...');
                    console.log('selectedDate after generateDates:', selectedDate);

                    // Kiểm tra date cards đã được tạo
                    const dateCards = document.querySelectorAll('.date-card');
                    console.log('Date cards found after generateDates:', dateCards.length);
                    if (dateCards.length > 0) {
                        console.log('First date card:', dateCards[0]);
                        console.log('First date card dataset:', dateCards[0].dataset);
                        console.log('Date cards are visible!');
                    } else {
                        console.error('WARNING: No date cards found after generateDates()!');
                        // Thử tạo lại
                        const dateScroll = document.getElementById('dateScroll');
                        if (dateScroll) {
                            console.log('Retrying generateDates()...');
                            generateDates();
                        }
                    }

                    // Kiểm tra cuối cùng
                    if (!selectedDate || selectedDate === '--' || selectedDate === 'null') {
                        console.error('WARNING: selectedDate is still invalid after generateDates:', selectedDate);
                        // Buộc set một ngày hợp lệ
                        const today = new Date();
                        const year = today.getFullYear();
                        const month = String(today.getMonth() + 1).padStart(2, '0');
                        const day = String(today.getDate()).padStart(2, '0');
                        selectedDate = `${year}-${month}-${day}`;
                        console.log('Force-set selectedDate to:', selectedDate);
                    }
                }

                /* 
                    ============================================
                    FUNCTION: initializeEventListeners()
                    ============================================
                    Khởi tạo event listeners cho các elements
                    
                    Flow:
                    1. Tìm tất cả movie cards và thêm click listeners (backup method)
                    2. Tìm tất cả cinema chips và thêm click listeners
                    
                    Note: Event delegation được sử dụng như primary method ở cuối file
                */
                function initializeEventListeners() {
                    // Log số lượng movie cards để debug
                    const movieCards = document.querySelectorAll('.movie-card');
                    console.log('Movie cards found:', movieCards.length);

                    // Thêm click listeners cho movie cards (phương pháp dự phòng)
                    movieCards.forEach((card, index) => {
                        card.addEventListener('click', function (e) {
                            e.preventDefault();
                            e.stopPropagation();
                            console.log('Movie card clicked:', index, card.dataset.movieId);
                            selectMovie(this);
                        });
                    });

                    // Thêm click listeners cho cinema chips
                    const cinemaChips = document.querySelectorAll('.cinema-chip');
                    console.log('Cinema chips found:', cinemaChips.length);
                    cinemaChips.forEach(chip => {
                        chip.addEventListener('click', function (e) {
                            e.preventDefault();
                            e.stopPropagation();
                            selectCinema(this);
                        });
                    });
                }

                /* 
                    ============================================
                    FUNCTION: startInitialization()
                    ============================================
                    Hàm chính để khởi tạo trang
                    
                    Flow:
                    1. Gọi initializePage() để tạo date cards
                    2. Gọi initializeEventListeners() để setup event listeners
                    3. Retry generateDates() sau các khoảng thời gian để đảm bảo hoạt động
                */
                function startInitialization() {
                    console.log('startInitialization called');
                    initializePage();
                    initializeEventListeners();

                    // Retry generateDates sau một khoảng thời gian ngắn để đảm bảo hoạt động
                    setTimeout(() => {
                        const dateScroll = document.getElementById('dateScroll');
                        const dateCards = document.querySelectorAll('.date-card');
                        if (!dateScroll || dateCards.length === 0) {
                            console.log('Retrying generateDates() - dateScroll or dateCards missing');
                            if (dateScroll) {
                                generateDates();
                            }
                        }
                    }, 500);

                    // Retry thêm một lần nữa sau khoảng thời gian dài hơn
                    setTimeout(() => {
                        const dateCards = document.querySelectorAll('.date-card');
                        if (dateCards.length === 0) {
                            console.log('Final retry - generating dates');
                            generateDates();
                        }
                    }, 1000);
                }

                // Khởi tạo khi DOM ready
                if (document.readyState === 'loading') {
                    document.addEventListener('DOMContentLoaded', startInitialization);
                } else {
                    // DOM đã sẵn sàng
                    startInitialization();
                }

                // Cũng thử trên window load như fallback
                window.addEventListener('load', function () {
                    const dateCards = document.querySelectorAll('.date-card');
                    if (dateCards.length === 0) {
                        console.log('Window load: No date cards found, generating dates');
                        generateDates();
                    }
                });

                /* 
                    ============================================
                    EVENT DELEGATION (Primary Method)
                    ============================================
                    Sử dụng event delegation để xử lý click events
                    cho movie cards, cinema chips và showtime buttons
                    
                    Ưu điểm:
                    - Hoạt động với elements được tạo động
                    - Hiệu quả hơn khi có nhiều elements
                    - Không cần attach listener cho từng element
                */
                document.addEventListener('click', function (e) {
                    // Kiểm tra click vào movie card
                    const movieCard = e.target.closest('.movie-card');
                    if (movieCard) {
                        e.preventDefault();
                        e.stopPropagation();
                        console.log('Movie card clicked via delegation:', movieCard.dataset.movieId);
                        selectMovie(movieCard);
                        return;
                    }

                    // Kiểm tra click vào cinema chip
                    const cinemaChip = e.target.closest('.cinema-chip');
                    if (cinemaChip) {
                        e.preventDefault();
                        e.stopPropagation();
                        selectCinema(cinemaChip);
                        return;
                    }

                    // Kiểm tra click vào showtime button
                    if (e.target.closest('.showtime-btn')) {
                        const btn = e.target.closest('.showtime-btn');
                        // Chỉ cho phép chọn nếu chưa hết chỗ
                        if (!btn.classList.contains('sold-out')) {
                            selectShowtime(btn);
                        }
                        return;
                    }
                });
            </script>
        </body>

        </html>