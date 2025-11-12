package com.cinema.dal;


import com.cinema.entity.Seat;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for Seat operations
 */
public class SeatDAO extends DBContext {
    
    /**
     * Get all seats for a specific room
     */
    public List<Seat> getSeatsByRoomID(int roomID) {
        List<Seat> seats = new ArrayList<>();
        String sql = "SELECT SeatID, RoomID, SeatRow, SeatNumber, SeatType, PriceMultiplier, Status " +
                     "FROM Seats WHERE RoomID = ? ORDER BY SeatRow, SeatNumber";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, roomID);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Seat seat = new Seat(
                    rs.getInt("SeatID"),
                    rs.getInt("RoomID"),
                    rs.getString("SeatRow"),
                    rs.getString("SeatNumber"),
                    rs.getString("SeatType"),
                    rs.getDouble("PriceMultiplier"),
                    rs.getString("Status")
                );
                seats.add(seat);
            }
        } catch (SQLException e) {
            System.err.println("Error getting seats by room ID: " + e.getMessage());
            e.printStackTrace();
        }
        
        return seats;
    }
    
    /**
     * Get booked seat IDs for a specific screening
     * Only includes seats from bookings with status 'Confirmed' or 'Completed'
     * Excludes cancelled bookings
     */
    public List<Integer> getBookedSeatsForScreening(int screeningID) {
        List<Integer> bookedSeatIDs = new ArrayList<>();
        String sql = "SELECT DISTINCT t.SeatID " +
                     "FROM Tickets t " +
                     "INNER JOIN Bookings b ON t.BookingID = b.BookingID " +
                     "WHERE t.ScreeningID = ? " +
                     "  AND b.Status IN ('Confirmed', 'Completed')";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, screeningID);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                bookedSeatIDs.add(rs.getInt("SeatID"));
            }
        } catch (SQLException e) {
            System.err.println("Error getting booked seats: " + e.getMessage());
            e.printStackTrace();
        }
        
        return bookedSeatIDs;
    }
    
    /**
     * Get reserved seat IDs for a specific screening (temporary reservations)
     */
    public List<Integer> getReservedSeatsForScreening(int screeningID) {
        List<Integer> reservedSeatIDs = new ArrayList<>();
        String sql = "SELECT DISTINCT SeatID FROM SeatReservations " +
                     "WHERE ScreeningID = ? AND ExpiresAt > GETDATE()";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, screeningID);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                reservedSeatIDs.add(rs.getInt("SeatID"));
            }
        } catch (SQLException e) {
            System.err.println("Error getting reserved seats: " + e.getMessage());
            e.printStackTrace();
        }
        
        return reservedSeatIDs;
    }
    
    /**
     * Reserve seats temporarily for a session (15 minutes)
     * Uses transaction to ensure atomicity and handles race conditions
     */
    public boolean reserveSeats(List<Integer> seatIDs, int screeningID, String sessionID) {
        Connection conn = null;
        PreparedStatement psRelease = null;
        PreparedStatement psInsert = null;
        
        try {
            conn = getConnection();
            // Start transaction with appropriate isolation level
            conn.setAutoCommit(false);
            conn.setTransactionIsolation(Connection.TRANSACTION_READ_COMMITTED);
            
            // Step 1: Release existing reservations for this session
            String sqlRelease = "DELETE FROM SeatReservations WHERE SessionID = ?";
            psRelease = conn.prepareStatement(sqlRelease);
            psRelease.setString(1, sessionID);
            psRelease.executeUpdate();
            
            // Step 2: Attempt to insert new reservations atomically
            String sqlInsert = "INSERT INTO SeatReservations (SeatID, ScreeningID, SessionID, ReservedAt, ExpiresAt) " +
                               "VALUES (?, ?, ?, GETDATE(), DATEADD(MINUTE, 15, GETDATE()))";
            psInsert = conn.prepareStatement(sqlInsert);
            
            for (Integer seatID : seatIDs) {
                psInsert.setInt(1, seatID);
                psInsert.setInt(2, screeningID);
                psInsert.setString(3, sessionID);
                psInsert.addBatch();
            }
            
            int[] results = psInsert.executeBatch();
            
            // Verify all inserts succeeded
            if (results.length != seatIDs.size()) {
                conn.rollback();
                return false;
            }
            
            // Commit transaction
            conn.commit();
            return true;
            
        } catch (SQLException e) {
            // Handle constraint violation (duplicate seat reservation)
            if (e.getErrorCode() == 2601 || e.getErrorCode() == 2627) {
                // SQL Server unique constraint violation
                System.err.println("Seat reservation conflict - seats already taken: " + e.getMessage());
            } else {
                System.err.println("Error reserving seats: " + e.getMessage());
                e.printStackTrace();
            }
            
            // Rollback on any error
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException rollbackEx) {
                    System.err.println("Error rolling back transaction: " + rollbackEx.getMessage());
                }
            }
            return false;
            
        } finally {
            // Clean up resources
            try {
                if (psRelease != null) psRelease.close();
                if (psInsert != null) psInsert.close();
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (SQLException e) {
                System.err.println("Error closing resources: " + e.getMessage());
            }
        }
    }
    
    /**
     * Release expired reservations
     */
    public int releaseExpiredReservations() {
        String sql = "DELETE FROM SeatReservations WHERE ExpiresAt <= GETDATE()";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            return ps.executeUpdate();
            
        } catch (SQLException e) {
            System.err.println("Error releasing expired reservations: " + e.getMessage());
            e.printStackTrace();
            return 0;
        }
    }
    
    /**
     * Release reservations for a specific session
     */
    public boolean releaseReservationsBySession(String sessionID) {
        String sql = "DELETE FROM SeatReservations WHERE SessionID = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, sessionID);
            ps.executeUpdate();
            return true;
            
        } catch (SQLException e) {
            System.err.println("Error releasing reservations by session: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Update seat status (for maintenance, etc.)
     * Note: 'Booked' is no longer a valid stored status - booked status is managed via Tickets table
     */
    public boolean updateSeatStatus(int seatID, String status) {
        // Validate status - 'Booked' is not allowed as stored status
        if (status != null && "Booked".equalsIgnoreCase(status)) {
            System.err.println("Error: Cannot set seat status to 'Booked'. Booked status is managed via Tickets table.");
            return false;
        }
        
        String sql = "UPDATE Seats SET Status = ? WHERE SeatID = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, status);
            ps.setInt(2, seatID);
            
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.err.println("Error updating seat status: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Get seat by ID
     */
    public Seat getSeatByID(int seatID) {
        String sql = "SELECT SeatID, RoomID, SeatRow, SeatNumber, SeatType, PriceMultiplier, Status " +
                     "FROM Seats WHERE SeatID = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, seatID);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return new Seat(
                    rs.getInt("SeatID"),
                    rs.getInt("RoomID"),
                    rs.getString("SeatRow"),
                    rs.getString("SeatNumber"),
                    rs.getString("SeatType"),
                    rs.getDouble("PriceMultiplier"),
                    rs.getString("Status")
                );
            }
        } catch (SQLException e) {
            System.err.println("Error getting seat by ID: " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * Check if seats are available for booking
     * More efficient version that checks all seats in a single query
     */
    public boolean areSeatsAvailable(List<Integer> seatIDs, int screeningID, String excludeSessionID) {
        if (seatIDs == null || seatIDs.isEmpty()) {
            return false;
        }
        
        // Build parameter placeholders for IN clause
        String placeholders = String.join(",", seatIDs.stream().map(id -> "?").toArray(String[]::new));
        
        // Check booked seats (from Tickets with Confirmed/Completed bookings only), 
        // reserved seats (from SeatReservations), and seats with Unavailable/Maintenance status
        String sql = "SELECT COUNT(DISTINCT SeatID) as UnavailableCount FROM ( " +
                     "  SELECT t.SeatID FROM Tickets t " +
                     "  INNER JOIN Bookings b ON t.BookingID = b.BookingID " +
                     "  WHERE t.ScreeningID = ? AND t.SeatID IN (" + placeholders + ") " +
                     "    AND b.Status IN ('Confirmed', 'Completed') " +
                     "  UNION " +
                     "  SELECT SeatID FROM SeatReservations " +
                     "  WHERE ScreeningID = ? AND SeatID IN (" + placeholders + ") " +
                     "    AND SessionID != ? AND ExpiresAt > GETDATE() " +
                     "  UNION " +
                     "  SELECT SeatID FROM Seats " +
                     "  WHERE SeatID IN (" + placeholders + ") " +
                     "    AND Status IN ('Unavailable', 'Maintenance') " +
                     ") AS UnavailableSeats";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            int paramIndex = 1;
            
            // Set screeningID for Tickets check
            ps.setInt(paramIndex++, screeningID);
            
            // Set seatIDs for Tickets check
            for (Integer seatID : seatIDs) {
                ps.setInt(paramIndex++, seatID);
            }
            
            // Set screeningID for SeatReservations check
            ps.setInt(paramIndex++, screeningID);
            
            // Set seatIDs for SeatReservations check
            for (Integer seatID : seatIDs) {
                ps.setInt(paramIndex++, seatID);
            }
            
            // Set excludeSessionID
            ps.setString(paramIndex++, excludeSessionID != null ? excludeSessionID : "");
            
            // Set seatIDs for Seats status check (Unavailable/Maintenance)
            for (Integer seatID : seatIDs) {
                ps.setInt(paramIndex++, seatID);
            }
            
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                int unavailableCount = rs.getInt("UnavailableCount");
                return unavailableCount == 0; // All seats must be available
            }
            
            return false;
            
        } catch (SQLException e) {
            System.err.println("Error checking seat availability: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Get list of unavailable seats from the requested seats
     * Useful for providing specific feedback to users
     */
    public List<Integer> getUnavailableSeats(List<Integer> seatIDs, int screeningID, String excludeSessionID) {
        List<Integer> unavailableSeats = new ArrayList<>();
        
        if (seatIDs == null || seatIDs.isEmpty()) {
            return unavailableSeats;
        }
        
        // Build parameter placeholders for IN clause
        String placeholders = String.join(",", seatIDs.stream().map(id -> "?").toArray(String[]::new));
        
        // Get unavailable seat IDs (booked from Confirmed/Completed bookings only, 
        // reserved, or with Unavailable/Maintenance status)
        String sql = "SELECT DISTINCT SeatID FROM ( " +
                     "  SELECT t.SeatID FROM Tickets t " +
                     "  INNER JOIN Bookings b ON t.BookingID = b.BookingID " +
                     "  WHERE t.ScreeningID = ? AND t.SeatID IN (" + placeholders + ") " +
                     "    AND b.Status IN ('Confirmed', 'Completed') " +
                     "  UNION " +
                     "  SELECT SeatID FROM SeatReservations " +
                     "  WHERE ScreeningID = ? AND SeatID IN (" + placeholders + ") " +
                     "    AND SessionID != ? AND ExpiresAt > GETDATE() " +
                     "  UNION " +
                     "  SELECT SeatID FROM Seats " +
                     "  WHERE SeatID IN (" + placeholders + ") " +
                     "    AND Status IN ('Unavailable', 'Maintenance') " +
                     ") AS UnavailableSeats";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            int paramIndex = 1;
            
            // Set screeningID for Tickets check
            ps.setInt(paramIndex++, screeningID);
            
            // Set seatIDs for Tickets check
            for (Integer seatID : seatIDs) {
                ps.setInt(paramIndex++, seatID);
            }
            
            // Set screeningID for SeatReservations check
            ps.setInt(paramIndex++, screeningID);
            
            // Set seatIDs for SeatReservations check
            for (Integer seatID : seatIDs) {
                ps.setInt(paramIndex++, seatID);
            }
            
            // Set excludeSessionID
            ps.setString(paramIndex++, excludeSessionID != null ? excludeSessionID : "");
            
            // Set seatIDs for Seats status check (Unavailable/Maintenance)
            for (Integer seatID : seatIDs) {
                ps.setInt(paramIndex++, seatID);
            }
            
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                unavailableSeats.add(rs.getInt("SeatID"));
            }
            
        } catch (SQLException e) {
            System.err.println("Error getting unavailable seats: " + e.getMessage());
            e.printStackTrace();
        }
        
        return unavailableSeats;
    }
}

