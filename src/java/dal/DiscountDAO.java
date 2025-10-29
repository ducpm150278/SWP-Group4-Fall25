/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dal;

import entity.Discount;
import java.util.ArrayList;
import java.util.List;
import java.sql.*;
import java.time.LocalDate;

/**
 *
 * @author admin
 */
public class DiscountDAO extends DBContext {

    public List<Discount> getAllDiscounts() {
        List<Discount> list = new ArrayList<>();
        String sql = "SELECT * FROM Discounts ORDER BY StartDate DESC";
        try (PreparedStatement ps = getConnection().prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Discount d = new Discount();
                d.setDiscountID(rs.getInt("DiscountID"));
                d.setCode(rs.getString("Code"));
                d.setDiscountType(rs.getString("DiscountType"));
                d.setDiscountValue(rs.getDouble("DiscountValue"));
                d.setStartDate(rs.getTimestamp("StartDate").toLocalDateTime());
                d.setEndDate(rs.getTimestamp("EndDate").toLocalDateTime());
                d.setStatus(rs.getString("Status"));
                list.add(d);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
    // Đếm tổng số CTKM (có lọc)

    public int countDiscounts(String keyword, String status, String startDate) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM Discounts WHERE 1=1");
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.isBlank()) {
            sql.append(" AND Code LIKE ?");
            params.add("%" + keyword + "%");
        }
        if (status != null && !status.isBlank()) {
            sql.append(" AND Status = ?");
            params.add(status);
        }
        if (startDate != null && !startDate.isBlank()) {
            sql.append(" AND CAST(StartDate AS DATE) >= ?");
            params.add(Date.valueOf(startDate));
        }

        try (PreparedStatement ps = getConnection().prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    //Lấy danh sách CTKM (có lọc + phân trang)
    public List<Discount> getDiscountsByPage(String keyword, String status, String startDate,
            int offset, int limit) {
        List<Discount> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM Discounts WHERE 1=1");
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.isBlank()) {
            sql.append(" AND Code LIKE ?");
            params.add("%" + keyword + "%");
        }
        if (status != null && !status.isBlank()) {
            sql.append(" AND Status = ?");
            params.add(status);
        }
        if (startDate != null && !startDate.isBlank()) {
            sql.append(" AND CAST(StartDate AS DATE) >= ?");
            params.add(Date.valueOf(startDate));
        }

        sql.append(" ORDER BY StartDate DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        params.add(offset);
        params.add(limit);

        try (PreparedStatement ps = getConnection().prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Discount d = new Discount();
                d.setDiscountID(rs.getInt("DiscountID"));
                d.setCode(rs.getString("Code"));
                d.setDiscountType(rs.getString("DiscountType"));
                d.setDiscountValue(rs.getDouble("DiscountValue"));
                d.setStartDate(rs.getTimestamp("StartDate").toLocalDateTime());
                d.setEndDate(rs.getTimestamp("EndDate").toLocalDateTime());
                d.setStatus(rs.getString("Status"));
                list.add(d);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    //lấy để hiển thị view
    public Discount getDiscountById(int id) {
        String sql = "SELECT * FROM Discounts WHERE DiscountID = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Discount d = new Discount();
                d.setDiscountID(rs.getInt("DiscountID"));
                d.setCode(rs.getString("Code"));
                d.setDiscountType(rs.getString("DiscountType"));
                d.setDiscountValue(rs.getDouble("DiscountValue"));
                d.setStartDate(rs.getTimestamp("StartDate").toLocalDateTime());
                d.setEndDate(rs.getTimestamp("EndDate").toLocalDateTime());
                d.setStatus(rs.getString("Status"));
                d.setMaxUsage(rs.getInt("MaxUsage"));
                d.setUsageCount(rs.getInt("UsageCount"));
                return d;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    //lấy discount theo mã code (dùng cho booking)
    public Discount getDiscountByCode(String code) {
        // Trim và uppercase để tránh lỗi khoảng trắng và case sensitivity
        String sql = "SELECT * FROM Discounts WHERE UPPER(LTRIM(RTRIM(Code))) = UPPER(?)";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setString(1, code.trim());
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Discount d = new Discount();
                d.setDiscountID(rs.getInt("DiscountID"));
                d.setCode(rs.getString("Code"));
                d.setDiscountType(rs.getString("DiscountType"));
                d.setDiscountValue(rs.getDouble("DiscountValue"));
                d.setStartDate(rs.getTimestamp("StartDate").toLocalDateTime());
                d.setEndDate(rs.getTimestamp("EndDate").toLocalDateTime());
                d.setStatus(rs.getString("Status"));
                d.setMaxUsage(rs.getInt("MaxUsage"));
                d.setUsageCount(rs.getInt("UsageCount"));
                return d;
            }
        } catch (SQLException e) {
            System.err.println("Error getting discount by code: " + code);
            e.printStackTrace();
        }
        return null;
    }

    //thêm discount
    public void insertDiscount(String code, int maxUsage, int usageCount,
            LocalDate startDate, LocalDate endDate,
            String status, double discountPercentage, int createdBy) {

        String sql = """
        INSERT INTO Discounts (CreatedBy, Code, MaxUsage, UsageCount, StartDate, EndDate, Status, DiscountPercentage)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    """;

        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, createdBy);
            ps.setString(2, code);
            ps.setInt(3, maxUsage);
            ps.setInt(4, usageCount);
            ps.setTimestamp(5, Timestamp.valueOf(startDate.atStartOfDay()));
            ps.setTimestamp(6, Timestamp.valueOf(endDate.atTime(23, 59, 59)));
            ps.setString(7, status);
            ps.setDouble(8, discountPercentage);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

// Cập nhật CTKM
    public void updateDiscount(int id, String code, int maxUsage, int usageCount,
            LocalDate start, LocalDate end, String status, double discountPercentage) {
        String sql = """
UPDATE Discounts
SET Code=?, MaxUsage=?, UsageCount=?, StartDate=?, EndDate=?, 
    Status=?, DiscountPercentage=?
WHERE DiscountID=?""";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setString(1, code);
            ps.setInt(2, maxUsage);
            ps.setInt(3, usageCount);
            ps.setTimestamp(4, Timestamp.valueOf(start.atStartOfDay()));
            ps.setTimestamp(5, Timestamp.valueOf(end.atStartOfDay()));
            ps.setString(6, status);
            ps.setDouble(7, discountPercentage);
            ps.setInt(8, id);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    //xóa

    public boolean deleteDiscount(int id) {
        String sql = "DELETE FROM Discounts WHERE DiscountID = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    //tìm kiếm
    public List<Discount> searchDiscounts(String keyword, LocalDate from, LocalDate to, String status) {
        List<Discount> list = new ArrayList<>();

        // Câu SQL động — chỉ thêm điều kiện khi người dùng nhập
        StringBuilder sql = new StringBuilder("SELECT * FROM Discounts WHERE 1=1");

        if (keyword != null && !keyword.isEmpty()) {
            sql.append(" AND Code LIKE ?");
        }
        if (from != null) {
            sql.append(" AND StartDate >= ?");
        }
        if (to != null) {
            sql.append(" AND EndDate <= ?");
        }
        if (status != null && !status.isEmpty()) {
            sql.append(" AND Status = ?");
        }

        sql.append(" ORDER BY DiscountID DESC");

        try (PreparedStatement ps = getConnection().prepareStatement(sql.toString())) {
            int index = 1;

            if (keyword != null && !keyword.isEmpty()) {
                ps.setString(index++, "%" + keyword + "%");
            }
            if (from != null) {
                ps.setTimestamp(index++, Timestamp.valueOf(from.atStartOfDay()));
            }
            if (to != null) {
                ps.setTimestamp(index++, Timestamp.valueOf(to.atTime(23, 59, 59)));
            }
            if (status != null && !status.isEmpty()) {
                ps.setString(index++, status);
            }

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Discount d = new Discount();
                d.setDiscountID(rs.getInt("DiscountID"));
                d.setCode(rs.getString("Code"));
                d.setCreatedBy(rs.getInt("CreatedBy"));
                d.setMaxUsage(rs.getInt("MaxUsage"));
                d.setUsageCount(rs.getInt("UsageCount"));
                d.setStartDate(rs.getTimestamp("StartDate").toLocalDateTime());
                d.setEndDate(rs.getTimestamp("EndDate").toLocalDateTime());
                d.setStatus(rs.getString("Status"));
                d.setDiscountPercentage(rs.getDouble("DiscountPercentage"));
                list.add(d);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

}
