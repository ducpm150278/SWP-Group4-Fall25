package com.cinema.controller.booking;

import com.cinema.dal.SeatDAO;
import com.cinema.dal.ScreeningDAO;
import com.cinema.entity.BookingSession;
import com.cinema.entity.Screening;
import com.cinema.entity.Seat;
import com.cinema.utils.BookingSessionManager;
import com.cinema.utils.Constants;

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
 * Servlet xử lý bước 2: Chọn ghế với bản đồ ghế tương tác
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
    
    /**
     * Xử lý request GET - hiển thị trang chọn ghế
     * Flow: Kiểm tra AJAX request -> Validate screening -> Lấy danh sách ghế -> Phân loại trạng thái ghế -> Hiển thị
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Bước 1: Kiểm tra xem có phải AJAX request không
        // AJAX request được sử dụng để cập nhật trạng thái ghế real-time mà không reload trang
        String isAjax = request.getParameter("ajax");
        if ("true".equals(isAjax)) {
            handleAjaxSeatUpdate(request, response);
            return;
        }
        
        HttpSession session = request.getSession();
        BookingSession bookingSession = BookingSessionManager.getBookingSession(session);
        
        // Bước 2: Kiểm tra suất chiếu đã được chọn chưa
        // Người dùng phải chọn suất chiếu trước khi chọn ghế
        if (bookingSession.getScreeningID() <= 0) {
            response.sendRedirect(request.getContextPath() + Constants.URL_BOOKING_SELECT_SCREENING);
            return;
        }
        
        // Bước 3: Lấy thông tin chi tiết suất chiếu từ database
        // Cần thông tin suất chiếu để lấy roomID và validate
        Screening screening = screeningDAO.getScreeningDetail(bookingSession.getScreeningID());
        if (screening == null) {
            // Suất chiếu không tồn tại - có thể bị xóa giữa chừng
            response.sendRedirect(request.getContextPath() + Constants.URL_BOOKING_SELECT_SCREENING);
            return;
        }
        
        // Bước 4: Lấy tất cả ghế trong phòng chiếu
        // Cần tất cả ghế để hiển thị bản đồ ghế
        List<Seat> allSeats = seatDAO.getSeatsByRoomID(screening.getRoomID());
        
        // Bước 5: Lọc các ghế có trạng thái Unavailable hoặc Maintenance
        // Các ghế này không thể chọn được nhưng vẫn hiển thị trong UI để người dùng biết
        // Ghế Unavailable: đã bị vô hiệu hóa vĩnh viễn
        // Ghế Maintenance: đang bảo trì, tạm thời không sử dụng
        List<Integer> unavailableStatusSeatIDs = allSeats.stream()
            .filter(seat -> Constants.SEAT_STATUS_UNAVAILABLE.equals(seat.getStatus()) || 
                           Constants.SEAT_STATUS_MAINTENANCE.equals(seat.getStatus()))
            .map(Seat::getSeatID)
            .collect(Collectors.toList());
        
        // Bước 6: Lấy danh sách ghế đã được đặt (booked)
        // Ghế đã booked là ghế đã được thanh toán thành công, không thể chọn
        List<Integer> bookedSeatIDs = seatDAO.getBookedSeatsForScreening(bookingSession.getScreeningID());
        
        // Bước 7: Lấy danh sách ghế đang được reserve (tạm giữ)
        // Ghế reserved là ghế đang được người khác tạm giữ trong thời gian chờ thanh toán
        List<Integer> reservedSeatIDs = seatDAO.getReservedSeatsForScreening(bookingSession.getScreeningID());
        
        // Bước 8: Loại bỏ ghế đang được reserve bởi session hiện tại
        // Ghế mà session hiện tại đang reserve sẽ được hiển thị là "đã chọn" thay vì "đang reserve"
        if (bookingSession.getReservationSessionID() != null) {
            // Giữ lại ghế đã chọn của session hiện tại để hiển thị là selected
            reservedSeatIDs = reservedSeatIDs.stream()
                .filter(id -> !bookingSession.getSelectedSeatIDs().contains(id))
                .collect(Collectors.toList());
        }
        
        // Bước 9: Truyền dữ liệu đến JSP để hiển thị
        request.setAttribute("screening", screening);                          // Thông tin suất chiếu
        request.setAttribute("allSeats", allSeats);                           // Tất cả ghế trong phòng
        request.setAttribute("bookedSeatIDs", bookedSeatIDs);                  // Ghế đã booked
        request.setAttribute("reservedSeatIDs", reservedSeatIDs);             // Ghế đang reserve (của người khác)
        request.setAttribute("unavailableStatusSeatIDs", unavailableStatusSeatIDs); // Ghế Unavailable/Maintenance
        request.setAttribute("bookingSession", bookingSession);                // Booking session để hiển thị ghế đã chọn
        
        // Bước 10: Chuyển tiếp đến trang JSP chọn ghế
        request.getRequestDispatcher(Constants.JSP_BOOKING_SELECT_SEATS).forward(request, response);
    }
    
    /**
     * Xử lý AJAX request để cập nhật trạng thái ghế real-time
     * Được gọi định kỳ từ frontend để cập nhật trạng thái ghế mà không cần reload trang
     * Trả về JSON chứa danh sách ghế đã booked và đang reserved
     */
    private void handleAjaxSeatUpdate(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        
        HttpSession session = request.getSession();
        BookingSession bookingSession = BookingSessionManager.getBookingSession(session);
        
        // Bước 1: Lấy screening ID từ booking session hoặc request parameter
        int screeningID = bookingSession.getScreeningID();
        if (screeningID <= 0) {
            // Nếu không có trong session, thử lấy từ request parameter
            // Trường hợp này xảy ra khi AJAX được gọi trước khi session được tạo
            String screeningIDParam = request.getParameter("screeningID");
            if (screeningIDParam != null) {
                try {
                    screeningID = Integer.parseInt(screeningIDParam);
                } catch (NumberFormatException e) {
                    // screeningID không hợp lệ - trả về lỗi 400
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    return;
                }
            } else {
                // Không có screeningID - trả về lỗi 400
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }
        }
        
        // Bước 2: Lấy danh sách ghế đã booked (đã thanh toán)
        // Ghế booked là ghế đã được xác nhận thanh toán, không thể chọn
        List<Integer> bookedSeatIDs = seatDAO.getBookedSeatsForScreening(screeningID);
        
        // Bước 3: Lấy danh sách ghế đang reserved (tạm giữ)
        // Ghế reserved là ghế đang được người khác tạm giữ trong thời gian chờ thanh toán
        List<Integer> reservedSeatIDs = seatDAO.getReservedSeatsForScreening(screeningID);
        
        // Bước 4: Loại bỏ ghế đang được reserve bởi session hiện tại
        // Ghế mà session hiện tại đang reserve sẽ không hiển thị là "reserved" mà là "selected"
        if (bookingSession.getReservationSessionID() != null) {
            reservedSeatIDs = reservedSeatIDs.stream()
                .filter(id -> !bookingSession.getSelectedSeatIDs().contains(id))
                .collect(Collectors.toList());
        }
        
        // Bước 5: Xây dựng JSON response thủ công (không dùng thư viện bên ngoài)
        // Format: {"bookedSeats":[1,2,3],"reservedSeats":[4,5,6]}
        StringBuilder json = new StringBuilder();
        json.append("{");
        
        // Thêm mảng booked seats
        json.append("\"bookedSeats\":[");
        for (int i = 0; i < bookedSeatIDs.size(); i++) {
            json.append(bookedSeatIDs.get(i));
            if (i < bookedSeatIDs.size() - 1) {
                json.append(",");
            }
        }
        json.append("],");
        
        // Thêm mảng reserved seats
        json.append("\"reservedSeats\":[");
        for (int i = 0; i < reservedSeatIDs.size(); i++) {
            json.append(reservedSeatIDs.get(i));
            if (i < reservedSeatIDs.size() - 1) {
                json.append(",");
            }
        }
        json.append("]");
        
        json.append("}");
        
        // Bước 6: Gửi JSON response về frontend
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        out.print(json.toString());
        out.flush();
    }
    
    /**
     * Xử lý request POST - xử lý khi người dùng chọn ghế
     * Flow: Validate screening -> Validate số lượng ghế -> Parse seat IDs -> Check availability -> Reserve seats -> Tính giá -> Lưu session -> Chuyển bước
     * 
     * Race Condition Handling:
     * - Kiểm tra availability trước khi reserve
     * - Reserve là atomic operation với database constraint
     * - Xử lý trường hợp ghế bị reserve bởi người khác giữa lúc check và reserve
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        BookingSession bookingSession = BookingSessionManager.getBookingSession(session);
        
        // Bước 1: Kiểm tra suất chiếu đã được chọn chưa
        // Phải có suất chiếu trước khi chọn ghế
        if (bookingSession.getScreeningID() <= 0) {
            response.sendRedirect(request.getContextPath() + Constants.URL_BOOKING_SELECT_SCREENING);
            return;
        }
        
        try {
            // Bước 2: Lấy danh sách seat IDs từ form
            // Form có thể gửi nhiều seatIDs (checkbox hoặc multi-select)
            String[] seatIDStrings = request.getParameterValues("seatIDs");
            
            // Bước 3: Kiểm tra người dùng đã chọn ít nhất một ghế
            if (seatIDStrings == null || seatIDStrings.length == 0) {
                request.setAttribute("error", "Vui lòng chọn ít nhất một ghế!");
                doGet(request, response);
                return;
            }
            
            // Bước 4: Validate số lượng ghế (từ 1 đến 8 ghế)
            // Giới hạn số ghế để tránh abuse và đảm bảo trải nghiệm tốt
            if (seatIDStrings.length < Constants.MIN_SEATS || seatIDStrings.length > Constants.MAX_SEATS) {
                request.setAttribute("error", "Vui lòng chọn từ 1 đến 8 ghế!");
                doGet(request, response);
                return;
            }
            
            // Bước 5: Parse seat IDs từ string sang integer với validation
            // Loại bỏ các giá trị rỗng và không hợp lệ
            List<Integer> selectedSeatIDs = new ArrayList<>();
            for (String seatIDStr : seatIDStrings) {
                if (seatIDStr == null || seatIDStr.trim().isEmpty()) {
                    throw new NumberFormatException("Empty seat ID");
                }
                try {
                    int seatID = Integer.parseInt(seatIDStr.trim());
                    selectedSeatIDs.add(seatID);
                } catch (NumberFormatException e) {
                    throw e;
                }
            }
            
            // Bước 6: Tạo reservation session ID nếu chưa có
            // Reservation session ID là unique identifier cho mỗi lần reserve
            // Được sử dụng để phân biệt reservation của các session khác nhau
            String reservationSessionID = bookingSession.getReservationSessionID();
            if (reservationSessionID == null) {
                reservationSessionID = BookingSessionManager.generateReservationSessionID();
                bookingSession.setReservationSessionID(reservationSessionID);
            }
            
            // Bước 7: Kiểm tra ghế còn available không (kiểm tra đầu tiên)
            // Kiểm tra này giúp tránh reserve ghế không available, nhưng không đảm bảo 100% do race condition
            if (!seatDAO.areSeatsAvailable(selectedSeatIDs, bookingSession.getScreeningID(), reservationSessionID)) {
                // Lấy danh sách ghế không available để hiển thị thông báo chi tiết
                List<Integer> unavailableSeats = seatDAO.getUnavailableSeats(selectedSeatIDs, bookingSession.getScreeningID(), reservationSessionID);
                
                // Lấy label của các ghế không available để hiển thị cho người dùng
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
            
            // Bước 8: Reserve ghế tạm thời (atomic operation với database constraint)
            // reserveSeats() sẽ thực hiện reserve với database constraint để đảm bảo atomicity
            // Nếu có race condition (người khác reserve cùng lúc), database constraint sẽ reject
            boolean reserved = seatDAO.reserveSeats(selectedSeatIDs, bookingSession.getScreeningID(), reservationSessionID);
            
            if (!reserved) {
                // Trường hợp này xảy ra do race condition - người khác đã reserve ghế giữa lúc check và insert
                // Lấy danh sách ghế không available sau khi reserve thất bại
                List<Integer> unavailableSeats = seatDAO.getUnavailableSeats(selectedSeatIDs, bookingSession.getScreeningID(), reservationSessionID);
                
                if (!unavailableSeats.isEmpty()) {
                    // Lấy label của các ghế không available để hiển thị
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
            
            // Bước 9: Lấy label của ghế và tính tổng tiền vé
            // Label để hiển thị cho người dùng (ví dụ: "A1", "B5")
            // Tính giá dựa trên base price và price multiplier của từng loại ghế
            List<String> seatLabels = new ArrayList<>();
            double ticketSubtotal = 0;
            double baseTicketPrice = bookingSession.getTicketPrice();
            
            for (Integer seatID : selectedSeatIDs) {
                Seat seat = seatDAO.getSeatByID(seatID);
                if (seat != null) {
                    seatLabels.add(seat.getSeatLabel());
                    // Tính giá dựa trên seat type multiplier
                    // Ví dụ: VIP seat có multiplier 1.5, Normal seat có multiplier 1.0
                    ticketSubtotal += baseTicketPrice * seat.getPriceMultiplier();
                }
            }
            
            // Bước 10: Lưu thông tin ghế vào booking session
            bookingSession.setSelectedSeatIDs(selectedSeatIDs);
            bookingSession.setSelectedSeatLabels(seatLabels);
            bookingSession.setReservationExpiry(BookingSessionManager.getReservationExpiry()); // Thời gian hết hạn reserve (15 phút)
            
            // Bước 11: Lưu tổng tiền vé đã tính
            bookingSession.setTicketSubtotal(ticketSubtotal);
            
            // Bước 12: QUAN TRỌNG: Lưu bookingSession lại vào session để đảm bảo persistence
            // BookingSession là object, cần set lại vào session sau khi modify
            session.setAttribute(Constants.SESSION_BOOKING_SESSION, bookingSession);
            
            // Bước 13: Chuyển hướng đến bước tiếp theo - chọn đồ ăn
            response.sendRedirect(request.getContextPath() + Constants.URL_BOOKING_SELECT_FOOD);
            
        } catch (NumberFormatException e) {
            // Xử lý lỗi khi seatID không phải là số hợp lệ
            request.setAttribute("error", "Dữ liệu không hợp lệ!");
            doGet(request, response);
        }
    }
}

