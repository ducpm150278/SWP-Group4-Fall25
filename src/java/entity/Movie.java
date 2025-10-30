/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package entity;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class Movie {

    private Integer movieID;
    private String title;
    private String genre;
    private String summary;
    private String trailerURL;
    private String cast;
    private String director;
    private Integer duration;
    private LocalDate releasedDate;
    private String posterURL;
    private Integer languageID;
    private String status;
    private LocalDateTime createdDate;
    // Chỉ lưu tên ngôn ngữ
    private String languageName;

    public Movie() {
    }

    public Movie(Integer movieID, String title, String genre, String summary, String trailerURL, String cast, String director, Integer duration,
            LocalDate releasedDate, String posterURL, Integer languageID, String status, LocalDateTime createdDate) {
        this.movieID = movieID;
        this.title = title;
        this.genre = genre;
        this.summary = summary;
        this.trailerURL = trailerURL;
        this.cast = cast;
        this.director = director;
        this.duration = duration;
        this.releasedDate = releasedDate;
        this.posterURL = posterURL;
        this.languageID = languageID;
        this.status = status;
        this.createdDate = createdDate;
    }

    public Movie(int movieID, String title, String genre, String summary, String trailerURL,
            String cast, String director, int duration, LocalDate releasedDate,
            String posterURL, String status, LocalDateTime createdDate,
            String languageName) {
        this.movieID = movieID;
        this.title = title;
        this.genre = genre;
        this.summary = summary;
        this.trailerURL = trailerURL;
        this.cast = cast;
        this.director = director;
        this.duration = duration;
        this.releasedDate = releasedDate;
        this.posterURL = posterURL;
        this.status = status;
        this.createdDate = createdDate;
        this.languageName = languageName;
    }

    // Getters and Setters
    public Integer getMovieID() {
        return movieID;
    }

    public void setMovieID(Integer movieID) {
        this.movieID = movieID;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getGenre() {
        return genre;
    }

    public void setGenre(String genre) {
        this.genre = genre;
    }

    public String getSummary() {
        return summary;
    }

    public void setSummary(String summary) {
        this.summary = summary;
    }

    public String getTrailerURL() {
        return trailerURL;
    }

    public void setTrailerURL(String trailerURL) {
        this.trailerURL = trailerURL;
    }

    public String getCast() {
        return cast;
    }

    public void setCast(String cast) {
        this.cast = cast;
    }

    public String getDirector() {
        return director;
    }

    public void setDirector(String director) {
        this.director = director;
    }

    public Integer getDuration() {
        return duration;
    }

    public void setDuration(Integer duration) {
        this.duration = duration;
    }

    public LocalDate getReleasedDate() {
        return releasedDate;
    }

    public void setReleasedDate(LocalDate releasedDate) {
        this.releasedDate = releasedDate;
    }

    public String getPosterURL() {
        return posterURL;
    }

    public void setPosterURL(String posterURL) {
        this.posterURL = posterURL;
    }

    public Integer getLanguageID() {
        return languageID;
    }

    public void setLanguageID(Integer languageID) {
        this.languageID = languageID;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public LocalDateTime getCreatedDate() {
        return createdDate;
    }

    public void setCreatedDate(LocalDateTime createdDate) {
        this.createdDate = createdDate;
    }

    public String getLanguageName() {
        return languageName;
    }

    public void setLanguageName(String languageName) {
        this.languageName = languageName;
    }

    public String getFormattedReleasedDate() {
        if (releasedDate == null) {
            return "";
        }
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd-MM-yyyy");
        return releasedDate.format(formatter);
    }

    @Override
    public String toString() {
        return "Movie{"
                + "movieID=" + movieID
                + ", title='" + title + '\''
                + ", genre='" + genre + '\''
                + ", summary='" + summary + '\''
                + ", trailerURL='" + trailerURL + '\''
                + ", cast='" + cast + '\''
                + ", director='" + director + '\''
                + ", duration=" + duration
                + ", releasedDate=" + releasedDate
                + ", posterURL='" + posterURL + '\''
                + ", status='" + status + '\''
                + ", createdDate=" + createdDate
                + ", languageName='" + languageName + '\''
                + '}';
    }
}
