package dal;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import entity.Cinema;

/**
 *
 * @author dungv
 */
public class CinemaDAO {

    DBContext db = new DBContext();
    protected Connection connection = db.connection;

    // Test function
    public static void main(String[] args) throws SQLException {
        CinemaDAO cinemaDAO = new CinemaDAO();

        // Test get all cinemas
        System.out.println("=== All Cinemas ===");
        for (Cinema cinema : cinemaDAO.getAllCinemas()) {
            System.out.println(cinema);
        }

        // Test add new cinema
//        boolean added = cinemaDAO.addNewCinema("CGV Vincom Center", "72 Lê Thánh Tôn, Quận 1, TP.HCM", 8, true);
//        System.out.println("Add cinema result: " + added);

        // Test get cinema by ID
//        System.out.println("\n=== Cinema by ID ===");
//        Cinema cinema = cinemaDAO.getCinemaByID(1);
//        System.out.println(cinema);

        // Test update cinema
//        boolean updated = cinemaDAO.updateCinema(1, "CGV Vincom Center Updated", "72 Lê Thánh Tôn, Quận 1, TP.HCM Updated", 10, false);
//        System.out.println("Update cinema result: " + updated);

        // Test delete cinema (soft delete)
//        boolean deleted = cinemaDAO.deleteCinema(1);
//        System.out.println("Delete cinema result: " + deleted);

        // Test filter and sort cinemas
//        System.out.println("\n=== Filtered Cinemas ===");
//        List<Cinema> filtered = cinemaDAO.getAllCinemas("CGV", "active", "name_asc");
//        for (Cinema c : filtered) {
//            System.out.println(c);
//        }

        // Test count cinemas
//        int total = cinemaDAO.countCinemas("CGV", "active");
//        System.out.println("Total cinemas: " + total);
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

    // ============ CRUD OPERATIONS ============

    // Get all cinemas
    public List<Cinema> getAllCinemas() {
        List<Cinema> list = new ArrayList<>();
        String sql = "SELECT [CinemaID]\n"
                + "      ,[CinemaName]\n"
                + "      ,[Location]\n"
                + "      ,[TotalRooms]\n"
                + "      ,[IsActive]\n"
                + "      ,[CreatedDate]\n"
                + "  FROM [dbo].[Cinemas]\n"
                + "  ORDER BY [CinemaName] ASC";

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(new Cinema(
                        rs.getInt("CinemaID"),
                        rs.getString("CinemaName"),
                        rs.getString("Location"),
                        rs.getInt("TotalRooms"),
                        rs.getBoolean("IsActive"),
                        toLocalDateTime(rs.getTimestamp("CreatedDate"))
                ));
            }
        } catch (SQLException e) {
            System.out.println("Error in getAllCinemas: " + e);
        }
        return list;
    }

    // Get cinema by ID
    public Cinema getCinemaByID(int cinemaID) {
        String sql = "SELECT [CinemaID]\n"
                + "      ,[CinemaName]\n"
                + "      ,[Location]\n"
                + "      ,[TotalRooms]\n"
                + "      ,[IsActive]\n"
                + "      ,[CreatedDate]\n"
                + "  FROM [dbo].[Cinemas]\n"
                + "  WHERE [CinemaID] = ?";

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, cinemaID);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return new Cinema(
                        rs.getInt("CinemaID"),
                        rs.getString("CinemaName"),
                        rs.getString("Location"),
                        rs.getInt("TotalRooms"),
                        rs.getBoolean("IsActive"),
                        toLocalDateTime(rs.getTimestamp("CreatedDate"))
                );
            }
        } catch (SQLException e) {
            System.out.println("Error in getCinemaByID: " + e);
        }
        return null;
    }

    // Add new cinema
    public boolean addNewCinema(String cinemaName, String location, int totalRooms, boolean isActive) {
        String sql = "INSERT INTO [dbo].[Cinemas]\n"
                + "           ([CinemaName]\n"
                + "           ,[Location]\n"
                + "           ,[TotalRooms]\n"
                + "           ,[IsActive])\n"
                + "     VALUES\n"
                + "           (?, ?, ?, ?)";

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setString(1, cinemaName);
            ps.setString(2, location);
            ps.setInt(3, totalRooms);
            ps.setBoolean(4, isActive);
            
            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.out.println("Error in addNewCinema: " + e);
            return false;
        }
    }

    // Update cinema
    public boolean updateCinema(int cinemaID, String cinemaName, String location, int totalRooms, boolean isActive) {
        String sql = "UPDATE [dbo].[Cinemas]\n"
                + "   SET [CinemaName] = ?\n"
                + "      ,[Location] = ?\n"
                + "      ,[TotalRooms] = ?\n"
                + "      ,[IsActive] = ?\n"
                + " WHERE [CinemaID] = ?";

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setString(1, cinemaName);
            ps.setString(2, location);
            ps.setInt(3, totalRooms);
            ps.setBoolean(4, isActive);
            ps.setInt(5, cinemaID);
            
            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.out.println("Error in updateCinema: " + e);
            return false;
        }
    }

    // Delete cinema (soft delete - set IsActive = false)
    public boolean deleteCinema(int cinemaID) {
        String sql = "UPDATE [dbo].[Cinemas]\n"
                + "   SET [IsActive] = 0\n"
                + " WHERE [CinemaID] = ?";

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, cinemaID);
            
            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.out.println("Error in deleteCinema: " + e);
            return false;
        }
    }

    // ============ FILTER AND SORT ============

    // Get all cinemas with filter and sort (không phân trang)
    public List<Cinema> getAllCinemas(String search, String statusFilter, String sortBy) {
        List<Cinema> list = new ArrayList<>();
        
        String sql = "SELECT [CinemaID]\n"
                + "      ,[CinemaName]\n"
                + "      ,[Location]\n"
                + "      ,[TotalRooms]\n"
                + "      ,[IsActive]\n"
                + "      ,[CreatedDate]\n"
                + "  FROM [dbo].[Cinemas]\n"
                + "  WHERE 1=1";

        // Thêm điều kiện search
        if (search != null && !search.trim().isEmpty()) {
            sql += " AND ([CinemaName] LIKE ? OR [Location] LIKE ?)";
        }

        // Thêm điều kiện filter status
        if (statusFilter != null && !statusFilter.equals("all")) {
            if (statusFilter.equals("active")) {
                sql += " AND [IsActive] = 1";
            } else if (statusFilter.equals("inactive")) {
                sql += " AND [IsActive] = 0";
            }
        }

        // Thêm điều kiện sort
        if (sortBy != null) {
            switch (sortBy) {
                case "name_asc" ->
                    sql += " ORDER BY [CinemaName] ASC";
                case "name_desc" ->
                    sql += " ORDER BY [CinemaName] DESC";
                case "rooms_asc" ->
                    sql += " ORDER BY [TotalRooms] ASC";
                case "rooms_desc" ->
                    sql += " ORDER BY [TotalRooms] DESC";
                case "date_asc" ->
                    sql += " ORDER BY [CreatedDate] ASC";
                case "date_desc" ->
                    sql += " ORDER BY [CreatedDate] DESC";
                default ->
                    sql += " ORDER BY [CinemaName] ASC";
            }
        } else {
            sql += " ORDER BY [CinemaName] ASC";
        }

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            int paramIndex = 1;

            // Set parameters cho search
            if (search != null && !search.trim().isEmpty()) {
                String searchPattern = "%" + search + "%";
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
            }

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(new Cinema(
                        rs.getInt("CinemaID"),
                        rs.getString("CinemaName"),
                        rs.getString("Location"),
                        rs.getInt("TotalRooms"),
                        rs.getBoolean("IsActive"),
                        toLocalDateTime(rs.getTimestamp("CreatedDate"))
                ));
            }
        } catch (SQLException e) {
            System.out.println("Error in getAllCinemas with filters: " + e);
        }
        return list;
    }

    // Count total cinemas (có thể dùng cho phân trang ở servlet sau này)
    public int countCinemas(String search, String statusFilter) {
        String sql = "SELECT COUNT(*) as Total\n"
                + "  FROM [dbo].[Cinemas]\n"
                + "  WHERE 1=1";

        // Thêm điều kiện search
        if (search != null && !search.trim().isEmpty()) {
            sql += " AND ([CinemaName] LIKE ? OR [Location] LIKE ?)";
        }

        // Thêm điều kiện filter status
        if (statusFilter != null && !statusFilter.equals("all")) {
            if (statusFilter.equals("active")) {
                sql += " AND [IsActive] = 1";
            } else if (statusFilter.equals("inactive")) {
                sql += " AND [IsActive] = 0";
            }
        }

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            int paramIndex = 1;

            // Set parameters cho search
            if (search != null && !search.trim().isEmpty()) {
                String searchPattern = "%" + search + "%";
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
            }

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("Total");
            }
        } catch (SQLException e) {
            System.out.println("Error in countCinemas: " + e);
        }
        return 0;
    }

    // ============ ADDITIONAL BUSINESS LOGIC ============

    // Get active cinemas only (for dropdowns, etc.)
    public List<Cinema> getActiveCinemas() {
        List<Cinema> list = new ArrayList<>();
        String sql = "SELECT [CinemaID]\n"
                + "      ,[CinemaName]\n"
                + "      ,[Location]\n"
                + "      ,[TotalRooms]\n"
                + "      ,[IsActive]\n"
                + "      ,[CreatedDate]\n"
                + "  FROM [dbo].[Cinemas]\n"
                + "  WHERE [IsActive] = 1\n"
                + "  ORDER BY [CinemaName] ASC";

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(new Cinema(
                        rs.getInt("CinemaID"),
                        rs.getString("CinemaName"),
                        rs.getString("Location"),
                        rs.getInt("TotalRooms"),
                        rs.getBoolean("IsActive"),
                        toLocalDateTime(rs.getTimestamp("CreatedDate"))
                ));
            }
        } catch (SQLException e) {
            System.out.println("Error in getActiveCinemas: " + e);
        }
        return list;
    }

    // Check if cinema name already exists (for validation)
    public boolean checkCinemaNameExists(String cinemaName) {
        String sql = "SELECT 1 FROM [dbo].[Cinemas] WHERE [CinemaName] = ?";
        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setString(1, cinemaName);
            ResultSet rs = ps.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            System.out.println("Error in checkCinemaNameExists: " + e);
            return false;
        }
    }

    // Check if cinema name exists excluding current cinema (for update)
    public boolean checkCinemaNameExists(String cinemaName, int excludeCinemaID) {
        String sql = "SELECT 1 FROM [dbo].[Cinemas] WHERE [CinemaName] = ? AND [CinemaID] != ?";
        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setString(1, cinemaName);
            ps.setInt(2, excludeCinemaID);
            ResultSet rs = ps.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            System.out.println("Error in checkCinemaNameExists: " + e);
            return false;
        }
    }

    // Toggle cinema status (active/inactive)
    public boolean toggleCinemaStatus(int cinemaID, boolean isActive) {
        String sql = "UPDATE [dbo].[Cinemas]\n"
                + "   SET [IsActive] = ?\n"
                + " WHERE [CinemaID] = ?";

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setBoolean(1, isActive);
            ps.setInt(2, cinemaID);
            
            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.out.println("Error in toggleCinemaStatus: " + e);
            return false;
        }
    }
}
