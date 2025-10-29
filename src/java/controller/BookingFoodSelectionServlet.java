package controller;

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
 * Servlet for Step 3: Select Food and Combos (Optional)
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
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        BookingSession bookingSession = BookingSessionManager.getBookingSession(session);
        
        // Check if screening and seats are selected
        if (bookingSession.getScreeningID() <= 0 || 
            bookingSession.getSelectedSeatIDs() == null || 
            bookingSession.getSelectedSeatIDs().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/booking/select-screening");
            return;
        }
        
        // Check if reservation is expired
        if (BookingSessionManager.isReservationExpired(bookingSession.getReservationExpiry())) {
            request.setAttribute("error", "Thời gian đặt chỗ đã hết. Vui lòng đặt lại!");
            response.sendRedirect(request.getContextPath() + "/booking/select-screening");
            return;
        }
        
        // Get available combos and food
        List<Combo> combos = comboDAO.getAvailableCombos();
        List<Food> foods = foodDAO.getAllAvailableFood();
        
        request.setAttribute("combos", combos);
        request.setAttribute("foods", foods);
        request.setAttribute("bookingSession", bookingSession);
        
        // Calculate remaining time
        long remainingSeconds = BookingSessionManager.getRemainingSeconds(bookingSession.getReservationExpiry());
        request.setAttribute("remainingSeconds", remainingSeconds);
        
        // Forward to food selection page
        request.getRequestDispatcher("/booking/select-food.jsp").forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        BookingSession bookingSession = BookingSessionManager.getBookingSession(session);
        
        // Check if screening and seats are selected
        if (bookingSession.getScreeningID() <= 0 || 
            bookingSession.getSelectedSeatIDs() == null || 
            bookingSession.getSelectedSeatIDs().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/booking/select-screening");
            return;
        }
        
        // Check if user wants to skip food selection
        String action = request.getParameter("action");
        if ("skip".equals(action)) {
            // Clear food selections
            bookingSession.setSelectedCombos(new HashMap<>());
            bookingSession.setSelectedFoods(new HashMap<>());
            bookingSession.setFoodSubtotal(0);
            
            // Redirect to payment
            response.sendRedirect(request.getContextPath() + "/booking/payment");
            return;
        }
        
        try {
            // Get selected combos
            Map<Integer, Integer> selectedCombos = new HashMap<>();
            String[] comboIDs = request.getParameterValues("comboIDs");
            String[] comboQuantities = request.getParameterValues("comboQuantities");
            
            if (comboIDs != null && comboQuantities != null) {
                for (int i = 0; i < comboIDs.length; i++) {
                    int comboID = Integer.parseInt(comboIDs[i]);
                    int quantity = Integer.parseInt(comboQuantities[i]);
                    if (quantity > 0) {
                        selectedCombos.put(comboID, quantity);
                    }
                }
            }
            
            // Get selected foods
            Map<Integer, Integer> selectedFoods = new HashMap<>();
            String[] foodIDs = request.getParameterValues("foodIDs");
            String[] foodQuantities = request.getParameterValues("foodQuantities");
            
            if (foodIDs != null && foodQuantities != null) {
                for (int i = 0; i < foodIDs.length; i++) {
                    int foodID = Integer.parseInt(foodIDs[i]);
                    int quantity = Integer.parseInt(foodQuantities[i]);
                    if (quantity > 0) {
                        selectedFoods.put(foodID, quantity);
                    }
                }
            }
            
            // Calculate food subtotal
            double foodSubtotal = 0;
            
            // Calculate combo subtotal
            for (Map.Entry<Integer, Integer> entry : selectedCombos.entrySet()) {
                Combo combo = comboDAO.getComboById(entry.getKey());
                if (combo != null && combo.getIsAvailable()) {
                    double price = combo.getDiscountPrice() != null ? 
                                  combo.getDiscountPrice().doubleValue() : 
                                  combo.getTotalPrice().doubleValue();
                    foodSubtotal += price * entry.getValue();
                }
            }
            
            // Calculate food subtotal
            for (Map.Entry<Integer, Integer> entry : selectedFoods.entrySet()) {
                Food food = foodDAO.getFoodById(entry.getKey());
                if (food != null && food.getIsAvailable()) {
                    foodSubtotal += food.getPrice().doubleValue() * entry.getValue();
                }
            }
            
            // Store food selections in session
            bookingSession.setSelectedCombos(selectedCombos);
            bookingSession.setSelectedFoods(selectedFoods);
            bookingSession.setFoodSubtotal(foodSubtotal);
            
            // Redirect to payment
            response.sendRedirect(request.getContextPath() + "/booking/payment");
            
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Dữ liệu không hợp lệ!");
            doGet(request, response);
        }
    }
}

