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
    <title>Chọn Lịch Chiếu - Cinema Booking</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/booking.css" rel="stylesheet">
    <style>
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        
        .booking-container {
            max-width: 900px;
            margin: 50px auto;
            padding: 30px;
            background: white;
            border-radius: 15px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
        }
        
        .booking-header {
            text-align: center;
            margin-bottom: 40px;
        }
        
        .booking-header h2 {
            color: #667eea;
            font-weight: 700;
        }
        
        .booking-step {
            display: flex;
            justify-content: space-around;
            margin-bottom: 40px;
        }
        
        .step-item {
            text-align: center;
            flex: 1;
        }
        
        .step-number {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: #e0e0e0;
            color: #666;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            margin-bottom: 10px;
        }
        
        .step-item.active .step-number {
            background: #667eea;
            color: white;
        }
        
        .form-label {
            font-weight: 600;
            color: #333;
            margin-bottom: 8px;
        }
        
        .form-select, .form-control {
            border-radius: 8px;
            border: 2px solid #e0e0e0;
            padding: 12px;
        }
        
        .form-select:focus, .form-control:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 0.2rem rgba(102, 126, 234, 0.25);
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border: none;
            padding: 12px 40px;
            border-radius: 25px;
            font-weight: 600;
            transition: transform 0.3s;
        }
        
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 20px rgba(102, 126, 234, 0.4);
        }
        
        .alert {
            border-radius: 10px;
        }
    </style>
</head>
<body>
    <div class="booking-container">
        <div class="booking-header">
            <h2><i class="fas fa-ticket-alt"></i> Đặt Vé Xem Phim</h2>
            <p class="text-muted">Chọn rạp, phim, ngày và giờ chiếu</p>
        </div>
        
        <!-- Booking Steps -->
        <div class="booking-step">
            <div class="step-item active">
                <div class="step-number">1</div>
                <div class="step-label">Chọn Lịch</div>
            </div>
            <div class="step-item">
                <div class="step-number">2</div>
                <div class="step-label">Chọn Ghế</div>
            </div>
            <div class="step-item">
                <div class="step-number">3</div>
                <div class="step-label">Đồ Ăn</div>
            </div>
            <div class="step-item">
                <div class="step-number">4</div>
                <div class="step-label">Thanh Toán</div>
            </div>
        </div>
        
        <!-- Alert Messages -->
        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-danger" role="alert">
                <i class="fas fa-exclamation-circle"></i> <%= request.getAttribute("error") %>
            </div>
        <% } %>
        
        <% if (request.getAttribute("success") != null) { %>
            <div class="alert alert-success" role="alert">
                <i class="fas fa-check-circle"></i> <%= request.getAttribute("success") %>
            </div>
        <% } %>
        
        <!-- Screening Selection Form -->
        <form method="post" action="${pageContext.request.contextPath}/booking/select-screening" id="screeningForm">
            <div class="row mb-4">
                <div class="col-md-6">
                    <label for="cinemaSelect" class="form-label">
                        <i class="fas fa-building"></i> Chọn Rạp Chiếu
                    </label>
                    <select class="form-select" id="cinemaSelect" name="cinemaID" required>
                        <option value="">-- Chọn rạp --</option>
                        <%
                            List<Cinema> cinemas = (List<Cinema>) request.getAttribute("cinemas");
                            if (cinemas != null) {
                                for (Cinema cinema : cinemas) {
                        %>
                            <option value="<%= cinema.getCinemaID() %>"><%= cinema.getCinemaName() %></option>
                        <%
                                }
                            }
                        %>
                    </select>
                </div>
                
                <div class="col-md-6">
                    <label for="movieSelect" class="form-label">
                        <i class="fas fa-film"></i> Chọn Phim
                    </label>
                    <select class="form-select" id="movieSelect" name="movieID" required>
                        <option value="">-- Chọn phim --</option>
                        <%
                            List<Movie> movies = (List<Movie>) request.getAttribute("movies");
                            if (movies != null) {
                                for (Movie movie : movies) {
                        %>
                            <option value="<%= movie.getMovieID() %>"><%= movie.getTitle() %> (<%= movie.getDuration() %> phút)</option>
                        <%
                                }
                            }
                        %>
                    </select>
                </div>
            </div>
            
            <div class="row mb-4">
                <div class="col-md-6">
                    <label for="dateSelect" class="form-label">
                        <i class="fas fa-calendar-alt"></i> Chọn Ngày
                    </label>
                    <input type="date" class="form-control" id="dateSelect" name="date" required>
                </div>
                
                <div class="col-md-6">
                    <label for="screeningSelect" class="form-label">
                        <i class="fas fa-clock"></i> Chọn Giờ Chiếu
                    </label>
                    <select class="form-select" id="screeningSelect" name="screeningID" required>
                        <option value="">-- Chọn giờ chiếu --</option>
                    </select>
                </div>
            </div>
            
            <div class="text-center mt-4">
                <button type="submit" class="btn btn-primary btn-lg">
                    <i class="fas fa-arrow-right"></i> Xác Nhận
                </button>
            </div>
        </form>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Set minimum date to today
        const today = new Date().toISOString().split('T')[0];
        document.getElementById('dateSelect').setAttribute('min', today);
        document.getElementById('dateSelect').value = today;
        
        // AJAX to load screenings based on selections
        const cinemaSelect = document.getElementById('cinemaSelect');
        const movieSelect = document.getElementById('movieSelect');
        const dateSelect = document.getElementById('dateSelect');
        const screeningSelect = document.getElementById('screeningSelect');
        
        function loadScreenings() {
            const cinemaID = cinemaSelect.value;
            const movieID = movieSelect.value;
            const date = dateSelect.value;
            
            if (!cinemaID || !movieID || !date) {
                screeningSelect.innerHTML = '<option value="">-- Chọn giờ chiếu --</option>';
                return;
            }
            
            // Show loading state
            screeningSelect.innerHTML = '<option value="">Đang tải...</option>';
            screeningSelect.disabled = true;
            
            // AJAX call to fetch screenings
            const url = '${pageContext.request.contextPath}/api/load-screenings?' + 
                        'cinemaID=' + encodeURIComponent(cinemaID) + 
                        '&movieID=' + encodeURIComponent(movieID) + 
                        '&date=' + encodeURIComponent(date) +
                        '&_=' + new Date().getTime(); // Cache buster
            
            fetch(url)
                .then(response => response.json())
                .then(data => {
                    screeningSelect.disabled = false;
                    
                    if (data.success && data.screenings && data.screenings.length > 0) {
                        let options = '<option value="">-- Chọn giờ chiếu --</option>';
                        
                        data.screenings.forEach(screening => {
                            const id = screening.screeningID || '';
                            const time = screening.startTime || '??:??';
                            const room = screening.roomName || 'Phòng không xác định';
                            const seats = screening.availableSeats !== undefined ? screening.availableSeats : 0;
                            
                            options += '<option value="' + id + '">' + time + ' - ' + room + ' (' + seats + ' ghế trống)</option>';
                        });
                        
                        screeningSelect.innerHTML = options;
                    } else {
                        const message = data.message || 'Không có suất chiếu';
                        screeningSelect.innerHTML = '<option value="">' + message + '</option>';
                    }
                })
                .catch(error => {
                    screeningSelect.disabled = false;
                    screeningSelect.innerHTML = '<option value="">Lỗi tải dữ liệu</option>';
                });
        }
        
        cinemaSelect.addEventListener('change', loadScreenings);
        movieSelect.addEventListener('change', loadScreenings);
        dateSelect.addEventListener('change', loadScreenings);
    </script>
</body>
</html>

