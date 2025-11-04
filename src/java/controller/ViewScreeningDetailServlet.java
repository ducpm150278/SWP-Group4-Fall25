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
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author admin
 */
@WebServlet(name = "ViewScreeningDetailServlet", urlPatterns = {"/viewScreening"})
public class ViewScreeningDetailServlet extends HttpServlet {

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
            out.println("<title>Servlet ViewScreeningDetailServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet ViewScreeningDetailServlet at " + request.getContextPath() + "</h1>");
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

        String idStr = request.getParameter("screeningID");
        if (idStr == null) {
            response.sendRedirect("listScreening");
            return;
        }

        try {
            int screeningID = Integer.parseInt(idStr);
            ScreeningDAO dao = new ScreeningDAO();

            Screening detail = dao.getScreeningDetails(screeningID);
            System.out.println(detail.getBaseTicketPrice());
            if (detail == null) {
                response.sendRedirect("listScreening");
                return;
            }
            int capacity = dao.getSeatCapacityByRoomID(detail.getRoomID());
            int availableSeats = capacity;
            int soldSeats = 0;
            int cols = 10; // số ghế mỗi hàng
            int rows = (int) Math.ceil((double) capacity / cols);
            String rowLabels = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

            List<String> seatLabels = new ArrayList<>();
            for (int i = 0; i < rows; i++) {
                for (int j = 1; j <= cols; j++) {
                    int seatIndex = i * cols + j;
                    if (seatIndex > capacity) {
                        break;
                    }
                    String label = rowLabels.charAt(i) + String.valueOf(j);
                    seatLabels.add(label);
                }
            }

            String formattedDate = detail.getFormattedScreeningDate();

            request.setAttribute("detail", detail);
            request.setAttribute("seatLabels", seatLabels);
            request.setAttribute("rows", rows);
            request.setAttribute("cols", cols);
            request.setAttribute("availableSeats", availableSeats);
            request.setAttribute("soldSeats", soldSeats);
            request.setAttribute("formattedDate", formattedDate);
            request.getRequestDispatcher("viewScreening.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("listScreening");
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
        processRequest(request, response);
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
