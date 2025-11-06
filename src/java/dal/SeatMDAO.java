package dal;

import entity.SeatM;
import java.sql.*;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class SeatMDAO {

    private DBContext db = new DBContext();

    // 1. Lấy danh sách ghế theo room ID
    public List<SeatM> getSeatsByRoom(int roomId) {
        List<SeatM> seats = new ArrayList<>();
        String sql = """
            SELECT SeatID, RoomID, SeatRow, SeatNumber, SeatType, Status
            FROM Seats 
            WHERE RoomID = ? 
            ORDER BY 
                CASE WHEN SeatRow LIKE '[A-Z]' THEN 0 ELSE 1 END,
                SeatRow, 
                CAST(SeatNumber AS INT)
        """;

        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, roomId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                SeatM seat = mapResultSetToSeat(rs);
                seats.add(seat);
            }
        } catch (SQLException e) {
            System.out.println("Error in getSeatsByRoom for room " + roomId + ": " + e.getMessage());
            e.printStackTrace();
        }
        return seats;
    }

    // 2. Lấy ghế theo ID
    public SeatM getSeatById(int seatId) {
        String sql = "SELECT SeatID, RoomID, SeatRow, SeatNumber, SeatType, Status FROM Seats WHERE SeatID = ?";

        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, seatId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return mapResultSetToSeat(rs);
            }
        } catch (SQLException e) {
            System.out.println("Error in getSeatById: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    // 3. Tạo hàng loạt ghế
    public boolean createBulkSeats(List<SeatM> seats) {
        if (seats == null || seats.isEmpty()) {
            return true; // Nothing to create
        }

        String sql = "INSERT INTO Seats (RoomID, SeatRow, SeatNumber, SeatType, Status) VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            conn.setAutoCommit(false); // Start transaction

            for (SeatM seat : seats) {
                ps.setInt(1, seat.getRoomID());
                ps.setString(2, seat.getSeatRow());
                ps.setString(3, seat.getSeatNumber());
                ps.setString(4, seat.getSeatType());
                ps.setString(5, seat.getStatus());
                ps.addBatch();
            }

            int[] results = ps.executeBatch();
            conn.commit(); // Commit transaction

            // Check if all inserts were successful
            for (int result : results) {
                if (result == Statement.EXECUTE_FAILED) {
                    return false;
                }
            }
            return true;

        } catch (SQLException e) {
            System.out.println("Error in createBulkSeats: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // 4. Cập nhật ghế
    public boolean updateSeat(SeatM seat) {
        String sql = "UPDATE Seats SET SeatRow = ?, SeatNumber = ?, SeatType = ?, Status = ? WHERE SeatID = ?";

        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, seat.getSeatRow());
            ps.setString(2, seat.getSeatNumber());
            ps.setString(3, seat.getSeatType());
            ps.setString(4, seat.getStatus());
            ps.setInt(5, seat.getSeatID());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.out.println("Error in updateSeat: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // 5. Cập nhật loại ghế
    public boolean updateSeatType(int seatId, String seatType) {
        String sql = "UPDATE Seats SET SeatType = ? WHERE SeatID = ?";

        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, seatType);
            ps.setInt(2, seatId);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.out.println("Error in updateSeatType: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // 6. Cập nhật trạng thái ghế
    public boolean updateSeatStatus(int seatId, String status) {
        String sql = "UPDATE Seats SET Status = ? WHERE SeatID = ?";

        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setInt(2, seatId);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.out.println("Error in updateSeatStatus: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // 7. Xóa ghế (hard delete)
    public boolean deleteSeat(int seatId) {
        String sql = "DELETE FROM Seats WHERE SeatID = ?";

        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, seatId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.out.println("Error in deleteSeat: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // 8. Xóa tất cả ghế của một phòng
    public boolean deleteSeatsByRoom(int roomId) {
        String sql = "DELETE FROM Seats WHERE RoomID = ?";

        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, roomId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.out.println("Error in deleteSeatsByRoom: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // 9. Đếm số ghế theo loại trong một phòng
    public int countSeatsByType(int roomId, String seatType) {
        String sql = "SELECT COUNT(*) as count FROM Seats WHERE RoomID = ? AND SeatType = ?";

        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, roomId);
            ps.setString(2, seatType);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt("count");
            }
        } catch (SQLException e) {
            System.out.println("Error in countSeatsByType: " + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }

    // 10. Đếm số ghế theo trạng thái trong một phòng
    public int countSeatsByStatus(int roomId, String status) {
        String sql = "SELECT COUNT(*) as count FROM Seats WHERE RoomID = ? AND Status = ?";

        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, roomId);
            ps.setString(2, status);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt("count");
            }
        } catch (SQLException e) {
            System.out.println("Error in countSeatsByStatus: " + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }

    // 11. Kiểm tra xem vị trí ghế đã tồn tại chưa
    public boolean isSeatPositionExists(int roomId, String seatRow, String seatNumber) {
        String sql = "SELECT 1 FROM Seats WHERE RoomID = ? AND SeatRow = ? AND SeatNumber = ?";

        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, roomId);
            ps.setString(2, seatRow);
            ps.setString(3, seatNumber);
            ResultSet rs = ps.executeQuery();

            return rs.next();
        } catch (SQLException e) {
            System.out.println("Error in isSeatPositionExists: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // 12. Lấy thống kê ghế theo phòng
    public java.util.Map<String, Integer> getSeatStatisticsByRoom(int roomId) {
        java.util.Map<String, Integer> stats = new java.util.HashMap<>();

        // Thống kê theo loại ghế
        String typeSql = "SELECT SeatType, COUNT(*) as count FROM Seats WHERE RoomID = ? GROUP BY SeatType";
        // Thống kê theo trạng thái
        String statusSql = "SELECT Status, COUNT(*) as count FROM Seats WHERE RoomID = ? GROUP BY Status";

        try (Connection conn = db.getConnection(); PreparedStatement typePs = conn.prepareStatement(typeSql); PreparedStatement statusPs = conn.prepareStatement(statusSql)) {

            // Thống kê loại ghế
            typePs.setInt(1, roomId);
            ResultSet typeRs = typePs.executeQuery();
            while (typeRs.next()) {
                stats.put("type_" + typeRs.getString("SeatType"), typeRs.getInt("count"));
            }

            // Thống kê trạng thái
            statusPs.setInt(1, roomId);
            ResultSet statusRs = statusPs.executeQuery();
            while (statusRs.next()) {
                stats.put("status_" + statusRs.getString("Status"), statusRs.getInt("count"));
            }

        } catch (SQLException e) {
            System.out.println("Error in getSeatStatisticsByRoom: " + e.getMessage());
            e.printStackTrace();
        }
        return stats;
    }

    // 13. Cập nhật hàng loạt ghế
    public boolean bulkUpdateSeats(List<SeatM> seats) {
        if (seats == null || seats.isEmpty()) {
            return true;
        }

        String sql = "UPDATE Seats SET SeatRow = ?, SeatNumber = ?, SeatType = ?, Status = ? WHERE SeatID = ?";

        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            conn.setAutoCommit(false);

            for (SeatM seat : seats) {
                ps.setString(1, seat.getSeatRow());
                ps.setString(2, seat.getSeatNumber());
                ps.setString(3, seat.getSeatType());
                ps.setString(4, seat.getStatus());
                ps.setInt(5, seat.getSeatID());
                ps.addBatch();
            }

            int[] results = ps.executeBatch();
            conn.commit();

            for (int result : results) {
                if (result == Statement.EXECUTE_FAILED) {
                    return false;
                }
            }
            return true;

        } catch (SQLException e) {
            System.out.println("Error in bulkUpdateSeats: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // 14. Lấy trạng thái ghế theo screening (cho booking)
    public Map<Integer, String> getSeatStatusForScreening(int screeningId, int roomId) {
        Map<Integer, String> seatStatusMap = new HashMap<>();
        String sql = """
            SELECT s.SeatID, 
                   CASE 
                     WHEN t.TicketID IS NOT NULL THEN 'Booked'
                     WHEN sr.ReservationID IS NOT NULL AND sr.ExpiresAt > GETDATE() THEN 'Reserved'
                     ELSE s.Status
                   END AS CurrentStatus
            FROM Seats s
            LEFT JOIN Tickets t ON s.SeatID = t.SeatID AND t.ScreeningID = ?
            LEFT JOIN SeatReservations sr ON s.SeatID = sr.SeatID AND sr.ScreeningID = ?
            WHERE s.RoomID = ?
            ORDER BY s.SeatRow, s.SeatNumber
        """;

        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, screeningId);
            ps.setInt(2, screeningId);
            ps.setInt(3, roomId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                int seatId = rs.getInt("SeatID");
                String status = rs.getString("CurrentStatus");
                seatStatusMap.put(seatId, status);
            }
        } catch (SQLException e) {
            System.out.println("Error in getSeatStatusForScreening: " + e.getMessage());
            e.printStackTrace();
        }
        return seatStatusMap;
    }

    // 15. Kiểm tra ghế có available cho screening không
    public boolean isSeatAvailableForScreening(int seatId, int screeningId) {
        String sql = """
            SELECT CASE 
                     WHEN t.TicketID IS NOT NULL THEN 0
                     WHEN sr.ReservationID IS NOT NULL AND sr.ExpiresAt > GETDATE() THEN 0
                     WHEN s.Status != 'Available' THEN 0
                     ELSE 1
                   END AS IsAvailable
            FROM Seats s
            LEFT JOIN Tickets t ON s.SeatID = t.SeatID AND t.ScreeningID = ?
            LEFT JOIN SeatReservations sr ON s.SeatID = sr.SeatID AND sr.ScreeningID = ?
            WHERE s.SeatID = ?
        """;

        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, screeningId);
            ps.setInt(2, screeningId);
            ps.setInt(3, seatId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getBoolean("IsAvailable");
            }
        } catch (SQLException e) {
            System.out.println("Error in isSeatAvailableForScreening: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    // 16. Lấy ghế theo screening và room
    public List<SeatM> getSeatsForScreening(int screeningId, int roomId) {
        List<SeatM> seats = new ArrayList<>();
        String sql = """
            SELECT s.SeatID, s.RoomID, s.SeatRow, s.SeatNumber, s.SeatType, 
                   CASE 
                     WHEN t.TicketID IS NOT NULL THEN 'Booked'
                     WHEN sr.ReservationID IS NOT NULL AND sr.ExpiresAt > GETDATE() THEN 'Reserved'
                     ELSE s.Status
                   END AS CurrentStatus
            FROM Seats s
            LEFT JOIN Tickets t ON s.SeatID = t.SeatID AND t.ScreeningID = ?
            LEFT JOIN SeatReservations sr ON s.SeatID = sr.SeatID AND sr.ScreeningID = ?
            WHERE s.RoomID = ?
            ORDER BY 
                CASE WHEN s.SeatRow LIKE '[A-Z]' THEN 0 ELSE 1 END,
                s.SeatRow, 
                CAST(s.SeatNumber AS INT)
        """;

        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, screeningId);
            ps.setInt(2, screeningId);
            ps.setInt(3, roomId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                SeatM seat = new SeatM();
                seat.setSeatID(rs.getInt("SeatID"));
                seat.setRoomID(rs.getInt("RoomID"));
                seat.setSeatRow(rs.getString("SeatRow"));
                seat.setSeatNumber(rs.getString("SeatNumber"));
                seat.setSeatType(rs.getString("SeatType"));
                seat.setStatus(rs.getString("CurrentStatus")); // Status động theo screening

                seats.add(seat);
            }
        } catch (SQLException e) {
            System.out.println("Error in getSeatsForScreening: " + e.getMessage());
        }
        return seats;
    }

    // 17. Cập nhật hàng loạt trạng thái ghế
    public boolean bulkUpdateSeatStatus(List<Integer> seatIds, String status) {
        if (seatIds == null || seatIds.isEmpty()) {
            return true;
        }

        // Tạo placeholders cho IN clause
        String placeholders = String.join(",", Collections.nCopies(seatIds.size(), "?"));
        String sql = "UPDATE Seats SET Status = ? WHERE SeatID IN (" + placeholders + ")";

        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            conn.setAutoCommit(false);
            ps.setString(1, status);

            for (int i = 0; i < seatIds.size(); i++) {
                ps.setInt(i + 2, seatIds.get(i));
            }

            int result = ps.executeUpdate();
            conn.commit();

            return result > 0;
        } catch (SQLException e) {
            System.out.println("Error in bulkUpdateSeatStatus: " + e.getMessage());
            return false;
        }
    }

    // 18. Cập nhật hàng loạt loại ghế
    public boolean bulkUpdateSeatType(List<Integer> seatIds, String seatType) {
        if (seatIds == null || seatIds.isEmpty()) {
            return true;
        }

        String placeholders = String.join(",", Collections.nCopies(seatIds.size(), "?"));
        String sql = "UPDATE Seats SET SeatType = ? WHERE SeatID IN (" + placeholders + ")";

        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            conn.setAutoCommit(false);
            ps.setString(1, seatType);

            for (int i = 0; i < seatIds.size(); i++) {
                ps.setInt(i + 2, seatIds.get(i));
            }

            int result = ps.executeUpdate();
            conn.commit();

            return result > 0;
        } catch (SQLException e) {
            System.out.println("Error in bulkUpdateSeatType: " + e.getMessage());
            return false;
        }
    }

// Helper method: Map ResultSet to Seat object
    private SeatM mapResultSetToSeat(ResultSet rs) throws SQLException {
        try {
            SeatM seat = new SeatM();
            seat.setSeatID(rs.getInt("SeatID"));
            seat.setRoomID(rs.getInt("RoomID"));

            // Debug thông tin seatRow và seatNumber
            String seatRow = rs.getString("SeatRow");
            String seatNumber = rs.getString("SeatNumber");

            System.out.println("Loading seat - Row: '" + seatRow + "', Number: '" + seatNumber + "'");

            seat.setSeatRow(seatRow);
            seat.setSeatNumber(seatNumber);
            seat.setSeatType(rs.getString("SeatType"));
            seat.setStatus(rs.getString("Status"));

            return seat;
        } catch (SQLException e) {
            System.err.println("Error mapping seat from ResultSet: " + e.getMessage());
            e.printStackTrace();
            throw e;
        }
    }
}
