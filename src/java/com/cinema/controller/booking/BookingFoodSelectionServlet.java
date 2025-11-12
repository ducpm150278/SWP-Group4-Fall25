package com.cinema.controller.booking;


import com.cinema.dal.ComboDAO;
import com.cinema.dal.FoodDAO;
import com.cinema.entity.BookingSession;
import com.cinema.entity.Combo;
import com.cinema.entity.Food;
import com.cinema.utils.BookingSessionManager;
import com.cinema.utils.Constants;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Servlet xử lý bước 3: Chọn đồ ăn và combo (Tùy chọn)
 */
@WebServlet(name = "BookingFoodSelectionServlet", urlPatterns = {"/booking/select-food"})
public class BookingFoodSelectionServlet extends HttpServlet {
    
    private ComboDAO comboDAO;
    private FoodDAO foodDAO;
    
    @Override
    public void init() throws ServletException {
        comboDAO = new ComboDAO();
        foodDAO = new FoodDAO();
    }
    
    /**
     * Xử lý request GET - hiển thị trang chọn đồ ăn và combo
     * Flow: Validate screening/seats -> Kiểm tra reservation expiry -> Lấy danh sách đồ ăn/combo -> Tính thời gian còn lại -> Hiển thị
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        BookingSession bookingSession = BookingSessionManager.getBookingSession(session);
        
        // Bước 1: Kiểm tra suất chiếu và ghế đã được chọn chưa
        // Phải hoàn thành các bước trước (chọn suất chiếu và ghế) trước khi chọn đồ ăn
        if (bookingSession.getScreeningID() <= 0 || 
            bookingSession.getSelectedSeatIDs() == null || 
            bookingSession.getSelectedSeatIDs().isEmpty()) {
            // Chưa chọn suất chiếu hoặc ghế - quay về bước đầu
            response.sendRedirect(request.getContextPath() + Constants.URL_BOOKING_SELECT_SCREENING);
            return;
        }
        
        // Bước 2: Kiểm tra reservation có hết hạn không
        // Reservation có thời gian hết hạn (15 phút) để đảm bảo ghế không bị giữ quá lâu
        // Nếu hết hạn, người dùng phải bắt đầu lại từ đầu
        if (BookingSessionManager.isReservationExpired(bookingSession.getReservationExpiry())) {
            request.setAttribute("error", "Thời gian đặt chỗ đã hết. Vui lòng đặt lại!");
            response.sendRedirect(request.getContextPath() + Constants.URL_BOOKING_SELECT_SCREENING);
            return;
        }
        
        // Bước 3: Lấy danh sách combo và đồ ăn có sẵn
        // Chỉ hiển thị các combo và đồ ăn có trạng thái available
        List<Combo> combos = comboDAO.getAvailableCombos();
        List<Food> foods = foodDAO.getAllAvailableFood();
        
        // Bước 4: Truyền dữ liệu đến JSP
        request.setAttribute("combos", combos);
        request.setAttribute("foods", foods);
        request.setAttribute("bookingSession", bookingSession);
        
        // Bước 5: Tính thời gian còn lại của reservation (tính bằng giây)
        // Thời gian này được hiển thị trên frontend để người dùng biết còn bao nhiêu thời gian
        long remainingSeconds = BookingSessionManager.getRemainingSeconds(bookingSession.getReservationExpiry());
        request.setAttribute("remainingSeconds", remainingSeconds);
        
        // Bước 6: Chuyển tiếp đến trang JSP chọn đồ ăn
        request.getRequestDispatcher(Constants.JSP_BOOKING_SELECT_FOOD).forward(request, response);
    }
    
    /**
     * Xử lý request POST - xử lý khi người dùng chọn đồ ăn/combo hoặc skip
     * Flow: Validate screening/seats -> Xử lý skip action -> Parse combo/food selections -> Tính subtotal -> Lưu session -> Chuyển bước
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        BookingSession bookingSession = BookingSessionManager.getBookingSession(session);
        
        // Bước 1: Kiểm tra suất chiếu và ghế đã được chọn chưa
        // Đảm bảo người dùng đã hoàn thành các bước trước
        if (bookingSession.getScreeningID() <= 0 || 
            bookingSession.getSelectedSeatIDs() == null || 
            bookingSession.getSelectedSeatIDs().isEmpty()) {
            response.sendRedirect(request.getContextPath() + Constants.URL_BOOKING_SELECT_SCREENING);
            return;
        }
        
        // Bước 2: Kiểm tra người dùng có muốn bỏ qua bước chọn đồ ăn không
        // Người dùng có thể chọn "Bỏ qua" để không mua đồ ăn/combo
        String action = request.getParameter("action");
        if (Constants.ACTION_SKIP.equals(action)) {
            // Xóa tất cả lựa chọn đồ ăn/combo (nếu có từ lần trước)
            bookingSession.setSelectedCombos(new HashMap<>());
            bookingSession.setSelectedFoods(new HashMap<>());
            bookingSession.setFoodSubtotal(0);
            
            // Chuyển hướng trực tiếp đến trang thanh toán
            response.sendRedirect(request.getContextPath() + Constants.URL_BOOKING_PAYMENT);
            return;
        }
        
        try {
            // Bước 3: Lấy danh sách combo đã chọn từ form
            // Form gửi 2 mảng: comboIDs và comboQuantities (số lượng tương ứng)
            Map<Integer, Integer> selectedCombos = new HashMap<>();
            String[] comboIDs = request.getParameterValues("comboIDs");
            String[] comboQuantities = request.getParameterValues("comboQuantities");
            
            // Parse combo IDs và quantities thành Map<comboID, quantity>
            if (comboIDs != null && comboQuantities != null) {
                for (int i = 0; i < comboIDs.length; i++) {
                    int comboID = Integer.parseInt(comboIDs[i]);
                    int quantity = Integer.parseInt(comboQuantities[i]);
                    // Chỉ lưu combo có quantity > 0
                    if (quantity > 0) {
                        selectedCombos.put(comboID, quantity);
                    }
                }
            }
            
            // Bước 4: Lấy danh sách đồ ăn đã chọn từ form
            // Form gửi 2 mảng: foodIDs và foodQuantities (số lượng tương ứng)
            Map<Integer, Integer> selectedFoods = new HashMap<>();
            String[] foodIDs = request.getParameterValues("foodIDs");
            String[] foodQuantities = request.getParameterValues("foodQuantities");
            
            // Parse food IDs và quantities thành Map<foodID, quantity>
            if (foodIDs != null && foodQuantities != null) {
                for (int i = 0; i < foodIDs.length; i++) {
                    int foodID = Integer.parseInt(foodIDs[i]);
                    int quantity = Integer.parseInt(foodQuantities[i]);
                    // Chỉ lưu food có quantity > 0
                    if (quantity > 0) {
                        selectedFoods.put(foodID, quantity);
                    }
                }
            }
            
            // Bước 5: Tính tổng tiền đồ ăn (food subtotal)
            double foodSubtotal = 0;
            
            // Bước 5.1: Tính tổng tiền combo
            // Sử dụng discountPrice nếu có, nếu không thì dùng totalPrice
            for (Map.Entry<Integer, Integer> entry : selectedCombos.entrySet()) {
                Combo combo = comboDAO.getComboById(entry.getKey());
                // Kiểm tra combo tồn tại và còn available
                if (combo != null && combo.getIsAvailable()) {
                    // Ưu tiên dùng discountPrice nếu có, nếu không thì dùng totalPrice
                    double price = combo.getDiscountPrice() != null ? 
                                  combo.getDiscountPrice().doubleValue() : 
                                  combo.getTotalPrice().doubleValue();
                    // Tính tổng: giá * số lượng
                    foodSubtotal += price * entry.getValue();
                }
            }
            
            // Bước 5.2: Tính tổng tiền đồ ăn riêng lẻ
            // Đồ ăn riêng lẻ không có discount, chỉ có giá cố định
            for (Map.Entry<Integer, Integer> entry : selectedFoods.entrySet()) {
                Food food = foodDAO.getFoodById(entry.getKey());
                // Kiểm tra food tồn tại và còn available
                if (food != null && food.getIsAvailable()) {
                    // Tính tổng: giá * số lượng
                    foodSubtotal += food.getPrice().doubleValue() * entry.getValue();
                }
            }
            
            // Bước 6: Lưu lựa chọn đồ ăn/combo vào booking session
            bookingSession.setSelectedCombos(selectedCombos);
            bookingSession.setSelectedFoods(selectedFoods);
            bookingSession.setFoodSubtotal(foodSubtotal);
            
            // Bước 7: QUAN TRỌNG: Lưu bookingSession lại vào session để đảm bảo persistence
            // BookingSession là object, cần set lại vào session sau khi modify
            session.setAttribute(Constants.SESSION_BOOKING_SESSION, bookingSession);
            
            // Bước 8: Chuyển hướng đến bước tiếp theo - thanh toán
            response.sendRedirect(request.getContextPath() + Constants.URL_BOOKING_PAYMENT);
            
        } catch (NumberFormatException e) {
            // Xử lý lỗi khi comboID/foodID hoặc quantity không phải là số hợp lệ
            request.setAttribute("error", "Dữ liệu không hợp lệ!");
            doGet(request, response);
        }
    }
}

