package controller.guest;

import dal.MovieDAO;
import dal.ReviewDAO;
import entity.Movie;
import entity.Review;
import java.util.List;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Servlet xử lý xem chi tiết phim cho khách (không cần đăng nhập)
 * 
 * Flow tổng quan:
 * 1. Nhận movieID từ request parameter "id"
 * 2. Validate movieID (không được null, phải là số hợp lệ)
 * 3. Query database để lấy thông tin phim
 * 4. Kiểm tra phim có tồn tại không
 * 5. Kiểm tra trạng thái phim:
 *    - Chỉ hiển thị phim có trạng thái "Active" hoặc "Upcoming"
 *    - Redirect về danh sách phim nếu phim không hợp lệ (Inactive, Cancelled, etc.)
 * 6. Load thông tin reviews:
 *    - Danh sách reviews của phim
 *    - Điểm đánh giá trung bình (averageRating)
 *    - Tổng số reviews (totalReviews)
 * 7. Gửi dữ liệu đến JSP để hiển thị chi tiết phim
 * 
 * Tính năng:
 * - Chỉ hiển thị phim Active và Upcoming cho khách
 * - Hiển thị thông tin chi tiết phim: tên, mô tả, poster, trailer, etc.
 * - Hiển thị danh sách reviews và điểm đánh giá trung bình
 * - Bảo vệ: Không cho phép xem phim Inactive, Cancelled, hoặc không tồn tại
 * 
 * Endpoint: /guest-movie-detail
 */
@WebServlet(name="GuestMovieDetailServlet", urlPatterns={"/guest-movie-detail"})
public class GuestMovieDetailServlet extends HttpServlet {
   
    /** 
     * Xử lý request GET để hiển thị chi tiết phim
     * 
     * Flow xử lý:
     * Bước 1: Lấy movieID từ request parameter "id"
     * Bước 2: Validate movieID (không được null hoặc rỗng)
     * Bước 3: Parse movieID sang integer
     * Bước 4: Query database để lấy thông tin phim
     * Bước 5: Kiểm tra phim có tồn tại không
     * Bước 6: Kiểm tra trạng thái phim (chỉ Active hoặc Upcoming)
     * Bước 7: Load thông tin reviews (danh sách, điểm trung bình, tổng số)
     * Bước 8: Gửi dữ liệu đến JSP để hiển thị
     * 
     * @param request HTTP request chứa parameter "id" (movieID)
     * @param response HTTP response để forward hoặc redirect
     * @throws ServletException nếu có lỗi servlet
     * @throws IOException nếu có lỗi I/O
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        // Bước 1: Lấy movieID từ request parameter "id"
        String movieIDStr = request.getParameter("id");
        
        // Bước 2: Validate movieID (không được null hoặc rỗng)
        if (movieIDStr == null || movieIDStr.trim().isEmpty()) {
            // Không có movieID, redirect về danh sách phim
            response.sendRedirect(GuestConstants.PATH_GUEST_MOVIES);
            return;
        }
        
        try {
            // Bước 3: Parse movieID sang integer
            int movieID = Integer.parseInt(movieIDStr);
            
            // Tạo các DAO để query database
            MovieDAO movieDAO = new MovieDAO();
            ReviewDAO reviewDAO = new ReviewDAO();
            
            // Bước 4: Query database để lấy thông tin phim
            Movie movie = movieDAO.getMovieById(movieID);
            
            // Bước 5: Kiểm tra phim có tồn tại không
            if (movie == null) {
                // Phim không tồn tại, redirect về danh sách phim
                response.sendRedirect(GuestConstants.PATH_GUEST_MOVIES);
                return;
            }
            
            // Bước 6: Kiểm tra trạng thái phim
            // Chỉ hiển thị phim có trạng thái "Active" hoặc "Upcoming" cho khách
            // Không cho phép xem phim "Inactive", "Cancelled", hoặc các trạng thái khác
            String movieStatus = movie.getStatus();
            if (!GuestConstants.STATUS_ACTIVE.equals(movieStatus) && !GuestConstants.STATUS_UPCOMING.equals(movieStatus)) {
                // Phim không hợp lệ (không phải Active hoặc Upcoming), redirect về danh sách phim
                response.sendRedirect(GuestConstants.PATH_GUEST_MOVIES);
                return;
            }
            
            // Bước 7: Load thông tin reviews
            // Lấy danh sách tất cả reviews của phim
            List<Review> reviews = reviewDAO.getReviewsByMovieID(movieID);
            // Tính điểm đánh giá trung bình (ví dụ: 4.5/5.0)
            double averageRating = reviewDAO.getAverageRating(movieID);
            // Đếm tổng số reviews
            int totalReviews = reviewDAO.getTotalReviews(movieID);
            
            // Bước 8: Gửi dữ liệu đến JSP để hiển thị
            request.setAttribute("movie", movie);              // Thông tin chi tiết phim
            request.setAttribute("reviews", reviews);          // Danh sách reviews
            request.setAttribute("averageRating", averageRating); // Điểm đánh giá trung bình
            request.setAttribute("totalReviews", totalReviews);   // Tổng số reviews
            
            // Forward đến trang JSP để hiển thị chi tiết phim
            request.getRequestDispatcher(GuestConstants.JSP_GUEST_MOVIE_DETAIL).forward(request, response);
            
        } catch (NumberFormatException e) {
            // Xử lý lỗi khi parse movieID không thành công (không phải số)
            response.sendRedirect(GuestConstants.PATH_GUEST_MOVIES);
        }
    }
}

