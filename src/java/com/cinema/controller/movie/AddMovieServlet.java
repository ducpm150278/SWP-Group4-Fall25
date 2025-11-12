package com.cinema.controller.movie;


import com.cinema.dal.MovieDAO;
import com.cinema.entity.Language;
import com.cinema.utils.Constants;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 *
 * @author admin
 */
@WebServlet(name = "AddMovieServlet", urlPatterns = {"/add"})
public class AddMovieServlet extends HttpServlet {

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
            out.println("<title>Servlet AddMovieServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet AddMovieServlet at " + request.getContextPath() + "</h1>");
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
        MovieDAO mvd = new MovieDAO();
        List<Language> listLanguage = mvd.getAllLanguages();
        request.setAttribute("listLanguage", listLanguage);
        request.getRequestDispatcher(Constants.JSP_MOVIE_ADD).forward(request, response);
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
        // Lấy dữ liệu từ form
        String title = request.getParameter("title");
        String genre = request.getParameter("genre");
        String summary = request.getParameter("summary");
        String trailerURL = request.getParameter("trailerURL");
        String cast = request.getParameter("cast");
        String director = request.getParameter("director");
        String durationStr = request.getParameter("duration");
        String releasedDateStr = request.getParameter("releasedDate");
        String endDateStr = request.getParameter("endDate");
        String posterURL = request.getParameter("posterURL");
        String status = request.getParameter("status");
        String languageID = request.getParameter("languageName");

        // Giữ lại dữ liệu người dùng nhập (để không bị mất form khi lỗi)
        request.setAttribute("title", title);
        request.setAttribute("genre", genre);
        request.setAttribute("summary", summary);
        request.setAttribute("trailerURL", trailerURL);
        request.setAttribute("cast", cast);
        request.setAttribute("director", director);
        request.setAttribute("duration", durationStr);
        request.setAttribute("releasedDate", releasedDateStr);
        request.setAttribute("endDate", endDateStr);
        request.setAttribute("posterURL", posterURL);
        request.setAttribute("status", status);
        request.setAttribute("selectedLanguage", languageID);

        Map<String, String> errors = new HashMap<>();

        // ✅ Kiểm tra rỗng và độ dài chuỗi
        if (title == null || title.trim().isEmpty()) {
            errors.put("errorTitle", "Tiêu đề không được để trống!");
        } else if (title.length() > 100) {
            errors.put("errorTitle", "Tiêu đề không được vượt quá 100 ký tự!");
        }

        if (genre == null || genre.trim().isEmpty()) {
            errors.put("errorGenre", "Thể loại không được để trống!");
        } else if (genre.length() > 100) {
            errors.put("errorGenre", "Thể loại không được vượt quá 100 ký tự!");
        }

        if (director == null || director.trim().isEmpty()) {
            errors.put("errorDirector", "Đạo diễn không được để trống!");
        } else if (director.length() > 100) {
            errors.put("errorDirector", "Tên đạo diễn không được vượt quá 100 ký tự!");
        }

        if (cast == null || cast.trim().isEmpty()) {
            errors.put("errorCast", "Dàn diễn viên không được để trống!");
        } else if (cast.length() > 255) {
            errors.put("errorCast", "Dàn diễn viên không được vượt quá 255 ký tự!");
        }

        if (posterURL == null || posterURL.trim().isEmpty()) {
            errors.put("errorPoster", "Poster URL không được để trống!");
        } else if (posterURL.length() > 255) {
            errors.put("errorPoster", "Poster URL không được vượt quá 255 ký tự!");
        }

        if (trailerURL == null || trailerURL.trim().isEmpty()) {
            errors.put("errorTrailer", "Trailer URL không được để trống!");
        } else if (trailerURL.length() > 200) {
            errors.put("errorTrailer", "Trailer URL không được vượt quá 200 ký tự!");
        }

        if (summary == null || summary.trim().isEmpty()) {
            errors.put("errorSummary", "Tóm tắt phim không được để trống!");
        } else if (summary.length() > 500) {
            errors.put("errorSummary", "Tóm tắt phim không được vượt quá 500 ký tự!");
        }

        // ✅ Kiểm tra thời lượng
        int duration = Integer.parseInt(durationStr);
        if (duration <= 0) {
            errors.put("errorDuration", "Thời lượng phim phải lớn hơn 0!");
        }

        // ✅ Kiểm tra ngày
        LocalDate releasedDate = LocalDate.parse(releasedDateStr);
        LocalDate endDate = LocalDate.parse(endDateStr);
        if (!endDate.isAfter(releasedDate)) {
            errors.put("errorDate", "Ngày kết thúc phải sau ngày công chiếu!");
        }

        // Nếu có lỗi thì quay lại form
        if (!errors.isEmpty()) {
            request.setAttribute("errors", errors);
            MovieDAO mvd = new MovieDAO();
            List<Language> listLanguage = mvd.getAllLanguages();
            request.setAttribute("listLanguage", listLanguage);
            request.getRequestDispatcher(Constants.JSP_MOVIE_ADD).forward(request, response);
            return;
        }

        // ✅ Lưu vào DB
        int languageId = Integer.parseInt(languageID);
        MovieDAO dao = new MovieDAO();
        dao.addMovie(title, genre, summary, trailerURL, cast, director,
                duration, releasedDate, endDate, posterURL, languageId, status);

        // Thành công → redirect về danh sách
        response.sendRedirect("list?addSuccess=1");

    } catch (Exception e) {
        e.printStackTrace();
        request.setAttribute("error", "Có lỗi khi thêm phim!");
        MovieDAO mvd = new MovieDAO();
        List<Language> listLanguage = mvd.getAllLanguages();
        request.setAttribute("listLanguage", listLanguage);
        request.getRequestDispatcher(Constants.JSP_MOVIE_ADD).forward(request, response);
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
