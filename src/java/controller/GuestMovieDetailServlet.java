/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

import dal.MovieDAO;
import dal.ReviewDAO;
import entity.Movie;
import entity.Review;
import java.util.List;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 *
 * @author admin
 */
@WebServlet(name="GuestMovieDetailServlet", urlPatterns={"/guest-movie-detail"})
public class GuestMovieDetailServlet extends HttpServlet {
   
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
            out.println("<title>Servlet GuestMovieDetailServlet</title>");  
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet GuestMovieDetailServlet at " + request.getContextPath () + "</h1>");
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
        String movieIDStr = request.getParameter("id");
        
        if (movieIDStr == null || movieIDStr.trim().isEmpty()) {
            response.sendRedirect("guest-movies");
            return;
        }
        
        try {
            int movieID = Integer.parseInt(movieIDStr);
            MovieDAO movieDAO = new MovieDAO();
            ReviewDAO reviewDAO = new ReviewDAO();
            
            Movie movie = movieDAO.getMovieById(movieID);
            
            if (movie == null) {
                response.sendRedirect("guest-movies");
                return;
            }
            
            // Only show active or upcoming movies to guests
            if (!"Active".equals(movie.getStatus()) && !"Upcoming".equals(movie.getStatus())) {
                response.sendRedirect("guest-movies");
                return;
            }
            
            // Get reviews for this movie
            List<Review> reviews = reviewDAO.getReviewsByMovieID(movieID);
            double averageRating = reviewDAO.getAverageRating(movieID);
            int totalReviews = reviewDAO.getTotalReviews(movieID);
            
            request.setAttribute("movie", movie);
            request.setAttribute("reviews", reviews);
            request.setAttribute("averageRating", averageRating);
            request.setAttribute("totalReviews", totalReviews);
            request.getRequestDispatcher("guest-movie-detail.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendRedirect("guest-movies");
        }
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
