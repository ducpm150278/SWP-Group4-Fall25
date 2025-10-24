/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package entity;

import java.time.LocalDateTime;

/**
 *
 * @author admin
 */
public class Discount {
    private int discountID;
    private int createdBy;
    private String code;
    private int maxUsage;
    private int usageCount;
    private LocalDateTime startDate;
    private LocalDateTime endDate;
    private String status;
    private double discountPercentage;

    public Discount(int discountID, int createdBy, String code, int maxUsage, int usageCount, LocalDateTime startDate, LocalDateTime endDate, String status, double discountPercentage) {
        this.discountID = discountID;
        this.createdBy = createdBy;
        this.code = code;
        this.maxUsage = maxUsage;
        this.usageCount = usageCount;
        this.startDate = startDate;
        this.endDate = endDate;
        this.status = status;
        this.discountPercentage = discountPercentage;
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

    public double getDiscountPercentage() {
        return discountPercentage;
    }

    public void setDiscountPercentage(double discountPercentage) {
        this.discountPercentage = discountPercentage;
    }

    @Override
    public String toString() {
        return "Discount{" + "discountID=" + discountID + ", createdBy=" + createdBy + ", code=" + code + ", maxUsage=" + maxUsage + ", usageCount=" + usageCount + ", startDate=" + startDate + ", endDate=" + endDate + ", status=" + status + ", discountPercentage=" + discountPercentage + '}';
    }
    
    
}
