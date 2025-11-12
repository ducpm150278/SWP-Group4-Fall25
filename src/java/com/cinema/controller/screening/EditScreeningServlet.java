package com.cinema.controller.screening;



import com.cinema.dal.CinemaDAO;
import com.cinema.dal.MovieDAO;
import com.cinema.dal.ScreeningDAO;
import com.cinema.dal.ScreeningRoomDAO;
import com.cinema.entity.Cinema;
import com.cinema.entity.Movie;
import com.cinema.entity.Screening;
import com.cinema.entity.ScreeningRoom;
import com.cinema.utils.Constants;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Arrays;
import java.util.List;

/**
 *
 * @author admin
 */
@WebServlet(name = "EditScreeningServlet", urlPatterns = {"/editScreening"})
public class EditScreeningServlet extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet EditScreeningServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet EditScreeningServlet at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String idStr = request.getParameter("screeningID");
            if (idStr == null || idStr.isEmpty()) {
                response.sendRedirect(request.getContextPath() + Constants.URL_LIST_SCREENING);
                return;
            }

            int screeningID = Integer.parseInt(idStr);

            ScreeningDAO sdao = new ScreeningDAO();
            Screening screening = sdao.getScreeningDetails(screeningID);
            System.out.println(screening.getFormattedScreeningDate());

            if (screening == null) {
                response.sendRedirect(request.getContextPath() + Constants.URL_LIST_SCREENING);
                return;
            }

            // ✅ Lấy danh sách phim
            MovieDAO mdao = new MovieDAO();
            List<Movie> movies = mdao.getAll();

            // ✅ Lấy danh sách rạp
            CinemaDAO cdao = new CinemaDAO();
            List<Cinema> cinemas = cdao.getCinemas();

            // ✅ Lấy danh sách phòng
            ScreeningRoomDAO rdao = new ScreeningRoomDAO();
            List<ScreeningRoom> rooms = rdao.getAllRooms();

            // ✅ Gửi dữ liệu sang JSP
            request.setAttribute("screening", screening);
            request.setAttribute("movies", movies);
            request.setAttribute("cinemas", cinemas);
            request.setAttribute("rooms", rooms);
            List<String> showtimes = Arrays.asList(
                    "08:00-10:00", "10:15-12:15", "12:30-14:30",
                    "14:45-16:45", "17:00-19:00", "19:15-21:15", "21:30-23:30"
            );
            request.setAttribute("showtimes", showtimes);

            request.getRequestDispatcher(Constants.JSP_SCREENING_EDIT).forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + Constants.URL_LIST_SCREENING);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            request.setCharacterEncoding("UTF-8");

            int screeningID = Integer.parseInt(request.getParameter("screeningID"));
            int movieID = Integer.parseInt(request.getParameter("movieID"));
            int roomID = Integer.parseInt(request.getParameter("roomID"));
            String dateStr = request.getParameter("screeningDate");
            String showtime = request.getParameter("showtime");
            String status = request.getParameter("status");
            double baseTicketPrice = 0;
            String priceStr = request.getParameter("baseTicketPrice");
            if (priceStr != null && !priceStr.isBlank()) {
                baseTicketPrice = Double.parseDouble(priceStr);
            }
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
            LocalDate screeningDate = LocalDate.parse(dateStr, formatter);

            ScreeningDAO dao = new ScreeningDAO();

            boolean updated = dao.updateScreening(screeningID, movieID, roomID, screeningDate, showtime, baseTicketPrice);
            response.sendRedirect(request.getContextPath() + Constants.URL_LIST_SCREENING + "?success=1");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + Constants.URL_LIST_SCREENING + "?error=1");
        }
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
