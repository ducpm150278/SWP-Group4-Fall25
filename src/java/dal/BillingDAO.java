package dal;

import entity.Billing;
import java.sql.*;
import java.time.LocalDateTime;

/**
 * Data Access Object for Billing operations
 */
public class BillingDAO extends DBContext {
    
    /**
     * Create a billing record
     */
    public int createBilling(Billing billing) {
        String sql = "INSERT INTO Billings (UserID, TicketID, DiscountID, TotalAmount, PaymentDate, PaymentMethod) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setInt(1, billing.getUserID());
            ps.setInt(2, billing.getTicketID());
            
            if (billing.getDiscountID() != null) {
                ps.setInt(3, billing.getDiscountID());
            } else {
                ps.setNull(3, Types.INTEGER);
            }
            
            ps.setDouble(4, billing.getTotalAmount());
            ps.setTimestamp(5, Timestamp.valueOf(billing.getPaymentDate()));
            ps.setString(6, billing.getPaymentMethod());
            
            int affectedRows = ps.executeUpdate();
            
            if (affectedRows > 0) {
                ResultSet rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
            
        } catch (SQLException e) {
            System.err.println("Error creating billing: " + e.getMessage());
            e.printStackTrace();
        }
        
        return -1;
    }
    
    /**
     * Create billing records for multiple tickets (one billing per ticket)
     */
    public boolean createBillingsForTickets(int userID, java.util.List<Integer> ticketIDs, 
                                           Integer discountID, double totalAmountPerTicket, 
                                           String paymentMethod) {
        String sql = "INSERT INTO Billings (UserID, TicketID, DiscountID, TotalAmount, PaymentDate, PaymentMethod) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            LocalDateTime paymentDate = LocalDateTime.now();
            
            for (Integer ticketID : ticketIDs) {
                ps.setInt(1, userID);
                ps.setInt(2, ticketID);
                
                if (discountID != null) {
                    ps.setInt(3, discountID);
                } else {
                    ps.setNull(3, Types.INTEGER);
                }
                
                ps.setDouble(4, totalAmountPerTicket);
                ps.setTimestamp(5, Timestamp.valueOf(paymentDate));
                ps.setString(6, paymentMethod);
                
                ps.addBatch();
            }
            
            int[] results = ps.executeBatch();
            return results.length == ticketIDs.size();
            
        } catch (SQLException e) {
            System.err.println("Error creating billings for tickets: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Get billing by ID
     */
    public Billing getBillingByID(int billingID) {
        String sql = "SELECT BillingID, UserID, TicketID, DiscountID, TotalAmount, PaymentDate, PaymentMethod " +
                     "FROM Billings WHERE BillingID = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, billingID);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                Billing billing = new Billing();
                billing.setBillingID(rs.getInt("BillingID"));
                billing.setUserID(rs.getInt("UserID"));
                billing.setTicketID(rs.getInt("TicketID"));
                
                int discountID = rs.getInt("DiscountID");
                if (!rs.wasNull()) {
                    billing.setDiscountID(discountID);
                }
                
                billing.setTotalAmount(rs.getDouble("TotalAmount"));
                billing.setPaymentDate(rs.getTimestamp("PaymentDate").toLocalDateTime());
                billing.setPaymentMethod(rs.getString("PaymentMethod"));
                
                return billing;
            }
            
        } catch (SQLException e) {
            System.err.println("Error getting billing by ID: " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * Get billings by user ID
     */
    public java.util.List<Billing> getBillingsByUserID(int userID) {
        java.util.List<Billing> billings = new java.util.ArrayList<>();
        String sql = "SELECT BillingID, UserID, TicketID, DiscountID, TotalAmount, PaymentDate, PaymentMethod " +
                     "FROM Billings WHERE UserID = ? ORDER BY PaymentDate DESC";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, userID);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Billing billing = new Billing();
                billing.setBillingID(rs.getInt("BillingID"));
                billing.setUserID(rs.getInt("UserID"));
                billing.setTicketID(rs.getInt("TicketID"));
                
                int discountID = rs.getInt("DiscountID");
                if (!rs.wasNull()) {
                    billing.setDiscountID(discountID);
                }
                
                billing.setTotalAmount(rs.getDouble("TotalAmount"));
                billing.setPaymentDate(rs.getTimestamp("PaymentDate").toLocalDateTime());
                billing.setPaymentMethod(rs.getString("PaymentMethod"));
                
                billings.add(billing);
            }
            
        } catch (SQLException e) {
            System.err.println("Error getting billings by user ID: " + e.getMessage());
            e.printStackTrace();
        }
        
        return billings;
    }
    
    /**
     * Get billings by ticket ID
     */
    public Billing getBillingByTicketID(int ticketID) {
        String sql = "SELECT BillingID, UserID, TicketID, DiscountID, TotalAmount, PaymentDate, PaymentMethod " +
                     "FROM Billings WHERE TicketID = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, ticketID);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                Billing billing = new Billing();
                billing.setBillingID(rs.getInt("BillingID"));
                billing.setUserID(rs.getInt("UserID"));
                billing.setTicketID(rs.getInt("TicketID"));
                
                int discountID = rs.getInt("DiscountID");
                if (!rs.wasNull()) {
                    billing.setDiscountID(discountID);
                }
                
                billing.setTotalAmount(rs.getDouble("TotalAmount"));
                billing.setPaymentDate(rs.getTimestamp("PaymentDate").toLocalDateTime());
                billing.setPaymentMethod(rs.getString("PaymentMethod"));
                
                return billing;
            }
            
        } catch (SQLException e) {
            System.err.println("Error getting billing by ticket ID: " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * Update discount usage count
     */
    public boolean updateDiscountUsage(int discountID) {
        String sql = "UPDATE Discounts SET UsageCount = UsageCount + 1 WHERE DiscountID = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, discountID);
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.err.println("Error updating discount usage: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}

