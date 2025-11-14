package controller.booking;

import dal.CinemaDAO;
import dal.MovieDAO;
import dal.ScreeningDAO;
import entity.BookingSession;
import entity.Cinema;
import entity.Movie;
import entity.Screening;
import utils.BookingSessionManager;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDateTime;
import java.util.List;

/**
 * Servlet xử lý Bước 1 của quy trình đặt vé: Chọn suất chiếu
 * 
 * Flow tổng quan:
 * 1. Người dùng chọn rạp (Cinema)
 * 2. Người dùng chọn phim (Movie)
 * 3. Người dùng chọn ngày (Date)
 * 4. Hệ thống load các suất chiếu khả dụng (AJAX - LoadScreeningsServlet)
 * 5. Người dùng chọn suất chiếu (Screening) - thời gian cụ thể
 * 6. Lưu thông tin suất chiếu vào BookingSession
 * 7. Chuyển sang Bước 2: Chọn ghế
 * 
 * Endpoint: /booking/select-screening
 */
public class BookingSelectScreeningServlet extends HttpServlet {
    
    /** DAO để thao tác với dữ liệu rạp chiếu phim */
    private CinemaDAO cinemaDAO;
    /** DAO để thao tác với dữ liệu phim */
    private MovieDAO movieDAO;
    /** DAO để thao tác với dữ liệu suất chiếu */
    private ScreeningDAO screeningDAO;
    
    /**
     * Khởi tạo servlet - tạo các DAO instances
     */
    @Override
    public void init() throws ServletException {
        cinemaDAO = new CinemaDAO();
        movieDAO = new MovieDAO();
        screeningDAO = new ScreeningDAO();
    }
    
    /**
     * Xử lý request GET - hiển thị form chọn suất chiếu
     * 
     * Flow xử lý:
     * Bước 1: Kiểm tra người dùng đã đăng nhập chưa
     * Bước 2: Nếu chưa đăng nhập, lưu URL hiện tại để redirect sau khi login, rồi redirect đến trang login
     * Bước 3: Xóa booking session cũ (nếu có) để bắt đầu đặt vé mới
     * Bước 4: Load danh sách tất cả rạp đang hoạt động
     * Bước 5: Load danh sách tất cả phim đang chiếu
     * Bước 6: Forward đến trang JSP để hiển thị form chọn suất chiếu
     * 
     * @param request HTTP request
     * @param response HTTP response
     * @throws ServletException nếu có lỗi servlet
     * @throws IOException nếu có lỗi I/O
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        // Bước 1: Kiểm tra người dùng đã đăng nhập chưa
        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null) {
            // Bước 2: Chưa đăng nhập - lưu URL hiện tại để redirect về sau khi login
            session.setAttribute("redirectAfterLogin", request.getContextPath() + BookingConstants.PATH_SELECT_SCREENING);
            session.setAttribute("loginMessage", "Vui lòng đăng nhập để đặt vé");
            // Redirect đến trang đăng nhập
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        // Bước 3: Xóa booking session cũ (nếu có)
        // Đảm bảo bắt đầu một quy trình đặt vé mới, không bị ảnh hưởng bởi session cũ
        BookingSessionManager.clearBookingSession(session);
        
        // Bước 4: Load danh sách tất cả rạp đang hoạt động
        // Rạp sẽ được hiển thị trong dropdown để người dùng chọn
        List<Cinema> cinemas = cinemaDAO.getActiveCinemas();
        request.setAttribute("cinemas", cinemas);
        
        // Bước 5: Load danh sách tất cả phim đang chiếu
        // Phim sẽ được hiển thị trong dropdown để người dùng chọn
        List<Movie> movies = movieDAO.getAllActiveMovies();
        request.setAttribute("movies", movies);
        
        // Bước 6: Forward đến trang JSP để hiển thị form chọn suất chiếu
        request.getRequestDispatcher(BookingConstants.JSP_SELECT_SCREENING).forward(request, response);
    }
    
    /**
     * Xử lý request POST - xử lý khi người dùng chọn suất chiếu
     * 
     * Flow xử lý:
     * Bước 1: Lấy screeningID từ form
     * Bước 2: Lấy thông tin chi tiết của suất chiếu từ database
     * Bước 3: Kiểm tra suất chiếu có tồn tại không
     * Bước 4: Kiểm tra thời gian suất chiếu có trong quá khứ không (không cho đặt vé quá khứ)
     * Bước 5: Kiểm tra còn ghế trống không (availableSeats > 0)
     * Bước 6: Tạo hoặc lấy BookingSession từ session
     * Bước 7: Lưu thông tin suất chiếu vào BookingSession (screeningID, movieTitle, cinemaName, roomName, screeningTime, ticketPrice)
     * Bước 8: Redirect đến Bước 2: Chọn ghế
     * 
     * @param request HTTP request chứa screeningID từ form
     * @param response HTTP response để redirect
     * @throws ServletException nếu có lỗi servlet
     * @throws IOException nếu có lỗi I/O
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            // Bước 1: Lấy screeningID từ form và parse sang integer
            int screeningID = Integer.parseInt(request.getParameter("screeningID"));
            
            // Bước 2: Lấy thông tin chi tiết của suất chiếu từ database
            // Bao gồm: movieTitle, cinemaName, roomName, startTime, ticketPrice, availableSeats, etc.
            Screening screening = screeningDAO.getScreeningDetail(screeningID);
            
            // Bước 3: Kiểm tra suất chiếu có tồn tại không
            if (screening == null) {
                request.setAttribute("error", "Lịch chiếu không tồn tại!");
                // Hiển thị lại form với thông báo lỗi
                doGet(request, response);
                return;
            }
            
            // Bước 4: Kiểm tra thời gian suất chiếu có trong quá khứ không
            // Không cho phép đặt vé cho suất chiếu đã qua
            if (screening.getStartTime().isBefore(LocalDateTime.now())) {
                request.setAttribute("error", "Lịch chiếu đã qua. Vui lòng chọn lịch chiếu khác!");
                // Hiển thị lại form với thông báo lỗi
                doGet(request, response);
                return;
            }
            
            // Bước 5: Kiểm tra còn ghế trống không
            // availableSeats được tính từ view database, trừ đi số ghế đã đặt
            if (screening.getAvailableSeats() <= 0) {
                request.setAttribute("error", "Suất chiếu đã hết chỗ!");
                // Hiển thị lại form với thông báo lỗi
                doGet(request, response);
                return;
            }
            
            // Bước 6: Tạo hoặc lấy BookingSession từ session
            // BookingSession lưu trữ toàn bộ thông tin đặt vé trong suốt quy trình
            HttpSession session = request.getSession();
            BookingSession bookingSession = BookingSessionManager.getBookingSession(session);
            
            // Bước 7: Lưu thông tin suất chiếu vào BookingSession
            // Các thông tin này sẽ được sử dụng ở các bước tiếp theo
            bookingSession.setScreeningID(screeningID);                    // ID suất chiếu
            bookingSession.setMovieTitle(screening.getMovieTitle());       // Tên phim
            bookingSession.setCinemaName(screening.getCinemaName());       // Tên rạp
            bookingSession.setRoomName(screening.getRoomName());           // Tên phòng chiếu
            bookingSession.setScreeningTime(screening.getStartTime());     // Thời gian chiếu
            bookingSession.setTicketPrice(screening.getTicketPrice());     // Giá vé cơ bản
            
            // Bước 8: Redirect đến Bước 2: Chọn ghế
            response.sendRedirect(request.getContextPath() + BookingConstants.PATH_SELECT_SEATS);
            
        } catch (NumberFormatException e) {
            // Xử lý lỗi khi screeningID không phải là số hợp lệ
            request.setAttribute("error", "Dữ liệu không hợp lệ!");
            // Hiển thị lại form với thông báo lỗi
            doGet(request, response);
        }
    }
}

