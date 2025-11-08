package controller;

import dal.BookingDAO;
import entity.BookingDetailDTO;
import entity.User; 
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession; 
import java.io.IOException;

@WebServlet(name = "ViewBookingServlet", urlPatterns = {"/view-booking"})
public class ViewBookingServlet extends HttpServlet {

    private BookingDAO bookingDAO;

    @Override
    public void init() throws ServletException {
        bookingDAO = new BookingDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null || (!"Admin".equals(user.getRole()) && !"Staff".equals(user.getRole()))) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String bookingIdParam = request.getParameter("id");
        
        if (bookingIdParam == null) {
            request.setAttribute("error", "Không có ID đơn đặt vé.");
            request.getRequestDispatcher("listRefunds.jsp").forward(request, response);
            return;
        }

        try {
            int bookingID = Integer.parseInt(bookingIdParam);
            
            BookingDetailDTO booking = bookingDAO.getBookingDetailByID_Staff(bookingID);
            
            if (booking != null) {
                request.setAttribute("booking", booking);
                request.getRequestDispatcher("view-booking.jsp").forward(request, response);
            } else {
                request.setAttribute("error", "Không tìm thấy đơn đặt vé với ID: " + bookingID);
                request.getRequestDispatcher("listRefunds.jsp").forward(request, response);
            }
            
        } catch (NumberFormatException e) {
            request.setAttribute("error", "ID đơn đặt vé không hợp lệ.");
            request.getRequestDispatcher("listRefunds.jsp").forward(request, response);
        }
    }
}