package controller;

import dal.CinemaMDAO;
import dal.ScreeningRoomDAO;
import dal.SeatMDAO;
import dal.UserDAO;
import entity.CinemaM;
import entity.ScreeningRoom;
import entity.SeatM;
import entity.User;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.sql.Date;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;
import utils.EmailService;
import utils.SeatLayout;

/**
 *
 * @author dungv
 */
@WebServlet(name = "AdminDashboardServlet", urlPatterns = {"/adminFE/dashboard"})
public class AdminDashboardServlet extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet NewServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet NewServlet at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        UserDAO ud = new UserDAO();
        CinemaMDAO cd = new CinemaMDAO();
        try {
            String section = request.getParameter("section");
            System.out.println(section);
            if (section != null && section.equals("user-management")) {
                try {
                    String action = request.getParameter("action");
                    if (action != null) {
                        // Check view list or view detail
                        if (action.equals("view")) {
                            int user_Id = Integer.parseInt(request.getParameter("userId"));
                            User user = ud.getUserByID(user_Id);
                            if (user != null) {
                                System.out.println("User found: " + user.getFullName());
                            }
                            request.setAttribute("viewUser", user);
                        }
                    }
                } catch (NumberFormatException e) {
                    System.out.println("Error parsing user ID: " + e.getMessage());
                }

                // Get param for filter list
                String search = request.getParameter("search");
                String roleFilter = request.getParameter("role");
                String statusFilter = request.getParameter("status");
                String sortBy = request.getParameter("sort");

                // Set value get all in case role or status filter is null
                if (roleFilter == null) {
                    roleFilter = "all";
                }
                if (statusFilter == null) {
                    statusFilter = "all";
                }

                // Get list user after filter và sort
                List<User> listU = ud.getAllUsers(search, roleFilter, statusFilter, sortBy);
                System.out.println(listU);
                // Page setting
                int page = 1;
                int recordsPerPage = 10;
                try {
                    page = Integer.parseInt(request.getParameter("page"));
                } catch (NumberFormatException e) {
                    System.out.println("Error parsing page number: " + e.getMessage());
                }

                // Kiểm tra nếu danh sách rỗng
                boolean isEmptyList = listU.isEmpty();
                request.setAttribute("isEmptyList", isEmptyList);

                // Phân trang (chỉ thực hiện nếu danh sách không rỗng)
                if (!isEmptyList) {
                    List<User> usersPerPage = listU.stream()
                            .skip((page - 1) * recordsPerPage)
                            .limit(recordsPerPage)
                            .collect(Collectors.toList());
                    int noOfRecords = listU.size();
                    int noOfPages = (int) Math.ceil(noOfRecords * 1.0 / recordsPerPage);

                    request.setAttribute("listU", usersPerPage);
                    request.setAttribute("recordsPerPage", recordsPerPage);
                    request.setAttribute("noOfPages", noOfPages);
                }
                request.setAttribute("currentPage", page);
                request.setAttribute("search", search);
                request.setAttribute("roleFilter", roleFilter);
                request.setAttribute("statusFilter", statusFilter);
                request.setAttribute("section", section);
            } else if (section != null && section.equals("cinema-management")) {
                try {
                    String action = request.getParameter("action");
                    if (action != null) {
                        // Check view list or view detail
                        if (action.equals("view")) {
                            int cinemaId = Integer.parseInt(request.getParameter("cinemaId"));
                            CinemaM cinema = cd.getCinemaById(cinemaId);
                            if (cinema != null) {
                                System.out.println("Cinema found: " + cinema.getCinemaName());
                            }

                            ScreeningRoomDAO roomDAO = new ScreeningRoomDAO();
                            List<ScreeningRoom> screeningRooms = roomDAO.getScreeningRoomsByCinemaId(cinemaId);
                            request.setAttribute("screeningRooms", screeningRooms);
                            request.setAttribute("viewCinema", cinema);
                        }
                    }
                } catch (NumberFormatException e) {
                    System.out.println("Error parsing cinema ID: " + e.getMessage());
                }

                // Get param for filter list
                String search = request.getParameter("search");
                String statusFilter = request.getParameter("status");
                String locationFilter = request.getParameter("location"); // Thêm location filter
                String sortBy = request.getParameter("sort");

                // Set default values if filters are null
                if (statusFilter == null) {
                    statusFilter = "all";
                }
                if (locationFilter == null) {
                    locationFilter = "all";
                }

                // Get list cinema after filter và sort (cập nhật thêm locationFilter)
                List<CinemaM> listCinemas = cd.getAllCinemas(search, statusFilter, locationFilter, sortBy);
                System.out.println("Cinemas found: " + listCinemas.size());

                // Page setting
                int page = 1;
                int recordsPerPage = 10;
                try {
                    page = Integer.parseInt(request.getParameter("page"));
                } catch (NumberFormatException e) {
                    System.out.println("Error parsing page number: " + e.getMessage());
                }

                // Kiểm tra nếu danh sách rỗng
                boolean isEmptyList = listCinemas.isEmpty();
                request.setAttribute("isEmptyList", isEmptyList);

                // Phân trang (chỉ thực hiện nếu danh sách không rỗng)
                if (!isEmptyList) {
                    List<CinemaM> cinemasPerPage = listCinemas.stream()
                            .skip((page - 1) * recordsPerPage)
                            .limit(recordsPerPage)
                            .collect(Collectors.toList());
                    int noOfRecords = listCinemas.size();
                    int noOfPages = (int) Math.ceil(noOfRecords * 1.0 / recordsPerPage);

                    request.setAttribute("listCinemas", cinemasPerPage);
                    request.setAttribute("recordsPerPage", recordsPerPage);
                    request.setAttribute("noOfPages", noOfPages);
                }

                // Lấy danh sách locations để hiển thị trong dropdown
                List<String> allLocations = cd.getAllLocations();
                request.setAttribute("allLocations", allLocations);

                request.setAttribute("currentPage", page);
                request.setAttribute("search", search);
                request.setAttribute("statusFilter", statusFilter);
                request.setAttribute("locationFilter", locationFilter); // Thêm locationFilter
                request.setAttribute("section", section);
            } else if (section != null && section.equals("screening-room-management")) {
                ScreeningRoomDAO roomDAO = new ScreeningRoomDAO();
                CinemaMDAO cinemaDAO = new CinemaMDAO();
                SeatMDAO seatDAO = new SeatMDAO();

                try {
                    String action = request.getParameter("action");

//                    System.out.println("=== SCREENING ROOM MANAGEMENT DEBUG ===");
//                    System.out.println("Action: " + action);
//                    System.out.println("Section: " + section);
                    // Xử lý generate seats
                    if ("generateSeats".equals(action)) {
                        try {
                            int roomId = Integer.parseInt(request.getParameter("roomId"));

                            ScreeningRoom room = roomDAO.getRoomById(roomId);
                            if (room == null) {
                                request.getSession().setAttribute("showToast", "generate_error");
                                request.getSession().setAttribute("showError", "Room not found");
                                response.sendRedirect("dashboard?section=screening-room-management&action=edit&id=" + roomId);
                                return;
                            }

                            // Tạo seats mặc định
                            SeatLayout layout = new SeatLayout();
                            List<SeatM> seats = layout.generateSeats(roomId, room.getRoomType());

                            // Xóa seats cũ (nếu có)
                            seatDAO.deleteSeatsByRoom(roomId);

                            // Lưu seats mới
                            boolean seatsCreated = seatDAO.createBulkSeats(seats);

                            if (seatsCreated) {
                                // Cập nhật seat capacity
                                room.setSeatCapacity(seats.size());
                                roomDAO.updateRoom(room);

                                request.getSession().setAttribute("showToast", "generate_success");
                                request.getSession().setAttribute("showMessage", "Generated " + seats.size() + " seats successfully");
                            } else {
                                request.getSession().setAttribute("showToast", "generate_error");
                                request.getSession().setAttribute("showError", "Failed to generate seats");
                            }

                            response.sendRedirect("dashboard?section=screening-room-management&action=edit&id=" + roomId);
                            return;

                        } catch (NumberFormatException e) {
                            request.getSession().setAttribute("showToast", "generate_error");
                            request.getSession().setAttribute("showError", "Invalid room ID");
                            response.sendRedirect("dashboard?section=screening-room-management");
                            return;
                        }
                    }

                    // Xử lý edit seat - PHẢI ĐẶT Ở ĐẦU VÀ RETURN SAU KHI XỬ LÝ
                    if ("editSeat".equals(action)) {
                        try {
                            int seatId = Integer.parseInt(request.getParameter("seatId"));
                            int roomId = Integer.parseInt(request.getParameter("roomId"));

//                            System.out.println("=== EDIT SEAT PROCESSING ===");
//                            System.out.println("SeatID: " + seatId);
//                            System.out.println("RoomID: " + roomId);
                            // Lấy thông tin seat
                            SeatM seat = seatDAO.getSeatById(seatId);
//                            System.out.println("Seat found: " + (seat != null));

                            // Lấy thông tin room
                            ScreeningRoom room = roomDAO.getRoomById(roomId);
//                            System.out.println("Room found: " + (room != null));

                            if (seat != null && room != null) {
                                // Set attributes cho JSP
                                request.setAttribute("editSeat", seat);
                                request.setAttribute("viewRoom", room);

                                // Lấy danh sách seats để hiển thị layout
                                List<SeatM> seats = seatDAO.getSeatsByRoom(roomId);
                                request.setAttribute("seats", seats);

//                                System.out.println("Seat position: " + seat.getSeatPosition());
//                                System.out.println("Room name: " + room.getRoomName());
//                                System.out.println("Total seats: " + (seats != null ? seats.size() : 0));
                                // QUAN TRỌNG: Set section và forward
                                request.setAttribute("section", section);

//                                System.out.println("=== FORWARDING TO EDIT_SEAT.JSP ===");
                                request.getRequestDispatcher("admin_dashboard.jsp").forward(request, response);
                                return;

                            } else {
                                System.out.println("ERROR: Seat or Room not found");
                                request.getSession().setAttribute("showToast", "error");
                                request.getSession().setAttribute("showError", "Seat or room not found");
                                response.sendRedirect("dashboard?section=screening-room-management&action=edit&id=" + roomId);
                                return;
                            }

                        } catch (NumberFormatException e) {
                            System.out.println("ERROR parsing IDs: " + e.getMessage());
                            request.getSession().setAttribute("showToast", "error");
                            request.getSession().setAttribute("showError", "Invalid seat or room ID");
                            response.sendRedirect("dashboard?section=screening-room-management");
                            return;
                        }
                    }

                    // Xử lý view, edit, create, list
                    if (action != null && (action.equals("view") || action.equals("edit") || action.equals("create"))) {
                        if (action.equals("view") || action.equals("edit")) {
                            int roomId = Integer.parseInt(request.getParameter("id"));
                            ScreeningRoom room = roomDAO.getRoomById(roomId);
                            if (room != null) {
//                                System.out.println("Room found: " + room.getRoomName());
                                request.setAttribute("viewRoom", room);

                                // Lấy danh sách ghế
                                List<SeatM> seats = seatDAO.getSeatsByRoom(roomId);
                                request.setAttribute("seats", seats);
//                                System.out.println("Seats loaded: " + (seats != null ? seats.size() : 0));
                            }
                        } else if (action.equals("create")) {
                            // Xử lý cho create action
                            String cinemaIdParam = request.getParameter("cinemaId");
                            if (cinemaIdParam != null) {
                                try {
                                    int cinemaId = Integer.parseInt(cinemaIdParam);
                                    CinemaM cinema = cinemaDAO.getCinemaById(cinemaId);
                                    request.setAttribute("cinema", cinema);
                                } catch (NumberFormatException e) {
                                    System.out.println("Invalid cinema ID: " + cinemaIdParam);
                                }
                            }
                        }
                        request.setAttribute("section", section);
                    } else {
                        // Get parameters for filtering
                        String search = request.getParameter("search");
                        String statusFilter = request.getParameter("status");
                        String roomTypeFilter = request.getParameter("roomType");
                        String locationFilter = request.getParameter("locationFilter");
                        String cinemaFilter = request.getParameter("cinemaFilter");

                        // Set default values
                        if (statusFilter == null) {
                            statusFilter = "all";
                        }
                        if (roomTypeFilter == null) {
                            roomTypeFilter = "all";
                        }
                        if (locationFilter == null || locationFilter.isEmpty()) {
                            locationFilter = "none";
                        }
                        if (cinemaFilter == null || cinemaFilter.isEmpty()) {
                            cinemaFilter = "none";
                        }

                        // Parse cinema filter
                        Integer cinemaId = null;
                        if (cinemaFilter != null && !cinemaFilter.isEmpty()) {
                            try {
                                cinemaId = Integer.valueOf(cinemaFilter);
//                                System.out.println("Parsed cinemaId: " + cinemaId);
                            } catch (NumberFormatException e) {
                                System.out.println("Error parsing cinema filter: " + e.getMessage());
                            }
                        }

                        // Page settings
                        int page = 1;
                        int recordsPerPage = 10;
                        try {
                            page = Integer.parseInt(request.getParameter("page"));
                        } catch (NumberFormatException e) {
                            System.out.println("Error parsing page number: " + e.getMessage());
                        }

                        // THÊM: Kiểm tra xem đã chọn đủ location và cinema chưa
                        boolean hasValidFilters = !"none".equals(locationFilter) && !"none".equals(cinemaFilter);

                        List<ScreeningRoom> rooms = new ArrayList<>();
                        int totalRecords = 0;
                        int noOfPages = 0;

                        // Chỉ lấy dữ liệu nếu đã chọn đủ filter
                        if (hasValidFilters) {
                            // Get rooms with filters
                            rooms = roomDAO.getRoomsWithFilters(
                                    locationFilter, cinemaId, roomTypeFilter, statusFilter,
                                    search, (page - 1) * recordsPerPage, recordsPerPage
                            );

                            // Count total for pagination
                            totalRecords = roomDAO.countRoomsWithFilters(
                                    locationFilter, cinemaId, roomTypeFilter, statusFilter, search
                            );
                            noOfPages = (int) Math.ceil(totalRecords * 1.0 / recordsPerPage);
                        }

                        System.out.println("Total records: " + totalRecords + ", Pages: " + noOfPages);

                        // Get available data for filters
                        List<String> locations = cinemaDAO.getAllLocations();
                        List<String> roomTypes = roomDAO.getAvailableRoomTypes();
                        List<CinemaM> cinemas = new ArrayList<>();

                        // Load cinemas based on location filter
                        if (locationFilter != null && !locationFilter.isEmpty() && !locationFilter.equals("none")) {
                            cinemas = cinemaDAO.getCinemasByLocation(locationFilter);
                            System.out.println("Cinemas for location '" + locationFilter + "': " + cinemas.size());
                        }

                        // THÊM: Thêm option "None" vào danh sách locations và cinemas
                        List<String> allLocationsWithNone = new ArrayList<>();
                        allLocationsWithNone.add("none");
                        allLocationsWithNone.addAll(locations);

                        List<CinemaM> cinemasWithNone = new ArrayList<>();
                        // Tạo một cinema "None" giả
                        CinemaM noneCinema = new CinemaM();
                        noneCinema.setCinemaID(-1);
                        noneCinema.setCinemaName("None");
                        noneCinema.setLocation("none");
                        cinemasWithNone.add(noneCinema);
                        cinemasWithNone.addAll(cinemas);

                        // Set request attributes
                        request.setAttribute("listRooms", rooms);
                        request.setAttribute("currentPage", page);
                        request.setAttribute("recordsPerPage", recordsPerPage);
                        request.setAttribute("noOfPages", noOfPages);
                        request.setAttribute("search", search);
                        request.setAttribute("statusFilter", statusFilter);
                        request.setAttribute("roomTypeFilter", roomTypeFilter);
                        request.setAttribute("locationFilter", locationFilter);
                        request.setAttribute("cinemaFilter", cinemaFilter);
                        request.setAttribute("allLocations", allLocationsWithNone); // Sử dụng danh sách mới
                        request.setAttribute("allRoomTypes", roomTypes);
                        request.setAttribute("cinemasByLocation", cinemasWithNone); // Sử dụng danh sách mới
                        request.setAttribute("section", section);
                        request.setAttribute("hasValidFilters", hasValidFilters); // THÊM: flag để kiểm tra trong JSP
                    }

                } catch (NumberFormatException e) {
                    System.out.println("Error in room-management doGet: " + e.getMessage());
                }
            }

            response.setContentType("text/html;charset=UTF-8");
            request.setCharacterEncoding("UTF-8");
            request.getRequestDispatcher("admin_dashboard.jsp").forward(request, response);
        } catch (ServletException | IOException e) {
            System.out.println("Error in doGet: " + e.getMessage());
        }
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String section = request.getParameter("section");
            if (section != null && section.equals("user-management")) {
                UserDAO ud = new UserDAO();
                EmailService es = new EmailService();
//                LogHistoryDAO lhd = new LogHistoryDAO();

                String action = request.getParameter("action");
                switch (action) {
                    case "add" -> {
                        try {
                            // Get and trim data
                            String fullname = request.getParameter("fullname").trim();
                            String email = request.getParameter("email").trim().toLowerCase();
                            String phone = request.getParameter("phonenumber").trim();
                            String role = request.getParameter("role");

                            System.out.println("=== ADD USER DEBUG ===");
                            System.out.println("Fullname: " + fullname);
                            System.out.println("Email: " + email);
                            System.out.println("Phone: " + phone);
                            System.out.println("Role: " + role);

                            // Validate required fields
                            if (fullname.isEmpty() || email.isEmpty() || phone.isEmpty() || role == null || role.isEmpty()) {
                                request.getSession().setAttribute("showToast", "add_failed");
                                request.getSession().setAttribute("showError", "All fields are required");
                                response.sendRedirect("dashboard?section=user-management");
                                return;
                            }

                            // Check existing email
                            if (ud.checkExistedEmail(email)) {
                                request.getSession().setAttribute("showToast", "add_error_email");
                                response.sendRedirect("dashboard?section=user-management");
                                return;
                            }

                            // Check existing phone
                            if (ud.checkExistedPhone(phone)) {
                                request.getSession().setAttribute("showToast", "add_error_phone");
                                response.sendRedirect("dashboard?section=user-management");
                                return;
                            }

                            // Generate temporary password
                            String temp_pass = ud.generatePassword(12);
                            System.out.println("Generated temp password: " + temp_pass);

                            // Create user
                            boolean isCreated = ud.addNewUser(fullname, email, phone, temp_pass, "Male",
                                    role, ud.generateAddress(),
                                    Date.valueOf(ud.generateRandomDOB(18, 60)),
                                    "Temporary");

                            System.out.println("User creation result: " + isCreated);

                            if (isCreated) {
                                // Send email with credentials using the new method
                                boolean emailSent = es.sendAccountCreationEmail(email, fullname, email, phone, role, temp_pass);
                                System.out.println("Email sent result: " + emailSent);

                                if (emailSent) {
                                    request.getSession().setAttribute("showToast", "add_success");
                                } else {
                                    request.getSession().setAttribute("showToast", "add_success_no_email");
                                    System.err.println("User created but email not sent to: " + email);
                                }
                            } else {
                                request.getSession().setAttribute("showToast", "add_failed");
                                request.getSession().setAttribute("showError", "Failed to create user in database");
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                            request.getSession().setAttribute("ExceptionError", "add_failed");
                            request.getSession().setAttribute("showError", "System error: " + e.getMessage());
                        }
                        response.sendRedirect("dashboard?section=user-management");
                    }
                    case "delete" -> {
                        try {
                            int userId = Integer.parseInt(request.getParameter("userId"));
                            // Call your service to delete the user
                            boolean isDeleted = ud.deleteUser(userId);

                            if (isDeleted) {
//                                boolean addLog = lhd.addNewLog(new LogHistory(1, "DELETE", "USER", userId, "N/A", "N/A", "Delete an user for testing", "N/A"));
//                                System.out.println("Delete log added: " + addLog);
                                request.getSession().setAttribute("showToast", "delete_success");
                            } else {
                                request.getSession().setAttribute("ExceptionError", "delete_failed");
                                request.getSession().setAttribute("showError", "Error deleting user: User not found or deletion failed");
                            }
                        } catch (NumberFormatException e) {
                            request.getSession().setAttribute("ExceptionError", "delete_failed");
                            request.getSession().setAttribute("showError", "Error deleting user: " + e.getMessage());
                            System.out.println("Error in delete user: " + e.getMessage());
                        }

                        // Redirect back to user list
                        response.sendRedirect("dashboard?section=user-management");
                    }

                    case "update" -> {
                        try {
                            int userId = Integer.parseInt(request.getParameter("userId"));
                            String role = request.getParameter("role");
                            String status = request.getParameter("status");

                            User user = ud.getUserByID(userId);

                            if (user == null) {
                                request.getSession().setAttribute("ExceptionError", "update_failed");
                                request.getSession().setAttribute("showError", "Error update user: User not found");
                                response.sendRedirect("dashboard?section=user-management");
                                return;
                            }

                            // Log get input
                            System.out.println("Current Role: " + user.getRole());
                            System.out.println("New Role: " + role);
                            System.out.println("Current Status: " + user.getAccountStatus());
                            System.out.println("New Status: " + status);

                            //Set value
//                            String old_value = "Role: " + user.getRole() + " , Status: " + user.getAccountStatus() + ".";
//                            String new_value = "Role: " + role + " , Status: " + status + ".";
                            boolean isUpdated = ud.updateSettingUser(role, status, userId);

                            if (isUpdated) {
                                request.getSession().setAttribute("showToast", "update_success");

//                                boolean addLog = lhd.addNewLog(new LogHistory(1, "UPDATE", "USER", userId, old_value, new_value, "Update setting for user account.", "N/A"));
//                                System.out.println("Update log added: " + addLog);
                            } else {
                                request.getSession().setAttribute("ExceptionError", "update_failed");
                                request.getSession().setAttribute("showError", "Error update user: Update failed");
                            }
                        } catch (NumberFormatException e) {
                            request.getSession().setAttribute("ExceptionError", "update_failed");
                            request.getSession().setAttribute("showError", "Error update user: " + e.getMessage());
                            System.out.println("Error in update user: " + e.getMessage());
                        }
                        response.sendRedirect("dashboard?section=user-management");
                    }
                    default ->
                        response.sendRedirect("dashboard?section=user-management");
                }
            } else if (section != null && section.equals("cinema-management")) {
                CinemaMDAO cd = new CinemaMDAO();
                //  LogHistoryDAO lhd = new LogHistoryDAO();

                String action = request.getParameter("action");
                switch (action) {
                    case "add" -> {
                        try {
                            // Get data
                            String cinemaName = request.getParameter("cinemaName");
                            String location = request.getParameter("location");
                            String address = request.getParameter("address"); // Thêm address
                            boolean isActive = request.getParameter("isActive") != null;

                            // Validate input
                            if (cinemaName == null || cinemaName.trim().isEmpty()) {
                                request.getSession().setAttribute("showToast", "add_error");
                                request.getSession().setAttribute("showError", "Cinema name is required");
                                response.sendRedirect("dashboard?section=cinema-management");
                                return;
                            }

                            if (location == null || location.trim().isEmpty()) {
                                request.getSession().setAttribute("showToast", "add_error");
                                request.getSession().setAttribute("showError", "Location is required");
                                response.sendRedirect("dashboard?section=cinema-management");
                                return;
                            }

                            if (address == null || address.trim().isEmpty()) {
                                request.getSession().setAttribute("showToast", "add_error");
                                request.getSession().setAttribute("showError", "Address is required");
                                response.sendRedirect("dashboard?section=cinema-management");
                                return;
                            }

                            // Check if cinema name already exists
                            if (cd.checkCinemaNameExists(cinemaName)) {
                                request.getSession().setAttribute("showToast", "add_error_name");
                                response.sendRedirect("dashboard?section=cinema-management");
                                return;
                            }

                            // Save cinema to database
                            CinemaM newCinema = new CinemaM();
                            newCinema.setCinemaName(cinemaName);
                            newCinema.setLocation(location);
                            newCinema.setAddress(address); // Set address
                            newCinema.setActive(isActive);
                            boolean isCreated = cd.addCinema(newCinema);
                            System.out.println("Cinema created: " + isCreated);

                            if (isCreated) {
                                // Record logs
//                  boolean addLog = lhd.addNewLog(new LogHistory(1, "CREATE", "CINEMA", null, "N/A", "N/A", "Add new cinema: <br>"
//                          + "Cinema Details:<br>"
//                          + "Name: " + cinemaName + "<br>"
//                          + "Location: " + location + "<br>"
//                          + "Address: " + address + "<br>"
//                          + "Status: " + (isActive ? "Active" : "Inactive"), "N/A"));
//                  System.out.println("Log added: " + addLog);

                                request.getSession().setAttribute("showToast", "add_success");
                            } else {
                                request.getSession().setAttribute("showToast", "add_error");
                                request.getSession().setAttribute("showError", "Failed to create cinema");
                            }
                        } catch (IOException e) {
                            request.getSession().setAttribute("showToast", "add_error");
                            request.getSession().setAttribute("showError", "Error creating cinema: " + e.getMessage());
                            System.out.println("Error in add cinema: " + e.getMessage());
                        }
                        response.sendRedirect("dashboard?section=cinema-management");
                    }

                    case "delete" -> {
                        try {
                            int cinemaId = Integer.parseInt(request.getParameter("cinemaId"));
                            // Call your service to delete the cinema (soft delete)
//                            boolean isDeleted = cd.deleteCinema(cinemaId);
                            // Call your service to delete the cinema (hard delete)
                            boolean isDeleted = cd.deleteH_Cinema(cinemaId);

                            if (isDeleted) {
//                  boolean addLog = lhd.addNewLog(new LogHistory(1, "DELETE", "CINEMA", cinemaId, "N/A", "N/A", "Delete cinema for testing", "N/A"));
//                  System.out.println("Delete log added: " + addLog);
                                request.getSession().setAttribute("showToast", "delete_success");
                            } else {
                                request.getSession().setAttribute("showToast", "delete_error");
                                request.getSession().setAttribute("showError", "Error deleting cinema: Cinema not found or deletion failed");
                            }
                        } catch (NumberFormatException e) {
                            request.getSession().setAttribute("showToast", "delete_error");
                            request.getSession().setAttribute("showError", "Error deleting cinema: " + e.getMessage());
                            System.out.println("Error in delete cinema: " + e.getMessage());
                        }

                        // Redirect back to cinema list
                        response.sendRedirect("dashboard?section=cinema-management");
                    }

                    case "update" -> {
                        try {
                            int cinemaId = Integer.parseInt(request.getParameter("cinemaId"));
                            String cinemaName = request.getParameter("cinemaName");
                            String location = request.getParameter("location");
                            String address = request.getParameter("address"); // Thêm address
                            boolean isActive = request.getParameter("isActive") != null;

                            CinemaM cinema = cd.getCinemaById(cinemaId);

                            if (cinema == null) {
                                request.getSession().setAttribute("showToast", "update_error");
                                request.getSession().setAttribute("showError", "Error update cinema: Cinema not found");
                                response.sendRedirect("dashboard?section=cinema-management");
                                return;
                            }

                            // Validate required fields
                            if (cinemaName == null || cinemaName.trim().isEmpty()) {
                                request.getSession().setAttribute("showToast", "update_error");
                                request.getSession().setAttribute("showError", "Cinema name is required");
                                response.sendRedirect("dashboard?section=cinema-management");
                                return;
                            }

                            if (location == null || location.trim().isEmpty()) {
                                request.getSession().setAttribute("showToast", "update_error");
                                request.getSession().setAttribute("showError", "Location is required");
                                response.sendRedirect("dashboard?section=cinema-management");
                                return;
                            }

                            if (address == null || address.trim().isEmpty()) {
                                request.getSession().setAttribute("showToast", "update_error");
                                request.getSession().setAttribute("showError", "Address is required");
                                response.sendRedirect("dashboard?section=cinema-management");
                                return;
                            }

                            // Check if cinema name exists (excluding current cinema)
                            if (cd.checkCinemaNameExists(cinemaName, cinemaId)) {
                                request.getSession().setAttribute("showToast", "update_error");
                                request.getSession().setAttribute("showError", "Cinema name already exists");
                                response.sendRedirect("dashboard?section=cinema-management");
                                return;
                            }

                            // Log get input
                            System.out.println("Current Cinema: " + cinema.getCinemaName());
                            System.out.println("New Cinema Name: " + cinemaName);
                            System.out.println("Current Location: " + cinema.getLocation());
                            System.out.println("New Location: " + location);
                            System.out.println("Current Address: " + cinema.getAddress()); // Thêm address
                            System.out.println("New Address: " + address);
                            System.out.println("Current Status: " + cinema.isActive());
                            System.out.println("New Status: " + isActive);

                            // Set value for log (commented out for now)
//              String old_value = "Name: " + cinema.getCinemaName() + ", Location: " + cinema.getLocation() + 
//                      ", Address: " + cinema.getAddress() + ", Status: " + cinema.isActive() + ".";
//              String new_value = "Name: " + cinemaName + ", Location: " + location + 
//                      ", Address: " + address + ", Status: " + isActive + ".";
                            // Gọi phương thức update mới (không có totalRooms)
                            boolean isUpdated = cd.updateCinema(cinemaId, cinemaName, location, address, isActive);

                            if (isUpdated) {
                                request.getSession().setAttribute("showToast", "update_success");

//                  boolean addLog = lhd.addNewLog(new LogHistory(1, "UPDATE", "CINEMA", cinemaId, old_value, new_value, "Update cinema information.", "N/A"));
//                  System.out.println("Update log added: " + addLog);
                            } else {
                                request.getSession().setAttribute("showToast", "update_error");
                                request.getSession().setAttribute("showError", "Error update cinema: Update failed");
                            }
                        } catch (IOException | NumberFormatException e) {
                            request.getSession().setAttribute("showToast", "update_error");
                            request.getSession().setAttribute("showError", "Error update cinema: " + e.getMessage());
                            System.out.println("Error in update cinema: " + e.getMessage());
                        }
                        response.sendRedirect("dashboard?section=cinema-management");
                    }

                    default ->
                        response.sendRedirect("dashboard?section=cinema-management");
                }
            } else if (section != null && section.equals("screening-room-management")) {
                ScreeningRoomDAO roomDAO = new ScreeningRoomDAO();
                SeatMDAO seatDAO = new SeatMDAO();
                // LogHistoryDAO lhd = new LogHistoryDAO();

                String action = request.getParameter("action");
                switch (action) {
                    case "create" -> {
                        try {
                            // Get form data
                            int cinemaId = Integer.parseInt(request.getParameter("cinemaId"));
                            String roomName = request.getParameter("roomName");
                            int seatCapacity = Integer.parseInt(request.getParameter("seatCapacity"));
                            String roomType = request.getParameter("roomType");
                            boolean isActive = request.getParameter("isActive") != null;

                            // Validate input
                            if (roomName == null || roomName.trim().isEmpty()) {
                                request.getSession().setAttribute("showToast", "add_error");
                                request.getSession().setAttribute("showError", "Room name is required");
                                response.sendRedirect("dashboard?section=screening-room-management");
                                return;
                            }

                            // Check if room name already exists in the same cinema
                            if (roomDAO.isRoomNameExists(cinemaId, roomName)) {
                                request.getSession().setAttribute("showToast", "add_error_name");
                                response.sendRedirect("dashboard?section=screening-room-management");
                                return;
                            }

                            // Create screening room
                            ScreeningRoom room = new ScreeningRoom();
                            room.setCinemaID(cinemaId);
                            room.setRoomName(roomName);
                            room.setSeatCapacity(seatCapacity);
                            room.setRoomType(roomType);
                            room.setActive(isActive);

                            int roomId = roomDAO.createRoom(room);

                            if (roomId > 0) {
                                // Auto-generate seats based on room type
                                SeatLayout layout = new SeatLayout();
                                List<SeatM> seats = layout.generateSeats(roomId, roomType);

                                // Save seats to database
                                boolean seatsCreated = seatDAO.createBulkSeats(seats);

                                if (seatsCreated) {
                                    // Update seat capacity with actual generated seats count
                                    room.setSeatCapacity(seats.size());
                                    roomDAO.updateRoom(room);

                                    // Record log
                                    // boolean addLog = lhd.addNewLog(new LogHistory(1, "CREATE", "SCREENING_ROOM", roomId, "N/A", "N/A", 
                                    //     "Add new screening room: " + roomName + " with " + seats.size() + " seats", "N/A"));
                                    request.getSession().setAttribute("showToast", "add_success");
                                } else {
                                    // Rollback room creation if seats creation failed
                                    roomDAO.deleteRoom(roomId);
                                    request.getSession().setAttribute("showToast", "add_error");
                                    request.getSession().setAttribute("showError", "Failed to create seats layout");
                                }
                            } else {
                                request.getSession().setAttribute("showToast", "add_error");
                                request.getSession().setAttribute("showError", "Failed to create screening room");
                            }

                        } catch (IOException | NumberFormatException e) {
                            request.getSession().setAttribute("showToast", "add_error");
                            request.getSession().setAttribute("showError", "Error creating room: " + e.getMessage());
                            System.out.println("Error in create room: " + e.getMessage());
                        }
                        response.sendRedirect("dashboard?section=screening-room-management");
                    }

                    case "update" -> {
                        try {
                            int roomId = Integer.parseInt(request.getParameter("roomId"));
                            String roomName = request.getParameter("roomName");
                            int seatCapacity = Integer.parseInt(request.getParameter("seatCapacity"));
                            String roomType = request.getParameter("roomType");
                            boolean isActive = request.getParameter("isActive") != null;

                            ScreeningRoom room = roomDAO.getRoomById(roomId);

                            if (room == null) {
                                request.getSession().setAttribute("showToast", "update_error");
                                request.getSession().setAttribute("showError", "Room not found");
                                response.sendRedirect("dashboard?section=screening-room-management");
                                return;
                            }

                            // Validate input
                            if (roomName == null || roomName.trim().isEmpty()) {
                                request.getSession().setAttribute("showToast", "update_error");
                                request.getSession().setAttribute("showError", "Room name is required");
                                response.sendRedirect("dashboard?section=screening-room-management");
                                return;
                            }

                            // Check if room name exists (excluding current room)
                            if (roomDAO.isRoomNameExists(room.getCinemaID(), roomName, roomId)) {
                                request.getSession().setAttribute("showToast", "update_error");
                                request.getSession().setAttribute("showError", "Room name already exists in this cinema");
                                response.sendRedirect("dashboard?section=screening-room-management");
                                return;
                            }

                            // Update room
                            room.setRoomName(roomName);
                            room.setSeatCapacity(seatCapacity);
                            room.setRoomType(roomType);
                            room.setActive(isActive);

                            boolean isUpdated = roomDAO.updateRoom(room);

                            if (isUpdated) {
                                // Record log
                                // boolean addLog = lhd.addNewLog(new LogHistory(1, "UPDATE", "SCREENING_ROOM", roomId, 
                                //     "Old: " + room.getRoomName() + ", " + room.getSeatCapacity() + " seats, " + room.getRoomType(),
                                //     "New: " + roomName + ", " + seatCapacity + " seats, " + roomType,
                                //     "Update screening room information", "N/A"));

                                request.getSession().setAttribute("showToast", "update_success");
                            } else {
                                request.getSession().setAttribute("showToast", "update_error");
                                request.getSession().setAttribute("showError", "Failed to update room");
                            }

                        } catch (IOException | NumberFormatException e) {
                            request.getSession().setAttribute("showToast", "update_error");
                            request.getSession().setAttribute("showError", "Error updating room: " + e.getMessage());
                            System.out.println("Error in update room: " + e.getMessage());
                        }
                        response.sendRedirect("dashboard?section=screening-room-management");
                    }

                    case "delete" -> {
                        try {
                            int roomId = Integer.parseInt(request.getParameter("id"));

                            // Soft delete the room
                            boolean isDeleted = roomDAO.deleteRoom(roomId);

                            if (isDeleted) {
                                // Record log
                                // boolean addLog = lhd.addNewLog(new LogHistory(1, "DELETE", "SCREENING_ROOM", roomId, 
                                //     "N/A", "N/A", "Delete screening room", "N/A"));

                                request.getSession().setAttribute("showToast", "delete_success");
                            } else {
                                request.getSession().setAttribute("showToast", "delete_error");
                                request.getSession().setAttribute("showError", "Failed to delete room");
                            }

                        } catch (NumberFormatException e) {
                            request.getSession().setAttribute("showToast", "delete_error");
                            request.getSession().setAttribute("showError", "Error deleting room: " + e.getMessage());
                            System.out.println("Error in delete room: " + e.getMessage());
                        }
                        response.sendRedirect("dashboard?section=screening-room-management");
                    }

                    case "updateSeat" -> {
                        try {
                            int seatId = Integer.parseInt(request.getParameter("seatId"));
                            int roomId = Integer.parseInt(request.getParameter("roomId"));
                            // KHÔNG lấy seatRow và seatNumber từ parameter nữa
                            String seatType = request.getParameter("seatType");
                            String status = request.getParameter("status");
                            String mode = request.getParameter("mode");

                            SeatM seat = seatDAO.getSeatById(seatId);

                            if (seat == null) {
                                request.getSession().setAttribute("showToast", "update_error");
                                request.getSession().setAttribute("showError", "Seat not found");
                                response.sendRedirect("dashboard?section=screening-room-management&action=" + mode + "&id=" + roomId);
                                return;
                            }

                            // Check if seat can be modified
                            if (!seat.canBeModified()) {
                                request.getSession().setAttribute("showToast", "update_error");
                                request.getSession().setAttribute("showError", "Cannot modify booked seat");
                                response.sendRedirect("dashboard?section=screening-room-management&action=" + mode + "&id=" + roomId);
                                return;
                            }

                            // CHỈ update type và status, giữ nguyên row và number
                            seat.setSeatType(seatType);
                            seat.setStatus(status);

                            boolean isUpdated = seatDAO.updateSeat(seat);

                            if (isUpdated) {
                                request.getSession().setAttribute("showToast", "update_success");
                                request.getSession().setAttribute("showMessage", "Seat updated successfully");
                            } else {
                                request.getSession().setAttribute("showToast", "update_error");
                                request.getSession().setAttribute("showError", "Failed to update seat");
                            }

                        } catch (IOException | NumberFormatException e) {
                            request.getSession().setAttribute("showToast", "update_error");
                            request.getSession().setAttribute("showError", "Error updating seat: " + e.getMessage());
                            System.out.println("Error in update seat: " + e.getMessage());
                        }

                        String roomId = request.getParameter("roomId");
                        String mode = request.getParameter("mode");
                        response.sendRedirect("dashboard?section=screening-room-management&action=" + mode + "&id=" + roomId);
                    }

                    case "deleteSeat" -> {
                        try {
                            int seatId = Integer.parseInt(request.getParameter("seatId"));
                            int roomId = Integer.parseInt(request.getParameter("roomId"));
                            String mode = request.getParameter("mode");

                            SeatM seat = seatDAO.getSeatById(seatId);
                            if (seat == null) {
                                request.getSession().setAttribute("showToast", "delete_error");
                                request.getSession().setAttribute("showError", "Seat not found");
                                response.sendRedirect("dashboard?section=screening-room-management&action=" + mode + "&id=" + roomId);
                                return;
                            }

                            if (!seat.canBeModified()) {
                                request.getSession().setAttribute("showToast", "delete_error");
                                request.getSession().setAttribute("showError", "Cannot delete booked seat");
                                response.sendRedirect("dashboard?section=screening-room-management&action=" + mode + "&id=" + roomId);
                                return;
                            }

                            boolean isDeleted = seatDAO.deleteSeat(seatId);

                            if (isDeleted) {
                                request.getSession().setAttribute("showToast", "delete_success");
                                request.getSession().setAttribute("showMessage", "Seat deleted successfully");
                            } else {
                                request.getSession().setAttribute("showToast", "delete_error");
                                request.getSession().setAttribute("showError", "Failed to delete seat");
                            }

                        } catch (NumberFormatException e) {
                            request.getSession().setAttribute("showToast", "delete_error");
                            request.getSession().setAttribute("showError", "Error deleting seat: " + e.getMessage());
                            System.out.println("Error in delete seat: " + e.getMessage());
                        }

                        String roomId = request.getParameter("roomId");
                        String mode = request.getParameter("mode");
                        response.sendRedirect("dashboard?section=screening-room-management&action=" + mode + "&id=" + roomId);
                    }

                    default -> {
                        response.sendRedirect("dashboard?section=screening-room-management");
                    }
                }
            }
        } catch (IOException e) {
            System.out.println("Error in doPost: " + e.getMessage());
        }
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
