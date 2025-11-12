package com.cinema.controller.movie;




import com.cinema.dal.MovieDAO;
import com.cinema.entity.Movie;
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
import java.util.List;

/**
 *
 * @author admin
 */
@WebServlet(name="ListMovieServlet", urlPatterns={"/list"})
public class ListMovieServlet extends HttpServlet {
   
    /** 
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code> methods.
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
            out.println("<title>Servlet ListMovieServlet</title>");  
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet ListMovieServlet at " + request.getContextPath () + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    } 

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /** 
     * Handles the HTTP <code>GET</code> method.
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String keyword = request.getParameter("keyword");
        String fromStr = request.getParameter("from");
        String toStr = request.getParameter("to");
        String status = request.getParameter("status");
        LocalDate from = null, to = null;
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("yyyy-MM-dd");

        int page = 1;
        int recordsPerPage = 6;

        // Lấy trang hiện tại (nếu có)
        String pageParam = request.getParameter("page");
        if (pageParam != null) {
            try {
                page = Integer.parseInt(pageParam);
            } catch (NumberFormatException e) {
                page = 1;
            }
        }
        try {
            if (fromStr != null && !fromStr.isEmpty()) {
                from = LocalDate.parse(fromStr, fmt);
            }
            if (toStr != null && !toStr.isEmpty()) {
                to = LocalDate.parse(toStr, fmt);
            }
        } catch (Exception e) {
            System.out.println("Error parsing date: " + e.getMessage());
        }

        MovieDAO dao = new MovieDAO();

        int totalRecords = dao.getTotalMovies(keyword, from, to, status);
        int totalPages = (int) Math.ceil(totalRecords / (double) recordsPerPage);

        int offset = (page - 1) * recordsPerPage;

        List<Movie> movies = dao.getMoviesPaginated(offset, offset, keyword, from, to, status);

        // Gửi dữ liệu sang JSP
        request.setAttribute("movies", movies);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("keyword", keyword);
        request.setAttribute("from", fromStr);
        request.setAttribute("to", toStr);
        request.setAttribute("status", status);

        request.getRequestDispatcher(Constants.JSP_MOVIE_LIST).forward(request, response);
    }


    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /** 
     * Returns a short description of the servlet.
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}