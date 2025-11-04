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
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

/**
 *
 * @author admin
 */
@WebServlet(name = "AddScreeningServlet", urlPatterns = {"/addScreening"})
public class AddScreeningServlet extends HttpServlet {

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
            out.println("<title>Servlet AddScreeningServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet AddScreeningServlet at " + request.getContextPath() + "</h1>");
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

        MovieDAO mdao = new MovieDAO();
        CinemaDAO cdao = new CinemaDAO();
        ScreeningRoomDAO rdao = new ScreeningRoomDAO();

        List<Movie> movies = mdao.getAll();          // tất cả phim (có status)
        List<Cinema> cinemas = cdao.getAllCinemas();
        List<ScreeningRoom> rooms = rdao.getAllRooms();
        // Danh sách khung giờ cố định
        List<String> timeSlots = List.of(
                "08:00-10:00", "10:15-12:15", "12:30-14:30",
                "14:45-16:45", "17:00-19:00", "19:15-21:15", "21:30-23:30"
        );

        request.setAttribute("movies", movies);
        request.setAttribute("cinemas", cinemas);
        request.setAttribute("rooms", rooms);
        request.setAttribute("timeSlots", timeSlots);

        request.getRequestDispatcher("addScreening.jsp").forward(request, response);
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
            int movieID = Integer.parseInt(request.getParameter("movieID"));
            int roomID = Integer.parseInt(request.getParameter("roomID"));
            String selectedDate = request.getParameter("date");
            String timeSlot = request.getParameter("timeSlot");

            if (timeSlot == null || timeSlot.isBlank()) {
                request.setAttribute("error", "Vui lòng chọn khung giờ chiếu!");
                doGet(request, response);
                return;
            }

            String[] parts = timeSlot.split("-");
            LocalTime startT = LocalTime.parse(parts[0]);
            LocalTime endT = LocalTime.parse(parts[1]);
            LocalDate date = LocalDate.parse(selectedDate);

            LocalDateTime start = LocalDateTime.of(date, startT);
            LocalDateTime end = LocalDateTime.of(date, endT);

//            
            // Giá vé (có thể rỗng, mặc định 0)
            double baseTicketPrice = 0.0;
            String t = request.getParameter("ticketPrice");
            if (t != null && !t.isBlank()) {
                baseTicketPrice = Double.parseDouble(t);
            }

            // ✅ Tự động lấy sức chứa của phòng (không nhập tay)
            ScreeningDAO dao = new ScreeningDAO();
            int availableSeats = dao.getSeatCapacityByRoomID(roomID);

            // Gán dữ liệu vào model
            Screening sc = new Screening();
            sc.setMovieID(movieID);
            sc.setRoomID(roomID);
            sc.setScreeningDate(date);      // ✅ thêm dòng này
            sc.setShowtime(timeSlot);
            sc.setBaseTicketPrice(baseTicketPrice);
            sc.setAvailableSeats(availableSeats);

            // Lưu vào DB
            dao.insertScreening(sc);

            // Chuyển hướng về danh sách lịch chiếu
            response.sendRedirect(request.getContextPath() + "/listScreening?addSuccess=1");
        } catch (Exception ex) {
            ex.printStackTrace();
            request.setAttribute("error", "Lỗi khi thêm lịch chiếu: " + ex.getMessage());
            request.getRequestDispatcher("addScreening.jsp").forward(request, response);
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
