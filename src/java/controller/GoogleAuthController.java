package controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import utils.GoogleOAuthConfig;

/**
 * Google OAuth Controller
 * Handles Google OAuth login and signup redirects
 */
public class GoogleAuthController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        
        if ("login".equals(action) || "signup".equals(action)) {
            // Store the action in session for later use
            request.getSession().setAttribute("oauth_action", action);
            
            // Redirect to Google OAuth
            String authUrl = GoogleOAuthConfig.getAuthorizationUrl();
            response.sendRedirect(authUrl);
        } else {
            // Default to login if no action specified
            request.getSession().setAttribute("oauth_action", "login");
            String authUrl = GoogleOAuthConfig.getAuthorizationUrl();
            response.sendRedirect(authUrl);
        }
    }
}
