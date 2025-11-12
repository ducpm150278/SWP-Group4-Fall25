package com.cinema.controller.movie;


import com.cinema.dal.MovieDAO;
import com.cinema.dal.ReviewDAO;
import com.cinema.entity.Movie;
import com.cinema.entity.Review;
import com.cinema.utils.Constants;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Servlet xử lý xem chi tiết phim cho khách (chưa đăng nhập)
 */
@WebServlet(name="GuestMovieDetailServlet", urlPatterns={"/guest-movie-detail"})
public class GuestMovieDetailServlet extends HttpServlet { 

    private MovieDAO movieDAO;
    private ReviewDAO reviewDAO;

    @Override
    public void init() throws ServletException {
        movieDAO = new MovieDAO();
        reviewDAO = new ReviewDAO();
    }

    /**
     * Xử lý request GET - hiển thị chi tiết phim cho khách (chưa đăng nhập)
     * Flow: Validate movie ID -> Kiểm tra phim tồn tại -> Kiểm tra visibility -> Lấy reviews -> Hiển thị
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Bước 1: Lấy movie ID từ request parameter
        String movieIDStr = request.getParameter("id");
        
        // Bước 2: Kiểm tra movie ID có tồn tại không
        if (isBlank(movieIDStr)) {
            // Không có movie ID - chuyển về danh sách phim
            redirectToMovieList(request, response);
            return;
        }
        
        try {
            // Bước 3: Parse movie ID từ string sang integer
            int movieID = Integer.parseInt(movieIDStr);
            
            // Bước 4: Lấy thông tin phim từ database
            Movie movie = getMovieById(movieID);
            
            // Bước 5: Kiểm tra phim có tồn tại và có thể xem được không
            // Chỉ cho phép xem phim có status Active hoặc Upcoming
            if (movie == null || !isMovieVisibleToGuest(movie)) {
                // Phim không tồn tại hoặc không visible - chuyển về danh sách phim
                redirectToMovieList(request, response);
                return;
            }
            
            // Bước 6: Lấy thông tin reviews cho phim này
            List<Review> reviews = reviewDAO.getReviewsByMovieID(movieID);      // Danh sách reviews
            double averageRating = reviewDAO.getAverageRating(movieID);          // Điểm đánh giá trung bình
            int totalReviews = reviewDAO.getTotalReviews(movieID);               // Tổng số reviews
            
            // Bước 7: Truyền dữ liệu đến JSP
            request.setAttribute("movie", movie);
            request.setAttribute("reviews", reviews);
            request.setAttribute("averageRating", averageRating);
            request.setAttribute("totalReviews", totalReviews);
            
            // Bước 8: Chuyển tiếp đến trang JSP chi tiết phim
            request.getRequestDispatcher(Constants.JSP_MOVIE_GUEST_DETAIL).forward(request, response);
            
        } catch (NumberFormatException e) {
            // Bước 9: Xử lý lỗi khi movie ID không phải là số hợp lệ
            redirectToMovieList(request, response);
        }
    }
    
    /**
     * Lấy thông tin phim theo ID
     * @param movieID ID của phim
     * @return Movie object hoặc null nếu không tìm thấy
     */
    private Movie getMovieById(int movieID) {
        return movieDAO.getMovieById(movieID);
    }
    
    /**
     * Kiểm tra phim có thể xem được bởi khách không
     * Chỉ cho phép xem phim có status Active hoặc Upcoming
     * @param movie Movie object cần kiểm tra
     * @return true nếu phim có thể xem được, false nếu không
     */
    private boolean isMovieVisibleToGuest(Movie movie) {
        String status = movie.getStatus();
        // Chỉ cho phép xem phim Active (đang chiếu) hoặc Upcoming (sắp chiếu)
        return Constants.MOVIE_STATUS_ACTIVE.equals(status) || 
               Constants.MOVIE_STATUS_UPCOMING.equals(status);
    }
    
    /**
     * Chuyển hướng về trang danh sách phim
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     * @throws IOException nếu có lỗi khi redirect
     */
    private void redirectToMovieList(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.sendRedirect(request.getContextPath() + "/" + Constants.URL_GUEST_MOVIES);
    }
    
    /**
     * Kiểm tra chuỗi có rỗng hoặc chỉ chứa khoảng trắng không
     * @param str Chuỗi cần kiểm tra
     * @return true nếu rỗng hoặc chỉ chứa khoảng trắng
     */
    private boolean isBlank(String str) {
        return str == null || str.trim().isEmpty();
    }

}
