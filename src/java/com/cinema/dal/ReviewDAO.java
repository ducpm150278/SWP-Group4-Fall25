package com.cinema.dal;


import com.cinema.entity.Review;
import java.util.ArrayList;
import java.util.List;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;

/**
 *
 * @author quang
 */
public class ReviewDAO extends DBContext {

    public List<Review> getReviewsByMovieID(int movieID) {
        List<Review> list = new ArrayList<>();
        String sql = """
        SELECT r.ReviewID, r.MovieID, r.UserID, 
               ISNULL(u.FullName, 'Anonymous') as UserName, 
               r.Rating, r.Comment, r.CreatedDate
        FROM Reviews r
        LEFT JOIN Users u ON r.UserID = u.UserID
        WHERE r.MovieID = ?
        ORDER BY r.CreatedDate DESC
        """;

        try (PreparedStatement pre = getConnection().prepareStatement(sql)) {
            pre.setInt(1, movieID);
            ResultSet rs = pre.executeQuery();
            
            while (rs.next()) {
                Review review = new Review(
                    rs.getInt("ReviewID"),
                    rs.getInt("MovieID"),
                    rs.getInt("UserID"),
                    rs.getString("UserName"),
                    rs.getInt("Rating"),
                    rs.getString("Comment"),
                    rs.getTimestamp("CreatedDate").toLocalDateTime()
                );
                list.add(review);
            }
        } catch (SQLException e) {
            System.out.println("Error getReviewsByMovieID: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    public boolean addReview(int movieID, int userID, int rating, String comment) {
        String sql = "INSERT INTO Reviews (MovieID, UserID, Rating, Comment, CreatedDate, Status) VALUES (?, ?, ?, ?, ?, 'Active')";
        
        try (PreparedStatement pre = getConnection().prepareStatement(sql)) {
            pre.setInt(1, movieID);
            pre.setInt(2, userID);
            pre.setInt(3, rating);
            pre.setString(4, comment);
            pre.setTimestamp(5, java.sql.Timestamp.valueOf(LocalDateTime.now()));
            
            return pre.executeUpdate() > 0;
        } catch (SQLException e) {
            System.out.println("Error addReview: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateReview(int reviewID, int rating, String comment) {
        String sql = "UPDATE Reviews SET Rating = ?, Comment = ? WHERE ReviewID = ?";
        
        try (PreparedStatement pre = getConnection().prepareStatement(sql)) {
            pre.setInt(1, rating);
            pre.setString(2, comment);
            pre.setInt(3, reviewID);
            
            return pre.executeUpdate() > 0;
        } catch (SQLException e) {
            System.out.println("Error updateReview: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteReview(int reviewID) {
        String sql = "DELETE FROM Reviews WHERE ReviewID = ?";
        
        try (PreparedStatement pre = getConnection().prepareStatement(sql)) {
            pre.setInt(1, reviewID);
            
            return pre.executeUpdate() > 0;
        } catch (SQLException e) {
            System.out.println("Error deleteReview: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }


    public double getAverageRating(int movieID) {
        String sql = "SELECT AVG(CAST(Rating AS FLOAT)) FROM Reviews WHERE MovieID = ?";
        
        try (PreparedStatement pre = getConnection().prepareStatement(sql)) {
            pre.setInt(1, movieID);
            ResultSet rs = pre.executeQuery();
            
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (SQLException e) {
            System.out.println("Error getAverageRating: " + e.getMessage());
            e.printStackTrace();
        }
        return 0.0;
    }

    public int getTotalReviews(int movieID) {
        String sql = "SELECT COUNT(*) FROM Reviews WHERE MovieID = ?";
        
        try (PreparedStatement pre = getConnection().prepareStatement(sql)) {
            pre.setInt(1, movieID);
            ResultSet rs = pre.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.out.println("Error getTotalReviews: " + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }
    //Customer
    public List<Integer> getReviewedMovieIds(int userId) {
        List<Integer> ids = new ArrayList<>();
        String sql = "SELECT MovieID FROM Reviews WHERE UserID = ?";
        
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                ids.add(rs.getInt("MovieID"));
            }
        } catch (Exception e) {
            e.printStackTrace();
            System.out.println("Error getReviewedMovieIds: " + e.getMessage());
        }
        return ids;
    }
    //Customer
public boolean hasUserReviewedMovie(int userId, int movieId) {
    String sql = "SELECT COUNT(*) FROM Reviews WHERE UserID = ? AND MovieID = ?";
    
    try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
        ps.setInt(1, userId);
        ps.setInt(2, movieId); //
        
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            return rs.getInt(1) > 0;
        }
    } catch (Exception e) {
        e.printStackTrace();
        System.out.println("Error hasUserReviewedMovie: " + e.getMessage());
    }
    return false;
}
}
