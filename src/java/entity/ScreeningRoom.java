package entity;

import java.time.LocalDateTime;

public class ScreeningRoom {
    private int roomID;
    private int cinemaID;
    private String roomName;
    private int seatCapacity;
    private String roomType; // Standard, IMAX, 3D, VIP
    private boolean isActive;
    private LocalDateTime createdDate;
    
    // Constructors
    public ScreeningRoom() {}
    
    public ScreeningRoom(int roomID, int cinemaID, String roomName, int seatCapacity, 
                        String roomType, boolean isActive, LocalDateTime createdDate) {
        this.roomID = roomID;
        this.cinemaID = cinemaID;
        this.roomName = roomName;
        this.seatCapacity = seatCapacity;
        this.roomType = roomType;
        this.isActive = isActive;
        this.createdDate = createdDate;
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
    
    public LocalDateTime getCreatedDate() {
        return createdDate;
    }
    
    public void setCreatedDate(LocalDateTime createdDate) {
        this.createdDate = createdDate;
    }
    
    @Override
    public String toString() {
        return "ScreeningRoom{" +
                "roomID=" + roomID +
                ", cinemaID=" + cinemaID +
                ", roomName='" + roomName + '\'' +
                ", seatCapacity=" + seatCapacity +
                ", roomType='" + roomType + '\'' +
                ", isActive=" + isActive +
                ", createdDate=" + createdDate +
                '}';
    }
}