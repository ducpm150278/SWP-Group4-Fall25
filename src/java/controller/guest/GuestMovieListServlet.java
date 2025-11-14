package controller.guest;

import dal.MovieDAO;
import entity.Movie;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.List;

/**
 * Servlet xử lý xem danh sách phim cho khách (không cần đăng nhập)
 * 
 * Flow tổng quan:
 * 1. Nhận parameters từ request: status (lọc theo trạng thái), keyword (tìm kiếm), page (số trang)
 * 2. Validate và parse page parameter (mặc định là 1)
 * 3. Query database để lấy danh sách phim:
 *    - Nếu có status: Lọc theo trạng thái cụ thể (Active, Upcoming, etc.)
 *    - Nếu không có status: Lấy tất cả phim Active và Upcoming (dành cho khách)
 *    - Áp dụng keyword search nếu có
 * 4. Tính toán pagination:
 *    - Tính tổng số bản ghi (totalRecords)
 *    - Tính tổng số trang (totalPages)
 *    - Tính startIndex và endIndex để lấy subset phim cho trang hiện tại
 * 5. Cắt danh sách phim theo pagination
 * 6. Gửi dữ liệu đến JSP để hiển thị
 * 
 * Tính năng:
 * - Pagination: Hiển thị 12 phim mỗi trang (RECORDS_PER_PAGE)
 * - Filtering: Lọc theo trạng thái phim
 * - Search: Tìm kiếm theo keyword (tên phim, mô tả, etc.)
 * - Chỉ hiển thị phim Active và Upcoming cho khách (không hiển thị phim Inactive, Cancelled)
 * 
 * Endpoint: /guest-movies
 */
@WebServlet(name="GuestMovieListServlet", urlPatterns={"/guest-movies"})
public class GuestMovieListServlet extends HttpServlet {
   
    /** 
     * Xử lý request GET để hiển thị danh sách phim với pagination và filtering
     * 
     * Flow xử lý:
     * Bước 1: Lấy parameters từ request (status, keyword, page)
     * Bước 2: Validate và parse page parameter (mặc định là 1, tối thiểu là 1)
     * Bước 3: Query database để lấy danh sách phim:
     *    - Nếu có status: Lọc theo trạng thái cụ thể
     *    - Nếu không có status: Lấy tất cả phim Active và Upcoming
     *    - Áp dụng keyword search nếu có
     * Bước 4: Tính toán pagination:
     *    - Tính totalRecords (tổng số phim)
     *    - Tính totalPages (tổng số trang)
     *    - Tính startIndex và endIndex
     * Bước 5: Cắt danh sách phim theo pagination (lấy subset cho trang hiện tại)
     * Bước 6: Gửi dữ liệu đến JSP để hiển thị
     * 
     * @param request HTTP request chứa parameters: status, keyword, page
     * @param response HTTP response để forward
     * @throws ServletException nếu có lỗi servlet
     * @throws IOException nếu có lỗi I/O
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        // Bước 1: Lấy parameters từ request
        String status = request.getParameter("status");      // Trạng thái phim (Active, Upcoming, etc.)
        String keyword = request.getParameter("keyword");    // Từ khóa tìm kiếm
        int page = GuestConstants.DEFAULT_PAGE;              // Số trang hiện tại (mặc định là 1)
        int recordsPerPage = GuestConstants.RECORDS_PER_PAGE; // Số phim hiển thị mỗi trang (12)

        // Bước 2: Validate và parse page parameter
        String pageParam = request.getParameter("page");
        if (pageParam != null) {
            try {
                page = Integer.parseInt(pageParam);
                // Đảm bảo page >= 1
                if (page < 1) {
                    page = GuestConstants.DEFAULT_PAGE;
                }
            } catch (NumberFormatException e) {
                // Nếu parse thất bại, dùng giá trị mặc định
                page = GuestConstants.DEFAULT_PAGE;
            }
        }

        // Tạo MovieDAO để query database
        MovieDAO dao = new MovieDAO();
        List<Movie> movies;
        int totalRecords;
        int totalPages;

        // Bước 3: Query database để lấy danh sách phim
        if (status != null && !status.isEmpty()) {
            // Có status parameter: Lọc theo trạng thái cụ thể
            // Ví dụ: status="Active" → chỉ lấy phim Active
            movies = dao.getMoviesByStatus(status, keyword);
            totalRecords = movies.size();
        } else {
            // Không có status parameter: Lấy tất cả phim Active và Upcoming
            // Đây là danh sách phim dành cho khách (không cần đăng nhập)
            movies = dao.getActiveMoviesForGuest(keyword);
            totalRecords = movies.size();
        }

        // Bước 4: Tính toán pagination
        // Tính tổng số trang: làm tròn lên (ceil)
        // Ví dụ: 25 phim, 12 phim/trang → 3 trang (25/12 = 2.08 → ceil = 3)
        totalPages = (int) Math.ceil(totalRecords / (double) recordsPerPage);

        // Tính startIndex và endIndex để lấy subset phim cho trang hiện tại
        // Ví dụ: page=2, recordsPerPage=12 → startIndex=12, endIndex=24
        int startIndex = (page - 1) * recordsPerPage;
        int endIndex = Math.min(startIndex + recordsPerPage, movies.size());
        
        // Bước 5: Cắt danh sách phim theo pagination
        // Chỉ lấy các phim từ startIndex đến endIndex
        if (startIndex < movies.size()) {
            movies = movies.subList(startIndex, endIndex);
        }

        // Bước 6: Gửi dữ liệu đến JSP để hiển thị
        request.setAttribute("movies", movies);           // Danh sách phim cho trang hiện tại
        request.setAttribute("currentPage", page);        // Số trang hiện tại
        request.setAttribute("totalPages", totalPages);   // Tổng số trang
        request.setAttribute("status", status);           // Trạng thái filter (để giữ lại khi chuyển trang)
        request.setAttribute("keyword", keyword);         // Keyword search (để giữ lại khi chuyển trang)

        // Forward đến trang JSP để hiển thị danh sách phim
        request.getRequestDispatcher(GuestConstants.JSP_GUEST_MOVIES).forward(request, response);
    }
}

