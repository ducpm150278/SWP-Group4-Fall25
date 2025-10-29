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
import java.io.PrintWriter;
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
        
        // Check if this is an AJAX request for real-time seat updates
        String isAjax = request.getParameter("ajax");
        if ("true".equals(isAjax)) {
            handleAjaxSeatUpdate(request, response);
            return;
        }
        
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
    
    /**
     * Handle AJAX request for real-time seat availability updates
     */
    private void handleAjaxSeatUpdate(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        
        HttpSession session = request.getSession();
        BookingSession bookingSession = BookingSessionManager.getBookingSession(session);
        
        int screeningID = bookingSession.getScreeningID();
        if (screeningID <= 0) {
            // Try to get from request parameter
            String screeningIDParam = request.getParameter("screeningID");
            if (screeningIDParam != null) {
                try {
                    screeningID = Integer.parseInt(screeningIDParam);
                } catch (NumberFormatException e) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    return;
                }
            } else {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }
        }
        
        // Get current seat status
        List<Integer> bookedSeatIDs = seatDAO.getBookedSeatsForScreening(screeningID);
        List<Integer> reservedSeatIDs = seatDAO.getReservedSeatsForScreening(screeningID);
        
        // Exclude current session's reservations from reserved list
        if (bookingSession.getReservationSessionID() != null) {
            final String sessionID = bookingSession.getReservationSessionID();
            reservedSeatIDs = reservedSeatIDs.stream()
                .filter(id -> !bookingSession.getSelectedSeatIDs().contains(id))
                .collect(Collectors.toList());
        }
        
        // Build JSON response manually (no external library needed)
        StringBuilder json = new StringBuilder();
        json.append("{");
        
        // Booked seats array
        json.append("\"bookedSeats\":[");
        for (int i = 0; i < bookedSeatIDs.size(); i++) {
            json.append(bookedSeatIDs.get(i));
            if (i < bookedSeatIDs.size() - 1) {
                json.append(",");
            }
        }
        json.append("],");
        
        // Reserved seats array
        json.append("\"reservedSeats\":[");
        for (int i = 0; i < reservedSeatIDs.size(); i++) {
            json.append(reservedSeatIDs.get(i));
            if (i < reservedSeatIDs.size() - 1) {
                json.append(",");
            }
        }
        json.append("]");
        
        json.append("}");
        
        // Send JSON response
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        out.print(json.toString());
        out.flush();
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
            
            // Debug logging
            System.out.println("=== Seat Selection POST ===");
            System.out.println("Received seatIDs parameter: " + (seatIDStrings != null ? Arrays.toString(seatIDStrings) : "null"));
            
            if (seatIDStrings == null || seatIDStrings.length == 0) {
                System.out.println("Error: No seats selected");
                request.setAttribute("error", "Vui lòng chọn ít nhất một ghế!");
                doGet(request, response);
                return;
            }
            
            // Validate seat count (1-8 seats)
            if (seatIDStrings.length < 1 || seatIDStrings.length > 8) {
                System.out.println("Error: Invalid seat count: " + seatIDStrings.length);
                request.setAttribute("error", "Vui lòng chọn từ 1 đến 8 ghế!");
                doGet(request, response);
                return;
            }
            
            // Parse seat IDs with validation
            List<Integer> selectedSeatIDs = new ArrayList<>();
            for (String seatIDStr : seatIDStrings) {
                if (seatIDStr == null || seatIDStr.trim().isEmpty()) {
                    System.out.println("Error: Empty seat ID found");
                    throw new NumberFormatException("Empty seat ID");
                }
                try {
                    int seatID = Integer.parseInt(seatIDStr.trim());
                    selectedSeatIDs.add(seatID);
                    System.out.println("Parsed seat ID: " + seatID);
                } catch (NumberFormatException e) {
                    System.out.println("Error parsing seat ID: " + seatIDStr);
                    throw e;
                }
            }
            
            System.out.println("Total seats selected: " + selectedSeatIDs.size());
            
            // Generate reservation session ID if not exists
            String reservationSessionID = bookingSession.getReservationSessionID();
            if (reservationSessionID == null) {
                reservationSessionID = BookingSessionManager.generateReservationSessionID();
                bookingSession.setReservationSessionID(reservationSessionID);
            }
            
            // Check if seats are still available (first check before attempting reservation)
            if (!seatDAO.areSeatsAvailable(selectedSeatIDs, bookingSession.getScreeningID(), reservationSessionID)) {
                // Get specific unavailable seats for better error message
                List<Integer> unavailableSeats = seatDAO.getUnavailableSeats(selectedSeatIDs, bookingSession.getScreeningID(), reservationSessionID);
                
                // Get seat labels for unavailable seats
                List<String> unavailableLabels = new ArrayList<>();
                for (Integer seatID : unavailableSeats) {
                    Seat seat = seatDAO.getSeatByID(seatID);
                    if (seat != null) {
                        unavailableLabels.add(seat.getSeatLabel());
                    }
                }
                
                String errorMsg = "Ghế sau đã được người khác đặt: " + String.join(", ", unavailableLabels) + ". Vui lòng chọn ghế khác!";
                request.setAttribute("error", errorMsg);
                doGet(request, response);
                return;
            }
            
            // Reserve seats temporarily (atomic operation with database constraint protection)
            boolean reserved = seatDAO.reserveSeats(selectedSeatIDs, bookingSession.getScreeningID(), reservationSessionID);
            
            if (!reserved) {
                // This can happen due to race condition - another user reserved seats between check and insert
                // Get updated list of unavailable seats
                List<Integer> unavailableSeats = seatDAO.getUnavailableSeats(selectedSeatIDs, bookingSession.getScreeningID(), reservationSessionID);
                
                if (!unavailableSeats.isEmpty()) {
                    // Get seat labels
                    List<String> unavailableLabels = new ArrayList<>();
                    for (Integer seatID : unavailableSeats) {
                        Seat seat = seatDAO.getSeatByID(seatID);
                        if (seat != null) {
                            unavailableLabels.add(seat.getSeatLabel());
                        }
                    }
                    
                    String errorMsg = "Xin lỗi! Ghế " + String.join(", ", unavailableLabels) + 
                                     " vừa được người khác đặt. Vui lòng chọn ghế khác!";
                    request.setAttribute("error", errorMsg);
                } else {
                    request.setAttribute("error", "Không thể đặt chỗ. Vui lòng thử lại!");
                }
                
                doGet(request, response);
                return;
            }
            
            // Get seat labels and calculate ticket subtotal
            List<String> seatLabels = new ArrayList<>();
            double ticketSubtotal = 0;
            double baseTicketPrice = bookingSession.getTicketPrice();
            
            for (Integer seatID : selectedSeatIDs) {
                Seat seat = seatDAO.getSeatByID(seatID);
                if (seat != null) {
                    seatLabels.add(seat.getSeatLabel());
                    // Calculate price based on seat type multiplier
                    ticketSubtotal += baseTicketPrice * seat.getPriceMultiplier();
                }
            }
            
            // Store seat information in session
            bookingSession.setSelectedSeatIDs(selectedSeatIDs);
            bookingSession.setSelectedSeatLabels(seatLabels);
            bookingSession.setReservationExpiry(BookingSessionManager.getReservationExpiry());
            
            // Set calculated ticket subtotal
            bookingSession.setTicketSubtotal(ticketSubtotal);
            
            // Redirect to food selection
            response.sendRedirect(request.getContextPath() + "/booking/select-food");
            
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Dữ liệu không hợp lệ!");
            doGet(request, response);
        }
    }
}

