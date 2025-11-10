/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller;

import dal.DiscountDAO;
import entity.Discount;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.time.ZoneId;
import java.time.temporal.ChronoUnit;
import java.util.Date;

/**
 *
 * @author admin
 */
@WebServlet(name="ViewDiscountServlet", urlPatterns={"/viewDiscount"})
public class ViewDiscountServlet extends HttpServlet {
   
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
            out.println("<title>Servlet ViewDiscountServlet</title>");  
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet ViewDiscountServlet at " + request.getContextPath () + "</h1>");
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
            String idStr = request.getParameter("discountID");
            if (idStr == null || !idStr.matches("\\d+")) {
                response.sendRedirect("listDiscount");
                return;
            }

            int discountID = Integer.parseInt(idStr);
            DiscountDAO dao = new DiscountDAO();
            Discount d = dao.getDiscountById(discountID);
            System.out.println(d.getDiscountPercentage());

            if (d == null) {
                response.sendRedirect("listDiscount");
                return;
            }

            // Chuyển LocalDateTime → Date để JSP dùng fmt:formatDate
            Date startDate = Date.from(d.getStartDate().atZone(ZoneId.systemDefault()).toInstant());
            Date endDate = Date.from(d.getEndDate().atZone(ZoneId.systemDefault()).toInstant());
            long duration = ChronoUnit.DAYS.between(d.getStartDate().toLocalDate(), d.getEndDate().toLocalDate());

            request.setAttribute("discount", d);
            request.setAttribute("startDate", startDate);
            request.setAttribute("endDate", endDate);
            request.setAttribute("duration", duration);

            request.getRequestDispatcher("viewDiscount.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("listDiscount");
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
