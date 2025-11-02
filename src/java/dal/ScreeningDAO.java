package dal;

import entity.Screening;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Date;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for Screenings
 * Works with the new schema: ScreeningDate + Showtime, BaseTicketPrice
 */
public class ScreeningDAO extends DBContext {
    
    /**
     * Parse showtime string (e.g., "08:00-10:00") into start and end times
     */
    private LocalDateTime[] parseShowtime(LocalDate screeningDate, String showtime) {
        if (showtime == null || !showtime.contains("-")) {
            return new LocalDateTime[]{null, null};
        }
        
        try {
            String[] parts = showtime.split("-");
            if (parts.length != 2) {
                return new LocalDateTime[]{null, null};
            }
            
            LocalTime startTime = LocalTime.parse(parts[0].trim());
            LocalTime endTime = LocalTime.parse(parts[1].trim());
            
            return new LocalDateTime[]{
                LocalDateTime.of(screeningDate, startTime),
                LocalDateTime.of(screeningDate, endTime)
            };
        } catch (Exception e) {
            System.err.println("Error parsing showtime: " + showtime);
            return new LocalDateTime[]{null, null};
        }
    }
    
    /**
     * Get screening detail by ID with full information
     */
    public Screening getScreeningDetail(int screeningID) {
        Screening screening = null;
        
        String sql = "SELECT s.ScreeningID, s.MovieID, s.RoomID, "
                   + "s.ScreeningDate, s.Showtime, s.BaseTicketPrice, "
                   + "m.Title AS MovieTitle, m.Status AS MovieStatus, "
                   + "c.CinemaName, sr.RoomName, sr.RoomType, "
                   + "sr.SeatCapacity - ISNULL((SELECT COUNT(DISTINCT t.SeatID) "
                   + "FROM Tickets t WHERE t.ScreeningID = s.ScreeningID), 0) "
                   + "- ISNULL((SELECT COUNT(DISTINCT sr2.SeatID) "
                   + "FROM SeatReservations sr2 "
                   + "WHERE sr2.ScreeningID = s.ScreeningID AND sr2.ExpiresAt > GETDATE()), 0) AS AvailableSeats "
                   + "FROM Screenings s "
                   + "INNER JOIN Movies m ON s.MovieID = m.MovieID "
                   + "INNER JOIN ScreeningRooms sr ON s.RoomID = sr.RoomID "
                   + "INNER JOIN Cinemas c ON sr.CinemaID = c.CinemaID "
                   + "WHERE s.ScreeningID = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, screeningID);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                Date screeningDate = rs.getDate("ScreeningDate");
                String showtime = rs.getString("Showtime");
                LocalDateTime[] times = parseShowtime(
                    screeningDate.toLocalDate(), 
                    showtime
                );
                
                screening = new Screening(
                    rs.getInt("ScreeningID"),
                    rs.getInt("MovieID"),
                    rs.getInt("RoomID"),
                    times[0], // startTime
                    times[1], // endTime
                    rs.getDouble("BaseTicketPrice"), // ticketPrice
                    rs.getInt("AvailableSeats"),
                    rs.getString("MovieTitle"),
                    rs.getString("CinemaName"),
                    rs.getString("RoomName"),
                    rs.getString("MovieStatus"),
                    rs.getString("RoomType")
                );
            }
            
        } catch (SQLException e) {
            System.err.println("Error getting screening detail: " + e.getMessage());
            e.printStackTrace();
        }
        
        return screening;
    }
    
    /**
     * Get available screenings for a cinema, movie, and date
     */
    public List<Screening> getAvailableScreenings(int cinemaID, int movieID, LocalDate date) {
        List<Screening> screenings = new ArrayList<>();
        
        String sql = "SELECT s.ScreeningID, s.MovieID, s.RoomID, "
                   + "s.ScreeningDate, s.Showtime, s.BaseTicketPrice, "
                   + "m.Title AS MovieTitle, m.Status AS MovieStatus, "
                   + "c.CinemaName, sr.RoomName, sr.RoomType, "
                   + "sr.SeatCapacity - ISNULL((SELECT COUNT(DISTINCT t.SeatID) "
                   + "FROM Tickets t WHERE t.ScreeningID = s.ScreeningID), 0) "
                   + "- ISNULL((SELECT COUNT(DISTINCT sr2.SeatID) "
                   + "FROM SeatReservations sr2 "
                   + "WHERE sr2.ScreeningID = s.ScreeningID AND sr2.ExpiresAt > GETDATE()), 0) AS AvailableSeats "
                   + "FROM Screenings s "
                   + "INNER JOIN Movies m ON s.MovieID = m.MovieID "
                   + "INNER JOIN ScreeningRooms sr ON s.RoomID = sr.RoomID "
                   + "INNER JOIN Cinemas c ON sr.CinemaID = c.CinemaID "
                   + "WHERE c.CinemaID = ? "
                   + "AND s.MovieID = ? "
                   + "AND s.ScreeningDate = ? "
                   + "AND m.Status = 'Active' "
                   + "ORDER BY s.Showtime ASC";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, cinemaID);
            ps.setInt(2, movieID);
            ps.setDate(3, Date.valueOf(date));
            
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Date screeningDate = rs.getDate("ScreeningDate");
                String showtime = rs.getString("Showtime");
                LocalDateTime[] times = parseShowtime(
                    screeningDate.toLocalDate(), 
                    showtime
                );
                
                Screening screening = new Screening(
                    rs.getInt("ScreeningID"),
                    rs.getInt("MovieID"),
                    rs.getInt("RoomID"),
                    times[0], // startTime
                    times[1], // endTime
                    rs.getDouble("BaseTicketPrice"), // ticketPrice
                    rs.getInt("AvailableSeats"),
                    rs.getString("MovieTitle"),
                    rs.getString("CinemaName"),
                    rs.getString("RoomName"),
                    rs.getString("MovieStatus"),
                    rs.getString("RoomType")
                );
                
                screenings.add(screening);
            }
            
        } catch (SQLException e) {
            System.err.println("Error getting available screenings: " + e.getMessage());
            e.printStackTrace();
        }
        
        return screenings;
    }
}

