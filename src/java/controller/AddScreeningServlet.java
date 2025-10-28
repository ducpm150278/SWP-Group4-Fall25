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

        request.setAttribute("movies", movies);
        request.setAttribute("cinemas", cinemas);
        request.setAttribute("rooms", rooms);

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

            DateTimeFormatter fmt = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
            LocalDateTime start = LocalDateTime.parse(request.getParameter("startTime"), fmt);
            LocalDateTime end = LocalDateTime.parse(request.getParameter("endTime"), fmt);

            // Kiểm tra điều kiện ràng buộc ngày
            if (end.isBefore(start) || end.isEqual(start)) {
                request.setAttribute("error", "Thời gian kết thúc phải sau thời gian bắt đầu!");

                // Gửi lại dữ liệu để hiển thị form (tránh mất danh sách)
                MovieDAO mdao = new MovieDAO();
                CinemaDAO cdao = new CinemaDAO();
                ScreeningRoomDAO rdao = new ScreeningRoomDAO();
                request.setAttribute("movies", mdao.getAll());
                request.setAttribute("cinemas", cdao.getAllCinemas());
                request.setAttribute("rooms", rdao.getAllRooms());

                request.getRequestDispatcher("addScreening.jsp").forward(request, response);
                return;
            }

            // Giá vé (có thể rỗng, mặc định 0)
            double ticketPrice = 0.0;
            String t = request.getParameter("ticketPrice");
            if (t != null && !t.isBlank()) {
                ticketPrice = Double.parseDouble(t);
            }

            // ✅ Tự động lấy sức chứa của phòng (không nhập tay)
            ScreeningDAO dao = new ScreeningDAO();
            int availableSeats = dao.getSeatCapacityByRoomID(roomID);

            // Gán dữ liệu vào model
            Screening sc = new Screening();
            sc.setMovieID(movieID);
            sc.setRoomID(roomID);
            sc.setStartTime(start);
            sc.setEndTime(end);
            sc.setTicketPrice(ticketPrice);
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
