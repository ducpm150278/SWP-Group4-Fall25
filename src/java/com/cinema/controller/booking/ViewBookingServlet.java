package com.cinema.controller.booking;

import com.cinema.dal.BookingDAO;
import com.cinema.entity.BookingDetailDTO;
import com.cinema.entity.User;
import com.cinema.utils.Constants;
import com.cinema.utils.SessionUtils;
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
        User user = (User) SessionUtils.getUser(session);
        
        if (user == null || (!Constants.ROLE_ADMIN.equals(user.getRole()) && !Constants.ROLE_STAFF.equals(user.getRole()))) {
            response.sendRedirect(request.getContextPath() + Constants.URL_AUTH_LOGIN);
            return;
        }
        
        String bookingIdParam = request.getParameter("id");
        
        if (bookingIdParam == null) {
            request.setAttribute("error", "Không có ID đơn đặt vé.");
            request.getRequestDispatcher(Constants.JSP_STAFF_LIST_REFUNDS).forward(request, response);
            return;
        }

        try {
            int bookingID = Integer.parseInt(bookingIdParam);
            
            BookingDetailDTO booking = bookingDAO.getBookingDetailByID_Staff(bookingID);
            
            if (booking != null) {
                request.setAttribute("booking", booking);
                request.getRequestDispatcher(Constants.JSP_PROFILE_VIEW_BOOKING).forward(request, response);
            } else {
                request.setAttribute("error", "Không tìm thấy đơn đặt vé với ID: " + bookingID);
                request.getRequestDispatcher(Constants.JSP_STAFF_LIST_REFUNDS).forward(request, response);
            }
            
        } catch (NumberFormatException e) {
            request.setAttribute("error", "ID đơn đặt vé không hợp lệ.");
            request.getRequestDispatcher(Constants.JSP_STAFF_LIST_REFUNDS).forward(request, response);
        }
    }
}