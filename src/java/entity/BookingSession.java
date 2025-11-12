package entity;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Session object to track booking state across multiple steps
 */
public class BookingSession implements Serializable {
    private static final long serialVersionUID = 1L;
    
    // Step 1: Screening selection
    private int screeningID;
    private String movieTitle;
    private String cinemaName;
    private String roomName;
    private LocalDateTime screeningTime;
    private double ticketPrice;
    
    // Step 2: Seat selection
    private List<Integer> selectedSeatIDs;
    private List<String> selectedSeatLabels;
    private int seatCount;
    
    // Step 3: Food selection
    private Map<Integer, Integer> selectedCombos; // ComboID -> Quantity
    private Map<Integer, Integer> selectedFoods;  // FoodID -> Quantity
    
    // Reservation tracking
    private String reservationSessionID;
    private LocalDateTime reservationExpiry;
    
    // Price calculations
    private double ticketSubtotal;
    private double foodSubtotal;
    private double discountAmount;
    private double totalAmount;
    
    // Discount
    private Integer discountID;
    private String discountCode;
    
    public BookingSession() {
        this.selectedSeatIDs = new ArrayList<>();
        this.selectedSeatLabels = new ArrayList<>();
        this.selectedCombos = new HashMap<>();
        this.selectedFoods = new HashMap<>();
        this.seatCount = 0;
        this.ticketSubtotal = 0;
        this.foodSubtotal = 0;
        this.discountAmount = 0;
        this.totalAmount = 0;
    }
    
    // Getters and Setters
    public int getScreeningID() {
        return screeningID;
    }
    
    public void setScreeningID(int screeningID) {
        this.screeningID = screeningID;
    }
    
    public String getMovieTitle() {
        return movieTitle;
    }
    
    public void setMovieTitle(String movieTitle) {
        this.movieTitle = movieTitle;
    }
    
    public String getCinemaName() {
        return cinemaName;
    }
    
    public void setCinemaName(String cinemaName) {
        this.cinemaName = cinemaName;
    }
    
    public String getRoomName() {
        return roomName;
    }
    
    public void setRoomName(String roomName) {
        this.roomName = roomName;
    }
    
    public LocalDateTime getScreeningTime() {
        return screeningTime;
    }
    
    public void setScreeningTime(LocalDateTime screeningTime) {
        this.screeningTime = screeningTime;
    }
    
    public double getTicketPrice() {
        return ticketPrice;
    }
    
    public void setTicketPrice(double ticketPrice) {
        this.ticketPrice = ticketPrice;
    }
    
    public List<Integer> getSelectedSeatIDs() {
        return selectedSeatIDs;
    }
    
    public void setSelectedSeatIDs(List<Integer> selectedSeatIDs) {
        this.selectedSeatIDs = selectedSeatIDs;
        this.seatCount = selectedSeatIDs != null ? selectedSeatIDs.size() : 0;
    }
    
    public List<String> getSelectedSeatLabels() {
        return selectedSeatLabels;
    }
    
    public void setSelectedSeatLabels(List<String> selectedSeatLabels) {
        this.selectedSeatLabels = selectedSeatLabels;
    }
    
    public int getSeatCount() {
        return seatCount;
    }
    
    public void setSeatCount(int seatCount) {
        this.seatCount = seatCount;
    }
    
    public Map<Integer, Integer> getSelectedCombos() {
        return selectedCombos;
    }
    
    public void setSelectedCombos(Map<Integer, Integer> selectedCombos) {
        this.selectedCombos = selectedCombos;
    }
    
    public Map<Integer, Integer> getSelectedFoods() {
        return selectedFoods;
    }
    
    public void setSelectedFoods(Map<Integer, Integer> selectedFoods) {
        this.selectedFoods = selectedFoods;
    }
    
    public String getReservationSessionID() {
        return reservationSessionID;
    }
    
    public void setReservationSessionID(String reservationSessionID) {
        this.reservationSessionID = reservationSessionID;
    }
    
    public LocalDateTime getReservationExpiry() {
        return reservationExpiry;
    }
    
    public void setReservationExpiry(LocalDateTime reservationExpiry) {
        this.reservationExpiry = reservationExpiry;
    }
    
    public double getTicketSubtotal() {
        return ticketSubtotal;
    }
    
    public void setTicketSubtotal(double ticketSubtotal) {
        this.ticketSubtotal = ticketSubtotal;
    }
    
    public double getFoodSubtotal() {
        return foodSubtotal;
    }
    
    public void setFoodSubtotal(double foodSubtotal) {
        this.foodSubtotal = foodSubtotal;
    }
    
    public double getDiscountAmount() {
        return discountAmount;
    }
    
    public void setDiscountAmount(double discountAmount) {
        this.discountAmount = discountAmount;
    }
    
    public double getTotalAmount() {
        return totalAmount;
    }
    
    public void setTotalAmount(double totalAmount) {
        this.totalAmount = totalAmount;
    }
    
    public Integer getDiscountID() {
        return discountID;
    }
    
    public void setDiscountID(Integer discountID) {
        this.discountID = discountID;
    }
    
    public String getDiscountCode() {
        return discountCode;
    }
    
    public void setDiscountCode(String discountCode) {
        this.discountCode = discountCode;
    }
    
    /**
     * Calculate total amount based on existing subtotals
     * Note: ticketSubtotal should be set by BookingSeatSelectionServlet
     * to account for different seat types (VIP, Couple, etc.)
     * totalAmount = ticketSubtotal + foodSubtotal (before discount)
     * finalAmount = totalAmount - discountAmount (calculated separately)
     */
    public void calculateTotals() {
        // Do NOT recalculate ticketSubtotal - it's already set correctly
        // with seat type multipliers in BookingSeatSelectionServlet
        // totalAmount should be BEFORE discount, discount is applied when calculating finalAmount
        this.totalAmount = this.ticketSubtotal + this.foodSubtotal;
    }
    
    public boolean isExpired() {
        if (reservationExpiry == null) {
            return false;
        }
        return LocalDateTime.now().isAfter(reservationExpiry);
    }
    
    public void clear() {
        this.screeningID = 0;
        this.movieTitle = null;
        this.cinemaName = null;
        this.roomName = null;
        this.screeningTime = null;
        this.ticketPrice = 0;
        this.selectedSeatIDs.clear();
        this.selectedSeatLabels.clear();
        this.seatCount = 0;
        this.selectedCombos.clear();
        this.selectedFoods.clear();
        this.reservationSessionID = null;
        this.reservationExpiry = null;
        this.ticketSubtotal = 0;
        this.foodSubtotal = 0;
        this.discountAmount = 0;
        this.totalAmount = 0;
        this.discountID = null;
        this.discountCode = null;
    }
}

