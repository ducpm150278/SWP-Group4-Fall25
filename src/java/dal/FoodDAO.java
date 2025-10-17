/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dal;

import entity.Food;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 *
 * @author minhd
 */
public class FoodDAO extends DBContext{

    public List<Food> getAllFood() {
        List<Food> foodList = new ArrayList<>();
        String sql = "SELECT * FROM Food ORDER BY FoodID";

        try (PreparedStatement stmt = getConnection().prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                Food food = mapResultSetToFood(rs);
                foodList.add(food);
            }
        } catch (SQLException e) {
            System.err.println("Error getting all food: " + e.getMessage());
            e.printStackTrace();
        }
        return foodList;
    }

    /**
     * Lấy food theo ID
     */
    public Food getFoodById(int foodId) {
        String sql = "SELECT * FROM Food WHERE FoodID = ?";
        Food food = null;

        try (PreparedStatement stmt = getConnection().prepareStatement(sql)) {
            stmt.setInt(1, foodId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    food = mapResultSetToFood(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error getting food by ID: " + e.getMessage());
            e.printStackTrace();
        }
        return food;
    }

    /**
     * Tạo food mới
     */
    public boolean createFood(Food food) {
        String sql = "INSERT INTO Food (FoodName, Description, Price, FoodType, ImageURL, IsAvailable, CreatedDate, LastModifiedDate) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        try (PreparedStatement stmt = getConnection().prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, food.getFoodName());
            stmt.setString(2, food.getDescription());
            stmt.setBigDecimal(3, food.getPrice());
            stmt.setString(4, food.getFoodType());
            stmt.setString(5, food.getImageURL());
            stmt.setBoolean(6, food.getIsAvailable());
            stmt.setTimestamp(7, Timestamp.valueOf(LocalDateTime.now()));
            stmt.setTimestamp(8, Timestamp.valueOf(LocalDateTime.now()));

            int affectedRows = stmt.executeUpdate();

            if (affectedRows > 0) {
                // Lấy ID được generate tự động
                try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        food.setFoodID(generatedKeys.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            System.err.println("Error creating food: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Cập nhật food
     */
    public boolean updateFood(Food food) {
        String sql = "UPDATE Food SET FoodName = ?, Description = ?, Price = ?, FoodType = ?, "
                + "ImageURL = ?, IsAvailable = ?, LastModifiedDate = ? WHERE FoodID = ?";

        try (PreparedStatement stmt = getConnection().prepareStatement(sql)) {
            stmt.setString(1, food.getFoodName());
            stmt.setString(2, food.getDescription());
            stmt.setBigDecimal(3, food.getPrice());
            stmt.setString(4, food.getFoodType());
            stmt.setString(5, food.getImageURL());
            stmt.setBoolean(6, food.getIsAvailable());
            stmt.setTimestamp(7, Timestamp.valueOf(LocalDateTime.now()));
            stmt.setInt(8, food.getFoodID());

            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;

        } catch (SQLException e) {
            System.err.println("Error updating food: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Xóa food theo ID
     */
    public boolean deleteFood(int foodId) {
        // Kiểm tra xem food có tồn tại trong combo không trước khi xóa
        if (isFoodInCombo(foodId)) {
            System.err.println("Cannot delete food: Food is used in combos");
            return false;
        }

        String sql = "DELETE FROM Food WHERE FoodID = ?";

        try (PreparedStatement stmt = getConnection().prepareStatement(sql)) {
            stmt.setInt(1, foodId);

            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;

        } catch (SQLException e) {
            System.err.println("Error deleting food: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Kiểm tra xem food có được sử dụng trong combo không
     */
    private boolean isFoodInCombo(int foodId) {
        String sql = "SELECT COUNT(*) FROM ComboFood WHERE FoodID = ?";

        try (PreparedStatement stmt = getConnection().prepareStatement(sql)) {
            stmt.setInt(1, foodId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            System.err.println("Error checking if food is in combo: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Lấy food theo type
     */
    public List<Food> getFoodByType(String foodType) {
        List<Food> foodList = new ArrayList<>();
        String sql = "SELECT * FROM Food WHERE FoodType = ? ORDER BY FoodName";

        try (PreparedStatement stmt = getConnection().prepareStatement(sql)) {
            stmt.setString(1, foodType);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Food food = mapResultSetToFood(rs);
                    foodList.add(food);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error getting food by type: " + e.getMessage());
            e.printStackTrace();
        }
        return foodList;
    }

    /**
     * Lấy available food
     */
    public List<Food> getAvailableFood() {
        List<Food> foodList = new ArrayList<>();
        String sql = "SELECT * FROM Food WHERE IsAvailable = 1 ORDER BY FoodName";

        try (PreparedStatement stmt = getConnection().prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                Food food = mapResultSetToFood(rs);
                foodList.add(food);
            }
        } catch (SQLException e) {
            System.err.println("Error getting available food: " + e.getMessage());
            e.printStackTrace();
        }
        return foodList;
    }

    /**
     * Tìm kiếm food theo tên
     */
    public List<Food> searchFoodByName(String keyword) {
        List<Food> foodList = new ArrayList<>();
        String sql = "SELECT * FROM Food WHERE FoodName LIKE ? ORDER BY FoodName";

        try (PreparedStatement stmt = getConnection().prepareStatement(sql)) {
            stmt.setString(1, "%" + keyword + "%");

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Food food = mapResultSetToFood(rs);
                    foodList.add(food);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error searching food by name: " + e.getMessage());
            e.printStackTrace();
        }
        return foodList;
    }

    /**
     * Helper method để map ResultSet sang Food object
     */
    private Food mapResultSetToFood(ResultSet rs) throws SQLException {
        Food food = new Food();
        food.setFoodID(rs.getInt("FoodID"));
        food.setFoodName(rs.getString("FoodName"));
        food.setDescription(rs.getString("Description"));
        food.setPrice(rs.getBigDecimal("Price"));
        food.setFoodType(rs.getString("FoodType"));
        food.setImageURL(rs.getString("ImageURL"));
        food.setIsAvailable(rs.getBoolean("IsAvailable"));

        // Xử lý timestamp
        Timestamp createdTimestamp = rs.getTimestamp("CreatedDate");
        if (createdTimestamp != null) {
            food.setCreatedDate(createdTimestamp.toLocalDateTime());
        }

        Timestamp modifiedTimestamp = rs.getTimestamp("LastModifiedDate");
        if (modifiedTimestamp != null) {
            food.setLastModifiedDate(modifiedTimestamp.toLocalDateTime());
        }

        return food;
    }
    public static void main(String[] args) {
        System.out.println("=== TESTING FoodDAO.getAllFood() ===");
        
        try {
            FoodDAO foodDAO = new FoodDAO();
            
            // Test getAllFood()
            List<Food> foodList = foodDAO.getAllFood();
            
            if (foodList == null) {
                System.out.println("❌ foodList is NULL");
                return;
            }
            
            System.out.println("✅ Successfully retrieved " + foodList.size() + " food items");
            
            // Hiển thị thông tin từng food item
            System.out.println("\n=== FOOD LIST ===");
            for (Food food : foodList) {
                System.out.println("ID: " + food.getFoodID());
                System.out.println("Name: " + food.getFoodName());
                System.out.println("Description: " + food.getDescription());
                System.out.println("Price: " + food.getPrice());
                System.out.println("Type: " + food.getFoodType());
                System.out.println("Available: " + food.getIsAvailable());
                System.out.println("Image URL: " + food.getImageURL());
                System.out.println("Created: " + food.getCreatedDate());
                System.out.println("Modified: " + food.getLastModifiedDate());
                System.out.println("-----------------------------------");
            }
            
        } catch (Exception e) {
            System.out.println("❌ Error: " + e.getMessage());
            e.printStackTrace();
        }
    }
}


