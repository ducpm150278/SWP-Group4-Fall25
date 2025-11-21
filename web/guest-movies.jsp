<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@page import="java.util.List" %>
        <%@page import="entity.Movie" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <!-- ========== META TAGS ========== -->
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Danh Sách Phim - Cinema Booking</title>

                <!-- ========== EXTERNAL STYLESHEETS ========== -->
                <!-- Bootstrap 5.3.3 - Framework CSS -->
                <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
                <!-- Font Awesome 6.0.0 - Icon library -->
                <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
                <!-- Custom CSS file cho trang movies listing -->
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/guest-movies.css">
            </head>

            <body>
                <%  //==========LẤY THÔNG TIN TỪ SESSION VÀ REQUEST==========
                    // Kiểm tra xem user đã đăng nhập chưa
                    Object userObj=session.getAttribute("user"); 
                    String userName=(String)session.getAttribute("userName"); 
                    boolean isLoggedIn=(userObj !=null); 
                    // Lấy danh sách phim từ request attribute (do servlet gửi về) 
                    List<Movie> movies = (List<Movie>)request.getAttribute("movies");
                %>

                        <!-- ========== INCLUDE NAVBAR COMPONENT ========== -->
                        <jsp:include page="/components/navbar.jsp" />

                        <!-- ========== HERO SECTION ========== -->
                        <!-- Banner giới thiệu trang danh sách phim -->
                        <div class="hero-section">
                            <h1>Danh Sách Phim</h1>
                            <p>Khám phá các bộ phim đang chiếu và sắp chiếu</p>
                        </div>

                        <!-- ========== MAIN CONTAINER ========== -->
                        <div class="main-container">
                            <!-- ========== FILTER SECTION ========== -->
                            <!-- Bộ lọc phim theo trạng thái (Tất cả/Đang chiếu/Sắp chiếu) -->
                            <div class="filter-section">
                                <h4>
                                    <i class="fas fa-filter"></i>
                                    Lọc Phim
                                </h4>
                                <div class="filter-chips">
                                    <!-- Chip "Tất Cả" - Mặc định active -->
                                    <div class="filter-chip active" onclick="filterMovies('all', this)">
                                        <i class="fas fa-film"></i> Tất Cả
                                    </div>
                                    <!-- Chip "Đang Chiếu" -->
                                    <div class="filter-chip" onclick="filterMovies('showing', this)">
                                        <i class="fas fa-play-circle"></i> Đang Chiếu
                                    </div>
                                    <!-- Chip "Sắp Chiếu" -->
                                    <div class="filter-chip" onclick="filterMovies('upcoming', this)">
                                        <i class="fas fa-clock"></i> Sắp Chiếu
                                    </div>
                                </div>
                            </div>

                            <!-- ========== MOVIES GRID ========== -->
                            <!-- Grid hiển thị danh sách các phim -->
                            <div class="movies-grid" id="moviesGrid">
                                <% if (movies !=null && !movies.isEmpty()) { // Lặp qua từng phim trong danh sách for
                                    (Movie movie : movies) { //==========XỬ LÝ TRẠNG THÁI PHIM==========// Hỗ trợ
                                    cả 'Active' (database mới) và 'Showing' (legacy) String
                                    movieStatus=movie.getStatus(); boolean isShowing="Active"
                                    .equalsIgnoreCase(movieStatus) || "Showing" .equalsIgnoreCase(movieStatus); // CSS
                                    class cho status badge String statusClass=isShowing ? "status-showing"
                                    : "status-upcoming" ; // Text hiển thị trên status badge String statusText=isShowing
                                    ? "Đang Chiếu" : "Sắp Chiếu" ; // Data attribute cho JavaScript filter String
                                    dataStatus=isShowing ? "Showing" : "Upcoming" ; %>
                                    <!-- ========== MOVIE CARD ========== -->
                                    <!-- Card click để xem chi tiết phim -->
                                    <div class="movie-card" data-status="<%= dataStatus %>"
                                        data-movie-id="<%= movie.getMovieID() %>"
                                        data-href="${pageContext.request.contextPath}/guest-movie-detail?id=<%= movie.getMovieID() %>"
                                        onclick="window.location.href=this.getAttribute('data-href');"
                                        style="cursor: pointer;">

                                        <!-- ========== MOVIE POSTER ========== -->
                                        <!-- Hiển thị poster phim với fallback nếu không có ảnh -->
                                        <img src="<%= movie.getPosterURL() != null ? movie.getPosterURL() : "
                                            https://via.placeholder.com/280x400?text=No+Image" %>"
                                        alt="<%= movie.getTitle() %>"
                                            class="movie-poster"
                                            data-movie-title="<%= movie.getTitle() %>"
                                                onerror="this.onerror=null;
                                                this.src='https://via.placeholder.com/280x400/1a1d24/e50914?text=' +
                                                encodeURIComponent(this.getAttribute('data-movie-title') || 'Movie');">

                                                <!-- ========== MOVIE INFO ========== -->
                                                <div class="movie-info">
                                                    <!-- Tiêu đề phim -->
                                                    <h3 class="movie-title">
                                                        <%= movie.getTitle() %>
                                                    </h3>

                                                    <!-- Thể loại phim -->
                                                    <div class="movie-genre">
                                                        <i class="fas fa-tags"></i>
                                                        <%= movie.getGenre() %>
                                                    </div>

                                                    <!-- Mô tả phim -->
                                                    <p class="movie-description">
                                                        <%= movie.getSummary() !=null ? movie.getSummary()
                                                            : "Chưa có mô tả" %>
                                                    </p>

                                                    <!-- ========== MOVIE META ========== -->
                                                    <!-- Thông tin thời lượng và trạng thái phim -->
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
                                    <% } } else { %>
                                        <!-- ========== EMPTY STATE ========== -->
                                        <!-- Hiển thị khi không có phim nào -->
                                        <div class="empty-state" style="grid-column: 1 / -1;">
                                            <i class="fas fa-film"></i>
                                            <p>Không có phim nào để hiển thị</p>
                                        </div>
                                        <% } %>
                            </div>
                        </div>

                        <!-- ========== JAVASCRIPT LIBRARIES ========== -->
                        <script
                            src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

                        <!-- ========== CUSTOM JAVASCRIPT ========== -->
                        <script>
                            // ========== FUNCTION: FILTER MOVIES ==========
                            /**
                             * Lọc phim theo trạng thái (all/showing/upcoming)
                             * @param {string} status - Trạng thái cần lọc
                             * @param {HTMLElement} element - Element của chip được click
                             */
                            function filterMovies(status, element) {
                                try {
                                    // Cập nhật active chip
                                    const allChips = document.querySelectorAll('.filter-chip');
                                    allChips.forEach(chip => {
                                        chip.classList.remove('active');
                                    });

                                    // Thêm class active vào chip được click
                                    if (element) {
                                        element.classList.add('active');
                                    }

                                    // Lọc các movie cards
                                    const movieCards = document.querySelectorAll('.movie-card');
                                    let visibleCount = 0;

                                    movieCards.forEach(card => {
                                        const movieStatus = card.dataset.status;
                                        let shouldShow = false;

                                        // Xác định card có nên hiển thị không
                                        if (status === 'all') {
                                            shouldShow = true;
                                        } else if (status === 'showing' && movieStatus === 'Showing') {
                                            shouldShow = true;
                                        } else if (status === 'upcoming' && movieStatus === 'Upcoming') {
                                            shouldShow = true;
                                        }

                                        // Hiển thị/ẩn card
                                        if (shouldShow) {
                                            card.style.display = 'block';
                                            visibleCount++;
                                        } else {
                                            card.style.display = 'none';
                                        }
                                    });

                                    // Hiển thị empty state nếu không có phim nào visible
                                    const emptyState = document.querySelector('.empty-state');
                                    if (emptyState) {
                                        emptyState.style.display = visibleCount === 0 ? 'block' : 'none';
                                    }

                                } catch (error) {
                                    console.error('Error filtering movies:', error);
                                }
                            }

                            // ========== PAGE INITIALIZATION ==========
                            document.addEventListener('DOMContentLoaded', function () {
                                console.log('Guest movies page loaded');

                                // Verify movie cards are clickable
                                const movieCards = document.querySelectorAll('.movie-card');
                                console.log('Found', movieCards.length, 'movie cards');

                                // Verify each card has correct data-href
                                movieCards.forEach((card, index) => {
                                    const href = card.getAttribute('data-href');
                                    console.log(`Card ${index + 1} data-href:`, href);

                                    // Add hover effect feedback
                                    card.addEventListener('mouseenter', function () {
                                        console.log('Hovering card:', href);
                                    });
                                });

                                // ========== IMAGE ERROR HANDLING ==========
                                // Handle image load errors - set fallback placeholder
                                const moviePosters = document.querySelectorAll('.movie-poster');
                                moviePosters.forEach(function (img) {
                                    img.addEventListener('error', function () {
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