/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package entity;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 *
 * @author admin
 */
public class Screening {

    private int screeningID;
    private int movieID;
    private int roomID;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private double ticketPrice;
    private int availableSeats;
private int seatCapacity;

    public int getSeatCapacity() {
        return seatCapacity;
    }

    public void setSeatCapacity(int seatCapacity) {
        this.seatCapacity = seatCapacity;
    }

    // Thông tin join để hiển thị
    private String movieTitle;
    private String cinemaName;
    private String roomName;
    private String movieStatus;
    private String roomType;
    private int soldSeats;
    private LocalDate screeningDate;
    private String showtime;
    private double baseTicketPrice;
    
     public Screening(int screeningID, int movieID, int roomID,
            LocalDate screeningDate, String showtime,
            double baseTicketPrice,
            String movieTitle, String cinemaName,
            String roomName, String movieStatus, String roomType) {
        this.screeningID = screeningID;
        this.movieID = movieID;
        this.roomID = roomID;
        this.screeningDate = screeningDate;
        this.showtime = showtime;
        this.baseTicketPrice = baseTicketPrice;
        this.movieTitle = movieTitle;
        this.cinemaName = cinemaName;
        this.roomName = roomName;
        this.movieStatus = movieStatus;
        this.roomType = roomType;
    }

    public Screening(int screeningID, int movieID, int roomID,
            LocalDate screeningDate, String showtime,
            double baseTicketPrice, int availableSeats,
            String movieTitle, String cinemaName,
            String roomName, String movieStatus) {
        this.screeningID = screeningID;
        this.movieID = movieID;
        this.roomID = roomID;
        this.screeningDate = screeningDate;
        this.showtime = showtime;
        this.baseTicketPrice = baseTicketPrice;
        this.availableSeats = availableSeats;
        this.movieTitle = movieTitle;
        this.cinemaName = cinemaName;
        this.roomName = roomName;
        this.movieStatus = movieStatus;
    }
    
    public Screening(int screeningID, int movieID, int roomID, LocalDate screeningDate, String showtime,
                     double baseTicketPrice, String movieTitle, String cinemaName, String roomName,
                     int seatCapacity, String movieStatus) {
        this.screeningID = screeningID;
        this.movieID = movieID;
        this.roomID = roomID;
        this.screeningDate = screeningDate;
        this.showtime = showtime;
        this.baseTicketPrice = baseTicketPrice;
        this.movieTitle = movieTitle;
        this.cinemaName = cinemaName;
        this.roomName = roomName;
        this.seatCapacity = seatCapacity;
        this.movieStatus = movieStatus;
    }


    public String getShowtime() {
        return showtime;
    }

    public void setShowtime(String showtime) {
        this.showtime = showtime;
    }

    public double getBaseTicketPrice() {
        return baseTicketPrice;
    }

    public void setBaseTicketPrice(double baseTicketPrice) {
        this.baseTicketPrice = baseTicketPrice;
    }
    
    public LocalDate getScreeningDate() {
        return screeningDate;
    }

    public void setScreeningDate(LocalDate screeningDate) {
        this.screeningDate = screeningDate;
    }

    public Screening(int screeningID, int movieID, int roomID,
            LocalDateTime startTime, LocalDateTime endTime,
            double ticketPrice, int availableSeats,
            String movieTitle, String cinemaName, String roomName,
            String movieStatus, String roomType) { // 👈 thêm roomType
        this.screeningID = screeningID;
        this.movieID = movieID;
        this.roomID = roomID;
        this.startTime = startTime;
        this.endTime = endTime;
        this.ticketPrice = ticketPrice;
        this.availableSeats = availableSeats;
        this.movieTitle = movieTitle;
        this.cinemaName = cinemaName;
        this.roomName = roomName;
        this.movieStatus = movieStatus;
        this.roomType = roomType;
    }

    public Screening(int screeningID, int movieID, int roomID, LocalDateTime startTime, LocalDateTime endTime, double ticketPrice, int availableSeats, String movieTitle, String cinemaName, String roomName, String movieStatus, int soldSeats) {
        this.screeningID = screeningID;
        this.movieID = movieID;
        this.roomID = roomID;
        this.startTime = startTime;
        this.endTime = endTime;
        this.ticketPrice = ticketPrice;
        this.availableSeats = availableSeats;
        this.movieTitle = movieTitle;
        this.cinemaName = cinemaName;
        this.roomName = roomName;
        this.movieStatus = movieStatus;
        this.soldSeats = soldSeats;
    }

    public int getSoldSeats() {
        return soldSeats;
    }

    public void setSoldSeats(int soldSeats) {
        this.soldSeats = soldSeats;
    }

    public Screening() {
    }

    public String getMovieStatus() {
        return movieStatus;
    }

    public void setMovieStatus(String movieStatus) {
        this.movieStatus = movieStatus;
    }

    public Screening(int screeningID, int movieID, int roomID, LocalDateTime startTime, LocalDateTime endTime, double ticketPrice, int availableSeats, String movieTitle, String cinemaName, String roomName, String movieStatus) {
        this.screeningID = screeningID;
        this.movieID = movieID;
        this.roomID = roomID;
        this.startTime = startTime;
        this.endTime = endTime;
        this.ticketPrice = ticketPrice;
        this.availableSeats = availableSeats;
        this.movieTitle = movieTitle;
        this.cinemaName = cinemaName;
        this.roomName = roomName;
        this.movieStatus = movieStatus;
    }

    public int getScreeningID() {
        return screeningID;
    }

    public void setScreeningID(int screeningID) {
        this.screeningID = screeningID;
    }

    public int getMovieID() {
        return movieID;
    }

    public void setMovieID(int movieID) {
        this.movieID = movieID;
    }

    public int getRoomID() {
        return roomID;
    }

    public void setRoomID(int roomID) {
        this.roomID = roomID;
    }

    public LocalDateTime getStartTime() {
        return startTime;
    }

    public void setStartTime(LocalDateTime startTime) {
        this.startTime = startTime;
    }

    public LocalDateTime getEndTime() {
        return endTime;
    }

    public void setEndTime(LocalDateTime endTime) {
        this.endTime = endTime;
    }

    public double getTicketPrice() {
        return ticketPrice;
    }

    public void setTicketPrice(double ticketPrice) {
        this.ticketPrice = ticketPrice;
    }

    public int getAvailableSeats() {
        return availableSeats;
    }

    public void setAvailableSeats(int availableSeats) {
        this.availableSeats = availableSeats;
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

    public String getRoomType() {
        return roomType;
    }

    public void setRoomType(String roomType) {
        this.roomType = roomType;
    }

    public String getFormattedStartTime() {
        if (startTime == null) {
            return "";
        }
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd-MM-yyyy HH:mm");
        return startTime.format(formatter);
    }

    public String getFormattedEndTime() {
        if (endTime == null) {
            return "";
        }
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd-MM-yyyy HH:mm");
        return endTime.format(formatter);
    }
     public String getFormattedScreeningDate() {
        if (screeningDate == null) return "";
        return screeningDate.format(DateTimeFormatter.ofPattern("dd/MM/yyyy"));
    }

    @Override
    public String toString() {
        return "Screening{" + "screeningID=" + screeningID + ", movieID=" + movieID + ", roomID=" + roomID + ", startTime=" + startTime + ", endTime=" + endTime + ", ticketPrice=" + ticketPrice + ", availableSeats=" + availableSeats + ", movieTitle=" + movieTitle + ", cinemaName=" + cinemaName + ", roomName=" + roomName + ", movieStatus=" + movieStatus + '}';
    }

}
