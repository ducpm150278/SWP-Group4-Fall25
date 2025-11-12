/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.cinema.entity;

import java.time.LocalDateTime;

/**
 *
 * @author admin
 */
public class Discount {
    private int discountID;
    private int createdBy;
    private String code;
    private String discountType;  // "Percentage" or "FixedAmount"
    private double discountValue; // The value from database
    private int maxUsage;
    private int usageCount;
    private LocalDateTime startDate;
    private LocalDateTime endDate;
    private String status;
    
    // Computed field for backward compatibility
    private double discountPercentage;

    public Discount(int discountID, int createdBy, String code, String discountType, double discountValue, 
                    int maxUsage, int usageCount, LocalDateTime startDate, LocalDateTime endDate, String status) {
        this.discountID = discountID;
        this.createdBy = createdBy;
        this.code = code;
        this.discountType = discountType;
        this.discountValue = discountValue;
        this.maxUsage = maxUsage;
        this.usageCount = usageCount;
        this.startDate = startDate;
        this.endDate = endDate;
        this.status = status;
        
        // Set discountPercentage for backward compatibility
        if ("Percentage".equals(discountType)) {
            this.discountPercentage = discountValue;
        }
    }

    public Discount() {
    }

    public int getDiscountID() {
        return discountID;
    }

    public void setDiscountID(int discountID) {
        this.discountID = discountID;
    }

    public int getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(int createdBy) {
        this.createdBy = createdBy;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public int getMaxUsage() {
        return maxUsage;
    }

    public void setMaxUsage(int maxUsage) {
        this.maxUsage = maxUsage;
    }

    public int getUsageCount() {
        return usageCount;
    }

    public void setUsageCount(int usageCount) {
        this.usageCount = usageCount;
    }

    public LocalDateTime getStartDate() {
        return startDate;
    }

    public void setStartDate(LocalDateTime startDate) {
        this.startDate = startDate;
    }

    public LocalDateTime getEndDate() {
        return endDate;
    }

    public void setEndDate(LocalDateTime endDate) {
        this.endDate = endDate;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getDiscountType() {
        return discountType;
    }

    public void setDiscountType(String discountType) {
        this.discountType = discountType;
        // Update discountPercentage when type changes
        if ("Percentage".equals(discountType)) {
            this.discountPercentage = this.discountValue;
        }
    }

    public double getDiscountValue() {
        return discountValue;
    }

    public void setDiscountValue(double discountValue) {
        this.discountValue = discountValue;
        // Update discountPercentage if type is Percentage
        if ("Percentage".equals(this.discountType)) {
            this.discountPercentage = discountValue;
        }
    }

    public double getDiscountPercentage() {
        return discountPercentage;
    }

    public void setDiscountPercentage(double discountPercentage) {
        this.discountPercentage = discountPercentage;
        // Also update discountValue and type for consistency
        this.discountType = "Percentage";
        this.discountValue = discountPercentage;
    }
    
    /**
     * Calculate discount amount based on type
     * @param subtotal The subtotal amount to calculate discount from
     * @return The discount amount
     */
    public double calculateDiscountAmount(double subtotal) {
        if ("Percentage".equals(discountType)) {
            return subtotal * (discountValue / 100.0);
        } else if ("FixedAmount".equals(discountType)) {
            return Math.min(discountValue, subtotal); // Don't discount more than subtotal
        }
        return 0;
    }

    @Override
    public String toString() {
        return "Discount{" + "discountID=" + discountID + ", createdBy=" + createdBy + ", code=" + code + 
               ", discountType=" + discountType + ", discountValue=" + discountValue + 
               ", maxUsage=" + maxUsage + ", usageCount=" + usageCount + ", startDate=" + startDate + 
               ", endDate=" + endDate + ", status=" + status + '}';
    }
    
    
}
