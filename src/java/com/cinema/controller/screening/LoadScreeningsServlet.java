package com.cinema.controller.screening;


import com.cinema.dal.ScreeningDAO;
import com.cinema.entity.Screening;
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
 * Servlet AJAX để tải các suất chiếu có sẵn dựa trên rạp, phim và ngày
 */
@WebServlet(name = "LoadScreeningsServlet", urlPatterns = {"/api/load-screenings"})
public class LoadScreeningsServlet extends HttpServlet {
    
    private ScreeningDAO screeningDAO;
    
    @Override
    public void init() throws ServletException {
        screeningDAO = new ScreeningDAO();
    }
    
    /**
     * Xử lý request GET - AJAX endpoint để tải danh sách suất chiếu
     * Flow: Validate parameters -> Parse parameters -> Lấy screenings -> Build JSON response -> Trả về
     * 
     * Được gọi từ frontend khi người dùng chọn rạp, phim hoặc ngày
     * Trả về JSON chứa danh sách suất chiếu có sẵn
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Set content type cho JSON response
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        try {
            // Bước 1: Lấy các parameters từ request
            String cinemaIDStr = request.getParameter("cinemaID");  // ID rạp
            String movieIDStr = request.getParameter("movieID");    // ID phim
            String dateStr = request.getParameter("date");          // Ngày (format: YYYY-MM-DD)
            
            // Bước 2: Validate các parameters bắt buộc
            // Tất cả 3 parameters đều bắt buộc và không được rỗng
            if (isBlank(cinemaIDStr) || isBlank(movieIDStr) || 
                isBlank(dateStr) || dateStr.equals("--") || dateStr.equals("null")) {
                
                // Thiếu hoặc invalid parameters - trả về JSON error
                out.print("{\"success\":false,\"message\":\"Missing or invalid required parameters\"}");
                return;
            }
            
            // Bước 3: Validate format của date
            // Date phải có format YYYY-MM-DD (ví dụ: 2024-12-25)
            if (!dateStr.matches("\\d{4}-\\d{2}-\\d{2}")) {
                out.print("{\"success\":false,\"message\":\"Invalid date format. Expected YYYY-MM-DD\"}");
                return;
            }
            
            // Bước 4: Parse các parameters sang kiểu dữ liệu phù hợp
            int cinemaID = Integer.parseInt(cinemaIDStr);
            int movieID = Integer.parseInt(movieIDStr);
            
            // Bước 5: Parse date string sang LocalDate
            LocalDate date;
            try {
                date = LocalDate.parse(dateStr);
            } catch (Exception e) {
                // Date không parse được - trả về error
                out.print("{\"success\":false,\"message\":\"Invalid date format: " + dateStr + "\"}");
                return;
            }
            
            // Bước 6: Lấy danh sách suất chiếu có sẵn từ database
            // Chỉ lấy các suất chiếu có available seats > 0 và chưa bắt đầu
            List<Screening> screenings = screeningDAO.getAvailableScreenings(cinemaID, movieID, date);
            
            // Bước 7: Xây dựng JSON response thủ công
            // Format: {"success":true,"screenings":[{...},{...}]}
            StringBuilder json = new StringBuilder();
            json.append("{\"success\":true,\"screenings\":[");
            
            // Formatter để format thời gian (HH:mm)
            DateTimeFormatter timeFormatter = DateTimeFormatter.ofPattern("HH:mm");
            
            // Bước 8: Duyệt qua từng screening và thêm vào JSON
            for (int i = 0; i < screenings.size(); i++) {
                Screening screening = screenings.get(i);
                
                // Bỏ qua screenings có startTime null (lỗi parse từ database)
                if (screening.getStartTime() == null) {
                    continue;
                }
                
                // Thêm dấu phẩy trước mỗi object (trừ object đầu tiên)
                if (i > 0) json.append(",");
                
                // Bắt đầu object screening
                json.append("{");
                json.append("\"screeningID\":").append(screening.getScreeningID()).append(",");
                json.append("\"startTime\":\"").append(screening.getStartTime().format(timeFormatter)).append("\",");
                
                // EndTime có thể null - xử lý tương ứng
                if (screening.getEndTime() != null) {
                    json.append("\"endTime\":\"").append(screening.getEndTime().format(timeFormatter)).append("\",");
                } else {
                    json.append("\"endTime\":null,");
                }
                
                json.append("\"ticketPrice\":").append(screening.getTicketPrice()).append(",");
                json.append("\"availableSeats\":").append(screening.getAvailableSeats()).append(",");
                json.append("\"roomName\":\"").append(escapeJson(screening.getRoomName())).append("\"");
                json.append("}");
            }
            
            // Đóng mảng screenings và object JSON
            json.append("]}");
            
            // Bước 9: Gửi JSON response về frontend
            out.print(json.toString());
            
        } catch (NumberFormatException e) {
            // Xử lý lỗi khi parse số (cinemaID hoặc movieID không phải số)
            out.print("{\"success\":false,\"message\":\"Invalid parameter format\"}");
        } catch (Exception e) {
            // Xử lý các lỗi khác (database, v.v.)
            out.print("{\"success\":false,\"message\":\"Server error\"}");
        } finally {
            // Đảm bảo flush output stream
            out.flush();
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
     * Escape các ký tự đặc biệt trong JSON
     * Các ký tự cần escape: \, ", \n, \r, \t
     * @param str Chuỗi cần escape
     * @return Chuỗi đã được escape, hoặc chuỗi rỗng nếu str là null
     */
    private String escapeJson(String str) {
        if (str == null) return "";
        // Escape các ký tự đặc biệt để đảm bảo JSON hợp lệ
        return str.replace("\\", "\\\\")    // Escape backslash
                  .replace("\"", "\\\"")     // Escape double quote
                  .replace("\n", "\\n")      // Escape newline
                  .replace("\r", "\\r")      // Escape carriage return
                  .replace("\t", "\\t");     // Escape tab
    }
}

