/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dal;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author DUNGVT
 */
public class DBContext {

    // Không lưu connection như biến instance nữa
    // Thay vào đó, tạo connection mới mỗi lần cần
    
    // Thông tin kết nối
    private static final String USER = "minhd";
    private static final String PASS = "12345";
    private static final String URL = "jdbc:sqlserver://localhost\\SQLEXPRESS:1433;databaseName=MovieTicketDB;"
            + "sendStringParametersAsUnicode=true;"
            + "characterEncoding=UTF-8;";

    static {
        try {
            // Load driver chỉ một lần
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        } catch (ClassNotFoundException ex) {
            Logger.getLogger(DBContext.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    public DBContext() {
        // Constructor không tạo connection nữa
    }

    // Phương thức để lấy connection mới
    public Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASS);
    }


    public static void main(String[] args) {
        DBContext db = new DBContext();
        try (Connection conn = db.getConnection()) {
            System.out.println(conn != null ? "Connect successful" : "Can't connect to database");
        } catch (SQLException ex) {
            Logger.getLogger(DBContext.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
}
