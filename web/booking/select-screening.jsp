<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@page import="java.util.List" %>
        <%@page import="entity.Cinema" %>
            <%@page import="entity.Movie" %>
                <!DOCTYPE html>
                <html lang="vi">

                <head>
                    <meta charset="UTF-8">
                    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
                    <meta http-equiv="Pragma" content="no-cache">
                    <meta http-equiv="Expires" content="0">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Chọn Suất Chiếu - Cinema Booking</title>
                    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
                        rel="stylesheet">
                    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css"
                        rel="stylesheet">
                    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/select-screening.css">
                </head>

                <body>
                    <!-- Progress Steps -->
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

                    <!-- Main Content -->
                    <div class="main-container">
                        <div class="movie-header">
                            <h1><i class="fas fa-film"></i> Chọn Suất Chiếu</h1>
                            <p>Chọn phim, rạp, ngày và giờ chiếu phù hợp với bạn</p>
                        </div>

                        <!-- Alert Messages -->
                        <% if (request.getAttribute("error") !=null) { %>
                            <div class="alert alert-danger" role="alert">
                                <i class="fas fa-exclamation-circle"></i>
                                <%= request.getAttribute("error") %>
                            </div>
                            <% } %>

                                <% if (request.getAttribute("success") !=null) { %>
                                    <div class="alert alert-info" role="alert">
                                        <i class="fas fa-check-circle"></i>
                                        <%= request.getAttribute("success") %>
                                    </div>
                                    <% } %>

                                        <!-- Movie Selection -->
                                        <div class="selection-section">
                                            <div class="section-title">
                                                <i class="fas fa-film"></i>
                                                <span>Chọn Phim</span>
                                            </div>
                                            <div class="movie-grid" id="movieGrid">
                                                <% List<Movie> movies = (List<Movie>) request.getAttribute("movies");
                                                        if (movies != null && !movies.isEmpty()) {
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
                                                        <% } } else { %>
                                                            <div class="empty-state">
                                                                <i class="fas fa-film"></i>
                                                                <p>Không có phim nào đang chiếu</p>
                                                            </div>
                                                            <% } %>
                                            </div>
                                        </div>

                                        <!-- Cinema Selection -->
                                        <div class="selection-section">
                                            <div class="section-title">
                                                <i class="fas fa-building"></i>
                                                <span>Chọn Rạp</span>
                                            </div>
                                            <div class="cinema-chips" id="cinemaChips">
                                                <% List<Cinema> cinemas = (List<Cinema>)
                                                        request.getAttribute("cinemas");
                                                        if (cinemas != null && !cinemas.isEmpty()) {
                                                        for (Cinema cinema : cinemas) {
                                                        %>
                                                        <div class="cinema-chip"
                                                            data-cinema-id="<%= cinema.getCinemaID() %>"
                                                            data-cinema-name="<%= cinema.getCinemaName() %>">
                                                            <i class="fas fa-map-marker-alt"></i>
                                                            <%= cinema.getCinemaName() %>
                                                        </div>
                                                        <% } } else { %>
                                                            <div class="empty-state">
                                                                <i class="fas fa-building"></i>
                                                                <p>Không có rạp nào khả dụng</p>
                                                            </div>
                                                            <% } %>
                                            </div>
                                        </div>

                                        <!-- Date Selection -->
                                        <div class="selection-section">
                                            <div class="section-title">
                                                <i class="fas fa-calendar-alt"></i>
                                                <span>Chọn Ngày</span>
                                            </div>
                                            <div class="date-scroll" id="dateScroll">
                                                <!-- Dates will be generated by JavaScript -->
                                            </div>
                                        </div>

                                        <!-- Showtimes -->
                                        <div class="selection-section showtime-container" id="showtimeContainer">
                                            <div class="section-title">
                                                <i class="fas fa-clock"></i>
                                                <span>Chọn Giờ Chiếu</span>
                                            </div>
                                            <div id="showtimeContent">
                                                <div class="loading">
                                                    <i class="fas fa-spinner"></i>
                                                    <p>Đang tải suất chiếu...</p>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- Continue Button -->
                                        <div class="continue-section">
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
                                            <form method="post"
                                                action="${pageContext.request.contextPath}/booking/select-screening"
                                                id="screeningForm">
                                                <input type="hidden" name="screeningID" id="screeningIDInput">
                                                <button type="submit" class="continue-btn" id="continueBtn" disabled>
                                                    <i class="fas fa-arrow-right"></i> Tiếp Tục Chọn Ghế
                                                </button>
                                            </form>
                                        </div>
                    </div>

                    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
                    <script>
                        // State Management
                        let selectedMovie = null;
                        let selectedMovieName = '';
                        let selectedCinema = null;
                        let selectedCinemaName = '';
                        let selectedDate = null; // Will be set by generateDates()
                        let selectedScreening = null;
                        let selectedTime = '';

                        // Helper function to ensure selectedDate is valid
                        function ensureValidDate() {
                            // Check if selectedDate is invalid
                            if (!selectedDate || selectedDate === '--' || selectedDate === 'null' || selectedDate === 'undefined' ||
                                (typeof selectedDate === 'string' && selectedDate.trim() === '')) {

                                const today = new Date();
                                const year = today.getFullYear();
                                const monthNum = today.getMonth() + 1;
                                const dayNum = today.getDate();

                                // Validate values before creating date string
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

                                const month = String(monthNum).padStart(2, '0');
                                const day = String(dayNum).padStart(2, '0');
                                const newDate = year + '-' + month + '-' + day;

                                // Final validation
                                if (!newDate || newDate === '--' || !/^\d{4}-\d{2}-\d{2}$/.test(newDate)) {
                                    console.error('ensureValidDate(): Generated invalid date string:', newDate);
                                    return null;
                                }

                                selectedDate = newDate;
                                console.log('ensureValidDate(): Force-set selectedDate to:', selectedDate, '(from today:', year, month, day + ')');
                                return selectedDate;
                            }

                            // Validate format if date exists
                            if (typeof selectedDate === 'string' && !/^\d{4}-\d{2}-\d{2}$/.test(selectedDate)) {
                                console.warn('ensureValidDate(): Invalid date format detected:', selectedDate);
                                // Recursive call to fix it
                                const originalDate = selectedDate;
                                selectedDate = null;
                                return ensureValidDate();
                            }

                            return selectedDate;
                        }

                        // Generate Date Cards
                        function generateDates() {
                            try {
                                console.log('=== generateDates() START ===');
                                console.log('document.readyState:', document.readyState);
                                console.log('document.body exists?', !!document.body);

                                let dateScroll = document.getElementById('dateScroll');

                                // Try multiple ways to find the element
                                if (!dateScroll) {
                                    console.warn('dateScroll not found by ID, trying by class...');
                                    dateScroll = document.querySelector('.date-scroll');
                                }

                                if (!dateScroll) {
                                    console.error('dateScroll element not found! Will retry...');
                                    // Retry after a short delay
                                    setTimeout(() => {
                                        console.log('Retrying generateDates() after delay...');
                                        generateDates();
                                    }, 200);
                                    return;
                                }

                                console.log('Found dateScroll element:', dateScroll);
                                console.log('dateScroll parent:', dateScroll.parentElement);
                                console.log('dateScroll offsetParent:', dateScroll.offsetParent);

                                // Clear any existing dates first
                                dateScroll.innerHTML = '';

                                // Ensure the parent section is visible
                                let dateSection = dateScroll.closest('.selection-section');
                                if (dateSection) {
                                    dateSection.style.display = 'block';
                                }
                                dateScroll.style.display = 'flex';

                                console.log('Generating dates for dateScroll element:', dateScroll);
                                console.log('dateScroll parent:', dateScroll.parentElement);
                                console.log('dateScroll visible?', dateScroll.offsetParent !== null);

                                const todayDate = new Date();
                                const dates = [];

                                for (let i = 0; i < 7; i++) {
                                    const date = new Date(todayDate);
                                    date.setDate(todayDate.getDate() + i);
                                    dates.push(date);
                                }

                                console.log('Generated dates array:', dates.map(d => d.toISOString().split('T')[0]));

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

                                    // Format date as YYYY-MM-DD using local timezone (not UTC)
                                    // Use a more robust formatting approach
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

                                    // Build date string explicitly to avoid template literal issues
                                    const monthStr = (month < 10 ? '0' : '') + month;
                                    const dayStr = (day < 10 ? '0' : '') + day;
                                    const dateStr = year + '-' + monthStr + '-' + dayStr;

                                    // Validate date string before setting
                                    if (!dateStr || dateStr.length !== 10 || !/^\d{4}-\d{2}-\d{2}$/.test(dateStr)) {
                                        console.error('Invalid date string generated:', dateStr, 'length:', dateStr ? dateStr.length : 0, 'for date:', date, 'components:', { year, month, day });
                                        return; // Skip this date card
                                    }

                                    // Debug log successful date string creation
                                    console.log('Successfully created dateStr:', dateStr, 'for date:', date.toISOString());

                                    dateCard.dataset.date = dateStr;

                                    // Save first valid date
                                    if (index === 0 && !firstValidDate) {
                                        firstValidDate = dateStr;
                                    }

                                    const dayName = dayNames[date.getDay()];
                                    const dayNum = date.getDate();
                                    const monthName = monthNames[date.getMonth()];

                                    // Create inner elements
                                    const dayNameDiv = document.createElement('div');
                                    dayNameDiv.className = 'day-name';
                                    dayNameDiv.textContent = dayName;

                                    const dayNumDiv = document.createElement('div');
                                    dayNumDiv.className = 'day-num';
                                    dayNumDiv.textContent = dayNum;

                                    const monthDiv = document.createElement('div');
                                    monthDiv.className = 'month';
                                    monthDiv.textContent = monthName;

                                    dateCard.appendChild(dayNameDiv);
                                    dateCard.appendChild(dayNumDiv);
                                    dateCard.appendChild(monthDiv);

                                    dateCard.addEventListener('click', function () {
                                        selectDate(this);
                                    });
                                    dateScroll.appendChild(dateCard);

                                    console.log('Created date card:', dayName, dayNum, monthName, 'with date:', dateStr);
                                    console.log('Date card appended to dateScroll. dateScroll children count:', dateScroll.children.length);
                                });

                                console.log('Generated', dates.length, 'date cards');
                                console.log('Final dateScroll children count:', dateScroll.children.length);
                                console.log('Final dateScroll innerHTML length:', dateScroll.innerHTML.length);

                                // Force visibility of date scroll and its parent
                                if (dateScroll) {
                                    dateScroll.style.display = 'flex';
                                    dateScroll.style.visibility = 'visible';
                                    dateScroll.style.opacity = '1';
                                }

                                // Reuse dateSection variable (already declared earlier in function)
                                dateSection = dateScroll?.closest('.selection-section');
                                if (dateSection) {
                                    dateSection.style.display = 'block';
                                    dateSection.style.visibility = 'visible';
                                }

                                // Set selectedDate from first valid date
                                if (firstValidDate) {
                                    selectedDate = firstValidDate;
                                    console.log('Auto-selected first date:', selectedDate);
                                } else {
                                    // Fallback: get from first date card in DOM
                                    const firstDateCard = document.querySelector('.date-card[data-date]');
                                    if (firstDateCard && firstDateCard.dataset.date) {
                                        selectedDate = firstDateCard.dataset.date;
                                        console.log('Fallback: Set selectedDate from first date card:', selectedDate);
                                    } else {
                                        // Last resort: generate from today
                                        const today = new Date();
                                        const year = today.getFullYear();
                                        const month = String(today.getMonth() + 1).padStart(2, '0');
                                        const day = String(today.getDate()).padStart(2, '0');
                                        selectedDate = `${year}-${month}-${day}`;
                                        console.log('Last resort: Generated selectedDate:', selectedDate);
                                    }
                                }

                                console.log('Final selectedDate after generation:', selectedDate);

                                // Final verification that date cards are in DOM
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

                                    // Force visibility one more time
                                    dateScroll.style.display = 'flex';
                                    dateScroll.style.visibility = 'visible';
                                    dateScroll.style.opacity = '1';

                                    // Force reflow to ensure rendering
                                    void dateScroll.offsetHeight;

                                    // Log each date card for debugging
                                    finalDateCards.forEach((card, idx) => {
                                        console.log(`Date card ${idx}:`, card.textContent, 'data-date:', card.dataset.date, 'visible:', card.offsetParent !== null);
                                    });
                                }

                                console.log('=== generateDates() END ===');
                                return true; // Indicate success

                            } catch (error) {
                                console.error('Error in generateDates():', error);
                                // Last resort: generate from today
                                const today = new Date();
                                const year = today.getFullYear();
                                const month = String(today.getMonth() + 1).padStart(2, '0');
                                const day = String(today.getDate()).padStart(2, '0');
                                selectedDate = `${year}-${month}-${day}`;
                                console.log('Error recovery: Generated selectedDate:', selectedDate);
                            }
                        }

                        // Selection Functions
                        function selectMovie(movieCard) {
                            try {
                                console.log('selectMovie called with:', movieCard);

                                if (!movieCard) {
                                    console.error('Movie card is null or undefined');
                                    return;
                                }

                                const movieId = parseInt(movieCard.dataset.movieId);
                                const movieName = movieCard.dataset.movieName;

                                // Check for NaN explicitly - allow 0 as valid ID
                                if (isNaN(movieId) || movieCard.dataset.movieId === undefined) {
                                    console.error('Invalid movie ID:', movieCard.dataset.movieId);
                                    return;
                                }

                                console.log('Selecting movie:', movieId, movieName);

                                // Remove previous selection
                                document.querySelectorAll('.movie-card').forEach(card => {
                                    card.classList.remove('selected');
                                });

                                // Add selection to clicked card
                                movieCard.classList.add('selected');

                                selectedMovie = movieId;
                                selectedMovieName = movieName;

                                // Reset screening selection when movie changes
                                selectedScreening = null;
                                selectedTime = '';

                                const continueBtn = document.getElementById('continueBtn');
                                if (continueBtn) {
                                    continueBtn.disabled = true;
                                }

                                // Ensure selectedDate is valid before checking
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

                                // Only load showtimes if all selections are made AND selectedDate is valid
                                if (selectedCinema && selectedDate && selectedDate !== '--' && selectedDate !== 'null' &&
                                    /^\d{4}-\d{2}-\d{2}$/.test(selectedDate)) {
                                    loadShowtimes();
                                } else {
                                    // Clear showtimes if movie changed but cinema or date not selected/valid
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

                        function selectCinema(cinemaChip) {
                            const cinemaId = parseInt(cinemaChip.dataset.cinemaId);
                            const cinemaName = cinemaChip.dataset.cinemaName;

                            // Remove previous selection
                            document.querySelectorAll('.cinema-chip').forEach(chip => {
                                chip.classList.remove('selected');
                            });

                            // Add selection to clicked chip
                            cinemaChip.classList.add('selected');

                            selectedCinema = cinemaId;
                            selectedCinemaName = cinemaName;

                            // Reset screening selection when cinema changes
                            selectedScreening = null;
                            selectedTime = '';
                            document.getElementById('continueBtn').disabled = true;

                            // Ensure selectedDate is valid before checking
                            const validDate = ensureValidDate();
                            if (!validDate) {
                                console.error('Cannot ensure valid date!');
                                const content = document.getElementById('showtimeContent');
                                if (content) {
                                    content.innerHTML = '<div class="empty-state"><p>Lỗi: Không thể xác định ngày. Vui lòng tải lại trang.</p></div>';
                                }
                                return;
                            }

                            // Only load showtimes if all selections are made AND selectedDate is valid - allow movie ID = 0
                            if (selectedMovie !== null && selectedMovie !== undefined &&
                                selectedDate && selectedDate !== '--' && selectedDate !== 'null' &&
                                /^\d{4}-\d{2}-\d{2}$/.test(selectedDate)) {
                                loadShowtimes();
                            } else {
                                // Clear showtimes if cinema changed but movie or date not selected/valid
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

                        function selectDate(dateCard) {
                            const dateStr = dateCard.dataset.date;

                            // Validate date string
                            if (!dateStr || dateStr === '--' || dateStr === 'null' || dateStr.trim() === '') {
                                console.error('Invalid date string from date card:', dateStr);
                                return;
                            }

                            // Validate date format
                            const dateRegex = /^\d{4}-\d{2}-\d{2}$/;
                            if (!dateRegex.test(dateStr)) {
                                console.error('Invalid date format from date card:', dateStr);
                                return;
                            }

                            console.log('Date selected:', dateStr);

                            // Remove previous selection
                            document.querySelectorAll('.date-card').forEach(card => {
                                card.classList.remove('selected');
                            });

                            // Add selection
                            dateCard.classList.add('selected');
                            selectedDate = dateStr;

                            // Reset screening selection when date changes
                            selectedScreening = null;
                            selectedTime = '';
                            document.getElementById('continueBtn').disabled = true;

                            // Only load showtimes if all selections are made - allow movie ID = 0
                            if (selectedMovie !== null && selectedMovie !== undefined && selectedCinema) {
                                loadShowtimes();
                            }
                            updateSummary();
                        }

                        function selectShowtime(showtimeBtn) {
                            const screeningId = parseInt(showtimeBtn.dataset.screeningId);
                            const time = showtimeBtn.dataset.time;
                            const room = showtimeBtn.dataset.room;

                            // Remove previous selection
                            document.querySelectorAll('.showtime-btn').forEach(btn => {
                                btn.classList.remove('selected');
                            });

                            // Add selection
                            showtimeBtn.classList.add('selected');

                            selectedScreening = screeningId;
                            selectedTime = time;

                            // Update form
                            document.getElementById('screeningIDInput').value = screeningId;
                            document.getElementById('continueBtn').disabled = false;

                            updateSummary();
                        }

                        // Load Showtimes
                        function loadShowtimes() {
                            console.log('loadShowtimes called with:', {
                                movie: selectedMovie,
                                cinema: selectedCinema,
                                date: selectedDate,
                                dateType: typeof selectedDate
                            });

                            // Validate all required selections - allow movie ID = 0
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

                            // Additional validation for invalid date values
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

                            // Validate date format (YYYY-MM-DD)
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

                            container.classList.add('visible');
                            content.innerHTML = '<div class="loading"><i class="fas fa-spinner"></i><p>Đang tải suất chiếu...</p></div>';

                            console.log('Loading showtimes for:', {
                                cinemaID: selectedCinema,
                                movieID: selectedMovie,
                                date: selectedDate
                            });

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

                                    if (data.success && data.screenings && data.screenings.length > 0) {
                                        // Clear content
                                        content.innerHTML = '';

                                        // Create grid container
                                        const showtimeGrid = document.createElement('div');
                                        showtimeGrid.className = 'showtime-grid';

                                        data.screenings.forEach(screening => {
                                            const seats = screening.availableSeats || 0;
                                            const limited = seats < 20 && seats > 0;
                                            const soldOut = seats === 0;

                                            let seatClass = '';
                                            let seatText = seats + ' ghế trống';

                                            if (soldOut) {
                                                seatClass = 'sold-out';
                                                seatText = 'Hết chỗ';
                                            } else if (limited) {
                                                seatClass = 'limited';
                                            }

                                            // Create showtime button
                                            const showtimeBtn = document.createElement('div');
                                            showtimeBtn.className = 'showtime-btn ' + seatClass;
                                            showtimeBtn.dataset.screeningId = screening.screeningID;
                                            showtimeBtn.dataset.time = screening.startTime;
                                            showtimeBtn.dataset.room = screening.roomName;

                                            // Create time element
                                            const timeDiv = document.createElement('div');
                                            timeDiv.className = 'time';
                                            const timeText = screening.endTime ?
                                                screening.startTime + ' - ' + screening.endTime :
                                                screening.startTime;
                                            timeDiv.textContent = timeText;

                                            // Create room element
                                            const roomDiv = document.createElement('div');
                                            roomDiv.className = 'room';
                                            roomDiv.textContent = screening.roomName;

                                            // Create seats element
                                            const seatsDiv = document.createElement('div');
                                            seatsDiv.className = 'seats';

                                            const chairIcon = document.createElement('i');
                                            chairIcon.className = 'fas fa-chair';
                                            seatsDiv.appendChild(chairIcon);

                                            const seatsText = document.createTextNode(' ' + seatText);
                                            seatsDiv.appendChild(seatsText);

                                            // Append all to button
                                            showtimeBtn.appendChild(timeDiv);
                                            showtimeBtn.appendChild(roomDiv);
                                            showtimeBtn.appendChild(seatsDiv);

                                            // Add click event listener
                                            showtimeBtn.addEventListener('click', function (e) {
                                                e.preventDefault();
                                                e.stopPropagation();
                                                if (!this.classList.contains('sold-out')) {
                                                    selectShowtime(this);
                                                }
                                            });

                                            // Add to grid
                                            showtimeGrid.appendChild(showtimeBtn);

                                            console.log('Created showtime:', screening.startTime, screening.roomName, 'Available seats:', seats);
                                        });

                                        content.appendChild(showtimeGrid);
                                        console.log('Loaded', data.screenings.length, 'showtimes');
                                        console.log('Showtime grid appended to content. Content children:', content.children.length);
                                        console.log('Container visible?', container.classList.contains('visible'));

                                        // Force show container
                                        container.classList.add('visible');
                                        container.style.display = 'block';
                                    } else {
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

                        // Update Summary
                        function updateSummary() {
                            const summary = document.getElementById('selectionSummary');

                            // Allow movie ID = 0
                            if (selectedMovie !== null && selectedMovie !== undefined &&
                                selectedCinema && selectedDate && selectedScreening) {
                                summary.style.display = 'block';

                                document.getElementById('summaryMovie').textContent = selectedMovieName;
                                document.getElementById('summaryCinema').textContent = selectedCinemaName;

                                // Format date - validate first
                                if (selectedDate && selectedDate !== '--' && selectedDate !== 'null') {
                                    try {
                                        const dateObj = new Date(selectedDate + 'T00:00:00'); // Add time to avoid timezone issues
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

                                document.getElementById('summaryTime').textContent = selectedTime;
                            } else {
                                if (summary) {
                                    summary.style.display = 'none';
                                }
                            }
                        }

                        // Initialize function
                        function initializePage() {
                            console.log('=== initializePage() START ===');
                            console.log('Initializing page...');
                            console.log('selectedDate before generateDates:', selectedDate);

                            // Ensure date selection section is visible
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

                            // Generate dates - with retry if element not found
                            if (!dateScroll) {
                                console.warn('dateScroll not found immediately, retrying in 100ms...');
                                setTimeout(() => {
                                    generateDates();
                                    verifyDatesCreated();
                                }, 100);
                            } else {
                                generateDates();
                            }

                            // Verify after a short delay to ensure DOM is updated
                            setTimeout(() => {
                                verifyDatesCreated();
                            }, 200);
                        }

                        function verifyDatesCreated() {
                            console.log('Verifying dates created...');
                            console.log('selectedDate after generateDates:', selectedDate);

                            // Verify date cards were created
                            const dateCards = document.querySelectorAll('.date-card');
                            console.log('Date cards found after generateDates:', dateCards.length);
                            if (dateCards.length > 0) {
                                console.log('First date card:', dateCards[0]);
                                console.log('First date card dataset:', dateCards[0].dataset);
                                console.log('Date cards are visible!');
                            } else {
                                console.error('WARNING: No date cards found after generateDates()!');
                                // Try generating again
                                const dateScroll = document.getElementById('dateScroll');
                                if (dateScroll) {
                                    console.log('Retrying generateDates()...');
                                    generateDates();
                                }
                            }

                            // Final verification
                            if (!selectedDate || selectedDate === '--' || selectedDate === 'null') {
                                console.error('WARNING: selectedDate is still invalid after generateDates:', selectedDate);
                                // Force set a valid date
                                const today = new Date();
                                const year = today.getFullYear();
                                const month = String(today.getMonth() + 1).padStart(2, '0');
                                const day = String(today.getDate()).padStart(2, '0');
                                selectedDate = `${year}-${month}-${day}`;
                                console.log('Force-set selectedDate to:', selectedDate);
                            }
                        }

                        function initializeEventListeners() {
                            // Log movie cards count for debugging
                            const movieCards = document.querySelectorAll('.movie-card');
                            console.log('Movie cards found:', movieCards.length);

                            // Add click listeners to movie cards (backup method)
                            movieCards.forEach((card, index) => {
                                card.addEventListener('click', function (e) {
                                    e.preventDefault();
                                    e.stopPropagation();
                                    console.log('Movie card clicked:', index, card.dataset.movieId);
                                    selectMovie(this);
                                });
                            });

                            // Add click listeners to cinema chips
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

                        // Initialize Event Listeners
                        function startInitialization() {
                            console.log('startInitialization called');
                            initializePage();
                            initializeEventListeners();

                            // Retry generateDates after a short delay to ensure it works
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

                            // Another retry after longer delay
                            setTimeout(() => {
                                const dateCards = document.querySelectorAll('.date-card');
                                if (dateCards.length === 0) {
                                    console.log('Final retry - generating dates');
                                    generateDates();
                                }
                            }, 1000);
                        }

                        if (document.readyState === 'loading') {
                            document.addEventListener('DOMContentLoaded', startInitialization);
                        } else {
                            // DOM is already ready
                            startInitialization();
                        }

                        // Also try on window load as fallback
                        window.addEventListener('load', function () {
                            const dateCards = document.querySelectorAll('.date-card');
                            if (dateCards.length === 0) {
                                console.log('Window load: No date cards found, generating dates');
                                generateDates();
                            }
                        });

                        // Add event delegation for movie cards (primary method)
                        document.addEventListener('click', function (e) {
                            // Check for movie card clicks
                            const movieCard = e.target.closest('.movie-card');
                            if (movieCard) {
                                e.preventDefault();
                                e.stopPropagation();
                                console.log('Movie card clicked via delegation:', movieCard.dataset.movieId);
                                selectMovie(movieCard);
                                return;
                            }

                            // Check for cinema chip clicks
                            const cinemaChip = e.target.closest('.cinema-chip');
                            if (cinemaChip) {
                                e.preventDefault();
                                e.stopPropagation();
                                selectCinema(cinemaChip);
                                return;
                            }

                            // Check for showtime button clicks
                            if (e.target.closest('.showtime-btn')) {
                                const btn = e.target.closest('.showtime-btn');
                                if (!btn.classList.contains('sold-out')) {
                                    selectShowtime(btn);
                                }
                                return;
                            }
                        });
                    </script>
                </body>

                </html>