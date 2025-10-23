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
import java.time.LocalDate;

/**
 *
 * @author admin
 */
@WebServlet(name="EditDiscountServlet", urlPatterns={"/editDiscount"})
public class EditDiscountServlet extends HttpServlet {
   
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
            out.println("<title>Servlet EditDiscountServlet</title>");  
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet EditDiscountServlet at " + request.getContextPath () + "</h1>");
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
    
    DiscountDAO dao = new DiscountDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idStr = request.getParameter("discountID");
        if (idStr == null) {
            response.sendRedirect("listDiscount");
            return;
        }

        int id = Integer.parseInt(idStr);
        Discount discount = dao.getDiscountById(id);
        if (discount == null) {
            response.sendRedirect("listDiscount");
            return;
        }

        // Format ngày để hiển thị lại trong input[type=date]
        request.setAttribute("discount", discount);
        request.getRequestDispatcher("editDiscount.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            int discountID = Integer.parseInt(request.getParameter("discountID"));
            String code = request.getParameter("code");
            String status = request.getParameter("status");
            String startDateStr = request.getParameter("startDate");
            String endDateStr = request.getParameter("endDate");
            String maxUsageStr = request.getParameter("maxUsage");
            String usageCountStr = request.getParameter("usageCount");
            String discountStr = request.getParameter("discountPercentage");

            boolean hasError = false;

            LocalDate startDate = LocalDate.parse(startDateStr);
            LocalDate endDate = LocalDate.parse(endDateStr);
            int maxUsage = Integer.parseInt(maxUsageStr);
            int usageCount = Integer.parseInt(usageCountStr);
            double discountPercentage = Double.parseDouble(discountStr);

            if (endDate.isBefore(startDate)) {
                request.setAttribute("errorStartEnd", "Ngày kết thúc phải sau ngày bắt đầu!");
                hasError = true;
            }

            if (maxUsage <= 0) {
                request.setAttribute("errorMaxUsage", "Số lần sử dụng tối đa phải lớn hơn 0!");
                hasError = true;
            }

            if (usageCount < 0) {
                request.setAttribute("errorUsageCount", "Số lần đã sử dụng không được âm!");
                hasError = true;
            }

            if (discountPercentage < 0 || discountPercentage > 100) {
                request.setAttribute("errorDiscount", "Phần trăm giảm giá phải từ 0 đến 100!");
                hasError = true;
            }

            if (hasError) {
                Discount discount = new Discount();
                discount.setDiscountID(discountID);
                discount.setCode(code);
                discount.setStatus(status);
                discount.setMaxUsage(maxUsage);
                discount.setUsageCount(usageCount);
                discount.setDiscountPercentage(discountPercentage);
                discount.setStartDate(startDate.atStartOfDay());
                discount.setEndDate(endDate.atStartOfDay());
                request.setAttribute("discount", discount);
                request.getRequestDispatcher("editDiscount.jsp").forward(request, response);
                return;
            }

            dao.updateDiscount(discountID, code, maxUsage, usageCount, startDate, endDate, status, discountPercentage);
            response.sendRedirect("listDiscount?updateSuccess=1");

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "❌ Lỗi khi cập nhật: " + e.getMessage());
            request.getRequestDispatcher("editDiscount.jsp").forward(request, response);
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
