package com.cinema.controller.profile;


import com.cinema.dal.BookingDAO;
import com.cinema.dal.MovieDAO;
import com.cinema.dal.ReviewDAO;
import com.cinema.entity.Movie;
import com.cinema.utils.Constants;
import com.cinema.utils.SessionUtils;
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
        Integer userId = SessionUtils.getUserId(session); 
        
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + Constants.URL_AUTH_LOGIN);
            return;
        }

        try {
            int movieId = Integer.parseInt(request.getParameter("movieId"));

            boolean hasWatched = bookingDAO.hasUserCompletedMovie(userId, movieId);
            if (!hasWatched) {
                session.setAttribute(Constants.SESSION_ERROR, "Bạn chỉ có thể đánh giá phim bạn đã xem.");
                response.sendRedirect(request.getContextPath() + Constants.URL_BOOKING_HISTORY);
                return;
            }

            boolean hasReviewed = reviewDAO.hasUserReviewedMovie(userId, movieId);
            if (hasReviewed) {
                session.setAttribute(Constants.SESSION_ERROR, "Bạn đã đánh giá phim này rồi.");
                response.sendRedirect(request.getContextPath() + Constants.URL_BOOKING_HISTORY);
                return;
            }

            Movie movie = movieDAO.getMovieById(movieId);
            request.setAttribute("movie", movie);
            request.getRequestDispatcher(Constants.JSP_PROFILE_WRITE_REVIEW).forward(request, response);

        } catch (NumberFormatException e) {
            session.setAttribute(Constants.SESSION_ERROR, "Lỗi: ID phim không hợp lệ.");
            response.sendRedirect(request.getContextPath() + Constants.URL_BOOKING_HISTORY);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Integer userId = SessionUtils.getUserId(session);
        
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + Constants.URL_AUTH_LOGIN);
            return;
        }

        try {
            int movieId = Integer.parseInt(request.getParameter("movieId"));
            int rating = Integer.parseInt(request.getParameter("rating"));
            String comment = request.getParameter("comment");

            if (reviewDAO.hasUserReviewedMovie(userId, movieId)) {
                session.setAttribute(Constants.SESSION_ERROR, "Bạn đã đánh giá phim này rồi.");
                response.sendRedirect(request.getContextPath() + Constants.URL_BOOKING_HISTORY);
                return;
            }
            if (!bookingDAO.hasUserCompletedMovie(userId, movieId)) {
                session.setAttribute(Constants.SESSION_ERROR, "Bạn chỉ có thể đánh giá phim bạn đã xem.");
                response.sendRedirect(request.getContextPath() + Constants.URL_BOOKING_HISTORY);
                return;
            }

            boolean success = reviewDAO.addReview(movieId, userId, rating, comment);

            if (success) {
                session.setAttribute(Constants.SESSION_MESSAGE, "Gửi đánh giá thành công!");
                response.sendRedirect(request.getContextPath() + Constants.URL_BOOKING_HISTORY);
            } else {
                request.setAttribute(Constants.SESSION_ERROR, "Lỗi khi lưu đánh giá. Vui lòng thử lại.");
                Movie movie = movieDAO.getMovieById(movieId); 
                request.setAttribute("movie", movie);
                request.getRequestDispatcher(Constants.JSP_PROFILE_WRITE_REVIEW).forward(request, response);
            }
            
        } catch (Exception e) {
            request.setAttribute(Constants.SESSION_ERROR, "Dữ liệu không hợp lệ. Vui lòng điền đầy đủ thông tin.");
            request.getRequestDispatcher(Constants.JSP_PROFILE_WRITE_REVIEW).forward(request, response);
        }
    }
}