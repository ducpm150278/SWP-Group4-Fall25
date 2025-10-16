/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package entity;

/**
 *
 * @author admin
 */
public class ScreeningRoom {
    private int roomID;
    private int cinemaID;
    private String roomName;
    private int seatCapacity;
    private String roomType;
    private boolean isActive;

    public ScreeningRoom() {
    }

    public ScreeningRoom(int roomID, int cinemaID, String roomName, int seatCapacity, String roomType, boolean isActive) {
        this.roomID = roomID;
        this.cinemaID = cinemaID;
        this.roomName = roomName;
        this.seatCapacity = seatCapacity;
        this.roomType = roomType;
        this.isActive = isActive;
    }

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

    public boolean isIsActive() {
        return isActive;
    }

    public void setIsActive(boolean isActive) {
        this.isActive = isActive;
    }

    @Override
    public String toString() {
        return "ScreeningRoom{" + "roomID=" + roomID + ", cinemaID=" + cinemaID + ", roomName=" + roomName + ", seatCapacity=" + seatCapacity + ", roomType=" + roomType + ", isActive=" + isActive + '}';
    }
    
    
}
