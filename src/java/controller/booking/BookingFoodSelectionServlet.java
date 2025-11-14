package controller.booking;

import dal.ComboDAO;
import dal.FoodDAO;
import entity.BookingSession;
import entity.Combo;
import entity.Food;
import utils.BookingSessionManager;

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
 * Servlet xử lý Bước 3 của quy trình đặt vé: Chọn đồ ăn và combo (tùy chọn)
 * 
 * Flow tổng quan:
 * 1. Kiểm tra đã chọn suất chiếu và ghế chưa (từ Bước 1 và 2)
 * 2. Kiểm tra reservation còn hạn không (thường 15 phút)
 * 3. Load danh sách combo và đồ ăn đang có sẵn
 * 4. Tính thời gian còn lại của reservation
 * 5. Hiển thị form chọn đồ ăn/combo
 * 6. Người dùng có thể:
 *    - Chọn combo và đồ ăn
 *    - Hoặc bỏ qua (skip) bước này
 * 7. Parse selections và tính subtotal
 * 8. Lưu thông tin vào BookingSession
 * 9. Chuyển sang Bước 4: Thanh toán
 * 
 * Lưu ý: Bước này là tùy chọn, người dùng có thể bỏ qua và không chọn đồ ăn.
 * 
 * Endpoint: /booking/select-food
 */
@WebServlet(name = "BookingFoodSelectionServlet", urlPatterns = {"/booking/select-food"})
public class BookingFoodSelectionServlet extends HttpServlet {
    
    /** DAO để thao tác với dữ liệu combo */
    private ComboDAO comboDAO;
    /** DAO để thao tác với dữ liệu đồ ăn */
    private FoodDAO foodDAO;
    
    /**
     * Khởi tạo servlet - tạo các DAO instances
     */
    @Override
    public void init() throws ServletException {
        comboDAO = new ComboDAO();
        foodDAO = new FoodDAO();
    }
    
    /**
     * Xử lý request GET - hiển thị form chọn đồ ăn/combo
     * 
     * Flow xử lý:
     * Bước 1: Kiểm tra đã chọn suất chiếu và ghế chưa
     * Bước 2: Kiểm tra reservation còn hạn không (tránh đặt vé quá lâu)
     * Bước 3: Load danh sách combo đang có sẵn
     * Bước 4: Load danh sách đồ ăn đang có sẵn
     * Bước 5: Tính thời gian còn lại của reservation (để hiển thị countdown)
     * Bước 6: Forward đến trang JSP để hiển thị form
     * 
     * @param request HTTP request
     * @param response HTTP response
     * @throws ServletException nếu có lỗi servlet
     * @throws IOException nếu có lỗi I/O
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        BookingSession bookingSession = BookingSessionManager.getBookingSession(session);
        
        // Bước 1: Kiểm tra đã chọn suất chiếu và ghế chưa (từ Bước 1 và 2)
        // Phải có đầy đủ thông tin từ các bước trước mới được vào bước này
        if (bookingSession.getScreeningID() <= 0 || 
            bookingSession.getSelectedSeatIDs() == null || 
            bookingSession.getSelectedSeatIDs().isEmpty()) {
            // Chưa đủ thông tin, redirect về Bước 1
            response.sendRedirect(request.getContextPath() + BookingConstants.PATH_SELECT_SCREENING);
            return;
        }
        
        // Bước 2: Kiểm tra reservation còn hạn không
        // Reservation thường có thời hạn 15 phút, sau đó ghế sẽ được giải phóng
        if (BookingSessionManager.isReservationExpired(bookingSession.getReservationExpiry())) {
            // Reservation đã hết hạn, yêu cầu đặt lại từ đầu
            request.setAttribute("error", "Thời gian đặt chỗ đã hết. Vui lòng đặt lại!");
            response.sendRedirect(request.getContextPath() + BookingConstants.PATH_SELECT_SCREENING);
            return;
        }
        
        // Bước 3: Load danh sách combo đang có sẵn
        // Chỉ load các combo có trạng thái available
        List<Combo> combos = comboDAO.getAvailableCombos();
        
        // Bước 4: Load danh sách đồ ăn đang có sẵn
        // Chỉ load các đồ ăn có trạng thái available
        List<Food> foods = foodDAO.getAllAvailableFood();
        
        // Gửi dữ liệu đến JSP
        request.setAttribute("combos", combos);                    // Danh sách combo
        request.setAttribute("foods", foods);                      // Danh sách đồ ăn
        request.setAttribute("bookingSession", bookingSession);    // Booking session hiện tại
        
        // Bước 5: Tính thời gian còn lại của reservation (để hiển thị countdown)
        // Frontend sẽ dùng số giây này để hiển thị countdown timer
        long remainingSeconds = BookingSessionManager.getRemainingSeconds(bookingSession.getReservationExpiry());
        request.setAttribute("remainingSeconds", remainingSeconds);
        
        // Bước 6: Forward đến trang JSP để hiển thị form chọn đồ ăn/combo
        request.getRequestDispatcher(BookingConstants.JSP_SELECT_FOOD).forward(request, response);
    }
    
    /**
     * Xử lý request POST - xử lý khi người dùng chọn đồ ăn/combo hoặc skip
     * 
     * Flow xử lý:
     * Bước 1: Kiểm tra đã chọn suất chiếu và ghế chưa
     * Bước 2: Kiểm tra action - nếu là "skip" thì bỏ qua bước này
     * Bước 3: Nếu không skip, parse selections từ form:
     *    - Parse combo selections (comboID và quantity)
     *    - Parse food selections (foodID và quantity)
     * Bước 4: Tính subtotal cho combo (sử dụng discountPrice nếu có, không thì dùng totalPrice)
     * Bước 5: Tính subtotal cho đồ ăn
     * Bước 6: Tính tổng foodSubtotal (combo + food)
     * Bước 7: Lưu selections và subtotal vào BookingSession
     * Bước 8: Redirect đến Bước 4: Thanh toán
     * 
     * @param request HTTP request chứa selections hoặc action=skip từ form
     * @param response HTTP response để redirect
     * @throws ServletException nếu có lỗi servlet
     * @throws IOException nếu có lỗi I/O
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        BookingSession bookingSession = BookingSessionManager.getBookingSession(session);
        
        // Bước 1: Kiểm tra đã chọn suất chiếu và ghế chưa
        if (bookingSession.getScreeningID() <= 0 || 
            bookingSession.getSelectedSeatIDs() == null || 
            bookingSession.getSelectedSeatIDs().isEmpty()) {
            // Chưa đủ thông tin, redirect về Bước 1
            response.sendRedirect(request.getContextPath() + BookingConstants.PATH_SELECT_SCREENING);
            return;
        }
        
        // Bước 2: Kiểm tra action - nếu người dùng muốn bỏ qua bước chọn đồ ăn
        String action = request.getParameter("action");
        if (BookingConstants.ACTION_SKIP.equals(action)) {
            // Người dùng chọn skip - không chọn đồ ăn/combo
            // Xóa các selections cũ (nếu có) và set subtotal = 0
            bookingSession.setSelectedCombos(new HashMap<>());
            bookingSession.setSelectedFoods(new HashMap<>());
            bookingSession.setFoodSubtotal(0);
            
            // Redirect đến Bước 4: Thanh toán
            response.sendRedirect(request.getContextPath() + BookingConstants.PATH_PAYMENT);
            return;
        }
        
        try {
            // Bước 3: Parse selections từ form
            
            // Parse combo selections: Map<comboID, quantity>
            // Form sẽ gửi 2 arrays: comboIDs[] và comboQuantities[]
            Map<Integer, Integer> selectedCombos = parseComboSelections(request);
            
            // Parse food selections: Map<foodID, quantity>
            // Form sẽ gửi 2 arrays: foodIDs[] và foodQuantities[]
            Map<Integer, Integer> selectedFoods = parseFoodSelections(request);
            
            // Bước 4-6: Tính tổng foodSubtotal
            
            double foodSubtotal = 0;
            
            // Tính subtotal cho combo
            // Sử dụng discountPrice nếu có (combo đang giảm giá), không thì dùng totalPrice
            for (Map.Entry<Integer, Integer> entry : selectedCombos.entrySet()) {
                Combo combo = comboDAO.getComboById(entry.getKey());
                if (combo != null && combo.getIsAvailable()) {
                    // Ưu tiên dùng discountPrice nếu có, không thì dùng totalPrice
                    double price = combo.getDiscountPrice() != null ? 
                                  combo.getDiscountPrice().doubleValue() : 
                                  combo.getTotalPrice().doubleValue();
                    // Tính tổng: price * quantity
                    foodSubtotal += price * entry.getValue();
                }
            }
            
            // Tính subtotal cho đồ ăn
            // Đồ ăn không có discount, chỉ có một giá
            for (Map.Entry<Integer, Integer> entry : selectedFoods.entrySet()) {
                Food food = foodDAO.getFoodById(entry.getKey());
                if (food != null && food.getIsAvailable()) {
                    // Tính tổng: price * quantity
                    foodSubtotal += food.getPrice().doubleValue() * entry.getValue();
                }
            }
            
            // Bước 7: Lưu selections và subtotal vào BookingSession
            bookingSession.setSelectedCombos(selectedCombos);      // Map<comboID, quantity>
            bookingSession.setSelectedFoods(selectedFoods);        // Map<foodID, quantity>
            bookingSession.setFoodSubtotal(foodSubtotal);          // Tổng giá đồ ăn/combo
            
            // QUAN TRỌNG: Lưu lại BookingSession vào session để đảm bảo persistence
            session.setAttribute("bookingSession", bookingSession);
            
            // Bước 8: Redirect đến Bước 4: Thanh toán
            response.sendRedirect(request.getContextPath() + BookingConstants.PATH_PAYMENT);
            
        } catch (NumberFormatException e) {
            // Xử lý lỗi khi parse ID hoặc quantity không thành công
            request.setAttribute("error", "Dữ liệu không hợp lệ!");
            doGet(request, response);
        }
    }
    
    /**
     * Parse combo selections từ request parameters
     * 
     * Form sẽ gửi 2 arrays:
     * - comboIDs[]: Danh sách ID của các combo được chọn
     * - comboQuantities[]: Danh sách số lượng tương ứng với mỗi combo
     * 
     * Ví dụ:
     * comboIDs = [1, 2]
     * comboQuantities = [2, 1]
     * Kết quả: Map {1=2, 2=1} (combo ID 1 với số lượng 2, combo ID 2 với số lượng 1)
     * 
     * @param request HTTP request chứa comboIDs và comboQuantities parameters
     * @return Map<comboID, quantity> chứa các combo được chọn và số lượng
     */
    private Map<Integer, Integer> parseComboSelections(HttpServletRequest request) {
        Map<Integer, Integer> selectedCombos = new HashMap<>();
        String[] comboIDs = request.getParameterValues(BookingConstants.PARAM_COMBO_IDS);
        String[] comboQuantities = request.getParameterValues(BookingConstants.PARAM_COMBO_QUANTITIES);
        
        // Kiểm tra cả 2 arrays phải tồn tại và có cùng độ dài
        if (comboIDs != null && comboQuantities != null && comboIDs.length == comboQuantities.length) {
            for (int i = 0; i < comboIDs.length; i++) {
                // Parse comboID và quantity
                int comboID = Integer.parseInt(comboIDs[i]);
                int quantity = Integer.parseInt(comboQuantities[i]);
                // Chỉ thêm vào map nếu quantity > 0 (người dùng thực sự chọn)
                if (quantity > 0) {
                    selectedCombos.put(comboID, quantity);
                }
            }
        }
        return selectedCombos;
    }
    
    /**
     * Parse food selections từ request parameters
     * 
     * Form sẽ gửi 2 arrays:
     * - foodIDs[]: Danh sách ID của các món ăn được chọn
     * - foodQuantities[]: Danh sách số lượng tương ứng với mỗi món ăn
     * 
     * Ví dụ:
     * foodIDs = [5, 7]
     * foodQuantities = [3, 2]
     * Kết quả: Map {5=3, 7=2} (food ID 5 với số lượng 3, food ID 7 với số lượng 2)
     * 
     * @param request HTTP request chứa foodIDs và foodQuantities parameters
     * @return Map<foodID, quantity> chứa các món ăn được chọn và số lượng
     */
    private Map<Integer, Integer> parseFoodSelections(HttpServletRequest request) {
        Map<Integer, Integer> selectedFoods = new HashMap<>();
        String[] foodIDs = request.getParameterValues(BookingConstants.PARAM_FOOD_IDS);
        String[] foodQuantities = request.getParameterValues(BookingConstants.PARAM_FOOD_QUANTITIES);
        
        // Kiểm tra cả 2 arrays phải tồn tại và có cùng độ dài
        if (foodIDs != null && foodQuantities != null && foodIDs.length == foodQuantities.length) {
            for (int i = 0; i < foodIDs.length; i++) {
                // Parse foodID và quantity
                int foodID = Integer.parseInt(foodIDs[i]);
                int quantity = Integer.parseInt(foodQuantities[i]);
                // Chỉ thêm vào map nếu quantity > 0 (người dùng thực sự chọn)
                if (quantity > 0) {
                    selectedFoods.put(foodID, quantity);
                }
            }
        }
        return selectedFoods;
    }
}

