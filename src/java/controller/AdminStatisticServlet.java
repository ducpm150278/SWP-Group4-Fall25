package controller;

import com.google.gson.Gson; 
import dal.StatisticDAO;
import dal.CinemaDAO;
import dal.MovieDAO;
import entity.AdminDashboardStatsDTO;
import entity.ChartDataDTO;
import entity.TopItemDTO;
import entity.Movie;
import entity.Cinema;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

@WebServlet(name = "AdminStatisticServlet", urlPatterns = {"/admin-statistic"})
public class AdminStatisticServlet extends HttpServlet {

    private StatisticDAO statisticDAO;
    private MovieDAO movieDAO;
    private CinemaDAO cinemaDAO;
    private Gson gson = new Gson();

    @Override
    public void init() throws ServletException {
        statisticDAO = new StatisticDAO();
        movieDAO = new MovieDAO();
        cinemaDAO = new CinemaDAO(); 
    }

// (Trong file controller/AdminStatisticServlet.java)
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setAttribute("activePage", "admin-statistic");
        
        String fromStr = request.getParameter("from");
        String toStr = request.getParameter("to");
        String movieIdStr = request.getParameter("movieId");
        String cinemaIdStr = request.getParameter("cinemaId");

        LocalDate to, from;
        int movieId = 0;
        int cinemaId = 0;

        try {
            to = (toStr == null || toStr.isEmpty()) ? LocalDate.now() : LocalDate.parse(toStr);
            from = (fromStr == null || fromStr.isEmpty()) ? to.minusDays(6) : LocalDate.parse(fromStr);
            
            if (movieIdStr != null && !movieIdStr.isEmpty()) movieId = Integer.parseInt(movieIdStr);
            if (cinemaIdStr != null && !cinemaIdStr.isEmpty()) cinemaId = Integer.parseInt(cinemaIdStr);
            
        } catch (Exception e) {
            to = LocalDate.now();
            from = to.minusDays(6);
        }

        
        AdminDashboardStatsDTO stats = statisticDAO.getDashboardStats();
        request.setAttribute("stats", stats);

        List<ChartDataDTO> chartData = statisticDAO.getRevenueOverTime(from, to, movieId, cinemaId);
        String chartDataJson = this.gson.toJson(chartData);
        request.setAttribute("chartDataJson", chartDataJson);


        List<TopItemDTO> topMovies = statisticDAO.getTopMovies_AllTime();
        List<TopItemDTO> topCinemas = statisticDAO.getTopCinemas_AllTime();
        
        request.setAttribute("topMovies", topMovies);
        request.setAttribute("topCinemas", topCinemas);
        // ==========================================================

        List<Movie> filterMovies = movieDAO.getAllActiveMovies(); 
        List<Cinema> filterCinemas = cinemaDAO.getAllCinemas(); 
        
        request.setAttribute("filterMovies", filterMovies);
        request.setAttribute("filterCinemas", filterCinemas);
        
        request.setAttribute("selectedFrom", from.toString());
        request.setAttribute("selectedTo", to.toString());
        request.setAttribute("selectedMovieId", movieId);
        request.setAttribute("selectedCinemaId", cinemaId);
        
        request.getRequestDispatcher("admin-statistic.jsp").forward(request, response);
    }
}