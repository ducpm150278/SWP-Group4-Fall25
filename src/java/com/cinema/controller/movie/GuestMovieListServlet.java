package com.cinema.controller.movie;


import com.cinema.dal.MovieDAO;
import com.cinema.entity.Movie;
import com.cinema.utils.Constants;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.List;

/**
 * Servlet xử lý xem danh sách phim cho khách (chưa đăng nhập)
 */
@WebServlet(name="GuestMovieListServlet", urlPatterns={"/guest-movies"})
public class GuestMovieListServlet extends HttpServlet { 

    private MovieDAO movieDAO;

    @Override
    public void init() throws ServletException {
        movieDAO = new MovieDAO();
    }

    /**
     * Xử lý request GET - hiển thị danh sách phim cho khách (chưa đăng nhập)
     * Flow: Lấy filter parameters -> Lấy danh sách phim -> Tính pagination -> Hiển thị
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Bước 1: Lấy các tham số filter từ request
        String status = request.getParameter("status");      // Filter theo status (Active, Upcoming)
        String keyword = request.getParameter("keyword");    // Tìm kiếm theo từ khóa
        int page = parsePageNumber(request.getParameter("page"));  // Số trang hiện tại

        // Bước 2: Lấy danh sách phim theo filter
        // Nếu có status filter thì lấy theo status, nếu không thì lấy tất cả phim active
        List<Movie> movies = getMoviesByFilter(status, keyword);
        
        // Bước 3: Tính toán pagination
        int totalRecords = movies.size();  // Tổng số phim
        int totalPages = (int) Math.ceil(totalRecords / (double) Constants.MOVIES_PER_PAGE);  // Tổng số trang

        // Bước 4: Phân trang danh sách phim
        // Chỉ lấy các phim thuộc trang hiện tại
        movies = paginateMovies(movies, page);

        // Bước 5: Truyền dữ liệu đến JSP
        request.setAttribute("movies", movies);              // Danh sách phim của trang hiện tại
        request.setAttribute("currentPage", page);            // Trang hiện tại
        request.setAttribute("totalPages", totalPages);       // Tổng số trang
        request.setAttribute("status", status);               // Filter status hiện tại
        request.setAttribute("keyword", keyword);             // Từ khóa tìm kiếm hiện tại

        // Bước 6: Chuyển tiếp đến trang JSP danh sách phim
        request.getRequestDispatcher(Constants.JSP_MOVIE_GUEST_LIST).forward(request, response);
    }
    
    /**
     * Parse số trang từ parameter
     * @param pageParam String parameter từ request
     * @return Số trang hợp lệ (>= 1), mặc định là 1 nếu không hợp lệ
     */
    private int parsePageNumber(String pageParam) {
        if (pageParam == null) {
            return 1;  // Mặc định trang 1 nếu không có parameter
        }
        try {
            int page = Integer.parseInt(pageParam);
            return page > 0 ? page : 1;  // Đảm bảo page >= 1
        } catch (NumberFormatException e) {
            return 1;  // Nếu không parse được, mặc định là 1
        }
    }
    
    /**
     * Lấy danh sách phim theo filter
     * @param status Filter theo status (Active, Upcoming) hoặc null để lấy tất cả
     * @param keyword Từ khóa tìm kiếm hoặc null
     * @return Danh sách phim đã được filter
     */
    private List<Movie> getMoviesByFilter(String status, String keyword) {
        if (!isBlank(status)) {
            // Có filter status - lấy phim theo status cụ thể
            return movieDAO.getMoviesByStatus(status, keyword);
        } else {
            // Không có filter status - lấy tất cả phim active (cả Active và Upcoming)
            return movieDAO.getActiveMoviesForGuest(keyword);
        }
    }
    
    /**
     * Kiểm tra chuỗi có rỗng hoặc chỉ chứa khoảng trắng không
     * @param str Chuỗi cần kiểm tra
     * @return true nếu rỗng hoặc chỉ chứa khoảng trắng
     */
    private boolean isBlank(String str) {
        return str == null || str.trim().isEmpty();
    }
    
    /**
     * Phân trang danh sách phim
     * @param movies Danh sách phim đầy đủ
     * @param page Số trang (bắt đầu từ 1)
     * @return Danh sách phim của trang được chỉ định
     */
    private List<Movie> paginateMovies(List<Movie> movies, int page) {
        // Tính index bắt đầu và kết thúc
        int startIndex = (page - 1) * Constants.MOVIES_PER_PAGE;
        int endIndex = Math.min(startIndex + Constants.MOVIES_PER_PAGE, movies.size());
        
        // Kiểm tra startIndex có vượt quá kích thước danh sách không
        if (startIndex >= movies.size()) {
            return List.of();  // Trả về danh sách rỗng nếu trang không hợp lệ
        }
        
        // Trả về sublist từ startIndex đến endIndex
        return movies.subList(startIndex, endIndex);
    }

}
