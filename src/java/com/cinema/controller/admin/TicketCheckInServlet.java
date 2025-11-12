package com.cinema.controller.admin;


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
import java.util.List;

@WebServlet(name = "TicketCheckInServlet", urlPatterns = {"/staff-check-in"})
public class TicketCheckInServlet extends HttpServlet {

    private BookingDAO bookingDAO;

    @Override
    public void init() throws ServletException {
        bookingDAO = new BookingDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute(SessionUtils.ATTR_USER);

        if (user == null || (!Constants.ROLE_ADMIN.equals(user.getRole()) && !Constants.ROLE_STAFF.equals(user.getRole()))) {
            response.sendRedirect(request.getContextPath() + Constants.URL_AUTH_LOGIN);
            return;
        }

        request.setAttribute("activePage", "staff-check-in");

        String searchTerm = request.getParameter("searchTerm");

        if (searchTerm != null && !searchTerm.isEmpty()) {
            List<BookingDetailDTO> bookings = bookingDAO.findBookingsForCheckIn(searchTerm);

            if (bookings != null && !bookings.isEmpty()) {
                request.setAttribute("bookings", bookings);
            } else {
                request.setAttribute("error", "Không tìm thấy đơn đặt vé nào (chưa check-in) với mã: " + searchTerm);
            }
        }

        request.getRequestDispatcher(Constants.JSP_STAFF_CHECK_IN).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        int bookingID = Integer.parseInt(request.getParameter("bookingID"));

        if ("check-in-paid".equals(action)) {
            boolean success = bookingDAO.updateBookingStatus(bookingID, Constants.BOOKING_STATUS_COMPLETED);
            if (success) {
                request.setAttribute("message", "Check-in thành công cho đơn " + bookingID);
            } else {
                request.setAttribute("error", "Lỗi khi check-in đơn " + bookingID);
            }

        } else if ("collect-cash".equals(action)) {
            boolean success = bookingDAO.confirmAndCompleteBooking(bookingID, "Cash");
            if (success) {
                request.setAttribute("message", "Thu tiền mặt và Check-in thành công cho đơn " + bookingID);
            } else {
                request.setAttribute("error", "Lỗi khi cập nhật đơn " + bookingID);
            }
        }

        doGet(request, response);
    }
}
