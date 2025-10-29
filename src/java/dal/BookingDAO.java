package dal;

import entity.Booking;
import java.sql.*;
import java.time.LocalDateTime;

/**
 * Data Access Object for Booking operations
 */
public class BookingDAO extends DBContext {
    
    /**
     * Create a new booking and return the generated BookingID
     */
    public int createBooking(Booking booking) {
        String sql = "INSERT INTO Bookings (BookingCode, UserID, ScreeningID, BookingDate, " +
                     "TotalAmount, DiscountAmount, FinalAmount, Status, PaymentStatus, " +
                     "PaymentMethod, PaymentDate, Notes) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        System.out.println("BookingDAO: Creating booking...");
        System.out.println("  BookingCode: " + booking.getBookingCode());
        System.out.println("  UserID: " + booking.getUserID());
        System.out.println("  ScreeningID: " + booking.getScreeningID());
        System.out.println("  TotalAmount: " + booking.getTotalAmount());
        System.out.println("  FinalAmount: " + booking.getFinalAmount());
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setString(1, booking.getBookingCode());
            ps.setInt(2, booking.getUserID());
            ps.setInt(3, booking.getScreeningID());
            ps.setTimestamp(4, Timestamp.valueOf(booking.getBookingDate()));
            ps.setDouble(5, booking.getTotalAmount());
            ps.setDouble(6, booking.getDiscountAmount());
            ps.setDouble(7, booking.getFinalAmount());
            ps.setString(8, booking.getStatus());
            ps.setString(9, booking.getPaymentStatus());
            ps.setString(10, booking.getPaymentMethod());
            
            if (booking.getPaymentDate() != null) {
                ps.setTimestamp(11, Timestamp.valueOf(booking.getPaymentDate()));
            } else {
                ps.setNull(11, Types.TIMESTAMP);
            }
            
            ps.setString(12, booking.getNotes());
            
            int affectedRows = ps.executeUpdate();
            
            if (affectedRows > 0) {
                ResultSet rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    int bookingID = rs.getInt(1);
                    System.out.println("✓ Created booking with ID: " + bookingID);
                    return bookingID;
                }
            }
            
        } catch (SQLException e) {
            System.err.println("=== ERROR creating booking ===");
            System.err.println("SQL State: " + e.getSQLState());
            System.err.println("Error Code: " + e.getErrorCode());
            System.err.println("Message: " + e.getMessage());
            e.printStackTrace();
        }
        
        return -1;
    }
    
    /**
     * Update booking status
     */
    public boolean updateBookingStatus(int bookingID, String status) {
        String sql = "UPDATE Bookings SET Status = ? WHERE BookingID = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, status);
            ps.setInt(2, bookingID);
            
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.err.println("Error updating booking status: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Update booking payment status
     */
    public boolean updatePaymentStatus(int bookingID, String paymentStatus, LocalDateTime paymentDate) {
        String sql = "UPDATE Bookings SET PaymentStatus = ?, PaymentDate = ? WHERE BookingID = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, paymentStatus);
            if (paymentDate != null) {
                ps.setTimestamp(2, Timestamp.valueOf(paymentDate));
            } else {
                ps.setNull(2, Types.TIMESTAMP);
            }
            ps.setInt(3, bookingID);
            
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.err.println("Error updating payment status: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Generate unique booking code
     */
    public String generateBookingCode() {
        String prefix = "BK";
        String timestamp = String.format("%tY%<tm%<td%<tH%<tM", System.currentTimeMillis());
        int random = (int) (Math.random() * 90000) + 10000; // 5 digit random
        
        String bookingCode = prefix + timestamp + random;
        
        // Check if exists and regenerate if needed
        while (bookingCodeExists(bookingCode)) {
            random = (int) (Math.random() * 90000) + 10000;
            bookingCode = prefix + timestamp + random;
        }
        
        System.out.println("Generated booking code: " + bookingCode);
        return bookingCode;
    }
    
    /**
     * Check if booking code exists
     */
    private boolean bookingCodeExists(String bookingCode) {
        String sql = "SELECT COUNT(*) FROM Bookings WHERE BookingCode = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, bookingCode);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
            
        } catch (SQLException e) {
            System.err.println("Error checking booking code: " + e.getMessage());
        }
        
        return false;
    }
    
    /**
     * Get booking by ID
     */
    public Booking getBookingByID(int bookingID) {
        String sql = "SELECT * FROM Bookings WHERE BookingID = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, bookingID);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return extractBookingFromResultSet(rs);
            }
            
        } catch (SQLException e) {
            System.err.println("Error getting booking: " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * Extract Booking object from ResultSet
     */
    private Booking extractBookingFromResultSet(ResultSet rs) throws SQLException {
        Booking booking = new Booking();
        booking.setBookingID(rs.getInt("BookingID"));
        booking.setBookingCode(rs.getString("BookingCode"));
        booking.setUserID(rs.getInt("UserID"));
        booking.setScreeningID(rs.getInt("ScreeningID"));
        booking.setBookingDate(rs.getTimestamp("BookingDate").toLocalDateTime());
        booking.setTotalAmount(rs.getDouble("TotalAmount"));
        booking.setDiscountAmount(rs.getDouble("DiscountAmount"));
        booking.setFinalAmount(rs.getDouble("FinalAmount"));
        booking.setStatus(rs.getString("Status"));
        booking.setPaymentStatus(rs.getString("PaymentStatus"));
        booking.setPaymentMethod(rs.getString("PaymentMethod"));
        
        Timestamp paymentDate = rs.getTimestamp("PaymentDate");
        if (paymentDate != null) {
            booking.setPaymentDate(paymentDate.toLocalDateTime());
        }
        
        booking.setNotes(rs.getString("Notes"));
        
        return booking;
    }
}

