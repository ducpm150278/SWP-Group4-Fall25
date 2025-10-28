<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="entity.Cinema"%>
<%@page import="entity.Movie"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <meta http-equiv="Pragma" content="no-cache">
    <meta http-equiv="Expires" content="0">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chọn Suất Chiếu - Cinema Booking</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            background: #0f1014;
            min-height: 100vh;
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            color: #fff;
        }
        
        /* Progress Steps */
        .progress-container {
            background: #1a1d24;
            padding: 20px 0;
            border-bottom: 1px solid #2a2d35;
        }
        
        .progress-steps {
            max-width: 800px;
            margin: 0 auto;
            display: flex;
            justify-content: space-between;
            position: relative;
            padding: 0 20px;
        }
        
        .progress-steps::before {
            content: '';
            position: absolute;
            top: 20px;
            left: 15%;
            right: 15%;
            height: 2px;
            background: #2a2d35;
            z-index: 0;
        }
        
        .step {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 10px;
            position: relative;
            z-index: 1;
        }
        
        .step-circle {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: #2a2d35;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
            transition: all 0.3s;
        }
        
        .step.active .step-circle {
            background: #e50914;
            box-shadow: 0 0 20px rgba(229, 9, 20, 0.5);
        }
        
        .step.completed .step-circle {
            background: #2ea043;
        }
        
        .step-label {
            font-size: 12px;
            color: #8b92a7;
        }
        
        .step.active .step-label {
            color: #fff;
            font-weight: 600;
        }
        
        /* Main Container */
        .main-container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 30px 20px;
        }
        
        /* Movie Selection */
        .movie-header {
            margin-bottom: 30px;
        }
        
        .movie-header h1 {
            font-size: 28px;
            font-weight: 700;
            margin-bottom: 10px;
        }
        
        .movie-header p {
            color: #8b92a7;
            font-size: 16px;
        }
        
        /* Movie & Cinema Selection Cards */
        .selection-section {
            background: #1a1d24;
            border-radius: 12px;
            padding: 25px;
            margin-bottom: 25px;
            border: 1px solid #2a2d35;
        }
        
        .section-title {
            font-size: 18px;
            font-weight: 600;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
            color: #fff;
        }
        
        .section-title i {
            color: #e50914;
        }
        
        /* Movie Cards Grid */
        .movie-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
            gap: 15px;
            margin-bottom: 10px;
        }
        
        .movie-card {
            background: #2a2d35;
            border-radius: 8px;
            padding: 12px;
            cursor: pointer;
            transition: all 0.3s;
            border: 2px solid transparent;
            text-align: center;
        }
        
        .movie-card:hover {
            transform: translateY(-5px);
            border-color: #e50914;
            background: #32353d;
        }
        
        .movie-card.selected {
            border-color: #e50914;
            background: rgba(229, 9, 20, 0.1);
        }
        
        .movie-card .movie-icon {
            font-size: 40px;
            margin-bottom: 10px;
            color: #e50914;
        }
        
        .movie-card .movie-name {
            font-size: 14px;
            font-weight: 500;
            margin-bottom: 5px;
            color: #fff;
        }
        
        .movie-card .movie-duration {
            font-size: 12px;
            color: #8b92a7;
        }
        
        /* Cinema Chips */
        .cinema-chips {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
        }
        
        .cinema-chip {
            background: #2a2d35;
            border: 2px solid transparent;
            border-radius: 25px;
            padding: 12px 24px;
            cursor: pointer;
            transition: all 0.3s;
            font-size: 14px;
            font-weight: 500;
        }
        
        .cinema-chip:hover {
            border-color: #e50914;
            background: #32353d;
        }
        
        .cinema-chip.selected {
            background: #e50914;
            border-color: #e50914;
            color: #fff;
        }
        
        /* Date Selector */
        .date-scroll {
            display: flex;
            gap: 10px;
            overflow-x: auto;
            padding: 10px 0;
            scrollbar-width: thin;
            scrollbar-color: #e50914 #2a2d35;
        }
        
        .date-scroll::-webkit-scrollbar {
            height: 6px;
        }
        
        .date-scroll::-webkit-scrollbar-track {
            background: #2a2d35;
            border-radius: 3px;
        }
        
        .date-scroll::-webkit-scrollbar-thumb {
            background: #e50914;
            border-radius: 3px;
        }
        
        .date-card {
            min-width: 100px;
            background: #2a2d35;
            border: 2px solid transparent;
            border-radius: 12px;
            padding: 15px;
            text-align: center;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .date-card:hover {
            border-color: #e50914;
            background: #32353d;
        }
        
        .date-card.selected {
            background: #e50914;
            border-color: #e50914;
        }
        
        .date-card .day-name {
            font-size: 12px;
            color: #8b92a7;
            margin-bottom: 5px;
            display: block;
            line-height: 1.2;
        }
        
        .date-card.selected .day-name {
            color: #fff;
        }
        
        .date-card .day-num {
            font-size: 24px;
            font-weight: 700;
            margin-bottom: 5px;
            color: #fff;
            display: block;
            line-height: 1.2;
        }
        
        .date-card .month {
            font-size: 12px;
            color: #8b92a7;
            display: block;
            line-height: 1.2;
        }
        
        .date-card.selected .month {
            color: #fff;
        }
        
        /* Showtimes */
        .showtime-container {
            display: none;
            animation: fadeIn 0.3s;
        }
        
        .showtime-container.visible {
            display: block;
        }
        
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        .showtime-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
            gap: 12px;
        }
        
        .showtime-btn {
            background: #2a2d35;
            border: 2px solid #2a2d35;
            border-radius: 8px;
            padding: 15px 10px;
            cursor: pointer;
            transition: all 0.3s;
            text-align: center;
        }
        
        .showtime-btn:hover {
            border-color: #e50914;
            background: #32353d;
            transform: translateY(-2px);
        }
        
        .showtime-btn.selected {
            background: rgba(229, 9, 20, 0.2);
            border-color: #e50914;
        }
        
        .showtime-btn .time {
            font-size: 18px;
            font-weight: 700;
            margin-bottom: 5px;
            color: #fff;
            display: block;
            line-height: 1.2;
        }
        
        .showtime-btn .room {
            font-size: 11px;
            color: #8b92a7;
            margin-bottom: 5px;
            display: block;
            line-height: 1.2;
        }
        
        .showtime-btn .seats {
            font-size: 10px;
            color: #2ea043;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 5px;
            line-height: 1.2;
        }
        
        .showtime-btn.limited .seats {
            color: #ff9500;
        }
        
        .showtime-btn.sold-out {
            opacity: 0.5;
            cursor: not-allowed;
            pointer-events: none;
        }
        
        /* Continue Button */
        .continue-section {
            margin-top: 30px;
            text-align: center;
            padding: 20px;
            background: #1a1d24;
            border-radius: 12px;
            border: 1px solid #2a2d35;
        }
        
        .continue-btn {
            background: #e50914;
            color: #fff;
            border: none;
            border-radius: 8px;
            padding: 16px 50px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .continue-btn:hover {
            background: #b20710;
            transform: translateY(-2px);
            box-shadow: 0 10px 30px rgba(229, 9, 20, 0.3);
        }
        
        .continue-btn:disabled {
            background: #2a2d35;
            color: #8b92a7;
            cursor: not-allowed;
            transform: none;
        }
        
        .selection-summary {
            margin-bottom: 20px;
            padding: 15px;
            background: #2a2d35;
            border-radius: 8px;
            font-size: 14px;
        }
        
        .selection-summary .summary-item {
            margin-bottom: 8px;
            display: flex;
            justify-content: space-between;
        }
        
        .selection-summary .summary-label {
            color: #8b92a7;
        }
        
        .selection-summary .summary-value {
            color: #fff;
            font-weight: 600;
        }
        
        /* Alert Messages */
        .alert {
            border-radius: 8px;
            margin-bottom: 20px;
            border: none;
        }
        
        .alert-danger {
            background: rgba(229, 9, 20, 0.2);
            color: #ff6b6b;
            border-left: 4px solid #e50914;
        }
        
        .alert-info {
            background: rgba(41, 98, 255, 0.2);
            color: #5b9eff;
            border-left: 4px solid #2962ff;
        }
        
        /* Empty State */
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #8b92a7;
        }
        
        .empty-state i {
            font-size: 60px;
            margin-bottom: 20px;
            opacity: 0.3;
        }
        
        .empty-state p {
            font-size: 16px;
        }
        
        /* Loading State */
        .loading {
            text-align: center;
            padding: 40px;
            color: #8b92a7;
        }
        
        .loading i {
            font-size: 40px;
            animation: spin 1s linear infinite;
        }
        
        @keyframes spin {
            from { transform: rotate(0deg); }
            to { transform: rotate(360deg); }
        }
        
        /* Responsive */
        @media (max-width: 768px) {
            .movie-grid {
                grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
                gap: 10px;
            }
            
            .showtime-grid {
                grid-template-columns: repeat(auto-fill, minmax(100px, 1fr));
            }
            
            .progress-steps {
                font-size: 12px;
            }
            
            .step-label {
                display: none;
            }
        }
    </style>
</head>
<body>
    <!-- Progress Steps -->
    <div class="progress-container">
        <div class="progress-steps">
            <div class="step active">
                <div class="step-circle">1</div>
                <div class="step-label">Chọn Suất</div>
            </div>
            <div class="step">
                <div class="step-circle">2</div>
                <div class="step-label">Chọn Ghế</div>
            </div>
            <div class="step">
                <div class="step-circle">3</div>
                <div class="step-label">Đồ Ăn & Nước</div>
            </div>
            <div class="step">
                <div class="step-circle">4</div>
                <div class="step-label">Thanh Toán</div>
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
        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-danger" role="alert">
                <i class="fas fa-exclamation-circle"></i> <%= request.getAttribute("error") %>
            </div>
        <% } %>
        
        <% if (request.getAttribute("success") != null) { %>
            <div class="alert alert-info" role="alert">
                <i class="fas fa-check-circle"></i> <%= request.getAttribute("success") %>
            </div>
        <% } %>
        
        <!-- Movie Selection -->
        <div class="selection-section">
            <div class="section-title">
                <i class="fas fa-film"></i>
                <span>Chọn Phim</span>
            </div>
            <div class="movie-grid" id="movieGrid">
                <%
                    List<Movie> movies = (List<Movie>) request.getAttribute("movies");
                    if (movies != null && !movies.isEmpty()) {
                        for (Movie movie : movies) {
                %>
                    <div class="movie-card" data-movie-id="<%= movie.getMovieID() %>" data-movie-name="<%= movie.getTitle() %>">
                        <div class="movie-icon">🎬</div>
                        <div class="movie-name"><%= movie.getTitle() %></div>
                        <div class="movie-duration"><%= movie.getDuration() %> phút</div>
                    </div>
                <%
                        }
                    } else {
                %>
                    <div class="empty-state">
                        <i class="fas fa-film"></i>
                        <p>Không có phim nào đang chiếu</p>
                    </div>
                <%
                    }
                %>
            </div>
        </div>
        
        <!-- Cinema Selection -->
        <div class="selection-section">
            <div class="section-title">
                <i class="fas fa-building"></i>
                <span>Chọn Rạp</span>
            </div>
            <div class="cinema-chips" id="cinemaChips">
                <%
                    List<Cinema> cinemas = (List<Cinema>) request.getAttribute("cinemas");
                    if (cinemas != null && !cinemas.isEmpty()) {
                        for (Cinema cinema : cinemas) {
                %>
                    <div class="cinema-chip" data-cinema-id="<%= cinema.getCinemaID() %>" data-cinema-name="<%= cinema.getCinemaName() %>">
                        <i class="fas fa-map-marker-alt"></i> <%= cinema.getCinemaName() %>
                    </div>
                <%
                        }
                    } else {
                %>
                    <div class="empty-state">
                        <i class="fas fa-building"></i>
                        <p>Không có rạp nào khả dụng</p>
                    </div>
                <%
                    }
                %>
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
            <form method="post" action="${pageContext.request.contextPath}/booking/select-screening" id="screeningForm">
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
        let selectedDate = null;
        let selectedScreening = null;
        let selectedTime = '';
        
        // Generate Date Cards
        function generateDates() {
            const dateScroll = document.getElementById('dateScroll');
            
            if (!dateScroll) {
                console.error('dateScroll element not found!');
                return;
            }
            
            console.log('Generating dates for dateScroll element:', dateScroll);
            
            const today = new Date();
            const dates = [];
            
            for (let i = 0; i < 7; i++) {
                const date = new Date(today);
                date.setDate(today.getDate() + i);
                dates.push(date);
            }
            
            const dayNames = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
            const monthNames = ['Th1', 'Th2', 'Th3', 'Th4', 'Th5', 'Th6', 'Th7', 'Th8', 'Th9', 'Th10', 'Th11', 'Th12'];
            
            dates.forEach((date, index) => {
                const dateCard = document.createElement('div');
                dateCard.className = 'date-card' + (index === 0 ? ' selected' : '');
                dateCard.dataset.date = date.toISOString().split('T')[0];
                
                const dayName = dayNames[date.getDay()];
                const dayNum = date.getDate();
                const month = monthNames[date.getMonth()];
                
                // Create inner elements
                const dayNameDiv = document.createElement('div');
                dayNameDiv.className = 'day-name';
                dayNameDiv.textContent = dayName;
                
                const dayNumDiv = document.createElement('div');
                dayNumDiv.className = 'day-num';
                dayNumDiv.textContent = dayNum;
                
                const monthDiv = document.createElement('div');
                monthDiv.className = 'month';
                monthDiv.textContent = month;
                
                dateCard.appendChild(dayNameDiv);
                dateCard.appendChild(dayNumDiv);
                dateCard.appendChild(monthDiv);
                
                dateCard.addEventListener('click', function() {
                    selectDate(this);
                });
                dateScroll.appendChild(dateCard);
                
                console.log('Created date card:', dayName, dayNum, month);
            });
            
            console.log('Generated', dates.length, 'date cards');
            
            // Auto-select today
            selectedDate = dates[0].toISOString().split('T')[0];
        }
        
        // Selection Functions
        function selectMovie(movieCard) {
            const movieId = parseInt(movieCard.dataset.movieId);
            const movieName = movieCard.dataset.movieName;
            
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
            document.getElementById('continueBtn').disabled = true;
            
            loadShowtimes();
            updateSummary();
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
            
            loadShowtimes();
            updateSummary();
        }
        
        function selectDate(dateCard) {
            const dateStr = dateCard.dataset.date;
            
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
            
            loadShowtimes();
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
            if (!selectedMovie || !selectedCinema || !selectedDate) {
                return;
            }
            
            const container = document.getElementById('showtimeContainer');
            const content = document.getElementById('showtimeContent');
            
            container.classList.add('visible');
            content.innerHTML = '<div class="loading"><i class="fas fa-spinner"></i><p>Đang tải suất chiếu...</p></div>';
            
            const url = '${pageContext.request.contextPath}/api/load-screenings?' + 
                        'cinemaID=' + encodeURIComponent(selectedCinema) + 
                        '&movieID=' + encodeURIComponent(selectedMovie) + 
                        '&date=' + encodeURIComponent(selectedDate) +
                        '&_=' + new Date().getTime();
            
            fetch(url)
                .then(response => response.json())
                .then(data => {
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
                            timeDiv.textContent = screening.startTime;
                            
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
                            
                            // Add to grid
                            showtimeGrid.appendChild(showtimeBtn);
                            
                            console.log('Created showtime:', screening.startTime, screening.roomName);
                        });
                        
                        content.appendChild(showtimeGrid);
                        console.log('Loaded', data.screenings.length, 'showtimes');
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
            
            if (selectedMovie && selectedCinema && selectedDate && selectedScreening) {
                summary.style.display = 'block';
                
                document.getElementById('summaryMovie').textContent = selectedMovieName;
                document.getElementById('summaryCinema').textContent = selectedCinemaName;
                
                // Format date
                const dateObj = new Date(selectedDate);
                const dayNames = ['Chủ Nhật', 'Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7'];
                const formattedDate = dayNames[dateObj.getDay()] + ', ' + 
                                     dateObj.getDate() + '/' + 
                                     (dateObj.getMonth() + 1) + '/' + 
                                     dateObj.getFullYear();
                
                document.getElementById('summaryDate').textContent = formattedDate;
                document.getElementById('summaryTime').textContent = selectedTime;
            }
        }
        
        // Initialize function
        function initializePage() {
            console.log('Initializing page...');
            
            // Generate dates
            generateDates();
            console.log('Dates generated');
            
            // Add click listeners to movie cards
            document.querySelectorAll('.movie-card').forEach(card => {
                card.addEventListener('click', function() {
                    selectMovie(this);
                });
            });
            console.log('Movie cards initialized:', document.querySelectorAll('.movie-card').length);
            
            // Add click listeners to cinema chips
            document.querySelectorAll('.cinema-chip').forEach(chip => {
                chip.addEventListener('click', function() {
                    selectCinema(this);
                });
            });
            console.log('Cinema chips initialized:', document.querySelectorAll('.cinema-chip').length);
        }
        
        // Initialize Event Listeners
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', initializePage);
        } else {
            // DOM is already ready
            initializePage();
        }
        
        // Add event delegation for dynamically created showtime buttons
        document.addEventListener('click', function(e) {
            if (e.target.closest('.showtime-btn')) {
                const btn = e.target.closest('.showtime-btn');
                if (!btn.classList.contains('sold-out')) {
                    selectShowtime(btn);
                }
            }
        });
    </script>
</body>
</html>

