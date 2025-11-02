package controller;

import dal.BookingDAO;
import dal.ComboDAO;
import dal.DiscountDAO;
import dal.FoodDAO;
import dal.SeatDAO;
import dal.TicketDAO;
import entity.Booking;
import entity.BookingSession;
import entity.Combo;
import entity.Food;
import entity.Ticket;
import utils.BookingSessionManager;
import utils.VNPayConfig;
import utils.VNPayUtils;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Servlet to handle VNPay payment callback
 */
@WebServlet(name = "VNPayCallbackServlet", urlPatterns = {"/vnpay-callback"})
public class VNPayCallbackServlet extends HttpServlet {
    
    private TicketDAO ticketDAO;
    private DiscountDAO discountDAO;
    private SeatDAO seatDAO;
    private BookingDAO bookingDAO;
    private FoodDAO foodDAO;
    private ComboDAO comboDAO;
    
    @Override
    public void init() throws ServletException {
        ticketDAO = new TicketDAO();
        discountDAO = new DiscountDAO();
        seatDAO = new SeatDAO();
        bookingDAO = new BookingDAO();
        foodDAO = new FoodDAO();
        comboDAO = new ComboDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        System.out.println("=== VNPay Callback Received ===");
        
        HttpSession session = request.getSession();
        System.out.println("Callback Session ID: " + session.getId());
        
        BookingSession bookingSession = BookingSessionManager.getBookingSession(session);
        System.out.println("BookingSession retrieved: " + (bookingSession != null ? "YES" : "NULL"));
        
        // Get VNPay response parameters
        Map<String, String> vnpParams = new HashMap<>();
        request.getParameterMap().forEach((key, values) -> {
            if (values.length > 0) {
                vnpParams.put(key, values[0]);
                System.out.println(key + " = " + values[0]);
            }
        });
        
        // Get secure hash
        String vnpSecureHash = request.getParameter("vnp_SecureHash");
        String responseCode = request.getParameter("vnp_ResponseCode");
        String transactionNo = request.getParameter("vnp_TransactionNo");
        String orderID = request.getParameter("vnp_TxnRef");
        String amount = request.getParameter("vnp_Amount");
        String bankCode = request.getParameter("vnp_BankCode");
        String payDate = request.getParameter("vnp_PayDate");
        
        System.out.println("=== VNPay Response Details ===");
        System.out.println("Response Code: " + responseCode);
        System.out.println("Transaction No: " + (transactionNo != null ? transactionNo : "NULL - VNPay didn't provide"));
        System.out.println("Order ID: " + orderID);
        System.out.println("Amount: " + amount);
        System.out.println("Bank Code: " + bankCode);
        System.out.println("Pay Date: " + payDate);
        System.out.println("============================");
        
        // Check if booking session exists
        if (bookingSession == null) {
            System.out.println("ERROR: BookingSession is null!");
            request.setAttribute("error", "Phiên đặt vé đã hết hạn. Vui lòng đặt vé lại.");
            request.getRequestDispatcher("/booking/payment-failed.jsp").forward(request, response);
            return;
        }
        
        // DEBUG: Check food/combo data in session
        System.out.println("=== FOOD DATA IN CALLBACK SESSION ===");
        System.out.println("Selected Combos: " + bookingSession.getSelectedCombos());
        System.out.println("Selected Combos Size: " + (bookingSession.getSelectedCombos() != null ? bookingSession.getSelectedCombos().size() : "NULL"));
        System.out.println("Selected Foods: " + bookingSession.getSelectedFoods());
        System.out.println("Selected Foods Size: " + (bookingSession.getSelectedFoods() != null ? bookingSession.getSelectedFoods().size() : "NULL"));
        System.out.println("Food Subtotal: " + bookingSession.getFoodSubtotal());
        System.out.println("====================================");
        
        // Validate signature
        Map<String, String> paramsForValidation = new HashMap<>(vnpParams);
        boolean signatureValid = VNPayUtils.validateSignature(paramsForValidation, vnpSecureHash);
        System.out.println("Signature Valid: " + signatureValid);
        
        if (!signatureValid) {
            System.out.println("ERROR: Invalid signature!");
            request.setAttribute("error", "Chữ ký không hợp lệ!");
            request.setAttribute("message", "Giao dịch có thể bị giả mạo. Vui lòng liên hệ bộ phận hỗ trợ.");
            request.getRequestDispatcher("/booking/payment-failed.jsp").forward(request, response);
            return;
        }
        
        // Check response code
        if (!VNPayConfig.RESPONSE_CODE_SUCCESS.equals(responseCode)) {
            // Payment failed
            String errorMessage = VNPayUtils.getResponseMessage(responseCode);
            System.out.println("ERROR: Payment failed with code: " + responseCode);
            
            request.setAttribute("error", errorMessage);
            request.setAttribute("responseCode", responseCode);
            request.getRequestDispatcher("/booking/payment-failed.jsp").forward(request, response);
            return;
        }
        
        System.out.println("Payment successful, processing booking...");
        
        // Payment successful - process booking
        try {
            boolean bookingSuccess = processBooking(session, bookingSession, orderID, transactionNo);
            
            if (bookingSuccess) {
                System.out.println("SUCCESS: Booking processed successfully!");
                
                // Store success info for display BEFORE clearing session
                request.setAttribute("orderID", orderID);
                request.setAttribute("transactionNo", transactionNo);
                request.setAttribute("amount", Long.parseLong(amount) / 100); // Convert back from VNPay format
                request.setAttribute("bookingSession", bookingSession);
                
                // Clear booking session
                BookingSessionManager.clearBookingSession(session);
                
                request.getRequestDispatcher("/booking/payment-success.jsp").forward(request, response);
            } else {
                System.out.println("ERROR: processBooking returned false!");
                request.setAttribute("error", "Không thể hoàn tất đặt vé. Vui lòng liên hệ bộ phận hỗ trợ.");
                request.getRequestDispatcher("/booking/payment-failed.jsp").forward(request, response);
            }
            
        } catch (Exception e) {
            System.out.println("EXCEPTION in booking process: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra khi xử lý đặt vé: " + e.getMessage());
            request.getRequestDispatcher("/booking/payment-failed.jsp").forward(request, response);
        }
    }
    
    /**
     * Process booking after successful VNPay payment
     * Creates booking record, tickets, food items, and finalizes the transaction
     */
    private boolean processBooking(HttpSession session, BookingSession bookingSession, 
                                   String orderID, String transactionNo) {
        
        System.out.println("\n╔═══════════════════════════════════════════════════════════╗");
        System.out.println("║          PROCESSING BOOKING FOR ORDER: " + orderID + "          ║");
        System.out.println("╚═══════════════════════════════════════════════════════════╝");
        
        // Get user from session
        Integer userID = (Integer) session.getAttribute("userId");
        if (userID == null) {
            System.err.println("✗ ERROR: UserID is null in session!");
            return false;
        }
        System.out.println("✓ User ID: " + userID);
        
        try {
            LocalDateTime bookingTime = LocalDateTime.now();
            
            // Step 1: Create main Booking record
            System.out.println("\n=== Step 1: Creating Booking Record ===");
            String bookingCode = bookingDAO.generateBookingCode();
            double totalAmount = bookingSession.getTotalAmount();
            double discountAmount = bookingSession.getDiscountAmount();
            double finalAmount = totalAmount - discountAmount;
            
            System.out.println("Booking Code: " + bookingCode);
            System.out.println("Total Amount: " + String.format("%,.0f VND", totalAmount));
            System.out.println("Discount: " + String.format("%,.0f VND", discountAmount));
            System.out.println("Final Amount: " + String.format("%,.0f VND", finalAmount));
            
            Booking booking = new Booking(
                bookingCode,
                userID,
                bookingSession.getScreeningID(),
                totalAmount,
                discountAmount,
                finalAmount,
                "VNPay"
            );
            booking.setBookingDate(bookingTime);
            booking.setPaymentDate(bookingTime);
            booking.setPaymentStatus("Completed");
            booking.setStatus("Confirmed");
            
            // Set TransactionID - use VNPay's transaction number if available, otherwise use orderID
            String finalTransactionID;
            if (transactionNo != null && !transactionNo.trim().isEmpty() && !"0".equals(transactionNo)) {
                finalTransactionID = transactionNo;
                System.out.println("Transaction ID: " + transactionNo + " (from VNPay)");
            } else {
                // Fallback for sandbox/test mode where VNPay doesn't provide transaction number
                finalTransactionID = "VNPAY_" + orderID;
                System.out.println("Transaction ID: " + finalTransactionID + " (generated - VNPay sandbox mode)");
            }
            booking.setTransactionID(finalTransactionID);
            
            String notes = "VNPay Order: " + orderID;
            if (transactionNo != null && !transactionNo.trim().isEmpty()) {
                notes += " | VNPay Txn: " + transactionNo;
            }
            booking.setNotes(notes);
            
            int bookingID = bookingDAO.createBooking(booking);
            
            if (bookingID <= 0) {
                System.err.println("✗ ERROR: Failed to create booking in database!");
                return false;
            }
            
            System.out.println("✓ Booking record created successfully (ID: " + bookingID + ")");
            
            // Step 2: Create tickets for selected seats
            System.out.println("\n=== Step 2: Creating Tickets ===");
            int seatCount = bookingSession.getSelectedSeatIDs().size();
            System.out.println("Number of seats: " + seatCount);
            System.out.println("Base ticket price: " + String.format("%,.0f VND", bookingSession.getTicketPrice()));
            System.out.println("Ticket subtotal: " + String.format("%,.0f VND", bookingSession.getTicketSubtotal()));
            
            List<Ticket> tickets = new ArrayList<>();
            for (Integer seatID : bookingSession.getSelectedSeatIDs()) {
                Ticket ticket = new Ticket(
                    bookingSession.getScreeningID(),
                    userID,
                    seatID,
                    bookingSession.getTicketPrice()
                );
                ticket.setBookingTime(bookingTime);
                tickets.add(ticket);
            }
            
            // Insert tickets into database
            List<Integer> ticketIDs = ticketDAO.createTickets(tickets, bookingID);
            
            if (ticketIDs.isEmpty()) {
                System.err.println("✗ ERROR: Failed to create tickets in database!");
                return false;
            }
            
            System.out.println("✓ Created " + ticketIDs.size() + " ticket(s) successfully");
            
            // Step 3: Save food and combo items (optional - skip if customer didn't select any)
            System.out.println("\n=== Step 3: Saving Food & Combo Items ===");
            int comboSelections = (bookingSession.getSelectedCombos() != null ? bookingSession.getSelectedCombos().size() : 0);
            int foodSelections = (bookingSession.getSelectedFoods() != null ? bookingSession.getSelectedFoods().size() : 0);
            
            System.out.println("Combos selected: " + comboSelections);
            System.out.println("Foods selected: " + foodSelections);
            System.out.println("Food subtotal: " + String.format("%,.0f VND", bookingSession.getFoodSubtotal()));
            
            if (comboSelections == 0 && foodSelections == 0) {
                System.out.println("- No food/combo items selected, skipping this step");
            }
            
            // Save combo items
            if (bookingSession.getSelectedCombos() != null && !bookingSession.getSelectedCombos().isEmpty()) {
                System.out.println("\nProcessing " + bookingSession.getSelectedCombos().size() + " combo item(s):");
                java.util.Map<Integer, Double> comboPrices = new java.util.HashMap<>();
                
                for (Integer comboID : bookingSession.getSelectedCombos().keySet()) {
                    int quantity = bookingSession.getSelectedCombos().get(comboID);
                    Combo combo = comboDAO.getComboById(comboID);
                    if (combo != null) {
                        double price = combo.getDiscountPrice() != null ? 
                                      combo.getDiscountPrice().doubleValue() : 
                                      combo.getTotalPrice().doubleValue();
                        comboPrices.put(comboID, price);
                        System.out.println("  • " + combo.getComboName() + " x" + quantity + " @ " + String.format("%,.0f VND", price));
                    } else {
                        System.err.println("  ✗ ERROR: Combo ID " + comboID + " not found in database!");
                    }
                }
                
                int comboCount = bookingDAO.addBookingComboItems(bookingID, 
                                                                 bookingSession.getSelectedCombos(), 
                                                                 comboPrices);
                System.out.println("✓ Saved " + comboCount + " combo item(s) to database");
            }
            
            // Save food items
            if (bookingSession.getSelectedFoods() != null && !bookingSession.getSelectedFoods().isEmpty()) {
                System.out.println("\nProcessing " + bookingSession.getSelectedFoods().size() + " food item(s):");
                java.util.Map<Integer, Double> foodPrices = new java.util.HashMap<>();
                
                for (Integer foodID : bookingSession.getSelectedFoods().keySet()) {
                    int quantity = bookingSession.getSelectedFoods().get(foodID);
                    Food food = foodDAO.getFoodById(foodID);
                    if (food != null) {
                        foodPrices.put(foodID, food.getPrice().doubleValue());
                        System.out.println("  • " + food.getFoodName() + " x" + quantity + " @ " + String.format("%,.0f VND", food.getPrice()));
                    } else {
                        System.err.println("  ✗ ERROR: Food ID " + foodID + " not found in database!");
                    }
                }
                
                int foodCount = bookingDAO.addBookingFoodItems(bookingID, 
                                                               bookingSession.getSelectedFoods(), 
                                                               foodPrices);
                System.out.println("✓ Saved " + foodCount + " food item(s) to database");
            }
            
            // Step 4: Finalize booking
            System.out.println("\n=== Step 4: Finalizing Booking ===");
            
            // Update discount usage if discount was applied
            if (bookingSession.getDiscountID() != null) {
                discountDAO.updateDiscountUsage(bookingSession.getDiscountID());
                System.out.println("✓ Updated discount usage count (ID: " + bookingSession.getDiscountID() + ")");
            } else {
                System.out.println("- No discount code applied");
            }
            
            // Release temporary seat reservations (seats are now permanently booked via tickets)
            seatDAO.releaseReservationsBySession(bookingSession.getReservationSessionID());
            System.out.println("✓ Released temporary seat reservations");
            
            // Note: AvailableSeats is now calculated dynamically via view vw_CurrentScreenings
            // No need to manually update it
            
            System.out.println("\n╔═══════════════════════════════════════════════════════════╗");
            System.out.println("║            ✓ BOOKING COMPLETED SUCCESSFULLY!              ║");
            System.out.println("║       Booking ID: " + String.format("%-40s", bookingID) + "║");
            System.out.println("║       Booking Code: " + String.format("%-38s", bookingCode) + "║");
            System.out.println("╚═══════════════════════════════════════════════════════════╝\n");
            return true;
            
        } catch (Exception e) {
            System.err.println("\n╔═══════════════════════════════════════════════════════════╗");
            System.err.println("║              ✗ BOOKING PROCESS FAILED!                    ║");
            System.err.println("╚═══════════════════════════════════════════════════════════╝");
            System.err.println("Exception Type: " + e.getClass().getName());
            System.err.println("Error Message: " + e.getMessage());
            System.err.println("Stack Trace:");
            e.printStackTrace();
            return false;
        }
    }
}

