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
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 *
 * @author admin
 */
@WebServlet(name="ListDiscountServlet", urlPatterns={"/listDiscount"})
public class ListDiscountServlet extends HttpServlet {
   
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
            out.println("<title>Servlet ListDiscountServlet</title>");  
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet ListDiscountServlet at " + request.getContextPath () + "</h1>");
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
   
  
    private static final int RECORDS_PER_PAGE = 6; // mỗi trang 6 bản ghi

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            request.setCharacterEncoding("UTF-8");
            DiscountDAO dao = new DiscountDAO();

            // ===== Lấy tham số lọc từ request =====
            String keyword = request.getParameter("keyword");
            String status = request.getParameter("status");
            String startDate = request.getParameter("start");

            // ===== Tính phân trang =====
            int currentPage = 1;
            String pageStr = request.getParameter("page");
            if (pageStr != null && pageStr.matches("\\d+")) {
                currentPage = Integer.parseInt(pageStr);
            }

            int totalRecords = dao.countDiscounts(keyword, status, startDate);
            int totalPages = (int) Math.ceil((double) totalRecords / RECORDS_PER_PAGE);

            int offset = (currentPage - 1) * RECORDS_PER_PAGE;

            // ===== Lấy danh sách CTKM cho trang hiện tại =====
            List<Discount> discounts = dao.getDiscountsByPage(keyword, status, startDate, offset, RECORDS_PER_PAGE);

            // ✅ Chuyển đổi dữ liệu sang dạng hiển thị (Date, duration)
            List<Map<String, Object>> discountViewList = new ArrayList<>();
            for (Discount d : discounts) {
                Map<String, Object> map = new HashMap<>();
                map.put("discount", d);
                map.put("startDate", Date.from(d.getStartDate().atZone(ZoneId.systemDefault()).toInstant()));
                map.put("endDate", Date.from(d.getEndDate().atZone(ZoneId.systemDefault()).toInstant()));
                long duration = ChronoUnit.DAYS.between(d.getStartDate().toLocalDate(), d.getEndDate().toLocalDate());
                map.put("duration", duration);
                discountViewList.add(map);
            }

            // ===== Gửi dữ liệu sang JSP =====
            request.setAttribute("discounts", discountViewList);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("currentPage", currentPage);
            request.setAttribute("keyword", keyword);
            request.setAttribute("status", status);
            request.setAttribute("start", startDate);

            request.getRequestDispatcher("listDiscount.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi khi tải danh sách CTKM!");
            request.getRequestDispatcher("error.jsp").forward(request, response);
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
