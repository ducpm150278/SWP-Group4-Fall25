package dal;

import entity.ScreeningRoom;
import entity.CinemaM;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.HashMap;
import java.util.Map;

public class ScreeningRoomDAO {

    private final DBContext db = new DBContext();

    // CORE METHODS - Lấy danh sách với filtering và pagination
    public List<ScreeningRoom> getRoomsWithFilters(String location, Integer cinemaId, String roomType,
            String status, String search, int offset, int limit) {
        List<ScreeningRoom> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("""
        SELECT sr.RoomID, sr.CinemaID, sr.RoomName, sr.SeatCapacity, sr.RoomType, 
               sr.IsActive,
               c.CinemaName, c.Location, c.Address
        FROM ScreeningRooms sr
        JOIN Cinemas c ON sr.CinemaID = c.CinemaID
        WHERE 1=1
    """);

        List<Object> params = new ArrayList<>();

//        // DEBUG
//        System.out.println("=== DAO DEBUG ===");
//        System.out.println("Location: " + location);
//        System.out.println("CinemaId: " + cinemaId);
//        System.out.println("RoomType: " + roomType);
//        System.out.println("Status: " + status);
//        System.out.println("Search: " + search);

        // Build dynamic WHERE clause
        if (location != null && !location.isEmpty()) {
            sql.append(" AND c.Location = ?");
            params.add(location);
//            System.out.println("Added location filter: " + location);
        }

        if (cinemaId != null && cinemaId > 0) {
            sql.append(" AND sr.CinemaID = ?");
            params.add(cinemaId);
//            System.out.println("Added cinemaId filter: " + cinemaId);
        }

        if (roomType != null && !roomType.equals("all")) {
            sql.append(" AND sr.RoomType = ?");
            params.add(roomType);
//            System.out.println("Added roomType filter: " + roomType);
        }

        if (status != null && !status.equals("all")) {
            if (status.equals("active")) {
                sql.append(" AND sr.IsActive = 1");
//                System.out.println("Added active status filter");
            } else if (status.equals("inactive")) {
                sql.append(" AND sr.IsActive = 0");
//                System.out.println("Added inactive status filter");
            }
        }

        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (sr.RoomName LIKE ? OR c.CinemaName LIKE ?)");
            String searchTerm = "%" + search.trim() + "%";
            params.add(searchTerm);
            params.add(searchTerm);
//            System.out.println("Added search filter: " + searchTerm);
        }

        sql.append(" ORDER BY sr.RoomName OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        params.add(offset);
        params.add(limit);

//        System.out.println("Final SQL: " + sql.toString());
//        System.out.println("Parameters: " + params);

        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            // Set parameters
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            ResultSet rs = ps.executeQuery();
            int count = 0;
            while (rs.next()) {
                ScreeningRoom room = mapResultSetToScreeningRoom(rs);
                list.add(room);
                count++;
//                System.out.println("Found room: " + room.getRoomName() + " (ID: " + room.getRoomID() + ")");
            }
//            System.out.println("Total rooms found: " + count);

        } catch (SQLException e) {
            System.out.println("Error in getRoomsWithFilters: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    // Count cho pagination
    public int countRoomsWithFilters(String location, Integer cinemaId, String roomType,
            String status, String search) {
        StringBuilder sql = new StringBuilder("""
            SELECT COUNT(*) as total
            FROM ScreeningRooms sr
            JOIN Cinemas c ON sr.CinemaID = c.CinemaID
            WHERE 1=1
        """);

        List<Object> params = new ArrayList<>();

        // Same WHERE conditions as getRoomsWithFilters
        if (location != null && !location.isEmpty()) {
            sql.append(" AND c.Location = ?");
            params.add(location);
        }

        if (cinemaId != null && cinemaId > 0) {
            sql.append(" AND sr.CinemaID = ?");
            params.add(cinemaId);
        }

        if (roomType != null && !roomType.equals("all")) {
            sql.append(" AND sr.RoomType = ?");
            params.add(roomType);
        }

        if (status != null && !status.equals("all")) {
            if (status.equals("active")) {
                sql.append(" AND sr.IsActive = 1");
            } else if (status.equals("inactive")) {
                sql.append(" AND sr.IsActive = 0");
            }
        }

        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (sr.RoomName LIKE ? OR c.CinemaName LIKE ?)");
            String searchTerm = "%" + search.trim() + "%";
            params.add(searchTerm);
            params.add(searchTerm);
        }

        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("total");
            }
        } catch (SQLException e) {
            System.out.println("Error in countRoomsWithFilters: " + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }

    // Lấy room by ID với đầy đủ thông tin
    public ScreeningRoom getRoomById(int roomId) {
        String sql = """
        SELECT sr.RoomID, sr.CinemaID, sr.RoomName, sr.SeatCapacity, sr.RoomType, 
               sr.IsActive,
               c.CinemaName, c.Location, c.Address, c.IsActive as CinemaActive
        FROM ScreeningRooms sr
        JOIN Cinemas c ON sr.CinemaID = c.CinemaID
        WHERE sr.RoomID = ?
    """;

        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, roomId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return mapResultSetToScreeningRoom(rs);
            }
        } catch (SQLException e) {
            System.out.println("Error in getRoomById: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    // Tạo mới room
    public int createRoom(ScreeningRoom room) {
        String sql = """
        INSERT INTO ScreeningRooms (CinemaID, RoomName, SeatCapacity, RoomType, IsActive)
        VALUES (?, ?, ?, ?, ?)
    """;

        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, room.getCinemaID());
            ps.setString(2, room.getRoomName());
            ps.setInt(3, room.getSeatCapacity());
            ps.setString(4, room.getRoomType());
            ps.setBoolean(5, room.isActive());

            int affectedRows = ps.executeUpdate();

            if (affectedRows > 0) {
                try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        return generatedKeys.getInt(1);
                    }
                }
            }
        } catch (SQLException e) {
            System.out.println("Error in createRoom: " + e.getMessage());
            e.printStackTrace();
        }
        return -1;
    }

    // Cập nhật room
    public boolean updateRoom(ScreeningRoom room) {
        String sql = """
            UPDATE ScreeningRooms 
            SET RoomName = ?, SeatCapacity = ?, RoomType = ?, IsActive = ?
            WHERE RoomID = ?
        """;

        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, room.getRoomName());
            ps.setInt(2, room.getSeatCapacity());
            ps.setString(3, room.getRoomType());
            ps.setBoolean(4, room.isActive());
            ps.setInt(5, room.getRoomID());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.out.println("Error in updateRoom: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // Soft delete
    public boolean deleteRoom(int roomId) {
        String sql = "UPDATE ScreeningRooms SET IsActive = 0 WHERE RoomID = ?";

        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, roomId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.out.println("Error in deleteRoom: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // Lấy rooms by cinema ID (có thể giữ nguyên method cũ)
    public List<ScreeningRoom> getRoomsByCinemaId(int cinemaId) {
        List<ScreeningRoom> list = new ArrayList<>();
        String sql = """
        SELECT sr.RoomID, sr.CinemaID, sr.RoomName, sr.SeatCapacity, sr.RoomType, 
               sr.IsActive,
               c.CinemaName, c.Location, c.Address
        FROM ScreeningRooms sr
        JOIN Cinemas c ON sr.CinemaID = c.CinemaID
        WHERE sr.CinemaID = ? AND sr.IsActive = 1
        ORDER BY sr.RoomName
    """;

        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, cinemaId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                ScreeningRoom room = mapResultSetToScreeningRoom(rs);
                list.add(room);
            }
        } catch (SQLException e) {
            System.out.println("Error in getRoomsByCinemaId: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    // Check room name exists (for create)
    public boolean isRoomNameExists(int cinemaId, String roomName) {
        String sql = "SELECT 1 FROM ScreeningRooms WHERE CinemaID = ? AND RoomName = ? AND IsActive = 1";

        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, cinemaId);
            ps.setString(2, roomName);
            ResultSet rs = ps.executeQuery();
            return rs.next();

        } catch (SQLException e) {
            System.out.println("Error in isRoomNameExists: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // Check room name exists (for update - exclude current room)
    public boolean isRoomNameExists(int cinemaId, String roomName, int excludeRoomId) {
        String sql = "SELECT 1 FROM ScreeningRooms WHERE CinemaID = ? AND RoomName = ? AND RoomID != ? AND IsActive = 1";

        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, cinemaId);
            ps.setString(2, roomName);
            ps.setInt(3, excludeRoomId);
            ResultSet rs = ps.executeQuery();
            return rs.next();

        } catch (SQLException e) {
            System.out.println("Error in isRoomNameExists (exclude): " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

// Helper method: Map ResultSet to ScreeningRoom object
    private ScreeningRoom mapResultSetToScreeningRoom(ResultSet rs) throws SQLException {
        ScreeningRoom room = new ScreeningRoom();
        room.setRoomID(rs.getInt("RoomID"));
        room.setCinemaID(rs.getInt("CinemaID"));
        room.setRoomName(rs.getString("RoomName"));
        room.setSeatCapacity(rs.getInt("SeatCapacity"));
        room.setRoomType(rs.getString("RoomType"));
        room.setActive(rs.getBoolean("IsActive"));

        // Create and set Cinema object
        CinemaM cinema = new CinemaM();
        cinema.setCinemaID(rs.getInt("CinemaID"));
        cinema.setCinemaName(rs.getString("CinemaName"));
        cinema.setLocation(rs.getString("Location"));
        cinema.setAddress(rs.getString("Address"));

        room.setCinema(cinema);

        return room;
    }

    //  Lấy các room types available
    public List<String> getAvailableRoomTypes() {
        List<String> types = new ArrayList<>();
        String sql = "SELECT DISTINCT RoomType FROM ScreeningRooms WHERE IsActive = 1 ORDER BY RoomType";

        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                types.add(rs.getString("RoomType"));
            }
        } catch (SQLException e) {
            System.out.println("Error in getAvailableRoomTypes: " + e.getMessage());
            e.printStackTrace();
        }
        return types;
    }

    // Thống kê rooms by cinema
    public Map<String, Integer> getRoomStatisticsByCinema(int cinemaId) {
        Map<String, Integer> stats = new HashMap<>();
        String sql = """
            SELECT RoomType, COUNT(*) as count 
            FROM ScreeningRooms 
            WHERE CinemaID = ? AND IsActive = 1 
            GROUP BY RoomType
        """;

        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, cinemaId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                stats.put(rs.getString("RoomType"), rs.getInt("count"));
            }
        } catch (SQLException e) {
            System.out.println("Error in getRoomStatisticsByCinema: " + e.getMessage());
            e.printStackTrace();
        }
        return stats;
    }

    // Lấy total seats capacity by cinema
    public int getTotalSeatCapacityByCinema(int cinemaId) {
        String sql = "SELECT SUM(SeatCapacity) as total FROM ScreeningRooms WHERE CinemaID = ? AND IsActive = 1";

        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, cinemaId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt("total");
            }
        } catch (SQLException e) {
            System.out.println("Error in getTotalSeatCapacityByCinema: " + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }

    // Get screening rooms by cinema ID
    public List<ScreeningRoom> getScreeningRoomsByCinemaId(int cinemaId) {
        List<ScreeningRoom> rooms = new ArrayList<>();
        String sql = "SELECT RoomID, CinemaID, RoomName, SeatCapacity, RoomType, IsActive FROM ScreeningRooms WHERE CinemaID = ? ORDER BY RoomName";

        try (Connection conn = db.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, cinemaId);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                ScreeningRoom room = new ScreeningRoom();
                room.setRoomID(rs.getInt("RoomID"));
                room.setCinemaID(rs.getInt("CinemaID"));
                room.setRoomName(rs.getString("RoomName"));
                room.setSeatCapacity(rs.getInt("SeatCapacity"));
                room.setRoomType(rs.getString("RoomType"));
                room.setActive(rs.getBoolean("IsActive"));

                rooms.add(room);
            }
        } catch (SQLException e) {
            System.out.println("Error in getScreeningRoomsByCinemaId for cinema " + cinemaId + ": " + e.getMessage());
        }
        return rooms;
    }

    public List<ScreeningRoom> getAllRooms() {
        List<ScreeningRoom> list = new ArrayList<>();
        String sql = """
            SELECT r.RoomID, r.CinemaID, r.RoomName, r.SeatCapacity
            FROM ScreeningRooms r
            JOIN Cinemas c ON r.CinemaID = c.CinemaID
            WHERE r.IsActive = 1
            ORDER BY r.RoomName
        """;

        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                ScreeningRoom room = new ScreeningRoom();
                room.setRoomID(rs.getInt("RoomID"));
                room.setCinemaID(rs.getInt("CinemaID"));
                room.setRoomName(rs.getString("RoomName"));
                room.setSeatCapacity(rs.getInt("SeatCapacity"));
                list.add(room);
            }

        } catch (SQLException e) {
            System.out.println("Error getAllRooms: " + e.getMessage());
        }

        return list;
    }
}
