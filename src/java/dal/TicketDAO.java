package dal;

import entity.Ticket;
import java.sql.*;
import java.time.LocalDateTime;
import java.time.LocalDate;
import java.time.LocalTime;
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
        String sql = "INSERT INTO Tickets (ScreeningID, UserID, SeatID, BookingTime, SeatPrice) " +
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
     * Create multiple tickets in batch with BookingID
     * NOTE: SQL Server has issues with executeBatch() + RETURN_GENERATED_KEYS
     * So we insert one by one to get the generated IDs
     */
    public List<Integer> createTickets(List<Ticket> tickets, int bookingID) {
        List<Integer> ticketIDs = new ArrayList<>();
        
        System.out.println("TicketDAO: Creating " + tickets.size() + " tickets...");
        
        // Use single connection for all inserts (transaction context)
        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false); // Start transaction
            
            String sql = "INSERT INTO Tickets (BookingID, ScreeningID, UserID, SeatID, BookingTime, SeatPrice) " +
                         "VALUES (?, ?, ?, ?, ?, ?)";
            
            try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                
                int ticketIndex = 0;
                for (Ticket ticket : tickets) {
                    ticketIndex++;
                    System.out.println("=== Processing ticket " + ticketIndex + "/" + tickets.size() + " ===");
                    
                    // Check for null values
                    if (ticket == null) {
                        System.err.println("ERROR: Ticket object is null!");
                        continue;
                    }
                    if (ticket.getBookingTime() == null) {
                        System.err.println("ERROR: BookingTime is null!");
                        continue;
                    }
                    
                    System.out.println("Inserting ticket: ScreeningID=" + ticket.getScreeningID() + 
                                     ", UserID=" + ticket.getUserID() + 
                                     ", SeatID=" + ticket.getSeatID() +
                                     ", UnitPrice=" + ticket.getUnitPrice() +
                                     ", BookingTime=" + ticket.getBookingTime());
                    
                    try {
                        ps.setInt(1, bookingID);
                        ps.setInt(2, ticket.getScreeningID());
                        ps.setInt(3, ticket.getUserID());
                        ps.setInt(4, ticket.getSeatID());
                        ps.setTimestamp(5, Timestamp.valueOf(ticket.getBookingTime()));
                        ps.setDouble(6, ticket.getUnitPrice());
                        
                        System.out.println("Executing insert statement...");
                        int affectedRows = ps.executeUpdate();
                        System.out.println("Affected rows: " + affectedRows);
                        
                        if (affectedRows > 0) {
                            System.out.println("Getting generated keys...");
                            ResultSet rs = ps.getGeneratedKeys();
                            System.out.println("ResultSet retrieved: " + (rs != null));
                            
                            if (rs.next()) {
                                int ticketID = rs.getInt(1);
                                ticketIDs.add(ticketID);
                                System.out.println("✓ Created ticket with ID: " + ticketID);
                            } else {
                                System.err.println("ERROR: ResultSet.next() returned false - No generated key found!");
                            }
                            rs.close();
                        } else {
                            System.err.println("ERROR: No rows affected for ticket insert!");
                        }
                        
                    } catch (SQLException sqlEx) {
                        System.err.println("ERROR inserting individual ticket " + ticketIndex + ":");
                        System.err.println("SQL State: " + sqlEx.getSQLState());
                        System.err.println("Error Code: " + sqlEx.getErrorCode());
                        System.err.println("Message: " + sqlEx.getMessage());
                        sqlEx.printStackTrace();
                        // Don't throw, continue with next ticket
                    }
                }
                
                conn.commit(); // Commit transaction
                System.out.println("Successfully created " + ticketIDs.size() + " tickets");
                
            } catch (SQLException e) {
                conn.rollback(); // Rollback on error
                System.err.println("=== SQL ERROR in createTickets ===");
                System.err.println("Error Code: " + e.getErrorCode());
                System.err.println("SQL State: " + e.getSQLState());
                System.err.println("Message: " + e.getMessage());
                e.printStackTrace();
                
                // Try to get more details about constraint violations
                Throwable cause = e.getCause();
                if (cause != null) {
                    System.err.println("Caused by: " + cause.getMessage());
                }
                throw e; // Re-throw to outer catch
            }
            
        } catch (SQLException e) {
            System.err.println("=== OUTER CATCH: Connection/Transaction error ===");
            System.err.println("Error Code: " + e.getErrorCode());
            System.err.println("SQL State: " + e.getSQLState());
            System.err.println("Message: " + e.getMessage());
            e.printStackTrace();
        } catch (Exception e) {
            System.err.println("=== UNEXPECTED ERROR ===");
            System.err.println("Type: " + e.getClass().getName());
            System.err.println("Message: " + e.getMessage());
            e.printStackTrace();
        }
        
        System.out.println("Returning " + ticketIDs.size() + " ticket IDs");
        return ticketIDs;
    }
    
    /**
     * Get tickets by user ID
     */
    public List<Ticket> getTicketsByUserID(int userID) {
        List<Ticket> tickets = new ArrayList<>();
        String sql = "SELECT t.TicketID, t.ScreeningID, t.UserID, t.SeatID, t.BookingTime, t.SeatPrice AS UnitPrice, " +
                     "s.ScreeningDate, s.Showtime, m.Title AS MovieTitle, c.CinemaName, " +
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
                
                // Convert ScreeningDate + Showtime to LocalDateTime
                java.sql.Date screeningDate = rs.getDate("ScreeningDate");
                String showtime = rs.getString("Showtime");
                if (screeningDate != null && showtime != null) {
                    LocalDateTime[] times = parseShowtime(screeningDate.toLocalDate(), showtime);
                    ticket.setScreeningTime(times[0]);
                }
                
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
        String sql = "SELECT t.TicketID, t.ScreeningID, t.UserID, t.SeatID, t.BookingTime, t.SeatPrice AS UnitPrice, " +
                     "s.ScreeningDate, s.Showtime, m.Title AS MovieTitle, c.CinemaName, " +
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
                
                // Convert ScreeningDate + Showtime to LocalDateTime
                java.sql.Date screeningDate = rs.getDate("ScreeningDate");
                String showtime = rs.getString("Showtime");
                if (screeningDate != null && showtime != null) {
                    LocalDateTime[] times = parseShowtime(screeningDate.toLocalDate(), showtime);
                    ticket.setScreeningTime(times[0]);
                }
                
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
    
    // Note: updateScreeningAvailableSeats removed - AvailableSeats is now calculated
    // dynamically via view vw_CurrentScreenings in the database
    
    /**
     * Parse Showtime string (e.g., "08:00-10:00") and combine with ScreeningDate
     * to create LocalDateTime objects for StartTime and EndTime
     */
    private LocalDateTime[] parseShowtime(LocalDate screeningDate, String showtime) {
        if (showtime == null || !showtime.contains("-")) {
            LocalDateTime now = LocalDateTime.now();
            return new LocalDateTime[]{now, now.plusHours(2)};
        }
        
        try {
            String[] parts = showtime.split("-");
            if (parts.length != 2) {
                LocalDateTime now = LocalDateTime.now();
                return new LocalDateTime[]{now, now.plusHours(2)};
            }
            
            LocalTime startTime = LocalTime.parse(parts[0].trim());
            LocalTime endTime = LocalTime.parse(parts[1].trim());
            
            return new LocalDateTime[]{
                LocalDateTime.of(screeningDate, startTime),
                LocalDateTime.of(screeningDate, endTime)
            };
        } catch (Exception e) {
            System.err.println("Error parsing showtime: " + showtime + " - " + e.getMessage());
            LocalDateTime now = LocalDateTime.now();
            return new LocalDateTime[]{now, now.plusHours(2)};
        }
    }
}

