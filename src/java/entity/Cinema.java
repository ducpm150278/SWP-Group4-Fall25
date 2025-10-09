/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package entity;

import java.time.LocalDateTime;

/**
 *
 * @author dungv
 */
public class Cinema {

    private Integer cinemaID;
    private String cinemaName;
    private String location;
    private Integer totalRooms;
    private Boolean isActive;
    private LocalDateTime createdDate;

    // Constructor mặc định
    public Cinema() {
    }

    // Constructor với tất cả tham số
    public Cinema(Integer cinemaID, String cinemaName, String location,
            Integer totalRooms, Boolean isActive, LocalDateTime createdDate) {
        this.cinemaID = cinemaID;
        this.cinemaName = cinemaName;
        this.location = location;
        this.totalRooms = totalRooms;
        this.isActive = isActive;
        this.createdDate = createdDate;
    }

    // Constructor không có ID (dùng khi tạo mới)
    public Cinema(String cinemaName, String location, Integer totalRooms,
            Boolean isActive, LocalDateTime createdDate) {
        this.cinemaName = cinemaName;
        this.location = location;
        this.totalRooms = totalRooms;
        this.isActive = isActive;
        this.createdDate = createdDate;
    }

    // Getter và Setter
    public Integer getCinemaID() {
        return cinemaID;
    }

    public void setCinemaID(Integer cinemaID) {
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

    public Integer getTotalRooms() {
        return totalRooms;
    }

    public void setTotalRooms(Integer totalRooms) {
        this.totalRooms = totalRooms;
    }

    public Boolean getIsActive() {
        return isActive;
    }

    public void setIsActive(Boolean isActive) {
        this.isActive = isActive;
    }

    public LocalDateTime getCreatedDate() {
        return createdDate;
    }

    public void setCreatedDate(LocalDateTime createdDate) {
        this.createdDate = createdDate;
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
