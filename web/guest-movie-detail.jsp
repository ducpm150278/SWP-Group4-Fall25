<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="entity.Movie"%>
<%@page import="entity.Review"%>
<%@page import="java.util.List"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= ((Movie) request.getAttribute("movie")).getTitle() %> - Cinema Booking</title>
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
        
        /* Main Container */
        .main-container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 30px 20px;
        }
        
        /* Movie Detail Card */
        .movie-detail-container {
            background: #1a1d24;
            border-radius: 16px;
            overflow: hidden;
            border: 1px solid #2a2d35;
            margin-bottom: 30px;
        }
        
        .movie-hero {
            display: grid;
            grid-template-columns: 400px 1fr;
            gap: 40px;
            padding: 40px;
        }
        
        .poster-section {
            position: relative;
        }
        
        .movie-poster-large {
            width: 100%;
            border-radius: 12px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.5);
        }
        
        .info-section {
            display: flex;
            flex-direction: column;
            justify-content: center;
        }
        
        .movie-title-large {
            font-size: 2.5rem;
            font-weight: 800;
            color: #fff;
            margin-bottom: 20px;
            line-height: 1.2;
        }
        
        .movie-meta-row {
            display: flex;
            flex-wrap: wrap;
            gap: 15px;
            margin-bottom: 30px;
        }
        
        .meta-badge {
            background: #2a2d35;
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 0.9rem;
            display: flex;
            align-items: center;
            gap: 8px;
            border: 1px solid #3a3d45;
        }
        
        .meta-badge i {
            color: #e50914;
        }
        
        .movie-status-badge {
            padding: 8px 16px;
            border-radius: 20px;
            font-weight: 600;
            font-size: 0.9rem;
        }
        
        .status-showing {
            background: rgba(46, 160, 67, 0.2);
            color: #3fb950;
            border: 1px solid #2ea043;
        }
        
        .status-upcoming {
            background: rgba(255, 149, 0, 0.2);
            color: #ff9500;
            border: 1px solid #ff9500;
        }
        
        .movie-description-text {
            color: #8b92a7;
            line-height: 1.8;
            font-size: 1rem;
            margin-bottom: 30px;
        }
        
        .action-buttons {
            display: flex;
            gap: 15px;
        }
        
        .btn-book {
            background: linear-gradient(135deg, #e50914 0%, #b20710 100%);
            color: #fff;
            border: none;
            border-radius: 8px;
            padding: 14px 30px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            display: flex;
            align-items: center;
            gap: 10px;
            text-decoration: none;
        }
        
        .btn-book:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 30px rgba(229, 9, 20, 0.4);
            color: #fff;
        }
        
        .btn-back {
            background: #2a2d35;
            color: #fff;
            border: 1px solid #3a3d45;
            border-radius: 8px;
            padding: 14px 30px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            display: flex;
            align-items: center;
            gap: 10px;
            text-decoration: none;
        }
        
        .btn-back:hover {
            background: #3a3d45;
            transform: translateY(-2px);
            color: #fff;
        }
        
        /* Details Section */
        .details-section {
            background: #1a1d24;
            border-radius: 12px;
            padding: 30px;
            margin-bottom: 30px;
            border: 1px solid #2a2d35;
        }
        
        .section-title {
            font-size: 1.5rem;
            font-weight: 700;
            color: #fff;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .section-title i {
            color: #e50914;
        }
        
        .detail-row {
            display: flex;
            padding: 15px 0;
            border-bottom: 1px solid #2a2d35;
        }
        
        .detail-row:last-child {
            border-bottom: none;
        }
        
        .detail-label {
            font-weight: 600;
            color: #8b92a7;
            min-width: 150px;
        }
        
        .detail-value {
            color: #fff;
        }
        
        /* Reviews Section */
        .reviews-section {
            background: #1a1d24;
            border-radius: 12px;
            padding: 30px;
            border: 1px solid #2a2d35;
        }
        
        .review-card {
            background: #2a2d35;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 15px;
            border: 1px solid #3a3d45;
        }
        
        .review-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 10px;
        }
        
        .reviewer-name {
            font-weight: 600;
            color: #fff;
        }
        
        .review-rating {
            color: #ff9500;
            display: flex;
            gap: 3px;
        }
        
        .review-text {
            color: #8b92a7;
            line-height: 1.6;
        }
        
        .empty-reviews {
            text-align: center;
            padding: 40px;
            color: #8b92a7;
        }
        
        .empty-reviews i {
            font-size: 3rem;
            margin-bottom: 15px;
            opacity: 0.3;
        }
        
        /* Responsive */
        @media (max-width: 968px) {
            .movie-hero {
                grid-template-columns: 1fr;
                gap: 30px;
            }
            
            .poster-section {
                max-width: 400px;
                margin: 0 auto;
            }
        }
        
        @media (max-width: 768px) {
            .movie-title-large {
                font-size: 2rem;
            }
            
            .action-buttons {
                flex-direction: column;
            }
            
            .btn-book,
            .btn-back {
                width: 100%;
                justify-content: center;
            }
        }
    </style>
</head>
<body>
    <%
        // Check if user is logged in
        Object userObj = session.getAttribute("user");
        boolean isLoggedIn = (userObj != null);
        
        Movie movie = (Movie) request.getAttribute("movie");
        List<Review> reviews = (List<Review>) request.getAttribute("reviews");
        Double averageRating = (Double) request.getAttribute("averageRating");
        Integer totalReviews = (Integer) request.getAttribute("totalReviews");
    %>
    
    <!-- Include Navbar -->
    <jsp:include page="/components/navbar.jsp" />
    
    <div class="main-container">
        <!-- Movie Detail Container -->
        <div class="movie-detail-container">
            <div class="movie-hero">
                <!-- Poster Section -->
                <div class="poster-section">
                    <img src="<%= movie.getPosterURL() != null ? movie.getPosterURL() : "https://via.placeholder.com/400x600?text=No+Image" %>" 
                         alt="<%= movie.getTitle() %>" class="movie-poster-large">
                </div>
                
                <!-- Info Section -->
                <div class="info-section">
                    <h1 class="movie-title-large"><%= movie.getTitle() %></h1>
                    
                    <div class="movie-meta-row">
                        <div class="meta-badge">
                            <i class="fas fa-clock"></i>
                            <%= movie.getDuration() %> phút
                        </div>
                        <div class="meta-badge">
                            <i class="fas fa-tags"></i>
                            <%= movie.getGenre() %>
                        </div>
                        <div class="meta-badge">
                            <i class="fas fa-calendar"></i>
                            <%= movie.getReleasedDate() %>
                        </div>
                        <% if (averageRating != null && averageRating > 0) { %>
                            <div class="meta-badge">
                                <i class="fas fa-star"></i>
                                <%= String.format("%.1f", averageRating) %>/5
                            </div>
                        <% } %>
                        <% 
                            // Handle both 'Active' (database) and 'Showing' (legacy) status values
                            boolean isMovieShowing = "Active".equalsIgnoreCase(movie.getStatus()) || "Showing".equalsIgnoreCase(movie.getStatus());
                            String movieStatusClass = isMovieShowing ? "status-showing" : "status-upcoming";
                            String movieStatusText = isMovieShowing ? "Đang Chiếu" : "Sắp Chiếu";
                        %>
                        <div class="movie-status-badge <%= movieStatusClass %>">
                            <%= movieStatusText %>
                        </div>
                    </div>
                    
                    <p class="movie-description-text">
                        <%= movie.getSummary() != null ? movie.getSummary() : "Chưa có mô tả" %>
                    </p>
                    
                    <div class="action-buttons">
                        <% if (isLoggedIn) { %>
                            <a href="${pageContext.request.contextPath}/booking/select-screening" class="btn-book">
                                <i class="fas fa-ticket-alt"></i> Đặt Vé Ngay
                            </a>
                        <% } else { %>
                            <a href="${pageContext.request.contextPath}/auth/login" class="btn-book">
                                <i class="fas fa-sign-in-alt"></i> Đăng Nhập Để Đặt Vé
                            </a>
                        <% } %>
                        <a href="${pageContext.request.contextPath}/guest-movies" class="btn-back">
                            <i class="fas fa-arrow-left"></i> Quay Lại
                        </a>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Details Section -->
        <div class="details-section">
            <h2 class="section-title">
                <i class="fas fa-info-circle"></i>
                Thông Tin Chi Tiết
            </h2>
            <div class="detail-row">
                <div class="detail-label">Đạo diễn:</div>
                <div class="detail-value"><%= movie.getDirector() != null ? movie.getDirector() : "Đang cập nhật" %></div>
            </div>
            <div class="detail-row">
                <div class="detail-label">Diễn viên:</div>
                <div class="detail-value"><%= movie.getCast() != null ? movie.getCast() : "Đang cập nhật" %></div>
            </div>
            <div class="detail-row">
                <div class="detail-label">Thể loại:</div>
                <div class="detail-value"><%= movie.getGenre() %></div>
            </div>
            <div class="detail-row">
                <div class="detail-label">Thời lượng:</div>
                <div class="detail-value"><%= movie.getDuration() %> phút</div>
            </div>
            <div class="detail-row">
                <div class="detail-label">Ngày phát hành:</div>
                <div class="detail-value"><%= movie.getReleasedDate() %></div>
            </div>
            <div class="detail-row">
                <div class="detail-label">Ngôn ngữ:</div>
                <div class="detail-value"><%= movie.getLanguageName() != null ? movie.getLanguageName() : "Đang cập nhật" %></div>
            </div>
        </div>
        
        <!-- Reviews Section -->
        <div class="reviews-section">
            <h2 class="section-title">
                <i class="fas fa-comments"></i>
                Đánh Giá Từ Khán Giả
                <% if (totalReviews != null && totalReviews > 0) { %>
                    <span style="color: #8b92a7; font-size: 1rem; font-weight: 400;">
                        (<%= totalReviews %> đánh giá)
                    </span>
                <% } %>
            </h2>
            
            <% if (reviews != null && !reviews.isEmpty()) { 
                for (Review review : reviews) { %>
                    <div class="review-card">
                        <div class="review-header">
                            <span class="reviewer-name">
                                <i class="fas fa-user-circle"></i>
                                <%= review.getUserName() != null ? review.getUserName() : "Khách hàng" %>
                            </span>
                            <div class="review-rating">
                                <% for (int i = 1; i <= 5; i++) { %>
                                    <i class="fas fa-star <%= i <= review.getRating() ? "" : "opacity-25" %>"></i>
                                <% } %>
                            </div>
                        </div>
                        <p class="review-text"><%= review.getComment() %></p>
                    </div>
                <% } 
            } else { %>
                <div class="empty-reviews">
                    <i class="fas fa-comments"></i>
                    <p>Chưa có đánh giá nào cho phim này</p>
                </div>
            <% } %>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
