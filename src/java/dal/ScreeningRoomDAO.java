package dal;

import entity.ScreeningRoom;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ScreeningRoomDAO {

    DBContext db = new DBContext();

    public List<ScreeningRoom> getScreeningRoomsByCinemaId(int cinemaId) {
        List<ScreeningRoom> rooms = new ArrayList<>();
        String sql = "SELECT RoomID, CinemaID, RoomName, SeatCapacity, RoomType, IsActive FROM ScreeningRooms WHERE CinemaID = ? ORDER BY RoomName";

        try (Connection conn = db.connection; PreparedStatement stmt = conn.prepareStatement(sql)) {

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
        }
        return rooms;
    }

    public int countRoomsByCinemaId(int cinemaId) {
        String sql = "SELECT COUNT(*) as total FROM ScreeningRooms WHERE CinemaID = ? AND IsActive = 1";
        int total = 0;

        try (Connection conn = db.connection; PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, cinemaId);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                total = rs.getInt("total");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return total;
    }
}
