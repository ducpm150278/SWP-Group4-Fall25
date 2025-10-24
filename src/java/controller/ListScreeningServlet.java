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
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

/**
 *
 * @author admin
 */
@WebServlet(name="ListScreeningServlet", urlPatterns={"/listScreening"})
public class ListScreeningServlet extends HttpServlet {
   
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
            out.println("<title>Servlet ListScreeningServlet</title>");  
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet ListScreeningServlet at " + request.getContextPath () + "</h1>");
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
    String pageStr = request.getParameter("page");

    int page = 1;
    int pageSize = 6; // số bản ghi mỗi trang
    if (pageStr != null && !pageStr.isEmpty()) {
        page = Integer.parseInt(pageStr);
    }

    LocalDateTime from = null;
    LocalDateTime to = null;
    try {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        if (fromStr != null && !fromStr.isEmpty()) {
            from = LocalDate.parse(fromStr, formatter).atStartOfDay();
        }
        if (toStr != null && !toStr.isEmpty()) {
            to = LocalDate.parse(toStr, formatter).atTime(23, 59, 59);
        }
    } catch (Exception e) {
        System.out.println("Error parsing datetime: " + e.getMessage());
    }

    ScreeningDAO dao = new ScreeningDAO();
    List<Screening> list;
    int totalRecords;

    // Nếu có điều kiện tìm kiếm
    if ((keyword != null && !keyword.isEmpty()) || from != null || to != null || (status != null && !status.isEmpty())) {
        list = dao.searchScreeningsWithPaging(keyword, from, to, status, page, pageSize);
        totalRecords = dao.countSearchScreenings(keyword, from, to, status);
    } else {
        list = dao.getAllScreeningWithPaging(page, pageSize);
        totalRecords = dao.countAllScreenings();
    }

    int totalPages = (int) Math.ceil((double) totalRecords / pageSize);

    request.setAttribute("screenings", list);
    request.setAttribute("keyword", keyword);
    request.setAttribute("from", fromStr);
    request.setAttribute("to", toStr);
    request.setAttribute("status", status);
    request.setAttribute("currentPage", page);
    request.setAttribute("totalPages", totalPages);

    request.getRequestDispatcher("listScreening.jsp").forward(request, response);
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