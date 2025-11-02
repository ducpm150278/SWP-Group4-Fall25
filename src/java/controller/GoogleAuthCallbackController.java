package controller;

import dal.UserDAO;
import entity.User;
import java.io.IOException;
import java.sql.Date;
import java.time.LocalDate;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import utils.GoogleOAuthHelper;

/**
 * Google OAuth Callback Controller
 * Handles the callback from Google OAuth and processes login/signup
 */
public class GoogleAuthCallbackController extends HttpServlet {

    private UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String code = request.getParameter("code");
        String error = request.getParameter("error");
        
        if (error != null) {
            request.setAttribute("error", "Google OAuth error: " + error);
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }
        
        if (code == null || code.trim().isEmpty()) {
            request.setAttribute("error", "No authorization code received from Google");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }
        
        try {
            // Exchange code for access token
            String accessToken = GoogleOAuthHelper.exchangeCodeForToken(code);
            
            // Get user info from Google
            String userInfoJson = GoogleOAuthHelper.getUserInfo(accessToken);
            
            // Extract user information
            String email = GoogleOAuthHelper.extractUserEmail(userInfoJson);
            String name = GoogleOAuthHelper.extractUserName(userInfoJson);
            
            if (email == null || name == null) {
                request.setAttribute("error", "Failed to retrieve user information from Google");
                request.getRequestDispatcher("/login.jsp").forward(request, response);
                return;
            }
            
            // Get the action from session
            HttpSession session = request.getSession();
            String action = (String) session.getAttribute("oauth_action");
            if (action == null) {
                action = "login"; // Default to login
            }
            
            // Check if user exists
            User existingUser = userDAO.getUserByEmail(email);
            
            if (existingUser != null) {
                // User exists
                if ("login".equals(action)) {
                    // Login with Gmail - user exists, allow login
                    if (!"Active".equals(existingUser.getAccountStatus())) {
                        // For Google OAuth users, automatically activate the account
                        boolean updateSuccess = userDAO.updateUserStatus(existingUser.getUserID(), "Active");
                        if (updateSuccess) {
                            // Refresh user data
                            existingUser = userDAO.getUserByEmail(email);
                        } else {
                            request.setAttribute("error", "Your account is not active. Please contact support.");
                            request.getRequestDispatcher("/login.jsp").forward(request, response);
                            return;
                        }
                    }
                    
                    // Create session
                    session.setAttribute("user", existingUser);
                    session.setAttribute("userName", existingUser.getFullName());
                    session.setAttribute("userEmail", existingUser.getEmail());
                    session.setAttribute("userRole", existingUser.getRole());
                    session.setAttribute("userId", existingUser.getUserID());
                    
                    // Redirect based on role
                    if ("Admin".equals(existingUser.getRole())) {
                        response.sendRedirect(request.getContextPath() + "/list");
                    } else {
                        response.sendRedirect(request.getContextPath() + "/index.jsp");
                    }
                } else if ("signup".equals(action)) {
                    // Sign up with Gmail - user already exists, deny
                    request.setAttribute("error", "An account with this Google email already exists. Please use login instead.");
                    request.getRequestDispatcher("/login.jsp").forward(request, response);
                    return;
                }
                
            } else if ("signup".equals(action)) {
                // User doesn't exist and action is signup - create new user
                String phoneNumber = null; // Google doesn't provide phone number
                String password = "GOOGLE_OAUTH_USER"; // Placeholder password for OAuth users
                String gender = "Other"; // Default gender
                String address = null; // Google doesn't provide address
                Date dateOfBirth = null; // Google doesn't provide DOB
                
                boolean success = userDAO.addNewUser(
                    name,
                    email,
                    phoneNumber,
                    password,
                    gender,
                    "Customer", // Default role
                    address,
                    dateOfBirth,
                    "Active" // Default status
                );
                
                if (success) {
                    // Get the newly created user
                    User newUser = userDAO.getUserByEmail(email);
                    
                    // Create session
                    session.setAttribute("user", newUser);
                    session.setAttribute("userName", newUser.getFullName());
                    session.setAttribute("userEmail", newUser.getEmail());
                    session.setAttribute("userRole", newUser.getRole());
                    session.setAttribute("userId", newUser.getUserID());
                    
                    response.sendRedirect(request.getContextPath() + "/index.jsp");
                } else {
                    request.setAttribute("error", "Failed to create account. Please try again.");
                    request.getRequestDispatcher("/auth/signup.jsp").forward(request, response);
                }
                
            } else {
                // User doesn't exist
                if ("login".equals(action)) {
                    // Login with Gmail - user doesn't exist, deny
                    request.setAttribute("error", "No account found with this Google email. Please sign up first.");
                    request.getRequestDispatcher("/login.jsp").forward(request, response);
                } else {
                    // Sign up with Gmail - user doesn't exist, allow signup
                    request.setAttribute("error", "Invalid action. Please try again.");
                    request.getRequestDispatcher("/login.jsp").forward(request, response);
                }
            }
            
        } catch (Exception e) {
            System.err.println("Google OAuth error: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Authentication failed: " + e.getMessage() + ". Please try again.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        }
    }
}
