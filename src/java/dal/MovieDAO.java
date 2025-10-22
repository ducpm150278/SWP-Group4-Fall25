/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dal;

import java.util.ArrayList;
import java.util.List;
import entity.Movie;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import entity.Language;

/**
 *
 * @author admin
 */
public class MovieDAO extends DBContext {

    public List<Movie> getAll() {
        List<Movie> list = new ArrayList<>();
        String sql = """
                       SELECT m.movieID, m.title, m.genre, m.summary, m.trailerURL, 
                                      m.cast, m.director, m.duration, m.releasedDate, m.posterURL, 
                                      m.status, m.createdDate, l.languageName 
                                      FROM Movies m 
                                      JOIN Language l ON m.languageID = l.languageID""";
        try {
            PreparedStatement pre = getConnection().prepareStatement(sql);
            ResultSet rs = pre.executeQuery();
            while (rs.next()) {

                int movieID = rs.getInt("movieID");
                String title = rs.getString("title");
                String genre = rs.getString("genre");
                String summary = rs.getString("summary");
                String trailerURL = rs.getString("trailerURL");
                String cast = rs.getString("cast");
                String director = rs.getString("director");
                int duration = rs.getInt("duration"); // phút
                LocalDate releasedDate = rs.getDate("releasedDate").toLocalDate();
                String posterURL = rs.getString("posterURL");
                String status = rs.getString("status"); // true = đang chiếu, false = ngừng
                LocalDateTime createdDate = rs.getTimestamp("createdDate").toLocalDateTime();
                String languageName = rs.getString("languageName");
                list.add(new Movie(movieID, title, genre, summary, trailerURL, cast, director, duration, releasedDate, posterURL, status, createdDate, languageName));
            }

        } catch (SQLException e) {
            System.out.println(e);
        }
        return list;
    }


    public void addMovie(String title, String genre, String summary, String trailerURL,
            String cast, String director, int duration, LocalDate releasedDate,
            String posterURL, int languageID, String status, LocalDateTime createdDate) {
        String sql = "INSERT INTO Movies (Title, Genre, Summary, TrailerURL, Cast, Director, Duration, ReleasedDate, PosterURL, LanguageID, Status, CreatedDate) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (PreparedStatement pre = getConnection().prepareStatement(sql)) {
            pre.setString(1, title);
            pre.setString(2, genre);
            pre.setString(3, summary);
            pre.setString(4, trailerURL);
            pre.setString(5, cast);
            pre.setString(6, director);
            pre.setInt(7, duration);
            pre.setDate(8, java.sql.Date.valueOf(releasedDate));
            pre.setString(9, posterURL);
            pre.setInt(10, languageID);   // ✅ truyền trực tiếp ID
            pre.setString(11, status);
            pre.setTimestamp(12, java.sql.Timestamp.valueOf(createdDate));

            pre.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public List<Movie> getMoviesByTitle(String keyword) {
        List<Movie> list = new ArrayList<>();
        String sql = """
        SELECT m.MovieID, m.Title, m.Genre, m.Summary, m.TrailerURL, m.Cast, 
               m.Director, m.Duration, m.ReleasedDate, m.PosterURL, 
               m.Status, m.CreatedDate, l.LanguageName
        FROM Movies m
        JOIN Language l ON m.LanguageID = l.LanguageID
        WHERE m.Title LIKE ?
    """;
        try {
            PreparedStatement pre = getConnection().prepareStatement(sql);
            pre.setString(1, "%" + keyword + "%");
            ResultSet rs = pre.executeQuery();
            while (rs.next()) {
                Movie movie = new Movie(
                        rs.getInt("MovieID"),
                        rs.getString("Title"),
                        rs.getString("Genre"),
                        rs.getString("Summary"),
                        rs.getString("TrailerURL"),
                        rs.getString("Cast"),
                        rs.getString("Director"),
                        rs.getInt("Duration"),
                        rs.getDate("ReleasedDate").toLocalDate(),
                        rs.getString("PosterURL"),
                        rs.getString("Status"),
                        rs.getTimestamp("CreatedDate").toLocalDateTime(),
                        rs.getString("LanguageName") // ✅ lấy languageName
                );
                list.add(movie);
            }
        } catch (SQLException e) {
            System.out.println(e);
        }
        return list;
    }


    public void updateMovie(int movieID, String title, String genre, String summary,
            String trailerURL, String cast, String director,
            int duration, LocalDate releasedDate, String posterURL,
            String status, int languageId) {

        String sql = """
        UPDATE Movies
        SET Title=?, Genre=?, Summary=?, TrailerURL=?, Cast=?, Director=?, 
            Duration=?, ReleasedDate=?, PosterURL=?, Status=?, LanguageID=?
        WHERE MovieID=?""";

        try (PreparedStatement pre = getConnection().prepareStatement(sql)) {
            pre.setString(1, title);
            pre.setString(2, genre);
            pre.setString(3, summary);
            pre.setString(4, trailerURL);
            pre.setString(5, cast);
            pre.setString(6, director);
            pre.setInt(7, duration);
            pre.setDate(8, java.sql.Date.valueOf(releasedDate));
            pre.setString(9, posterURL);
            pre.setString(10, status);
            pre.setInt(11, languageId);   // ✅ truyền ID trực tiếp
            pre.setInt(12, movieID);

            pre.executeUpdate();
        } catch (SQLException e) {
            System.out.println("Update Movie Error: " + e.getMessage());
        }
    }

    public void delete(int movieID) {
        String sql = "DELETE FROM Movies WHERE MovieID = ?";
        try {
            PreparedStatement pre = getConnection().prepareStatement(sql);
            pre.setInt(1, movieID);
            pre.executeUpdate();
        } catch (SQLException e) {
            System.out.println(e);
        }
    }

    public Movie getMovieById(int id) {
        String sql = """
        SELECT m.MovieID, m.Title, m.Genre, m.Summary, m.TrailerURL, m.Cast, 
               m.Director, m.Duration, m.ReleasedDate, m.PosterURL, 
               m.Status, m.CreatedDate, l.LanguageName
        FROM Movies m
        JOIN Language l ON m.LanguageID = l.LanguageID
        WHERE m.MovieID = ?
        """;

        try (PreparedStatement pre = getConnection().prepareStatement(sql)) {
            pre.setInt(1, id);
            ResultSet rs = pre.executeQuery();
            if (rs.next()) {
                Movie m = new Movie(
                        rs.getInt("MovieID"),
                        rs.getString("Title"),
                        rs.getString("Genre"),
                        rs.getString("Summary"),
                        rs.getString("TrailerURL"),
                        rs.getString("Cast"),
                        rs.getString("Director"),
                        rs.getInt("Duration"),
                        rs.getDate("ReleasedDate").toLocalDate(),
                        rs.getString("PosterURL"),
                        rs.getString("Status"),
                        rs.getTimestamp("CreatedDate").toLocalDateTime(),
                        rs.getString("LanguageName") // thêm languageName
                );
                return m;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null; // nếu không tìm thấy
    }

    public List<Language> getAllLanguages() {
        List<Language> list = new ArrayList<>();
        String sql = "SELECT LanguageID, LanguageName FROM Language WHERE IsActive = 1";
        try (PreparedStatement pre = getConnection().prepareStatement(sql)) {
            ResultSet rs = pre.executeQuery();
            while (rs.next()) {
                list.add(new Language(
                        rs.getInt("LanguageID"),
                        rs.getString("LanguageName")
                ));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
    
    public List<Movie> getMoviesPaginated(int offset, int limit, String keyword) {
    List<Movie> list = new ArrayList<>();

    String sql = """
        SELECT m.movieID, m.title, m.genre, m.summary, m.trailerURL, 
               m.cast, m.director, m.duration, m.releasedDate, m.posterURL, 
               m.status, m.createdDate, l.languageName
        FROM Movies m 
        JOIN Language l ON m.languageID = l.languageID
        WHERE 1=1
    """;

    if (keyword != null && !keyword.isBlank()) {
        sql += " AND m.title LIKE ? ";
    }

    sql += " ORDER BY m.createdDate DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY ";

    try (PreparedStatement pre = getConnection().prepareStatement(sql)) {
        int index = 1;
        if (keyword != null && !keyword.isBlank()) {
            pre.setString(index++, "%" + keyword + "%");
        }
        pre.setInt(index++, offset);
        pre.setInt(index, limit);

        ResultSet rs = pre.executeQuery();
        while (rs.next()) {
            int movieID = rs.getInt("movieID");
            String title = rs.getString("title");
            String genre = rs.getString("genre");
            String summary = rs.getString("summary");
            String trailerURL = rs.getString("trailerURL");
            String cast = rs.getString("cast");
            String director = rs.getString("director");
            int duration = rs.getInt("duration");
            LocalDate releasedDate = rs.getDate("releasedDate").toLocalDate();
            String posterURL = rs.getString("posterURL");
            String status = rs.getString("status");
            LocalDateTime createdDate = rs.getTimestamp("createdDate").toLocalDateTime();
            String languageName = rs.getString("languageName");

            list.add(new Movie(movieID, title, genre, summary, trailerURL,
                    cast, director, duration, releasedDate, posterURL,
                    status, createdDate, languageName));
        }
    } catch (SQLException e) {
        System.out.println("Error getMoviesPaginated: " + e.getMessage());
    }

    return list;
}
    //lay so ban ghi
public int getTotalMovies(String keyword) {
    String sql = "SELECT COUNT(*) FROM Movies WHERE 1=1 ";
    if (keyword != null && !keyword.isBlank()) {
        sql += " AND title LIKE ? ";
    }

    try (PreparedStatement pre = getConnection().prepareStatement(sql)) {
        if (keyword != null && !keyword.isBlank()) {
            pre.setString(1, "%" + keyword + "%");
        }
        ResultSet rs = pre.executeQuery();
        if (rs.next()) {
            return rs.getInt(1);
        }
    } catch (SQLException e) {
        System.out.println("Error getTotalMovies: " + e.getMessage());
    }
    return 0;
}
public List<Movie> getActiveMovies() {
    List<Movie> list = new ArrayList<>();
    String sql = "SELECT MovieID, Title FROM Movies WHERE Status IN ('Active', 'Upcoming', 'Inactive', 'Cancelled')";
    try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Movie m = new Movie();
            m.setMovieID(rs.getInt("MovieID"));
            m.setTitle(rs.getString("Title"));
            list.add(m);
        }
    } catch (SQLException e) {
        System.out.println("Error getActiveMovies: " + e.getMessage());
    }
    return list;
}


    public static void main(String[] args) {
//    MovieDAO dao = new MovieDAO();
//    List<Movie> list = dao.getAll();
//
//    for (Movie m : list) {
//        System.out.println(m); // sẽ gọi hàm toString() của Movie
//    }
// MovieDAO dao = new MovieDAO();
//    dao.delete(8); // thử xóa phim có MovieID = 5
//    System.out.println("Xóa xong rồi, kiểm tra DB nhé!");

    }
}