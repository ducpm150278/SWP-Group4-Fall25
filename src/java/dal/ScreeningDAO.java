/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dal;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import entity.Screening;

/**
 *
 * @author admin
 */
public class ScreeningDAO extends DBContext {

    public List<Screening> getAllScrenning() {
        List<Screening> list = new ArrayList<>();
        String sql = """
                     SELECT s.ScreeningID, s.MovieID, s.RoomID, s.StartTime, s.EndTime, 
                                s.BaseTicketPrice, s.AvailableSeats, 
                                m.Title AS MovieTitle, 
                                m.Status AS MovieStatus, 
                                c.CinemaName, 
                                r.RoomName 
                                FROM Screenings s 
                                JOIN Movies m ON s.MovieID = m.MovieID 
                                JOIN ScreeningRooms r ON s.RoomID = r.RoomID 
                                JOIN Cinemas c ON r.CinemaID = c.CinemaID 
                                ORDER BY s.StartTime DESC""";

        try {
            PreparedStatement pre = getConnection().prepareStatement(sql);
            ResultSet rs = pre.executeQuery();
            while (rs.next()) {
                int screeningID = rs.getInt("ScreeningID");
                int movieID = rs.getInt("MovieID");
                int roomID = rs.getInt("RoomID");
                LocalDateTime startTime = rs.getTimestamp("StartTime").toLocalDateTime();
                LocalDateTime endTime = rs.getTimestamp("EndTime").toLocalDateTime();
                double ticketPrice = rs.getDouble("BaseTicketPrice");
                int availableSeats = rs.getInt("AvailableSeats");
                String movieTitle = rs.getString("MovieTitle");
                String movieStatus = rs.getString("MovieStatus");
                String cinemaName = rs.getString("CinemaName");
                String roomName = rs.getString("RoomName");
                list.add(new Screening(screeningID, movieID, roomID, startTime, endTime, ticketPrice, availableSeats, movieTitle, cinemaName, roomName, movieStatus));

            }
        } catch (SQLException e) {
            System.out.println(e);
        }

        return list;
    }

    //Tìm kiếm theo ngày hoặc trạng thái , theo tên
    public List<Screening> searchScreenings(String keyword, LocalDateTime from, LocalDateTime to, String status) {
        List<Screening> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("""
        SELECT s.ScreeningID, s.MovieID, s.RoomID, s.StartTime, s.EndTime, 
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

        if (keyword != null && !keyword.isEmpty()) {
            sql.append(" AND m.Title LIKE ? ");
        }
        if (from != null) {
            sql.append(" AND s.StartTime >= ? ");
        }
        if (to != null) {
            sql.append(" AND s.StartTime <= ? ");
        }
        if (status != null && !status.isEmpty() && !"all".equalsIgnoreCase(status)) {
            sql.append(" AND m.Status = ? ");
        }
        sql.append(" ORDER BY s.StartTime DESC");

        try (PreparedStatement pre = getConnection().prepareStatement(sql.toString())) {
            int index = 1;
            if (keyword != null && !keyword.isEmpty()) {
                pre.setString(index++, "%" + keyword + "%");
            }
            if (from != null) {
                pre.setObject(index++, from);
            }
            if (to != null) {
                pre.setObject(index++, to);
            }
            if (status != null && !status.isEmpty() && !"all".equalsIgnoreCase(status)) {
                pre.setString(index++, status);
            }

            ResultSet rs = pre.executeQuery();
            while (rs.next()) {
                Screening sc = new Screening(
                        rs.getInt("ScreeningID"),
                        rs.getInt("MovieID"),
                        rs.getInt("RoomID"),
                        rs.getTimestamp("StartTime").toLocalDateTime(),
                        rs.getTimestamp("EndTime").toLocalDateTime(),
                        rs.getDouble("BaseTicketPrice"),
                        rs.getInt("AvailableSeats"),
                        rs.getString("MovieTitle"),
                        rs.getString("CinemaName"),
                        rs.getString("RoomName"),
                        rs.getString("MovieStatus")
                );
                list.add(sc);
            }
        } catch (SQLException e) {
            System.out.println("Error searchScreenings: " + e.getMessage());
        }

        return list;
    }

    //Thêm lịch chiếu
    public void insertScreening(Screening sc) {
        String sql = """
        INSERT INTO Screenings (MovieID, RoomID, StartTime, EndTime, BaseTicketPrice, AvailableSeats)
        VALUES (?, ?, ?, ?, ?, ?)
    """;
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, sc.getMovieID());
            ps.setInt(2, sc.getRoomID());
            ps.setObject(3, sc.getStartTime());
            ps.setObject(4, sc.getEndTime());
            ps.setDouble(5, sc.getTicketPrice());
            ps.setInt(6, sc.getAvailableSeats());
            ps.executeUpdate();
        } catch (SQLException e) {
            System.out.println("insertScreening error: " + e.getMessage());
        }
    }
//xem chi tiết lịch phim

   public Screening getScreeningDetail(int screeningID) {
    Screening sc = null;
    String sql = """
        SELECT s.ScreeningID, s.MovieID, s.RoomID, s.StartTime, s.EndTime,
               s.BaseTicketPrice, s.AvailableSeats,
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
                    rs.getTimestamp("StartTime").toLocalDateTime(),
                    rs.getTimestamp("EndTime").toLocalDateTime(),
                    rs.getDouble("BaseTicketPrice"),
                    rs.getInt("AvailableSeats"),
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
    
    /**
     * Get available screenings filtered by cinema, movie, and date
     */
    public List<Screening> getAvailableScreenings(int cinemaID, int movieID, java.time.LocalDate date) {
        List<Screening> list = new ArrayList<>();
        String sql = """
            SELECT s.ScreeningID, s.MovieID, s.RoomID, s.StartTime, s.EndTime,
                   s.BaseTicketPrice, s.AvailableSeats,
                   m.Title AS MovieTitle, m.Status AS MovieStatus,
                   c.CinemaName, r.RoomName
            FROM Screenings s
            JOIN Movies m ON s.MovieID = m.MovieID
            JOIN ScreeningRooms r ON s.RoomID = r.RoomID
            JOIN Cinemas c ON r.CinemaID = c.CinemaID
            WHERE r.CinemaID = ?
              AND s.MovieID = ?
              AND CAST(s.StartTime AS DATE) = ?
              AND s.AvailableSeats > 0
              AND s.StartTime > GETDATE()
            ORDER BY s.StartTime ASC
        """;

        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, cinemaID);
            ps.setInt(2, movieID);
            ps.setObject(3, date);
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Screening sc = new Screening(
                        rs.getInt("ScreeningID"),
                        rs.getInt("MovieID"),
                        rs.getInt("RoomID"),
                        rs.getTimestamp("StartTime").toLocalDateTime(),
                        rs.getTimestamp("EndTime").toLocalDateTime(),
                        rs.getDouble("BaseTicketPrice"),
                        rs.getInt("AvailableSeats"),
                        rs.getString("MovieTitle"),
                        rs.getString("CinemaName"),
                        rs.getString("RoomName"),
                        rs.getString("MovieStatus")
                );
                list.add(sc);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }


    // Lấy các suất chiếu khác của cùng phim trong khoảng thời gian
    public List<Screening> getOtherSchedulesOfMovie(int movieID, LocalDateTime from, LocalDateTime to, int excludeID) {
        List<Screening> list = new ArrayList<>();
        String sql = """
            SELECT s.ScreeningID, s.StartTime, s.EndTime,
                   c.CinemaName, r.RoomName
            FROM Screenings s
            JOIN ScreeningRooms r ON s.RoomID = r.RoomID
            JOIN Cinemas c ON r.CinemaID = c.CinemaID
            WHERE s.MovieID = ? 
              AND s.StartTime >= ? 
              AND s.EndTime <= ? 
              AND s.ScreeningID <> ?
            ORDER BY s.StartTime
        """;

        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, movieID);
            ps.setTimestamp(2, Timestamp.valueOf(from));
            ps.setTimestamp(3, Timestamp.valueOf(to));
            ps.setInt(4, excludeID);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Screening s = new Screening();
                s.setScreeningID(rs.getInt("ScreeningID"));
                s.setStartTime(rs.getObject("StartTime", LocalDateTime.class));
                s.setEndTime(rs.getObject("EndTime", LocalDateTime.class));
                s.setCinemaName(rs.getString("CinemaName"));
                s.setRoomName(rs.getString("RoomName"));
                list.add(s);
            }
        } catch (SQLException e) {
            System.out.println("Error getOtherSchedulesOfMovie: " + e.getMessage());
        }
        return list;
    }

    //  Lấy số ghế đã bán (nếu có bảng Tickets)
    private int getSoldSeats(int screeningID) {
        String sql = "SELECT COUNT(*) FROM Tickets WHERE ScreeningID = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, screeningID);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.out.println("Error getSoldSeats: " + e.getMessage());
        }
        return 0;
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
        SELECT s.ScreeningID, s.MovieID, s.RoomID, s.StartTime, s.EndTime, 
               s.BaseTicketPrice, s.AvailableSeats, 
               m.Title AS MovieTitle, 
               m.Status AS MovieStatus, 
               c.CinemaName, 
               r.RoomName 
        FROM Screenings s 
        JOIN Movies m ON s.MovieID = m.MovieID 
        JOIN ScreeningRooms r ON s.RoomID = r.RoomID 
        JOIN Cinemas c ON r.CinemaID = c.CinemaID 
        ORDER BY s.StartTime DESC
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
                LocalDateTime startTime = rs.getTimestamp("StartTime").toLocalDateTime();
                LocalDateTime endTime = rs.getTimestamp("EndTime").toLocalDateTime();
                double ticketPrice = rs.getDouble("BaseTicketPrice");
                int availableSeats = rs.getInt("AvailableSeats");
                String movieTitle = rs.getString("MovieTitle");
                String movieStatus = rs.getString("MovieStatus");
                String cinemaName = rs.getString("CinemaName");
                String roomName = rs.getString("RoomName");

                list.add(new Screening(screeningID, movieID, roomID, startTime, endTime,
                        ticketPrice, availableSeats, movieTitle, cinemaName, roomName, movieStatus));
            }
        } catch (SQLException e) {
            System.out.println("getAllScreeningWithPaging error: " + e.getMessage());
        }
        return list;
    }

    public int countSearchScreenings(String keyword, LocalDateTime from, LocalDateTime to, String status) {
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
            sql.append(" AND s.StartTime >= ? ");
            params.add(Timestamp.valueOf(from));
        }
        if (to != null) {
            sql.append(" AND s.StartTime <= ? ");
            params.add(Timestamp.valueOf(to));
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

    public List<Screening> searchScreeningsWithPaging(String keyword, LocalDateTime from, LocalDateTime to, String status, int page, int pageSize) {
        List<Screening> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("""
        SELECT s.ScreeningID, s.MovieID, s.RoomID, s.StartTime, s.EndTime, 
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

        if (keyword != null && !keyword.isEmpty()) {
            sql.append(" AND m.Title LIKE ? ");
            params.add("%" + keyword + "%");
        }
        if (from != null) {
            sql.append(" AND s.StartTime >= ? ");
            params.add(Timestamp.valueOf(from));
        }
        if (to != null) {
            sql.append(" AND s.StartTime <= ? ");
            params.add(Timestamp.valueOf(to));
        }
        if (status != null && !status.isEmpty()) {
            sql.append(" AND m.Status = ? ");
            params.add(status);
        }

        sql.append(" ORDER BY s.StartTime DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        try (PreparedStatement pre = getConnection().prepareStatement(sql.toString())) {
            int index = 1;
            for (Object param : params) {
                pre.setObject(index++, param);
            }
            pre.setInt(index++, (page - 1) * pageSize);
            pre.setInt(index, pageSize);

            ResultSet rs = pre.executeQuery();
            while (rs.next()) {
                int screeningID = rs.getInt("ScreeningID");
                int movieID = rs.getInt("MovieID");
                int roomID = rs.getInt("RoomID");
                LocalDateTime startTime = rs.getTimestamp("StartTime").toLocalDateTime();
                LocalDateTime endTime = rs.getTimestamp("EndTime").toLocalDateTime();
                double ticketPrice = rs.getDouble("BaseTicketPrice");
                int availableSeats = rs.getInt("AvailableSeats");
                String movieTitle = rs.getString("MovieTitle");
                String movieStatus = rs.getString("MovieStatus");
                String cinemaName = rs.getString("CinemaName");
                String roomName = rs.getString("RoomName");

                list.add(new Screening(screeningID, movieID, roomID, startTime, endTime,
                        ticketPrice, availableSeats, movieTitle, cinemaName, roomName, movieStatus));
            }
        } catch (SQLException e) {
            System.out.println("searchScreeningsWithPaging error: " + e.getMessage());
        }

        return list;
    }
    //cập nhật lịch chiếu

    public boolean updateScreening(int screeningID, int movieID, int roomID,
            LocalDateTime startTime, LocalDateTime endTime, String status) {
        String sql = """
        UPDATE Screenings
        SET MovieID = ?, RoomID = ?, StartTime = ?, EndTime = ?
        WHERE ScreeningID = ?;
        UPDATE Movies SET Status = ? WHERE MovieID = ?;
    """;
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, movieID);
            ps.setInt(2, roomID);
            ps.setObject(3, startTime);
            ps.setObject(4, endTime);
            ps.setInt(5, screeningID);
            ps.setString(6, status);
            ps.setInt(7, movieID);
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

    public static void main(String[] args) {
//        ScreeningDAO dao = new ScreeningDAO();
//        List<Screening> list = dao.getAllScrenning();
//
//        for (Screening s : list) {
//            System.out.println(s);
//        }
    }
}
