/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dal;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Date;
import entity.User;
import java.security.SecureRandom;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Random;
import java.text.Normalizer;
import java.time.LocalDate;
import java.util.Locale;
import java.util.concurrent.ThreadLocalRandom;
import java.util.regex.Pattern;

/**
 *
 * @author dungv
 */
public class UserDAO extends DBContext{

    // Test function
    public static void main(String[] args) {
        UserDAO ud = new UserDAO();

        // Test get all user infor
//        for (User user : ud.getAllUser()) {
//            System.out.println(user);
//        }
        // Test add new account
        Random random = new Random();

        // Gender data
        String[] gender = {"Male", "Female", "Other"};

        // Role data
        String[] role = {"Administrator", "InventoryManager", "StoreManager", "Salesperson"};

        //Status data
        String[] status = {"Active", "Suspend"};

        // Generator user data
        String fullName;

//        for (int i = 0; i < 20; i++) {
//            //Get fullname data
//            fullName = ud.generateRandomFullName();
//
//            ud.addNewUser(fullName, ud.generateRandomEmail(fullName), ud.generatePhoneNumber(), ud.generatePassword(12),
//                    gender[random.nextInt(gender.length)], role[random.nextInt(role.length)], ud.generateAddress(),
//                    Date.valueOf(ud.generateRandomDOB(18, 55)), status[random.nextInt(status.length)]);
//        }
        // Test delete user
//            ud.deleteUser(1);
        // Test update uset setting
//        ud.updateSettingUser(role[random.nextInt(role.length)], status[random.nextInt(status.length)], 7);
        // Test get user by id
//        System.out.println(ud.getUserByID(7));
        // Test filter list user
        for (User allUser : ud.getAllUsers(null, "all", "all", "name_asc")) {
            System.out.println(allUser);
        }
    }

// Account generator
    // Address generator
    public String generateAddress() {
        Random random = new Random();
        String[] STREETS = {
            "Lê Lợi", "Nguyễn Huệ", "Trần Hưng Đạo", "Hai Bà Trưng", "Cách Mạng Tháng 8",
            "Điện Biên Phủ", "Nguyễn Thị Minh Khai", "Pasteur", "Hoàng Văn Thụ", "Lý Thường Kiệt"
        };

        String[] WARDS = {
            "Phường Bến Nghé", "Phường Bến Thành", "Phường Nguyễn Cư Trinh", "Phường 1", "Phường 2",
            "Phường Tân Định", "Phường Phạm Ngũ Lão"
        };

        String[] DISTRICTS = {
            "Quận 1", "Quận 3", "Quận 5", "Quận 7", "Quận Bình Thạnh", "Quận Gò Vấp", "Quận Tân Bình"
        };

        String[] CITIES = {
            "TP. Hồ Chí Minh", "Hà Nội", "Đà Nẵng", "Cần Thơ", "Hải Phòng", "Huế"
        };

        int number = 1 + random.nextInt(999);  // số nhà từ 1 đến 999
        String street = STREETS[random.nextInt(STREETS.length)];
        String ward = WARDS[random.nextInt(WARDS.length)];
        String district = DISTRICTS[random.nextInt(DISTRICTS.length)];
        String city = CITIES[random.nextInt(CITIES.length)];

        return number + " Đường " + street + ", " + ward + ", " + district + ", " + city;
    }

    // Phone generator
    public String generatePhoneNumber() {
        Random random = new Random();

        String[] PREFIXES = {
            "032", "033", "034", "035", "036", "037", "038", "039", // Viettel
            "070", "076", "077", "078", "079", // Mobifone
            "083", "084", "085", "081", "082", // Vinaphone
            "056", "058", // Vietnamobile
            "059" // Gmobile
        };

        // Chọn đầu số ngẫu nhiên
        String prefix = PREFIXES[random.nextInt(PREFIXES.length)];

        // Sinh 7 chữ số còn lại (3 + 4)
        int middle = 100 + random.nextInt(900);     // đảm bảo có 3 chữ số
        int last = 1000 + random.nextInt(9000);     // đảm bảo có 4 chữ số

        return prefix + " " + middle + " " + last;
    }

    // Password generator
    public String generatePassword(int length) {
        String UPPER = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        String LOWER = "abcdefghijklmnopqrstuvwxyz";
        String DIGITS = "0123456789";
        String SPECIAL = "!@#$%^&*()-_+=<>?";

        String ALL_ALLOWED = UPPER + LOWER + DIGITS + SPECIAL;

        if (length < 4) {
            throw new IllegalArgumentException("Độ dài mật khẩu phải ít nhất 4 ký tự");
        }

        SecureRandom random = new SecureRandom();
        List<Character> password = new ArrayList<>();

        // Đảm bảo ít nhất 1 ký tự từ mỗi nhóm
        password.add(UPPER.charAt(random.nextInt(UPPER.length())));
        password.add(DIGITS.charAt(random.nextInt(DIGITS.length())));
        password.add(SPECIAL.charAt(random.nextInt(SPECIAL.length())));
        password.add(LOWER.charAt(random.nextInt(LOWER.length())));

        // Thêm các ký tự còn lại
        for (int i = 4;
                i < length;
                i++) {
            password.add(ALL_ALLOWED.charAt(random.nextInt(ALL_ALLOWED.length())));
        }

        // Trộn ngẫu nhiên để phân tán các ký tự đặc biệt
        Collections.shuffle(password, random);

        // Chuyển danh sách sang chuỗi
        StringBuilder sb = new StringBuilder();
        for (char ch : password) {
            sb.append(ch);
        }

        return sb.toString();
    }

    //Fullname generator
    public String generateRandomFullName() {
        Random random = new Random();
        String[] FIRST_NAMES = {
            "Nguyễn", "Trần", "Lê", "Phạm", "Hoàng", "Võ", "Đặng", "Bùi", "Đỗ", "Hồ"
        };

        String[] MIDDLE_NAMES = {
            "Văn", "Thị", "Hữu", "Quang", "Gia", "Thanh", "Ngọc", "Minh", "Xuân", "Phúc"
        };

        String[] LAST_NAMES = {
            "An", "Bình", "Chi", "Dũng", "Hạnh", "Hòa", "Khánh", "Lan", "Nam", "Tú"
        };
        String first = FIRST_NAMES[random.nextInt(FIRST_NAMES.length)];
        String middle = MIDDLE_NAMES[random.nextInt(MIDDLE_NAMES.length)];
        String last = LAST_NAMES[random.nextInt(LAST_NAMES.length)];

        return first + " " + middle + " " + last;
    }

    // Xóa dấu tiếng Việt, chuyển thành dạng ascii
    private static String normalize(String input) {
        String normalized = Normalizer.normalize(input, Normalizer.Form.NFD);
        Pattern pattern = Pattern.compile("\\p{InCombiningDiacriticalMarks}+");
        return pattern.matcher(normalized).replaceAll("").toLowerCase(Locale.ROOT);
    }

    public static String generateRandomEmail(String fullName) {
        String normalized = normalize(fullName); // ví dụ: "Nguyễn Văn An" → "nguyen van an"
        String[] parts = normalized.split(" ");
        StringBuilder emailName = new StringBuilder();

        for (int i = 0; i < parts.length; i++) {
            emailName.append(parts[i]);
        }

        // Thêm số ngẫu nhiên để tránh trùng
        Random random = new Random();
        int number = 10 + random.nextInt(90);

        String[] DOMAINS = {
            "@gmail.com", "@yahoo.com", "@outlook.com", "@example.com"
        };

        String domain = DOMAINS[random.nextInt(DOMAINS.length)];
        return emailName + String.valueOf(number) + domain;
    }

    // Date of birth generator
    public LocalDate generateRandomDOB(int minAge, int maxAge) {
        LocalDate today = LocalDate.now();

        // Ngày sinh trễ nhất (tức là trẻ nhất)
        LocalDate minDate = today.minusYears(minAge);
        // Ngày sinh sớm nhất (tức là già nhất)
        LocalDate maxDate = today.minusYears(maxAge);

        long minDay = maxDate.toEpochDay();  // Giới hạn dưới
        long maxDay = minDate.toEpochDay();  // Giới hạn trên

        long randomDay = ThreadLocalRandom.current().nextLong(minDay, maxDay + 1);

        return LocalDate.ofEpochDay(randomDay);
    }

// Database access object
// Get all user infor
    public List<User> getAllUser() {
        List<User> list = new ArrayList<>();
        String sql = "SELECT [UserID]\n"
                + "      ,[FullName]\n"
                + "      ,[Email]\n"
                + "      ,[PhoneNumber]\n"
                + "      ,[Password]\n"
                + "      ,[Gender]\n"
                + "      ,[role]\n"
                + "      ,[Address]\n"
                + "      ,[DateOfBirth]\n"
                + "      ,[Status]\n"
                + "      ,[CreatedAt]\n"
                + "      ,[UpdatedAt]\n"
                + "  FROM [dbo].[Users]";
        try {
            PreparedStatement ps = getConnection().prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(new User(rs.getInt(1), rs.getString(2), rs.getString(3), rs.getString(4),
                        rs.getString(5), rs.getString(6), rs.getString(7), rs.getString(8), rs.getDate(9), rs.getString(10)));
            }
        } catch (SQLException e) {
            System.out.println(e);
        }
        return list;
    }

    // Add new user
    public boolean addNewUser(String fullname, String email, String phonenumber, String password, String gender, String role, String address, Date dob, String status) {
        String sql = "INSERT INTO [dbo].[Users]\n"
                + "           ([FullName]\n"
                + "           ,[Email]\n"
                + "           ,[PhoneNumber]\n"
                + "           ,[Password]\n"
                + "           ,[Gender]\n"
                + "           ,[role]\n"
                + "           ,[Address]\n"
                + "           ,[DateOfBirth]\n"
                + "           ,[Status]\n"
                + "           ,[CreatedAt]\n"
                + "           ,[UpdatedAt])\n"
                + "     VALUES"
                + "           (?,?,?,?,?,?,?,?,?,GETDATE(),GETDATE())";
        try {
            PreparedStatement ps = getConnection().prepareStatement(sql);
            ps.setString(1, fullname);
            ps.setString(2, email);
            ps.setString(3, phonenumber);
            ps.setString(4, password);
            ps.setString(5, gender);
            ps.setString(6, role);
            ps.setString(7, address);
            ps.setDate(8, dob);
            ps.setString(9, status);
            ps.executeUpdate();
            return true;
        } catch (SQLException e) {
            System.out.println(e);
            return false;
        }
    }

    // Delete user
    public boolean deleteUser(int user_id) {
        String sql = "DELETE FROM [dbo].[Users] WHERE UserID = ?";
        try {
            PreparedStatement ps = getConnection().prepareStatement(sql);
            ps.setInt(1, user_id);
            ps.executeUpdate();
            return true;
        } catch (SQLException e) {
            System.out.println(e);
            return false;
        }
    }

    // Update setting user (only role and status)
    public boolean updateSettingUser(String role, String status, int user_id) {
        String sql = "UPDATE  [dbo].[Users] SET [role] = ?,"
                + "[Status] = ?, UpdatedAt = GETDATE() WHERE [UserID] = ?";
        try {
            PreparedStatement ps = getConnection().prepareStatement(sql);
            ps.setString(1, role);
            ps.setString(2, status);
            ps.setInt(3, user_id);
            ps.executeUpdate();
            return true;
        } catch (SQLException e) {
            System.out.println(e);
            return false;
        }
    }

    // Get user by input ID
    public User getUserByID(int user_Id) {
        String sql = "SELECT [FullName]\n"
                + "      ,[Email]\n"
                + "      ,[PhoneNumber]\n"
                + "      ,[Password]\n"
                + "      ,[Gender]\n"
                + "      ,[role]\n"
                + "      ,[Address]\n"
                + "      ,[DateOfBirth]\n"
                + "      ,[Status]\n"
                + "      ,[CreatedAt]\n"
                + "      ,[UpdatedAt]\n"
                + "  FROM [dbo].[Users] WHERE [UserID] = ?";
        try {
            PreparedStatement ps = getConnection().prepareStatement(sql);
            ps.setInt(1, user_Id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return new User(user_Id, rs.getString(1), rs.getString(2), rs.getString(3),
                        rs.getString(4), rs.getString(5), rs.getString(6), rs.getString(7), rs.getDate(8), rs.getString(9));
            }
        } catch (SQLException e) {
            System.out.println(e);
        }
        return null;
    }

    // Check existed email
    public boolean checkExistedEmail(String email) {
        String sql = "SELECT 1 FROM dbo.Users WHERE [Email] = ?";
        try {
            PreparedStatement ps = getConnection().prepareStatement(sql);
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            System.out.println(e);
            return false;
        }
    }

    // Check existed phone
    public boolean checkExistedPhone(String phone) {
        String sql = "SELECT 1 FROM dbo.Users WHERE [PhoneNumber] = ?";
        try {
            PreparedStatement ps = getConnection().prepareStatement(sql);
            ps.setString(1, phone);
            ResultSet rs = ps.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            System.out.println(e);
            return false;
        }
    }

    // Lấy danh sách user với sort, search và filter
    public List<User> getAllUsers(String search, String roleFilter, String statusFilter, String sortBy) {
        List<User> list = new ArrayList<>();
        String sql = "SELECT * FROM [dbo].[Users] WHERE 1=1";

        // Thêm điều kiện search
        if (search != null && !search.trim().isEmpty()) {
            sql += " AND ([FullName] LIKE ? OR [Email] LIKE ? OR [PhoneNumber] LIKE ?)";
        }

        // Thêm điều kiện filter role
        if (roleFilter != null && !roleFilter.equals("all")) {
            sql += " AND [role] = ?";
        }

        // Thêm điều kiện filter status
        if (statusFilter != null && !statusFilter.equals("all")) {
            sql += " AND [Status] = ?";
        }

        // Thêm điều kiện sort
        if (sortBy != null) {
            switch (sortBy) {
                case "name_asc" ->
                    sql += " ORDER BY [FullName] ASC";
                case "name_desc" ->
                    sql += " ORDER BY [FullName] DESC";
            }
        }

        try {
            PreparedStatement ps = getConnection().prepareStatement(sql);
            int paramIndex = 1;

            // Set parameters cho search
            if (search != null && !search.trim().isEmpty()) {
                String searchPattern = "%" + search + "%";
                ps.setString(paramIndex++, searchPattern); // set fullname value
                ps.setString(paramIndex++, searchPattern); // set email value
                ps.setString(paramIndex++, searchPattern); // set phone value
            }

            // Set parameters cho role filter
            if (roleFilter != null && !roleFilter.equals("all")) {
                ps.setString(paramIndex++, roleFilter);
            }

            // Set parameters cho status filter
            if (statusFilter != null && !statusFilter.equals("all")) {
                ps.setString(paramIndex++, statusFilter);
            }

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                list.add(new User(rs.getInt(1), rs.getString(2), rs.getString(3), rs.getString(4),
                        rs.getString(5), rs.getString(6), rs.getString(7), rs.getString(8), rs.getDate(9), rs.getString(10)));
            }
        } catch (SQLException e) {
            System.out.println(e);
        }

        return list;
    }

    // Get account by email and pass
    public User authenticate(String email, String password) {
        String sql = "SELECT [UserID]\n"
                + "      ,[FullName]\n"
                + "      ,[Email]\n"
                + "      ,[PhoneNumber]\n"
                + "      ,[Password]\n"
                + "      ,[Gender]\n"
                + "      ,[role]\n"
                + "      ,[Address]\n"
                + "      ,[DateOfBirth]\n"
                + "      ,[Status]\n"
                + "  FROM [dbo].[Users] WHERE [Email] = ? AND [Password] = ?";
        try {
            PreparedStatement ps = getConnection().prepareStatement(sql);
            ps.setString(1, email);
            ps.setString(2, password);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return new User(rs.getInt(1), rs.getString(2), rs.getString(3), rs.getString(4),
                        rs.getString(5), rs.getString(6), rs.getString(7), rs.getString(8), rs.getDate(9), rs.getString(10));
            }
        } catch (SQLException e) {
            System.out.println(e);
        }
        return null;
    }

    // Reset password for temporary account
    public boolean updatePasswordTempAcc(int userId, String newPassword) {
        String sql = "UPDATE Users SET Password = ?, UpdatedAt = GETDATE() WHERE UserID = ?";
        try {
            PreparedStatement ps = getConnection().prepareStatement(sql);
            ps.setString(1, newPassword);
            ps.setInt(2, userId);
            return ps.execute();
        } catch (SQLException e) {
            System.out.println(e);
            return false;
        }
    }

    // Finish profile for temporary account
    public boolean updateProfileTempAcc(int userId, String gender, String address, String dob) {
        String sql = "UPDATE Users SET Gender = ?, Address = ?, DateOfBirth = ?, UpdatedAt = GETDATE() WHERE UserID = ?";
        try {
            PreparedStatement ps = getConnection().prepareStatement(sql);
            ps.setString(1, gender);
            ps.setString(2, address);
            ps.setString(3, dob);
            ps.setInt(4, userId);
            return ps.execute();
        } catch (SQLException e) {
            System.out.println(e);
            return false;
        }
    }

    // Set status for account after finish information
    public boolean updateStatusForTempAcc(int userId, String status) {
        String sql = "UPDATE Users SET Status = ?, UpdatedAt = GETDATE() WHERE UserID = ?";
        try {
            PreparedStatement ps = getConnection().prepareStatement(sql);
            ps.setString(1, status);
            ps.setInt(2, userId);
            return ps.execute();
        } catch (SQLException e) {
            System.out.println(e);
            return false;
        }
    }
}
