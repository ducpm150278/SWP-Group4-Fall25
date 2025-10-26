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
    private ScreeningRoomDAO screeningRoomDAO = new ScreeningRoomDAO();

    // Test function
    public static void main(String[] args) {
        CinemaDAO cinemaDAO = new CinemaDAO();

        // Test get all cinemas
        System.out.println("=== All Cinemas ===");
        List<Cinema> cinemas = cinemaDAO.getAllCinemas();
        for (Cinema cinema : cinemas) {
            System.out.println(cinema);
        }
        System.out.println("Total cinemas: " + cinemas.size());
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
    // Get all cinemas - TỐI ƯU HÓA: lấy tất cả trong một query
    public List<Cinema> getAllCinemas() {
        List<Cinema> list = new ArrayList<>();
        
        // Query lấy tất cả cinemas và số lượng phòng trong một lần
        String sql = "SELECT c.[CinemaID], c.[CinemaName], c.[Location], "
                   + "c.[IsActive], c.[CreatedDate], "
                   + "COUNT(sr.RoomID) as TotalRooms "
                   + "FROM [dbo].[Cinemas] c "
                   + "LEFT JOIN [dbo].[ScreeningRooms] sr ON c.CinemaID = sr.CinemaID AND sr.IsActive = 1 "
                   + "GROUP BY c.[CinemaID], c.[CinemaName], c.[Location], c.[IsActive], c.[CreatedDate] "
                   + "ORDER BY c.[CinemaName] ASC";

        try (Connection conn = db.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Cinema cinema = new Cinema(
                    rs.getInt("CinemaID"),
                    rs.getString("CinemaName"),
                    rs.getString("Location"),
                    null,  // Address column doesn't exist in database
                    rs.getBoolean("IsActive"),
                    toLocalDateTime(rs.getTimestamp("CreatedDate"))
                );
                
                // Set total rooms từ kết quả query
                cinema.setTotalRooms(rs.getInt("TotalRooms"));
                
                list.add(cinema);
            }
        } catch (SQLException e) {
            System.out.println("Error in getAllCinemas: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    // Get cinema by ID
    public Cinema getCinemaById(int cinemaId) {
        Cinema cinema = null;
        String sql = "SELECT CinemaID, CinemaName, Location, IsActive, CreatedDate FROM Cinemas WHERE CinemaID = ?";

        try (Connection conn = db.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, cinemaId);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                cinema = new Cinema();
                cinema.setCinemaID(rs.getInt("CinemaID"));
                cinema.setCinemaName(rs.getString("CinemaName"));
                cinema.setLocation(rs.getString("Location"));
                cinema.setAddress(null);  // Address column doesn't exist in database
                cinema.setActive(rs.getBoolean("IsActive"));
                cinema.setCreatedDate(toLocalDateTime(rs.getTimestamp("CreatedDate")));

                // Lấy danh sách phòng chiếu
                List<ScreeningRoom> rooms = screeningRoomDAO.getScreeningRoomsByCinemaId(cinemaId);
                cinema.setScreeningRooms(rooms);
                
                // Tính totalRooms
                cinema.setTotalRooms(cinema.calculateTotalRooms());
            }
        } catch (SQLException e) {
            System.out.println("Error in getCinemaById: " + e.getMessage());
        }
        return cinema;
    }

    // Add new cinema
    public boolean addCinema(Cinema cinema) {
        String sql = "INSERT INTO Cinemas (CinemaName, Location, IsActive) VALUES (?, ?, ?)";
        
        try (Connection conn = db.getConnection();
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
            System.out.println("Error in addCinema: " + e.getMessage());
        }
        return false;
    }

    // Update cinema
    public boolean updateCinema(int cinemaID, String cinemaName, String location, String address, boolean isActive) {
        String sql = "UPDATE [dbo].[Cinemas]\n"
                + "   SET [CinemaName] = ?\n"
                + "      ,[Location] = ?\n"
                + "      ,[IsActive] = ?\n"
                + " WHERE [CinemaID] = ?";

        try (Connection conn = db.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, cinemaName);
            ps.setString(2, location);
            ps.setBoolean(3, isActive);
            ps.setInt(4, cinemaID);

            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.out.println("Error in updateCinema: " + e.getMessage());
            return false;
        }
    }

    // Delete cinema (soft delete - set IsActive = false)
    public boolean deleteCinema(int cinemaID) {
        String sql = "UPDATE [dbo].[Cinemas]\n"
                + "   SET [IsActive] = 0\n"
                + " WHERE [CinemaID] = ?";

        try (Connection conn = db.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, cinemaID);

            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.out.println("Error in deleteCinema: " + e.getMessage());
            return false;
        }
    }

        // Delete cinema (hard delete - set IsActive = false)
    public boolean deleteH_Cinema(int cinemaID) {
        String sql = "DELETE FROM [dbo].[Cinemas] WHERE [CinemaID] = ?";
        try (Connection conn = db.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)){
            ps.setInt(1, cinemaID);
            ps.executeUpdate();
            return true;
        } catch (SQLException e) {
            System.out.println(e);
            return false;
        }
    }
    
    // ============ FILTER AND SORT ============
    // Get all cinemas with filter and sort
    public List<Cinema> getAllCinemas(String search, String statusFilter, String locationFilter, String sortBy) {
        List<Cinema> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT c.[CinemaID], c.[CinemaName], c.[Location], ")
           .append("c.[IsActive], c.[CreatedDate], ")
           .append("COUNT(sr.RoomID) as TotalRooms ")
           .append("FROM [dbo].[Cinemas] c ")
           .append("LEFT JOIN [dbo].[ScreeningRooms] sr ON c.CinemaID = sr.CinemaID AND sr.IsActive = 1 ")
           .append("WHERE 1=1");

        // Thêm điều kiện search
        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (c.[CinemaName] LIKE ? OR c.[Location] LIKE ?)");
        }

        // Thêm điều kiện filter status
        if (statusFilter != null && !statusFilter.equals("all")) {
            if (statusFilter.equals("active")) {
                sql.append(" AND c.[IsActive] = 1");
            } else if (statusFilter.equals("inactive")) {
                sql.append(" AND c.[IsActive] = 0");
            }
        }

        // Thêm điều kiện filter location
        if (locationFilter != null && !locationFilter.equals("all")) {
            sql.append(" AND c.[Location] = ?");
        }

        sql.append(" GROUP BY c.[CinemaID], c.[CinemaName], c.[Location], c.[IsActive], c.[CreatedDate]");

        // Thêm điều kiện sort
        if (sortBy != null) {
            switch (sortBy) {
                case "name_asc" -> sql.append(" ORDER BY c.[CinemaName] ASC");
                case "name_desc" -> sql.append(" ORDER BY c.[CinemaName] DESC");
                case "rooms_asc" -> sql.append(" ORDER BY TotalRooms ASC");
                case "rooms_desc" -> sql.append(" ORDER BY TotalRooms DESC");
                case "date_asc" -> sql.append(" ORDER BY c.[CreatedDate] ASC");
                case "date_desc" -> sql.append(" ORDER BY c.[CreatedDate] DESC");
                case "location_asc" -> sql.append(" ORDER BY c.[Location] ASC");
                case "location_desc" -> sql.append(" ORDER BY c.[Location] DESC");
                default -> sql.append(" ORDER BY c.[CinemaName] ASC");
            }
        } else {
            sql.append(" ORDER BY c.[CinemaName] ASC");
        }

        try (Connection conn = db.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            int paramIndex = 1;

            // Set parameters cho search
            if (search != null && !search.trim().isEmpty()) {
                String searchPattern = "%" + search + "%";
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
            }

            // Set parameter cho location filter
            if (locationFilter != null && !locationFilter.equals("all")) {
                ps.setString(paramIndex++, locationFilter);
            }

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Cinema cinema = new Cinema(
                    rs.getInt("CinemaID"),
                    rs.getString("CinemaName"),
                    rs.getString("Location"),
                    null,  // Address column doesn't exist in database
                    rs.getBoolean("IsActive"),
                    toLocalDateTime(rs.getTimestamp("CreatedDate"))
                );
                
                // Set total rooms từ kết quả query
                cinema.setTotalRooms(rs.getInt("TotalRooms"));
                
                list.add(cinema);
            }
        } catch (SQLException e) {
            System.out.println("Error in getAllCinemas with filters: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    // Count total cinemas
    public int countCinemas(String search, String statusFilter, String locationFilter) {
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

        // Thêm điều kiện filter location
        if (locationFilter != null && !locationFilter.equals("all")) {
            sql += " AND [Location] = ?";
        }

        try (Connection conn = db.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            int paramIndex = 1;

            // Set parameters cho search
            if (search != null && !search.trim().isEmpty()) {
                String searchPattern = "%" + search + "%";
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
            }

            // Set parameter cho location filter
            if (locationFilter != null && !locationFilter.equals("all")) {
                ps.setString(paramIndex++, locationFilter);
            }

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("Total");
            }
        } catch (SQLException e) {
            System.out.println("Error in countCinemas: " + e.getMessage());
        }
        return 0;
    }

    // ============ ADDITIONAL BUSINESS LOGIC ============
    // Get active cinemas only
    public List<Cinema> getActiveCinemas() {
        List<Cinema> list = new ArrayList<>();
        String sql = "SELECT c.[CinemaID], c.[CinemaName], c.[Location], "
                   + "c.[IsActive], c.[CreatedDate], "
                   + "COUNT(sr.RoomID) as TotalRooms "
                   + "FROM [dbo].[Cinemas] c "
                   + "LEFT JOIN [dbo].[ScreeningRooms] sr ON c.CinemaID = sr.CinemaID AND sr.IsActive = 1 "
                   + "WHERE c.[IsActive] = 1 "
                   + "GROUP BY c.[CinemaID], c.[CinemaName], c.[Location], c.[IsActive], c.[CreatedDate] "
                   + "ORDER BY c.[CinemaName] ASC";

        try (Connection conn = db.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Cinema cinema = new Cinema(
                    rs.getInt("CinemaID"),
                    rs.getString("CinemaName"),
                    rs.getString("Location"),
                    null,  // Address column doesn't exist in database
                    rs.getBoolean("IsActive"),
                    toLocalDateTime(rs.getTimestamp("CreatedDate"))
                );
                
                cinema.setTotalRooms(rs.getInt("TotalRooms"));
                list.add(cinema);
            }
        } catch (SQLException e) {
            System.out.println("Error in getActiveCinemas: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    // Get all distinct locations
    public List<String> getAllLocations() {
        List<String> locations = new ArrayList<>();
        String sql = "SELECT DISTINCT [Location] FROM [dbo].[Cinemas] ORDER BY [Location] ASC";

        try (Connection conn = db.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                locations.add(rs.getString("Location"));
            }
        } catch (SQLException e) {
            System.out.println("Error in getAllLocations: " + e.getMessage());
        }
        return locations;
    }

    // Check if cinema name already exists (for validation)
    public boolean checkCinemaNameExists(String cinemaName) {
        String sql = "SELECT 1 FROM [dbo].[Cinemas] WHERE [CinemaName] = ?";
        try (Connection conn = db.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, cinemaName);
            ResultSet rs = ps.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            System.out.println("Error in checkCinemaNameExists: " + e.getMessage());
            return false;
        }
    }

    // Check if cinema name exists excluding current cinema (for update)
    public boolean checkCinemaNameExists(String cinemaName, int excludeCinemaID) {
        String sql = "SELECT 1 FROM [dbo].[Cinemas] WHERE [CinemaName] = ? AND [CinemaID] != ?";
        try (Connection conn = db.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, cinemaName);
            ps.setInt(2, excludeCinemaID);
            ResultSet rs = ps.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            System.out.println("Error in checkCinemaNameExists: " + e.getMessage());
            return false;
        }
    }

    // Toggle cinema status (active/inactive)
    public boolean toggleCinemaStatus(int cinemaID, boolean isActive) {
        String sql = "UPDATE [dbo].[Cinemas]\n"
                + "   SET [IsActive] = ?\n"
                + " WHERE [CinemaID] = ?";

        try (Connection conn = db.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setBoolean(1, isActive);
            ps.setInt(2, cinemaID);

            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.out.println("Error in toggleCinemaStatus: " + e.getMessage());
            return false;
        }
    }

    // Get cinemas by location
    public List<Cinema> getCinemasByLocation(String location) {
        List<Cinema> list = new ArrayList<>();
        String sql = "SELECT c.[CinemaID], c.[CinemaName], c.[Location], "
                   + "c.[IsActive], c.[CreatedDate], "
                   + "COUNT(sr.RoomID) as TotalRooms "
                   + "FROM [dbo].[Cinemas] c "
                   + "LEFT JOIN [dbo].[ScreeningRooms] sr ON c.CinemaID = sr.CinemaID AND sr.IsActive = 1 "
                   + "WHERE c.[Location] = ? AND c.[IsActive] = 1 "
                   + "GROUP BY c.[CinemaID], c.[CinemaName], c.[Location], c.[IsActive], c.[CreatedDate] "
                   + "ORDER BY c.[CinemaName] ASC";

        try (Connection conn = db.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, location);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Cinema cinema = new Cinema(
                    rs.getInt("CinemaID"),
                    rs.getString("CinemaName"),
                    rs.getString("Location"),
                    null,  // Address column doesn't exist in database
                    rs.getBoolean("IsActive"),
                    toLocalDateTime(rs.getTimestamp("CreatedDate"))
                );
                
                cinema.setTotalRooms(rs.getInt("TotalRooms"));
                list.add(cinema);
            }
        } catch (SQLException e) {
            System.out.println("Error in getCinemasByLocation: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }
}