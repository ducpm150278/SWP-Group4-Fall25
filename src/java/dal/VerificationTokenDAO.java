package dal;

import entity.VerificationToken;
import java.sql.*;
import java.time.LocalDateTime;

/**
 * Data Access Object for VerificationToken operations
 * Uses stored procedures from the database for token management
 */
public class VerificationTokenDAO extends DBContext {
    
    /**
     * Create a verification token using the stored procedure
     * @param userID The user ID
     * @param tokenType "EmailVerification" or "PasswordReset"
     * @param expirationHours Token expiration time in hours (default 24)
     * @return The generated token string, or null if failed
     */
    public String createVerificationToken(int userID, String tokenType, int expirationHours) {
        String sql = "{CALL sp_CreateVerificationToken(?, ?, ?, ?)}";
        
        try (Connection conn = getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            
            cs.setInt(1, userID);
            cs.setString(2, tokenType);
            cs.setInt(3, expirationHours);
            cs.registerOutParameter(4, Types.NVARCHAR);
            
            cs.execute();
            return cs.getString(4);
            
        } catch (SQLException e) {
            System.err.println("Error creating verification token: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Create a verification token with default 24-hour expiration
     * @param userID The user ID
     * @param tokenType "EmailVerification" or "PasswordReset"
     * @return The generated token string, or null if failed
     */
    public String createVerificationToken(int userID, String tokenType) {
        return createVerificationToken(userID, tokenType, 24);
    }
    
    /**
     * Verify and use a token using the stored procedure
     * @param token The token string to verify
     * @param tokenType "EmailVerification" or "PasswordReset"
     * @return Array with [isValid (boolean), userID (int)]
     */
    public Object[] verifyToken(String token, String tokenType) {
        String sql = "{CALL sp_VerifyToken(?, ?, ?, ?)}";
        
        try (Connection conn = getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            
            cs.setString(1, token);
            cs.setString(2, tokenType);
            cs.registerOutParameter(3, Types.BIT);
            cs.registerOutParameter(4, Types.INTEGER);
            
            cs.execute();
            
            boolean isValid = cs.getBoolean(3);
            int userID = cs.getInt(4);
            
            return new Object[]{isValid, userID};
            
        } catch (SQLException e) {
            System.err.println("Error verifying token: " + e.getMessage());
            e.printStackTrace();
            return new Object[]{false, 0};
        }
    }
    
    /**
     * Check if a token is valid without marking it as used
     * @param token The token string to check
     * @return true if the token exists and is valid (not used and not expired)
     */
    public boolean isTokenValid(String token) {
        String sql = "SELECT TokenID, IsUsed, ExpiresAt FROM VerificationTokens WHERE Token = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, token);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                boolean isUsed = rs.getBoolean("IsUsed");
                Timestamp expiresAt = rs.getTimestamp("ExpiresAt");
                LocalDateTime expiration = expiresAt.toLocalDateTime();
                
                return !isUsed && LocalDateTime.now().isBefore(expiration);
            }
            
            return false;
            
        } catch (SQLException e) {
            System.err.println("Error checking token validity: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Get token details by token string
     * @param token The token string
     * @return VerificationToken object or null if not found
     */
    public VerificationToken getTokenByString(String token) {
        String sql = "SELECT TokenID, UserID, Token, TokenType, ExpiresAt, IsUsed, CreatedDate "
                   + "FROM VerificationTokens WHERE Token = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, token);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return new VerificationToken(
                    rs.getInt("TokenID"),
                    rs.getInt("UserID"),
                    rs.getString("Token"),
                    rs.getString("TokenType"),
                    rs.getTimestamp("ExpiresAt").toLocalDateTime(),
                    rs.getBoolean("IsUsed"),
                    rs.getTimestamp("CreatedDate").toLocalDateTime()
                );
            }
            
        } catch (SQLException e) {
            System.err.println("Error getting token by string: " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * Delete expired tokens (cleanup)
     * @return Number of tokens deleted
     */
    public int deleteExpiredTokens() {
        String sql = "DELETE FROM VerificationTokens WHERE ExpiresAt < GETDATE()";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            return ps.executeUpdate();
            
        } catch (SQLException e) {
            System.err.println("Error deleting expired tokens: " + e.getMessage());
            e.printStackTrace();
            return 0;
        }
    }
    
    /**
     * Delete all tokens for a user
     * @param userID The user ID
     * @param tokenType Optional token type filter, or null for all types
     * @return Number of tokens deleted
     */
    public int deleteTokensForUser(int userID, String tokenType) {
        String sql = "DELETE FROM VerificationTokens WHERE UserID = ?";
        if (tokenType != null) {
            sql += " AND TokenType = ?";
        }
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, userID);
            if (tokenType != null) {
                ps.setString(2, tokenType);
            }
            
            return ps.executeUpdate();
            
        } catch (SQLException e) {
            System.err.println("Error deleting tokens for user: " + e.getMessage());
            e.printStackTrace();
            return 0;
        }
    }
    
    /**
     * Manually mark a token as used (for cases where you don't use the stored procedure)
     * @param token The token string
     * @return true if successful
     */
    public boolean markTokenAsUsed(String token) {
        String sql = "UPDATE VerificationTokens SET IsUsed = 1 WHERE Token = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, token);
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.err.println("Error marking token as used: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}

