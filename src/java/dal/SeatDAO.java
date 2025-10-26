package dal;

import entity.Seat;
import java.sql.*;
import java.time.LocalDateTime;
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
        String sql = "SELECT SeatID, RoomID, SeatRow, SeatNumber, SeatType, Status " +
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
     */
    public List<Integer> getBookedSeatsForScreening(int screeningID) {
        List<Integer> bookedSeatIDs = new ArrayList<>();
        String sql = "SELECT DISTINCT SeatID FROM Tickets WHERE ScreeningID = ?";
        
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
     */
    public boolean reserveSeats(List<Integer> seatIDs, int screeningID, String sessionID) {
        // First, release any existing reservations for this session
        releaseReservationsBySession(sessionID);
        
        String sql = "INSERT INTO SeatReservations (SeatID, ScreeningID, SessionID, ReservedAt, ExpiresAt) " +
                     "VALUES (?, ?, ?, GETDATE(), DATEADD(MINUTE, 15, GETDATE()))";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            for (Integer seatID : seatIDs) {
                ps.setInt(1, seatID);
                ps.setInt(2, screeningID);
                ps.setString(3, sessionID);
                ps.addBatch();
            }
            
            int[] results = ps.executeBatch();
            return results.length == seatIDs.size();
            
        } catch (SQLException e) {
            System.err.println("Error reserving seats: " + e.getMessage());
            e.printStackTrace();
            return false;
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
     */
    public boolean updateSeatStatus(int seatID, String status) {
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
        String sql = "SELECT SeatID, RoomID, SeatRow, SeatNumber, SeatType, Status " +
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
     */
    public boolean areSeatsAvailable(List<Integer> seatIDs, int screeningID, String excludeSessionID) {
        if (seatIDs == null || seatIDs.isEmpty()) {
            return false;
        }
        
        // Check if any seat is already booked
        List<Integer> bookedSeats = getBookedSeatsForScreening(screeningID);
        for (Integer seatID : seatIDs) {
            if (bookedSeats.contains(seatID)) {
                return false;
            }
        }
        
        // Check if any seat is reserved by another session
        String sql = "SELECT COUNT(*) FROM SeatReservations " +
                     "WHERE ScreeningID = ? AND SeatID = ? AND SessionID != ? AND ExpiresAt > GETDATE()";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, screeningID);
            ps.setString(3, excludeSessionID != null ? excludeSessionID : "");
            
            for (Integer seatID : seatIDs) {
                ps.setInt(2, seatID);
                ResultSet rs = ps.executeQuery();
                
                if (rs.next() && rs.getInt(1) > 0) {
                    return false; // Seat is reserved by another session
                }
            }
            
            return true;
            
        } catch (SQLException e) {
            System.err.println("Error checking seat availability: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}

