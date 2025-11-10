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
        User user = (User) session.getAttribute("user");

        if (user == null || (!"Admin".equals(user.getRole()) && !"Staff".equals(user.getRole()))) {
            response.sendRedirect("login.jsp");
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

        request.getRequestDispatcher("staff-check-in.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        int bookingID = Integer.parseInt(request.getParameter("bookingID"));

        if ("check-in-paid".equals(action)) {
            boolean success = bookingDAO.updateBookingStatus(bookingID, "Completed");
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
