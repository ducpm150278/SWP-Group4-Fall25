package com.cinema.entity;


import java.io.Serializable;
import java.math.BigDecimal;

/**
 * Entity class representing a food or combo item in a booking
 */
public class BookingFoodItem implements Serializable {
    private static final long serialVersionUID = 1L;
    
    private int bookingFoodItemID;
    private int bookingID;
    private Integer foodID;      // Nullable - either foodID or comboID must be set
    private Integer comboID;     // Nullable - either foodID or comboID must be set
    private int quantity;
    private BigDecimal unitPrice;
    private BigDecimal totalPrice;
    
    // Constructors
    public BookingFoodItem() {
    }
    
    /**
     * Constructor for food item
     */
    public BookingFoodItem(int bookingID, int foodID, int quantity, BigDecimal unitPrice) {
        this.bookingID = bookingID;
        this.foodID = foodID;
        this.comboID = null;
        this.quantity = quantity;
        this.unitPrice = unitPrice;
        this.totalPrice = unitPrice.multiply(new BigDecimal(quantity));
    }
    
    /**
     * Constructor for combo item
     */
    public static BookingFoodItem createComboItem(int bookingID, int comboID, int quantity, BigDecimal unitPrice) {
        BookingFoodItem item = new BookingFoodItem();
        item.setBookingID(bookingID);
        item.setComboID(comboID);
        item.setFoodID(null);
        item.setQuantity(quantity);
        item.setUnitPrice(unitPrice);
        item.setTotalPrice(unitPrice.multiply(new BigDecimal(quantity)));
        return item;
    }
    
    // Getters and Setters
    public int getBookingFoodItemID() {
        return bookingFoodItemID;
    }
    
    public void setBookingFoodItemID(int bookingFoodItemID) {
        this.bookingFoodItemID = bookingFoodItemID;
    }
    
    public int getBookingID() {
        return bookingID;
    }
    
    public void setBookingID(int bookingID) {
        this.bookingID = bookingID;
    }
    
    public Integer getFoodID() {
        return foodID;
    }
    
    public void setFoodID(Integer foodID) {
        this.foodID = foodID;
    }
    
    public Integer getComboID() {
        return comboID;
    }
    
    public void setComboID(Integer comboID) {
        this.comboID = comboID;
    }
    
    public int getQuantity() {
        return quantity;
    }
    
    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }
    
    public BigDecimal getUnitPrice() {
        return unitPrice;
    }
    
    public void setUnitPrice(BigDecimal unitPrice) {
        this.unitPrice = unitPrice;
    }
    
    public BigDecimal getTotalPrice() {
        return totalPrice;
    }
    
    public void setTotalPrice(BigDecimal totalPrice) {
        this.totalPrice = totalPrice;
    }
    
    /**
     * Check if this is a food item (not combo)
     */
    public boolean isFoodItem() {
        return foodID != null && comboID == null;
    }
    
    /**
     * Check if this is a combo item (not food)
     */
    public boolean isComboItem() {
        return comboID != null && foodID == null;
    }
    
    @Override
    public String toString() {
        String itemType = isFoodItem() ? "Food" : "Combo";
        int itemId = isFoodItem() ? foodID : comboID;
        return "BookingFoodItem{" +
                "bookingFoodItemID=" + bookingFoodItemID +
                ", bookingID=" + bookingID +
                ", " + itemType + "ID=" + itemId +
                ", quantity=" + quantity +
                ", unitPrice=" + unitPrice +
                ", totalPrice=" + totalPrice +
                '}';
    }
}

