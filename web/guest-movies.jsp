<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="entity.Movie"%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Danh sách phim - Cinema Management</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/modern-theme.css" rel="stylesheet">
    <style>

        * {
            box-sizing: border-box;
        }

        body {
            background: #334457 !important;
            min-height: 100vh;
            font-family: 'Inter', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
            color: #f7efe7;
            overflow-x: hidden;
        }

        /* Enhanced Hero Section */
        .hero-section {
            background: linear-gradient(135deg, #334457 0%, #4a5a6b 50%, #2a3744 100%);
            border-radius: 0;
            padding: 60px 40px 80px 40px;
            margin: 0;
            margin-bottom: 50px;
            color: #f7efe7;
            text-align: center;
            position: relative;
            overflow: hidden;
            box-shadow: 0 4px 20px rgba(0,0,0,0.3);
        }

        .hero-section::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(45deg, transparent 30%, rgba(255, 255, 255, 0.1) 50%, transparent 70%);
            animation: shimmer 3s infinite;
        }

        @keyframes shimmer {
            0% { transform: translateX(-100%); }
            100% { transform: translateX(100%); }
        }

        .hero-section h1 {
            font-size: 3.5rem;
            font-weight: 800;
            margin-bottom: 20px;
            text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
            animation: fadeInUp 1s ease-out;
            color: #f7efe7;
            position: relative;
            z-index: 1;
        }

        .hero-section p {
            font-size: 1.3rem;
            opacity: 0.95;
            animation: fadeInUp 1s ease-out 0.2s both;
            color: #f7efe7;
            position: relative;
            z-index: 1;
            margin-bottom: 0;
        }

        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* Enhanced Search Section */
        .search-section {
            background: rgba(44, 62, 80, 0.9);
            border-radius: 20px;
            padding: 30px;
            margin-bottom: 40px;
            box-shadow: 0 8px 24px rgba(0,0,0,0.3);
            border: 1px solid rgba(255, 255, 255, 0.1);
            transition: all 0.3s ease;
        }

        .search-section:hover {
            transform: translateY(-2px);
            box-shadow: 0 12px 40px rgba(0,0,0,0.4);
        }

        .search-input {
            border: 2px solid rgba(247, 239, 231, 0.2);
            border-radius: 12px;
            padding: 16px 20px;
            font-size: 1.1rem;
            transition: all 0.3s ease;
            background: rgba(44, 62, 80, 0.6);
            color: #f7efe7;
            font-family: 'Inter', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        .search-input:focus {
            border-color: #5cbe8f;
            box-shadow: 0 0 0 4px rgba(92, 190, 143, 0.25), 0 4px 12px rgba(92, 190, 143, 0.2);
            background: rgba(44, 62, 80, 0.9);
            outline: none;
            color: #f7efe7;
        }
        
        .search-input::placeholder {
            color: rgba(247, 239, 231, 0.6);
        }

        .btn-search {
            background: linear-gradient(135deg, #5cbe8f 0%, #4a9b7a 100%);
            border: 2px solid #5cbe8f;
            border-radius: 12px;
            padding: 16px 30px;
            color: white;
            font-weight: 600;
            font-size: 1.1rem;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
        }

        .btn-search::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
            transition: left 0.5s;
        }

        .btn-search:hover::before {
            left: 100%;
        }

        .btn-search:hover {
            background: linear-gradient(135deg, #4a9b7a 0%, #3d8263 100%);
            border-color: #4a9b7a;
            transform: translateY(-2px) scale(1.02);
            box-shadow: 0 8px 24px rgba(92, 190, 143, 0.4);
            color: white;
        }

        /* Enhanced Filter Section */
        .filter-section {
            background: rgba(44, 62, 80, 0.9);
            border-radius: 20px;
            padding: 35px;
            margin-bottom: 40px;
            box-shadow: 0 16px 40px rgba(0,0,0,0.3);
            border: 1px solid rgba(255, 255, 255, 0.1);
        }

        .filter-section h5 {
            color: #f7efe7;
            font-weight: 700;
            margin-bottom: 25px;
        }

        .filter-btn {
            background: linear-gradient(135deg, #5cbe8f 0%, #4a9b7a 100%);
            border: 2px solid #5cbe8f;
            border-radius: 12px;
            padding: 12px 24px;
            color: white;
            font-weight: 600;
            margin: 8px;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            text-decoration: none;
            display: inline-block;
            position: relative;
            overflow: hidden;
        }

        .filter-btn::before {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            width: 0;
            height: 0;
            background: rgba(255, 255, 255, 0.2);
            border-radius: 50%;
            transform: translate(-50%, -50%);
            transition: width 0.6s, height 0.6s;
        }

        .filter-btn:hover::before {
            width: 300px;
            height: 300px;
        }

        .filter-btn:hover, .filter-btn.active {
            background: linear-gradient(135deg, #4a9b7a 0%, #3d8263 100%);
            border-color: #4a9b7a;
            transform: translateY(-2px) scale(1.02);
            box-shadow: 0 8px 24px rgba(92, 190, 143, 0.4);
            color: white;
        }

        /* Enhanced Movie Cards */
        .movie-card {
            background: rgba(44, 62, 80, 0.9);
            border-radius: 20px;
            overflow: hidden;
            box-shadow: 0 8px 24px rgba(0,0,0,0.3);
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            margin-bottom: 30px;
            position: relative;
            border: 1px solid rgba(255, 255, 255, 0.1);
        }

        .movie-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(135deg, rgba(92, 190, 143, 0.1) 0%, rgba(92, 190, 143, 0.05) 100%);
            opacity: 0;
            transition: all 0.3s ease;
            z-index: 1;
        }

        .movie-card:hover::before {
            opacity: 1;
        }

        .movie-card:hover {
            transform: translateY(-8px) scale(1.02);
            box-shadow: 0 16px 40px rgba(0,0,0,0.4);
            border-color: rgba(92, 190, 143, 0.5);
        }

        .movie-poster {
            width: 100%;
            height: 320px;
            object-fit: cover;
            transition: all 0.4s ease;
        }

        .movie-card:hover .movie-poster {
            transform: scale(1.05);
        }

        .movie-info {
            padding: 25px;
            position: relative;
            z-index: 2;
        }

        .movie-title {
            font-size: 1.4rem;
            font-weight: 700;
            color: #f7efe7;
            margin-bottom: 12px;
            line-height: 1.3;
        }

        .movie-genre {
            color: #5cbe8f;
            font-weight: 600;
            margin-bottom: 12px;
            font-size: 0.95rem;
        }

        .movie-genre i {
            margin-right: 6px;
        }

        .movie-summary {
            color: rgba(247, 239, 231, 0.8);
            font-size: 0.95rem;
            line-height: 1.6;
            margin-bottom: 20px;
            display: -webkit-box;
            -webkit-line-clamp: 3;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }

        .movie-meta {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        .movie-duration {
            color: rgba(247, 239, 231, 0.7);
            font-size: 0.9rem;
            font-weight: 500;
        }

        .movie-duration i {
            margin-right: 6px;
            color: #5cbe8f;
        }

        .movie-status {
            padding: 6px 14px;
            border-radius: 25px;
            font-size: 0.8rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .status-active {
            background: #5cbe8f;
            color: white;
            box-shadow: 0 2px 8px rgba(92, 190, 143, 0.3);
        }

        .status-upcoming {
            background: #f8b500;
            color: white;
            box-shadow: 0 2px 8px rgba(248, 181, 0, 0.3);
        }

        .btn-detail {
            background: linear-gradient(135deg, #5cbe8f 0%, #4a9b7a 100%);
            border: 2px solid #5cbe8f;
            border-radius: 12px;
            padding: 12px 24px;
            color: white;
            font-weight: 600;
            width: 100%;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            text-decoration: none;
            display: inline-block;
            text-align: center;
            position: relative;
            overflow: hidden;
        }

        .btn-detail::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
            transition: left 0.5s;
        }

        .btn-detail:hover::before {
            left: 100%;
        }

        .btn-detail:hover {
            background: linear-gradient(135deg, #4a9b7a 0%, #3d8263 100%);
            border-color: #4a9b7a;
            transform: translateY(-2px) scale(1.02);
            box-shadow: 0 8px 24px rgba(92, 190, 143, 0.4);
            color: white;
        }

        /* Enhanced No Movies State */
        .no-movies {
            text-align: center;
            padding: 80px 20px;
            color: #f7efe7;
            background: rgba(44, 62, 80, 0.6);
            border-radius: 20px;
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.1);
        }

        .no-movies i {
            font-size: 5rem;
            margin-bottom: 30px;
            opacity: 0.7;
            animation: bounce 2s infinite;
        }

        @keyframes bounce {
            0%, 20%, 50%, 80%, 100% { transform: translateY(0); }
            40% { transform: translateY(-10px); }
            60% { transform: translateY(-5px); }
        }

        .no-movies h3 {
            margin-bottom: 15px;
            font-size: 2rem;
            font-weight: 700;
        }

        .no-movies p {
            opacity: 0.9;
            font-size: 1.1rem;
            margin-bottom: 30px;
        }

        /* Loading Animation */
        .loading {
            display: inline-block;
            width: 20px;
            height: 20px;
            border: 3px solid rgba(255, 255, 255, 0.3);
            border-radius: 50%;
            border-top-color: white;
            animation: spin 1s ease-in-out infinite;
        }

        @keyframes spin {
            to { transform: rotate(360deg); }
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            .hero-section h1 {
                font-size: 2.5rem;
            }
            
            .hero-section p {
                font-size: 1.1rem;
            }
            
            .movie-card {
                margin-bottom: 20px;
            }
            
            .filter-btn {
                margin: 4px;
                padding: 10px 16px;
                font-size: 0.9rem;
            }
        }

        @media (max-width: 576px) {
            .hero-section {
                padding: 40px 20px;
            }
            
            .hero-section h1 {
                font-size: 2rem;
            }
            
            .search-section, .filter-section {
                padding: 20px;
            }
        }
    </style>
</head>
<body>
    <%
        // Check if user is logged in
        Object userObj = session.getAttribute("user");
        String userName = (String) session.getAttribute("userName");
        String userRole = (String) session.getAttribute("userRole");
        boolean isLoggedIn = (userObj != null);
        
        List<Movie> movies = (List<Movie>) request.getAttribute("movies");
        String status = (String) request.getAttribute("status");
        String keyword = (String) request.getAttribute("keyword");
        Integer currentPage = (Integer) request.getAttribute("currentPage");
        Integer totalPages = (Integer) request.getAttribute("totalPages");
    %>
    
    <!-- Include Reusable Navbar Component -->
    <jsp:include page="/components/navbar.jsp" />

    <!-- Hero Section (Full Width) -->
    <div class="hero-section">
        <div class="container">
            <h1><i class="fas fa-film"></i> Khám phá phim hay</h1>
            <p>Tìm kiếm và đặt vé cho những bộ phim tuyệt vời nhất</p>
        </div>
    </div>

    <div class="container">
        <!-- Search Section -->
        <div class="search-section">
            <form action="guest-movies" method="get" class="row g-3" id="searchForm">
                <div class="col-md-8">
                    <input type="text" name="keyword" id="searchInput" class="form-control search-input" 
                           placeholder="Tìm kiếm phim theo tên..." 
                           value="<%= keyword != null ? keyword : "" %>">
                </div>
                <div class="col-md-4">
                    <button type="submit" class="btn btn-search w-100">
                        <i class="fas fa-search"></i> Tìm kiếm
                    </button>
                </div>
            </form>
        </div>

        <!-- Filter Section -->
        <div class="filter-section">
            <h5 class="mb-3"><i class="fas fa-filter"></i> Lọc theo trạng thái</h5>
            <div class="d-flex flex-wrap">
                <a href="guest-movies" class="btn filter-btn <%= status == null ? "active" : "" %>">
                    <i class="fas fa-list"></i> Tất cả phim
                </a>
                <a href="guest-movies?status=Active" class="btn filter-btn <%= "Active".equals(status) ? "active" : "" %>">
                    <i class="fas fa-play"></i> Đang chiếu
                </a>
                <a href="guest-movies?status=Upcoming" class="btn filter-btn <%= "Upcoming".equals(status) ? "active" : "" %>">
                    <i class="fas fa-clock"></i> Sắp chiếu
                </a>
            </div>
        </div>

        <!-- Movies Grid -->
        <% if (movies != null && !movies.isEmpty()) { %>
            <div class="row">
                <% for (Movie movie : movies) { %>
                    <div class="col-lg-4 col-md-6">
                        <div class="movie-card">
                            <img src="<%= movie.getPosterURL() %>" alt="<%= movie.getTitle() %>" class="movie-poster">
                            <div class="movie-info">
                                <h5 class="movie-title"><%= movie.getTitle() %></h5>
                                <div class="movie-genre">
                                    <i class="fas fa-tags"></i> <%= movie.getGenre() %>
                                </div>
                                <p class="movie-summary"><%= movie.getSummary() %></p>
                                <div class="movie-meta">
                                    <span class="movie-duration">
                                        <i class="fas fa-clock"></i> <%= movie.getDuration() %> phút
                                    </span>
                                    <span class="movie-status status-<%= "Active".equals(movie.getStatus()) ? "active" : "upcoming" %>">
                                        <%= "Active".equals(movie.getStatus()) ? "Đang chiếu" : "Sắp chiếu" %>
                                    </span>
                                </div>
                                <a href="guest-movie-detail?movieID=<%= movie.getMovieID() %>" class="btn btn-detail">
                                    <i class="fas fa-eye"></i> Xem chi tiết
                                </a>
                            </div>
                        </div>
                    </div>
                <% } %>
            </div>
        <% } else { %>
            <div class="no-movies">
                <i class="fas fa-film"></i>
                <h3>Không tìm thấy phim nào</h3>
                <p>Hãy thử tìm kiếm với từ khóa khác hoặc chọn bộ lọc khác</p>
                <a href="guest-movies" class="btn btn-primary">
                    <i class="fas fa-refresh"></i> Xem tất cả phim
                </a>
            </div>
        <% } %>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    
    <script>
        // Real-time search functionality
        document.addEventListener('DOMContentLoaded', function() {
            const searchInput = document.getElementById('searchInput');
            const searchForm = document.getElementById('searchForm');
            let searchTimeout;
            
            // Add real-time search with debouncing
            searchInput.addEventListener('input', function() {
                clearTimeout(searchTimeout);
                
                // Show loading indicator
                const originalPlaceholder = searchInput.placeholder;
                searchInput.placeholder = 'Đang tìm kiếm...';
                
                searchTimeout = setTimeout(function() {
                    // Get current URL parameters
                    const urlParams = new URLSearchParams(window.location.search);
                    const currentStatus = urlParams.get('status');
                    
                    // Build new URL with search term
                    let newUrl = 'guest-movies?';
                    if (searchInput.value.trim() !== '') {
                        newUrl += 'keyword=' + encodeURIComponent(searchInput.value.trim());
                    }
                    if (currentStatus) {
                        newUrl += (searchInput.value.trim() !== '' ? '&' : '') + 'status=' + currentStatus;
                    }
                    
                    // Navigate to new URL
                    window.location.href = newUrl;
                }, 700); // Wait 500ms after user stops typing
            });
            
            // Handle form submission (for manual search button click)
            searchForm.addEventListener('submit', function(e) {
                e.preventDefault();
                clearTimeout(searchTimeout);
                
                const urlParams = new URLSearchParams(window.location.search);
                const currentStatus = urlParams.get('status');
                
                let newUrl = 'guest-movies?';
                if (searchInput.value.trim() !== '') {
                    newUrl += 'keyword=' + encodeURIComponent(searchInput.value.trim());
                }
                if (currentStatus) {
                    newUrl += (searchInput.value.trim() !== '' ? '&' : '') + 'status=' + currentStatus;
                }
                
                window.location.href = newUrl;
            });
            
            // Add visual feedback for search
            searchInput.addEventListener('focus', function() {
                this.style.borderColor = '#667eea';
                this.style.boxShadow = '0 0 0 0.2rem rgba(102, 126, 234, 0.25)';
            });
            
            searchInput.addEventListener('blur', function() {
                this.style.borderColor = '#e1e5e9';
                this.style.boxShadow = 'none';
            });
        });
    </script>
</body>
</html>

