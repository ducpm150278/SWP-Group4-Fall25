package com.cinema.entity;


/**
 * Entity class representing a cinema seat
 */
public class Seat {
    private int seatID;
    private int roomID;
    private String seatRow;
    private String seatNumber; // Changed from int to String (VARCHAR(5))
    private String seatType; // Standard, VIP, Couple
    private double priceMultiplier; // Price multiplier for different seat types
    private String status; // Available, Maintenance
    
    public Seat() {
    }
    
    public Seat(int seatID, int roomID, String seatRow, String seatNumber, 
                String seatType, double priceMultiplier, String status) {
        this.seatID = seatID;
        this.roomID = roomID;
        this.seatRow = seatRow;
        this.seatNumber = seatNumber;
        this.seatType = seatType;
        this.priceMultiplier = priceMultiplier;
        this.status = status;
    }
    
    // Getters and Setters
    public int getSeatID() {
        return seatID;
    }
    
    public void setSeatID(int seatID) {
        this.seatID = seatID;
    }
    
    public int getRoomID() {
        return roomID;
    }
    
    public void setRoomID(int roomID) {
        this.roomID = roomID;
    }
    
    public String getSeatRow() {
        return seatRow;
    }
    
    public void setSeatRow(String seatRow) {
        this.seatRow = seatRow;
    }
    
    public String getSeatNumber() {
        return seatNumber;
    }
    
    public void setSeatNumber(String seatNumber) {
        this.seatNumber = seatNumber;
    }
    
    public String getSeatType() {
        return seatType;
    }
    
    public void setSeatType(String seatType) {
        this.seatType = seatType;
    }
    
    public double getPriceMultiplier() {
        return priceMultiplier;
    }
    
    public void setPriceMultiplier(double priceMultiplier) {
        this.priceMultiplier = priceMultiplier;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public String getSeatLabel() {
        return seatRow + seatNumber;
    }
    
    /**
     * Calculate the actual price for this seat based on base ticket price
     */
    public double calculatePrice(double basePrice) {
        return basePrice * priceMultiplier;
    }
    
    @Override
    public String toString() {
        return "Seat{" +
                "seatID=" + seatID +
                ", roomID=" + roomID +
                ", seatRow='" + seatRow + '\'' +
                ", seatNumber=" + seatNumber +
                ", seatType='" + seatType + '\'' +
                ", priceMultiplier=" + priceMultiplier +
                ", status='" + status + '\'' +
                '}';
    }
}

