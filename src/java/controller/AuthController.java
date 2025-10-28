package controller;

import dal.UserDAO;
import entity.User;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Date;
import java.time.LocalDate;
import java.util.UUID;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import utils.EmailService;

/**
 * Main Authentication Controller
 * Handles login, signup, logout, and forgot password functionality
 */
public class AuthController extends HttpServlet {

    private UserDAO userDAO = new UserDAO();
    private EmailService emailService = new EmailService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getPathInfo();
        
        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        switch (action) {
            case "/login":
                showLoginPage(request, response);
                break;
            case "/signup":
                showSignupPage(request, response);
                break;
            case "/logout":
                handleLogout(request, response);
                break;
            case "/forgot-password":
                showForgotPasswordPage(request, response);
                break;
            case "/reset-password":
                showResetPasswordPage(request, response);
                break;
            default:
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getPathInfo();
        
        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        switch (action) {
            case "/login":
                handleLogin(request, response);
                break;
            case "/signup":
                handleSignup(request, response);
                break;
            case "/logout":
                handleLogout(request, response);
                break;
            case "/forgot-password":
                handleForgotPassword(request, response);
                break;
            case "/reset-password":
                handleResetPassword(request, response);
                break;
            default:
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    private void showLoginPage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/login.jsp").forward(request, response);
    }

    private void showSignupPage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/signup.jsp").forward(request, response);
    }

    private void showForgotPasswordPage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/forgot-password.jsp").forward(request, response);
    }

    private void showResetPasswordPage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String token = request.getParameter("token");
        if (token == null || token.trim().isEmpty()) {
            request.setAttribute("error", "Invalid or missing reset token");
            request.getRequestDispatcher("/forgot-password.jsp").forward(request, response);
            return;
        }
        
        // TODO: Validate token in database
        request.setAttribute("token", token);
        request.getRequestDispatcher("/reset-password.jsp").forward(request, response);
    }

    private void handleLogin(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        
        if (email == null || password == null || email.trim().isEmpty() || password.trim().isEmpty()) {
            request.setAttribute("error", "Email and password are required");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }
        
        User user = userDAO.authenticate(email.trim(), password);
        
        if (user == null) {
            request.setAttribute("error", "Invalid email or password");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }
        
        if (!"Active".equals(user.getAccountStatus())) {
            request.setAttribute("error", "Your account is not active. Please contact support.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }
        
        // Create session
        HttpSession session = request.getSession();
        session.setAttribute("user", user);
        session.setAttribute("userName", user.getFullName());
        session.setAttribute("userEmail", user.getEmail());
        session.setAttribute("userRole", user.getRole());
        session.setAttribute("userId", user.getUserID());
        
        // Redirect based on role
        if ("Admin".equals(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/adminFE/dashboard");
        } else if ("Staff".equals(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/list"); // Staff goes to movie management
        } else {
            response.sendRedirect(request.getContextPath() + "/index.jsp"); // Customers go to homepage
        }
    }

    private void handleSignup(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phoneNumber = request.getParameter("phoneNumber");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String gender = request.getParameter("gender");
        String address = request.getParameter("address");
        String dateOfBirthStr = request.getParameter("dateOfBirth");
        
        // Validation
        if (fullName == null || email == null || password == null || 
            fullName.trim().isEmpty() || email.trim().isEmpty() || password.trim().isEmpty()) {
            request.setAttribute("error", "Full name, email, and password are required");
            request.getRequestDispatcher("/signup.jsp").forward(request, response);
            return;
        }
        
        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Passwords do not match");
            request.getRequestDispatcher("/signup.jsp").forward(request, response);
            return;
        }
        
        if (password.length() < 6) {
            request.setAttribute("error", "Password must be at least 6 characters long");
            request.getRequestDispatcher("/signup.jsp").forward(request, response);
            return;
        }
        
        // Check if email already exists
        if (userDAO.checkExistedEmail(email.trim())) {
            request.setAttribute("error", "Email already exists");
            request.getRequestDispatcher("/signup.jsp").forward(request, response);
            return;
        }
        
        // Check if phone already exists (if provided)
        if (phoneNumber != null && !phoneNumber.trim().isEmpty() && userDAO.checkExistedPhone(phoneNumber.trim())) {
            request.setAttribute("error", "Phone number already exists");
            request.getRequestDispatcher("/signup.jsp").forward(request, response);
            return;
        }
        
        // Parse date of birth
        Date dateOfBirth = null;
        if (dateOfBirthStr != null && !dateOfBirthStr.trim().isEmpty()) {
            try {
                dateOfBirth = Date.valueOf(dateOfBirthStr);
            } catch (IllegalArgumentException e) {
                request.setAttribute("error", "Invalid date of birth format");
                request.getRequestDispatcher("/signup.jsp").forward(request, response);
                return;
            }
        }
        
        // Create new user
        boolean success = userDAO.addNewUser(
            fullName.trim(),
            email.trim(),
            phoneNumber != null ? phoneNumber.trim() : null,
            password,
            gender != null ? gender : "Other",
            "Customer", // Default role
            address != null ? address.trim() : null,
            dateOfBirth,
            "Active" // Default status
        );
        
        if (success) {
            request.setAttribute("success", "Account created successfully! You can now login.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        } else {
            request.setAttribute("error", "Failed to create account. Please try again.");
            request.getRequestDispatcher("/signup.jsp").forward(request, response);
        }
    }

    private void handleForgotPassword(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = request.getParameter("email");
        
        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("error", "Email is required");
            request.getRequestDispatcher("/forgot-password.jsp").forward(request, response);
            return;
        }
        
        User user = userDAO.getUserByEmail(email.trim());
        
        if (user == null) {
            // For security, don't reveal if email exists or not
            request.setAttribute("success", "If the email exists, a password reset link has been sent.");
            request.getRequestDispatcher("/forgot-password.jsp").forward(request, response);
            return;
        }
        
        // Generate reset token
        String resetToken = UUID.randomUUID().toString();
        
        // Store reset token in database
        boolean tokenStored = userDAO.storePasswordResetToken(email.trim(), resetToken);
        
        if (!tokenStored) {
            request.setAttribute("error", "Failed to generate reset token. Please try again.");
            request.getRequestDispatcher("/forgot-password.jsp").forward(request, response);
            return;
        }
        
        // Send reset email
        String resetLink = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + 
                          request.getContextPath() + "/auth/reset-password?token=" + resetToken;
        
        String subject = "Password Reset Request";
        String body = "Hello " + user.getFullName() + ",\n\n" +
                     "You requested a password reset. Click the link below to reset your password:\n\n" +
                     resetLink + "\n\n" +
                     "This link will expire in 1 hour.\n\n" +
                     "If you didn't request this, please ignore this email.\n\n" +
                     "Best regards,\nCinema Management Team";
        
        boolean emailSent = emailService.sendEmail(email, subject, body);
        
        if (emailSent) {
            request.setAttribute("success", "Password reset link has been sent to your email.");
        } else {
            request.setAttribute("error", "Failed to send reset email. Please try again later.");
        }
        
        request.getRequestDispatcher("/forgot-password.jsp").forward(request, response);
    }

    private void handleResetPassword(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String token = request.getParameter("token");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");
        
        if (token == null || token.trim().isEmpty()) {
            request.setAttribute("error", "Invalid reset token");
            request.getRequestDispatcher("/forgot-password.jsp").forward(request, response);
            return;
        }
        
        if (newPassword == null || confirmPassword == null || 
            newPassword.trim().isEmpty() || confirmPassword.trim().isEmpty()) {
            request.setAttribute("error", "Password fields are required");
            request.setAttribute("token", token);
            request.getRequestDispatcher("/reset-password.jsp").forward(request, response);
            return;
        }
        
        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("error", "Passwords do not match");
            request.setAttribute("token", token);
            request.getRequestDispatcher("/reset-password.jsp").forward(request, response);
            return;
        }
        
        if (newPassword.length() < 6) {
            request.setAttribute("error", "Password must be at least 6 characters long");
            request.setAttribute("token", token);
            request.getRequestDispatcher("/reset-password.jsp").forward(request, response);
            return;
        }
        
        // Validate token and get user
        User user = userDAO.getUserByResetToken(token);
        
        if (user == null) {
            request.setAttribute("error", "Invalid or expired reset token");
            request.getRequestDispatcher("/forgot-password.jsp").forward(request, response);
            return;
        }
        
        // Update password
        boolean success = userDAO.updatePasswordByToken(token, newPassword);
        
        if (success) {
            request.setAttribute("success", "Password has been reset successfully. You can now login with your new password.");
        } else {
            request.setAttribute("error", "Failed to reset password. Please try again.");
        }
        
        request.getRequestDispatcher("/login.jsp").forward(request, response);
    }

    private void handleLogout(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        response.sendRedirect(request.getContextPath() + "/index.jsp");
    }
}
