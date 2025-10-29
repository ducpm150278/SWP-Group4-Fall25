package controller;

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
 * AJAX servlet to load available screenings based on cinema, movie, and date
 */
@WebServlet(name = "LoadScreeningsServlet", urlPatterns = {"/api/load-screenings"})
public class LoadScreeningsServlet extends HttpServlet {
    
    private ScreeningDAO screeningDAO;
    
    @Override
    public void init() throws ServletException {
        screeningDAO = new ScreeningDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        try {
            // Get parameters
            String cinemaIDStr = request.getParameter("cinemaID");
            String movieIDStr = request.getParameter("movieID");
            String dateStr = request.getParameter("date");
            
            // Validate parameters
            if (cinemaIDStr == null || cinemaIDStr.isEmpty() ||
                movieIDStr == null || movieIDStr.isEmpty() ||
                dateStr == null || dateStr.isEmpty()) {
                
                out.print("{\"success\":false,\"message\":\"Missing required parameters\"}");
                return;
            }
            
            int cinemaID = Integer.parseInt(cinemaIDStr);
            int movieID = Integer.parseInt(movieIDStr);
            LocalDate date = LocalDate.parse(dateStr);
            
            // Get available screenings
            List<Screening> screenings = screeningDAO.getAvailableScreenings(cinemaID, movieID, date);
            
            // Build JSON response
            StringBuilder json = new StringBuilder();
            json.append("{\"success\":true,\"screenings\":[");
            
            DateTimeFormatter timeFormatter = DateTimeFormatter.ofPattern("HH:mm");
            
            for (int i = 0; i < screenings.size(); i++) {
                Screening screening = screenings.get(i);
                if (i > 0) json.append(",");
                
                json.append("{");
                json.append("\"screeningID\":").append(screening.getScreeningID()).append(",");
                json.append("\"startTime\":\"").append(screening.getStartTime().format(timeFormatter)).append("\",");
                json.append("\"ticketPrice\":").append(screening.getTicketPrice()).append(",");
                json.append("\"availableSeats\":").append(screening.getAvailableSeats()).append(",");
                json.append("\"roomName\":\"").append(escapeJson(screening.getRoomName())).append("\"");
                json.append("}");
            }
            
            json.append("]}");
            
            out.print(json.toString());
            
        } catch (NumberFormatException e) {
            out.print("{\"success\":false,\"message\":\"Invalid parameter format\"}");
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\":false,\"message\":\"Server error\"}");
        } finally {
            out.flush();
        }
    }
    
    /**
     * Escape special characters for JSON
     */
    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\n", "\\n")
                  .replace("\r", "\\r")
                  .replace("\t", "\\t");
    }
}

