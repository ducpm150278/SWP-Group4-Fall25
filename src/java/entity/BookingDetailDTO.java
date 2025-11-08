package entity;

import java.time.LocalDateTime;
import java.util.List;
import java.util.ArrayList;

/**
 * Data Transfer Object for complete booking details
 * Includes booking, screening, movie, tickets, and food information
 */

public class BookingDetailDTO {
    // Booking information
    private int bookingID;
    private String bookingCode;
    private LocalDateTime bookingDate;
    private double totalAmount;
    private double discountAmount;
    private double finalAmount;
    private String status;
    private String paymentStatus;
    private String paymentMethod;
    private LocalDateTime paymentDate;
    
    // Movie and Screening information
    private String movieTitle;
    private String moviePosterURL;
    private String cinemaName;
    private String roomName;
    private LocalDateTime screeningTime;
    private int movieDuration;
    
    // Tickets information
    private List<String> seatLabels;
    private int ticketCount;
    private double ticketSubtotal;
    
    // Food information (optional)
    private List<FoodItemDetail> foodItems;
    private double foodSubtotal;
    
    // Discount information
    private String discountCode;
    
    //For review
    private int movieID;
    private String customerName;
    private String customerEmail;
    private String customerPhone;
    
    public BookingDetailDTO() {
        this.seatLabels = new ArrayList<>();
        this.foodItems = new ArrayList<>();
        this.ticketSubtotal = 0.0;
        this.foodSubtotal = 0.0;
    }
    
    // Inner class for food item details
    public static class FoodItemDetail {
        private String name;
        private int quantity;
        private double unitPrice;
        private double totalPrice;
        private String type; // "Food" or "Combo"
        
        public FoodItemDetail(String name, int quantity, double unitPrice, double totalPrice, String type) {
            this.name = name;
            this.quantity = quantity;
            this.unitPrice = unitPrice;
            this.totalPrice = totalPrice;
            this.type = type;
        }
        
        // Getters and Setters
        public String getName() {
            return name;
        }
        
        public void setName(String name) {
            this.name = name;
        }
        
        public int getQuantity() {
            return quantity;
        }
        
        public void setQuantity(int quantity) {
            this.quantity = quantity;
        }
        
        public double getUnitPrice() {
            return unitPrice;
        }
        
        public void setUnitPrice(double unitPrice) {
            this.unitPrice = unitPrice;
        }
        
        public double getTotalPrice() {
            return totalPrice;
        }
        
        public void setTotalPrice(double totalPrice) {
            this.totalPrice = totalPrice;
        }
        
        public String getType() {
            return type;
        }
        
        public void setType(String type) {
            this.type = type;
        }
    }
    
    // Getters and Setters
    public int getBookingID() {
        return bookingID;
    }
    
    public void setBookingID(int bookingID) {
        this.bookingID = bookingID;
    }
    
    public String getBookingCode() {
        return bookingCode;
    }
    
    public void setBookingCode(String bookingCode) {
        this.bookingCode = bookingCode;
    }
    
    public LocalDateTime getBookingDate() {
        return bookingDate;
    }
    
    public void setBookingDate(LocalDateTime bookingDate) {
        this.bookingDate = bookingDate;
    }
    
    public double getTotalAmount() {
        return totalAmount;
    }
    
    public void setTotalAmount(double totalAmount) {
        this.totalAmount = totalAmount;
    }
    
    public double getDiscountAmount() {
        return discountAmount;
    }
    
    public void setDiscountAmount(double discountAmount) {
        this.discountAmount = discountAmount;
    }
    
    public double getFinalAmount() {
        return finalAmount;
    }
    
    public void setFinalAmount(double finalAmount) {
        this.finalAmount = finalAmount;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public String getPaymentStatus() {
        return paymentStatus;
    }
    
    public void setPaymentStatus(String paymentStatus) {
        this.paymentStatus = paymentStatus;
    }
    
    public String getPaymentMethod() {
        return paymentMethod;
    }
    
    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }
    
    public LocalDateTime getPaymentDate() {
        return paymentDate;
    }
    
    public void setPaymentDate(LocalDateTime paymentDate) {
        this.paymentDate = paymentDate;
    }
    
    public String getMovieTitle() {
        return movieTitle;
    }
    
    public void setMovieTitle(String movieTitle) {
        this.movieTitle = movieTitle;
    }
    
    public String getMoviePosterURL() {
        return moviePosterURL;
    }
    
    public void setMoviePosterURL(String moviePosterURL) {
        this.moviePosterURL = moviePosterURL;
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
    
    public int getMovieDuration() {
        return movieDuration;
    }
    
    public void setMovieDuration(int movieDuration) {
        this.movieDuration = movieDuration;
    }
    
    public List<String> getSeatLabels() {
        return seatLabels;
    }
    
    public void setSeatLabels(List<String> seatLabels) {
        this.seatLabels = seatLabels;
        this.ticketCount = seatLabels != null ? seatLabels.size() : 0;
    }
    
    public int getTicketCount() {
        return ticketCount;
    }
    
    public void setTicketCount(int ticketCount) {
        this.ticketCount = ticketCount;
    }
    
    public double getTicketSubtotal() {
        return ticketSubtotal;
    }
    
    public void setTicketSubtotal(double ticketSubtotal) {
        this.ticketSubtotal = ticketSubtotal;
    }
    
    public List<FoodItemDetail> getFoodItems() {
        return foodItems;
    }
    
    public void setFoodItems(List<FoodItemDetail> foodItems) {
        this.foodItems = foodItems;
    }
    
    public double getFoodSubtotal() {
        return foodSubtotal;
    }
    
    public void setFoodSubtotal(double foodSubtotal) {
        this.foodSubtotal = foodSubtotal;
    }
    
    public String getDiscountCode() {
        return discountCode;
    }
    
    public void setDiscountCode(String discountCode) {
        this.discountCode = discountCode;
    }
    
    /**
     * Helper method to get seat labels as comma-separated string
     */
    public String getSeatLabelsString() {
        return String.join(", ", seatLabels);
    }
    
    /**
     * Check if booking has food items
     */
    public boolean hasFoodItems() {
        return foodItems != null && !foodItems.isEmpty();
    }
    
    /**
     * Check if screening time has passed
     */
    public boolean isPast() {
        return screeningTime != null && screeningTime.isBefore(LocalDateTime.now());
    }
    
    /**
     * Check if booking can be cancelled
     * Can cancel if: status is Pending/Confirmed AND screening is in future
     */
    public boolean canBeCancelled() {
        return ("Pending".equals(status) || "Confirmed".equals(status)) && !isPast();
    }
    
    //For review
    public int getMovieID() {
        return movieID;
    }

    public void setMovieID(int movieID) {
        this.movieID = movieID;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public String getCustomerEmail() {
        return customerEmail;
    }

    public void setCustomerEmail(String customerEmail) {
        this.customerEmail = customerEmail;
    }

    public String getCustomerPhone() {
        return customerPhone;
    }

    public void setCustomerPhone(String customerPhone) {
        this.customerPhone = customerPhone;
    }
    
    
}

    

