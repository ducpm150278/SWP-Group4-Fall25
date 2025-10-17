/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package entity;

import java.time.LocalDateTime;
import java.util.List;

/**
 *
 * @author admin
 */
public class Cinema {
    private int cinemaID;
    private String cinemaName;
    private String location;
    private int totalRooms;
    private boolean isActive;
    private String address; // Thêm trường address\
    private LocalDateTime createdDate;
    private List<ScreeningRoom> screeningRooms; // Danh sách phòng chiếu
    public Cinema() {
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
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
   public Cinema(int cinemaID, String cinemaName, String location, String address, 
            int totalRooms, boolean isActive, LocalDateTime createdDate) {
        this.cinemaID = cinemaID;
        this.cinemaName = cinemaName;
        this.location = location;
        this.address = address;
        this.totalRooms = totalRooms;
        this.isActive = isActive;
        this.createdDate = createdDate;
    }
    public Cinema(int cinemaID, String cinemaName, String location, int totalRooms, boolean isActive) {
        this.cinemaID = cinemaID;
        this.cinemaName = cinemaName;
        this.location = location;
        this.totalRooms = totalRooms;
        this.isActive = isActive;
    }

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

    public boolean isIsActive() {
        return isActive;
    }

    public void setIsActive(boolean isActive) {
        this.isActive = isActive;
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
        return "Cinema{" + "cinemaID=" + cinemaID + ", cinemaName=" + cinemaName + ", location=" + location + ", totalRooms=" + totalRooms + ", isActive=" + isActive + '}';
    }
    
}
