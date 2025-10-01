/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dal.UserDAO;
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
        try {
            String section = request.getParameter("section");
            if (section != null && section.equals("user-management")) {
                try {
                    String action = request.getParameter("action");
                    if (action != null) {
                        // Check view list or view detail
                        if (action.equals("view")) {
                            int user_Id = Integer.parseInt(request.getParameter("userId"));
                            User user = ud.getUserByID(user_Id);
                            if (user != null) {
                                System.out.println("true");
                            }
                            request.setAttribute("viewUser", user);
                        }
                    }
                } catch (NumberFormatException e) {
                    System.out.println(e);
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
                // Page setting
                int page = 1;
                int recordsPerPage = 10;
                try {
                    page = Integer.parseInt(request.getParameter("page"));
                } catch (NumberFormatException e) {
                    System.out.println(e);
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
            }
            response.setContentType("text/html;charset=UTF-8");
            request.setCharacterEncoding("UTF-8");
            request.getRequestDispatcher("admin_dashboard.jsp").forward(request, response);
        } catch (ServletException | IOException e) {
            System.out.println(e);
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
//                EmailService es = new EmailService();
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
                            System.out.println(isCreated);

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
//                                System.out.println(addLog);

                                // Send email with credentials
                                String emailContent = "Your account has been created successfully!\n\n"
                                        + "Account Details:\n"
                                        + "Full Name: " + fullname + "\n"
                                        + "Email: " + email + "\n"
                                        + "Phone: " + phone + "\n"
                                        + "Role: " + role + "\n"
                                        + "Temporary Password: " + temp_pass + "\n\n"
                                        + "Please login and change your password immediately.";

//                                boolean emailSent = es.sendEmail(email, "Account Created Successfully!", emailContent);
//                                if (emailSent) {
//                                    request.getSession().setAttribute("showToast", "add_success");
//                                } else {
//                                    request.getSession().setAttribute("showToast", "add_success_no_email");
//                                    // Log this case as it's not critical but should be monitored
//                                    System.err.println("User created but email not sent to: " + email);
//                                }
                            } else {
                                request.getSession().setAttribute("showToast", "add_failed");
                            }
                        } catch (NumberFormatException e) {
                            request.getSession().setAttribute("ExceptionError", "add_failed");
                            request.getSession().setAttribute("showError", "Error: " + e.getMessage());
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
//                                System.out.println(addLog);
                            }
                            // Set success message
                            request.getSession().setAttribute("showToast", "delete_success");
                        } catch (NumberFormatException e) {
                            request.getSession().setAttribute("ExceptionError", "delete_failed");
                            request.getSession().setAttribute("showError", "Error deleting user: " + e.getMessage());
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

                            // Log get input
                            System.out.println(user.getRole());
                            System.out.println(role);
                            System.out.println(user.getAccountStatus());
                            System.out.println(status);

                            //Set value
//                            String old_value = "Role: " + user.getRole() + " , Status: " + user.getStatus() + ".";
//                            String new_value = "Role: " + role + " , Status: " + status + ".";

                            boolean isUpdated = ud.updateSettingUser(role, status, userId);

                            if (isUpdated) {
                                request.getSession().setAttribute("showToast", "update_success");

//                                boolean addLog = lhd.addNewLog(new LogHistory(1, "UPDATE", "USER", userId, old_value, new_value, "Update setting for user account.", "N/A"));
//                                System.out.println(addLog);
                            }
                        } catch (NumberFormatException e) {
                            request.getSession().setAttribute("ExceptionError", "update_failed");
                            request.getSession().setAttribute("showError", "Error update user: " + e.getMessage());
                        }
                        response.sendRedirect("dashboard?section=user-management");
                    }
                    default ->
                        response.sendRedirect("dashboard?section=user-management");
                }
            }
        } catch (IOException e) {
            System.out.println(e);
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
