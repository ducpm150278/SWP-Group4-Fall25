package controller;

import dal.BookingDAO;
import dal.MovieDAO;
import dal.ReviewDAO;
import entity.Movie;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "WriteReviewServlet", urlPatterns = {"/writeReview"})
public class WriteReviewServlet extends HttpServlet {

    private MovieDAO movieDAO;
    private ReviewDAO reviewDAO;
    private BookingDAO bookingDAO;

    @Override
    public void init() throws ServletException {
        movieDAO = new MovieDAO();
        reviewDAO = new ReviewDAO();
        bookingDAO = new BookingDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId"); 
        
        if (userId == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        try {
            int movieId = Integer.parseInt(request.getParameter("movieId"));

            boolean hasWatched = bookingDAO.hasUserCompletedMovie(userId, movieId);
            if (!hasWatched) {
                session.setAttribute("error", "Bạn chỉ có thể đánh giá phim bạn đã xem.");
                response.sendRedirect("booking-history");
                return;
            }

            boolean hasReviewed = reviewDAO.hasUserReviewedMovie(userId, movieId);
            if (hasReviewed) {
                session.setAttribute("error", "Bạn đã đánh giá phim này rồi.");
                response.sendRedirect("booking-history");
                return;
            }

            Movie movie = movieDAO.getMovieById(movieId);
            request.setAttribute("movie", movie);
            request.getRequestDispatcher("writeReview.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            session.setAttribute("error", "Lỗi: ID phim không hợp lệ.");
            response.sendRedirect("booking-history");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");
        
        if (userId == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        try {
            int movieId = Integer.parseInt(request.getParameter("movieId"));
            int rating = Integer.parseInt(request.getParameter("rating"));
            String comment = request.getParameter("comment");

            if (reviewDAO.hasUserReviewedMovie(userId, movieId)) {
                session.setAttribute("error", "Bạn đã đánh giá phim này rồi.");
                response.sendRedirect("booking-history");
                return;
            }
            if (!bookingDAO.hasUserCompletedMovie(userId, movieId)) {
                session.setAttribute("error", "Bạn chỉ có thể đánh giá phim bạn đã xem.");
                response.sendRedirect("booking-history");
                return;
            }

            boolean success = reviewDAO.addReview(movieId, userId, rating, comment);

            if (success) {
                session.setAttribute("message", "Gửi đánh giá thành công!");
                response.sendRedirect("booking-history");
            } else {
                request.setAttribute("error", "Lỗi khi lưu đánh giá. Vui lòng thử lại.");
                Movie movie = movieDAO.getMovieById(movieId); 
                request.setAttribute("movie", movie);
                request.getRequestDispatcher("writeReview.jsp").forward(request, response);
            }
            
        } catch (Exception e) {
            request.setAttribute("error", "Dữ liệu không hợp lệ. Vui lòng điền đầy đủ thông tin.");
            request.getRequestDispatcher("writeReview.jsp").forward(request, response);
        }
    }
}