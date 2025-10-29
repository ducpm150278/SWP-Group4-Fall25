package dal;

import entity.Booking;
import entity.BookingDetailDTO;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for Booking operations
 */
public class BookingDAO extends DBContext {
    
    /**
     * Create a new booking and return the generated BookingID
     */
    public int createBooking(Booking booking) {
        // CRITICAL: Column order MUST match database schema!
        // Schema order: PaymentMethod, PaymentDate, Notes, TransactionID
        String sql = "INSERT INTO Bookings (BookingCode, UserID, ScreeningID, BookingDate, " +
                     "TotalAmount, DiscountAmount, FinalAmount, Status, PaymentStatus, " +
                     "PaymentMethod, PaymentDate, Notes, TransactionID) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        System.out.println("BookingDAO: Creating booking...");
        System.out.println("  BookingCode: " + booking.getBookingCode());
        System.out.println("  UserID: " + booking.getUserID());
        System.out.println("  ScreeningID: " + booking.getScreeningID());
        System.out.println("  TotalAmount: " + booking.getTotalAmount());
        System.out.println("  FinalAmount: " + booking.getFinalAmount());
        System.out.println("  Notes: " + booking.getNotes());
        System.out.println("  TransactionID: " + booking.getTransactionID());
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setString(1, booking.getBookingCode());
            ps.setInt(2, booking.getUserID());
            ps.setInt(3, booking.getScreeningID());
            ps.setTimestamp(4, Timestamp.valueOf(booking.getBookingDate()));
            ps.setDouble(5, booking.getTotalAmount());
            ps.setDouble(6, booking.getDiscountAmount());
            ps.setDouble(7, booking.getFinalAmount());
            ps.setString(8, booking.getStatus());
            ps.setString(9, booking.getPaymentStatus());
            ps.setString(10, booking.getPaymentMethod());
            
            // Position 11: PaymentDate
            if (booking.getPaymentDate() != null) {
                ps.setTimestamp(11, Timestamp.valueOf(booking.getPaymentDate()));
            } else {
                ps.setNull(11, Types.TIMESTAMP);
            }
            
            // Position 12: Notes (BEFORE TransactionID in schema!)
            if (booking.getNotes() != null && !booking.getNotes().isEmpty()) {
                ps.setString(12, booking.getNotes());
            } else {
                ps.setNull(12, Types.NVARCHAR);
            }
            
            // Position 13: TransactionID (AFTER Notes in schema!)
            if (booking.getTransactionID() != null && !booking.getTransactionID().isEmpty()) {
                ps.setString(13, booking.getTransactionID());
            } else {
                ps.setNull(13, Types.NVARCHAR);
            }
            
            int affectedRows = ps.executeUpdate();
            
            if (affectedRows > 0) {
                ResultSet rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    int bookingID = rs.getInt(1);
                    System.out.println("✓ Created booking with ID: " + bookingID);
                    return bookingID;
                }
            }
            
        } catch (SQLException e) {
            System.err.println("=== ERROR creating booking ===");
            System.err.println("SQL State: " + e.getSQLState());
            System.err.println("Error Code: " + e.getErrorCode());
            System.err.println("Message: " + e.getMessage());
            e.printStackTrace();
        }
        
        return -1;
    }
    
    /**
     * Update booking status
     */
    public boolean updateBookingStatus(int bookingID, String status) {
        String sql = "UPDATE Bookings SET Status = ? WHERE BookingID = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, status);
            ps.setInt(2, bookingID);
            
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.err.println("Error updating booking status: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Update booking payment status
     */
    public boolean updatePaymentStatus(int bookingID, String paymentStatus, LocalDateTime paymentDate) {
        String sql = "UPDATE Bookings SET PaymentStatus = ?, PaymentDate = ? WHERE BookingID = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, paymentStatus);
            if (paymentDate != null) {
                ps.setTimestamp(2, Timestamp.valueOf(paymentDate));
            } else {
                ps.setNull(2, Types.TIMESTAMP);
            }
            ps.setInt(3, bookingID);
            
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.err.println("Error updating payment status: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Generate unique booking code
     */
    public String generateBookingCode() {
        String prefix = "BK";
        String timestamp = String.format("%tY%<tm%<td%<tH%<tM", System.currentTimeMillis());
        int random = (int) (Math.random() * 90000) + 10000; // 5 digit random
        
        String bookingCode = prefix + timestamp + random;
        
        // Check if exists and regenerate if needed
        while (bookingCodeExists(bookingCode)) {
            random = (int) (Math.random() * 90000) + 10000;
            bookingCode = prefix + timestamp + random;
        }
        
        System.out.println("Generated booking code: " + bookingCode);
        return bookingCode;
    }
    
    /**
     * Check if booking code exists
     */
    private boolean bookingCodeExists(String bookingCode) {
        String sql = "SELECT COUNT(*) FROM Bookings WHERE BookingCode = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, bookingCode);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
            
        } catch (SQLException e) {
            System.err.println("Error checking booking code: " + e.getMessage());
        }
        
        return false;
    }
    
    /**
     * Get booking by ID
     */
    public Booking getBookingByID(int bookingID) {
        String sql = "SELECT * FROM Bookings WHERE BookingID = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, bookingID);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return extractBookingFromResultSet(rs);
            }
            
        } catch (SQLException e) {
            System.err.println("Error getting booking: " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * Extract Booking object from ResultSet
     */
    private Booking extractBookingFromResultSet(ResultSet rs) throws SQLException {
        Booking booking = new Booking();
        booking.setBookingID(rs.getInt("BookingID"));
        booking.setBookingCode(rs.getString("BookingCode"));
        booking.setUserID(rs.getInt("UserID"));
        booking.setScreeningID(rs.getInt("ScreeningID"));
        booking.setBookingDate(rs.getTimestamp("BookingDate").toLocalDateTime());
        booking.setTotalAmount(rs.getDouble("TotalAmount"));
        booking.setDiscountAmount(rs.getDouble("DiscountAmount"));
        booking.setFinalAmount(rs.getDouble("FinalAmount"));
        booking.setStatus(rs.getString("Status"));
        booking.setPaymentStatus(rs.getString("PaymentStatus"));
        booking.setPaymentMethod(rs.getString("PaymentMethod"));
        
        Timestamp paymentDate = rs.getTimestamp("PaymentDate");
        if (paymentDate != null) {
            booking.setPaymentDate(paymentDate.toLocalDateTime());
        }
        
        booking.setTransactionID(rs.getString("TransactionID"));
        booking.setNotes(rs.getString("Notes"));
        
        return booking;
    }
    
    /**
     * Get all bookings for a user (ordered by booking date, most recent first)
     */
    public java.util.List<Booking> getUserBookings(int userID) {
        java.util.List<Booking> bookings = new java.util.ArrayList<>();
        String sql = "SELECT * FROM Bookings WHERE UserID = ? ORDER BY BookingDate DESC";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, userID);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                bookings.add(extractBookingFromResultSet(rs));
            }
            
        } catch (SQLException e) {
            System.err.println("Error getting user bookings: " + e.getMessage());
            e.printStackTrace();
        }
        
        return bookings;
    }
    
    /**
     * Get bookings by status for a user
     */
    public java.util.List<Booking> getUserBookingsByStatus(int userID, String status) {
        java.util.List<Booking> bookings = new java.util.ArrayList<>();
        String sql = "SELECT * FROM Bookings WHERE UserID = ? AND Status = ? ORDER BY BookingDate DESC";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, userID);
            ps.setString(2, status);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                bookings.add(extractBookingFromResultSet(rs));
            }
            
        } catch (SQLException e) {
            System.err.println("Error getting user bookings by status: " + e.getMessage());
            e.printStackTrace();
        }
        
        return bookings;
    }
    
    /**
     * Get booking by booking code
     */
    public Booking getBookingByCode(String bookingCode) {
        String sql = "SELECT * FROM Bookings WHERE BookingCode = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, bookingCode);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return extractBookingFromResultSet(rs);
            }
            
        } catch (SQLException e) {
            System.err.println("Error getting booking by code: " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * Cancel a booking (updates status and releases seats)
     */
    public boolean cancelBooking(int bookingID) {
        String sql = "UPDATE Bookings SET Status = 'Cancelled' WHERE BookingID = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, bookingID);
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.err.println("Error cancelling booking: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Get complete booking details with movie, screening, tickets, and food information
     */
    public List<BookingDetailDTO> getUserBookingDetails(int userID) {
        List<BookingDetailDTO> bookingDetails = new ArrayList<>();
        
        String sql = "SELECT " +
                     "b.BookingID, b.BookingCode, b.BookingDate, b.TotalAmount, " +
                     "b.DiscountAmount, b.FinalAmount, b.Status, b.PaymentStatus, " +
                     "b.PaymentMethod, b.PaymentDate, " +
                     "m.Title AS MovieTitle, m.PosterURL AS MoviePosterURL, m.Duration AS MovieDuration, " +
                     "c.CinemaName, r.RoomName, s.StartTime AS ScreeningTime " +
                     "FROM Bookings b " +
                     "JOIN Screenings s ON b.ScreeningID = s.ScreeningID " +
                     "JOIN Movies m ON s.MovieID = m.MovieID " +
                     "JOIN ScreeningRooms r ON s.RoomID = r.RoomID " +
                     "JOIN Cinemas c ON r.CinemaID = c.CinemaID " +
                     "WHERE b.UserID = ? " +
                     "ORDER BY b.BookingDate DESC";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, userID);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                BookingDetailDTO detail = new BookingDetailDTO();
                
                // Booking info
                int bookingID = rs.getInt("BookingID");
                detail.setBookingID(bookingID);
                detail.setBookingCode(rs.getString("BookingCode"));
                detail.setBookingDate(rs.getTimestamp("BookingDate").toLocalDateTime());
                detail.setTotalAmount(rs.getDouble("TotalAmount"));
                detail.setDiscountAmount(rs.getDouble("DiscountAmount"));
                detail.setFinalAmount(rs.getDouble("FinalAmount"));
                detail.setStatus(rs.getString("Status"));
                detail.setPaymentStatus(rs.getString("PaymentStatus"));
                detail.setPaymentMethod(rs.getString("PaymentMethod"));
                
                Timestamp paymentDate = rs.getTimestamp("PaymentDate");
                if (paymentDate != null) {
                    detail.setPaymentDate(paymentDate.toLocalDateTime());
                }
                
                // Movie and screening info
                detail.setMovieTitle(rs.getString("MovieTitle"));
                detail.setMoviePosterURL(rs.getString("MoviePosterURL"));
                detail.setMovieDuration(rs.getInt("MovieDuration"));
                detail.setCinemaName(rs.getString("CinemaName"));
                detail.setRoomName(rs.getString("RoomName"));
                detail.setScreeningTime(rs.getTimestamp("ScreeningTime").toLocalDateTime());
                detail.setDiscountCode(null); // Bookings table doesn't have DiscountID reference
                
                // Get tickets (seats) for this booking
                List<String> seatLabels = getBookingSeats(bookingID);
                detail.setSeatLabels(seatLabels);
                detail.setTicketCount(seatLabels.size());
                
                // Calculate ticket subtotal
                double ticketSubtotal = getBookingTicketSubtotal(bookingID);
                detail.setTicketSubtotal(ticketSubtotal);
                
                // Get food items for this booking
                List<BookingDetailDTO.FoodItemDetail> foodItems = getBookingFoodItems(bookingID);
                detail.setFoodItems(foodItems);
                
                // Calculate food subtotal
                double foodSubtotal = 0;
                for (BookingDetailDTO.FoodItemDetail item : foodItems) {
                    foodSubtotal += item.getTotalPrice();
                }
                detail.setFoodSubtotal(foodSubtotal);
                
                bookingDetails.add(detail);
            }
            
        } catch (SQLException e) {
            System.err.println("Error getting user booking details: " + e.getMessage());
            e.printStackTrace();
        }
        
        return bookingDetails;
    }
    
    /**
     * Get seat labels for a booking
     */
    private List<String> getBookingSeats(int bookingID) {
        List<String> seatLabels = new ArrayList<>();
        String sql = "SELECT CONCAT(s.SeatRow, s.SeatNumber) AS SeatLabel " +
                     "FROM Tickets t " +
                     "JOIN Seats s ON t.SeatID = s.SeatID " +
                     "WHERE t.BookingID = ? " +
                     "ORDER BY s.SeatRow, s.SeatNumber";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, bookingID);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                seatLabels.add(rs.getString("SeatLabel"));
            }
            
        } catch (SQLException e) {
            System.err.println("Error getting booking seats: " + e.getMessage());
        }
        
        return seatLabels;
    }
    
    /**
     * Get ticket subtotal for a booking
     */
    private double getBookingTicketSubtotal(int bookingID) {
        String sql = "SELECT SUM(SeatPrice) AS TicketSubtotal FROM Tickets WHERE BookingID = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, bookingID);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getDouble("TicketSubtotal");
            }
            
        } catch (SQLException e) {
            System.err.println("Error getting ticket subtotal: " + e.getMessage());
        }
        
        return 0.0;
    }
    
    /**
     * Get food items for a booking
     */
    private List<BookingDetailDTO.FoodItemDetail> getBookingFoodItems(int bookingID) {
        List<BookingDetailDTO.FoodItemDetail> foodItems = new ArrayList<>();
        
        String sql = "SELECT " +
                     "CASE WHEN bfi.FoodID IS NOT NULL THEN f.FoodName " +
                     "     WHEN bfi.ComboID IS NOT NULL THEN cb.ComboName " +
                     "END AS ItemName, " +
                     "bfi.Quantity, bfi.UnitPrice, bfi.TotalPrice, " +
                     "CASE WHEN bfi.FoodID IS NOT NULL THEN 'Food' " +
                     "     WHEN bfi.ComboID IS NOT NULL THEN 'Combo' " +
                     "END AS ItemType " +
                     "FROM BookingFoodItems bfi " +
                     "LEFT JOIN Food f ON bfi.FoodID = f.FoodID " +
                     "LEFT JOIN Combo cb ON bfi.ComboID = cb.ComboID " +
                     "WHERE bfi.BookingID = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, bookingID);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                BookingDetailDTO.FoodItemDetail item = new BookingDetailDTO.FoodItemDetail(
                    rs.getString("ItemName"),
                    rs.getInt("Quantity"),
                    rs.getDouble("UnitPrice"),
                    rs.getDouble("TotalPrice"),
                    rs.getString("ItemType")
                );
                foodItems.add(item);
            }
            
        } catch (SQLException e) {
            System.err.println("Error getting booking food items: " + e.getMessage());
        }
        
        return foodItems;
    }
    
    /**
     * Add a food item to a booking
     * @return true if successful, false otherwise
     */
    public boolean addBookingFoodItem(int bookingID, int foodID, int quantity, double unitPrice) {
        String sql = "INSERT INTO BookingFoodItems (BookingID, FoodID, ComboID, Quantity, UnitPrice, TotalPrice) " +
                     "VALUES (?, ?, NULL, ?, ?, ?)";
        
        double totalPrice = unitPrice * quantity;
        
        System.out.println("=== Adding Food Item to Booking ===");
        System.out.println("BookingID: " + bookingID);
        System.out.println("FoodID: " + foodID);
        System.out.println("Quantity: " + quantity);
        System.out.println("UnitPrice: " + unitPrice);
        System.out.println("TotalPrice: " + totalPrice);
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, bookingID);
            ps.setInt(2, foodID);
            ps.setInt(3, quantity);
            ps.setDouble(4, unitPrice);
            ps.setDouble(5, totalPrice);
            
            System.out.println("Executing SQL: " + sql);
            int affectedRows = ps.executeUpdate();
            System.out.println("Affected rows: " + affectedRows);
            
            if (affectedRows > 0) {
                System.out.println("✓ Added food item (ID: " + foodID + ") x" + quantity + " to booking " + bookingID);
                return true;
            } else {
                System.err.println("✗ No rows affected when adding food item!");
                return false;
            }
            
        } catch (SQLException e) {
            System.err.println("=== ERROR adding food item to booking ===");
            System.err.println("SQL State: " + e.getSQLState());
            System.err.println("Error Code: " + e.getErrorCode());
            System.err.println("Message: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Add a combo item to a booking
     * @return true if successful, false otherwise
     */
    public boolean addBookingComboItem(int bookingID, int comboID, int quantity, double unitPrice) {
        String sql = "INSERT INTO BookingFoodItems (BookingID, FoodID, ComboID, Quantity, UnitPrice, TotalPrice) " +
                     "VALUES (?, NULL, ?, ?, ?, ?)";
        
        double totalPrice = unitPrice * quantity;
        
        System.out.println("=== Adding Combo Item to Booking ===");
        System.out.println("BookingID: " + bookingID);
        System.out.println("ComboID: " + comboID);
        System.out.println("Quantity: " + quantity);
        System.out.println("UnitPrice: " + unitPrice);
        System.out.println("TotalPrice: " + totalPrice);
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, bookingID);
            ps.setInt(2, comboID);
            ps.setInt(3, quantity);
            ps.setDouble(4, unitPrice);
            ps.setDouble(5, totalPrice);
            
            System.out.println("Executing SQL: " + sql);
            int affectedRows = ps.executeUpdate();
            System.out.println("Affected rows: " + affectedRows);
            
            if (affectedRows > 0) {
                System.out.println("✓ Added combo item (ID: " + comboID + ") x" + quantity + " to booking " + bookingID);
                return true;
            } else {
                System.err.println("✗ No rows affected when adding combo item!");
                return false;
            }
            
        } catch (SQLException e) {
            System.err.println("=== ERROR adding combo item to booking ===");
            System.err.println("SQL State: " + e.getSQLState());
            System.err.println("Error Code: " + e.getErrorCode());
            System.err.println("Message: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Add multiple food items to a booking
     * @param foodItems Map of FoodID -> Quantity
     * @param foodPrices Map of FoodID -> UnitPrice
     * @return number of items successfully added
     */
    public int addBookingFoodItems(int bookingID, java.util.Map<Integer, Integer> foodItems, 
                                   java.util.Map<Integer, Double> foodPrices) {
        int successCount = 0;
        
        if (foodItems == null || foodItems.isEmpty()) {
            return 0;
        }
        
        for (java.util.Map.Entry<Integer, Integer> entry : foodItems.entrySet()) {
            int foodID = entry.getKey();
            int quantity = entry.getValue();
            double unitPrice = foodPrices.getOrDefault(foodID, 0.0);
            
            if (addBookingFoodItem(bookingID, foodID, quantity, unitPrice)) {
                successCount++;
            }
        }
        
        return successCount;
    }
    
    /**
     * Add multiple combo items to a booking
     * @param comboItems Map of ComboID -> Quantity
     * @param comboPrices Map of ComboID -> UnitPrice
     * @return number of items successfully added
     */
    public int addBookingComboItems(int bookingID, java.util.Map<Integer, Integer> comboItems, 
                                    java.util.Map<Integer, Double> comboPrices) {
        int successCount = 0;
        
        if (comboItems == null || comboItems.isEmpty()) {
            return 0;
        }
        
        for (java.util.Map.Entry<Integer, Integer> entry : comboItems.entrySet()) {
            int comboID = entry.getKey();
            int quantity = entry.getValue();
            double unitPrice = comboPrices.getOrDefault(comboID, 0.0);
            
            if (addBookingComboItem(bookingID, comboID, quantity, unitPrice)) {
                successCount++;
            }
        }
        
        return successCount;
    }
    
    /**
     * Get single booking detail by ID
     */
    public BookingDetailDTO getBookingDetailByID(int bookingID, int userID) {
        List<BookingDetailDTO> details = getUserBookingDetails(userID);
        
        for (BookingDetailDTO detail : details) {
            if (detail.getBookingID() == bookingID) {
                return detail;
            }
        }
        
        return null;
    }
}

