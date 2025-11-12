package com.cinema.controller.booking;

import com.cinema.dal.CinemaDAO;
import com.cinema.dal.MovieDAO;
import com.cinema.dal.ScreeningDAO;
import com.cinema.entity.BookingSession;
import com.cinema.entity.Cinema;
import com.cinema.entity.Movie;
import com.cinema.entity.Screening;
import com.cinema.utils.BookingSessionManager;
import com.cinema.utils.Constants;
import com.cinema.utils.SessionUtils;

import jakarta.servlet.ServletException;
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
 * Servlet xử lý bước 1: Chọn suất chiếu (Rạp, Phim, Ngày, Giờ)
 */
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
    
    /**
     * Xử lý request GET - hiển thị trang chọn suất chiếu
     * Flow: Kiểm tra đăng nhập -> Dọn dẹp session cũ -> Lấy danh sách rạp/phim -> Hiển thị form
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        // Bước 1: Kiểm tra người dùng đã đăng nhập chưa
        // Đặt vé yêu cầu người dùng phải đăng nhập để lưu thông tin booking
        Integer userId = SessionUtils.getUserId(session);
        if (userId == null) {
            // Người dùng chưa đăng nhập - lưu URL hiện tại để redirect lại sau khi đăng nhập
            // Điều này đảm bảo người dùng không bị mất context khi đăng nhập
            session.setAttribute(Constants.SESSION_REDIRECT_AFTER_LOGIN, request.getContextPath() + Constants.URL_BOOKING_SELECT_SCREENING);
            session.setAttribute(Constants.SESSION_LOGIN_MESSAGE, "Vui lòng đăng nhập để đặt vé");
            response.sendRedirect(request.getContextPath() + Constants.URL_AUTH_LOGIN);
            return;
        }
        
        // Bước 2: Dọn dẹp booking session cũ (nếu có)
        // Xóa booking session từ lần đặt vé trước để bắt đầu booking mới
        // Đảm bảo không có dữ liệu cũ ảnh hưởng đến booking hiện tại
        BookingSessionManager.clearBookingSession(session);
        
        // Bước 3: Lấy danh sách tất cả rạp đang hoạt động
        // Chỉ hiển thị các rạp có trạng thái Active để người dùng chọn
        List<Cinema> cinemas = cinemaDAO.getActiveCinemas();
        request.setAttribute("cinemas", cinemas);
        
        // Bước 4: Lấy danh sách tất cả phim đang hoạt động
        // Bao gồm cả phim đang chiếu (Active) và sắp chiếu (Upcoming)
        List<Movie> movies = movieDAO.getAllActiveMovies();
        request.setAttribute("movies", movies);
        
        // Bước 5: Chuyển tiếp đến trang JSP để hiển thị form chọn suất chiếu
        // JSP sẽ hiển thị dropdown cho rạp, phim, ngày và AJAX load suất chiếu
        request.getRequestDispatcher(Constants.JSP_BOOKING_SELECT_SCREENING).forward(request, response);
    }
    
    /**
     * Xử lý request POST - xử lý khi người dùng chọn suất chiếu
     * Flow: Validate screening ID -> Kiểm tra tồn tại -> Validate thời gian -> Validate ghế trống -> Lưu vào session -> Chuyển bước tiếp
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            // Bước 1: Lấy và parse screening ID từ form
            // screeningID là ID của suất chiếu mà người dùng đã chọn
            int screeningID = Integer.parseInt(request.getParameter("screeningID"));
            
            // Bước 2: Lấy thông tin chi tiết của suất chiếu từ database
            // Bao gồm: phim, rạp, phòng, thời gian, giá vé, số ghế trống, v.v.
            Screening screening = screeningDAO.getScreeningDetail(screeningID);
            
            // Bước 3: Kiểm tra suất chiếu có tồn tại không
            // Có thể bị xóa hoặc không hợp lệ giữa lúc người dùng chọn và submit
            if (screening == null) {
                request.setAttribute("error", "Lịch chiếu không tồn tại!");
                doGet(request, response);
                return;
            }
            
            // Bước 4: Kiểm tra thời gian suất chiếu có trong quá khứ không
            // Không cho phép đặt vé cho suất chiếu đã qua
            if (screening.getStartTime().isBefore(LocalDateTime.now())) {
                request.setAttribute("error", "Lịch chiếu đã qua. Vui lòng chọn lịch chiếu khác!");
                doGet(request, response);
                return;
            }
            
            // Bước 5: Kiểm tra còn ghế trống không
            // availableSeats là số ghế còn trống sau khi trừ đi ghế đã đặt và đã reserve
            if (screening.getAvailableSeats() <= 0) {
                request.setAttribute("error", "Suất chiếu đã hết chỗ!");
                doGet(request, response);
                return;
            }
            
            // Bước 6: Tạo hoặc lấy booking session từ session
            // Booking session sẽ lưu toàn bộ thông tin booking qua các bước
            HttpSession session = request.getSession();
            BookingSession bookingSession = BookingSessionManager.getBookingSession(session);
            
            // Bước 7: Lưu thông tin suất chiếu vào booking session
            // Thông tin này sẽ được sử dụng ở các bước tiếp theo (chọn ghế, chọn đồ ăn, thanh toán)
            bookingSession.setScreeningID(screeningID);
            bookingSession.setMovieTitle(screening.getMovieTitle());
            bookingSession.setCinemaName(screening.getCinemaName());
            bookingSession.setRoomName(screening.getRoomName());
            bookingSession.setScreeningTime(screening.getStartTime());
            bookingSession.setTicketPrice(screening.getTicketPrice());
            
            // Bước 8: Chuyển hướng đến bước tiếp theo - chọn ghế
            // Người dùng sẽ được đưa đến trang chọn ghế với thông tin suất chiếu đã lưu
            response.sendRedirect(request.getContextPath() + Constants.URL_BOOKING_SELECT_SEATS);
            
        } catch (NumberFormatException e) {
            // Xử lý lỗi khi screeningID không phải là số hợp lệ
            // Có thể do người dùng chỉnh sửa form hoặc gửi request không hợp lệ
            request.setAttribute("error", "Dữ liệu không hợp lệ!");
            doGet(request, response);
        }
    }
}

