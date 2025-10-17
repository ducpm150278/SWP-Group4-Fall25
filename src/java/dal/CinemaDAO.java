/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dal;

import entity.Cinema;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author admin
 */
public class CinemaDAO extends DBContext{
     public List<Cinema> getAllCinemas() {
        List<Cinema> list = new ArrayList<>();
        String sql = "SELECT CinemaID, CinemaName, Location, TotalRooms, IsActive FROM Cinemas";
        try (PreparedStatement ps = getConnection().prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Cinema c = new Cinema(
                    rs.getInt("CinemaID"),
                    rs.getString("CinemaName"),
                    rs.getString("Location"),
                    rs.getInt("TotalRooms"),
                    rs.getBoolean("IsActive")
                );
                list.add(c);
            }
        } catch (SQLException e) {
            System.out.println("getAllCinemas error: " + e.getMessage());
        }
        return list;
    }
    
}
