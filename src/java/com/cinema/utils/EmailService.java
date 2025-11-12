package com.cinema.utils;


import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.mail.Authenticator;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;

public class EmailService {
    private static final Logger LOGGER = Logger.getLogger(EmailService.class.getName());
    
    // SMTP Configuration - Update these with your actual email credentials
    private final String SMTP_HOST = "smtp.gmail.com";
    private final String SMTP_PORT = "587";
    private final String SMTP_USER = "swordartonline282@gmail.com";
    private final String SMTP_PASS = "lfbo sxny fzru zygm";
    
    // Email templates
    private static final String ACCOUNT_CREATION_SUBJECT = "Account Created Successfully - Cinema Management System";
    private static final String ACCOUNT_CREATION_TEMPLATE = """
        Dear %s,
        
        Your account has been successfully created in the Cinema Management System.
        
        ACCOUNT DETAILS:
        • Full Name: %s
        • Email: %s
        • Phone: %s
        • Role: %s
        • Temporary Password: %s
        
        IMPORTANT SECURITY NOTES:
        1. This is a temporary password
        2. You must change your password immediately after first login
        3. Keep your login credentials confidential
        4. Do not share your password with anyone
        
        LOGIN INSTRUCTIONS:
        1. Go to the login page
        2. Enter your email: %s
        3. Enter the temporary password provided above
        4. You will be prompted to change your password
        
        If you did not request this account or believe this is an error, 
        please contact the system administrator immediately.
        
        Best regards,
        Cinema Management System Admin Team
        
        --- This is an automated message. Please do not reply to this email. ---
        """;

    public EmailService() {
        LOGGER.log(Level.INFO, "EmailService initialized with SMTP host: {0}", SMTP_HOST);
    }
    
    /**
     * Send email for new account creation
     */
    public boolean sendAccountCreationEmail(String to, String fullName, String email, 
                                          String phone, String role, String tempPassword) {
        try {
            System.out.println("=== EMAIL SERVICE DEBUG ===");
            System.out.println("Preparing to send account creation email...");
            System.out.println("Recipient: " + to);
            System.out.println("Full Name: " + fullName);
            System.out.println("Role: " + role);
            
            String subject = ACCOUNT_CREATION_SUBJECT;
            String body = String.format(ACCOUNT_CREATION_TEMPLATE, 
                fullName, fullName, email, phone, role, tempPassword, email);
            
            System.out.println("Email subject: " + subject);
            System.out.println("Email body length: " + body.length());
            
            boolean result = sendEmail(to, subject, body);
            System.out.println("Email sending result: " + result);
            
            return result;
            
        } catch (Exception e) {
            System.err.println("Error in sendAccountCreationEmail: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Generic email sending method
     */
    public boolean sendEmail(String to, String subject, String body) {
        System.out.println("=== SEND EMAIL METHOD DEBUG ===");
        System.out.println("To: " + to);
        System.out.println("Subject: " + subject);
        System.out.println("Body preview: " + (body.length() > 100 ? body.substring(0, 100) + "..." : body));
        
        // Validate inputs
        if (to == null || to.trim().isEmpty()) {
            LOGGER.log(Level.SEVERE, "Recipient email is null or empty");
            return false;
        }
        
        if (subject == null || subject.trim().isEmpty()) {
            LOGGER.log(Level.SEVERE, "Email subject is null or empty");
            return false;
        }
        
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", SMTP_HOST);
        props.put("mail.smtp.port", SMTP_PORT);
        props.put("mail.smtp.ssl.trust", SMTP_HOST);
        props.put("mail.smtp.ssl.protocols", "TLSv1.2");
        
        // Additional properties for better compatibility
        props.put("mail.smtp.connectiontimeout", "5000");
        props.put("mail.smtp.timeout", "5000");
        props.put("mail.smtp.writetimeout", "5000");

        try {
            Session session = Session.getInstance(props, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    System.out.println("Authenticating with: " + SMTP_USER);
                    return new PasswordAuthentication(SMTP_USER, SMTP_PASS);
                }
            });
            
            // Enable debug mode to see SMTP communication
            session.setDebug(true);

            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(SMTP_USER, "Cinema Management System"));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
            message.setSubject(subject);
            message.setText(body);

            System.out.println("Attempting to send email...");
            Transport.send(message);
            
            LOGGER.log(Level.INFO, "✅ Email sent successfully to: {0}", to);
            System.out.println("✅ Email sent successfully!");
            return true;
            
        } catch (MessagingException e) {
            LOGGER.log(Level.SEVERE, "❌ Failed to send email to: " + to, e);
            System.err.println("❌ Email sending failed: " + e.getMessage());
            e.printStackTrace();
            return false;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "❌ Unexpected error sending email to: " + to, e);
            System.err.println("❌ Unexpected error: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Test email configuration
     */
    public boolean testEmailConfiguration() {
        System.out.println("=== TESTING EMAIL CONFIGURATION ===");
        System.out.println("SMTP Host: " + SMTP_HOST);
        System.out.println("SMTP Port: " + SMTP_PORT);
        System.out.println("SMTP User: " + SMTP_USER);
        System.out.println("SMTP Pass: " + (SMTP_PASS != null ? "***" + SMTP_PASS.substring(Math.max(0, SMTP_PASS.length() - 3)) : "NULL"));
        
        try {
            // Simple configuration test
            Properties props = new Properties();
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");
            props.put("mail.smtp.host", SMTP_HOST);
            props.put("mail.smtp.port", SMTP_PORT);
            
            Session session = Session.getInstance(props, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(SMTP_USER, SMTP_PASS);
                }
            });
            
            session.setDebug(true);
            System.out.println("✅ Email configuration test passed");
            return true;
            
        } catch (Exception e) {
            System.err.println("❌ Email configuration test failed: " + e.getMessage());
            return false;
        }
    }
    
    /**
     * Get SMTP configuration info (for debugging)
     */
    public String getConfigInfo() {
        return String.format("""
            SMTP Configuration:
            • Host: %s
            • Port: %s
            • User: %s
            • Auth: %s
            • TLS: %s
            """, SMTP_HOST, SMTP_PORT, SMTP_USER, "true", "true");
    }
}