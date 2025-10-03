/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller;

import dal.MovieDAO;
import entity.Language;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

/**
 *
 * @author admin
 */
@WebServlet(name="AddMovieServlet", urlPatterns={"/add"})
public class AddMovieServlet extends HttpServlet {
   
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
            out.println("<title>Servlet AddMovieServlet</title>");  
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet AddMovieServlet at " + request.getContextPath () + "</h1>");
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
        MovieDAO mvd = new MovieDAO();
        List<Language> listLanguage = mvd.getAllLanguages();
        request.setAttribute("listLanguage", listLanguage);
        request.getRequestDispatcher("addMovie.jsp").forward(request, response);
    } 

    /** 
     * Handles the HTTP <code>POST</code> method.
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
        int duration = Integer.parseInt(request.getParameter("duration"));
        String releasedDateStr = request.getParameter("releasedDate");
        String posterURL = request.getParameter("posterURL");
        String status = request.getParameter("status");
        String languageID = request.getParameter("languageName");
        int languageId = Integer.parseInt(languageID);
        System.out.println("languageID" +languageId);
        LocalDate releasedDate = LocalDate.parse(releasedDateStr);
        LocalDateTime createdDate = LocalDateTime.now();


        // Gọi DAO
        MovieDAO dao = new MovieDAO();
        dao.addMovie(title, genre, summary, trailerURL, cast, director, duration, releasedDate, posterURL, languageId, status, createdDate);

        // Chuyển về danh sách
        response.sendRedirect("list");

    } catch (Exception e) {
        System.out.println("Lỗi khi thêm phim: " + e.getMessage());
        request.setAttribute("error", "Có lỗi khi thêm phim!");
        request.getRequestDispatcher("addMovie.jsp").forward(request, response);
    }
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
