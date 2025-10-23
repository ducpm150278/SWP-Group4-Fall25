/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dal.MovieDAO;
import entity.Language;
import entity.Movie;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.time.LocalDate;
import java.util.List;

/**
 *
 * @author admin
 */
@WebServlet(name = "EditMovieServlet", urlPatterns = {"/edit"})
public class EditMovieServlet extends HttpServlet {

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
            out.println("<title>Servlet EditMovieServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet EditMovieServlet at " + request.getContextPath() + "</h1>");
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
            int movieID = Integer.parseInt(request.getParameter("movieID"));
            MovieDAO dao = new MovieDAO();
            Movie m = dao.getMovieById(movieID); // tạo thêm getMovieById trong DAO
            List<Language> listLanguage = dao.getAllLanguages();

            if (m != null) {
                request.setAttribute("movie", m);
                request.setAttribute("listLanguage", listLanguage);
                request.getRequestDispatcher("editMovie.jsp").forward(request, response);
            } else {
                response.sendRedirect("list");
            }
        } catch (NumberFormatException e) {
            System.out.println("MovieID không hợp lệ: " + e.getMessage());
            response.sendRedirect("list");
        }
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

        try {
            // Lấy dữ liệu
            int movieID = Integer.parseInt(request.getParameter("movieID"));
            String title = request.getParameter("title");
            String genre = request.getParameter("genre");
            String summary = request.getParameter("summary");
            String trailerURL = request.getParameter("trailerURL");
            String cast = request.getParameter("cast");
            String director = request.getParameter("director");
            String durationStr = request.getParameter("duration");
            String languageID = request.getParameter("languageName");
            String releasedDateStr = request.getParameter("releasedDate");
            String posterURL = request.getParameter("posterURL");
            String status = request.getParameter("status");

            // Gán lại dữ liệu để giữ form khi có lỗi
            request.setAttribute("title", title);
            request.setAttribute("genre", genre);
            request.setAttribute("summary", summary);
            request.setAttribute("trailerURL", trailerURL);
            request.setAttribute("cast", cast);
            request.setAttribute("director", director);
            request.setAttribute("duration", durationStr);
            request.setAttribute("releasedDate", releasedDateStr);
            request.setAttribute("posterURL", posterURL);
            request.setAttribute("status", status);
            request.setAttribute("selectedLanguage", languageID);

            int duration = Integer.parseInt(durationStr);

            // ⚠️ Kiểm tra điều kiện thời lượng > 0
            if (duration <= 0) {
                request.setAttribute("errorDuration", "Thời lượng phim phải lớn hơn 0!");
                MovieDAO dao = new MovieDAO();
                Movie m = dao.getMovieById(movieID);
                List<Language> listLanguage = dao.getAllLanguages();

                request.setAttribute("movie", m);
                request.setAttribute("listLanguage", listLanguage);
                request.getRequestDispatcher("editMovie.jsp").forward(request, response);
                return;
            }

            int languageId = Integer.parseInt(languageID);
            LocalDate releasedDate = LocalDate.parse(releasedDateStr);

            // Gọi DAO để cập nhật
            MovieDAO dao = new MovieDAO();
            dao.updateMovie(movieID, title, genre, summary, trailerURL, cast, director,
                    duration, releasedDate, posterURL, status, languageId);

            // ✅ Thành công
            response.sendRedirect("list?updateSuccess=1");

        } catch (Exception e) {
            System.out.println("Lỗi khi update phim!");
            request.setAttribute("error", "Có lỗi khi cập nhật phim!");
            MovieDAO dao = new MovieDAO();
            List<Language> listLanguage = dao.getAllLanguages();
            request.setAttribute("listLanguage", listLanguage);
            request.getRequestDispatcher("editMovie.jsp").forward(request, response);
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
