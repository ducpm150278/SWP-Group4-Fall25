/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dal;

import entity.ScreeningRoom;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author admin
 */

public class ScreeningRoomDAO extends DBContext{
       public List<ScreeningRoom> getAllRooms() {
    List<ScreeningRoom> list = new ArrayList<>();
    String sql = """
        SELECT r.RoomID, r.CinemaID, r.RoomName, r.SeatCapacity
        FROM ScreeningRooms r
        JOIN Cinemas c ON r.CinemaID = c.CinemaID
        WHERE r.IsActive = 1
        ORDER BY r.RoomName
    """;

    try (PreparedStatement ps = connection.prepareStatement(sql);
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

    
}