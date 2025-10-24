/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller;

import dal.DiscountDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.time.LocalDate;

/**
 *
 * @author admin
 */
@WebServlet(name="AddDiscountServlet", urlPatterns={"/addDiscount"})
public class AddDiscountServlet extends HttpServlet {
   
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
            out.println("<title>Servlet AddDiscountServlet</title>");  
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet AddDiscountServlet at " + request.getContextPath () + "</h1>");
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
        request.getRequestDispatcher("addDiscount.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String code = request.getParameter("code");
            int maxUsage = Integer.parseInt(request.getParameter("maxUsage"));
            int usageCount = Integer.parseInt(request.getParameter("usageCount"));
            double discountPercentage = Double.parseDouble(request.getParameter("discountPercentage"));
            String status = request.getParameter("status");
            LocalDate startDate = LocalDate.parse(request.getParameter("startDate"));
            LocalDate endDate = LocalDate.parse(request.getParameter("endDate"));

            if (endDate.isBefore(startDate)) {
                request.setAttribute("error", "Ngày kết thúc phải sau ngày bắt đầu!");
                request.getRequestDispatcher("addDiscount.jsp").forward(request, response);
                return;
            }

            DiscountDAO dao = new DiscountDAO();
            dao.insertDiscount(code, maxUsage, usageCount, startDate, endDate, status, discountPercentage, 1); // CreatedBy = 1 (Admin)

            // ✅ Sau khi thêm thành công -> quay về danh sách + thông báo
            response.sendRedirect("listDiscount?addSuccess=1");

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "❌ Lỗi khi thêm CTKM: " + e.getMessage());
            request.getRequestDispatcher("addDiscount.jsp").forward(request, response);
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
