package controller;

import dal.CinemaDAO;
import dal.MovieDAO;
import dal.ScreeningDAO;
import entity.BookingSession;
import entity.Cinema;
import entity.Movie;
import entity.Screening;
import utils.BookingSessionManager;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

/**
 * Servlet for Step 1: Select Screening (Cinema, Movie, Date, Time)
 */
@WebServlet(name = "BookingSelectScreeningServlet", urlPatterns = {"/booking/select-screening"})
public class BookingSelectScreeningServlet extends HttpServlet {
    
    private CinemaDAO cinemaDAO;
    private MovieDAO movieDAO;
    private ScreeningDAO screeningDAO;
    
    @Override
    public void init() throws ServletException {
        cinemaDAO = new CinemaDAO();
        movieDAO = new MovieDAO();
        screeningDAO = new ScreeningDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        // Check if user is logged in
        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null) {
            // Save the current URL to redirect back after login
            session.setAttribute("redirectAfterLogin", request.getContextPath() + "/booking/select-screening");
            session.setAttribute("loginMessage", "Vui lòng đăng nhập để đặt vé");
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        // Clear any existing booking session
        BookingSessionManager.clearBookingSession(session);
        
        // Get all active cinemas
        List<Cinema> cinemas = cinemaDAO.getActiveCinemas();
        request.setAttribute("cinemas", cinemas);
        
        // Get all active movies
        List<Movie> movies = movieDAO.getAllActiveMovies();
        request.setAttribute("movies", movies);
        
        // Forward to selection page
        request.getRequestDispatcher("/booking/select-screening.jsp").forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            // Get selected screening ID
            int screeningID = Integer.parseInt(request.getParameter("screeningID"));
            
            // Get screening details
            Screening screening = screeningDAO.getScreeningDetail(screeningID);
            
            if (screening == null) {
                request.setAttribute("error", "Lịch chiếu không tồn tại!");
                doGet(request, response);
                return;
            }
            
            // Check if screening time is in the past
            if (screening.getStartTime().isBefore(LocalDateTime.now())) {
                request.setAttribute("error", "Lịch chiếu đã qua. Vui lòng chọn lịch chiếu khác!");
                doGet(request, response);
                return;
            }
            
            // Check if seats are available
            if (screening.getAvailableSeats() <= 0) {
                request.setAttribute("error", "Suất chiếu đã hết chỗ!");
                doGet(request, response);
                return;
            }
            
            // Create or get booking session
            HttpSession session = request.getSession();
            BookingSession bookingSession = BookingSessionManager.getBookingSession(session);
            
            // Store screening information in session
            bookingSession.setScreeningID(screeningID);
            bookingSession.setMovieTitle(screening.getMovieTitle());
            bookingSession.setCinemaName(screening.getCinemaName());
            bookingSession.setRoomName(screening.getRoomName());
            bookingSession.setScreeningTime(screening.getStartTime());
            bookingSession.setTicketPrice(screening.getTicketPrice());
            
            // Redirect to seat selection
            response.sendRedirect(request.getContextPath() + "/booking/select-seats");
            
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Dữ liệu không hợp lệ!");
            doGet(request, response);
        }
    }
}

