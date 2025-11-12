package com.cinema.entity;


import java.time.LocalDateTime;

/**
 * Entity class representing a movie ticket
 */
public class Ticket {
    private int ticketID;
    private int screeningID;
    private int userID;
    private int seatID;
    private LocalDateTime bookingTime;
    private double unitPrice;
    
    // Additional fields for display purposes
    private String seatLabel;
    private String movieTitle;
    private String cinemaName;
    private LocalDateTime screeningTime;
    
    public Ticket() {
    }
    
    public Ticket(int screeningID, int userID, int seatID, double unitPrice) {
        this.screeningID = screeningID;
        this.userID = userID;
        this.seatID = seatID;
        this.unitPrice = unitPrice;
        this.bookingTime = LocalDateTime.now();
    }
    
    public Ticket(int ticketID, int screeningID, int userID, int seatID, 
                  LocalDateTime bookingTime, double unitPrice) {
        this.ticketID = ticketID;
        this.screeningID = screeningID;
        this.userID = userID;
        this.seatID = seatID;
        this.bookingTime = bookingTime;
        this.unitPrice = unitPrice;
    }
    
    // Getters and Setters
    public int getTicketID() {
        return ticketID;
    }
    
    public void setTicketID(int ticketID) {
        this.ticketID = ticketID;
    }
    
    public int getScreeningID() {
        return screeningID;
    }
    
    public void setScreeningID(int screeningID) {
        this.screeningID = screeningID;
    }
    
    public int getUserID() {
        return userID;
    }
    
    public void setUserID(int userID) {
        this.userID = userID;
    }
    
    public int getSeatID() {
        return seatID;
    }
    
    public void setSeatID(int seatID) {
        this.seatID = seatID;
    }
    
    public LocalDateTime getBookingTime() {
        return bookingTime;
    }
    
    public void setBookingTime(LocalDateTime bookingTime) {
        this.bookingTime = bookingTime;
    }
    
    public double getUnitPrice() {
        return unitPrice;
    }
    
    public void setUnitPrice(double unitPrice) {
        this.unitPrice = unitPrice;
    }
    
    public String getSeatLabel() {
        return seatLabel;
    }
    
    public void setSeatLabel(String seatLabel) {
        this.seatLabel = seatLabel;
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
    
    public LocalDateTime getScreeningTime() {
        return screeningTime;
    }
    
    public void setScreeningTime(LocalDateTime screeningTime) {
        this.screeningTime = screeningTime;
    }
    
    @Override
    public String toString() {
        return "Ticket{" +
                "ticketID=" + ticketID +
                ", screeningID=" + screeningID +
                ", userID=" + userID +
                ", seatID=" + seatID +
                ", bookingTime=" + bookingTime +
                ", unitPrice=" + unitPrice +
                '}';
    }
}

