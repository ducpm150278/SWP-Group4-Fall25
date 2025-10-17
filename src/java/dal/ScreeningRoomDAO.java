/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dal;

import entity.ScreeningRoom;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.sql.*;
/**
 *
 * @author admin
 */

public class ScreeningRoomDAO {
    DBContext db = new DBContext();
     public List<ScreeningRoom> getAllRooms() {
        List<ScreeningRoom> list = new ArrayList<>();
        String sql = """
            SELECT r.RoomID, r.CinemaID, r.RoomName, r.SeatCapacity
            FROM ScreeningRooms r
            JOIN Cinemas c ON r.CinemaID = c.CinemaID
            WHERE r.IsActive = 1
            ORDER BY r.RoomName
        """;

        try (Connection conn = db.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

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
    // Chuyển đổi Timestamp sang LocalDateTime
    private LocalDateTime toLocalDateTime(Timestamp timestamp) {
        try {
            return timestamp != null ? timestamp.toLocalDateTime() : null;
        } catch (Exception e) {
            System.out.println("Error converting timestamp: " + e.getMessage());
            return null;
        }
    }

    // Get screening rooms by cinema ID
    public List<ScreeningRoom> getScreeningRoomsByCinemaId(int cinemaId) {
        List<ScreeningRoom> rooms = new ArrayList<>();
        String sql = "SELECT RoomID, CinemaID, RoomName, SeatCapacity, RoomType, IsActive FROM ScreeningRooms WHERE CinemaID = ? ORDER BY RoomName";

        try (Connection conn = db.getConnection(); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {

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

    // Count total rooms by cinema ID
    public int countRoomsByCinemaId(int cinemaId) {
        String sql = "SELECT COUNT(*) as total FROM ScreeningRooms WHERE CinemaID = ? AND IsActive = 1";
        int total = 0;

        try (Connection conn = db.getConnection(); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, cinemaId);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                total = rs.getInt("total");
            }
        } catch (SQLException e) {
            System.out.println("Error in countRoomsByCinemaId for cinema " + cinemaId + ": " + e.getMessage());
        }
        return total;
    }

    // Get screening room by ID
    public ScreeningRoom getScreeningRoomById(int roomId) {
        ScreeningRoom room = null;
        String sql = "SELECT RoomID, CinemaID, RoomName, SeatCapacity, RoomType, IsActive FROM ScreeningRooms WHERE RoomID = ?";

        try (Connection conn = db.getConnection(); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, roomId);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                room = new ScreeningRoom();
                room.setRoomID(rs.getInt("RoomID"));
                room.setCinemaID(rs.getInt("CinemaID"));
                room.setRoomName(rs.getString("RoomName"));
                room.setSeatCapacity(rs.getInt("SeatCapacity"));
                room.setRoomType(rs.getString("RoomType"));
                room.setActive(rs.getBoolean("IsActive"));
            }
        } catch (SQLException e) {
            System.out.println("Error in getScreeningRoomById: " + e.getMessage());
        }
        return room;
    }

    // Add new screening room
    public boolean addScreeningRoom(ScreeningRoom room) {
        String sql = "INSERT INTO ScreeningRooms (CinemaID, RoomName, SeatCapacity, RoomType, IsActive) VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = db.getConnection(); 
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setInt(1, room.getCinemaID());
            stmt.setString(2, room.getRoomName());
            stmt.setInt(3, room.getSeatCapacity());
            stmt.setString(4, room.getRoomType());
            stmt.setBoolean(5, room.isActive());

            int affectedRows = stmt.executeUpdate();

            if (affectedRows > 0) {
                try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        room.setRoomID(generatedKeys.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            System.out.println("Error in addScreeningRoom: " + e.getMessage());
        }
        return false;
    }

    // Update screening room
    public boolean updateScreeningRoom(ScreeningRoom room) {
        String sql = "UPDATE ScreeningRooms SET RoomName = ?, SeatCapacity = ?, RoomType = ?, IsActive = ? WHERE RoomID = ?";

        try (Connection conn = db.getConnection(); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, room.getRoomName());
            stmt.setInt(2, room.getSeatCapacity());
            stmt.setString(3, room.getRoomType());
            stmt.setBoolean(4, room.isActive());
            stmt.setInt(5, room.getRoomID());

            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.out.println("Error in updateScreeningRoom: " + e.getMessage());
            return false;
        }
    }

    // Delete screening room (soft delete)
    public boolean deleteScreeningRoom(int roomId) {
        String sql = "UPDATE ScreeningRooms SET IsActive = 0 WHERE RoomID = ?";

        try (Connection conn = db.getConnection(); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, roomId);
            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.out.println("Error in deleteScreeningRoom: " + e.getMessage());
            return false;
        }
    }

    // Hard delete screening room
    public boolean hardDeleteScreeningRoom(int roomId) {
        String sql = "DELETE FROM ScreeningRooms WHERE RoomID = ?";

        try (Connection conn = db.getConnection(); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, roomId);
            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.out.println("Error in hardDeleteScreeningRoom: " + e.getMessage());
            return false;
        }
    }

    // Get active screening rooms by cinema ID
    public List<ScreeningRoom> getActiveScreeningRoomsByCinemaId(int cinemaId) {
        List<ScreeningRoom> rooms = new ArrayList<>();
        String sql = "SELECT RoomID, CinemaID, RoomName, SeatCapacity, RoomType, IsActive FROM ScreeningRooms WHERE CinemaID = ? AND IsActive = 1 ORDER BY RoomName";

        try (Connection conn = db.getConnection(); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {

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
            System.out.println("Error in getActiveScreeningRoomsByCinemaId: " + e.getMessage());
        }
        return rooms;
    }

    // Count total seats by cinema ID
    public int countTotalSeatsByCinemaId(int cinemaId) {
        String sql = "SELECT SUM(SeatCapacity) as totalSeats FROM ScreeningRooms WHERE CinemaID = ? AND IsActive = 1";
        int totalSeats = 0;

        try (Connection conn = db.getConnection(); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, cinemaId);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                totalSeats = rs.getInt("totalSeats");
            }
        } catch (SQLException e) {
            System.out.println("Error in countTotalSeatsByCinemaId: " + e.getMessage());
        }
        return totalSeats;
    }

    // Get screening rooms by room type
    public List<ScreeningRoom> getScreeningRoomsByType(int cinemaId, String roomType) {
        List<ScreeningRoom> rooms = new ArrayList<>();
        String sql = "SELECT RoomID, CinemaID, RoomName, SeatCapacity, RoomType, IsActive FROM ScreeningRooms WHERE CinemaID = ? AND RoomType = ? AND IsActive = 1 ORDER BY RoomName";

        try (Connection conn = db.getConnection(); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, cinemaId);
            stmt.setString(2, roomType);
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
            System.out.println("Error in getScreeningRoomsByType: " + e.getMessage());
        }
        return rooms;
    }

    // Check if room name already exists in the same cinema
    public boolean checkRoomNameExists(int cinemaId, String roomName) {
        String sql = "SELECT 1 FROM ScreeningRooms WHERE CinemaID = ? AND RoomName = ?";
        
        try (Connection conn = db.getConnection(); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, cinemaId);
            stmt.setString(2, roomName);
            ResultSet rs = stmt.executeQuery();
            
            return rs.next();
        } catch (SQLException e) {
            System.out.println("Error in checkRoomNameExists: " + e.getMessage());
            return false;
        }
    }

    // Check if room name exists excluding current room (for update)
    public boolean checkRoomNameExists(int cinemaId, String roomName, int excludeRoomId) {
        String sql = "SELECT 1 FROM ScreeningRooms WHERE CinemaID = ? AND RoomName = ? AND RoomID != ?";
        
        try (Connection conn = db.getConnection(); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, cinemaId);
            stmt.setString(2, roomName);
            stmt.setInt(3, excludeRoomId);
            ResultSet rs = stmt.executeQuery();
            
            return rs.next();
        } catch (SQLException e) {
            System.out.println("Error in checkRoomNameExists: " + e.getMessage());
            return false;
        }
    }

    // Toggle room status
    public boolean toggleRoomStatus(int roomId, boolean isActive) {
        String sql = "UPDATE ScreeningRooms SET IsActive = ? WHERE RoomID = ?";

        try (Connection conn = db.getConnection(); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setBoolean(1, isActive);
            stmt.setInt(2, roomId);
            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.out.println("Error in toggleRoomStatus: " + e.getMessage());
            return false;
        }
    }

    // Get room statistics by cinema ID
    public java.util.Map<String, Integer> getRoomStatisticsByCinemaId(int cinemaId) {
        java.util.Map<String, Integer> stats = new java.util.HashMap<>();
        String sql = "SELECT RoomType, COUNT(*) as count FROM ScreeningRooms WHERE CinemaID = ? AND IsActive = 1 GROUP BY RoomType";

        try (Connection conn = db.getConnection(); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, cinemaId);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                stats.put(rs.getString("RoomType"), rs.getInt("count"));
            }
        } catch (SQLException e) {
            System.out.println("Error in getRoomStatisticsByCinemaId: " + e.getMessage());
        }
        return stats;
    }

    
}