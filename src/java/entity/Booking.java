package entity;

import java.time.LocalDateTime;

/**
 * Booking entity - represents a complete booking (tickets + food)
 */
public class Booking {
    private int bookingID;
    private String bookingCode;
    private int userID;
    private int screeningID;
    private LocalDateTime bookingDate;
    private double totalAmount;
    private double discountAmount;
    private double finalAmount;
    private String status; // Pending, Confirmed, Cancelled, Completed
    private String paymentStatus; // Pending, Completed, Failed
    private String paymentMethod; // Cash, Credit Card, E-Wallet, VNPay, Momo
    private LocalDateTime paymentDate;
    private String transactionID; // VNPay/Momo transaction ID
    private String notes;

    // Default constructor
    public Booking() {
        this.bookingDate = LocalDateTime.now();
        this.status = "Pending";
        this.paymentStatus = "Pending";
        this.discountAmount = 0.0;
    }

    // Constructor for creating new booking
    public Booking(String bookingCode, int userID, int screeningID, 
                   double totalAmount, double discountAmount, double finalAmount,
                   String paymentMethod) {
        this();
        this.bookingCode = bookingCode;
        this.userID = userID;
        this.screeningID = screeningID;
        this.totalAmount = totalAmount;
        this.discountAmount = discountAmount;
        this.finalAmount = finalAmount;
        this.paymentMethod = paymentMethod;
    }

    // Full constructor
    public Booking(int bookingID, String bookingCode, int userID, int screeningID,
                   LocalDateTime bookingDate, double totalAmount, double discountAmount,
                   double finalAmount, String status, String paymentStatus,
                   String paymentMethod, LocalDateTime paymentDate, String notes) {
        this.bookingID = bookingID;
        this.bookingCode = bookingCode;
        this.userID = userID;
        this.screeningID = screeningID;
        this.bookingDate = bookingDate;
        this.totalAmount = totalAmount;
        this.discountAmount = discountAmount;
        this.finalAmount = finalAmount;
        this.status = status;
        this.paymentStatus = paymentStatus;
        this.paymentMethod = paymentMethod;
        this.paymentDate = paymentDate;
        this.notes = notes;
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

    public int getUserID() {
        return userID;
    }

    public void setUserID(int userID) {
        this.userID = userID;
    }

    public int getScreeningID() {
        return screeningID;
    }

    public void setScreeningID(int screeningID) {
        this.screeningID = screeningID;
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

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public String getTransactionID() {
        return transactionID;
    }

    public void setTransactionID(String transactionID) {
        this.transactionID = transactionID;
    }

    @Override
    public String toString() {
        return "Booking{" +
                "bookingID=" + bookingID +
                ", bookingCode='" + bookingCode + '\'' +
                ", userID=" + userID +
                ", screeningID=" + screeningID +
                ", totalAmount=" + totalAmount +
                ", finalAmount=" + finalAmount +
                ", status='" + status + '\'' +
                ", paymentStatus='" + paymentStatus + '\'' +
                '}';
    }
}

