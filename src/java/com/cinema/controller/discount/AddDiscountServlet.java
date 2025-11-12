package com.cinema.controller.discount;


import com.cinema.dal.DiscountDAO;
import com.cinema.utils.Constants;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.Map;

/**
 *
 * @author admin
 */
@WebServlet(name = "AddDiscountServlet", urlPatterns = {"/addDiscount"})
public class AddDiscountServlet extends HttpServlet {

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
            out.println("<title>Servlet AddDiscountServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet AddDiscountServlet at " + request.getContextPath() + "</h1>");
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
        request.getRequestDispatcher(Constants.JSP_DISCOUNT_ADD).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            request.setCharacterEncoding("UTF-8");

            String code = request.getParameter("code");
            String status = request.getParameter("status");
            String startDateStr = request.getParameter("startDate");
            String endDateStr = request.getParameter("endDate");

            int maxUsage = Integer.parseInt(request.getParameter("maxUsage"));
            int usageCount = Integer.parseInt(request.getParameter("usageCount"));
            double discountPercentage = Double.parseDouble(request.getParameter("discountPercentage"));

            LocalDate startDate = LocalDate.parse(startDateStr);
            LocalDate endDate = LocalDate.parse(endDateStr);

            Map<String, String> errors = new HashMap<>();

            // ==== Kiểm tra hợp lệ ====
            if (code == null || code.trim().isEmpty()) {
                errors.put("codeError", "❌ Mã CTKM không được để trống!");
            } else if (code.length() > 50) {
                errors.put("codeError", "❌ Mã CTKM không được vượt quá 50 ký tự!");
            }
            if (endDate.isBefore(startDate)) {
                errors.put("dateError", "❌ Ngày kết thúc phải sau ngày bắt đầu!");
            }
            if (maxUsage < 0) {
                errors.put("maxUsageError", "❌ Số lần sử dụng tối đa không được nhỏ hơn 0!");
            }
            if (usageCount < 0) {
                errors.put("usageCountError", "❌ Số lần đã sử dụng không được nhỏ hơn 0!");
            }
            if (usageCount > maxUsage) {
                errors.put("usageCountError", "❌ Số lần đã sử dụng không được lớn hơn số lần tối đa!");
            }
            if (discountPercentage < 0) {
                errors.put("discountError", "❌ Phần trăm giảm giá không được nhỏ hơn 0!");
            } else if (discountPercentage > 100) {
                errors.put("discountError", "❌ Phần trăm giảm giá không được vượt quá 100%!");
            }

            // ==== Nếu có lỗi, quay lại form và hiển thị ====
            if (!errors.isEmpty()) {
                request.setAttribute("errors", errors);
                // Giữ lại giá trị người dùng đã nhập
                request.setAttribute("code", code);
                request.setAttribute("status", status);
                request.setAttribute("startDate", startDateStr);
                request.setAttribute("endDate", endDateStr);
                request.setAttribute("maxUsage", maxUsage);
                request.setAttribute("usageCount", usageCount);
                request.setAttribute("discountPercentage", discountPercentage);
                request.getRequestDispatcher(Constants.JSP_DISCOUNT_ADD).forward(request, response);
                return;
            }

            // ==== Nếu không lỗi, thêm mới ====
            DiscountDAO dao = new DiscountDAO();
            dao.insertDiscount(code, maxUsage, usageCount, startDate, endDate, status, discountPercentage, 1);

            response.sendRedirect("listDiscount?addSuccess=1");

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "❌ Lỗi khi thêm CTKM: " + e.getMessage());
            request.getRequestDispatcher(Constants.JSP_DISCOUNT_ADD).forward(request, response);
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
