package controller;

import dal.BookingDAO;
import entity.BookingDetailDTO;
import entity.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

import java.util.Properties;
import javax.mail.Authenticator;
import javax.mail.Message;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import java.time.LocalDateTime; 
import java.time.format.DateTimeFormatter; 
import java.util.Locale; 

@WebServlet(name = "TicketCheckInServlet", urlPatterns = {"/staff-check-in"})
public class TicketCheckInServlet extends HttpServlet {

    private BookingDAO bookingDAO;

    @Override
    public void init() throws ServletException {
        bookingDAO = new BookingDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null || (!"Admin".equals(user.getRole()) && !"Staff".equals(user.getRole()))) {
            response.sendRedirect("login.jsp");
            return;
        }

        request.setAttribute("activePage", "staff-check-in");

        String searchTerm = request.getParameter("searchTerm");

        if (searchTerm != null && !searchTerm.isEmpty()) {
            List<BookingDetailDTO> bookings = bookingDAO.findBookingsForCheckIn(searchTerm);

            if (bookings != null && !bookings.isEmpty()) {
                request.setAttribute("bookings", bookings);
            } else {
                request.setAttribute("error", "Không tìm thấy đơn đặt vé nào (chưa check-in) với mã: " + searchTerm);
            }
        }

        request.getRequestDispatcher("staff-check-in.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        int bookingID = Integer.parseInt(request.getParameter("bookingID"));

BookingDetailDTO booking = bookingDAO.getBookingDetailByID_Staff(bookingID);
        if (booking == null) {
            request.setAttribute("error", "Lỗi: Không tìm thấy vé để check-in.");
            doGet(request, response);
            return;
        }

        LocalDateTime checkInTime = LocalDateTime.now();
        boolean success = false;

        if ("check-in-paid".equals(action)) {
            // Kịch bản: Khách đã thanh toán
            success = bookingDAO.updateBookingStatus(bookingID, "Completed");
            if (success) {
                request.setAttribute("message", "Check-in thành công cho đơn " + booking.getBookingCode());
            } else {
                request.setAttribute("error", "Lỗi khi check-in đơn " + booking.getBookingCode());
            }
            

        if (success) {
            sendCheckInConfirmationEmail(booking, checkInTime);
        }
        
        String searchTerm = request.getParameter("searchTerm");
        if (searchTerm != null) {
            request.setAttribute("searchTerm", searchTerm);
        }
        doGet(request, response);
    }
    }
    
    private boolean sendCheckInConfirmationEmail(BookingDetailDTO booking, LocalDateTime checkInTime) {
        
        String customerEmail = booking.getCustomerEmail();
        System.out.println("Chuẩn bị gửi email check-in đến: " + customerEmail);
        
        final String fromEmail = "justaclonecc@gmail.com"; 
        final String password = "zkmg qcqk vvup kyad"; 
        
        Properties props = new Properties();
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587"); 
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        
        Authenticator auth = new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(fromEmail, password);
            }
        };
        Session mailSession = Session.getInstance(props, auth);
        
        try {
            MimeMessage msg = new MimeMessage(mailSession);
            msg.setFrom(new InternetAddress(fromEmail));
            msg.addRecipient(Message.RecipientType.TO, new InternetAddress(customerEmail));
            
            msg.setSubject("Xác nhận lấy vé thành công! Mã vé: " + booking.getBookingCode(), "UTF-8");
            
            // locale cho dep
            Locale localeVN = new Locale("vi", "VN");
            DateTimeFormatter screeningFormatter = DateTimeFormatter.ofPattern("EEEE, dd/MM/yyyy - HH:mm", localeVN);
            DateTimeFormatter checkInFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss", localeVN);

            String movieTitle = booking.getMovieTitle();
            String screeningTime = booking.getScreeningTime().format(screeningFormatter);
            String cinemaName = booking.getCinemaName();
            String roomName = booking.getRoomName();
            String seats = String.join(", ", booking.getSeatLabels());
            double finalAmount = booking.getFinalAmount();
            String checkedInAt = checkInTime.format(checkInFormatter);

            String emailBody = "Chào " + booking.getCustomerName() + ",\n\n"
                    + "Bạn đã lấy vé thành công. Chúng tôi xin được gửi lịch sử tới bên bạn.\n\n"
                    + "--------------------------------------------------\n"
                    + "THÔNG TIN VÉ (Mã: " + booking.getBookingCode() + ")\n"
                    + "--------------------------------------------------\n\n"
                    + "Phim: " + movieTitle + "\n"
                    + "Rạp: " + cinemaName + "\n"
                    + "Phòng: " + roomName + "\n"
                    + "Suất chiếu: " + screeningTime + "\n"
                    + "Ghế: " + seats + "\n\n"
                    + "Thời gian lấy vé (Check-in): " + checkedInAt + "\n" // <-- THÔNG TIN MỚI
                    + "Tổng Thanh Toán: " + String.format("%,.0f VNĐ", finalAmount) + "\n\n"
                    + "--------------------------------------------------\n\n"
                    + "Chúc bạn có một buổi xem phim vui vẻ!\n\n" // 
                    + "Trân trọng,\n"
                    + "Đội ngũ Cinema";
            
            msg.setText(emailBody, "UTF-8");

            //Gửi mail
            Transport.send(msg);
            System.out.println("✓ Email Check-in đã gửi thành công!");
            return true;
            
        } catch (Exception e) { 
            e.printStackTrace();
            return false;
        }
    }
}
