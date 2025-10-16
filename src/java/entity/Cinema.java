/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package entity;

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

    public Cinema() {
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

    @Override
    public String toString() {
        return "Cinema{" + "cinemaID=" + cinemaID + ", cinemaName=" + cinemaName + ", location=" + location + ", totalRooms=" + totalRooms + ", isActive=" + isActive + '}';
    }
    
}
