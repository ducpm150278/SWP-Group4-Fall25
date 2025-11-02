package entity;

import java.time.LocalDateTime;
import java.util.List;

public class CinemaM {
    private int cinemaID;
    private String cinemaName;
    private String location;
    private String address;
    private int totalRooms;
    private boolean isActive;
    private LocalDateTime createdDate;
    private List<ScreeningRoom> screeningRooms;

    // Constructors 
    public CinemaM() {
    }

    public CinemaM(int cinemaID, String cinemaName, String location, String address, 
            boolean isActive, LocalDateTime createdDate) {
        this.cinemaID = cinemaID;
        this.cinemaName = cinemaName;
        this.location = location;
        this.address = address;
        this.totalRooms = 0;
        this.isActive = isActive;
        this.createdDate = createdDate;
    }

    public CinemaM(int cinemaID, String cinemaName, String location, String address, 
            int totalRooms, boolean isActive, LocalDateTime createdDate) {
        this.cinemaID = cinemaID;
        this.cinemaName = cinemaName;
        this.location = location;
        this.address = address;
        this.totalRooms = totalRooms;
        this.isActive = isActive;
        this.createdDate = createdDate;
    }

    // Getters and Setters 
    public int getCinemaID() {
        return cinemaID;
    }

    public void setCinemaID(int cinemaID) {
        this.cinemaID = cinemaID;
    }

    public String getCinemaName() {
        return cinemaName;
    }

    public void setCinemaName(String cinemaName) {
        this.cinemaName = cinemaName;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public int getTotalRooms() {
        return totalRooms;
    }

    public void setTotalRooms(int totalRooms) {
        this.totalRooms = totalRooms;
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

    public List<ScreeningRoom> getScreeningRooms() {
        return screeningRooms;
    }

    public void setScreeningRooms(List<ScreeningRoom> screeningRooms) {
        this.screeningRooms = screeningRooms;
        // Tự động cập nhật totalRooms khi set screeningRooms
        if (screeningRooms != null) {
            this.totalRooms = screeningRooms.size();
        } else {
            this.totalRooms = 0;
        }
    }

    // Helper methods
    public int calculateTotalRooms() {
        if (screeningRooms != null) {
            return screeningRooms.size();
        }
        return 0;
    }

    public int calculateActiveRooms() {
        if (screeningRooms != null) {
            return (int) screeningRooms.stream()
                    .filter(ScreeningRoom::isActive)
                    .count();
        }
        return 0;
    }

    @Override
    public String toString() {
        return "Cinema{" +
                "cinemaID=" + cinemaID +
                ", cinemaName='" + cinemaName + '\'' +
                ", location='" + location + '\'' +
                ", address='" + address + '\'' +
                ", totalRooms=" + totalRooms +
                ", isActive=" + isActive +
                ", createdDate=" + createdDate +
                '}';
    }
}