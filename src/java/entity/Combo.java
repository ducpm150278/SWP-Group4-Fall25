/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package entity;

import java.time.LocalDateTime;
import java.math.BigDecimal;

public class Combo {
    private Integer comboID;
    private String comboName;
    private String description;
    private BigDecimal totalPrice;
    private BigDecimal discountPrice;
    private String comboImage;
    private Boolean isAvailable;
    private LocalDateTime createdDate;
    private LocalDateTime lastModifiedDate;

    public Combo() {}

    public Combo(Integer comboID, String comboName, String description, BigDecimal totalPrice, 
                 BigDecimal discountPrice, String comboImage, Boolean isAvailable, 
                 LocalDateTime createdDate, LocalDateTime lastModifiedDate) {
        this.comboID = comboID;
        this.comboName = comboName;
        this.description = description;
        this.totalPrice = totalPrice;
        this.discountPrice = discountPrice;
        this.comboImage = comboImage;
        this.isAvailable = isAvailable;
        this.createdDate = createdDate;
        this.lastModifiedDate = lastModifiedDate;
    }

    // Getters and Setters
    public Integer getComboID() { return comboID; }
    public void setComboID(Integer comboID) { this.comboID = comboID; }

    public String getComboName() { return comboName; }
    public void setComboName(String comboName) { this.comboName = comboName; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public BigDecimal getTotalPrice() { return totalPrice; }
    public void setTotalPrice(BigDecimal totalPrice) { this.totalPrice = totalPrice; }

    public BigDecimal getDiscountPrice() { return discountPrice; }
    public void setDiscountPrice(BigDecimal discountPrice) { this.discountPrice = discountPrice; }

    public String getComboImage() { return comboImage; }
    public void setComboImage(String comboImage) { this.comboImage = comboImage; }

    public Boolean getIsAvailable() { return isAvailable; }
    public void setIsAvailable(Boolean isAvailable) { this.isAvailable = isAvailable; }

    public LocalDateTime getCreatedDate() { return createdDate; }
    public void setCreatedDate(LocalDateTime createdDate) { this.createdDate = createdDate; }

    public LocalDateTime getLastModifiedDate() { return lastModifiedDate; }
    public void setLastModifiedDate(LocalDateTime lastModifiedDate) { this.lastModifiedDate = lastModifiedDate; }
}
