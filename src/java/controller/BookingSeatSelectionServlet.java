package controller;

import dal.SeatDAO;
import dal.ScreeningDAO;
import entity.BookingSession;
import entity.Screening;
import entity.Seat;
import utils.BookingSessionManager;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Servlet for Step 2: Select Seats with interactive seat map
 */
@WebServlet(name = "BookingSeatSelectionServlet", urlPatterns = {"/booking/select-seats"})
public class BookingSeatSelectionServlet extends HttpServlet {
    
    private SeatDAO seatDAO;
    private ScreeningDAO screeningDAO;
    
    @Override
    public void init() throws ServletException {
        seatDAO = new SeatDAO();
        screeningDAO = new ScreeningDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        BookingSession bookingSession = BookingSessionManager.getBookingSession(session);
        
        // Check if screening is selected
        if (bookingSession.getScreeningID() <= 0) {
            response.sendRedirect(request.getContextPath() + "/booking/select-screening");
            return;
        }
        
        // Get screening details
        Screening screening = screeningDAO.getScreeningDetail(bookingSession.getScreeningID());
        if (screening == null) {
            response.sendRedirect(request.getContextPath() + "/booking/select-screening");
            return;
        }
        
        // Get all seats for the room
        List<Seat> allSeats = seatDAO.getSeatsByRoomID(screening.getRoomID());
        
        // Get booked seats
        List<Integer> bookedSeatIDs = seatDAO.getBookedSeatsForScreening(bookingSession.getScreeningID());
        
        // Get reserved seats (excluding current session)
        List<Integer> reservedSeatIDs = seatDAO.getReservedSeatsForScreening(bookingSession.getScreeningID());
        if (bookingSession.getReservationSessionID() != null) {
            // Keep current session's reservations as selected
            reservedSeatIDs = reservedSeatIDs.stream()
                .filter(id -> !bookingSession.getSelectedSeatIDs().contains(id))
                .collect(Collectors.toList());
        }
        
        request.setAttribute("screening", screening);
        request.setAttribute("allSeats", allSeats);
        request.setAttribute("bookedSeatIDs", bookedSeatIDs);
        request.setAttribute("reservedSeatIDs", reservedSeatIDs);
        request.setAttribute("bookingSession", bookingSession);
        
        // Forward to seat selection page
        request.getRequestDispatcher("/booking/select-seats.jsp").forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        BookingSession bookingSession = BookingSessionManager.getBookingSession(session);
        
        // Check if screening is selected
        if (bookingSession.getScreeningID() <= 0) {
            response.sendRedirect(request.getContextPath() + "/booking/select-screening");
            return;
        }
        
        try {
            // Get selected seat IDs
            String[] seatIDStrings = request.getParameterValues("seatIDs");
            
            if (seatIDStrings == null || seatIDStrings.length == 0) {
                request.setAttribute("error", "Vui lòng chọn ít nhất một ghế!");
                doGet(request, response);
                return;
            }
            
            // Validate seat count (2-8 seats)
            if (seatIDStrings.length < 1 || seatIDStrings.length > 8) {
                request.setAttribute("error", "Vui lòng chọn từ 1 đến 8 ghế!");
                doGet(request, response);
                return;
            }
            
            // Parse seat IDs
            List<Integer> selectedSeatIDs = Arrays.stream(seatIDStrings)
                .map(Integer::parseInt)
                .collect(Collectors.toList());
            
            // Generate reservation session ID if not exists
            String reservationSessionID = bookingSession.getReservationSessionID();
            if (reservationSessionID == null) {
                reservationSessionID = BookingSessionManager.generateReservationSessionID();
                bookingSession.setReservationSessionID(reservationSessionID);
            }
            
            // Check if seats are still available
            if (!seatDAO.areSeatsAvailable(selectedSeatIDs, bookingSession.getScreeningID(), reservationSessionID)) {
                request.setAttribute("error", "Một hoặc nhiều ghế đã được đặt. Vui lòng chọn ghế khác!");
                doGet(request, response);
                return;
            }
            
            // Reserve seats temporarily
            boolean reserved = seatDAO.reserveSeats(selectedSeatIDs, bookingSession.getScreeningID(), reservationSessionID);
            
            if (!reserved) {
                request.setAttribute("error", "Không thể đặt chỗ. Vui lòng thử lại!");
                doGet(request, response);
                return;
            }
            
            // Get seat labels
            List<String> seatLabels = new ArrayList<>();
            for (Integer seatID : selectedSeatIDs) {
                Seat seat = seatDAO.getSeatByID(seatID);
                if (seat != null) {
                    seatLabels.add(seat.getSeatLabel());
                }
            }
            
            // Store seat information in session
            bookingSession.setSelectedSeatIDs(selectedSeatIDs);
            bookingSession.setSelectedSeatLabels(seatLabels);
            bookingSession.setReservationExpiry(BookingSessionManager.getReservationExpiry());
            
            // Calculate ticket subtotal
            bookingSession.setTicketSubtotal(bookingSession.getTicketPrice() * selectedSeatIDs.size());
            
            // Redirect to food selection
            response.sendRedirect(request.getContextPath() + "/booking/select-food");
            
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Dữ liệu không hợp lệ!");
            doGet(request, response);
        }
    }
}

