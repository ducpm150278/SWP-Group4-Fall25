package entity;

import java.time.LocalDateTime;
import java.util.List;

public class Cinema {

    private int cinemaID;
    private String cinemaName;
    private String location; // Full address
    private String city; // e.g., "Hồ Chí Minh"
    private String district; // e.g., "Quận 1"
    private int totalRooms;
    private String phoneNumber;
    private boolean isActive;
    private LocalDateTime createdDate;
    private List<ScreeningRoom> screeningRooms; // Danh sách phòng chiếu

    // Constructors
    public Cinema() {
    }

    public Cinema(int cinemaID, String cinemaName, String location, String city, String district,
            int totalRooms, String phoneNumber, boolean isActive, LocalDateTime createdDate) {
        this.cinemaID = cinemaID;
        this.cinemaName = cinemaName;
        this.location = location;
        this.city = city;
        this.district = district;
        this.totalRooms = totalRooms;
        this.phoneNumber = phoneNumber;
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

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public String getDistrict() {
        return district;
    }

    public void setDistrict(String district) {
        this.district = district;
    }

    public int getTotalRooms() {
        return totalRooms;
    }

    public void setTotalRooms(int totalRooms) {
        this.totalRooms = totalRooms;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
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

    // Helper method để tính tổng số phòng từ danh sách screeningRooms
    public int calculateTotalRooms() {
        if (screeningRooms != null) {
            return screeningRooms.size();
        }
        return 0;
    }

    // Helper method để tính tổng số phòng active
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
        return "Cinema{"
                + "cinemaID=" + cinemaID
                + ", cinemaName='" + cinemaName + '\''
                + ", location='" + location + '\''
                + ", city='" + city + '\''
                + ", district='" + district + '\''
                + ", totalRooms=" + totalRooms
                + ", phoneNumber='" + phoneNumber + '\''
                + ", isActive=" + isActive
                + ", createdDate=" + createdDate
                + '}';
    }
}
