/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package entity;

import java.time.LocalDateTime;

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

    // Thông tin join để hiển thị
    private String movieTitle;
    private String cinemaName;
    private String roomName;
    private String movieStatus;
    private String roomType;
    private int soldSeats;

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

    @Override
    public String toString() {
        return "Screening{" + "screeningID=" + screeningID + ", movieID=" + movieID + ", roomID=" + roomID + ", startTime=" + startTime + ", endTime=" + endTime + ", ticketPrice=" + ticketPrice + ", availableSeats=" + availableSeats + ", movieTitle=" + movieTitle + ", cinemaName=" + cinemaName + ", roomName=" + roomName + ", movieStatus=" + movieStatus + '}';
    }

}
