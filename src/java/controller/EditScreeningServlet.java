/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller;

import dal.CinemaDAO;
import dal.MovieDAO;
import dal.ScreeningDAO;
import dal.ScreeningRoomDAO;
import entity.Cinema;
import entity.Movie;
import entity.Screening;
import entity.ScreeningRoom;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

/**
 *
 * @author admin
 */
@WebServlet(name="EditScreeningServlet", urlPatterns={"/editScreening"})
public class EditScreeningServlet extends HttpServlet {
   
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
            out.println("<title>Servlet EditScreeningServlet</title>");  
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet EditScreeningServlet at " + request.getContextPath () + "</h1>");
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
        try {
            String idStr = request.getParameter("screeningID");
            if (idStr == null || idStr.isEmpty()) {
                response.sendRedirect("listScreening");
                return;
            }

            int screeningID = Integer.parseInt(idStr);

            ScreeningDAO sdao = new ScreeningDAO();
            Screening screening = sdao.getScreeningDetail(screeningID);

            if (screening == null) {
                response.sendRedirect("listScreening");
                return;
            }

            // ✅ Lấy danh sách phim
            MovieDAO mdao = new MovieDAO();
            List<Movie> movies = mdao.getAll();

            // ✅ Lấy danh sách rạp
            CinemaDAO cdao = new CinemaDAO();
            List<Cinema> cinemas = cdao.getAllCinemas();

            // ✅ Lấy danh sách phòng
            ScreeningRoomDAO rdao = new ScreeningRoomDAO();
            List<ScreeningRoom> rooms = rdao.getAllRooms();

            // ✅ Gửi dữ liệu sang JSP
            request.setAttribute("screening", screening);
            request.setAttribute("movies", movies);
            request.setAttribute("cinemas", cinemas);
            request.setAttribute("rooms", rooms);

            request.getRequestDispatcher("editScreening.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("listScreening");
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
            String startTimeStr = request.getParameter("startTime");
            String endTimeStr = request.getParameter("endTime");
            String status = request.getParameter("status");

            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
            LocalDateTime startTime = LocalDateTime.parse(startTimeStr, formatter);
            LocalDateTime endTime = LocalDateTime.parse(endTimeStr, formatter);

            ScreeningDAO dao = new ScreeningDAO();
            boolean updated = dao.updateScreening(screeningID, movieID, roomID, startTime, endTime, status);

            if (updated) {
                response.sendRedirect("listScreening?success=1");
            } else {
                response.sendRedirect("editScreening?screeningID=" + screeningID + "&error=1");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("listScreening?error=1");
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
