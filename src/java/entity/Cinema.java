package entity;

import java.time.LocalDateTime;
import java.util.List;

public class Cinema {

    private int cinemaID;
    private String cinemaName;
    private String location;
    private int totalRooms; // Sẽ được tính từ số lượng ScreeningRoom
    private boolean isActive;
    private LocalDateTime createdDate;
    private List<ScreeningRoom> screeningRooms; // Danh sách phòng chiếu

    // Constructors
    public Cinema() {
    }

    public Cinema(int cinemaID, String cinemaName, String location, int totalRooms,
            boolean isActive, LocalDateTime createdDate) {
        this.cinemaID = cinemaID;
        this.cinemaName = cinemaName;
        this.location = location;
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
    }

    @Override
    public String toString() {
        return "Cinema{"
                + "cinemaID=" + cinemaID
                + ", cinemaName='" + cinemaName + '\''
                + ", location='" + location + '\''
                + ", totalRooms=" + totalRooms
                + ", isActive=" + isActive
                + ", createdDate=" + createdDate
                + '}';
    }
}
