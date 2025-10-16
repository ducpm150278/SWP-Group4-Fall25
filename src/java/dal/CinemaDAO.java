package dal;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.sql.Statement; 
import entity.Cinema;
import entity.ScreeningRoom;

/**
 *
 * @author dungv
 */
public class CinemaDAO {

    DBContext db = new DBContext();
    protected Connection connection = db.connection;
    private ScreeningRoomDAO screeningRoomDAO = new ScreeningRoomDAO();

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
    public Cinema getCinemaById(int cinemaId) {
        Cinema cinema = null;
        String sql = "SELECT CinemaID, CinemaName, Location, TotalRooms, IsActive, CreatedDate FROM Cinemas WHERE CinemaID = ?";

        try (Connection conn = db.connection; PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, cinemaId);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                cinema = new Cinema();
                cinema.setCinemaID(rs.getInt("CinemaID"));
                cinema.setCinemaName(rs.getString("CinemaName"));
                cinema.setLocation(rs.getString("Location"));
                cinema.setTotalRooms(rs.getInt("TotalRooms"));
                cinema.setActive(rs.getBoolean("IsActive"));
                cinema.setCreatedDate(rs.getTimestamp("CreatedDate").toLocalDateTime());

                // Lấy danh sách phòng chiếu
                List<ScreeningRoom> rooms = screeningRoomDAO.getScreeningRoomsByCinemaId(cinemaId);
                cinema.setScreeningRooms(rooms);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return cinema;
    }

    // Add new cinema
    public boolean addCinema(Cinema cinema) {
        String sql = "INSERT INTO Cinemas (CinemaName, Location, IsActive) VALUES (?, ?, ?)";
        
        try (Connection conn = db.connection;
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setString(1, cinema.getCinemaName());
            stmt.setString(2, cinema.getLocation());
            stmt.setBoolean(3, cinema.isActive());
            
            int affectedRows = stmt.executeUpdate();
            
            if (affectedRows > 0) {
                try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        cinema.setCinemaID(generatedKeys.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
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
    // Get all cinemas with filter and sort
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

    // Count total cinemas
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
    // Get active cinemas only
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
