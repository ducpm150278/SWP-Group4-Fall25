<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Viết Đánh Giá - ${movie.title}</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/cinema-dark-theme.css" rel="stylesheet">
    
    <style>
        .rating-group {
            display: flex;
            flex-wrap: wrap;
            gap: 10px; 
            margin-bottom: 25px;
        }
        .rating-group input[type="radio"] {
            display: none; 
        }
        
        .rating-group label {
            position: relative;
            background: transparent;
            border: none;
            color: #3a3d45;
            padding: 0;
            width: 40px;
            height: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            font-size: 30px;
            transition: all 0.2s ease;
        }
        
        .rating-group label::before {
            font-family: "Font Awesome 6 Free";
            font-weight: 900;
            content: "\f005"; 
        }
        
        .rating-group label:hover {
             transform: scale(1.2);
             color: #777;
        }

        .rating-group label.preceding {
            color: #fff; /* Màu TRẮNG */
        }

        .rating-group label.selected {
            color: var(--primary-red, #e50914);
            transform: scale(1.2);
        }
        
        .rating-group label span {
            display: none; 
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            color: #fff; 
            font-family: 'Poppins', sans-serif;
            font-size: 14px;
            font-weight: 700;
            line-height: 1; 
        }
        
        .rating-group label.selected span {
            display: block; 
        }
    </style>
</head>
<body>
    <jsp:include page="/components/navbar.jsp" />

    <div class="container-medium">
        <div class="card-cinema">
            <div class="card-header-cinema">
                <h1><i class="fas fa-star"></i> Viết Đánh Giá</h1>
                <p>Bạn đang đánh giá cho phim: <strong>${movie.title}</strong></p>
            </div>
            
            <div style="padding: 30px;">
                <c:if test="${not empty error}">
                    <div class="alert-cinema alert-danger-cinema">
                        <i class="fas fa-exclamation-circle"></i> ${error}
                    </div>
                </c:if>

                <form action="writeReview" method="post">
                    <input type="hidden" name="movieId" value="${movie.movieID}">
                    
                    <div class="form-group-cinema">
                        <label class="form-label-cinema">
                            <i class="fas fa-poll"></i> 
                            Bạn chấm phim này bao nhiêu điểm? 
                            (<i class="fas fa-star" style="color: #3a3d45; font-size: 0.8em;"></i> 1 = Tệ, 
                            <i class="fas fa-star" style="color: var(--primary-red, #e50914); font-size: 0.8em;"></i> 10 = Tuyệt vời)
                        </label>
                        <div class="rating-group" id="starRatingGroup">
                            <c:forEach begin="1" end="10" var="score">
                                <input type="radio" id="rating-${score}" name="rating" value="${score}" 
                                       onclick="handleRatingClick(${score})" required> 
                                <label for="rating-${score}" 
                                       data-rating="${score}" 
                                       title="${score} điểm">
                                    <span>${score}</span>
                                </label>
                            </c:forEach>
                        </div>
                    </div>

                    <div class="form-group-cinema">
                        <label class="form-label-cinema" for="commentText">
                            <i class="fas fa-comment"></i> Nội dung đánh giá
                        </label>
                        <textarea class="form-control-cinema" 
                                  id="commentText" 
                                  name="comment" 
                                  rows="6" 
                                  placeholder="Chia sẻ cảm nhận của bạn về bộ phim..." 
                                  required></textarea>
                    </div>

                    <div class="d-flex gap-2 justify-content-between" style="margin-top: 30px;">
                        <a href="${pageContext.request.contextPath}/booking-history" class="btn-secondary-cinema btn-cinema">
                            <i class="fas fa-arrow-left"></i> Quay lại
                        </a>
                        <button type="submit" class="btn-primary-cinema btn-cinema">
                            <i class="fas fa-paper-plane"></i> Gửi bình luận
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function handleRatingClick(clickedRating) {
            const labels = document.querySelectorAll('#starRatingGroup label');
            labels.forEach(label => {
                const labelRating = parseInt(label.dataset.rating);
                label.classList.remove('selected', 'preceding');
                if (labelRating < clickedRating) {
                    label.classList.add('preceding');
                } else if (labelRating === clickedRating) {
                    label.classList.add('selected');
                }
            });
        }
    </script>
</body>
</html>