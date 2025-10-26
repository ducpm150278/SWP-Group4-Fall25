package entity;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Entity class representing a billing/payment record
 */
public class Billing {
    private int billingID;
    private int userID;
    private int ticketID;
    private Integer discountID; // Nullable
    private double totalAmount;
    private LocalDateTime paymentDate;
    private String paymentMethod; // Cash, Credit Card, Debit Card, E-Wallet, Bank Transfer
    private String paymentStatus; // Pending, Completed, Failed, Refunded
    
    // Additional fields for multiple tickets and food
    private List<Integer> ticketIDs;
    private double ticketSubtotal;
    private double foodSubtotal;
    private double discountAmount;
    private String discountCode;
    
    public Billing() {
    }
    
    public Billing(int userID, int ticketID, Integer discountID, 
                   double totalAmount, String paymentMethod) {
        this.userID = userID;
        this.ticketID = ticketID;
        this.discountID = discountID;
        this.totalAmount = totalAmount;
        this.paymentMethod = paymentMethod;
        this.paymentDate = LocalDateTime.now();
        this.paymentStatus = "Pending";
    }
    
    // Getters and Setters
    public int getBillingID() {
        return billingID;
    }
    
    public void setBillingID(int billingID) {
        this.billingID = billingID;
    }
    
    public int getUserID() {
        return userID;
    }
    
    public void setUserID(int userID) {
        this.userID = userID;
    }
    
    public int getTicketID() {
        return ticketID;
    }
    
    public void setTicketID(int ticketID) {
        this.ticketID = ticketID;
    }
    
    public Integer getDiscountID() {
        return discountID;
    }
    
    public void setDiscountID(Integer discountID) {
        this.discountID = discountID;
    }
    
    public double getTotalAmount() {
        return totalAmount;
    }
    
    public void setTotalAmount(double totalAmount) {
        this.totalAmount = totalAmount;
    }
    
    public LocalDateTime getPaymentDate() {
        return paymentDate;
    }
    
    public void setPaymentDate(LocalDateTime paymentDate) {
        this.paymentDate = paymentDate;
    }
    
    public String getPaymentMethod() {
        return paymentMethod;
    }
    
    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }
    
    public String getPaymentStatus() {
        return paymentStatus;
    }
    
    public void setPaymentStatus(String paymentStatus) {
        this.paymentStatus = paymentStatus;
    }
    
    public List<Integer> getTicketIDs() {
        return ticketIDs;
    }
    
    public void setTicketIDs(List<Integer> ticketIDs) {
        this.ticketIDs = ticketIDs;
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
    
    public String getDiscountCode() {
        return discountCode;
    }
    
    public void setDiscountCode(String discountCode) {
        this.discountCode = discountCode;
    }
    
    @Override
    public String toString() {
        return "Billing{" +
                "billingID=" + billingID +
                ", userID=" + userID +
                ", ticketID=" + ticketID +
                ", discountID=" + discountID +
                ", totalAmount=" + totalAmount +
                ", paymentDate=" + paymentDate +
                ", paymentMethod='" + paymentMethod + '\'' +
                ", paymentStatus='" + paymentStatus + '\'' +
                '}';
    }
}

