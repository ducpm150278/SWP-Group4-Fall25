package com.cinema.dal;


import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.sql.Statement; 
import com.cinema.entity.CinemaM;
import com.cinema.entity.ScreeningRoom;

/**
 *
 * @author dungv
 */
public class CinemaMDAO {

    DBContext db = new DBContext();
    private final ScreeningRoomDAO screeningRoomDAO = new ScreeningRoomDAO();

    // Test function
    public static void main(String[] args) {
        CinemaMDAO cinemaDAO = new CinemaMDAO();

        System.out.println(cinemaDAO.getAllLocations());
        // Test get all cinemas
        System.out.println("=== All Cinemas ===");
        List<CinemaM> cinemas = cinemaDAO.getAllCinemas();
        for (CinemaM cinema : cinemas) {
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

    // Helper method: Map ResultSet to Cinema object
    private CinemaM mapResultSetToCinema(ResultSet rs) throws SQLException {
        CinemaM cinema = new CinemaM(
            rs.getInt("CinemaID"),
            rs.getString("CinemaName"),
            rs.getString("Location"),
            rs.getString("Address"),
            rs.getBoolean("IsActive"),
            toLocalDateTime(rs.getTimestamp("CreatedDate"))
        );
        
        // Set total rooms từ kết quả query (nếu có)
        try {
            cinema.setTotalRooms(rs.getInt("TotalRooms"));
        } catch (SQLException e) {
            // Nếu không có column TotalRooms, tính sau
            cinema.setTotalRooms(0);
        }
        
        return cinema;
    }

    // ============ CRUD OPERATIONS ============
    // Get all cinemas 
    public List<CinemaM> getAllCinemas() {
        List<CinemaM> list = new ArrayList<>();
        
        // Query lấy tất cả cinemas và số lượng phòng trong một lần
        String sql = "SELECT c.[CinemaID], c.[CinemaName], c.[Location], c.[Address], "
                   + "c.[IsActive], c.[CreatedDate], "
                   + "COUNT(sr.RoomID) as TotalRooms " 
                   + "FROM [dbo].[Cinemas] c "
                   + "LEFT JOIN [dbo].[ScreeningRooms] sr ON c.CinemaID = sr.CinemaID AND sr.IsActive = 1 "
                   + "GROUP BY c.[CinemaID], c.[CinemaName], c.[Location], c.[Address], c.[IsActive], c.[CreatedDate] "
                   + "ORDER BY c.[CinemaName] ASC";

        try (Connection conn = db.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                list.add(mapResultSetToCinema(rs));
            }
        } catch (SQLException e) {
            System.out.println("Error in getAllCinemas: " + e.getMessage());
        }
        return list;
    }

    // Get cinema by ID
    public CinemaM getCinemaById(int cinemaId) {
        CinemaM cinema = null;
        String sql = "SELECT CinemaID, CinemaName, Location, Address, IsActive, CreatedDate FROM Cinemas WHERE CinemaID = ?";

        try (Connection conn = db.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, cinemaId);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                cinema = new CinemaM();
                cinema.setCinemaID(rs.getInt("CinemaID"));
                cinema.setCinemaName(rs.getString("CinemaName"));
                cinema.setLocation(rs.getString("Location"));
                cinema.setAddress(rs.getString("Address"));
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
    public boolean addCinema(CinemaM cinema) {
        String sql = "INSERT INTO Cinemas (CinemaName, Location, Address, IsActive) VALUES (?, ?, ?, ?)";
        
        try (Connection conn = db.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setString(1, cinema.getCinemaName());
            stmt.setString(2, cinema.getLocation());
            stmt.setString(3, cinema.getAddress());
            stmt.setBoolean(4, cinema.isActive());
            
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

    // Update cinema - Overload version nhận Cinema object
    public boolean updateCinema(CinemaM cinema) {
        String sql = """
                     UPDATE [dbo].[Cinemas]
                        SET [CinemaName] = ?
                           ,[Location] = ?
                           ,[Address] = ?
                           ,[IsActive] = ?
                      WHERE [CinemaID] = ?""";

        try (Connection conn = db.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, cinema.getCinemaName());
            ps.setString(2, cinema.getLocation());
            ps.setString(3, cinema.getAddress());
            ps.setBoolean(4, cinema.isActive());
            ps.setInt(5, cinema.getCinemaID());

            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.out.println("Error in updateCinema: " + e.getMessage());
            return false;
        }
    }

    // Update cinema - Giữ nguyên version cũ cho compatibility
    public boolean updateCinema(int cinemaID, String cinemaName, String location, String address, boolean isActive) {
        CinemaM cinema = new CinemaM();
        cinema.setCinemaID(cinemaID);
        cinema.setCinemaName(cinemaName);
        cinema.setLocation(location);
        cinema.setAddress(address);
        cinema.setActive(isActive);
        
        return updateCinema(cinema);
    }

    // Delete cinema (soft delete - set IsActive = false)
    public boolean deleteCinema(int cinemaID) {
        String sql = """
                     UPDATE [dbo].[Cinemas]
                        SET [IsActive] = 0
                      WHERE [CinemaID] = ?""";

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

    // Delete cinema (hard delete)
    public boolean deleteH_Cinema(int cinemaID) {
        String sql = "DELETE FROM [dbo].[Cinemas] WHERE [CinemaID] = ?";
        try (Connection conn = db.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)){
            ps.setInt(1, cinemaID);
            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.out.println("Error in deleteH_Cinema: " + e.getMessage());
            return false;
        }
    }
    
    // ============ FILTER AND SORT ============
    // Get all cinemas with filter and sort
    public List<CinemaM> getAllCinemas(String search, String statusFilter, String locationFilter, String sortBy) {
        List<CinemaM> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT c.[CinemaID], c.[CinemaName], c.[Location], c.[Address], ")
           .append("c.[IsActive], c.[CreatedDate], ")
           .append("COUNT(sr.RoomID) as TotalRooms ")
           .append("FROM [dbo].[Cinemas] c ")
           .append("LEFT JOIN [dbo].[ScreeningRooms] sr ON c.CinemaID = sr.CinemaID AND sr.IsActive = 1 ")
           .append("WHERE 1=1");

        List<Object> params = new ArrayList<>();

        // Thêm điều kiện search
        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (c.[CinemaName] LIKE ? OR c.[Address] LIKE ?)");
            String searchPattern = "%" + search.trim() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
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
            params.add(locationFilter);
        }

        sql.append(" GROUP BY c.[CinemaID], c.[CinemaName], c.[Location], c.[Address], c.[IsActive], c.[CreatedDate]");

        // Thêm điều kiện sort
        sql.append(getOrderByClause(sortBy));

        try (Connection conn = db.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            // Set parameters
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToCinema(rs));
            }
        } catch (SQLException e) {
            System.out.println("Error in getAllCinemas with filters: " + e.getMessage());
        }
        return list;
    }

    // Helper method for ORDER BY clause
    private String getOrderByClause(String sortBy) {
        if (sortBy != null) {
            switch (sortBy) {
                case "name_asc" -> { return " ORDER BY c.[CinemaName] ASC"; }
                case "name_desc" -> { return " ORDER BY c.[CinemaName] DESC"; }
                case "rooms_asc" -> { return " ORDER BY TotalRooms ASC"; }
                case "rooms_desc" -> { return " ORDER BY TotalRooms DESC"; }
                case "date_asc" -> { return " ORDER BY c.[CreatedDate] ASC"; }
                case "date_desc" -> { return " ORDER BY c.[CreatedDate] DESC"; }
                case "location_asc" -> { return " ORDER BY c.[Location] ASC"; }
                case "location_desc" -> { return " ORDER BY c.[Location] DESC"; }
            }
        }
        return " ORDER BY c.[CinemaName] ASC";
    }

    // Count total cinemas
    public int countCinemas(String search, String statusFilter, String locationFilter) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) as Total FROM [dbo].[Cinemas] WHERE 1=1");
        List<Object> params = new ArrayList<>();

        // Thêm điều kiện search
        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND ([CinemaName] LIKE ? OR [Address] LIKE ?)");
            String searchPattern = "%" + search.trim() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
        }

        // Thêm điều kiện filter status
        if (statusFilter != null && !statusFilter.equals("all")) {
            if (statusFilter.equals("active")) {
                sql.append(" AND [IsActive] = 1");
            } else if (statusFilter.equals("inactive")) {
                sql.append(" AND [IsActive] = 0");
            }
        }

        // Thêm điều kiện filter location
        if (locationFilter != null && !locationFilter.equals("all")) {
            sql.append(" AND [Location] = ?");
            params.add(locationFilter);
        }

        try (Connection conn = db.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            // Set parameters
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
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

    // Get active cinemas only
    public List<CinemaM> getActiveCinemas() {
        List<CinemaM> list = new ArrayList<>();
        String sql = "SELECT c.[CinemaID], c.[CinemaName], c.[Location], c.[Address], "
                   + "c.[IsActive], c.[CreatedDate], "
                   + "COUNT(sr.RoomID) as TotalRooms "
                   + "FROM [dbo].[Cinemas] c "
                   + "LEFT JOIN [dbo].[ScreeningRooms] sr ON c.CinemaID = sr.CinemaID AND sr.IsActive = 1 "
                   + "WHERE c.[IsActive] = 1 "
                   + "GROUP BY c.[CinemaID], c.[CinemaName], c.[Location], c.[Address], c.[IsActive], c.[CreatedDate] "
                   + "ORDER BY c.[CinemaName] ASC";

        try (Connection conn = db.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                list.add(mapResultSetToCinema(rs));
            }
        } catch (SQLException e) {
            System.out.println("Error in getActiveCinemas: " + e.getMessage());
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
        String sql = "UPDATE [dbo].[Cinemas] SET [IsActive] = ? WHERE [CinemaID] = ?";

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
    public List<CinemaM> getCinemasByLocation(String location) {
        List<CinemaM> list = new ArrayList<>();
        String sql = "SELECT c.[CinemaID], c.[CinemaName], c.[Location], c.[Address], "
                   + "c.[IsActive], c.[CreatedDate], "
                   + "COUNT(sr.RoomID) as TotalRooms "
                   + "FROM [dbo].[Cinemas] c "
                   + "LEFT JOIN [dbo].[ScreeningRooms] sr ON c.CinemaID = sr.CinemaID AND sr.IsActive = 1 "
                   + "WHERE c.[Location] = ? AND c.[IsActive] = 1 "
                   + "GROUP BY c.[CinemaID], c.[CinemaName], c.[Location], c.[Address], c.[IsActive], c.[CreatedDate] "
                   + "ORDER BY c.[CinemaName] ASC";

        try (Connection conn = db.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, location);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                list.add(mapResultSetToCinema(rs));
            }
        } catch (SQLException e) {
            System.out.println("Error in getCinemasByLocation: " + e.getMessage());
        }
        return list;
    }
}