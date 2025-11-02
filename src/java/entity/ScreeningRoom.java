package entity;

import java.util.List;

public class ScreeningRoom {
    private int roomID;
    private int cinemaID;
    private String roomName;
    private int seatCapacity;
    private String roomType;
    private boolean isActive;
    private List<SeatM> seats; // Thêm danh sách ghế
    private CinemaM cinema; // Thêm tham chiếu đến cinema

    // Constructors
    public ScreeningRoom() {
    }

    public ScreeningRoom(int roomID, int cinemaID, String roomName, int seatCapacity, 
                        String roomType, boolean isActive) {
        this.roomID = roomID;
        this.cinemaID = cinemaID;
        this.roomName = roomName;
        this.seatCapacity = seatCapacity;
        this.roomType = roomType;
        this.isActive = isActive;
    }


    // Getters and Setters
    public int getRoomID() {
        return roomID;
    }

    public void setRoomID(int roomID) {
        this.roomID = roomID;
    }

    public int getCinemaID() {
        return cinemaID;
    }

    public void setCinemaID(int cinemaID) {
        this.cinemaID = cinemaID;
    }

    public String getRoomName() {
        return roomName;
    }

    public void setRoomName(String roomName) {
        this.roomName = roomName;
    }

    public int getSeatCapacity() {
        return seatCapacity;
    }

    public void setSeatCapacity(int seatCapacity) {
        this.seatCapacity = seatCapacity;
    }

    public String getRoomType() {
        return roomType;
    }

    public void setRoomType(String roomType) {
        this.roomType = roomType;
    }

    public boolean isActive() {
        return isActive;
    }

    public void setActive(boolean active) {
        isActive = active;
    }

    public List<SeatM> getSeats() {
        return seats;
    }

    public void setSeats(List<SeatM> seats) {
        this.seats = seats;
        // Tự động cập nhật seatCapacity khi set seats
        if (seats != null) {
            this.seatCapacity = seats.size();
        } else {
            this.seatCapacity = 0;
        }
    }

    public CinemaM getCinema() {
        return cinema;
    }

    public void setCinema(CinemaM cinema) {
        this.cinema = cinema;
        if (cinema != null) {
            this.cinemaID = cinema.getCinemaID();
        }
    }

    // Helper methods
    public int calculateAvailableSeats() {
        if (seats != null) {
            return (int) seats.stream()
                    .filter(seat -> "Available".equals(seat.getStatus()))
                    .count();
        }
        return 0;
    }

    public int calculateSeatsByType(String seatType) {
        if (seats != null) {
            return (int) seats.stream()
                    .filter(seat -> seatType.equals(seat.getSeatType()))
                    .count();
        }
        return 0;
    }

    @Override
    public String toString() {
        return "ScreeningRoom{" + 
                "roomID=" + roomID + 
                ", cinemaID=" + cinemaID + 
                ", roomName=" + roomName + 
                ", seatCapacity=" + seatCapacity + 
                ", roomType=" + roomType + 
                ", isActive=" + isActive + 
                '}';
    }
}