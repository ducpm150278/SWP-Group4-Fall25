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
    public List<Screening> getAllScrenning() {
        List<Screening> list = new ArrayList<>();
        String sql = """
                      SELECT s.ScreeningID, s.MovieID, s.RoomID, 
                                s.ScreeningDate, s.Showtime, 
                                s.BaseTicketPrice, 
                                m.Title AS MovieTitle, 
                                m.Status AS MovieStatus, 
                                c.CinemaName, 
                                r.RoomName
                         FROM Screenings s
                         JOIN Movies m ON s.MovieID = m.MovieID
                         JOIN ScreeningRooms r ON s.RoomID = r.RoomID
                         JOIN Cinemas c ON r.CinemaID = c.CinemaID
                         ORDER BY s.ScreeningDate DESC, s.Showtime""";

        try {
            PreparedStatement pre = getConnection().prepareStatement(sql);
            ResultSet rs = pre.executeQuery();
            while (rs.next()) {
                int screeningID = rs.getInt("ScreeningID");
                int movieID = rs.getInt("MovieID");
                int roomID = rs.getInt("RoomID");
                LocalDate screeningDate = rs.getDate("ScreeningDate").toLocalDate();
                String showtime = rs.getString("Showtime");
                double baseTicketPrice = rs.getDouble("BaseTicketPrice");
                int availableSeats = 0; // Nếu chưa có cột này trong DB, tạm set = 0
                String movieTitle = rs.getString("MovieTitle");
                String movieStatus = rs.getString("MovieStatus");
                String cinemaName = rs.getString("CinemaName");
                String roomName = rs.getString("RoomName");

                list.add(new Screening(screeningID, movieID, roomID, screeningDate, showtime,
                        baseTicketPrice, availableSeats, movieTitle, cinemaName,
                        roomName, movieStatus));

            }
        } catch (SQLException e) {
            System.out.println(e);
        }

        return list;
    }
    
    
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
     public List<Screening> searchScreenings(String keyword, LocalDate from, LocalDate to, String showtime, String status) {
        List<Screening> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("""
        SELECT s.ScreeningID, s.MovieID, s.RoomID,
               s.ScreeningDate, s.Showtime,
               s.BaseTicketPrice, s.AvailableSeats,
               m.Title AS MovieTitle,
               m.Status AS MovieStatus,
               c.CinemaName,
               r.RoomName
        FROM Screenings s
        JOIN Movies m ON s.MovieID = m.MovieID
        JOIN ScreeningRooms r ON s.RoomID = r.RoomID
        JOIN Cinemas c ON r.CinemaID = c.CinemaID
        WHERE 1=1
    """);

        List<Object> params = new ArrayList<>();

        // --- Điều kiện lọc ---
        if (keyword != null && !keyword.isEmpty()) {
            sql.append(" AND m.Title LIKE ? ");
            params.add("%" + keyword + "%");
        }
        if (from != null) {
            sql.append(" AND s.ScreeningDate >= ? ");
            params.add(Date.valueOf(from));
        }
        if (to != null) {
            sql.append(" AND s.ScreeningDate <= ? ");
            params.add(Date.valueOf(to));
        }
        if (showtime != null && !showtime.isEmpty()) {
            sql.append(" AND s.Showtime = ? ");
            params.add(showtime);
        }
        if (status != null && !status.isEmpty() && !"all".equalsIgnoreCase(status)) {
            sql.append(" AND m.Status = ? ");
            params.add(status);
        }

        sql.append(" ORDER BY s.ScreeningDate DESC, s.Showtime ASC");

        // --- Thực thi truy vấn ---
        try (PreparedStatement pre = getConnection().prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                pre.setObject(i + 1, params.get(i));
            }

            ResultSet rs = pre.executeQuery();
            while (rs.next()) {
                Screening s = new Screening(
                        rs.getInt("ScreeningID"),
                        rs.getInt("MovieID"),
                        rs.getInt("RoomID"),
                        rs.getDate("ScreeningDate").toLocalDate(),
                        rs.getString("Showtime"),
                        rs.getDouble("BaseTicketPrice"),
                        rs.getInt("AvailableSeats"),
                        rs.getString("MovieTitle"),
                        rs.getString("CinemaName"),
                        rs.getString("RoomName"),
                        rs.getString("MovieStatus")
                );
                list.add(s);
            }

        } catch (SQLException e) {
            System.out.println("Error searchScreenings: " + e.getMessage());
        }

        return list;
    }
     
         //Thêm lịch chiếu
   public void insertScreening(Screening sc) {
    String sql = """
        INSERT INTO Screenings (MovieID, RoomID, ScreeningDate, Showtime, BaseTicketPrice)
        VALUES (?, ?, ?, ?, ?)
    """;
    try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
        ps.setInt(1, sc.getMovieID());
        ps.setInt(2, sc.getRoomID());
        ps.setDate(3, Date.valueOf(sc.getScreeningDate())); // giờ đã có LocalDate
        ps.setString(4, sc.getShowtime());
        ps.setDouble(5, sc.getBaseTicketPrice());
        ps.executeUpdate();
    } catch (SQLException e) {
        System.out.println("insertScreening error: " + e.getMessage());
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
      public int countAllScreenings() {
        String sql = "SELECT COUNT(*) FROM Screenings";
        try (PreparedStatement pre = getConnection().prepareStatement(sql)) {
            ResultSet rs = pre.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.out.println("countAllScreenings error: " + e.getMessage());
        }
        return 0;
    }
        public List<Screening> getAllScreeningWithPaging(int page, int pageSize) {
        List<Screening> list = new ArrayList<>();
        String sql = """
        SELECT s.ScreeningID, s.MovieID, s.RoomID, 
               s.ScreeningDate, s.Showtime, 
               s.BaseTicketPrice, 
               m.Title AS MovieTitle, 
               m.Status AS MovieStatus, 
               c.CinemaName, 
               r.RoomName 
        FROM Screenings s
        JOIN Movies m ON s.MovieID = m.MovieID
        JOIN ScreeningRooms r ON s.RoomID = r.RoomID
        JOIN Cinemas c ON r.CinemaID = c.CinemaID
        ORDER BY s.ScreeningDate DESC, s.Showtime
        OFFSET ? ROWS FETCH NEXT ? ROWS ONLY
    """;

        try (PreparedStatement pre = getConnection().prepareStatement(sql)) {
            pre.setInt(1, (page - 1) * pageSize);
            pre.setInt(2, pageSize);

            ResultSet rs = pre.executeQuery();
            while (rs.next()) {
                int screeningID = rs.getInt("ScreeningID");
                int movieID = rs.getInt("MovieID");
                int roomID = rs.getInt("RoomID");
                LocalDate screeningDate = rs.getDate("ScreeningDate").toLocalDate();
                String showtime = rs.getString("Showtime");
                double baseTicketPrice = rs.getDouble("BaseTicketPrice");
                int availableSeats = 0; // Nếu DB chưa có cột này, đặt tạm = 0
                String movieTitle = rs.getString("MovieTitle");
                String movieStatus = rs.getString("MovieStatus");
                String cinemaName = rs.getString("CinemaName");
                String roomName = rs.getString("RoomName");

                list.add(new Screening(
                        screeningID, movieID, roomID,
                        screeningDate, showtime,
                        baseTicketPrice, availableSeats,
                        movieTitle, cinemaName, roomName, movieStatus
                ));
            }
        } catch (SQLException e) {
            System.out.println("getAllScreeningWithPaging error: " + e.getMessage());
        }

        return list;
    }
            public int countSearchScreenings(String keyword, LocalDate from, LocalDate to, String showtime, String status) {
        StringBuilder sql = new StringBuilder("""
        SELECT COUNT(*) 
        FROM Screenings s 
        JOIN Movies m ON s.MovieID = m.MovieID 
        JOIN ScreeningRooms r ON s.RoomID = r.RoomID 
        JOIN Cinemas c ON r.CinemaID = c.CinemaID 
        WHERE 1=1
    """);

        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.isEmpty()) {
            sql.append(" AND m.Title LIKE ? ");
            params.add("%" + keyword + "%");
        }
        if (from != null) {
            sql.append(" AND s.ScreeningDate >= ? ");
            params.add(Date.valueOf(from)); // sử dụng java.sql.Date.valueOf(LocalDate)
        }
        if (to != null) {
            sql.append(" AND s.ScreeningDate <= ? ");
            params.add(Date.valueOf(to));
        }
        if (showtime != null && !showtime.isEmpty()) {
            sql.append(" AND s.Showtime LIKE ? ");
            params.add("%" + showtime + "%");
        }
        if (status != null && !status.isEmpty()) {
            sql.append(" AND m.Status = ? ");
            params.add(status);
        }

        try (PreparedStatement pre = getConnection().prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                pre.setObject(i + 1, params.get(i));
            }

            ResultSet rs = pre.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.out.println("countSearchScreenings error: " + e.getMessage());
        }

        return 0;
    }
            public List<Screening> searchScreeningsWithPaging(
            String keyword, LocalDate from, LocalDate to,
            String showtime, String status, int page, int pageSize) {

        List<Screening> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder("""
        SELECT 
            s.ScreeningID, 
            s.MovieID, 
            s.RoomID, 
            s.ScreeningDate, 
            s.Showtime, 
            s.BaseTicketPrice, 
            m.Status AS MovieStatus,
            m.Title AS MovieTitle, 
            c.CinemaName, 
            r.RoomName, 
            r.SeatCapacity
        FROM Screenings s
        JOIN Movies m ON s.MovieID = m.MovieID
        JOIN ScreeningRooms r ON s.RoomID = r.RoomID
        JOIN Cinemas c ON r.CinemaID = c.CinemaID
        WHERE 1 = 1
    """);

        List<Object> params = new ArrayList<>();

        // 🔎 Tìm kiếm theo tên phim
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND m.Title LIKE ? ");
            params.add("%" + keyword.trim() + "%");
        }

        // 📅 Tìm kiếm theo khoảng ngày
        if (from != null) {
            sql.append(" AND s.ScreeningDate >= ? ");
            params.add(Date.valueOf(from));
        }
        if (to != null) {
            sql.append(" AND s.ScreeningDate <= ? ");
            params.add(Date.valueOf(to));
        }

        // ⏰ Tìm kiếm theo khung giờ
        if (showtime != null && !showtime.trim().isEmpty()) {
            sql.append(" AND s.Showtime = ? ");
            params.add(showtime.trim());
        }

        // ⚙️ Tìm kiếm theo trạng thái phim (đang chiếu, ngừng chiếu,...)
        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND m.Status = ? ");
            params.add(status.trim());
        }

        // 📑 Phân trang
        sql.append(" ORDER BY s.ScreeningDate DESC, s.Showtime ASC ");
        sql.append(" OFFSET ? ROWS FETCH NEXT ? ROWS ONLY ");

        try (PreparedStatement pre = getConnection().prepareStatement(sql.toString())) {

            int index = 1;
            for (Object param : params) {
                pre.setObject(index++, param);
            }
            pre.setInt(index++, (page - 1) * pageSize);
            pre.setInt(index, pageSize);

            ResultSet rs = pre.executeQuery();
            while (rs.next()) {
                Screening s = new Screening(
                        rs.getInt("ScreeningID"),
                        rs.getInt("MovieID"),
                        rs.getInt("RoomID"),
                        rs.getDate("ScreeningDate").toLocalDate(),
                        rs.getString("Showtime"),
                        rs.getDouble("BaseTicketPrice"),
                        rs.getString("MovieTitle"),
                        rs.getString("CinemaName"),
                        rs.getString("RoomName"),
                        rs.getInt("SeatCapacity"),
                        rs.getString("MovieStatus")
                );
                list.add(s);
            }

        } catch (SQLException e) {
            System.out.println("searchScreeningsWithPaging error: " + e.getMessage());
        }

        return list;
    }
            //cập nhật lịch chiếu
    public boolean updateScreening(int screeningID, int movieID, int roomID,
            LocalDate screeningDate, String showtime, double baseTicketPrice) {

        String sql = """
        UPDATE Screenings
        SET MovieID = ?, RoomID = ?, ScreeningDate = ?, Showtime = ?, BaseTicketPrice = ?
        WHERE ScreeningID = ?
    """;

        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, movieID);
            ps.setInt(2, roomID);
            ps.setDate(3, Date.valueOf(screeningDate));
            ps.setString(4, showtime);
            ps.setDouble(5, baseTicketPrice);
            ps.setInt(6, screeningID);
            ps.executeUpdate();
            return true;
        } catch (SQLException e) {
            System.out.println("Error updateScreening: " + e.getMessage());
            return false;
        }
    }
    //Hủy lịch chiếu
    public boolean cancelScreening(int screeningID) {
        String sql = "DELETE FROM Screenings WHERE ScreeningID = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, screeningID);
            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            System.out.println("Error cancelScreening: " + e.getMessage());
        }
        return false;
    }
     public Integer getSeatCapacityByRoomID(int roomID) {
        String sql = "SELECT SeatCapacity FROM ScreeningRooms WHERE RoomID = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {

            ps.setInt(1, roomID);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("SeatCapacity");
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
      public Screening getScreeningDetails(int screeningID) {
        Screening sc = null;
        String sql = """
         SELECT s.ScreeningID, s.MovieID, s.RoomID, 
                   s.ScreeningDate, s.Showtime,
                   s.BaseTicketPrice AS Price,
                   m.Title AS MovieTitle, m.Status AS MovieStatus,
                   c.CinemaName, r.RoomName, r.RoomType
            FROM Screenings s
            JOIN Movies m ON s.MovieID = m.MovieID
            JOIN ScreeningRooms r ON s.RoomID = r.RoomID
            JOIN Cinemas c ON r.CinemaID = c.CinemaID
            WHERE s.ScreeningID = ?
    """;

        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, screeningID);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                sc = new Screening(
                        rs.getInt("ScreeningID"),
                        rs.getInt("MovieID"),
                        rs.getInt("RoomID"),
                        rs.getDate("ScreeningDate").toLocalDate(),
                        rs.getString("Showtime"),
                        rs.getDouble("Price"),
                        rs.getString("MovieTitle"),
                        rs.getString("CinemaName"),
                        rs.getString("RoomName"),
                        rs.getString("MovieStatus"),
                        rs.getString("RoomType")
                );
            }
        } catch (SQLException e) {
            System.out.println("Error getScreeningDetail: " + e.getMessage());
        }
        return sc;
    }


}

