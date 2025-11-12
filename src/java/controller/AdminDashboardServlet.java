package controller;

import dal.CinemaMDAO;
import dal.ScreeningRoomDAO;
import dal.SeatMDAO;
import dal.UserMDAO;
import entity.CinemaM;
import entity.ScreeningRoom;
import entity.SeatM;
import entity.User;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.sql.Date;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import utils.EmailService;
import utils.SeatLayout;

@WebServlet(name = "AdminDashboardServlet", urlPatterns = {"/adminFE/dashboard"})
public class AdminDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String section = request.getParameter("section");

        try {
            if (section == null) {
                showDefaultDashboard(request, response);
                request.getRequestDispatcher("admin_dashboard.jsp").forward(request, response);
            } else {
                switch (section) {
                    case "user-management" -> {
                        handleUserManagementGet(request, response);
                        request.getRequestDispatcher("admin_dashboard.jsp").forward(request, response);
                    }
                    case "cinema-management" -> {
                        handleCinemaManagementGet(request, response);
                        request.getRequestDispatcher("admin_dashboard.jsp").forward(request, response);
                    }
                    case "screening-room-management" ->
                        handleScreeningRoomManagementGet(request, response);
                    default -> {
                        showDefaultDashboard(request, response);
                        request.getRequestDispatcher("admin_dashboard.jsp").forward(request, response);
                    }
                }
            }

        } catch (ServletException | IOException e) {
            handleError(request, response, e, "doGet");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String section = request.getParameter("section");

        try {
            if (section == null) {
                response.sendRedirect("dashboard");
                return;
            }

            switch (section) {
                case "user-management" ->
                    handleUserManagementPost(request, response);
                case "cinema-management" ->
                    handleCinemaManagementPost(request, response);
                case "screening-room-management" ->
                    handleScreeningRoomManagementPost(request, response);
                default ->
                    response.sendRedirect("dashboard?section=" + section);
            }

        } catch (ServletException | IOException e) {
            handleError(request, response, e, "doPost");
        }
    }

    // ========== USER MANAGEMENT HANDLERS ==========
    private void handleUserManagementGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processToastMessages(request);
        UserMDAO ud = new UserMDAO();

        try {
            String action = request.getParameter("action");
            if (action != null && action.equals("view")) {
                int user_Id = Integer.parseInt(request.getParameter("userId"));
                User user = ud.getUserByID(user_Id);
                request.setAttribute("viewUser", user);
            }

            // Get parameters for filtering
            String search = request.getParameter("search");
            String roleFilter = request.getParameter("role");
            String statusFilter = request.getParameter("status");
            String sortBy = request.getParameter("sort");

            // Set default values
            if (roleFilter == null) {
                roleFilter = "all";
            }
            if (statusFilter == null) {
                statusFilter = "all";
            }

            // Get filtered list
            List<User> listU = ud.getAllUsers(search, roleFilter, statusFilter, sortBy);

            // Pagination
            int page = 1;
            int recordsPerPage = 10;
            try {
                page = Integer.parseInt(request.getParameter("page"));
            } catch (NumberFormatException e) {
                // Use default page
            }

            boolean isEmptyList = listU.isEmpty();
            request.setAttribute("isEmptyList", isEmptyList);

            if (!isEmptyList) {
                List<User> usersPerPage = listU.stream()
                        .skip((page - 1) * recordsPerPage)
                        .limit(recordsPerPage)
                        .collect(Collectors.toList());
                int noOfRecords = listU.size();
                int noOfPages = (int) Math.ceil(noOfRecords * 1.0 / recordsPerPage);

                request.setAttribute("listU", usersPerPage);
                request.setAttribute("noOfPages", noOfPages);
            }

            request.setAttribute("currentPage", page);
            request.setAttribute("recordsPerPage", recordsPerPage);
            request.setAttribute("search", search);
            request.setAttribute("roleFilter", roleFilter);
            request.setAttribute("statusFilter", statusFilter);
            request.setAttribute("section", "user-management");

        } catch (NumberFormatException e) {
            throw new ServletException("Error in user management GET", e);
        }
    }

    private void handleUserManagementPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        UserMDAO ud = new UserMDAO();
        EmailService es = new EmailService();

        String action = request.getParameter("action");
        if (action == null) {
            response.sendRedirect("dashboard?section=user-management");
            return;
        }

        try {
            switch (action) {
                case "add" ->
                    handleUserAdd(request, response, ud, es);
                case "delete" ->
                    handleUserDelete(request, response, ud);
                case "update" ->
                    handleUserUpdate(request, response, ud);
                default ->
                    response.sendRedirect("dashboard?section=user-management");
            }

        } catch (IOException e) {
            sendToast(request, "danger", "Error: " + e.getMessage());
            response.sendRedirect("dashboard?section=user-management");
        }
    }

    private void handleUserAdd(HttpServletRequest request, HttpServletResponse response,
            UserMDAO ud, EmailService es) throws IOException {

        // Get and trim data
        String fullname = request.getParameter("fullname").trim();
        String email = request.getParameter("email").trim().toLowerCase();
        String phone = request.getParameter("phonenumber").trim();
        String role = request.getParameter("role");

        // Validation
        if (fullname.isEmpty() || email.isEmpty() || phone.isEmpty() || role == null || role.isEmpty()) {
            sendToast(request, "danger", "All fields are required");
            response.sendRedirect("dashboard?section=user-management");
            return;
        }

        // Check existing email
        if (ud.checkExistedEmail(email)) {
            sendToast(request, "danger", "Email already exists");
            response.sendRedirect("dashboard?section=user-management");
            return;
        }

        // Check existing phone
        if (ud.checkExistedPhone(phone)) {
            sendToast(request, "danger", "Phone number already exists");
            response.sendRedirect("dashboard?section=user-management");
            return;
        }

        // Generate temporary password
        String temp_pass = ud.generatePassword(12);

        // Create user
        boolean isCreated = ud.addNewUser(fullname, email, phone, temp_pass, "Male",
                role, ud.generateAddress(),
                Date.valueOf(ud.generateRandomDOB(18, 60)),
                "Temporary");

        if (isCreated) {
            // Send email
            boolean emailSent = es.sendAccountCreationEmail(email, fullname, email, phone, role, temp_pass);

            if (emailSent) {
                sendToast(request, "success", "User created successfully and email sent");
            } else {
                sendToast(request, "success", "User created but email not sent");
            }
        } else {
            sendToast(request, "danger", "Failed to create user");
        }

        response.sendRedirect("dashboard?section=user-management");
    }

    private void handleUserDelete(HttpServletRequest request, HttpServletResponse response,
            UserMDAO ud) throws IOException {

        try {
            int userId = Integer.parseInt(request.getParameter("userId"));
            boolean isDeleted = ud.deleteUser(userId);

            if (isDeleted) {
                sendToast(request, "success", "User deleted successfully");
            } else {
                sendToast(request, "danger", "Failed to delete user");
            }
        } catch (NumberFormatException e) {
            sendToast(request, "danger", "Invalid user ID");
        }

        response.sendRedirect("dashboard?section=user-management");
    }

    private void handleUserUpdate(HttpServletRequest request, HttpServletResponse response,
            UserMDAO ud) throws IOException {

        try {
            int userId = Integer.parseInt(request.getParameter("userId"));
            String role = request.getParameter("role");
            String status = request.getParameter("status");

            User user = ud.getUserByID(userId);
            if (user == null) {
                sendToast(request, "danger", "User not found");
                response.sendRedirect("dashboard?section=user-management");
                return;
            }

            boolean isUpdated = ud.updateSettingUser(role, status, userId);

            if (isUpdated) {
                sendToast(request, "success", "User updated successfully");
            } else {
                sendToast(request, "danger", "Failed to update user");
            }
        } catch (NumberFormatException e) {
            sendToast(request, "danger", "Invalid user ID");
        }

        response.sendRedirect("dashboard?section=user-management");
    }

    // ========== CINEMA MANAGEMENT HANDLERS ==========
    private void handleCinemaManagementGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processToastMessages(request);
        CinemaMDAO cd = new CinemaMDAO();

        try {
            String action = request.getParameter("action");
            if (action != null && action.equals("view")) {
                int cinemaId = Integer.parseInt(request.getParameter("cinemaId"));
                CinemaM cinema = cd.getCinemaById(cinemaId);

                ScreeningRoomDAO roomDAO = new ScreeningRoomDAO();
                List<ScreeningRoom> screeningRooms = roomDAO.getScreeningRoomsByCinemaId(cinemaId);

                request.setAttribute("screeningRooms", screeningRooms);
                request.setAttribute("viewCinema", cinema);
            }

            // Get parameters for filtering
            String search = request.getParameter("search");
            String statusFilter = request.getParameter("status");
            String locationFilter = request.getParameter("location");
            String sortBy = request.getParameter("sort");

            // Set default values
            if (statusFilter == null) {
                statusFilter = "all";
            }
            if (locationFilter == null) {
                locationFilter = "all";
            }

            // Get filtered list
            List<CinemaM> listCinemas = cd.getAllCinemas(search, statusFilter, locationFilter, sortBy);
            System.out.println(listCinemas);
            // Pagination
            int page = 1;
            int recordsPerPage = 10;
            try {
                page = Integer.parseInt(request.getParameter("page"));
            } catch (NumberFormatException e) {
                // Use default page
            }

            boolean isEmptyList = listCinemas.isEmpty();
            request.setAttribute("isEmptyList", isEmptyList);

            if (!isEmptyList) {
                List<CinemaM> cinemasPerPage = listCinemas.stream()
                        .skip((page - 1) * recordsPerPage)
                        .limit(recordsPerPage)
                        .collect(Collectors.toList());
                int noOfRecords = listCinemas.size();
                int noOfPages = (int) Math.ceil(noOfRecords * 1.0 / recordsPerPage);

                request.setAttribute("listCinemas", cinemasPerPage);
                request.setAttribute("noOfPages", noOfPages);
            }

            // Get all locations for filter dropdown
            List<String> allLocations = cd.getAllLocations();

            request.setAttribute("currentPage", page);
            request.setAttribute("recordsPerPage", recordsPerPage);
            request.setAttribute("search", search);
            request.setAttribute("statusFilter", statusFilter);
            request.setAttribute("locationFilter", locationFilter);
            request.setAttribute("allLocations", allLocations);
            request.setAttribute("section", "cinema-management");

        } catch (NumberFormatException e) {
            throw new ServletException("Error in cinema management GET", e);
        }
    }

    private void handleCinemaManagementPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        CinemaMDAO cd = new CinemaMDAO();

        String action = request.getParameter("action");
        if (action == null) {
            response.sendRedirect("dashboard?section=cinema-management");
            return;
        }

        try {
            switch (action) {
                case "add" ->
                    handleCinemaAdd(request, response, cd);
                case "delete" ->
                    handleCinemaDelete(request, response, cd);
                case "update" ->
                    handleCinemaUpdate(request, response, cd);
                default ->
                    response.sendRedirect("dashboard?section=cinema-management");
            }

        } catch (IOException e) {
            sendToast(request, "danger", "Error: " + e.getMessage());
            response.sendRedirect("dashboard?section=cinema-management");
        }
    }

    private void handleCinemaAdd(HttpServletRequest request, HttpServletResponse response,
            CinemaMDAO cd) throws IOException {

        String cinemaName = request.getParameter("cinemaName");
        String location = request.getParameter("location");
        String address = request.getParameter("address");
        boolean isActive = request.getParameter("isActive") != null;

        // Validation
        if (cinemaName == null || cinemaName.trim().isEmpty()) {
            sendToast(request, "danger", "Cinema name is required");
            response.sendRedirect("dashboard?section=cinema-management");
            return;
        }

        if (location == null || location.trim().isEmpty()) {
            sendToast(request, "danger", "Location is required");
            response.sendRedirect("dashboard?section=cinema-management");
            return;
        }

        if (address == null || address.trim().isEmpty()) {
            sendToast(request, "danger", "Address is required");
            response.sendRedirect("dashboard?section=cinema-management");
            return;
        }

        // Check duplicate cinema name
        if (cd.checkCinemaNameExists(cinemaName)) {
            sendToast(request, "danger", "Cinema name already exists");
            response.sendRedirect("dashboard?section=cinema-management");
            return;
        }

        // Create cinema
        CinemaM newCinema = new CinemaM();
        newCinema.setCinemaName(cinemaName);
        newCinema.setLocation(location);
        newCinema.setAddress(address);
        newCinema.setActive(isActive);

        boolean isCreated = cd.addCinema(newCinema);

        if (isCreated) {
            sendToast(request, "success", "Cinema created successfully");
        } else {
            sendToast(request, "danger", "Failed to create cinema");
        }

        response.sendRedirect("dashboard?section=cinema-management");
    }

    private void handleCinemaDelete(HttpServletRequest request, HttpServletResponse response,
            CinemaMDAO cd) throws IOException {

        try {
            int cinemaId = Integer.parseInt(request.getParameter("cinemaId"));
            boolean isDeleted = cd.deleteH_Cinema(cinemaId);

            if (isDeleted) {
                sendToast(request, "success", "Cinema deleted successfully");
            } else {
                sendToast(request, "danger", "Failed to delete cinema");
            }
        } catch (NumberFormatException e) {
            sendToast(request, "danger", "Invalid cinema ID");
        }

        response.sendRedirect("dashboard?section=cinema-management");
    }

    private void handleCinemaUpdate(HttpServletRequest request, HttpServletResponse response,
            CinemaMDAO cd) throws IOException {

        try {
            int cinemaId = Integer.parseInt(request.getParameter("cinemaId"));
            String cinemaName = request.getParameter("cinemaName");
            String location = request.getParameter("location");
            String address = request.getParameter("address");
            boolean isActive = request.getParameter("isActive") != null;

            CinemaM cinema = cd.getCinemaById(cinemaId);
            if (cinema == null) {
                sendToast(request, "danger", "Cinema not found");
                response.sendRedirect("dashboard?section=cinema-management");
                return;
            }

            // Validation
            if (cinemaName == null || cinemaName.trim().isEmpty()) {
                sendToast(request, "danger", "Cinema name is required");
                response.sendRedirect("dashboard?section=cinema-management&action=view&cinemaId=" + cinemaId);
                return;
            }

            // Check duplicate (excluding current cinema)
            if (cd.checkCinemaNameExists(cinemaName, cinemaId)) {
                sendToast(request, "danger", "Cinema name already exists");
                response.sendRedirect("dashboard?section=cinema-management&action=view&cinemaId=" + cinemaId);
                return;
            }

            // Update cinema
            boolean isUpdated = cd.updateCinema(cinemaId, cinemaName, location, address, isActive);

            if (isUpdated) {
                sendToast(request, "success", "Cinema updated successfully");
            } else {
                sendToast(request, "danger", "Failed to update cinema");
            }
        } catch (NumberFormatException e) {
            sendToast(request, "danger", "Invalid cinema ID");
        }

        response.sendRedirect("dashboard?section=cinema-management");
    }

    // ========== SCREENING ROOM MANAGEMENT HANDLERS ==========
    private void handleScreeningRoomManagementGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processToastMessages(request);
        ScreeningRoomDAO roomDAO = new ScreeningRoomDAO();
        CinemaMDAO cinemaDAO = new CinemaMDAO();
        SeatMDAO seatDAO = new SeatMDAO();

        try {
            String action = request.getParameter("action");
            System.out.println("=== SCREENING ROOM MANAGEMENT ===");
            System.out.println("Action: " + action);

            if (action == null) {
                handleRoomList(request, response, roomDAO, cinemaDAO);
                request.getRequestDispatcher("admin_dashboard.jsp").forward(request, response);
            } else {
                switch (action) {
                    case "view", "edit" -> {
                        handleViewEditRoom(request, response, roomDAO, seatDAO);
                        request.getRequestDispatcher("admin_dashboard.jsp").forward(request, response);
                    }
                    case "create" -> {
                        handleCreateRoom(request, response, cinemaDAO);
                        request.getRequestDispatcher("admin_dashboard.jsp").forward(request, response);
                    }
                    case "generateSeats" ->
                        handleGenerateSeats(request, response, roomDAO, seatDAO);
                    case "editSeat" -> {
                        handleEditSeat(request, response, roomDAO, seatDAO);
                        request.getRequestDispatcher("admin_dashboard.jsp").forward(request, response);
                    }
                    case "seatStatistics" -> {
                        handleSeatStatistics(request, response, roomDAO);
                        request.getRequestDispatcher("admin_dashboard.jsp").forward(request, response);
                    }
                    default -> {
                        handleRoomList(request, response, roomDAO, cinemaDAO);
                        request.getRequestDispatcher("admin_dashboard.jsp").forward(request, response);
                    }
                }
            }

        } catch (ServletException | IOException e) {
            System.out.println("Error in screening room management: " + e.getMessage());
            sendToast(request, "danger", "System error: " + e.getMessage());
            response.sendRedirect("dashboard?section=screening-room-management");
        }
    }

    private void handleRoomList(HttpServletRequest request, HttpServletResponse response,
            ScreeningRoomDAO roomDAO, CinemaMDAO cinemaDAO)
            throws ServletException, IOException {

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

        // Check hasValidFilters - Filter LOCATION and CINEMA or not
        boolean hasValidFilters = !"none".equals(locationFilter) && !"none".equals(cinemaFilter);

        // Parse cinema filter
        Integer cinemaId = null;
        if (!"none".equals(cinemaFilter)) {
            try {
                cinemaId = Integer.valueOf(cinemaFilter);
            } catch (NumberFormatException e) {
                System.out.println("Invalid cinema filter: " + cinemaFilter);
            }
        }

        // Pagination
        int page = 1;
        int recordsPerPage = 10;
        try {
            page = Integer.parseInt(request.getParameter("page"));
        } catch (NumberFormatException e) {
            // Use default page
        }

        List<ScreeningRoom> rooms = new ArrayList<>();
        int totalRecords = 0;
        int noOfPages = 0;

        // if filter get list
        if (hasValidFilters) {
            // Get data
            rooms = roomDAO.getRoomsWithFilters(
                    locationFilter,
                    cinemaId,
                    "all".equals(roomTypeFilter) ? null : roomTypeFilter,
                    "all".equals(statusFilter) ? null : statusFilter,
                    search,
                    (page - 1) * recordsPerPage,
                    recordsPerPage
            );

            totalRecords = roomDAO.countRoomsWithFilters(
                    locationFilter,
                    cinemaId,
                    "all".equals(roomTypeFilter) ? null : roomTypeFilter,
                    "all".equals(statusFilter) ? null : statusFilter,
                    search
            );

            noOfPages = (int) Math.ceil(totalRecords * 1.0 / recordsPerPage);
        }

        System.out.println("Rooms found: " + rooms.size());
        System.out.println("Total records: " + totalRecords);
        System.out.println("Has valid filters: " + hasValidFilters);

        // Get data for filters
        List<String> locations = cinemaDAO.getAllLocations();
        List<String> roomTypes = roomDAO.getAvailableRoomTypes();
        List<CinemaM> cinemas = new ArrayList<>();

        if (!"none".equals(locationFilter)) {
            cinemas = cinemaDAO.getCinemasByLocation(locationFilter);
        }

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
        request.setAttribute("allLocations", getLocationsWithNone(locations));
        request.setAttribute("allRoomTypes", roomTypes);
        request.setAttribute("cinemasByLocation", getCinemasWithNone(cinemas));
        request.setAttribute("hasValidFilters", hasValidFilters);
        request.setAttribute("section", "screening-room-management");
    }

    private void handleViewEditRoom(HttpServletRequest request, HttpServletResponse response,
            ScreeningRoomDAO roomDAO, SeatMDAO seatDAO)
            throws ServletException, IOException {

        try {
            int roomId = Integer.parseInt(request.getParameter("id"));
            ScreeningRoom room = roomDAO.getRoomById(roomId);

            if (room == null) {
                sendToast(request, "danger", "Room not found");
                response.sendRedirect("dashboard?section=screening-room-management");
                return;
            }

            List<SeatM> seats = seatDAO.getSeatsByRoom(roomId);

            // Lấy thống kê ghế chi tiết từ DAO mới
            Map<String, Integer> seatStatusCounts = roomDAO.countSeatsByStatus(roomId);
            Map<String, Integer> seatTypeCounts = roomDAO.countSeatsByType(roomId);

            request.setAttribute("viewRoom", room);
            request.setAttribute("seats", seats);
            request.setAttribute("seatStatusCounts", seatStatusCounts);
            request.setAttribute("seatTypeCounts", seatTypeCounts);
            request.setAttribute("section", "screening-room-management");

            System.out.println("Loaded room: " + room.getRoomName()
                    + ", seats: " + seats.size()
                    + ", capacity: " + room.getSeatCapacity());

        } catch (NumberFormatException e) {
            sendToast(request, "danger", "Invalid room ID");
            response.sendRedirect("dashboard?section=screening-room-management");
        }
    }

    private void handleCreateRoom(HttpServletRequest request, HttpServletResponse response,
            CinemaMDAO cinemaDAO) throws ServletException, IOException {

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
        request.setAttribute("section", "screening-room-management");
    }

    private void handleEditSeat(HttpServletRequest request, HttpServletResponse response,
            ScreeningRoomDAO roomDAO, SeatMDAO seatDAO) throws ServletException, IOException {

        try {
            int seatId = Integer.parseInt(request.getParameter("seatId"));
            int roomId = Integer.parseInt(request.getParameter("roomId"));

            SeatM seat = seatDAO.getSeatById(seatId);
            ScreeningRoom room = roomDAO.getRoomById(roomId);

            if (seat == null || room == null) {
                sendToast(request, "danger", "Seat or room not found");
                response.sendRedirect("dashboard?section=screening-room-management");
                return;
            }

            List<SeatM> seats = seatDAO.getSeatsByRoom(roomId);
            request.setAttribute("editSeat", seat);
            request.setAttribute("viewRoom", room);
            request.setAttribute("seats", seats);
            request.setAttribute("section", "screening-room-management");

        } catch (NumberFormatException e) {
            sendToast(request, "danger", "Invalid seat or room ID");
            response.sendRedirect("dashboard?section=screening-room-management");
        }
    }

    private void handleSeatStatistics(HttpServletRequest request, HttpServletResponse response,
            ScreeningRoomDAO roomDAO) throws ServletException, IOException {

        try {
            int roomId = Integer.parseInt(request.getParameter("id"));
            ScreeningRoom room = roomDAO.getRoomById(roomId);

            if (room == null) {
                sendToast(request, "danger", "Room not found");
                response.sendRedirect("dashboard?section=screening-room-management");
                return;
            }

            // Lấy thống kê chi tiết từ DAO mới
            Map<String, Object> seatStats = roomDAO.getDetailedSeatStatistics(roomId);

            request.setAttribute("viewRoom", room);
            request.setAttribute("seatStats", seatStats);
            request.setAttribute("section", "screening-room-management");

        } catch (NumberFormatException e) {
            sendToast(request, "danger", "Invalid room ID");
            response.sendRedirect("dashboard?section=screening-room-management");
        }
    }

    private void handleGenerateSeats(HttpServletRequest request, HttpServletResponse response,
            ScreeningRoomDAO roomDAO, SeatMDAO seatDAO) throws ServletException, IOException {

        try {
            int roomId = Integer.parseInt(request.getParameter("roomId"));
            System.out.println("=== START GENERATE SEATS FOR ROOM: " + roomId + " ===");

            ScreeningRoom room = roomDAO.getRoomById(roomId);
            if (room == null) {
                System.out.println("ERROR: Room not found with ID: " + roomId);
                sendToast(request, "danger", "Room not found");
                response.sendRedirect("dashboard?section=screening-room-management");
                return;
            }

            System.out.println("Found room: " + room.getRoomName() + ", type: " + room.getRoomType());

            // Generate seats layout
            SeatLayout layout = new SeatLayout();
            List<SeatM> seats = layout.generateSeats(roomId, room.getRoomType());

            if (seats == null || seats.isEmpty()) {
                System.out.println("ERROR: No seats generated by SeatLayout");
                sendToast(request, "danger", "No seats were generated");
                response.sendRedirect("dashboard?section=screening-room-management&action=edit&id=" + roomId);
                return;
            }

            System.out.println("Successfully generated " + seats.size() + " seats");

            // Delete existing seats first
            try {
                boolean deleted = seatDAO.deleteSeatsByRoom(roomId);
                System.out.println("Deleted existing seats: " + deleted);
            } catch (Exception e) {
                System.out.println("Error deleting existing seats: " + e.getMessage());
            }

            // Create new seats
            boolean seatsCreated = seatDAO.createBulkSeats(seats);
            System.out.println("Seats creation result: " + seatsCreated);

            if (seatsCreated) {
                sendToast(request, "success", "Successfully generated " + seats.size() + " seats");
                System.out.println("=== SEAT GENERATION COMPLETED SUCCESSFULLY ===");
            } else {
                sendToast(request, "danger", "Failed to save seats to database");
                System.out.println("=== SEAT GENERATION FAILED - DATABASE ERROR ===");
            }

            response.sendRedirect("dashboard?section=screening-room-management&action=edit&id=" + roomId);

        } catch (NumberFormatException e) {
            System.out.println("ERROR: Invalid room ID format");
            sendToast(request, "danger", "Invalid room ID");
            response.sendRedirect("dashboard?section=screening-room-management");
        } catch (IOException e) {
            System.out.println("ERROR in generateSeats: " + e.getMessage());
            sendToast(request, "danger", "System error: " + e.getMessage());
            response.sendRedirect("dashboard?section=screening-room-management");
        }
    }

    private void handleScreeningRoomManagementPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        ScreeningRoomDAO roomDAO = new ScreeningRoomDAO();
        SeatMDAO seatDAO = new SeatMDAO();

        try {
            String action = request.getParameter("action");
            System.out.println("=== SCREENING ROOM MANAGEMENT POST ===");
            System.out.println("Action: " + action);

            if (action == null) {
                response.sendRedirect("dashboard?section=screening-room-management");
                return;
            }

            switch (action) {
                case "create" ->
                    handleCreateRoomPost(request, response, roomDAO, seatDAO);
                case "update" ->
                    handleUpdateRoomPost(request, response, roomDAO);
                case "delete" ->
                    handleDeleteRoomPost(request, response, roomDAO);
                case "updateSeat" ->
                    handleUpdateSeatPost(request, response, seatDAO);
                case "deleteSeat" ->
                    handleDeleteSeatPost(request, response, seatDAO);
                case "bulkSeatAction" ->
                    handleBulkSeatActionPost(request, response, seatDAO);
                default ->
                    response.sendRedirect("dashboard?section=screening-room-management");
            }

        } catch (ServletException | IOException e) {
            System.out.println("Error in screening room management POST: " + e.getMessage());
            sendToast(request, "danger", "System error: " + e.getMessage());
            response.sendRedirect("dashboard?section=screening-room-management");
        }
    }

    private void handleCreateRoomPost(HttpServletRequest request, HttpServletResponse response,
            ScreeningRoomDAO roomDAO, SeatMDAO seatDAO) throws ServletException, IOException {

        try {
            int cinemaId = Integer.parseInt(request.getParameter("cinemaId"));
            String roomName = request.getParameter("roomName");
            String roomType = request.getParameter("roomType");
//            System.out.println(roomName);
//            System.out.println(roomType);
            boolean isActive = request.getParameter("isActive") != null;

            // Validation
            if (roomName == null || roomName.trim().isEmpty()) {
                sendToast(request, "danger", "Room name is required");
                redirectBackToCreateWithFilters(request, response, cinemaId);
                return;
            }

            // Check duplicate room name
            if (roomDAO.isRoomNameExists(cinemaId, roomName)) {
                sendToast(request, "danger", "Room name already exists in this cinema");
                redirectBackToCreateWithFilters(request, response, cinemaId);
                return;
            }

            // Create room 
            ScreeningRoom room = new ScreeningRoom();
            room.setCinemaID(cinemaId);
            room.setRoomName(roomName);
            room.setRoomType(roomType);
            room.setActive(isActive);

            int roomId = roomDAO.createRoom(room);

            if (roomId > 0) {
                // Auto-generate seats
                SeatLayout layout = new SeatLayout();
                List<SeatM> seats = layout.generateSeats(roomId, roomType);

                boolean seatsCreated = seatDAO.createBulkSeats(seats);

                if (seatsCreated) {
                    sendToast(request, "success", "Room created with " + seats.size() + " seats");
                } else {
                    // Rollback room creation
                    roomDAO.deleteRoom(roomId);
                    sendToast(request, "danger", "Failed to create seat layout");
                }
            } else {
                sendToast(request, "danger", "Failed to create room");
            }

        } catch (NumberFormatException e) {
            sendToast(request, "danger", "Invalid input data");
        }

        // Redirect back to list with preserved filters
        redirectBackToListWithFilters(request, response);
    }

    private void handleUpdateRoomPost(HttpServletRequest request, HttpServletResponse response,
            ScreeningRoomDAO roomDAO) throws ServletException, IOException {

        try {
            int roomId = Integer.parseInt(request.getParameter("roomId"));
            String roomName = request.getParameter("roomName");
            String roomType = request.getParameter("roomType");
            boolean isActive = request.getParameter("isActive") != null;

            ScreeningRoom room = roomDAO.getRoomById(roomId);
            if (room == null) {
                sendToast(request, "danger", "Room not found");
                redirectBackToListWithFilters(request, response);
                return;
            }

            // Validation
            if (roomName == null || roomName.trim().isEmpty()) {
                sendToast(request, "danger", "Room name is required");
                redirectBackToEditWithFilters(request, response, roomId);
                return;
            }

            // Check duplicate (excluding current room)
            if (roomDAO.isRoomNameExists(room.getCinemaID(), roomName, roomId)) {
                sendToast(request, "danger", "Room name already exists in this cinema");
                redirectBackToEditWithFilters(request, response, roomId);
                return;
            }

            // Update room 
            room.setRoomName(roomName);
            room.setRoomType(roomType);
            room.setActive(isActive);

            boolean success = roomDAO.updateRoom(room);

            if (success) {
                sendToast(request, "success", "Room updated successfully");
            } else {
                sendToast(request, "danger", "Failed to update room");
            }

        } catch (NumberFormatException e) {
            sendToast(request, "danger", "Invalid input data");
        }

        // Redirect back to list with preserved filters
        redirectBackToListWithFilters(request, response);
    }

    private void handleDeleteRoomPost(HttpServletRequest request, HttpServletResponse response,
            ScreeningRoomDAO roomDAO) throws ServletException, IOException {

        try {
            int roomId = Integer.parseInt(request.getParameter("id"));
            boolean success = roomDAO.deleteHRoom(roomId);

            if (success) {
                sendToast(request, "success", "Room deleted successfully");
            } else {
                sendToast(request, "danger", "Failed to delete room");
            }

        } catch (NumberFormatException e) {
            sendToast(request, "danger", "Invalid room ID");
        }

        // Redirect back to list with preserved filters
        redirectBackToListWithFilters(request, response);
    }

    private void handleUpdateSeatPost(HttpServletRequest request, HttpServletResponse response,
            SeatMDAO seatDAO) throws ServletException, IOException {

        try {
            int seatId = Integer.parseInt(request.getParameter("seatId"));
            int roomId = Integer.parseInt(request.getParameter("roomId"));
            String seatType = request.getParameter("seatType");
            String status = request.getParameter("status");
            String mode = request.getParameter("mode");

            SeatM seat = seatDAO.getSeatById(seatId);
            if (seat == null) {
                sendToast(request, "danger", "Seat not found");
                response.sendRedirect("dashboard?section=screening-room-management");
                return;
            }

            if (!seat.canBeModified()) {
                sendToast(request, "danger", "Cannot modify booked seat");
                redirectBackToRoomWithFilters(request, response, roomId, mode);
                return;
            }

            seat.setSeatType(seatType);
            seat.setStatus(status);

            boolean success = seatDAO.updateSeat(seat);

            if (success) {
                sendToast(request, "success", "Seat updated successfully");
            } else {
                sendToast(request, "danger", "Failed to update seat");
            }

        } catch (NumberFormatException e) {
            sendToast(request, "danger", "Invalid seat data");
        }

        redirectBackToRoomWithFilters(request, response,
                Integer.parseInt(request.getParameter("roomId")),
                request.getParameter("mode"));
    }

    private void handleDeleteSeatPost(HttpServletRequest request, HttpServletResponse response,
            SeatMDAO seatDAO) throws ServletException, IOException {

        try {
            int seatId = Integer.parseInt(request.getParameter("seatId"));
            int roomId = Integer.parseInt(request.getParameter("roomId"));
            String mode = request.getParameter("mode");

            SeatM seat = seatDAO.getSeatById(seatId);
            if (seat == null) {
                sendToast(request, "danger", "Seat not found");
                redirectBackToRoomWithFilters(request, response, roomId, mode);
                return;
            }

            if (!seat.canBeModified()) {
                sendToast(request, "danger", "Cannot delete booked seat");
                redirectBackToRoomWithFilters(request, response, roomId, mode);
                return;
            }

            boolean success = seatDAO.deleteSeat(seatId);

            if (success) {
                sendToast(request, "success", "Seat deleted successfully");
            } else {
                sendToast(request, "danger", "Failed to delete seat");
            }

        } catch (NumberFormatException e) {
            sendToast(request, "danger", "Invalid seat ID");
        }

        redirectBackToRoomWithFilters(request, response,
                Integer.parseInt(request.getParameter("roomId")),
                request.getParameter("mode"));
    }

    private void handleBulkSeatActionPost(HttpServletRequest request, HttpServletResponse response,
            SeatMDAO seatDAO) throws ServletException, IOException {

        try {
            int roomId = Integer.parseInt(request.getParameter("roomId"));
            String operation = request.getParameter("operation");

            String[] seatIdsParam = request.getParameterValues("seatIds");
            if (seatIdsParam == null || seatIdsParam.length == 0) {
                sendToast(request, "danger", "No seats selected");
                redirectBackToRoomWithFilters(request, response, roomId, "edit");
                return;
            }

            List<Integer> seatIds = new ArrayList<>();
            for (String seatIdStr : seatIdsParam) {
                seatIds.add(Integer.valueOf(seatIdStr));
            }

            boolean success = false;
            String message = "";

            switch (operation) {
                case "changeType" -> {
                    String newType = request.getParameter("newType");
                    success = seatDAO.bulkUpdateSeatType(seatIds, newType);
                    message = "Updated type for " + seatIds.size() + " seats";
                }
                case "changeStatus" -> {
                    String newStatus = request.getParameter("newStatus");
                    success = seatDAO.bulkUpdateSeatStatus(seatIds, newStatus);
                    message = "Updated status for " + seatIds.size() + " seats";
                }
                default ->
                    message = "Unknown operation";
            }

            if (success) {
                sendToast(request, "success", message);
            } else {
                sendToast(request, "danger", "Failed to update seats");
            }

        } catch (NumberFormatException e) {
            sendToast(request, "danger", "Invalid seat IDs");
        }

        redirectBackToRoomWithFilters(request, response,
                Integer.parseInt(request.getParameter("roomId")), "edit");
    }

    // ========== FILTER PRESERVATION HELPER METHODS ==========
    
    private void redirectBackToListWithFilters(HttpServletRequest request, HttpServletResponse response) throws IOException {
        StringBuilder redirectUrl = new StringBuilder("dashboard?section=screening-room-management");

        // Get all filter parameters from request
        String[] filterParams = {"locationFilter", "cinemaFilter", "roomType", "status", "search", "page"};
        
        for (String param : filterParams) {
            String value = request.getParameter(param);
            if (isValidFilterValue(value)) {
                redirectUrl.append("&").append(param).append("=").append(encodeValue(value));
            }
        }

        System.out.println("Redirecting to list with filters: " + redirectUrl.toString());
        response.sendRedirect(redirectUrl.toString());
    }

    private void redirectBackToCreateWithFilters(HttpServletRequest request, HttpServletResponse response, int cinemaId) throws IOException {
        StringBuilder redirectUrl = new StringBuilder("dashboard?section=screening-room-management&action=create&cinemaId=" + cinemaId);

        // Get all filter parameters from request
        String[] filterParams = {"locationFilter", "cinemaFilter", "roomType", "status", "search", "page"};
        
        for (String param : filterParams) {
            String value = request.getParameter(param);
            if (isValidFilterValue(value)) {
                redirectUrl.append("&").append(param).append("=").append(encodeValue(value));
            }
        }

        response.sendRedirect(redirectUrl.toString());
    }

    private void redirectBackToEditWithFilters(HttpServletRequest request, HttpServletResponse response, int roomId) throws IOException {
        StringBuilder redirectUrl = new StringBuilder("dashboard?section=screening-room-management&action=edit&id=" + roomId);

        // Get all filter parameters from request
        String[] filterParams = {"locationFilter", "cinemaFilter", "roomType", "status", "search", "page"};
        
        for (String param : filterParams) {
            String value = request.getParameter(param);
            if (isValidFilterValue(value)) {
                redirectUrl.append("&").append(param).append("=").append(encodeValue(value));
            }
        }

        response.sendRedirect(redirectUrl.toString());
    }

    private void redirectBackToRoomWithFilters(HttpServletRequest request, HttpServletResponse response,
            int roomId, String mode) throws IOException {
        
        StringBuilder redirectUrl = new StringBuilder("dashboard?section=screening-room-management");
        redirectUrl.append("&action=").append(mode != null ? mode : "edit");
        redirectUrl.append("&id=").append(roomId);

        // Get all filter parameters from request
        String[] filterParams = {"locationFilter", "cinemaFilter", "roomType", "status", "search", "page"};
        
        for (String param : filterParams) {
            String value = request.getParameter(param);
            if (isValidFilterValue(value)) {
                redirectUrl.append("&").append(param).append("=").append(encodeValue(value));
            }
        }

        response.sendRedirect(redirectUrl.toString());
    }

    private boolean isValidFilterValue(String value) {
        return value != null && !value.trim().isEmpty() && !value.equals("none") && !value.equals("all");
    }

    private String encodeValue(String value) {
        try {
            return java.net.URLEncoder.encode(value, "UTF-8");
        } catch (java.io.UnsupportedEncodingException e) {
            return value;
        }
    }

    // ========== HELPER METHODS ==========
    private void showDefaultDashboard(HttpServletRequest request, HttpServletResponse response) {
        request.setAttribute("section", "dashboard");
    }

    private void handleError(HttpServletRequest request, HttpServletResponse response,
            Exception e, String context) throws IOException {

        System.err.println("Error in " + context + ": " + e.getMessage());

        sendToast(request, "danger", "System error occurred");
        response.sendRedirect("dashboard");
    }

    private void sendToast(HttpServletRequest request, String type, String message) {
        request.getSession().setAttribute("toastType", type);
        request.getSession().setAttribute("toastMessage", message);
        System.out.println("Toast set: " + type + " - " + message);
    }

    private List<String> getLocationsWithNone(List<String> locations) {
        List<String> result = new ArrayList<>();
        result.add("none");
        result.addAll(locations);
        return result;
    }

    private List<CinemaM> getCinemasWithNone(List<CinemaM> cinemas) {
        List<CinemaM> result = new ArrayList<>();
        // Add "None" option
        CinemaM noneCinema = new CinemaM();
        noneCinema.setCinemaID(-1);
        noneCinema.setCinemaName("None");
        noneCinema.setLocation("none");
        result.add(noneCinema);
        result.addAll(cinemas);
        return result;
    }

    private void processToastMessages(HttpServletRequest request) {
        try {
            String toastType = (String) request.getSession().getAttribute("toastType");
            String toastMessage = (String) request.getSession().getAttribute("toastMessage");

            if (toastType != null && toastMessage != null) {
                request.setAttribute("toastType", toastType);
                request.setAttribute("toastMessage", toastMessage);

                request.getSession().removeAttribute("toastType");
                request.getSession().removeAttribute("toastMessage");

                System.out.println("Toast message processed: " + toastType + " - " + toastMessage);
            }
        } catch (Exception e) {
            System.out.println("Error processing toast messages: " + e.getMessage());
        }
    }

    @Override
    public String getServletInfo() {
        return "Admin Dashboard Servlet - Updated with Filter Preservation";
    }
}