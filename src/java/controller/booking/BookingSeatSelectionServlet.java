package controller.booking;

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
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Servlet xử lý Bước 2 của quy trình đặt vé: Chọn ghế với seat map tương tác
 * 
 * Flow tổng quan:
 * 1. Kiểm tra đã chọn suất chiếu chưa (từ Bước 1)
 * 2. Load tất cả ghế trong phòng chiếu
 * 3. Phân loại trạng thái ghế:
 *    - Available: Ghế trống, có thể chọn
 *    - Booked: Ghế đã được đặt (có ticket trong database)
 *    - Reserved: Ghế đang được giữ tạm thời bởi user khác (chưa thanh toán)
 *    - Unavailable/Maintenance: Ghế không khả dụng hoặc đang bảo trì
 * 4. Hiển thị seat map với các trạng thái khác nhau
 * 5. Người dùng chọn ghế (1-8 ghế)
 * 6. Kiểm tra ghế còn available không (tránh race condition)
 * 7. Reserve ghế tạm thời (tạo reservation record với session ID)
 * 8. Tính giá vé dựa trên loại ghế (price multiplier)
 * 9. Lưu thông tin ghế vào BookingSession
 * 10. Chuyển sang Bước 3: Chọn đồ ăn
 * 
 * Tính năng đặc biệt:
 * - AJAX real-time update: Frontend có thể gọi AJAX để cập nhật trạng thái ghế theo thời gian thực
 * - Race condition handling: Xử lý trường hợp nhiều user cùng chọn ghế
 * - Temporary reservation: Giữ ghế tạm thời trong thời gian nhất định (thường 15 phút)
 * 
 * Endpoint: /booking/select-seats
 */
@WebServlet(name = "BookingSeatSelectionServlet", urlPatterns = {"/booking/select-seats"})
public class BookingSeatSelectionServlet extends HttpServlet {
    
    /** DAO để thao tác với dữ liệu ghế */
    private SeatDAO seatDAO;
    /** DAO để thao tác với dữ liệu suất chiếu */
    private ScreeningDAO screeningDAO;
    
    /**
     * Khởi tạo servlet - tạo các DAO instances
     */
    @Override
    public void init() throws ServletException {
        seatDAO = new SeatDAO();
        screeningDAO = new ScreeningDAO();
    }
    
    /**
     * Xử lý request GET - hiển thị seat map hoặc trả về AJAX response
     * 
     * Flow xử lý:
     * Bước 1: Kiểm tra có phải AJAX request không (parameter ajax=true)
     * Bước 2: Nếu là AJAX, xử lý AJAX request để cập nhật trạng thái ghế real-time
     * Bước 3: Nếu không phải AJAX, kiểm tra đã chọn suất chiếu chưa
     * Bước 4: Load thông tin suất chiếu
     * Bước 5: Load tất cả ghế trong phòng chiếu
     * Bước 6: Phân loại trạng thái ghế (booked, reserved, unavailable)
     * Bước 7: Forward đến trang JSP để hiển thị seat map
     * 
     * @param request HTTP request (có thể chứa parameter ajax=true cho AJAX request)
     * @param response HTTP response
     * @throws ServletException nếu có lỗi servlet
     * @throws IOException nếu có lỗi I/O
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Bước 1: Kiểm tra có phải AJAX request không
        // Frontend sẽ gọi AJAX định kỳ để cập nhật trạng thái ghế real-time
        String isAjax = request.getParameter(BookingConstants.PARAM_AJAX);
        if (BookingConstants.PARAM_AJAX_TRUE.equals(isAjax)) {
            // Bước 2: Xử lý AJAX request - trả về JSON chứa trạng thái ghế mới nhất
            handleAjaxSeatUpdate(request, response);
            return;
        }
        
        // Bước 3: Không phải AJAX - xử lý request GET thông thường
        HttpSession session = request.getSession();
        BookingSession bookingSession = BookingSessionManager.getBookingSession(session);
        
        // Kiểm tra đã chọn suất chiếu chưa (từ Bước 1)
        if (bookingSession.getScreeningID() <= 0) {
            // Chưa chọn suất chiếu, redirect về Bước 1
            response.sendRedirect(request.getContextPath() + BookingConstants.PATH_SELECT_SCREENING);
            return;
        }
        
        // Bước 4: Load thông tin chi tiết của suất chiếu
        Screening screening = screeningDAO.getScreeningDetail(bookingSession.getScreeningID());
        if (screening == null) {
            // Suất chiếu không tồn tại, redirect về Bước 1
            response.sendRedirect(request.getContextPath() + BookingConstants.PATH_SELECT_SCREENING);
            return;
        }
        
        // Bước 5: Load tất cả ghế trong phòng chiếu
        // Bao gồm cả ghế available, booked, reserved, unavailable, maintenance
        List<Seat> allSeats = seatDAO.getSeatsByRoomID(screening.getRoomID());
        
        // Bước 6: Phân loại trạng thái ghế
        
        // Lọc các ghế có trạng thái Unavailable hoặc Maintenance
        // Các ghế này không thể chọn được (do hỏng, bảo trì, hoặc không sử dụng)
        // Lưu ý: Vẫn hiển thị trong UI nhưng đánh dấu là không thể chọn
        List<Integer> unavailableStatusSeatIDs = allSeats.stream()
            .filter(seat -> BookingConstants.SEAT_STATUS_UNAVAILABLE.equals(seat.getStatus()) 
                         || BookingConstants.SEAT_STATUS_MAINTENANCE.equals(seat.getStatus()))
            .map(Seat::getSeatID)
            .collect(Collectors.toList());
        
        // Lấy danh sách ghế đã được đặt (booked)
        // Ghế booked là ghế đã có ticket trong database (đã thanh toán thành công)
        List<Integer> bookedSeatIDs = seatDAO.getBookedSeatsForScreening(bookingSession.getScreeningID());
        
        // Lấy danh sách ghế đang được giữ tạm thời (reserved)
        // Ghế reserved là ghế đang được user khác giữ (chưa thanh toán, có reservation record)
        List<Integer> reservedSeatIDs = seatDAO.getReservedSeatsForScreening(bookingSession.getScreeningID());
        
        // Loại bỏ các ghế mà session hiện tại đang giữ khỏi danh sách reserved
        // (vì những ghế đó sẽ được hiển thị là "selected" chứ không phải "reserved")
        if (bookingSession.getReservationSessionID() != null) {
            reservedSeatIDs = reservedSeatIDs.stream()
                .filter(id -> !bookingSession.getSelectedSeatIDs().contains(id))
                .collect(Collectors.toList());
        }
        
        // Gửi dữ liệu đến JSP để hiển thị
        request.setAttribute("screening", screening);                      // Thông tin suất chiếu
        request.setAttribute("allSeats", allSeats);                        // Tất cả ghế trong phòng
        request.setAttribute("bookedSeatIDs", bookedSeatIDs);              // Danh sách ID ghế đã đặt
        request.setAttribute("reservedSeatIDs", reservedSeatIDs);          // Danh sách ID ghế đang được giữ
        request.setAttribute("unavailableStatusSeatIDs", unavailableStatusSeatIDs); // Danh sách ID ghế không khả dụng
        request.setAttribute("bookingSession", bookingSession);            // Booking session hiện tại
        
        // Bước 7: Forward đến trang JSP để hiển thị seat map
        request.getRequestDispatcher(BookingConstants.JSP_SELECT_SEATS).forward(request, response);
    }
    
    /**
     * Xử lý AJAX request để cập nhật trạng thái ghế real-time
     * 
     * Flow xử lý:
     * Bước 1: Lấy screeningID từ BookingSession hoặc request parameter
     * Bước 2: Validate screeningID
     * Bước 3: Lấy danh sách ghế đã đặt (booked) từ database
     * Bước 4: Lấy danh sách ghế đang được giữ (reserved) từ database
     * Bước 5: Loại bỏ các ghế của session hiện tại khỏi danh sách reserved
     * Bước 6: Xây dựng JSON response chứa trạng thái ghế
     * Bước 7: Trả về JSON response cho frontend
     * 
     * Mục đích: Frontend sẽ gọi AJAX này định kỳ (ví dụ mỗi 5 giây) để cập nhật
     * trạng thái ghế real-time, giúp người dùng thấy ghế nào vừa được người khác chọn.
     * 
     * JSON Response format:
     * {
     *   "bookedSeats": [1, 2, 3, ...],
     *   "reservedSeats": [4, 5, 6, ...]
     * }
     * 
     * @param request HTTP request (có thể chứa screeningID parameter)
     * @param response HTTP response để trả về JSON
     * @throws IOException nếu có lỗi I/O
     */
    private void handleAjaxSeatUpdate(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        
        HttpSession session = request.getSession();
        BookingSession bookingSession = BookingSessionManager.getBookingSession(session);
        
        // Bước 1: Lấy screeningID từ BookingSession
        int screeningID = bookingSession.getScreeningID();
        if (screeningID <= 0) {
            // Nếu không có trong session, thử lấy từ request parameter
            String screeningIDParam = request.getParameter("screeningID");
            if (screeningIDParam != null) {
                try {
                    screeningID = Integer.parseInt(screeningIDParam);
                } catch (NumberFormatException e) {
                    // screeningID không hợp lệ
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    return;
                }
            } else {
                // Không có screeningID, trả về lỗi
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }
        }
        
        // Bước 3: Lấy danh sách ghế đã được đặt (booked)
        // Ghế booked là ghế đã có ticket trong database
        List<Integer> bookedSeatIDs = seatDAO.getBookedSeatsForScreening(screeningID);
        
        // Bước 4: Lấy danh sách ghế đang được giữ tạm thời (reserved)
        // Ghế reserved là ghế đang được user khác giữ (chưa thanh toán)
        List<Integer> reservedSeatIDs = seatDAO.getReservedSeatsForScreening(screeningID);
        
        // Bước 5: Loại bỏ các ghế của session hiện tại khỏi danh sách reserved
        // (vì những ghế đó sẽ được hiển thị là "selected" chứ không phải "reserved")
        if (bookingSession.getReservationSessionID() != null) {
            final String sessionID = bookingSession.getReservationSessionID();
            reservedSeatIDs = reservedSeatIDs.stream()
                .filter(id -> !bookingSession.getSelectedSeatIDs().contains(id))
                .collect(Collectors.toList());
        }
        
        // Bước 6: Xây dựng JSON response thủ công (không dùng thư viện JSON)
        // Format: {"bookedSeats":[1,2,3], "reservedSeats":[4,5,6]}
        StringBuilder json = new StringBuilder();
        json.append("{");
        
        // Thêm mảng bookedSeats
        json.append("\"bookedSeats\":[");
        for (int i = 0; i < bookedSeatIDs.size(); i++) {
            json.append(bookedSeatIDs.get(i));
            // Thêm dấu phẩy giữa các phần tử (trừ phần tử cuối)
            if (i < bookedSeatIDs.size() - 1) {
                json.append(",");
            }
        }
        json.append("],");
        
        // Thêm mảng reservedSeats
        json.append("\"reservedSeats\":[");
        for (int i = 0; i < reservedSeatIDs.size(); i++) {
            json.append(reservedSeatIDs.get(i));
            // Thêm dấu phẩy giữa các phần tử (trừ phần tử cuối)
            if (i < reservedSeatIDs.size() - 1) {
                json.append(",");
            }
        }
        json.append("]");
        
        json.append("}");
        
        // Bước 7: Trả về JSON response cho frontend
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        out.print(json.toString());
        out.flush();
    }
    
    /**
     * Xử lý request POST - xử lý khi người dùng chọn ghế và submit
     * 
     * Flow xử lý:
     * Bước 1: Kiểm tra đã chọn suất chiếu chưa
     * Bước 2: Lấy danh sách seatIDs từ form
     * Bước 3: Validation số lượng ghế (1-8 ghế)
     * Bước 4: Parse seatIDs sang integer và validate
     * Bước 5: Tạo hoặc lấy reservation session ID
     * Bước 6: Kiểm tra ghế còn available không (lần kiểm tra đầu tiên)
     * Bước 7: Reserve ghế tạm thời trong database (atomic operation)
     * Bước 8: Xử lý race condition nếu reserve thất bại
     * Bước 9: Tính giá vé dựa trên loại ghế (price multiplier)
     * Bước 10: Lưu thông tin ghế vào BookingSession
     * Bước 11: Redirect đến Bước 3: Chọn đồ ăn
     * 
     * Xử lý Race Condition:
     * - Có thể xảy ra khi nhiều user cùng chọn ghế cùng lúc
     * - Kiểm tra available trước khi reserve (Bước 6)
     * - Reserve là atomic operation với database constraint (Bước 7)
     * - Nếu reserve thất bại, kiểm tra lại và thông báo ghế nào đã bị chọn (Bước 8)
     * 
     * @param request HTTP request chứa seatIDs từ form
     * @param response HTTP response để redirect
     * @throws ServletException nếu có lỗi servlet
     * @throws IOException nếu có lỗi I/O
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        BookingSession bookingSession = BookingSessionManager.getBookingSession(session);
        
        // Bước 1: Kiểm tra đã chọn suất chiếu chưa (từ Bước 1)
        if (bookingSession.getScreeningID() <= 0) {
            // Chưa chọn suất chiếu, redirect về Bước 1
            response.sendRedirect(request.getContextPath() + BookingConstants.PATH_SELECT_SCREENING);
            return;
        }
        
        try {
            // Bước 2: Lấy danh sách seatIDs từ form
            // Form sẽ gửi nhiều giá trị với cùng tên parameter "seatIDs"
            String[] seatIDStrings = request.getParameterValues(BookingConstants.PARAM_SEAT_IDS);
            
            // Kiểm tra có chọn ghế nào không
            if (seatIDStrings == null || seatIDStrings.length == 0) {
                request.setAttribute("error", "Vui lòng chọn ít nhất một ghế!");
                doGet(request, response);
                return;
            }
            
            // Bước 3: Validation số lượng ghế
            // Giới hạn: tối thiểu 1 ghế, tối đa 8 ghế
            if (seatIDStrings.length < BookingConstants.MIN_SEATS || seatIDStrings.length > BookingConstants.MAX_SEATS) {
                request.setAttribute("error", "Vui lòng chọn từ " + BookingConstants.MIN_SEATS + " đến " + BookingConstants.MAX_SEATS + " ghế!");
                doGet(request, response);
                return;
            }
            
            // Bước 4: Parse seatIDs sang integer và validate
            List<Integer> selectedSeatIDs = new ArrayList<>();
            for (String seatIDStr : seatIDStrings) {
                // Kiểm tra seatID không rỗng
                if (seatIDStr == null || seatIDStr.trim().isEmpty()) {
                    throw new NumberFormatException("Empty seat ID");
                }
                try {
                    // Parse sang integer
                    int seatID = Integer.parseInt(seatIDStr.trim());
                    selectedSeatIDs.add(seatID);
                } catch (NumberFormatException e) {
                    // SeatID không phải số hợp lệ
                    throw new NumberFormatException("Invalid seat ID: " + seatIDStr);
                }
            }
            
            // Bước 5: Tạo hoặc lấy reservation session ID
            // Reservation session ID dùng để nhận biết các ghế được giữ bởi session này
            // Nếu chưa có, tạo mới (UUID)
            String reservationSessionID = bookingSession.getReservationSessionID();
            if (reservationSessionID == null) {
                reservationSessionID = BookingSessionManager.generateReservationSessionID();
                bookingSession.setReservationSessionID(reservationSessionID);
            }
            
            // Bước 6: Kiểm tra ghế còn available không (lần kiểm tra đầu tiên)
            // Kiểm tra trước khi reserve để tránh reserve ghế đã bị chọn
            if (!seatDAO.areSeatsAvailable(selectedSeatIDs, bookingSession.getScreeningID(), reservationSessionID)) {
                // Có ghế không còn available, lấy danh sách ghế không available
                List<Integer> unavailableSeats = seatDAO.getUnavailableSeats(selectedSeatIDs, bookingSession.getScreeningID(), reservationSessionID);
                
                // Lấy tên ghế (label) để hiển thị thông báo lỗi rõ ràng hơn
                List<String> unavailableLabels = new ArrayList<>();
                for (Integer seatID : unavailableSeats) {
                    Seat seat = seatDAO.getSeatByID(seatID);
                    if (seat != null) {
                        unavailableLabels.add(seat.getSeatLabel());
                    }
                }
                
                // Hiển thị thông báo lỗi với tên ghế cụ thể
                String errorMsg = "Ghế sau đã được người khác đặt: " + String.join(", ", unavailableLabels) + ". Vui lòng chọn ghế khác!";
                request.setAttribute("error", errorMsg);
                doGet(request, response);
                return;
            }
            
            // Bước 7: Reserve ghế tạm thời trong database (atomic operation)
            // Operation này được bảo vệ bởi database constraint để tránh race condition
            // Nếu nhiều user cùng reserve cùng một ghế, chỉ một user thành công
            boolean reserved = seatDAO.reserveSeats(selectedSeatIDs, bookingSession.getScreeningID(), reservationSessionID);
            
            if (!reserved) {
                // Bước 8: Xử lý race condition - reserve thất bại
                // Có thể xảy ra khi user khác vừa reserve ghế giữa lúc kiểm tra (Bước 6) và reserve (Bước 7)
                // Lấy danh sách ghế không available sau khi reserve thất bại
                List<Integer> unavailableSeats = seatDAO.getUnavailableSeats(selectedSeatIDs, bookingSession.getScreeningID(), reservationSessionID);
                
                if (!unavailableSeats.isEmpty()) {
                    // Lấy tên ghế để hiển thị thông báo
                    List<String> unavailableLabels = new ArrayList<>();
                    for (Integer seatID : unavailableSeats) {
                        Seat seat = seatDAO.getSeatByID(seatID);
                        if (seat != null) {
                            unavailableLabels.add(seat.getSeatLabel());
                        }
                    }
                    
                    // Thông báo ghế vừa bị người khác chọn
                    String errorMsg = "Xin lỗi! Ghế " + String.join(", ", unavailableLabels) + 
                                     " vừa được người khác đặt. Vui lòng chọn ghế khác!";
                    request.setAttribute("error", errorMsg);
                } else {
                    // Không xác định được ghế nào không available
                    request.setAttribute("error", "Không thể đặt chỗ. Vui lòng thử lại!");
                }
                
                // Hiển thị lại form với thông báo lỗi
                doGet(request, response);
                return;
            }
            
            // Bước 9: Reserve thành công - tính giá vé dựa trên loại ghế
            // Mỗi loại ghế có price multiplier khác nhau (ví dụ: VIP = 1.5x, Normal = 1.0x)
            List<String> seatLabels = new ArrayList<>();
            double ticketSubtotal = 0;
            double baseTicketPrice = bookingSession.getTicketPrice();
            
            for (Integer seatID : selectedSeatIDs) {
                Seat seat = seatDAO.getSeatByID(seatID);
                if (seat != null) {
                    // Lưu tên ghế (ví dụ: "A1", "B5") để hiển thị
                    seatLabels.add(seat.getSeatLabel());
                    // Tính giá vé: baseTicketPrice * priceMultiplier
                    // Ví dụ: 100,000 * 1.5 = 150,000 (ghế VIP)
                    ticketSubtotal += baseTicketPrice * seat.getPriceMultiplier();
                }
            }
            
            // Bước 10: Lưu thông tin ghế vào BookingSession
            bookingSession.setSelectedSeatIDs(selectedSeatIDs);                    // Danh sách ID ghế đã chọn
            bookingSession.setSelectedSeatLabels(seatLabels);                      // Danh sách tên ghế (để hiển thị)
            bookingSession.setReservationExpiry(BookingSessionManager.getReservationExpiry()); // Thời gian hết hạn reservation (thường 15 phút)
            
            // Lưu tổng giá vé (chưa tính đồ ăn và discount)
            bookingSession.setTicketSubtotal(ticketSubtotal);
            
            // QUAN TRỌNG: Lưu lại BookingSession vào session để đảm bảo persistence
            // Cần thiết vì có thể session đã được serialize/deserialize
            session.setAttribute("bookingSession", bookingSession);
            
            // Bước 11: Redirect đến Bước 3: Chọn đồ ăn
            response.sendRedirect(request.getContextPath() + BookingConstants.PATH_SELECT_FOOD);
            
        } catch (NumberFormatException e) {
            // Xử lý lỗi khi parse seatID không thành công
            request.setAttribute("error", "Dữ liệu không hợp lệ!");
            doGet(request, response);
        }
    }
}

