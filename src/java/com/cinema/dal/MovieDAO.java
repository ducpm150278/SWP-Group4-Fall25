package com.cinema.dal;


import java.util.ArrayList;
import java.util.List;
import com.cinema.entity.Movie;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import com.cinema.entity.Language;
import java.sql.Date;
import java.time.LocalDateTime;

/**
 *
 * @author admin
 */
public class MovieDAO extends DBContext {

    public List<Movie> getAll() {
        List<Movie> list = new ArrayList<>();
        String sql = """
                        SELECT m.movieID, m.title, m.genre, m.summary, m.trailerURL, 
                                                m.cast, m.director, m.duration, m.releasedDate, m.endDate, 
                                                m.posterURL, m.status, l.languageName 
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
                LocalDate endDate = rs.getDate("endDate").toLocalDate();
                String posterURL = rs.getString("posterURL");
                String status = rs.getString("status"); // true = đang chiếu, false = ngừng

                String languageName = rs.getString("languageName");
                list.add(new Movie(movieID, title, genre, summary, trailerURL, cast, director, duration, releasedDate, endDate, posterURL, status, languageName));


            }

        } catch (SQLException e) {
            System.out.println(e);
        }
        return list;
    }

    public void addMovie(String title, String genre, String summary, String trailerURL,

            String cast, String director, int duration, LocalDate releasedDate, LocalDate endDate,
            String posterURL, int languageID, String status) {

        String sql = """
        INSERT INTO Movies 
        (Title, Genre, Summary, TrailerURL, Cast, Director, Duration, ReleasedDate, EndDate, 
         PosterURL, LanguageID, Status)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    """;



        try (PreparedStatement pre = getConnection().prepareStatement(sql)) {
            pre.setString(1, title);
            pre.setString(2, genre);
            pre.setString(3, summary);
            pre.setString(4, trailerURL);
            pre.setString(5, cast);
            pre.setString(6, director);
            pre.setInt(7, duration);
            pre.setDate(8, java.sql.Date.valueOf(releasedDate));
            pre.setDate(9, java.sql.Date.valueOf(endDate)); // ✅ thêm dòng này
            pre.setString(10, posterURL);
            pre.setInt(11, languageID);
            pre.setString(12, status);

            pre.executeUpdate();
        } catch (SQLException e) {
            System.out.println("Error addMovie: " + e.getMessage());
        }
    }

    public List<Movie> getMoviesByTitle(String keyword) {
        List<Movie> list = new ArrayList<>();
        String sql = """
        SELECT m.MovieID, m.Title, m.Genre, m.Summary, m.TrailerURL, m.Cast, 
<<<<<<< HEAD
               m.Director, m.Duration, m.ReleasedDate, m.EndDate, m.PosterURL, 
=======
               m.Director, m.Duration, m.ReleasedDate, m.PosterURL, 
>>>>>>> 329185d30de73c790fa4e3314fb834db2db85570
               m.Status, l.LanguageName
        FROM Movies m
        JOIN Language l ON m.LanguageID = l.LanguageID
        WHERE m.Title LIKE ?
    """;

        try (PreparedStatement pre = getConnection().prepareStatement(sql)) {
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
                        rs.getDate("EndDate").toLocalDate(), // ✅ đổi từ CreatedDate → EndDate
                        rs.getString("PosterURL"),
                        rs.getString("Status"),

                        rs.getString("LanguageName")

                      
                );
                list.add(movie);
            }
        } catch (SQLException e) {
            System.out.println("Error getMoviesByTitle: " + e.getMessage());
        }
        return list;
    }

    public void updateMovie(int movieID, String title, String genre, String summary,
            String trailerURL, String cast, String director,
            int duration, LocalDate releasedDate, LocalDate endDate, // ✅ thêm endDate
            String posterURL, String status, int languageId) {

        String sql = """
        UPDATE Movies
        SET Title = ?, Genre = ?, Summary = ?, TrailerURL = ?, Cast = ?, Director = ?, 
            Duration = ?, ReleasedDate = ?, EndDate = ?, PosterURL = ?, 
            Status = ?, LanguageID = ?
        WHERE MovieID = ?
    """;

        try (PreparedStatement pre = getConnection().prepareStatement(sql)) {
            pre.setString(1, title);
            pre.setString(2, genre);
            pre.setString(3, summary);
            pre.setString(4, trailerURL);
            pre.setString(5, cast);
            pre.setString(6, director);
            pre.setInt(7, duration);
            pre.setDate(8, java.sql.Date.valueOf(releasedDate));
            pre.setDate(9, java.sql.Date.valueOf(endDate)); // ✅ thêm dòng này
            pre.setString(10, posterURL);
            pre.setString(11, status);
            pre.setInt(12, languageId);
            pre.setInt(13, movieID);

            pre.executeUpdate();
        } catch (SQLException e) {
            System.out.println("Update Movie Error: " + e.getMessage());
        }
    }

    public boolean delete(int movieID) {
        String sql = "DELETE FROM Movies WHERE MovieID = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, movieID);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.out.println("Lỗi khi xóa phim: " + e.getMessage());
        }
        return false;
    }

    public Movie getMovieById(int id) {
        String sql = """
        SELECT m.movieID, m.title, m.genre, m.summary, m.trailerURL, 
               m.cast, m.director, m.duration, m.releasedDate, m.endDate, 
               m.posterURL, m.status, l.languageName
        FROM Movies m
        JOIN Language l ON m.languageID = l.languageID
        WHERE m.movieID = ?
    """;

        try (PreparedStatement pre = getConnection().prepareStatement(sql)) {
            pre.setInt(1, id);
            ResultSet rs = pre.executeQuery();

            if (rs.next()) {
                int movieID = rs.getInt("movieID");
                String title = rs.getString("title");
                String genre = rs.getString("genre");
                String summary = rs.getString("summary");
                String trailerURL = rs.getString("trailerURL");
                String cast = rs.getString("cast");
                String director = rs.getString("director");
                int duration = rs.getInt("duration");
                LocalDate releasedDate = rs.getDate("releasedDate").toLocalDate();
                LocalDate endDate = rs.getDate("endDate").toLocalDate();
                String posterURL = rs.getString("posterURL");
                String status = rs.getString("status");
                String language = rs.getString("languageName");

                return new Movie(movieID, title, genre, summary, trailerURL, cast, director,
                        duration, releasedDate, endDate, posterURL, status, language);
            }
        } catch (SQLException e) {
            System.out.println("Error getMovieById: " + e.getMessage());
        }
        return null;
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

      public List<Movie> getMoviesPaginated(int offset, int limit, String keyword, LocalDate from, LocalDate to, String status) {
    List<Movie> list = new ArrayList<>();

    // ✅ Ngăn lỗi nếu limit = 0 hoặc âm
    if (limit <= 0) {
        limit = 6; // mặc định 6 phim mỗi trang
    }

    StringBuilder sql = new StringBuilder("""
        SELECT m.movieID, m.title, m.genre, m.summary, m.trailerURL, 
               m.cast, m.director, m.duration, m.releasedDate, m.endDate,
               m.posterURL, m.status, l.languageName
        FROM Movies m 
        JOIN Language l ON m.languageID = l.languageID
        WHERE 1=1
    """);

    List<Object> params = new ArrayList<>();

    if (keyword != null && !keyword.isBlank()) {
        sql.append(" AND m.title LIKE ? ");
        params.add("%" + keyword + "%");
    }
    if (from != null) {
        sql.append(" AND m.releasedDate >= ? ");
        params.add(Date.valueOf(from));
    }
    if (to != null) {
        sql.append(" AND m.endDate <= ? ");
        params.add(Date.valueOf(to));
    }
    if (status != null && !status.isBlank()) {
        sql.append(" AND m.status = ? ");
        params.add(status);
    }

    sql.append(" ORDER BY m.movieID DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY ");

    try (PreparedStatement pre = getConnection().prepareStatement(sql.toString())) {
        int index = 1;
        for (Object param : params) {
            pre.setObject(index++, param);
        }
        pre.setInt(index++, offset);
        pre.setInt(index, limit);

        ResultSet rs = pre.executeQuery();
        while (rs.next()) {
            list.add(new Movie(
                    rs.getInt("movieID"),
                    rs.getString("title"),
                    rs.getString("genre"),
                    rs.getString("summary"),
                    rs.getString("trailerURL"),
                    rs.getString("cast"),
                    rs.getString("director"),
                    rs.getInt("duration"),
                    rs.getDate("releasedDate").toLocalDate(),
                    rs.getDate("endDate").toLocalDate(),
                    rs.getString("posterURL"),
                    rs.getString("status"),
                    rs.getString("languageName")
            ));
        }
    } catch (SQLException e) {
        System.out.println("Error getMoviesPaginated: " + e.getMessage());
    }

    return list;
}

    //lay so ban ghi
    public int getTotalMovies(String keyword, LocalDate from, LocalDate to, String status) {
        StringBuilder sql = new StringBuilder("""
        SELECT COUNT(*) 
        FROM Movies m 
        JOIN Language l ON m.languageID = l.languageID
        WHERE 1=1
    """);

        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.isBlank()) {
            sql.append(" AND m.title LIKE ? ");
            params.add("%" + keyword + "%");
        }
        if (from != null) {
            sql.append(" AND m.releasedDate >= ? ");
            params.add(Date.valueOf(from));
        }
        if (to != null) {
            sql.append(" AND m.endDate <= ? ");
            params.add(Date.valueOf(to));
        }
        if (status != null && !status.isBlank()) {
            sql.append(" AND m.status = ? ");
            params.add(status);
        }

        try (PreparedStatement pre = getConnection().prepareStatement(sql.toString())) {
            int i = 1;
            for (Object param : params) {
                pre.setObject(i++, param);
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

    public List<Movie> getMoviesByStatus(String status, String keyword) {
        List<Movie> list = new ArrayList<>();
        String sql = """
        SELECT m.movieID, m.title, m.genre, m.summary, m.trailerURL, 
               m.cast, m.director, m.duration, m.releasedDate, m.endDate, 
               m.posterURL, m.status, l.languageName
        FROM Movies m 
        JOIN Language l ON m.languageID = l.languageID
        WHERE m.status = ?
    """;

        if (!keyword.isBlank()) {
            sql += " AND m.title LIKE ?";
        }

        sql += " ORDER BY m.releasedDate DESC";

        try (PreparedStatement pre = getConnection().prepareStatement(sql)) {
            pre.setString(1, status);
            if (!keyword.isBlank()) {
                pre.setString(2, "%" + keyword + "%");
            }

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
                LocalDate endDate = rs.getDate("endDate").toLocalDate();
                String posterURL = rs.getString("posterURL");
                String movieStatus = rs.getString("status");
                String languageName = rs.getString("languageName");

                list.add(new Movie(movieID, title, genre, summary, trailerURL, cast,
                        director, duration, releasedDate, endDate, posterURL,
                        movieStatus, languageName));
            }
        } catch (SQLException e) {
            System.out.println("Error getMoviesByStatus: " + e.getMessage());
        }
        return list;
    }

    public List<Movie> getActiveMoviesForGuest(String keyword) {
        List<Movie> list = new ArrayList<>();
        String sql = """
        SELECT m.movieID, m.title, m.genre, m.summary, m.trailerURL, 
               m.cast, m.director, m.duration, m.releasedDate, m.endDate, 
               m.posterURL, m.status, l.languageName
        FROM Movies m 
        JOIN Language l ON m.languageID = l.languageID
        WHERE m.status IN ('Active', 'Upcoming')
    """;

        if (keyword != null && !keyword.isBlank()) {
            sql += " AND m.title LIKE ?";
        }

        sql += " ORDER BY m.releasedDate DESC";

        try (PreparedStatement pre = getConnection().prepareStatement(sql)) {
            if (keyword != null && !keyword.isBlank()) {
                pre.setString(1, "%" + keyword + "%");
            }

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
                LocalDate endDate = rs.getDate("endDate").toLocalDate();
                String posterURL = rs.getString("posterURL");
                String status = rs.getString("status");
                String languageName = rs.getString("languageName");

                list.add(new Movie(movieID, title, genre, summary, trailerURL, cast, director,
                        duration, releasedDate, endDate, posterURL, status, languageName));
            }
        } catch (SQLException e) {
            System.out.println("Error getActiveMoviesForGuest: " + e.getMessage());
        }
        return list;
    }


    /**
     * Get all active movies for booking
     */
    public List<Movie> getAllActiveMovies() {
        List<Movie> list = new ArrayList<>();
        String sql = """
                      SELECT m.MovieID, m.Title, m.Genre, m.Summary, m.TrailerURL, 
                             m.Cast, m.Director, m.Duration, m.ReleasedDate, m.PosterURL, 
                             m.Status, l.LanguageName 
                      FROM Movies m 
                      JOIN Language l ON m.LanguageID = l.LanguageID
                      WHERE m.Status = 'Active'
                      ORDER BY m.Title ASC""";
        try {
            PreparedStatement pre = getConnection().prepareStatement(sql);
            ResultSet rs = pre.executeQuery();
            while (rs.next()) {
                int movieID = rs.getInt("MovieID");
                String title = rs.getString("Title");
                String genre = rs.getString("Genre");
                String summary = rs.getString("Summary");
                String trailerURL = rs.getString("TrailerURL");
                String cast = rs.getString("Cast");
                String director = rs.getString("Director");
                int duration = rs.getInt("Duration");
                LocalDate releasedDate = rs.getDate("ReleasedDate").toLocalDate();
                String posterURL = rs.getString("PosterURL");
                String status = rs.getString("Status");
                LocalDateTime createdDate = null; // Movies table doesn't have CreatedDate
                String languageName = rs.getString("LanguageName");
                list.add(new Movie(movieID, title, genre, summary, trailerURL, cast, director, duration, releasedDate, posterURL, status, createdDate, languageName));
            }
        } catch (SQLException e) {
            System.out.println("Error getAllActiveMovies: " + e.getMessage());
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
