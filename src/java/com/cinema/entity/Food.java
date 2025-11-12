/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.cinema.entity;

import java.time.LocalDateTime;
import java.math.BigDecimal;

public class Food {
    private Integer foodID;
    private String foodName;
    private String description;
    private BigDecimal price;
    private String foodType;
    private String imageURL;
    private Boolean isAvailable;
    private LocalDateTime createdDate;
    private LocalDateTime lastModifiedDate;

    public Food() {}

    public Food(Integer foodID, String foodName, String description, BigDecimal price, 
                String foodType, String imageURL, Boolean isAvailable, 
                LocalDateTime createdDate, LocalDateTime lastModifiedDate) {
        this.foodID = foodID;
        this.foodName = foodName;
        this.description = description;
        this.price = price;
        this.foodType = foodType;
        this.imageURL = imageURL;
        this.isAvailable = isAvailable;
        this.createdDate = createdDate;
        this.lastModifiedDate = lastModifiedDate;
    }

    // Getters and Setters
    public Integer getFoodID() { return foodID; }
    public void setFoodID(Integer foodID) { this.foodID = foodID; }

    public String getFoodName() { return foodName; }
    public void setFoodName(String foodName) { this.foodName = foodName; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }

    public String getFoodType() { return foodType; }
    public void setFoodType(String foodType) { this.foodType = foodType; }

    public String getImageURL() { return imageURL; }
    public void setImageURL(String imageURL) { this.imageURL = imageURL; }

    public Boolean getIsAvailable() { return isAvailable; }
    public void setIsAvailable(Boolean isAvailable) { this.isAvailable = isAvailable; }

    public LocalDateTime getCreatedDate() { return createdDate; }
    public void setCreatedDate(LocalDateTime createdDate) { this.createdDate = createdDate; }

    public LocalDateTime getLastModifiedDate() { return lastModifiedDate; }
    public void setLastModifiedDate(LocalDateTime lastModifiedDate) { this.lastModifiedDate = lastModifiedDate; }
}
