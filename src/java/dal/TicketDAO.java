package dal;

import entity.Ticket;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for Ticket operations
 */
public class TicketDAO extends DBContext {
    
    /**
     * Create a single ticket
     */
    public int createTicket(Ticket ticket) {
        String sql = "INSERT INTO Tickets (ScreeningID, UserID, SeatID, BookingTime, UnitPrice) " +
                     "VALUES (?, ?, ?, ?, ?)";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setInt(1, ticket.getScreeningID());
            ps.setInt(2, ticket.getUserID());
            ps.setInt(3, ticket.getSeatID());
            ps.setTimestamp(4, Timestamp.valueOf(ticket.getBookingTime()));
            ps.setDouble(5, ticket.getUnitPrice());
            
            int affectedRows = ps.executeUpdate();
            
            if (affectedRows > 0) {
                ResultSet rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
            
        } catch (SQLException e) {
            System.err.println("Error creating ticket: " + e.getMessage());
            e.printStackTrace();
        }
        
        return -1;
    }
    
    /**
     * Create multiple tickets in batch
     */
    public List<Integer> createTickets(List<Ticket> tickets) {
        List<Integer> ticketIDs = new ArrayList<>();
        String sql = "INSERT INTO Tickets (ScreeningID, UserID, SeatID, BookingTime, UnitPrice) " +
                     "VALUES (?, ?, ?, ?, ?)";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            for (Ticket ticket : tickets) {
                ps.setInt(1, ticket.getScreeningID());
                ps.setInt(2, ticket.getUserID());
                ps.setInt(3, ticket.getSeatID());
                ps.setTimestamp(4, Timestamp.valueOf(ticket.getBookingTime()));
                ps.setDouble(5, ticket.getUnitPrice());
                ps.addBatch();
            }
            
            ps.executeBatch();
            ResultSet rs = ps.getGeneratedKeys();
            
            while (rs.next()) {
                ticketIDs.add(rs.getInt(1));
            }
            
        } catch (SQLException e) {
            System.err.println("Error creating tickets: " + e.getMessage());
            e.printStackTrace();
        }
        
        return ticketIDs;
    }
    
    /**
     * Get tickets by user ID
     */
    public List<Ticket> getTicketsByUserID(int userID) {
        List<Ticket> tickets = new ArrayList<>();
        String sql = "SELECT t.TicketID, t.ScreeningID, t.UserID, t.SeatID, t.BookingTime, t.UnitPrice, " +
                     "s.StartTime, m.Title AS MovieTitle, c.CinemaName, " +
                     "CONCAT(st.SeatRow, st.SeatNumber) AS SeatLabel " +
                     "FROM Tickets t " +
                     "JOIN Screenings s ON t.ScreeningID = s.ScreeningID " +
                     "JOIN Movies m ON s.MovieID = m.MovieID " +
                     "JOIN ScreeningRooms r ON s.RoomID = r.RoomID " +
                     "JOIN Cinemas c ON r.CinemaID = c.CinemaID " +
                     "JOIN Seats st ON t.SeatID = st.SeatID " +
                     "WHERE t.UserID = ? " +
                     "ORDER BY t.BookingTime DESC";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, userID);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Ticket ticket = new Ticket(
                    rs.getInt("TicketID"),
                    rs.getInt("ScreeningID"),
                    rs.getInt("UserID"),
                    rs.getInt("SeatID"),
                    rs.getTimestamp("BookingTime").toLocalDateTime(),
                    rs.getDouble("UnitPrice")
                );
                ticket.setMovieTitle(rs.getString("MovieTitle"));
                ticket.setCinemaName(rs.getString("CinemaName"));
                ticket.setScreeningTime(rs.getTimestamp("StartTime").toLocalDateTime());
                ticket.setSeatLabel(rs.getString("SeatLabel"));
                
                tickets.add(ticket);
            }
            
        } catch (SQLException e) {
            System.err.println("Error getting tickets by user ID: " + e.getMessage());
            e.printStackTrace();
        }
        
        return tickets;
    }
    
    /**
     * Get tickets by screening ID
     */
    public List<Ticket> getTicketsByScreeningID(int screeningID) {
        List<Ticket> tickets = new ArrayList<>();
        String sql = "SELECT t.TicketID, t.ScreeningID, t.UserID, t.SeatID, t.BookingTime, t.UnitPrice, " +
                     "CONCAT(s.SeatRow, s.SeatNumber) AS SeatLabel, u.FullName " +
                     "FROM Tickets t " +
                     "JOIN Seats s ON t.SeatID = s.SeatID " +
                     "JOIN Users u ON t.UserID = u.UserID " +
                     "WHERE t.ScreeningID = ? " +
                     "ORDER BY s.SeatRow, s.SeatNumber";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, screeningID);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Ticket ticket = new Ticket(
                    rs.getInt("TicketID"),
                    rs.getInt("ScreeningID"),
                    rs.getInt("UserID"),
                    rs.getInt("SeatID"),
                    rs.getTimestamp("BookingTime").toLocalDateTime(),
                    rs.getDouble("UnitPrice")
                );
                ticket.setSeatLabel(rs.getString("SeatLabel"));
                
                tickets.add(ticket);
            }
            
        } catch (SQLException e) {
            System.err.println("Error getting tickets by screening ID: " + e.getMessage());
            e.printStackTrace();
        }
        
        return tickets;
    }
    
    /**
     * Get ticket by ID with full details
     */
    public Ticket getTicketByID(int ticketID) {
        String sql = "SELECT t.TicketID, t.ScreeningID, t.UserID, t.SeatID, t.BookingTime, t.UnitPrice, " +
                     "s.StartTime, m.Title AS MovieTitle, c.CinemaName, " +
                     "CONCAT(st.SeatRow, st.SeatNumber) AS SeatLabel " +
                     "FROM Tickets t " +
                     "JOIN Screenings s ON t.ScreeningID = s.ScreeningID " +
                     "JOIN Movies m ON s.MovieID = m.MovieID " +
                     "JOIN ScreeningRooms r ON s.RoomID = r.RoomID " +
                     "JOIN Cinemas c ON r.CinemaID = c.CinemaID " +
                     "JOIN Seats st ON t.SeatID = st.SeatID " +
                     "WHERE t.TicketID = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, ticketID);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                Ticket ticket = new Ticket(
                    rs.getInt("TicketID"),
                    rs.getInt("ScreeningID"),
                    rs.getInt("UserID"),
                    rs.getInt("SeatID"),
                    rs.getTimestamp("BookingTime").toLocalDateTime(),
                    rs.getDouble("UnitPrice")
                );
                ticket.setMovieTitle(rs.getString("MovieTitle"));
                ticket.setCinemaName(rs.getString("CinemaName"));
                ticket.setScreeningTime(rs.getTimestamp("StartTime").toLocalDateTime());
                ticket.setSeatLabel(rs.getString("SeatLabel"));
                
                return ticket;
            }
            
        } catch (SQLException e) {
            System.err.println("Error getting ticket by ID: " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * Delete ticket (for cancellation)
     */
    public boolean deleteTicket(int ticketID) {
        String sql = "DELETE FROM Tickets WHERE TicketID = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, ticketID);
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.err.println("Error deleting ticket: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Update available seats count for screening
     */
    public boolean updateScreeningAvailableSeats(int screeningID) {
        String sql = "UPDATE Screenings SET AvailableSeats = AvailableSeats - 1 WHERE ScreeningID = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, screeningID);
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.err.println("Error updating available seats: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}

