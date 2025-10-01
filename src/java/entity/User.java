/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package entity;

import java.time.LocalDate;
import java.time.LocalDateTime;

public class User {
    private Integer userID;
    private String fullName;
    private String email;
    private String phoneNumber;
    private String password;
    private String gender;
    private LocalDate dateOfBirth;
    private String address;
    private String accountStatus;
    private String role;
    private LocalDateTime createdDate;
    private LocalDateTime lastModifiedDate;

    public User() {}

    public User(Integer userID, String fullName, String email, String phoneNumber, String password, String gender, LocalDate dateOfBirth,
            String address, String accountStatus, String role, LocalDateTime createdDate, LocalDateTime lastModifiedDate) {
        
        this.userID = userID;
        this.fullName = fullName;
        this.email = email;
        this.phoneNumber = phoneNumber;
        this.password = password;
        this.gender = gender;
        this.dateOfBirth = dateOfBirth;
        this.address = address;
        this.accountStatus = accountStatus;
        this.role = role;
        this.createdDate = createdDate;
        this.lastModifiedDate = lastModifiedDate;
    }


    // Getters and Setters
    public Integer getUserID() { return userID; }
    public void setUserID(Integer userID) { this.userID = userID; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }

    public LocalDate getDateOfBirth() { return dateOfBirth; }
    public void setDateOfBirth(LocalDate dateOfBirth) { this.dateOfBirth = dateOfBirth; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }
    
    public String getAccountStatus() { return accountStatus; }
    public void setAccountStatus(String accountStatus) { this.accountStatus = accountStatus; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public LocalDateTime getCreatedDate() { return createdDate; }
    public void setCreatedDate(LocalDateTime createdDate) { this.createdDate = createdDate; }

    public LocalDateTime getLastModifiedDate() { return lastModifiedDate; }
    public void setLastModifiedDate(LocalDateTime lastModifiedDate) { this.lastModifiedDate = lastModifiedDate; }
}