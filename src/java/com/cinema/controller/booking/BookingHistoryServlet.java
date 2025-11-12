package com.cinema.controller.booking;

import com.cinema.dal.BookingDAO;
import com.cinema.dal.ReviewDAO;
import com.cinema.entity.BookingDetailDTO;
import com.cinema.utils.Constants;
import com.cinema.utils.SessionUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
/**
 * Servlet xử lý lịch sử đặt vé và quản lý đặt vé của người dùng
 */
@WebServlet(name = "BookingHistoryServlet", urlPatterns = {"/booking-history"})
public class BookingHistoryServlet extends HttpServlet {
    
    private BookingDAO bookingDAO;
    private ReviewDAO reviewDAO;
    @Override
    public void init() throws ServletException {
        bookingDAO = new BookingDAO();
        reviewDAO = new ReviewDAO();
    }
    
    /**
     * Xử lý request GET - hiển thị lịch sử đặt vé
     * Flow: Kiểm tra đăng nhập -> Đọc session messages -> Lấy filter -> Lấy danh sách booking -> Lấy danh sách phim đã review -> Hiển thị
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Integer userID = SessionUtils.getUserId(session);
        
        // Bước 1: Kiểm tra người dùng đã đăng nhập chưa
        // Chỉ người dùng đã đăng nhập mới có thể xem lịch sử đặt vé
        if (userID == null) {
            response.sendRedirect(request.getContextPath() + Constants.URL_AUTH_LOGIN);
            return;
        }
        
        // Bước 2: Đọc thông báo từ session (nếu có)
        // Thông báo này được set từ các action khác (ví dụ: hủy vé thành công)
        String message = (String) session.getAttribute(Constants.SESSION_MESSAGE);
        if (message != null) {
            request.setAttribute("message", message);
            // Xóa message khỏi session sau khi đã đọc để không hiển thị lại
            session.removeAttribute(Constants.SESSION_MESSAGE);
        }
        String error = (String) session.getAttribute(Constants.SESSION_ERROR);
        if (error != null) {
            request.setAttribute("error", error);
            // Xóa error khỏi session sau khi đã đọc
            session.removeAttribute(Constants.SESSION_ERROR);
        }
        
        // Bước 3: Lấy filter parameter từ request
        // Filter có thể là: "Confirmed", "Cancelled", "Completed", hoặc "all"
        String statusFilter = request.getParameter("status");
        
        // Bước 4: Lấy danh sách booking details của người dùng
        List<BookingDetailDTO> bookingDetails;
        
        if (statusFilter != null && !statusFilter.isEmpty() && !Constants.FILTER_ALL.equals(statusFilter)) {
            // Có filter - lấy tất cả booking rồi filter trong Java
            // Lấy tất cả booking trước
            bookingDetails = bookingDAO.getUserBookingDetails(userID);
            // Filter theo status (case-insensitive)
            bookingDetails = bookingDetails.stream()
                .filter(b -> statusFilter.equalsIgnoreCase(b.getStatus()))
                .toList();
        } else {
            // Không có filter hoặc filter = "all" - lấy tất cả booking
            bookingDetails = bookingDAO.getUserBookingDetails(userID);
        }
        
        // Bước 5: Lấy danh sách movie IDs mà người dùng đã review
        // Dùng để hiển thị nút "Đánh giá" chỉ cho các phim chưa review
        List<Integer> reviewedMovieIds = reviewDAO.getReviewedMovieIds(userID);
        if (reviewedMovieIds == null) {
            reviewedMovieIds = new ArrayList<>();
        }
        
        // Bước 6: Truyền dữ liệu đến JSP
        request.setAttribute("bookingDetails", bookingDetails);                    // Danh sách booking
        request.setAttribute("statusFilter", statusFilter != null ? statusFilter : Constants.FILTER_ALL);  // Filter hiện tại
        request.setAttribute("reviewedMovieIds", reviewedMovieIds);                // Danh sách phim đã review
        
        // Bước 7: Chuyển tiếp đến trang JSP lịch sử đặt vé
        request.getRequestDispatcher(Constants.JSP_BOOKING_HISTORY).forward(request, response);
    }
    
    /**
     * Xử lý request POST - xử lý các action (hủy vé, v.v.)
     * Flow: Kiểm tra đăng nhập -> Xác định action -> Validate booking -> Xử lý action -> Redirect
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Integer userID = SessionUtils.getUserId(session);
        
        // Bước 1: Kiểm tra người dùng đã đăng nhập chưa
        if (userID == null) {
            response.sendRedirect(request.getContextPath() + Constants.URL_AUTH_LOGIN);
            return;
        }
        
        // Bước 2: Lấy action từ form
        String action = request.getParameter("action");
        
        // Bước 3: Xử lý action hủy vé
        if (Constants.ACTION_CANCEL.equals(action)) {
            // Lấy booking ID từ form
            int bookingID = Integer.parseInt(request.getParameter("bookingID"));
            
            // Bước 3.1: Xác thực booking thuộc về người dùng hiện tại
            // Đảm bảo người dùng chỉ có thể hủy booking của chính họ
            BookingDetailDTO booking = bookingDAO.getBookingDetailByID(bookingID, userID);
            
            if (booking == null) {
                // Booking không tồn tại hoặc không thuộc về người dùng
                request.setAttribute("error", "Không tìm thấy đơn đặt vé!");
                doGet(request, response);
                return;
            }
            
            // Bước 3.2: Kiểm tra booking có thể hủy được không
            // Chỉ có thể hủy các booking chưa chiếu phim (screening chưa bắt đầu)
            if (!booking.canBeCancelled()) {
                request.setAttribute("error", "Không thể yêu cầu hủy đơn đặt vé này. Chỉ có thể hủy các đơn chưa chiếu phim.");
                doGet(request, response);
                return;
            }
            
            // Bước 3.3: Gửi yêu cầu refund thay vì hủy ngay lập tức
            // Hệ thống sẽ gửi yêu cầu refund, nhân viên sẽ xử lý và hoàn tiền
            boolean requested = bookingDAO.requestRefund(bookingID);
            if (requested) {
                // Gửi yêu cầu thành công - lưu thông báo vào session
                session.setAttribute(Constants.SESSION_MESSAGE, "Đã gửi yêu cầu hủy vé thành công! Vui lòng chờ nhân viên xử lý.");
            } else {
                // Gửi yêu cầu thất bại - có thể do lỗi database
                session.setAttribute(Constants.SESSION_ERROR, "Có lỗi xảy ra khi gửi yêu cầu hủy vé.");
            }
        }
        
        // Bước 4: Redirect về trang lịch sử đặt vé
        // Thông báo sẽ được hiển thị trong doGet()
        response.sendRedirect(request.getContextPath() + Constants.URL_BOOKING_HISTORY);
    }
}

