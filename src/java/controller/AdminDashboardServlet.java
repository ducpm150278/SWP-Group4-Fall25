package controller;

import dal.CinemaDAO;
import dal.UserDAO;
import entity.Cinema;
import entity.User;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.sql.Date;
import java.util.List;
import java.util.stream.Collectors;
import utils.EmailService;

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
        CinemaDAO cd = new CinemaDAO();
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
                            Cinema cinema = cd.getCinemaByID(cinemaId);
                            if (cinema != null) {
                                System.out.println("Cinema found: " + cinema.getCinemaName());
                            }
                            request.setAttribute("viewCinema", cinema);
                        }
                    }
                } catch (NumberFormatException e) {
                    System.out.println("Error parsing cinema ID: " + e.getMessage());
                }

                // Get param for filter list
                String search = request.getParameter("search");
                String statusFilter = request.getParameter("status");
                String sortBy = request.getParameter("sort");

                // Set value get all in case status filter is null
                if (statusFilter == null) {
                    statusFilter = "all";
                }

                // Get list cinema after filter và sort
                List<Cinema> listCinemas = cd.getAllCinemas(search, statusFilter, sortBy);
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
                    List<Cinema> cinemasPerPage = listCinemas.stream()
                            .skip((page - 1) * recordsPerPage)
                            .limit(recordsPerPage)
                            .collect(Collectors.toList());
                    int noOfRecords = listCinemas.size();
                    int noOfPages = (int) Math.ceil(noOfRecords * 1.0 / recordsPerPage);

                    request.setAttribute("listCinemas", cinemasPerPage);
                    request.setAttribute("recordsPerPage", recordsPerPage);
                    request.setAttribute("noOfPages", noOfPages);
                }
                request.setAttribute("currentPage", page);
                request.setAttribute("search", search);
                request.setAttribute("statusFilter", statusFilter);
                request.setAttribute("section", section);
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
                            // Get data
                            String fullname = request.getParameter("fullname");
                            String email = request.getParameter("email");
                            String phone = request.getParameter("phonenumber");
                            String role = request.getParameter("role");

                            // Validate input
                            if (ud.checkExistedEmail(email)) {
                                request.getSession().setAttribute("showToast", "add_error_email");
                                response.sendRedirect("dashboard?section=user-management");
                                return;
                            }

                            if (ud.checkExistedPhone(phone)) {
                                request.getSession().setAttribute("showToast", "add_error_phone");
                                response.sendRedirect("dashboard?section=user-management");
                                return;
                            }

                            // Create temporary password
                            String temp_pass = ud.generatePassword(12);

                            // Save temporary user to database
                            boolean isCreated = ud.addNewUser(fullname, email, phone, temp_pass, "Male", role, ud.generateAddress(), Date.valueOf(ud.generateRandomDOB(18, 60)), "Temporary");
                            System.out.println("User created: " + isCreated);

                            if (isCreated) {
                                // Record logs
//                                boolean addLog = lhd.addNewLog(new LogHistory(1, "CREATE", "USER", null, "N/A", "N/A", "Add new temporary account: <br>"
//                                        + "Account Details:<br>"
//                                        + "Full Name: " + fullname + "<br>"
//                                        + "Email: " + email + "<br>"
//                                        + "Phone: " + phone + "<br>"
//                                        + "Role: " + role + "<br>"
//                                        + "Temporary Password: " + temp_pass + "<br>"
//                                        + "Need login and change temporary password.", "N/A"));
//                                System.out.println("Log added: " + addLog);

                                // Send email with credentials
                                String emailContent = "Your account has been created successfully!\n\n"
                                        + "Account Details:\n"
                                        + "Full Name: " + fullname + "\n"
                                        + "Email: " + email + "\n"
                                        + "Phone: " + phone + "\n"
                                        + "Role: " + role + "\n"
                                        + "Temporary Password: " + temp_pass + "\n\n"
                                        + "Please login and change your password immediately.";

                                boolean emailSent = es.sendEmail(email, "Account Created Successfully!", emailContent);
                                if (emailSent) {
                                    request.getSession().setAttribute("showToast", "add_success");
                                } else {
                                    request.getSession().setAttribute("showToast", "add_success_no_email");
                                    // Log this case as it's not critical but should be monitored
                                    System.err.println("User created but email not sent to: " + email);
                                }

                                // Temporary: always show success for testing
                                request.getSession().setAttribute("showToast", "add_success");
                            } else {
                                request.getSession().setAttribute("showToast", "add_failed");
                            }
                        } catch (NumberFormatException e) {
                            request.getSession().setAttribute("ExceptionError", "add_failed");
                            request.getSession().setAttribute("showError", "Error: " + e.getMessage());
                            System.out.println("Error in add user: " + e.getMessage());
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
                CinemaDAO cd = new CinemaDAO();
//                LogHistoryDAO lhd = new LogHistoryDAO();

                String action = request.getParameter("action");
                switch (action) {
                    case "add" -> {
                        try {
                            // Get data
                            String cinemaName = request.getParameter("cinemaName");
                            String location = request.getParameter("location");
                            int totalRooms = Integer.parseInt(request.getParameter("totalRooms"));
                            boolean isActive = request.getParameter("isActive") != null;

                            // Validate input
                            if (cd.checkCinemaNameExists(cinemaName)) {
                                request.getSession().setAttribute("showToast", "add_error_name");
                                response.sendRedirect("dashboard?section=cinema-management");
                                return;
                            }

                            // Validate total rooms
                            if (totalRooms < 1 || totalRooms > 50) {
                                request.getSession().setAttribute("showToast", "add_error");
                                request.getSession().setAttribute("showError", "Total rooms must be between 1 and 50");
                                response.sendRedirect("dashboard?section=cinema-management");
                                return;
                            }

                            // Save cinema to database
                            boolean isCreated = cd.addNewCinema(cinemaName, location, totalRooms, isActive);
                            System.out.println("Cinema created: " + isCreated);

                            if (isCreated) {
                                // Record logs
//                                boolean addLog = lhd.addNewLog(new LogHistory(1, "CREATE", "CINEMA", null, "N/A", "N/A", "Add new cinema: <br>"
//                                        + "Cinema Details:<br>"
//                                        + "Name: " + cinemaName + "<br>"
//                                        + "Location: " + location + "<br>"
//                                        + "Total Rooms: " + totalRooms + "<br>"
//                                        + "Status: " + (isActive ? "Active" : "Inactive"), "N/A"));
//                                System.out.println("Log added: " + addLog);

                                request.getSession().setAttribute("showToast", "add_success");
                            } else {
                                request.getSession().setAttribute("showToast", "add_error");
                                request.getSession().setAttribute("showError", "Failed to create cinema");
                            }
                        } catch (NumberFormatException e) {
                            request.getSession().setAttribute("showToast", "add_error");
                            request.getSession().setAttribute("showError", "Error: Invalid total rooms format");
                            System.out.println("Error in add cinema: " + e.getMessage());
                        }
                        response.sendRedirect("dashboard?section=cinema-management");
                    }
                    case "delete" -> {
                        try {
                            int cinemaId = Integer.parseInt(request.getParameter("cinemaId"));
                            // Call your service to delete the cinema (soft delete)
                            boolean isDeleted = cd.deleteCinema(cinemaId);

                            if (isDeleted) {
//                                boolean addLog = lhd.addNewLog(new LogHistory(1, "DELETE", "CINEMA", cinemaId, "N/A", "N/A", "Delete cinema for testing", "N/A"));
//                                System.out.println("Delete log added: " + addLog);
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
                            int totalRooms = Integer.parseInt(request.getParameter("totalRooms"));
                            boolean isActive = request.getParameter("isActive") != null;

                            Cinema cinema = cd.getCinemaByID(cinemaId);

                            if (cinema == null) {
                                request.getSession().setAttribute("showToast", "update_error");
                                request.getSession().setAttribute("showError", "Error update cinema: Cinema not found");
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

                            // Validate total rooms
                            if (totalRooms < 1 || totalRooms > 50) {
                                request.getSession().setAttribute("showToast", "update_error");
                                request.getSession().setAttribute("showError", "Total rooms must be between 1 and 50");
                                response.sendRedirect("dashboard?section=cinema-management");
                                return;
                            }

                            // Log get input
                            System.out.println("Current Cinema: " + cinema.getCinemaName());
                            System.out.println("New Cinema Name: " + cinemaName);
                            System.out.println("Current Location: " + cinema.getLocation());
                            System.out.println("New Location: " + location);
                            System.out.println("Current Rooms: " + cinema.getTotalRooms());
                            System.out.println("New Rooms: " + totalRooms);
                            System.out.println("Current Status: " + cinema.getIsActive());
                            System.out.println("New Status: " + isActive);

                            // Set value for log (commented out for now)
//                            String old_value = "Name: " + cinema.getCinemaName() + ", Location: " + cinema.getLocation() + 
//                                    ", Rooms: " + cinema.getTotalRooms() + ", Status: " + cinema.getIsActive() + ".";
//                            String new_value = "Name: " + cinemaName + ", Location: " + location + 
//                                    ", Rooms: " + totalRooms + ", Status: " + isActive + ".";
                            boolean isUpdated = cd.updateCinema(cinemaId, cinemaName, location, totalRooms, isActive);

                            if (isUpdated) {
                                request.getSession().setAttribute("showToast", "update_success");

//                                boolean addLog = lhd.addNewLog(new LogHistory(1, "UPDATE", "CINEMA", cinemaId, old_value, new_value, "Update cinema information.", "N/A"));
//                                System.out.println("Update log added: " + addLog);
                            } else {
                                request.getSession().setAttribute("showToast", "update_error");
                                request.getSession().setAttribute("showError", "Error update cinema: Update failed");
                            }
                        } catch (NumberFormatException e) {
                            request.getSession().setAttribute("showToast", "update_error");
                            request.getSession().setAttribute("showError", "Error update cinema: " + e.getMessage());
                            System.out.println("Error in update cinema: " + e.getMessage());
                        }
                        response.sendRedirect("dashboard?section=cinema-management");
                    }
                    default ->
                        response.sendRedirect("dashboard?section=cinema-management");
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
