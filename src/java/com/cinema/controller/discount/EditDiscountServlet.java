package com.cinema.controller.discount;


import com.cinema.dal.DiscountDAO;
import com.cinema.entity.Discount;
import com.cinema.utils.Constants;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

/**
 *
 * @author admin
 */
@WebServlet(name = "EditDiscountServlet", urlPatterns = {"/editDiscount"})
public class EditDiscountServlet extends HttpServlet {

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
            out.println("<title>Servlet EditDiscountServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet EditDiscountServlet at " + request.getContextPath() + "</h1>");
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

        // ✅ Format ngày theo chuẩn HTML5: yyyy-MM-dd
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");

        String startDateFormatted = "";
        String endDateFormatted = "";

        if (discount.getStartDate() != null) {
            startDateFormatted = discount.getStartDate().toLocalDate().format(formatter);
        }

        if (discount.getEndDate() != null) {
            endDateFormatted = discount.getEndDate().toLocalDate().format(formatter);
        }

        // Gửi sang JSP
        request.setAttribute("discount", discount);
        request.setAttribute("startDateFormatted", startDateFormatted);
        request.setAttribute("endDateFormatted", endDateFormatted);

        request.getRequestDispatcher(Constants.JSP_DISCOUNT_EDIT).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            int discountID = Integer.parseInt(request.getParameter("discountID"));
            String code = request.getParameter("code");
            String status = request.getParameter("status");

            LocalDate startDate = LocalDate.parse(request.getParameter("startDate"));
            LocalDate endDate = LocalDate.parse(request.getParameter("endDate"));
            int maxUsage = Integer.parseInt(request.getParameter("maxUsage"));
            int usageCount = Integer.parseInt(request.getParameter("usageCount"));
            double discountPercentage = Double.parseDouble(request.getParameter("discountPercentage"));

            boolean hasError = false;
             // ✅ Kiểm tra mã khuyến mãi (code)
        if (code == null || code.trim().isEmpty()) {
            request.setAttribute("errorCode", "Mã CTKM không được để trống!");
            hasError = true;
        } else if (code.length() > 50) {
            request.setAttribute("errorCode", "Mã CTKM không được vượt quá 50 ký tự!");
            hasError = true;
        }

            // ✅ Kiểm tra ngày
            if (endDate.isBefore(startDate)) {
                request.setAttribute("errorStartEnd", "Ngày kết thúc phải sau ngày bắt đầu!");
                hasError = true;
            }

            // ✅ Kiểm tra số lần sử dụng
            if (maxUsage <= 0) {
                request.setAttribute("errorMaxUsage", "Số lần sử dụng tối đa phải lớn hơn 0!");
                hasError = true;
            }
            if (usageCount < 0) {
                request.setAttribute("errorUsageCount", "Số lần đã sử dụng không được âm!");
                hasError = true;
            }
            if (usageCount > maxUsage) {
                request.setAttribute("errorUsageCount", "Số lần đã sử dụng không được vượt quá số lần tối đa!");
                hasError = true;
            }

            // ✅ Kiểm tra phần trăm giảm giá
            if (discountPercentage < 0 || discountPercentage > 100) {
                request.setAttribute("errorDiscount", "Phần trăm giảm giá phải nằm trong khoảng 0–100%!");
                hasError = true;
            }

            // ✅ Nếu có lỗi thì trả lại trang cũ + giữ dữ liệu
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
                request.getRequestDispatcher(Constants.JSP_DISCOUNT_EDIT).forward(request, response);
                return;
            }

            // ✅ Cập nhật DB
            dao.updateDiscount(discountID, code, maxUsage, usageCount, startDate, endDate, status, discountPercentage);

            // ✅ Chuyển hướng sau khi cập nhật thành công
            response.sendRedirect("listDiscount?updateSuccess=1");

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "❌ Lỗi khi cập nhật: " + e.getMessage());
            request.getRequestDispatcher(Constants.JSP_DISCOUNT_EDIT).forward(request, response);
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
