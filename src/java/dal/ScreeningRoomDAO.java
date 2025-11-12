package dal;

import entity.ScreeningRoom;
import entity.Cinema;
import entity.CinemaM;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.HashMap;
import java.util.Map;
import java.util.Collections;

public class ScreeningRoomDAO {

    private final DBContext db = new DBContext();

    // CORE METHODS - Lấy danh sách với filtering, pagination và seat capacity
    public List<ScreeningRoom> getRoomsWithFilters(String location, Integer cinemaId, String roomType,
            String status, String search, int offset, int limit) {
        List<ScreeningRoom> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("""
        SELECT sr.RoomID, sr.CinemaID, sr.RoomName, sr.RoomType, 
               sr.IsActive,
               c.CinemaName, c.Location, c.Address
        FROM ScreeningRooms sr
        JOIN Cinemas c ON sr.CinemaID = c.CinemaID
        WHERE 1=1
    """);

        List<Object> params = new ArrayList<>();

        // Build dynamic WHERE clause
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

        sql.append(" ORDER BY sr.RoomName OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        params.add(offset);
        params.add(limit);

        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            // Set parameters
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            ResultSet rs = ps.executeQuery();

            // Lấy danh sách room IDs để đếm ghế hiệu quả
            List<Integer> roomIds = new ArrayList<>();
            List<ScreeningRoom> tempRooms = new ArrayList<>();

            while (rs.next()) {
                ScreeningRoom room = mapResultSetToScreeningRoom(rs);
                tempRooms.add(room);
                roomIds.add(room.getRoomID());
            }

            // Đếm số ghế cho tất cả các phòng một lần
            Map<Integer, Integer> seatCounts = countSeatsForRooms(roomIds);

            // Gán seat capacity cho từng phòng
            for (ScreeningRoom room : tempRooms) {
                int seatCount = seatCounts.getOrDefault(room.getRoomID(), 0);
                room.setSeatCapacity(seatCount);
                list.add(room);
            }

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

    // Lấy room by ID với đầy đủ thông tin bao gồm seat capacity
    public ScreeningRoom getRoomById(int roomId) {
        ScreeningRoom room = getRoomByIdWithoutSeats(roomId);
        if (room != null) {
            int seatCount = countSeatsByRoomId(roomId);
            room.setSeatCapacity(seatCount);
        }
        return room;
    }

    // Phương thức phụ lấy room không có seat capacity
    private ScreeningRoom getRoomByIdWithoutSeats(int roomId) {
        String sql = """
        SELECT sr.RoomID, sr.CinemaID, sr.RoomName, sr.RoomType, 
               sr.IsActive,
               c.CinemaName, c.Location, c.Address
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
            System.out.println("Error in getRoomByIdWithoutSeats: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    // Tạo mới room
    public int createRoom(ScreeningRoom room) {
        String sql = """
        INSERT INTO ScreeningRooms (CinemaID, RoomName, RoomType, IsActive)
        VALUES (?, ?, ?, ?)
    """;

        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, room.getCinemaID());
            ps.setString(2, room.getRoomName());
            ps.setString(3, room.getRoomType());
            ps.setBoolean(4, room.isActive());

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
            SET RoomName = ?, RoomType = ?, IsActive = ?
            WHERE RoomID = ?
        """;

        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, room.getRoomName());
            ps.setString(2, room.getRoomType());
            ps.setBoolean(3, room.isActive());
            ps.setInt(4, room.getRoomID());

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

    // Hard delete
    public boolean deleteHRoom(int roomId) {
        String sql = "DELETE FROM ScreeningRooms WHERE RoomID = ?";

        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, roomId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.out.println("Error in deleteHRoom: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // Lấy rooms by cinema ID với seat capacity
    public List<ScreeningRoom> getRoomsByCinemaId(int cinemaId) {
        List<ScreeningRoom> list = new ArrayList<>();
        String sql = """
        SELECT sr.RoomID, sr.CinemaID, sr.RoomName, sr.RoomType, 
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

            // Lấy danh sách room IDs để đếm ghế hiệu quả
            List<Integer> roomIds = new ArrayList<>();
            List<ScreeningRoom> tempRooms = new ArrayList<>();

            while (rs.next()) {
                ScreeningRoom room = mapResultSetToScreeningRoom(rs);
                tempRooms.add(room);
                roomIds.add(room.getRoomID());
            }

            // Đếm số ghế cho tất cả các phòng một lần
            Map<Integer, Integer> seatCounts = countSeatsForRooms(roomIds);

            // Gán seat capacity cho từng phòng
            for (ScreeningRoom room : tempRooms) {
                int seatCount = seatCounts.getOrDefault(room.getRoomID(), 0);
                room.setSeatCapacity(seatCount);
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

    // Helper method: Map ResultSet to ScreeningRoom object (KHÔNG include seatCapacity)
    private ScreeningRoom mapResultSetToScreeningRoom(ResultSet rs) throws SQLException {
        ScreeningRoom room = new ScreeningRoom();
        room.setRoomID(rs.getInt("RoomID"));
        room.setCinemaID(rs.getInt("CinemaID"));
        room.setRoomName(rs.getString("RoomName"));
        room.setRoomType(rs.getString("RoomType"));
        room.setActive(rs.getBoolean("IsActive"));
        // KHÔNG set seatCapacity ở đây, sẽ set sau bằng phương thức riêng

        // Create and set Cinema object
        CinemaM cinema = new CinemaM();
        cinema.setCinemaID(rs.getInt("CinemaID"));
        cinema.setCinemaName(rs.getString("CinemaName"));
        cinema.setLocation(rs.getString("Location"));
        cinema.setAddress(rs.getString("Address"));

        room.setCinema(cinema);

        return room;
    }

    // Lấy các room types available
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

    // Get screening rooms by cinema ID (basic - không có cinema info)
    public List<ScreeningRoom> getScreeningRoomsByCinemaId(int cinemaId) {
        List<ScreeningRoom> rooms = new ArrayList<>();
        String sql = """
            SELECT sr.RoomID, sr.CinemaID, sr.RoomName, sr.RoomType, sr.IsActive,
                   c.CinemaName, c.Location, c.Address
            FROM ScreeningRooms sr
            JOIN Cinemas c ON sr.CinemaID = c.CinemaID
            WHERE sr.CinemaID = ? 
            ORDER BY sr.RoomName
        """;

        try (Connection conn = db.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, cinemaId);
            ResultSet rs = stmt.executeQuery();

            // Lấy danh sách room IDs để đếm ghế hiệu quả
            List<Integer> roomIds = new ArrayList<>();
            List<ScreeningRoom> tempRooms = new ArrayList<>();

            while (rs.next()) {
                ScreeningRoom room = mapResultSetToScreeningRoom(rs);
                tempRooms.add(room);
                roomIds.add(room.getRoomID());
            }

            // Đếm số ghế cho tất cả các phòng một lần
            Map<Integer, Integer> seatCounts = countSeatsForRooms(roomIds);

            // Gán seat capacity cho từng phòng
            for (ScreeningRoom room : tempRooms) {
                int seatCount = seatCounts.getOrDefault(room.getRoomID(), 0);
                room.setSeatCapacity(seatCount);
                rooms.add(room);
            }
        } catch (SQLException e) {
            System.out.println("Error in getScreeningRoomsByCinemaId for cinema " + cinemaId + ": " + e.getMessage());
            e.printStackTrace();
        }
        return rooms;
    }

    // Lấy tất cả rooms active với seat capacity
    public List<ScreeningRoom> getAllRooms() {
        List<ScreeningRoom> list = new ArrayList<>();
        String sql = """
            SELECT sr.RoomID, sr.CinemaID, sr.RoomName, sr.RoomType, sr.IsActive,
                   c.CinemaName, c.Location, c.Address
            FROM ScreeningRooms sr
            JOIN Cinemas c ON sr.CinemaID = c.CinemaID
            WHERE sr.IsActive = 1
            ORDER BY sr.RoomName
        """;

        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            // Lấy danh sách room IDs để đếm ghế hiệu quả
            List<Integer> roomIds = new ArrayList<>();
            List<ScreeningRoom> tempRooms = new ArrayList<>();

            while (rs.next()) {
                ScreeningRoom room = mapResultSetToScreeningRoom(rs);
                tempRooms.add(room);
                roomIds.add(room.getRoomID());
            }

            // Đếm số ghế cho tất cả các phòng một lần
            Map<Integer, Integer> seatCounts = countSeatsForRooms(roomIds);

            // Gán seat capacity cho từng phòng
            for (ScreeningRoom room : tempRooms) {
                int seatCount = seatCounts.getOrDefault(room.getRoomID(), 0);
                room.setSeatCapacity(seatCount);
                list.add(room);
            }

        } catch (SQLException e) {
            System.out.println("Error getAllRooms: " + e.getMessage());
            e.printStackTrace();
        }

        return list;
    }

    // Phương thức đếm số ghế của một phòng chiếu (chỉ đếm ghế Available và Maintenance)
    public int countSeatsByRoomId(int roomId) {
        String sql = """
            SELECT COUNT(*) as seatCount 
            FROM Seats 
            WHERE RoomID = ? AND Status IN ('Available', 'Maintenance')
        """;

        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, roomId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt("seatCount");
            }
        } catch (SQLException e) {
            System.out.println("Error in countSeatsByRoomId: " + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }

    // Phương thức đếm số ghế cho nhiều phòng (tối ưu hiệu suất)
    public Map<Integer, Integer> countSeatsForRooms(List<Integer> roomIds) {
        Map<Integer, Integer> seatCounts = new HashMap<>();
        if (roomIds == null || roomIds.isEmpty()) {
            return seatCounts;
        }

        // Tạo placeholders cho query
        String placeholders = String.join(",", Collections.nCopies(roomIds.size(), "?"));
        String sql = String.format("""
            SELECT RoomID, COUNT(*) as seatCount 
            FROM Seats 
            WHERE RoomID IN (%s) AND Status IN ('Available', 'Maintenance')
            GROUP BY RoomID
        """, placeholders);

        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            // Set parameters
            for (int i = 0; i < roomIds.size(); i++) {
                ps.setInt(i + 1, roomIds.get(i));
            }

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                seatCounts.put(rs.getInt("RoomID"), rs.getInt("seatCount"));
            }
        } catch (SQLException e) {
            System.out.println("Error in countSeatsForRooms: " + e.getMessage());
            e.printStackTrace();
        }
        return seatCounts;
    }

    // Đếm số ghế theo trạng thái cho một phòng
    public Map<String, Integer> countSeatsByStatus(int roomId) {
        Map<String, Integer> statusCounts = new HashMap<>();
        String sql = """
            SELECT Status, COUNT(*) as count
            FROM Seats 
            WHERE RoomID = ?
            GROUP BY Status
        """;

        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, roomId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                statusCounts.put(rs.getString("Status"), rs.getInt("count"));
            }
        } catch (SQLException e) {
            System.out.println("Error in countSeatsByStatus: " + e.getMessage());
            e.printStackTrace();
        }
        return statusCounts;
    }

    // Đếm số ghế theo loại cho một phòng
    public Map<String, Integer> countSeatsByType(int roomId) {
        Map<String, Integer> typeCounts = new HashMap<>();
        String sql = """
            SELECT SeatType, COUNT(*) as count
            FROM Seats 
            WHERE RoomID = ? AND Status IN ('Available', 'Maintenance')
            GROUP BY SeatType
        """;

        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, roomId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                typeCounts.put(rs.getString("SeatType"), rs.getInt("count"));
            }
        } catch (SQLException e) {
            System.out.println("Error in countSeatsByType: " + e.getMessage());
            e.printStackTrace();
        }
        return typeCounts;
    }

    // Lấy thống kê seat capacity theo cinema
    public Map<String, Object> getSeatCapacityStatistics(int cinemaId) {
        Map<String, Object> stats = new HashMap<>();
        String sql = """
            SELECT 
                sr.RoomType,
                COUNT(DISTINCT sr.RoomID) as roomCount,
                COUNT(s.SeatID) as totalSeats
            FROM ScreeningRooms sr
            LEFT JOIN Seats s ON sr.RoomID = s.RoomID AND s.Status IN ('Available', 'Maintenance')
            WHERE sr.CinemaID = ? AND sr.IsActive = 1
            GROUP BY sr.RoomType
        """;

        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, cinemaId);
            ResultSet rs = ps.executeQuery();

            int totalRooms = 0;
            int totalSeats = 0;
            Map<String, Integer> seatsByType = new HashMap<>();

            while (rs.next()) {
                String roomType = rs.getString("RoomType");
                int roomCount = rs.getInt("roomCount");
                int seatCount = rs.getInt("totalSeats");

                totalRooms += roomCount;
                totalSeats += seatCount;
                seatsByType.put(roomType, seatCount);
            }

            stats.put("totalRooms", totalRooms);
            stats.put("totalSeats", totalSeats);
            stats.put("seatsByType", seatsByType);

        } catch (SQLException e) {
            System.out.println("Error in getSeatCapacityStatistics: " + e.getMessage());
            e.printStackTrace();
        }
        return stats;
    }

    // Lấy thống kê chi tiết về ghế cho một phòng
    public Map<String, Object> getDetailedSeatStatistics(int roomId) {
        Map<String, Object> stats = new HashMap<>();

        // Tổng số ghế
        int totalSeats = countSeatsByRoomId(roomId);
        stats.put("totalSeats", totalSeats);

        // Số ghế theo trạng thái
        Map<String, Integer> statusCounts = countSeatsByStatus(roomId);
        stats.put("seatsByStatus", statusCounts);

        // Số ghế theo loại
        Map<String, Integer> typeCounts = countSeatsByType(roomId);
        stats.put("seatsByType", typeCounts);

        return stats;
    }

    // MAIN METHOD FOR TESTING
    public static void main(String[] args) {
        ScreeningRoomDAO srd = new ScreeningRoomDAO();

        System.out.println("=== TESTING SCREENING ROOM DAO ===");

        // Test lấy danh sách phòng với seat capacity
        List<ScreeningRoom> rooms = srd.getRoomsWithFilters("Cần Thơ", null, "all", "all", "", 0, 10);
        System.out.println("Found " + rooms.size() + " rooms in Cần Thơ");

        for (ScreeningRoom room : rooms) {
            System.out.println("Room: " + room.getRoomName()
                    + " | Cinema: " + room.getCinema().getCinemaName()
                    + " | Type: " + room.getRoomType()
                    + " | Seats: " + room.getSeatCapacity()
                    + " | Active: " + room.isActive());

            // Test thống kê chi tiết ghế cho mỗi phòng
            if (room.getSeatCapacity() > 0) {
                Map<String, Object> seatStats = srd.getDetailedSeatStatistics(room.getRoomID());
                System.out.println("  - Seat Details: " + seatStats);
            }
        }

        // Test count
        int totalCount = srd.countRoomsWithFilters("Cần Thơ", null, "all", "all", "");
        System.out.println("Total count: " + totalCount);

        // Test lấy room types
        List<String> roomTypes = srd.getAvailableRoomTypes();
        System.out.println("Available room types: " + roomTypes);

        if (!rooms.isEmpty()) {
            // Test lấy phòng cụ thể
            ScreeningRoom room = srd.getRoomById(rooms.get(0).getRoomID());
            System.out.println("Room detail - Name: " + room.getRoomName()
                    + ", Seats: " + room.getSeatCapacity());

            // Test thống kê ghế theo trạng thái và loại
            Map<String, Integer> statusCounts = srd.countSeatsByStatus(room.getRoomID());
            Map<String, Integer> typeCounts = srd.countSeatsByType(room.getRoomID());
            System.out.println("Seat status counts: " + statusCounts);
            System.out.println("Seat type counts: " + typeCounts);
        }
    }
}
