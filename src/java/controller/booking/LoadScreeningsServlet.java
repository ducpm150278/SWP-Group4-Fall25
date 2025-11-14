package controller.booking;

import dal.ScreeningDAO;
import entity.Screening;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;

/**
 * AJAX servlet để load danh sách suất chiếu có sẵn dựa trên rạp, phim và ngày
 * 
 * Flow tổng quan:
 * 1. Frontend gọi AJAX request với parameters: cinemaID, movieID, date
 * 2. Validate các parameters (không được null, date phải đúng format YYYY-MM-DD)
 * 3. Parse parameters sang integer và LocalDate
 * 4. Query database để lấy danh sách suất chiếu có sẵn
 * 5. Xây dựng JSON response chứa thông tin suất chiếu:
 *    - screeningID: ID suất chiếu
 *    - startTime: Giờ bắt đầu (format HH:mm)
 *    - endTime: Giờ kết thúc (format HH:mm, có thể null)
 *    - ticketPrice: Giá vé
 *    - availableSeats: Số ghế còn trống
 *    - roomName: Tên phòng chiếu
 * 6. Trả về JSON response cho frontend
 * 
 * Mục đích: Cung cấp endpoint AJAX để frontend load động danh sách suất chiếu
 * khi người dùng thay đổi rạp, phim hoặc ngày trong form đặt vé (Bước 1).
 * 
 * Endpoint: /api/load-screenings
 */
@WebServlet(name = "LoadScreeningsServlet", urlPatterns = {"/api/load-screenings"})
public class LoadScreeningsServlet extends HttpServlet {
    
    /** DAO để thao tác với dữ liệu suất chiếu */
    private ScreeningDAO screeningDAO;
    
    /**
     * Khởi tạo servlet - tạo ScreeningDAO instance
     */
    @Override
    public void init() throws ServletException {
        screeningDAO = new ScreeningDAO();
    }
    
    /**
     * Xử lý AJAX request GET để load danh sách suất chiếu
     * 
     * Flow xử lý:
     * Bước 1: Lấy parameters từ request (cinemaID, movieID, date)
     * Bước 2: Validate parameters (không được null, date phải đúng format)
     * Bước 3: Parse cinemaID và movieID sang integer
     * Bước 4: Parse date sang LocalDate
     * Bước 5: Query database để lấy danh sách suất chiếu có sẵn
     * Bước 6: Xây dựng JSON response thủ công
     * Bước 7: Trả về JSON response cho frontend
     * 
     * JSON Response format:
     * {
     *   "success": true,
     *   "screenings": [
     *     {
     *       "screeningID": 1,
     *       "startTime": "14:00",
     *       "endTime": "16:30",
     *       "ticketPrice": 100000,
     *       "availableSeats": 50,
     *       "roomName": "Phòng 1"
     *     },
     *     ...
     *   ]
     * }
     * 
     * @param request HTTP request chứa parameters: cinemaID, movieID, date
     * @param response HTTP response để trả về JSON
     * @throws ServletException nếu có lỗi servlet
     * @throws IOException nếu có lỗi I/O
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Thiết lập content type là JSON
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        try {
            // Bước 1: Lấy parameters từ request
            String cinemaIDStr = request.getParameter("cinemaID");
            String movieIDStr = request.getParameter("movieID");
            String dateStr = request.getParameter("date");
            
            // Bước 2: Validate parameters
            // Kiểm tra các parameters không được null hoặc rỗng
            // date không được là "--" hoặc "null" (giá trị mặc định từ frontend)
            if (cinemaIDStr == null || cinemaIDStr.isEmpty() ||
                movieIDStr == null || movieIDStr.isEmpty() ||
                dateStr == null || dateStr.isEmpty() || 
                dateStr.trim().isEmpty() || dateStr.equals("--") || dateStr.equals("null")) {
                
                // Trả về JSON error nếu thiếu parameters
                out.print("{\"success\":false,\"message\":\"Missing or invalid required parameters\"}");
                return;
            }
            
            // Validate date format (phải là YYYY-MM-DD)
            if (!dateStr.matches("\\d{4}-\\d{2}-\\d{2}")) {
                out.print("{\"success\":false,\"message\":\"Invalid date format. Expected YYYY-MM-DD\"}");
                return;
            }
            
            // Bước 3: Parse cinemaID và movieID sang integer
            int cinemaID = Integer.parseInt(cinemaIDStr);
            int movieID = Integer.parseInt(movieIDStr);
            
            // Bước 4: Parse date sang LocalDate
            LocalDate date;
            try {
                date = LocalDate.parse(dateStr);
            } catch (Exception e) {
                // Date không hợp lệ
                out.print("{\"success\":false,\"message\":\"Invalid date format: " + dateStr + "\"}");
                return;
            }
            
            // Bước 5: Query database để lấy danh sách suất chiếu có sẵn
            // Chỉ lấy các suất chiếu:
            // - Của rạp được chọn (cinemaID)
            // - Của phim được chọn (movieID)
            // - Vào ngày được chọn (date)
            // - Còn ghế trống (availableSeats > 0)
            List<Screening> screenings = screeningDAO.getAvailableScreenings(cinemaID, movieID, date);
            
            // Bước 6: Xây dựng JSON response thủ công
            StringBuilder json = new StringBuilder();
            json.append("{\"success\":true,\"screenings\":[");
            
            // Formatter để format thời gian thành HH:mm
            DateTimeFormatter timeFormatter = DateTimeFormatter.ofPattern("HH:mm");
            
            // Duyệt qua từng suất chiếu và thêm vào JSON
            for (int i = 0; i < screenings.size(); i++) {
                Screening screening = screenings.get(i);
                
                // Bỏ qua suất chiếu có startTime null (lỗi parse từ database)
                if (screening.getStartTime() == null) {
                    continue;
                }
                
                // Thêm dấu phẩy giữa các phần tử (trừ phần tử đầu tiên)
                if (i > 0) json.append(",");
                
                // Xây dựng JSON object cho mỗi suất chiếu
                json.append("{");
                json.append("\"screeningID\":").append(screening.getScreeningID()).append(",");
                json.append("\"startTime\":\"").append(screening.getStartTime().format(timeFormatter)).append("\",");
                
                // endTime có thể null
                if (screening.getEndTime() != null) {
                    json.append("\"endTime\":\"").append(screening.getEndTime().format(timeFormatter)).append("\",");
                } else {
                    json.append("\"endTime\":null,");
                }
                
                json.append("\"ticketPrice\":").append(screening.getTicketPrice()).append(",");
                json.append("\"availableSeats\":").append(screening.getAvailableSeats()).append(",");
                // Escape ký tự đặc biệt trong roomName để tránh lỗi JSON
                json.append("\"roomName\":\"").append(escapeJson(screening.getRoomName())).append("\"");
                json.append("}");
            }
            
            json.append("]}");
            
            // Bước 7: Trả về JSON response cho frontend
            out.print(json.toString());
            
        } catch (NumberFormatException e) {
            // Xử lý lỗi khi parse integer không thành công
            out.print("{\"success\":false,\"message\":\"Invalid parameter format\"}");
        } catch (Exception e) {
            // Xử lý các lỗi khác
            e.printStackTrace();
            out.print("{\"success\":false,\"message\":\"Server error\"}");
        } finally {
            // Đảm bảo flush output stream
            out.flush();
        }
    }
    
    /**
     * Escape các ký tự đặc biệt trong chuỗi để đảm bảo JSON hợp lệ
     * 
     * Các ký tự cần escape:
     * - Backslash (\) → \\
     * - Double quote (") → \"
     * - Newline (\n) → \n
     * - Carriage return (\r) → \r
     * - Tab (\t) → \t
     * 
     * @param str Chuỗi cần escape
     * @return Chuỗi đã được escape, hoặc chuỗi rỗng nếu str là null
     */
    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")    // Escape backslash trước (quan trọng!)
                  .replace("\"", "\\\"")    // Escape double quote
                  .replace("\n", "\\n")     // Escape newline
                  .replace("\r", "\\r")     // Escape carriage return
                  .replace("\t", "\\t");    // Escape tab
    }
}

