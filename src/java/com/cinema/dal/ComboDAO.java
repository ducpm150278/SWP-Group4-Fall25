package com.cinema.dal;

/**
 *
 * @author minhd
 */

import com.cinema.entity.Combo;
import com.cinema.entity.Food;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.math.BigDecimal;
import java.time.LocalDateTime;

public class ComboDAO extends DBContext{

    // GET ALL COMBOS
    public List<Combo> getAllCombos() {
        List<Combo> comboList = new ArrayList<>();
        String sql = "SELECT * FROM Combo ORDER BY ComboID";

        try (PreparedStatement stmt = getConnection().prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                Combo combo = mapResultSetToCombo(rs);
                comboList.add(combo);
            }
        } catch (SQLException e) {
            System.err.println("Error getting all combos: " + e.getMessage());
            e.printStackTrace();
        }
        return comboList;
    }

    // GET COMBO BY ID
    public Combo getComboById(int comboId) {
        String sql = "SELECT * FROM Combo WHERE ComboID = ?";
        Combo combo = null;

        try (PreparedStatement stmt = getConnection().prepareStatement(sql)) {
            stmt.setInt(1, comboId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    combo = mapResultSetToCombo(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error getting combo by ID: " + e.getMessage());
            e.printStackTrace();
        }
        return combo;
    }

    // CREATE COMBO
    public boolean createCombo(Combo combo) {
        String sql = "INSERT INTO Combo (ComboName, Description, TotalPrice, DiscountPrice, "
                + "ComboImage, IsAvailable) "
                + "VALUES (?, ?, ?, ?, ?, ?)";

        try (PreparedStatement stmt = getConnection().prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, combo.getComboName());
            stmt.setString(2, combo.getDescription());
            stmt.setBigDecimal(3, combo.getTotalPrice());
            stmt.setBigDecimal(4, combo.getDiscountPrice());
            stmt.setString(5, combo.getComboImage());
            stmt.setBoolean(6, combo.getIsAvailable());

            int affectedRows = stmt.executeUpdate();

            if (affectedRows > 0) {
                try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        combo.setComboID(generatedKeys.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            System.err.println("Error creating combo: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    // UPDATE COMBO
    public boolean updateCombo(Combo combo) {
        String sql = "UPDATE Combo SET ComboName = ?, Description = ?, TotalPrice = ?, "
                + "DiscountPrice = ?, ComboImage = ?, IsAvailable = ? "
                + "WHERE ComboID = ?";

        try (PreparedStatement stmt = getConnection().prepareStatement(sql)) {
            stmt.setString(1, combo.getComboName());
            stmt.setString(2, combo.getDescription());
            stmt.setBigDecimal(3, combo.getTotalPrice());
            stmt.setBigDecimal(4, combo.getDiscountPrice());
            stmt.setString(5, combo.getComboImage());
            stmt.setBoolean(6, combo.getIsAvailable());
            stmt.setInt(7, combo.getComboID());

            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;

        } catch (SQLException e) {
            System.err.println("Error updating combo: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    // DELETE COMBO
    public boolean deleteCombo(int comboId) {
        // First delete related records in ComboFood
        if (!deleteComboFoodRelations(comboId)) {
            return false;
        }

        String sql = "DELETE FROM Combo WHERE ComboID = ?";

        try (PreparedStatement stmt = getConnection().prepareStatement(sql)) {
            stmt.setInt(1, comboId);

            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;

        } catch (SQLException e) {
            System.err.println("Error deleting combo: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    // DELETE COMBO FOOD RELATIONS
    private boolean deleteComboFoodRelations(int comboId) {
        String sql = "DELETE FROM ComboFood WHERE ComboID = ?";

        try (PreparedStatement stmt = getConnection().prepareStatement(sql)) {
            stmt.setInt(1, comboId);
            stmt.executeUpdate();
            return true;
        } catch (SQLException e) {
            System.err.println("Error deleting combo food relations: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    // GET AVAILABLE COMBOS
    public List<Combo> getAvailableCombos() {
        List<Combo> comboList = new ArrayList<>();
        String sql = "SELECT * FROM Combo WHERE IsAvailable = 1 ORDER BY ComboName";

        try (PreparedStatement stmt = getConnection().prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                Combo combo = mapResultSetToCombo(rs);
                comboList.add(combo);
            }
        } catch (SQLException e) {
            System.err.println("Error getting available combos: " + e.getMessage());
            e.printStackTrace();
        }
        return comboList;
    }

    // SEARCH COMBOS BY NAME
    public List<Combo> searchCombosByName(String keyword) {
        List<Combo> comboList = new ArrayList<>();
        String sql = "SELECT * FROM Combo WHERE ComboName LIKE ? ORDER BY ComboName";

        try (PreparedStatement stmt = getConnection().prepareStatement(sql)) {
            stmt.setString(1, "%" + keyword + "%");

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Combo combo = mapResultSetToCombo(rs);
                    comboList.add(combo);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error searching combos by name: " + e.getMessage());
            e.printStackTrace();
        }
        return comboList;
    }

    // GET AVAILABLE FOOD FOR COMBO
    public List<Food> getAvailableFoodForCombo() {
        List<Food> foodList = new ArrayList<>();
        String sql = "SELECT * FROM Food WHERE IsAvailable = 1 ORDER BY FoodName";

        try (PreparedStatement stmt = getConnection().prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                Food food = mapResultSetToFood(rs);
                foodList.add(food);
            }
        } catch (SQLException e) {
            System.err.println("Error getting available food for combo: " + e.getMessage());
            e.printStackTrace();
        }
        return foodList;
    }

    // ADD FOOD TO COMBO
    public boolean addFoodToCombo(int comboId, int foodId, int quantity) {
        String sql = "INSERT INTO ComboFood (ComboID, FoodID, Quantity) VALUES (?, ?, ?)";

        try (PreparedStatement stmt = getConnection().prepareStatement(sql)) {
            stmt.setInt(1, comboId);
            stmt.setInt(2, foodId);
            stmt.setInt(3, quantity);

            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;

        } catch (SQLException e) {
            System.err.println("Error adding food to combo: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    // GET FOOD IN COMBO (FIXED VERSION)
    public List<Food> getFoodInCombo(int comboId) {
        List<Food> foodList = new ArrayList<>();
        String sql = "SELECT f.*, cf.Quantity FROM Food f "
                + "INNER JOIN ComboFood cf ON f.FoodID = cf.FoodID "
                + "WHERE cf.ComboID = ? ORDER BY f.FoodName";

        try (PreparedStatement stmt = getConnection().prepareStatement(sql)) {
            stmt.setInt(1, comboId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Food food = mapResultSetToFood(rs);
                    foodList.add(food);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error getting food in combo: " + e.getMessage());
            e.printStackTrace();
        }
        return foodList;
    }

    // MAP RESULT SET TO COMBO
    private Combo mapResultSetToCombo(ResultSet rs) throws SQLException {
        Combo combo = new Combo();
        combo.setComboID(rs.getInt("ComboID"));
        combo.setComboName(rs.getString("ComboName"));
        combo.setDescription(rs.getString("Description"));
        combo.setTotalPrice(rs.getBigDecimal("TotalPrice"));
        combo.setDiscountPrice(rs.getBigDecimal("DiscountPrice"));
        combo.setComboImage(rs.getString("ComboImage"));
        combo.setIsAvailable(rs.getBoolean("IsAvailable"));

        Timestamp createdTimestamp = rs.getTimestamp("CreatedDate");
        if (createdTimestamp != null) {
            combo.setCreatedDate(createdTimestamp.toLocalDateTime());
        }

        return combo;
    }

    // MAP RESULT SET TO FOOD (NEW METHOD)
    private Food mapResultSetToFood(ResultSet rs) throws SQLException {
        Food food = new Food();
        food.setFoodID(rs.getInt("FoodID"));
        food.setFoodName(rs.getString("FoodName"));
        food.setDescription(rs.getString("Description"));
        food.setPrice(rs.getBigDecimal("Price"));
        food.setFoodType(rs.getString("FoodType"));
        food.setImageURL(rs.getString("ImageURL"));
        food.setIsAvailable(rs.getBoolean("IsAvailable"));

        // Handle timestamps if they exist in the result set
        try {
            Timestamp createdTimestamp = rs.getTimestamp("CreatedDate");
            if (createdTimestamp != null) {
                food.setCreatedDate(createdTimestamp.toLocalDateTime());
            }
        } catch (SQLException e) {
            // Ignore if these columns don't exist in the result set
        }

        return food;
    }

    // TEST METHOD
    public static void main(String[] args) {
        System.out.println("=== TESTING ComboDAO ===");

        try {
            ComboDAO comboDAO = new ComboDAO();

            // Test getAllCombos()
            List<Combo> comboList = comboDAO.getAllCombos();
            System.out.println("✅ Successfully retrieved " + comboList.size() + " combos");

            // Test getAvailableFoodForCombo()
            List<Food> foodList = comboDAO.getAvailableFoodForCombo();
            System.out.println("✅ Successfully retrieved " + foodList.size() + " available food items");

            for (Food food : foodList) {
                System.out.println("Food ID: " + food.getFoodID() + " - " + food.getFoodName() + " - " + food.getPrice() + " VND");
            }

        } catch (Exception e) {
            System.out.println("❌ Error: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
