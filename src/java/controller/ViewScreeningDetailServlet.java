/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller;

import dal.ScreeningDAO;
import entity.Screening;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.time.format.DateTimeFormatter;
import java.util.List;

/**
 *
 * @author admin
 */
@WebServlet(name="ViewScreeningDetailServlet", urlPatterns={"/viewScreening"})
public class ViewScreeningDetailServlet extends HttpServlet {
   
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
            out.println("<title>Servlet ViewScreeningDetailServlet</title>");  
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet ViewScreeningDetailServlet at " + request.getContextPath () + "</h1>");
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

    String idStr = request.getParameter("screeningID");
    if (idStr == null) {
        response.sendRedirect("listScreening");
        return;
    }

    try {
        int screeningID = Integer.parseInt(idStr);
        ScreeningDAO dao = new ScreeningDAO();

        Screening detail = dao.getScreeningDetail(screeningID);
        if (detail == null) {
            response.sendRedirect("listScreening");
            return;
        }

        // Lấy các khung giờ khác của cùng phim trong khoảng từ ngày bắt đầu -> kết thúc
        List<Screening> otherSchedules = dao.getOtherSchedulesOfMovie(
                detail.getMovieID(),
                detail.getStartTime().toLocalDate().atStartOfDay(),
                detail.getEndTime().toLocalDate().atTime(23, 59, 59),
                screeningID
        );

        // Format sẵn thời gian để hiển thị trong JSP
        DateTimeFormatter dateFmt = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
        DateTimeFormatter timeFmt = DateTimeFormatter.ofPattern("HH:mm");

        // Gán các chuỗi đã định dạng vào request
        request.setAttribute("formattedStart", detail.getStartTime().format(dateFmt));
        request.setAttribute("formattedEnd", detail.getEndTime().format(dateFmt));

        // Format khung giờ khác
        for (Screening s : otherSchedules) {
            s.setMovieTitle(s.getStartTime().format(dateFmt) + " - " + s.getEndTime().format(timeFmt)
                    + " (" + s.getCinemaName() + " - " + s.getRoomName() + ")");
        }

        request.setAttribute("detail", detail);
        request.setAttribute("otherSchedules", otherSchedules);
        request.getRequestDispatcher("viewScreening.jsp").forward(request, response);

    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("listScreening");
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
