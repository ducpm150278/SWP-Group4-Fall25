package utils;

import entity.BookingSession;
import jakarta.servlet.http.HttpSession;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Manager class for booking session lifecycle
 */
public class BookingSessionManager {
    
    private static final String BOOKING_SESSION_KEY = "bookingSession";
    private static final int RESERVATION_TIMEOUT_MINUTES = 15;
    
    /**
     * Get or create booking session
     */
    public static BookingSession getBookingSession(HttpSession session) {
        BookingSession bookingSession = (BookingSession) session.getAttribute(BOOKING_SESSION_KEY);
        
        if (bookingSession == null) {
            bookingSession = new BookingSession();
            session.setAttribute(BOOKING_SESSION_KEY, bookingSession);
        }
        
        return bookingSession;
    }
    
    /**
     * Clear booking session
     */
    public static void clearBookingSession(HttpSession session) {
        session.removeAttribute(BOOKING_SESSION_KEY);
    }
    
    /**
     * Generate unique reservation session ID
     */
    public static String generateReservationSessionID() {
        return UUID.randomUUID().toString();
    }
    
    /**
     * Set reservation expiry time
     */
    public static LocalDateTime getReservationExpiry() {
        return LocalDateTime.now().plusMinutes(RESERVATION_TIMEOUT_MINUTES);
    }
    
    /**
     * Check if reservation is expired
     */
    public static boolean isReservationExpired(LocalDateTime expiryTime) {
        if (expiryTime == null) {
            return true;
        }
        return LocalDateTime.now().isAfter(expiryTime);
    }
    
    /**
     * Get remaining time in seconds
     */
    public static long getRemainingSeconds(LocalDateTime expiryTime) {
        if (expiryTime == null) {
            return 0;
        }
        
        LocalDateTime now = LocalDateTime.now();
        if (now.isAfter(expiryTime)) {
            return 0;
        }
        
        return java.time.Duration.between(now, expiryTime).getSeconds();
    }
    
    /**
     * Format remaining time for display
     */
    public static String formatRemainingTime(long seconds) {
        if (seconds <= 0) {
            return "00:00";
        }
        
        long minutes = seconds / 60;
        long secs = seconds % 60;
        
        return String.format("%02d:%02d", minutes, secs);
    }
    
    /**
     * Validate booking session for payment
     */
    public static boolean isValidForPayment(BookingSession session) {
        if (session == null) {
            return false;
        }
        
        // Check if screening is selected
        if (session.getScreeningID() <= 0) {
            return false;
        }
        
        // Check if seats are selected
        if (session.getSelectedSeatIDs() == null || session.getSelectedSeatIDs().isEmpty()) {
            return false;
        }
        
        // Check if reservation is not expired
        if (isReservationExpired(session.getReservationExpiry())) {
            return false;
        }
        
        return true;
    }
    
    /**
     * Calculate subtotals
     */
    public static void calculateSubtotals(BookingSession session, 
                                         java.util.Map<Integer, entity.Combo> combos,
                                         java.util.Map<Integer, entity.Food> foods) {
        // Calculate ticket subtotal
        double ticketSubtotal = session.getTicketPrice() * session.getSeatCount();
        session.setTicketSubtotal(ticketSubtotal);
        
        // Calculate food subtotal
        double foodSubtotal = 0;
        
        // Add combo prices
        if (combos != null && session.getSelectedCombos() != null) {
            for (java.util.Map.Entry<Integer, Integer> entry : session.getSelectedCombos().entrySet()) {
                entity.Combo combo = combos.get(entry.getKey());
                if (combo != null) {
                    double price = combo.getDiscountPrice() != null ? 
                                  combo.getDiscountPrice().doubleValue() : 
                                  combo.getTotalPrice().doubleValue();
                    foodSubtotal += price * entry.getValue();
                }
            }
        }
        
        // Add individual food prices
        if (foods != null && session.getSelectedFoods() != null) {
            for (java.util.Map.Entry<Integer, Integer> entry : session.getSelectedFoods().entrySet()) {
                entity.Food food = foods.get(entry.getKey());
                if (food != null) {
                    foodSubtotal += food.getPrice().doubleValue() * entry.getValue();
                }
            }
        }
        
        session.setFoodSubtotal(foodSubtotal);
        
        // Calculate total
        session.calculateTotals();
    }
}

