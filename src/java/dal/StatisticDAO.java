package dal;

import entity.AdminDashboardStatsDTO;
import entity.ChartDataDTO;
import entity.TopItemDTO;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class StatisticDAO extends DBContext {

    public AdminDashboardStatsDTO getDashboardStats() {
        AdminDashboardStatsDTO stats = new AdminDashboardStatsDTO();
        String sql = "SELECT " +
                     "ISNULL(SUM(FinalAmount), 0) AS TotalRevenue, " +
                     "ISNULL(SUM(TicketCount), 0) AS TotalTickets, " +
                     "COUNT(BookingID) AS TotalBookings " +
                     "FROM vw_RevenueAnalytics " +
                     "WHERE PaymentDate >= DATEADD(day, -30, GETDATE())";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                stats.setTotalRevenue(rs.getDouble("TotalRevenue"));
                stats.setTotalTicketsSold(rs.getInt("TotalTickets"));
                stats.setTotalBookings(rs.getInt("TotalBookings"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return stats;
    }

    public List<ChartDataDTO> getRevenueOverTime(LocalDate from, LocalDate to, int movieId, int cinemaId) {
        List<ChartDataDTO> data = new ArrayList<>();
        
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT CONVERT(varchar, PaymentDate, 23) AS SaleDate, ");
        sql.append("SUM(FinalAmount) AS DailyRevenue ");
        sql.append("FROM vw_RevenueAnalytics ");
        sql.append("WHERE PaymentDate BETWEEN ? AND ? ");
        
        if (movieId > 0) sql.append(" AND MovieID = ? ");
        if (cinemaId > 0) sql.append(" AND CinemaID = ? ");
        
        sql.append(" GROUP BY CONVERT(varchar, PaymentDate, 23) ORDER BY SaleDate ASC");

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            int paramIndex = 1;
            ps.setDate(paramIndex++, Date.valueOf(from));
            ps.setDate(paramIndex++, Date.valueOf(to));
            
            if (movieId > 0) ps.setInt(paramIndex++, movieId);
            if (cinemaId > 0) ps.setInt(paramIndex++, cinemaId);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                data.add(new ChartDataDTO(
                    rs.getString("SaleDate"), 
                    rs.getDouble("DailyRevenue")
                ));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return data;
    }

    public List<TopItemDTO> getTopMovies(LocalDate from, LocalDate to, int cinemaId) {
        List<TopItemDTO> list = new ArrayList<>();
        
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT TOP 5 MovieTitle, ");
        sql.append("SUM(TicketCount) AS TotalTickets, ");
        sql.append("SUM(FinalAmount) AS TotalRevenue ");
        sql.append("FROM vw_RevenueAnalytics ");
        sql.append("WHERE PaymentDate BETWEEN ? AND ? ");
        
        if (cinemaId > 0) sql.append(" AND CinemaID = ? ");
        
        sql.append(" GROUP BY MovieID, MovieTitle ");
        sql.append(" ORDER BY TotalRevenue DESC");

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            int paramIndex = 1;
            ps.setDate(paramIndex++, Date.valueOf(from));
            ps.setDate(paramIndex++, Date.valueOf(to));
            if (cinemaId > 0) ps.setInt(paramIndex++, cinemaId);
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(new TopItemDTO(
                    rs.getString("MovieTitle"),
                    rs.getInt("TotalTickets"),
                    rs.getDouble("TotalRevenue")
                ));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<TopItemDTO> getTopCinemas(LocalDate from, LocalDate to, int movieId) {
        List<TopItemDTO> list = new ArrayList<>();
        
        StringBuilder sql = new StringBuilder(); //Sửa lỗi cú pháp bằng StringBuilder
        sql.append("SELECT TOP 5 CinemaName, ");
        sql.append("SUM(TicketCount) AS TotalTickets, ");
        sql.append("SUM(FinalAmount) AS TotalRevenue ");
        sql.append("FROM vw_RevenueAnalytics ");
        sql.append("WHERE PaymentDate BETWEEN ? AND ? ");
        
        if (movieId > 0) sql.append(" AND MovieID = ? ");
        
        sql.append(" GROUP BY CinemaID, CinemaName ");
        sql.append(" ORDER BY TotalRevenue DESC");

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            int paramIndex = 1;
            ps.setDate(paramIndex++, Date.valueOf(from));
            ps.setDate(paramIndex++, Date.valueOf(to));
            if (movieId > 0) ps.setInt(paramIndex++, movieId);
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(new TopItemDTO(
                    rs.getString("CinemaName"),
                    rs.getInt("TotalTickets"),
                    rs.getDouble("TotalRevenue")
                ));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}