package com.cinema.controller.auth;

import com.cinema.dal.UserDAO;
import com.cinema.entity.User;
import com.cinema.utils.Constants;
import com.cinema.utils.EmailService;
import com.cinema.utils.SessionUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Random;

@WebServlet(name = "VerifyEmailServlet", urlPatterns = {"/VerifyEmail"})
public class VerifyEmailServlet extends HttpServlet {

    private UserDAO userDAO;
    private EmailService emailService;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
        emailService = new EmailService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        if (SessionUtils.getUser(session) == null) {
            response.sendRedirect(request.getContextPath() + Constants.URL_AUTH_LOGIN);
            return;
        }
        
        request.getRequestDispatcher(Constants.JSP_AUTH_VERIFY_EMAIL).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) SessionUtils.getUser(session);

        if (user == null) {
            request.setAttribute("error", "You must be logged in to perform this action.");
            request.getRequestDispatcher(Constants.JSP_AUTH_LOGIN).forward(request, response);
            return;
        }

        String action = request.getParameter("action");

        if (action == null) {
            request.setAttribute("error", "Invalid action.");
            request.getRequestDispatcher(Constants.JSP_AUTH_VERIFY_EMAIL).forward(request, response);
            return;
        }

        if (Constants.ACTION_SEND_CODE.equals(action)) {
            String emailToSend = user.getEmail();
            String code = String.format("%06d", new Random().nextInt(999999));
            boolean emailSent = sendVerificationEmail(emailToSend, code);

            if (emailSent) {
                session.setAttribute(Constants.SESSION_VERIFICATION_CODE, code);
                session.setAttribute(Constants.SESSION_VERIFICATION_EMAIL, emailToSend); 
                session.setAttribute(Constants.SESSION_VERIFICATION_EXPIRY, System.currentTimeMillis() + 600000);
                request.setAttribute("emailSent", emailToSend);
                request.setAttribute("message", "A verification code has been sent to " + emailToSend + ".");
            } else {
                request.setAttribute("error", "Failed to send verification email. Please try again later.");
            }

            request.getRequestDispatcher(Constants.JSP_AUTH_VERIFY_EMAIL).forward(request, response);
        
        } else if (Constants.ACTION_VERIFY.equals(action)) {
            String formCode = request.getParameter("verificationCode");
            String savedCode = (String) session.getAttribute(Constants.SESSION_VERIFICATION_CODE);
            String savedEmail = (String) session.getAttribute(Constants.SESSION_VERIFICATION_EMAIL);
            Long expiryTime = (Long) session.getAttribute(Constants.SESSION_VERIFICATION_EXPIRY);

            if (savedCode == null || savedEmail == null || expiryTime == null) {
                request.setAttribute("error", "Your verification session has expired. Please request a new code.");
                request.getRequestDispatcher(Constants.JSP_AUTH_VERIFY_EMAIL).forward(request, response);
                return;
            }

            if (System.currentTimeMillis() > expiryTime) {
                request.setAttribute("error", "Your verification code has expired. Please request a new one.");
                session.removeAttribute(Constants.SESSION_VERIFICATION_CODE);
                session.removeAttribute(Constants.SESSION_VERIFICATION_EMAIL);
                session.removeAttribute(Constants.SESSION_VERIFICATION_EXPIRY);
                request.getRequestDispatcher(Constants.JSP_AUTH_VERIFY_EMAIL).forward(request, response);
                return;
            }

            if (savedCode != null && savedCode.equals(formCode)) {
                boolean success = userDAO.updateVerificationStatus(user.getUserID(), true);
                if (success) {
                    user.setEmailVerified(true);
                    session.setAttribute(SessionUtils.ATTR_USER, user);
                    request.setAttribute("message", "Email successfully verified!");
                    session.removeAttribute(Constants.SESSION_VERIFICATION_CODE);
                    session.removeAttribute(Constants.SESSION_VERIFICATION_EMAIL);
                    session.removeAttribute(Constants.SESSION_VERIFICATION_EXPIRY);
                } else {
                    request.setAttribute("error", "A database error occurred. Could not update status.");
                    request.setAttribute("emailSent", savedEmail);
                }

            } else {
                request.setAttribute("error", "Invalid verification code. Please try again.");
                request.setAttribute("emailSent", savedEmail);
            }
            
            request.getRequestDispatcher(Constants.JSP_AUTH_VERIFY_EMAIL).forward(request, response);
        }
    }

    private boolean sendVerificationEmail(String toEmail, String code) {
        String subject = "Your Cinema Management Verification Code";
        String emailBody = "Hello,\n\n"
                + "Your verification code is: " + code + "\n\n"
                + "This code will expire in 10 minutes.\n\n"
                + "Thank you,\n"
                + "Cinema Management Team";
        
        return emailService.sendEmail(toEmail, subject, emailBody);
    }
}