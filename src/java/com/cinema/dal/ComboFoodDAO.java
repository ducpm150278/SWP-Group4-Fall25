package com.cinema.dal;


import com.cinema.entity.ComboFood;
import com.cinema.entity.Food;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ComboFoodDAO extends DBContext {

    public ComboFoodDAO() {
        try {
            if (this.getConnection() == null) {
                System.err.println("ERROR: Database getConnection() is null!");
            } else {
                System.out.println("ComboFoodDAO: Database getConnection() established successfully");
            }
        } catch (Exception e) {
            System.err.println("Error initializing ComboFoodDAO: " + e.getMessage());
            e.printStackTrace();
        }
    }

    // GET ALL FOOD ITEMS IN COMBO
    public List<Food> getFoodItemsByComboId(int comboId) {
        List<Food> foodItems = new ArrayList<>();
        String sql = "SELECT f.*, cf.Quantity FROM Food f "
                + "INNER JOIN ComboFood cf ON f.FoodID = cf.FoodID "
                + "WHERE cf.ComboID = ? ORDER BY f.FoodName";

        System.out.println("Executing SQL: " + sql + " with comboId: " + comboId); // Debug

        try (PreparedStatement stmt = getConnection().prepareStatement(sql)) {
            stmt.setInt(1, comboId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Food food = mapResultSetToFood(rs);
                    foodItems.add(food);
                    System.out.println("Found food: " + food.getFoodName()); // Debug
                }
            }
        } catch (SQLException e) {
            System.err.println("Error getting food items by combo ID: " + e.getMessage());
            e.printStackTrace();
        }
        return foodItems;
    }

    // GET AVAILABLE FOOD ITEMS NOT IN COMBO
    public List<Food> getAvailableFoodItemsNotInCombo(int comboId) {
        List<Food> foodItems = new ArrayList<>();
        String sql = "SELECT * FROM Food WHERE IsAvailable = 1 AND FoodID NOT IN "
                + "(SELECT FoodID FROM ComboFood WHERE ComboID = ?) "
                + "ORDER BY FoodName";

        System.out.println("Executing SQL: " + sql + " with comboId: " + comboId); // Debug

        try (PreparedStatement stmt = getConnection().prepareStatement(sql)) {
            stmt.setInt(1, comboId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Food food = mapResultSetToFood(rs);
                    foodItems.add(food);
                    System.out.println("Available food: " + food.getFoodName()); // Debug
                }
            }
        } catch (SQLException e) {
            System.err.println("Error getting available food items not in combo: " + e.getMessage());
            e.printStackTrace();
        }
        return foodItems;
    }

    public List<Map<String, Object>> getComboFoodItemsWithQuantity(int comboId) {
        List<Map<String, Object>> foodItems = new ArrayList<>();
        String sql = "SELECT f.*, cf.Quantity FROM Food f "
                + "INNER JOIN ComboFood cf ON f.FoodID = cf.FoodID "
                + "WHERE cf.ComboID = ? ORDER BY f.FoodName";

        System.out.println("Executing SQL: " + sql + " with comboId: " + comboId);

        try (PreparedStatement stmt = getConnection().prepareStatement(sql)) {
            stmt.setInt(1, comboId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> foodItem = new HashMap<>();

                    // DEBUG: In ra từng cột
                    System.out.println("=== ROW DATA ===");
                    ResultSetMetaData metaData = rs.getMetaData();
                    int columnCount = metaData.getColumnCount();
                    for (int i = 1; i <= columnCount; i++) {
                        String columnName = metaData.getColumnName(i);
                        Object value = rs.getObject(i);
                        System.out.println(columnName + ": " + value + " (type: " + (value != null ? value.getClass().getSimpleName() : "null") + ")");
                    }

                    // Food information - SỬ DỤNG getString/getInt/getBigDecimal THAY VÌ getObject
                    foodItem.put("foodId", rs.getInt("FoodID"));
                    foodItem.put("foodName", rs.getString("FoodName"));
                    foodItem.put("description", rs.getString("Description"));
                    foodItem.put("price", rs.getBigDecimal("Price"));
                    foodItem.put("foodType", rs.getString("FoodType"));
                    foodItem.put("imageURL", rs.getString("ImageURL"));
                    foodItem.put("isAvailable", rs.getBoolean("IsAvailable"));

                    // Quantity in combo
                    foodItem.put("quantity", rs.getInt("Quantity"));

                    foodItems.add(foodItem);
                    System.out.println("Added food: " + rs.getString("FoodName") + " - Quantity: " + rs.getInt("Quantity"));
                }

                System.out.println("Total food items found: " + foodItems.size());
            }
        } catch (SQLException e) {
            System.err.println("Error getting food items with quantity by combo ID: " + e.getMessage());
            e.printStackTrace();
        }
        return foodItems;
    }

    // ADD FOOD TO COMBO
    public boolean addFoodToCombo(int comboId, int foodId, int quantity) {
        System.out.println("Adding food to combo - ComboID: " + comboId + ", FoodID: " + foodId + ", Quantity: " + quantity);

        // First check if the food is already in the combo
        if (isFoodInCombo(comboId, foodId)) {
            System.err.println("Food already exists in combo");
            return false;
        }

        String sql = "INSERT INTO ComboFood (ComboID, FoodID, Quantity) VALUES (?, ?, ?)";

        try (PreparedStatement stmt = getConnection().prepareStatement(sql)) {
            stmt.setInt(1, comboId);
            stmt.setInt(2, foodId);
            stmt.setInt(3, quantity);

            int affectedRows = stmt.executeUpdate();
            System.out.println("Add food - Affected rows: " + affectedRows); // Debug
            return affectedRows > 0;

        } catch (SQLException e) {
            System.err.println("Error adding food to combo: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    // REMOVE FOOD FROM COMBO
    public boolean removeFoodFromCombo(int comboId, int foodId) {
        System.out.println("Removing food from combo - ComboID: " + comboId + ", FoodID: " + foodId);

        String sql = "DELETE FROM ComboFood WHERE ComboID = ? AND FoodID = ?";

        try (PreparedStatement stmt = getConnection().prepareStatement(sql)) {
            stmt.setInt(1, comboId);
            stmt.setInt(2, foodId);

            int affectedRows = stmt.executeUpdate();
            System.out.println("Remove food - Affected rows: " + affectedRows); // Debug
            return affectedRows > 0;

        } catch (SQLException e) {
            System.err.println("Error removing food from combo: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    // CHECK IF FOOD IS ALREADY IN COMBO
    public boolean isFoodInCombo(int comboId, int foodId) {
        String sql = "SELECT 1 FROM ComboFood WHERE ComboID = ? AND FoodID = ?";

        try (PreparedStatement stmt = getConnection().prepareStatement(sql)) {
            stmt.setInt(1, comboId);
            stmt.setInt(2, foodId);

            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            System.err.println("Error checking if food is in combo: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    // MAP RESULT SET TO FOOD
    private Food mapResultSetToFood(ResultSet rs) throws SQLException {
        Food food = new Food();
        food.setFoodID(rs.getInt("FoodID"));
        food.setFoodName(rs.getString("FoodName"));
        food.setDescription(rs.getString("Description"));
        food.setPrice(rs.getBigDecimal("Price"));
        food.setFoodType(rs.getString("FoodType"));
        food.setImageURL(rs.getString("ImageURL"));
        food.setIsAvailable(rs.getBoolean("IsAvailable"));

        return food;
    }

    // TEST CONNECTION
    public boolean testConnection() {
        try {
            return getConnection() != null && !getConnection().isClosed();
        } catch (SQLException e) {
            System.err.println("Error testing getConnection(): " + e.getMessage());
            return false;
        }
    }
}
