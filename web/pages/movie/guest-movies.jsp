<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="com.cinema.entity.Movie"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Danh Sách Phim - Cinema Booking</title>
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
        
        /* Hero Section */
        .hero-section {
            background: linear-gradient(135deg, #e50914 0%, #b20710 100%);
            padding: 80px 40px;
            text-align: center;
            margin-bottom: 50px;
            position: relative;
            overflow: hidden;
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
            color: #fff;
            position: relative;
            z-index: 1;
            text-shadow: 
                0 0 20px rgba(229, 9, 20, 0.6),
                0 0 40px rgba(229, 9, 20, 0.4),
                0 5px 20px rgba(0, 0, 0, 0.5),
                0 10px 40px rgba(0, 0, 0, 0.3);
        }
        
        .hero-section p {
            font-size: 1.4rem;
            opacity: 0.95;
            color: #fff;
            position: relative;
            z-index: 1;
            text-shadow: 
                0 2px 10px rgba(0, 0, 0, 0.5),
                0 4px 20px rgba(0, 0, 0, 0.3);
        }
        
        /* Main Container */
        .main-container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 0 20px 50px 20px;
        }
        
        /* Filter Section */
        .filter-section {
            background: #1a1d24;
            border-radius: 12px;
            padding: 25px;
            margin-bottom: 30px;
            border: 1px solid #2a2d35;
        }
        
        .filter-section h4 {
            color: #fff;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .filter-section h4 i {
            color: #e50914;
        }
        
        .filter-chips {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
        }
        
        .filter-chip {
            background: #2a2d35;
            border: 2px solid transparent;
            border-radius: 25px;
            padding: 10px 20px;
            cursor: pointer;
            transition: all 0.3s;
            color: #fff;
            font-weight: 500;
            user-select: none;
            -webkit-user-select: none;
            -moz-user-select: none;
            -ms-user-select: none;
        }
        
        .filter-chip:hover {
            background: #3a3d45;
            border-color: #e50914;
            transform: translateY(-2px);
        }
        
        .filter-chip.active {
            background: #e50914;
            border-color: #e50914;
        }
        
        .filter-chip:active {
            transform: translateY(0);
        }
        
        /* Movies Grid */
        .movies-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 25px;
        }
        
        .movie-card {
            background: #1a1d24;
            border-radius: 12px;
            overflow: hidden;
            transition: all 0.3s ease;
            border: 1px solid #2a2d35;
            cursor: pointer !important;
            color: #fff;
            display: flex;
            flex-direction: column;
            position: relative;
            user-select: none;
            height: 100%;
        }
        
        .movie-card:hover {
            transform: translateY(-8px);
            box-shadow: 0 20px 60px rgba(229, 9, 20, 0.3);
            border-color: #e50914;
        }
        
        .movie-card:active {
            transform: translateY(-4px);
        }
        
        .movie-poster {
            width: 100%;
            height: 400px;
            object-fit: cover;
            transition: all 0.3s ease;
            display: block;
            user-select: none;
        }
        
        .movie-card:hover .movie-poster {
            transform: scale(1.05);
        }
        
        .movie-info {
            padding: 20px;
            display: flex;
            flex-direction: column;
            flex-grow: 1;
        }
        
        .movie-title {
            font-size: 1.3rem;
            font-weight: 700;
            color: #fff;
            margin-bottom: 10px;
            line-height: 1.3;
            min-height: 3.9rem;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        
        .movie-genre {
            color: #e50914;
            font-weight: 600;
            margin-bottom: 10px;
            font-size: 0.9rem;
            display: flex;
            align-items: center;
            gap: 5px;
            min-height: 1.5rem;
        }
        
        .movie-description {
            color: #8b92a7;
            font-size: 0.9rem;
            line-height: 1.6;
            margin-bottom: 15px;
            display: -webkit-box;
            -webkit-line-clamp: 4;
            line-clamp: 4;
            -webkit-box-orient: vertical;
            overflow: hidden;
            text-overflow: ellipsis;
            flex-grow: 1;
            min-height: 6.4rem;
        }
        
        .movie-meta {
            display: flex;
            justify-content: space-between;
            align-items: center;
            color: #8b92a7;
            font-size: 0.85rem;
            padding-top: 15px;
            border-top: 1px solid #2a2d35;
            margin-top: auto;
        }
        
        .movie-meta i {
            margin-right: 5px;
        }
        
        .movie-status {
            padding: 4px 12px;
            border-radius: 6px;
            font-size: 0.75rem;
            font-weight: 600;
        }
        
        .status-showing {
            background: rgba(46, 160, 67, 0.2);
            color: #3fb950;
        }
        
        .status-upcoming {
            background: rgba(255, 149, 0, 0.2);
            color: #ff9500;
        }
        
        /* Empty State */
        .empty-state {
            text-align: center;
            padding: 80px 20px;
            color: #8b92a7;
        }
        
        .empty-state i {
            font-size: 80px;
            margin-bottom: 20px;
            opacity: 0.3;
        }
        
        .empty-state p {
            font-size: 1.2rem;
        }
        
        /* Responsive */
        @media (max-width: 768px) {
            .hero-section h1 {
                font-size: 2rem;
            }
            
            .hero-section p {
                font-size: 1rem;
            }
            
            .movies-grid {
                grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
                gap: 15px;
            }
        }
        
        @media (max-width: 480px) {
            .hero-section {
                padding: 40px 20px;
            }
            
            .movies-grid {
                grid-template-columns: 1fr;
            }
        }
        
        /* Hide Scrollbar */
        ::-webkit-scrollbar {
            display: none;
        }
        
        /* Hide scrollbar for IE, Edge and Firefox */
        html, body {
            -ms-overflow-style: none;  /* IE and Edge */
            scrollbar-width: none;  /* Firefox */
        }
    </style>
</head>
<body>
    <%
        // Get user information from session
        Object userObj = session.getAttribute("user");
        String userName = (String) session.getAttribute("userName");
        boolean isLoggedIn = (userObj != null);
        
        // Get movies list
        List<Movie> movies = (List<Movie>) request.getAttribute("movies");
    %>
    
    <!-- Include Navbar -->
    <jsp:include page="/components/navbar.jsp" />
    
    <!-- Hero Section -->
    <div class="hero-section">
        <h1>Danh Sách Phim</h1>
        <p>Khám phá các bộ phim đang chiếu và sắp chiếu</p>
    </div>
    
    <!-- Main Container -->
    <div class="main-container">
        <!-- Filter Section -->
        <div class="filter-section">
            <h4>
                <i class="fas fa-filter"></i>
                Lọc Phim
            </h4>
            <div class="filter-chips">
                <div class="filter-chip active" onclick="filterMovies('all', this)">
                    <i class="fas fa-film"></i> Tất Cả
                </div>
                <div class="filter-chip" onclick="filterMovies('showing', this)">
                    <i class="fas fa-play-circle"></i> Đang Chiếu
                </div>
                <div class="filter-chip" onclick="filterMovies('upcoming', this)">
                    <i class="fas fa-clock"></i> Sắp Chiếu
                </div>
            </div>
        </div>
        
        <!-- Movies Grid -->
        <div class="movies-grid" id="moviesGrid">
            <% if (movies != null && !movies.isEmpty()) { 
                for (Movie movie : movies) { 
                    // Handle both 'Active' (database) and 'Showing' (legacy) status values
                    String movieStatus = movie.getStatus();
                    boolean isShowing = "Active".equalsIgnoreCase(movieStatus) || "Showing".equalsIgnoreCase(movieStatus);
                    String statusClass = isShowing ? "status-showing" : "status-upcoming";
                    String statusText = isShowing ? "Đang Chiếu" : "Sắp Chiếu";
                    String dataStatus = isShowing ? "Showing" : "Upcoming"; // For filter compatibility
            %>
                <div class="movie-card" 
                     data-status="<%= dataStatus %>"
                     data-movie-id="<%= movie.getMovieID() %>"
                     data-href="${pageContext.request.contextPath}/guest-movie-detail?id=<%= movie.getMovieID() %>"
                     onclick="window.location.href=this.getAttribute('data-href');"
                     style="cursor: pointer;">
                    <img src="<%= movie.getPosterURL() != null ? movie.getPosterURL() : "https://via.placeholder.com/280x400?text=No+Image" %>" 
                         alt="<%= movie.getTitle() %>" 
                         class="movie-poster"
                         data-movie-title="<%= movie.getTitle() %>"
                         onerror="this.onerror=null; this.src='https://via.placeholder.com/280x400/1a1d24/e50914?text=' + encodeURIComponent(this.getAttribute('data-movie-title') || 'Movie');">
                    <div class="movie-info">
                        <h3 class="movie-title"><%= movie.getTitle() %></h3>
                        <div class="movie-genre">
                            <i class="fas fa-tags"></i>
                            <%= movie.getGenre() %>
                        </div>
                        <p class="movie-description">
                            <%= movie.getSummary() != null ? movie.getSummary() : "Chưa có mô tả" %>
                        </p>
                        <div class="movie-meta">
                            <span>
                                <i class="fas fa-clock"></i>
                                <%= movie.getDuration() %> phút
                            </span>
                            <span class="movie-status <%= statusClass %>">
                                <%= statusText %>
                            </span>
                        </div>
                    </div>
                </div>
            <% 
                }
            } else { 
            %>
                <div class="empty-state" style="grid-column: 1 / -1;">
                    <i class="fas fa-film"></i>
                    <p>Không có phim nào để hiển thị</p>
                </div>
            <% } %>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Filter movies function
        function filterMovies(status, element) {
            try {
                // Update active chip
                const allChips = document.querySelectorAll('.filter-chip');
                allChips.forEach(chip => {
                    chip.classList.remove('active');
                });
                
                // Add active class to clicked element
                if (element) {
                    element.classList.add('active');
                }
                
                // Filter movies
                const movieCards = document.querySelectorAll('.movie-card');
                let visibleCount = 0;
                
                movieCards.forEach(card => {
                    const movieStatus = card.dataset.status;
                    let shouldShow = false;
                    
                    if (status === 'all') {
                        shouldShow = true;
                    } else if (status === 'showing' && movieStatus === 'Showing') {
                        shouldShow = true;
                    } else if (status === 'upcoming' && movieStatus === 'Upcoming') {
                        shouldShow = true;
                    }
                    
                    if (shouldShow) {
                        card.style.display = 'block';
                        visibleCount++;
                    } else {
                        card.style.display = 'none';
                    }
                });
                
                // Show empty state if no movies visible
                const emptyState = document.querySelector('.empty-state');
                if (emptyState) {
                    emptyState.style.display = visibleCount === 0 ? 'block' : 'none';
                }
                
            } catch (error) {
                console.error('Error filtering movies:', error);
            }
        }
        
        // Initialize page
        document.addEventListener('DOMContentLoaded', function() {
            console.log('Guest movies page loaded');
            
            // Verify movie cards are clickable
            const movieCards = document.querySelectorAll('.movie-card');
            console.log('Found', movieCards.length, 'movie cards');
            
            // Verify each card has correct data-href
            movieCards.forEach((card, index) => {
                const href = card.getAttribute('data-href');
                console.log(`Card ${index + 1} data-href:`, href);
                
                // Add hover effect feedback
                card.addEventListener('mouseenter', function() {
                    console.log('Hovering card:', href);
                });
            });
            
            // Handle image load errors - set fallback placeholder
            const moviePosters = document.querySelectorAll('.movie-poster');
            moviePosters.forEach(function(img) {
                img.addEventListener('error', function() {
                    // If image fails to load, set a placeholder
                    if (!this.src.includes('placeholder')) {
                        const movieTitle = this.alt || 'Movie';
                        this.src = 'https://via.placeholder.com/280x400/1a1d24/e50914?text=' + encodeURIComponent(movieTitle);
                    }
                });
            });
        });
    </script>
</body>
</html>
