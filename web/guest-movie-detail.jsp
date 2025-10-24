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
    <title><%= ((Movie) request.getAttribute("movie")).getTitle() %> - Cinema Management</title>
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

        /* Enhanced Movie Detail Container */
        .movie-detail-container {
            background: rgba(44, 62, 80, 0.9);
            border-radius: 24px;
            overflow: hidden;
            box-shadow: 0 16px 40px rgba(0,0,0,0.4);
            margin: 30px 0;
            border: 1px solid rgba(255, 255, 255, 0.1);
            animation: fadeInUp 0.8s ease-out;
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

        /* Enhanced Poster Section */
        .movie-poster-section {
            position: relative;
            height: 600px;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
            background: none !important;
        }


        .movie-poster {
            max-width: 90%;
            max-height: 90%;
            border-radius: 20px;
            box-shadow: none;
            transition: all 0.4s ease;
            position: relative;
            z-index: 2;
        }

        .movie-poster:hover {
            transform: scale(1.05);
            box-shadow: none;
        }

        /* Enhanced Info Section */
        .movie-info-section {
            padding: 50px;
            position: relative;
            background: rgba(44, 62, 80, 0.5);
        }

        .movie-title {
            font-size: 3rem;
            font-weight: 800;
            color: #f7efe7;
            margin-bottom: 20px;
            line-height: 1.2;
        }

        .movie-meta {
            display: flex;
            flex-wrap: wrap;
            gap: 25px;
            margin-bottom: 40px;
        }

        .meta-item {
            display: flex;
            align-items: center;
            color: rgba(247, 239, 231, 0.9);
            font-size: 1.1rem;
            font-weight: 500;
            background: rgba(92, 190, 143, 0.15);
            padding: 8px 16px;
            border-radius: 25px;
            transition: all 0.3s ease;
            border: 1px solid rgba(92, 190, 143, 0.3);
        }

        .meta-item:hover {
            background: rgba(92, 190, 143, 0.25);
            transform: translateY(-2px);
            border-color: rgba(92, 190, 143, 0.5);
        }

        .meta-item i {
            color: #5cbe8f;
            margin-right: 10px;
            width: 20px;
            font-size: 1.2rem;
        }

        .meta-item:has(.movie-status) {
            background: transparent;
            border: none;
            padding: 0;
        }

        .movie-status {
            padding: 10px 20px;
            border-radius: 30px;
            font-size: 0.9rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            box-shadow: var(--shadow-light);
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

        /* Enhanced Description */
        .movie-description {
            font-size: 1.2rem;
            line-height: 1.8;
            color: rgba(247, 239, 231, 0.9);
            margin-bottom: 40px;
            background: rgba(44, 62, 80, 0.4);
            padding: 30px;
            border-radius: 16px;
            border-left: 4px solid #5cbe8f;
        }

        .movie-description h5 {
            color: #f7efe7;
            font-weight: 700;
            margin-bottom: 15px;
            font-size: 1.3rem;
        }

        .movie-description h5 i {
            margin-right: 10px;
            color: #5cbe8f;
        }

        /* Enhanced Details Section */
        .movie-details {
            background: rgba(44, 62, 80, 0.6);
            border-radius: 20px;
            padding: 40px;
            margin-bottom: 40px;
            border: 1px solid rgba(255, 255, 255, 0.1);
            box-shadow: 0 8px 24px rgba(0,0,0,0.3);
        }

        .movie-details h5 {
            color: #f7efe7;
            font-weight: 700;
            margin-bottom: 25px;
            font-size: 1.4rem;
        }

        .movie-details h5 i {
            margin-right: 10px;
            color: #5cbe8f;
        }

        .detail-row {
            display: flex;
            margin-bottom: 20px;
            padding-bottom: 20px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }

        .detail-row:last-child {
            border-bottom: none;
            margin-bottom: 0;
            padding-bottom: 0;
        }

        .detail-label {
            font-weight: 700;
            color: #5cbe8f;
            width: 180px;
            flex-shrink: 0;
            font-size: 1.1rem;
        }

        .detail-value {
            color: rgba(247, 239, 231, 0.9);
            flex: 1;
            font-size: 1.1rem;
        }

        /* Enhanced Trailer Section */
        .trailer-section {
            margin-bottom: 40px;
        }

        .trailer-section h5 {
            color: #f7efe7;
            font-weight: 700;
            margin-bottom: 20px;
            font-size: 1.4rem;
        }

        .trailer-section h5 i {
            margin-right: 10px;
            color: #5cbe8f;
        }

        .trailer-btn {
            background: linear-gradient(135deg, #5cbe8f 0%, #4a9b7a 100%);
            border: 2px solid #5cbe8f;
            border-radius: 15px;
            padding: 12px 24px;
            color: white;
            font-weight: 600;
            font-size: 1rem;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            text-decoration: none;
            display: inline-block;
            position: relative;
            overflow: hidden;
            box-shadow: 0 4px 12px rgba(92, 190, 143, 0.3);
        }

        .trailer-btn::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
            transition: left 0.5s;
        }

        .trailer-btn:hover::before {
            left: 100%;
        }

        .trailer-btn:hover {
            background: linear-gradient(135deg, #4a9b7a 0%, #3d8263 100%);
            border-color: #4a9b7a;
            transform: translateY(-2px) scale(1.02);
            box-shadow: 0 8px 24px rgba(92, 190, 143, 0.4);
            color: white;
        }

        .trailer-btn i {
            margin-right: 10px;
        }

        /* Enhanced Action Buttons */
        .action-buttons {
            display: flex;
            gap: 20px;
            flex-wrap: wrap;
            margin-top: 30px;
        }

        .btn-book {
            background: linear-gradient(135deg, #e74c3c 0%, #c0392b 100%);
            border: 2px solid #e74c3c;
            border-radius: 15px;
            padding: 18px 35px;
            color: white;
            font-weight: 700;
            font-size: 1.2rem;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            text-decoration: none;
            display: inline-block;
            position: relative;
            overflow: hidden;
            box-shadow: 0 4px 12px rgba(231, 76, 60, 0.3);
        }

        .btn-book::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
            transition: left 0.5s;
        }

        .btn-book:hover::before {
            left: 100%;
        }

        .btn-book:hover {
            background: linear-gradient(135deg, #c0392b 0%, #a93226 100%);
            border-color: #c0392b;
            transform: translateY(-2px) scale(1.02);
            box-shadow: 0 8px 24px rgba(231, 76, 60, 0.4);
            color: white;
        }

        .btn-book i {
            margin-right: 10px;
        }

        .btn-back {
            background: rgba(44, 62, 80, 0.6);
            border: 2px solid rgba(255, 255, 255, 0.2);
            border-radius: 15px;
            padding: 18px 35px;
            color: #f7efe7;
            font-weight: 700;
            font-size: 1.2rem;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            text-decoration: none;
            display: inline-block;
            position: relative;
            overflow: hidden;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
        }

        .btn-back::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
            transition: left 0.5s;
        }

        .btn-back:hover::before {
            left: 100%;
        }

        .btn-back:hover {
            background: rgba(44, 62, 80, 0.9);
            border-color: rgba(255, 255, 255, 0.4);
            transform: translateY(-2px) scale(1.02);
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.3);
            color: #f7efe7;
        }

        .btn-back i {
            margin-right: 10px;
        }

        /* Enhanced Reviews Section */
        .reviews-section {
            background: rgba(44, 62, 80, 0.6);
            border-radius: 24px;
            padding: 50px;
            margin: 30px 0;
            box-shadow: 0 16px 40px rgba(0,0,0,0.4);
            border: 1px solid rgba(255, 255, 255, 0.1);
            animation: fadeInUp 0.8s ease-out 0.2s both;
        }

        .reviews-title {
            font-size: 2.2rem;
            font-weight: 800;
            color: #f7efe7;
            margin-bottom: 40px;
            text-align: center;
        }

        .reviews-title i {
            margin-right: 15px;
            color: #ffc107;
        }

        .review-item {
            background: rgba(44, 62, 80, 0.4);
            border-radius: 20px;
            padding: 30px;
            margin-bottom: 25px;
            border-left: 5px solid #5cbe8f;
            transition: all 0.3s ease;
            box-shadow: 0 4px 12px rgba(0,0,0,0.2);
        }

        .review-item:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 24px rgba(0,0,0,0.3);
            border-left-color: #4a9b7a;
        }

        .review-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        .reviewer-name {
            font-weight: 700;
            color: #f7efe7;
            font-size: 1.2rem;
        }

        .review-rating {
            color: #ffc107;
            font-size: 1.3rem;
            text-shadow: 0 2px 4px rgba(255, 193, 7, 0.3);
        }

        .review-date {
            color: rgba(247, 239, 231, 0.7);
            font-size: 1rem;
            font-weight: 500;
        }

        .review-content {
            color: rgba(247, 239, 231, 0.9);
            line-height: 1.7;
            font-size: 1.1rem;
        }

        .no-reviews {
            text-align: center;
            color: rgba(247, 239, 231, 0.8);
            padding: 60px 20px;
            background: rgba(44, 62, 80, 0.3);
            border-radius: 20px;
        }

        .no-reviews i {
            font-size: 4rem;
            margin-bottom: 25px;
            opacity: 0.6;
            color: var(--primary-color);
        }

        .no-reviews h5 {
            font-size: 1.5rem;
            font-weight: 700;
            margin-bottom: 15px;
            color: var(--text-dark);
        }

        .no-reviews p {
            font-size: 1.1rem;
            opacity: 0.8;
        }

        /* Enhanced Rating Display */
        .text-warning {
            color: #ffc107 !important;
            text-shadow: 0 2px 4px rgba(255, 193, 7, 0.3);
        }

        .badge {
            font-size: 1rem;
            padding: 8px 16px;
            border-radius: 20px;
        }

        /* Responsive Design */
        @media (max-width: 992px) {
            .movie-poster-section {
                height: 400px;
            }
            
            .movie-info-section {
                padding: 30px;
            }
            
            .movie-title {
                font-size: 2.5rem;
            }
        }

        @media (max-width: 768px) {
            .movie-title {
                font-size: 2rem;
            }
            
            .movie-meta {
                flex-direction: column;
                gap: 15px;
            }
            
            .detail-row {
                flex-direction: column;
            }
            
            .detail-label {
                width: 100%;
                margin-bottom: 8px;
                font-size: 1rem;
            }
            
            .action-buttons {
                flex-direction: column;
            }
            
            .btn-book, .btn-back, .trailer-btn {
                width: 100%;
                text-align: center;
            }
            
            .reviews-section {
                padding: 30px 20px;
            }
        }

        @media (max-width: 576px) {
            .movie-info-section {
                padding: 20px;
            }
            
            .movie-title {
                font-size: 1.8rem;
            }
            
            .movie-details, .movie-description {
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
        
        Movie movie = (Movie) request.getAttribute("movie");
        List<Review> reviews = (List<Review>) request.getAttribute("reviews");
        Double averageRating = (Double) request.getAttribute("averageRating");
        Integer totalReviews = (Integer) request.getAttribute("totalReviews");
    %>
    
    <!-- Include Reusable Navbar Component -->
    <jsp:include page="/components/navbar.jsp" />

    <div class="container">
        <div class="movie-detail-container">
            <div class="row">
                <!-- Movie Poster -->
                <div class="col-lg-4">
                    <div class="movie-poster-section">
                        <img src="<%= movie.getPosterURL() %>" alt="<%= movie.getTitle() %>" class="movie-poster">
                    </div>
                </div>
                
                <!-- Movie Information -->
                <div class="col-lg-8">
                    <div class="movie-info-section">
                        <h1 class="movie-title"><%= movie.getTitle() %></h1>
                        
                        <div class="movie-meta">
                            <div class="meta-item">
                                <i class="fas fa-tags"></i>
                                <span><%= movie.getGenre() %></span>
                            </div>
                            <div class="meta-item">
                                <i class="fas fa-clock"></i>
                                <span><%= movie.getDuration() %> phút</span>
                            </div>
                            <div class="meta-item">
                                <i class="fas fa-calendar"></i>
                                <span><%= movie.getReleasedDate() %></span>
                            </div>
                            <div class="meta-item">
                                <i class="fas fa-language"></i>
                                <span><%= movie.getLanguageName() %></span>
                            </div>
                            <div class="meta-item">
                                <span class="movie-status status-<%= "Active".equals(movie.getStatus()) ? "active" : "upcoming" %>">
                                    <%= "Active".equals(movie.getStatus()) ? "Đang chiếu" : "Sắp chiếu" %>
                                </span>
                            </div>
                        </div>
                        
                        <div class="movie-description">
                            <h5><i class="fas fa-info-circle"></i> Tóm tắt phim</h5>
                            <p><%= movie.getSummary() %></p>
                        </div>
                        
                        <div class="movie-details">
                            <h5><i class="fas fa-info"></i> Thông tin chi tiết</h5>
                            <div class="detail-row">
                                <div class="detail-label">Đạo diễn:</div>
                                <div class="detail-value"><%= movie.getDirector() %></div>
                            </div>
                            <div class="detail-row">
                                <div class="detail-label">Diễn viên:</div>
                                <div class="detail-value"><%= movie.getCast() %></div>
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
                                <div class="detail-label">Ngày công chiếu:</div>
                                <div class="detail-value"><%= movie.getReleasedDate() %></div>
                            </div>
                            <div class="detail-row">
                                <div class="detail-label">Ngôn ngữ:</div>
                                <div class="detail-value"><%= movie.getLanguageName() %></div>
                            </div>
                            <div class="detail-row">
                                <div class="detail-label">Trạng thái:</div>
                                <div class="detail-value">
                                    <span class="movie-status status-<%= "Active".equals(movie.getStatus()) ? "active" : "upcoming" %>">
                                        <%= "Active".equals(movie.getStatus()) ? "Đang chiếu" : "Sắp chiếu" %>
                                    </span>
                                </div>
                            </div>
                        </div>
                        
                        <% if (movie.getTrailerURL() != null && !movie.getTrailerURL().isEmpty()) { %>
                            <div class="trailer-section">
                                <h5><i class="fas fa-play-circle"></i> Trailer</h5>
                                <a href="<%= movie.getTrailerURL() %>" target="_blank" class="trailer-btn">
                                    <i class="fas fa-play"></i> Xem trailer
                                </a>
                            </div>
                        <% } %>
                        
                        <div class="action-buttons">
                            <a href="#" class="btn-book" onclick="alert('Vui lòng đăng nhập để đặt vé!')">
                                <i class="fas fa-ticket-alt"></i> Đặt vé
                            </a>
                            <a href="guest-movies" class="btn-back">
                                <i class="fas fa-arrow-left"></i> Quay lại
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Reviews Section -->
        <div class="reviews-section">
            <div style="display: flex; align-items: center; gap: 15px; margin-bottom: 30px;">
                <h3 class="reviews-title" style="margin: 0;">
                    <i class="fas fa-star"></i> Đánh giá phim
                </h3>
                <% if (totalReviews != null && totalReviews > 0) { %>
                    <span class="badge" style="background: linear-gradient(135deg, #5cbe8f 0%, #4a9b7a 100%); color: white; padding: 6px 14px; font-size: 0.85rem; border-radius: 20px; box-shadow: 0 2px 8px rgba(92, 190, 143, 0.3); line-height: 1.5; display: inline-flex; align-items: center;"><%= totalReviews %> đánh giá</span>
                <% } %>
            </div>
            
            <% if (totalReviews != null && totalReviews > 0) { %>
                <div class="mb-4" style="background: rgba(92, 190, 143, 0.1); border-left: 4px solid #5cbe8f; padding: 20px; border-radius: 12px;">
                    <h5 style="color: #f7efe7; margin: 0; display: flex; align-items: center; gap: 10px;">
                        <span>Điểm trung bình:</span>
                        <span style="color: #f8b500; font-size: 1.3rem;">
                            <% 
                                // Calculate filled and empty stars based on average rating
                                int fullStars = (int) Math.floor(averageRating);
                                boolean hasHalfStar = (averageRating - fullStars) >= 0.5;
                                int emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);
                                
                                for (int i = 0; i < fullStars; i++) { 
                            %>
                                <i class="fas fa-star"></i>
                            <% } %>
                            <% if (hasHalfStar) { %>
                                <i class="fas fa-star-half-alt"></i>
                            <% } %>
                            <% for (int i = 0; i < emptyStars; i++) { %>
                                <i class="far fa-star"></i>
                            <% } %>
                        </span>
                        <span style="color: #5cbe8f; font-weight: 700; font-size: 1.2rem; text-shadow: none;"><%= String.format("%.1f", averageRating) %>/5</span>
                    </h5>
                </div>
            <% } %>
            
            <% if (reviews != null && !reviews.isEmpty()) { %>
                <% for (Review review : reviews) { %>
                    <div class="review-item">
                        <div class="review-header">
                            <div>
                                <div class="reviewer-name"><%= review.getUserName() != null ? review.getUserName() : "Anonymous" %></div>
                                <div class="review-rating" style="text-shadow: none;">
                                    <% 
                                        int rating = review.getRating() != null ? review.getRating() : 0;
                                        for (int i = 1; i <= 5; i++) { 
                                    %>
                                        <i class="fas fa-star <%= i <= rating ? "text-warning" : "far text-muted" %>" style="text-shadow: none;"></i>
                                    <% } %>
                                    <span class="ms-2" style="color: #5cbe8f; font-weight: 600; text-shadow: none;"><%= rating %>/5</span>
                                </div>
                            </div>
                            <div class="review-date">
                                <%= review.getReviewDate() != null ? review.getReviewDate().format(DateTimeFormatter.ofPattern("dd/MM/yyyy")) : "" %>
                            </div>
                        </div>
                        <div class="review-content">
                            <%= review.getComment() != null ? review.getComment() : "Không có bình luận" %>
                        </div>
                    </div>
                <% } %>
            <% } else { %>
                <div class="no-reviews">
                    <i class="fas fa-comment-slash"></i>
                    <h5>Chưa có đánh giá nào</h5>
                    <p>Hãy là người đầu tiên đánh giá bộ phim này!</p>
                </div>
            <% } %>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
