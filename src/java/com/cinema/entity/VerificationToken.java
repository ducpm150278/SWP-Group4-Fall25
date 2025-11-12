package com.cinema.entity;


import java.time.LocalDateTime;

/**
 * Entity class representing an email verification or password reset token
 */
public class VerificationToken {
    private int tokenID;
    private int userID;
    private String token;
    private String tokenType; // EmailVerification, PasswordReset
    private LocalDateTime expiresAt;
    private boolean isUsed;
    private LocalDateTime createdDate;
    
    // Constructors
    public VerificationToken() {
    }
    
    public VerificationToken(int tokenID, int userID, String token, String tokenType,
                            LocalDateTime expiresAt, boolean isUsed, LocalDateTime createdDate) {
        this.tokenID = tokenID;
        this.userID = userID;
        this.token = token;
        this.tokenType = tokenType;
        this.expiresAt = expiresAt;
        this.isUsed = isUsed;
        this.createdDate = createdDate;
    }
    
    // Getters and Setters
    public int getTokenID() {
        return tokenID;
    }
    
    public void setTokenID(int tokenID) {
        this.tokenID = tokenID;
    }
    
    public int getUserID() {
        return userID;
    }
    
    public void setUserID(int userID) {
        this.userID = userID;
    }
    
    public String getToken() {
        return token;
    }
    
    public void setToken(String token) {
        this.token = token;
    }
    
    public String getTokenType() {
        return tokenType;
    }
    
    public void setTokenType(String tokenType) {
        this.tokenType = tokenType;
    }
    
    public LocalDateTime getExpiresAt() {
        return expiresAt;
    }
    
    public void setExpiresAt(LocalDateTime expiresAt) {
        this.expiresAt = expiresAt;
    }
    
    public boolean isUsed() {
        return isUsed;
    }
    
    public void setUsed(boolean isUsed) {
        this.isUsed = isUsed;
    }
    
    public LocalDateTime getCreatedDate() {
        return createdDate;
    }
    
    public void setCreatedDate(LocalDateTime createdDate) {
        this.createdDate = createdDate;
    }
    
    // Helper methods
    public boolean isExpired() {
        return LocalDateTime.now().isAfter(expiresAt);
    }
    
    public boolean isValid() {
        return !isUsed && !isExpired();
    }
    
    @Override
    public String toString() {
        return "VerificationToken{" +
                "tokenID=" + tokenID +
                ", userID=" + userID +
                ", token='" + token + '\'' +
                ", tokenType='" + tokenType + '\'' +
                ", expiresAt=" + expiresAt +
                ", isUsed=" + isUsed +
                ", createdDate=" + createdDate +
                '}';
    }
}

