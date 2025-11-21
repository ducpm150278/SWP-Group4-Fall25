<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@page import="entity.Movie" %>
        <%@page import="entity.Review" %>
            <%@page import="java.util.List" %>
                <%@page import="java.time.format.DateTimeFormatter" %>
                    <!DOCTYPE html>
                    <html lang="vi">

                    <head>
                        <!-- ========== META TAGS ========== -->
                        <meta charset="UTF-8">
                        <meta name="viewport" content="width=device-width, initial-scale=1.0">
                        <!-- Dynamic title with movie name -->
                        <title>
                            <%= ((Movie) request.getAttribute("movie")).getTitle() %> - Cinema Booking
                        </title>

                        <!-- ========== EXTERNAL STYLESHEETS ========== -->
                        <!-- Bootstrap 5.3.3 - Framework CSS -->
                        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
                            rel="stylesheet">
                        <!-- Font Awesome 6.0.0 - Icon library -->
                        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css"
                            rel="stylesheet">
                        <!-- Custom CSS file cho trang movie detail -->
                        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/guest-movie-detail.css">
                    </head>

                    <body>
                        <% //==========LẤY THÔNG TIN TỪ SESSION VÀ REQUEST==========
                        // Kiểm tra user đã đăng nhập chưa
                            Object userObj=session.getAttribute("user"); 
                            boolean isLoggedIn=(userObj !=null); 
                            // Lấy thông tin chi tiết phim từ request attribute 
                            Movie movie=(Movie)request.getAttribute("movie"); 
                            // Lấy danh sách reviews của phim 
                            List<Review> reviews = (List<Review>) request.getAttribute("reviews");

                                // Lấy rating trung bình và tổng số reviews
                                Double averageRating = (Double) request.getAttribute("averageRating");
                                Integer totalReviews = (Integer) request.getAttribute("totalReviews");
                                %>

                                <!-- ========== INCLUDE NAVBAR COMPONENT ========== -->
                                <jsp:include page="/components/navbar.jsp" />

                                <!-- ========== MAIN CONTAINER ========== -->
                                <div class="main-container">
                                    <!-- ========== MOVIE DETAIL CONTAINER ========== -->
                                    <div class="movie-detail-container">
                                        <div class="movie-hero">
                                            <!-- ========== POSTER SECTION ========== -->
                                            <!-- Hiển thị poster lớn của phim -->
                                            <div class="poster-section">
                                                <img src="<%= movie.getPosterURL() != null ? movie.getPosterURL() : "https://via.placeholder.com/400x600?text=No+Image" %>"
                                                alt="<%= movie.getTitle() %>" class="movie-poster-large">
                                            </div>

                                            <!-- ========== INFO SECTION ========== -->
                                            <!-- Thông tin chính của phim -->
                                            <div class="info-section">
                                                <!-- Tiêu đề phim -->
                                                <h1 class="movie-title-large">
                                                    <%= movie.getTitle() %>
                                                </h1>

                                                <!-- ========== MOVIE META ROW ========== -->
                                                <!-- Hàng các badge hiển thị thông tin ngắn gọn -->
                                                <div class="movie-meta-row">
                                                    <!-- Badge: Thời lượng -->
                                                    <div class="meta-badge">
                                                        <i class="fas fa-clock"></i>
                                                        <%= movie.getDuration() %> phút
                                                    </div>

                                                    <!-- Badge: Thể loại -->
                                                    <div class="meta-badge">
                                                        <i class="fas fa-tags"></i>
                                                        <%= movie.getGenre() %>
                                                    </div>

                                                    <!-- Badge: Ngày phát hành -->
                                                    <div class="meta-badge">
                                                        <i class="fas fa-calendar"></i>
                                                        <%= movie.getReleasedDate() %>
                                                    </div>

                                                    <!-- Badge: Rating (chỉ hiển thị nếu có đánh giá) -->
                                                    <% if (averageRating !=null && averageRating> 0) { %>
                                                        <div class="meta-badge">
                                                            <i class="fas fa-star"></i>
                                                            <%= String.format("%.1f", averageRating) %>/5
                                                        </div>
                                                        <% } %>

                                                            <!-- ========== STATUS BADGE ========== -->
                                                            <% // Xử lý trạng thái phim (Active/Showing hoặc Upcoming)
                                                                boolean isMovieShowing="Active"
                                                                .equalsIgnoreCase(movie.getStatus()) || "Showing"
                                                                .equalsIgnoreCase(movie.getStatus()); String
                                                                movieStatusClass=isMovieShowing ? "status-showing"
                                                                : "status-upcoming" ; String
                                                                movieStatusText=isMovieShowing ? "Đang Chiếu"
                                                                : "Sắp Chiếu" ; %>
                                                                <div class="movie-status-badge <%= movieStatusClass %>">
                                                                    <%= movieStatusText %>
                                                                </div>
                                                </div>

                                                <!-- ========== MOVIE DESCRIPTION ========== -->
                                                <!-- Mô tả chi tiết của phim -->
                                                <p class="movie-description-text">
                                                    <%= movie.getSummary() !=null ? movie.getSummary() : "Chưa có mô tả"
                                                        %>
                                                </p>

                                                <!-- ========== ACTION BUTTONS ========== -->
                                                <!-- Nút hành động: Đặt vé hoặc Đăng nhập -->
                                                <div class="action-buttons">
                                                    <% if (isLoggedIn) { %>
                                                        <!-- User đã đăng nhập -> Hiển thị nút đặt vé -->
                                                        <a href="${pageContext.request.contextPath}/booking/select-screening"
                                                            class="btn-book">
                                                            <i class="fas fa-ticket-alt"></i> Đặt Vé Ngay
                                                        </a>
                                                        <% } else { %>
                                                            <!-- User chưa đăng nhập -> Hiển thị nút đăng nhập -->
                                                            <a href="${pageContext.request.contextPath}/auth/login"
                                                                class="btn-book">
                                                                <i class="fas fa-sign-in-alt"></i> Đăng Nhập Để Đặt Vé
                                                            </a>
                                                            <% } %>

                                                                <!-- Nút quay lại danh sách phim -->
                                                                <a href="${pageContext.request.contextPath}/guest-movies"
                                                                    class="btn-back">
                                                                    <i class="fas fa-arrow-left"></i> Quay Lại
                                                                </a>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- ========== DETAILS SECTION ========== -->
                                    <!-- Thông tin chi tiết đầy đủ về phim -->
                                    <div class="details-section">
                                        <h2 class="section-title">
                                            <i class="fas fa-info-circle"></i>
                                            Thông Tin Chi Tiết
                                        </h2>

                                        <!-- Đạo diễn -->
                                        <div class="detail-row">
                                            <div class="detail-label">Đạo diễn:</div>
                                            <div class="detail-value">
                                                <%= movie.getDirector() !=null ? movie.getDirector() : "Đang cập nhật"
                                                    %>
                                            </div>
                                        </div>

                                        <!-- Diễn viên -->
                                        <div class="detail-row">
                                            <div class="detail-label">Diễn viên:</div>
                                            <div class="detail-value">
                                                <%= movie.getCast() !=null ? movie.getCast() : "Đang cập nhật" %>
                                            </div>
                                        </div>

                                        <!-- Thể loại -->
                                        <div class="detail-row">
                                            <div class="detail-label">Thể loại:</div>
                                            <div class="detail-value">
                                                <%= movie.getGenre() %>
                                            </div>
                                        </div>

                                        <!-- Thời lượng -->
                                        <div class="detail-row">
                                            <div class="detail-label">Thời lượng:</div>
                                            <div class="detail-value">
                                                <%= movie.getDuration() %> phút
                                            </div>
                                        </div>

                                        <!-- Ngày phát hành -->
                                        <div class="detail-row">
                                            <div class="detail-label">Ngày phát hành:</div>
                                            <div class="detail-value">
                                                <%= movie.getReleasedDate() %>
                                            </div>
                                        </div>

                                        <!-- Ngôn ngữ -->
                                        <div class="detail-row">
                                            <div class="detail-label">Ngôn ngữ:</div>
                                            <div class="detail-value">
                                                <%= movie.getLanguageName() !=null ? movie.getLanguageName()
                                                    : "Đang cập nhật" %>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- ========== REVIEWS SECTION ========== -->
                                    <!-- Hiển thị đánh giá từ khán giả -->
                                    <div class="reviews-section">
                                        <h2 class="section-title">
                                            <i class="fas fa-comments"></i>
                                            Đánh Giá Từ Khán Giả
                                            <!-- Hiển thị tổng số review nếu có -->
                                            <% if (totalReviews !=null && totalReviews> 0) { %>
                                                <span style="color: #8b92a7; font-size: 1rem; font-weight: 400;">
                                                    (<%= totalReviews %> đánh giá)
                                                </span>
                                                <% } %>
                                        </h2>

                                        <!-- ========== DANH SÁCH REVIEWS ========== -->
                                        <% if (reviews !=null && !reviews.isEmpty()) { 
                                            // Lặp qua từng review 
                                            for(Review review : reviews) { %>
                                            <div class="review-card">
                                                <!-- Review header: tên user và rating -->
                                                <div class="review-header">
                                                    <span class="reviewer-name">
                                                        <i class="fas fa-user-circle"></i>
                                                        <%= review.getUserName() !=null ? review.getUserName()
                                                            : "Khách hàng" %>
                                                    </span>

                                                    <!-- Rating stars (5 sao) -->
                                                    <div class="review-rating">
                                                        <% for (int i=1; i <=5; i++) { %>
                                                            <!-- Sao đầy nếu i <= rating, sao mờ nếu không -->
                                                            <i class="fas fa-star <%= i <= review.getRating() ? "" : "opacity-25" %>"></i>
                                                            <% } %>
                                                    </div>
                                                </div>
                                                <!-- Nội dung comment -->
                                                <p class="review-text">
                                                    <%= review.getComment() %>
                                                </p>
                                            </div>
                                            <% } } else { %>
                                                <!-- ========== EMPTY STATE - Không có review ========== -->
                                                <div class="empty-reviews">
                                                    <i class="fas fa-comments"></i>
                                                    <p>Chưa có đánh giá nào cho phim này</p>
                                                </div>
                                                <% } %>
                                    </div>
                                </div>

                                <!-- ========== JAVASCRIPT LIBRARIES ========== -->
                                <script
                                    src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
                    </body>

                    </html>