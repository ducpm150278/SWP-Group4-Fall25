package dal;

import entity.SupportMessage;
import entity.SupportTicket;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class SupportDAO extends DBContext {

    public List<SupportTicket> getTicketsByUserId(int userId) {
        List<SupportTicket> tickets = new ArrayList<>();
        String sql = "SELECT * FROM SupportTickets WHERE UserID = ? ORDER BY LastActivityDate DESC";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                tickets.add(mapTicket(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return tickets;
    }

    public SupportTicket getTicketById(int ticketId, int userId) {
        String sql = "SELECT * FROM SupportTickets WHERE TicketID = ? AND UserID = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, ticketId);
            ps.setInt(2, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapTicket(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<SupportMessage> getMessagesByTicketId(int ticketId) {
        List<SupportMessage> messages = new ArrayList<>();
        String sql = "SELECT m.*, u.FullName, u.Role "
                   + "FROM SupportMessages m "
                   + "JOIN Users u ON m.SenderUserID = u.UserID "
                   + "WHERE m.TicketID = ? ORDER BY m.SentDate ASC";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, ticketId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                SupportMessage msg = new SupportMessage();
                msg.setMessageID(rs.getInt("MessageID"));
                msg.setTicketID(rs.getInt("TicketID"));
                msg.setSenderUserID(rs.getInt("SenderUserID"));
                msg.setMessageContent(rs.getString("MessageContent"));
                msg.setSentDate(rs.getTimestamp("SentDate").toLocalDateTime());
                msg.setSenderName(rs.getString("FullName"));
                msg.setSenderRole(rs.getString("Role"));
                messages.add(msg);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return messages;
    }

    public boolean createTicket(SupportTicket ticket, String firstMessageContent) {
        String sqlTicket = "INSERT INTO SupportTickets (UserID, Title, SupportType, Status, CreatedDate, LastActivityDate) "
                         + "VALUES (?, ?, ?, 'New', GETDATE(), GETDATE())";
        String sqlMessage = "INSERT INTO SupportMessages (TicketID, SenderUserID, MessageContent, SentDate) "
                          + "VALUES (?, ?, ?, GETDATE())";
        
        Connection conn = null;
        PreparedStatement psTicket = null;
        PreparedStatement psMessage = null;
        ResultSet generatedKeys = null;
        
        try {
            conn = getConnection();
            conn.setAutoCommit(false); 

            psTicket = conn.prepareStatement(sqlTicket, Statement.RETURN_GENERATED_KEYS);
            psTicket.setInt(1, ticket.getUserID());
            psTicket.setString(2, ticket.getTitle());
            psTicket.setString(3, ticket.getSupportType());
            psTicket.executeUpdate();

            generatedKeys = psTicket.getGeneratedKeys();
            if (generatedKeys.next()) {
                int ticketId = generatedKeys.getInt(1);

                psMessage = conn.prepareStatement(sqlMessage);
                psMessage.setInt(1, ticketId);
                psMessage.setInt(2, ticket.getUserID());
                psMessage.setString(3, firstMessageContent);
                psMessage.executeUpdate();
                
                conn.commit(); 
                return true;
            } else {
                conn.rollback();
                return false;
            }
        } catch (Exception e) {
            if (conn != null) try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            e.printStackTrace();
            return false;
        } finally {
            try { if (generatedKeys != null) generatedKeys.close(); } catch (SQLException e) {  }
            try { if (psMessage != null) psMessage.close(); } catch (SQLException e) {  }
            try { if (psTicket != null) psTicket.close(); } catch (SQLException e) {  }
            try { if (conn != null) conn.close(); } catch (SQLException e) {  }
        }
    }

    public boolean addMessageAndUpdateTicket(SupportMessage message, String newStatus) {
        String sqlMessage = "INSERT INTO SupportMessages (TicketID, SenderUserID, MessageContent, SentDate) "
                          + "VALUES (?, ?, ?, GETDATE())";
        
        String sqlUpdateTicket;
        
        boolean isStaff = "Staff".equals(message.getSenderRole()) || "Admin".equals(message.getSenderRole());

        if (isStaff) {
            sqlUpdateTicket = "UPDATE SupportTickets " +
                              "SET LastActivityDate = GETDATE(), Status = ?, StaffID = ? " +
                              "WHERE TicketID = ?";
        } else {
            sqlUpdateTicket = "UPDATE SupportTickets " +
                              "SET LastActivityDate = GETDATE(), Status = ? " +
                              "WHERE TicketID = ?";
        }
        
        Connection conn = null;
        PreparedStatement psMessage = null;
        PreparedStatement psUpdateTicket = null;

        try {
            conn = getConnection();
            conn.setAutoCommit(false); 

            psMessage = conn.prepareStatement(sqlMessage);
            psMessage.setInt(1, message.getTicketID());
            psMessage.setInt(2, message.getSenderUserID());
            psMessage.setString(3, message.getMessageContent());
            psMessage.executeUpdate();

            psUpdateTicket = conn.prepareStatement(sqlUpdateTicket);
            psUpdateTicket.setString(1, newStatus); 
            
            if (isStaff) {
                psUpdateTicket.setInt(2, message.getSenderUserID()); 
                psUpdateTicket.setInt(3, message.getTicketID());
            } else {
                psUpdateTicket.setInt(2, message.getTicketID());
            }
            psUpdateTicket.executeUpdate();

            conn.commit();
            return true;
            
        } catch (Exception e) {
            if (conn != null) try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            e.printStackTrace();
            System.err.println("Lỗi nghiêm trọng khi addMessageAndUpdateTicket: " + e.getMessage());
            return false;
        } finally {
            try { if (psMessage != null) psMessage.close(); } catch (SQLException e) {  }
            try { if (psUpdateTicket != null) psUpdateTicket.close(); } catch (SQLException e) { }
            try { if (conn != null) conn.close(); } catch (SQLException e) { }
        }
    }
    
    private SupportTicket mapTicket(ResultSet rs) throws SQLException {
        SupportTicket ticket = new SupportTicket();
        ticket.setTicketID(rs.getInt("TicketID"));
        ticket.setUserID(rs.getInt("UserID"));
        ticket.setStaffID(rs.getInt("StaffID")); 
        ticket.setTitle(rs.getString("Title"));
        ticket.setSupportType(rs.getString("SupportType"));
        ticket.setStatus(rs.getString("Status"));
        ticket.setCreatedDate(rs.getTimestamp("CreatedDate").toLocalDateTime());
        ticket.setLastActivityDate(rs.getTimestamp("LastActivityDate").toLocalDateTime());
        return ticket;
    }
    
public List<SupportTicket> getAllTicketsForStaff() {
        List<SupportTicket> tickets = new ArrayList<>();
        String sql = "SELECT t.*, u.FullName AS CustomerName " +
                     "FROM SupportTickets t " +
                     "JOIN Users u ON t.UserID = u.UserID " +
                     "ORDER BY " +
                     "  CASE " +
                     "    WHEN t.Status = 'New' THEN 1 " +
                     "    WHEN t.Status = 'In Progress' THEN 2 " + 
                     "    WHEN t.Status = 'Answered' THEN 3 " +   
                     "    ELSE 4 " + 
                     "  END, " +
                     "  t.LastActivityDate DESC"; 

        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                SupportTicket ticket = mapTicket(rs); 
                ticket.setCustomerName(rs.getString("CustomerName")); 
                tickets.add(ticket);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return tickets;
    }

    public SupportTicket getTicketById_Staff(int ticketId) {
        String sql = "SELECT t.*, u.FullName AS CustomerName " +
                     "FROM SupportTickets t " +
                     "JOIN Users u ON t.UserID = u.UserID " +
                     "WHERE t.TicketID = ?";
        try (PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setInt(1, ticketId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                SupportTicket ticket = mapTicket(rs);
                ticket.setCustomerName(rs.getString("CustomerName")); 
                return ticket;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}