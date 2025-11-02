package utils;

import entity.SeatM;
import java.util.ArrayList;
import java.util.List;

public class SeatLayout {
    private int totalRows;
    private int seatsPerRow;
    private List<SeatM> generatedSeats;
    
    // Các layout mẫu cho các loại phòng khác nhau
    public enum RoomLayoutTemplate {
        STANDARD(5, 10),    // 5 rows, 10 seats/row (giảm để test)
        IMAX(6, 12),        // 6 rows, 12 seats/row  
        VIP(4, 8),          // 4 rows, 8 seats/row
        COUPLE(4, 10);      // 4 rows, 10 seats/row (with couple seats)
        
        private final int rows;
        private final int seatsPerRow;
        
        RoomLayoutTemplate(int rows, int seatsPerRow) {
            this.rows = rows;
            this.seatsPerRow = seatsPerRow;
        }
        
        public int getRows() { return rows; }
        public int getSeatsPerRow() { return seatsPerRow; }
    }

    public SeatLayout() {
        this.generatedSeats = new ArrayList<>();
    }

    public SeatLayout(int totalRows, int seatsPerRow) {
        this.totalRows = totalRows;
        this.seatsPerRow = seatsPerRow;
        this.generatedSeats = new ArrayList<>();
    }

    // Getters and Setters
    public int getTotalRows() { return totalRows; }
    public void setTotalRows(int totalRows) { this.totalRows = totalRows; }
    
    public int getSeatsPerRow() { return seatsPerRow; }
    public void setSeatsPerRow(int seatsPerRow) { this.seatsPerRow = seatsPerRow; }
    
    public List<SeatM> getGeneratedSeats() { return generatedSeats; }
    public void setGeneratedSeats(List<SeatM> generatedSeats) { this.generatedSeats = generatedSeats; }

    // Main method: Tạo danh sách seats dựa trên layout
    public List<SeatM> generateSeats(int roomID, String roomType) {
        List<SeatM> seats = new ArrayList<>();
        
        // Lấy template dựa trên roomType
        RoomLayoutTemplate template = getTemplateForRoomType(roomType);
        this.totalRows = template.getRows();
        this.seatsPerRow = template.getSeatsPerRow();
        
        System.out.println("Generating seats for room " + roomID + ", type: " + roomType + 
                          ", layout: " + totalRows + "x" + seatsPerRow);
        
        for (int row = 0; row < totalRows; row++) {
            String seatRow = toRowString(row);
            
            for (int seatNum = 1; seatNum <= seatsPerRow; seatNum++) {
                String seatType = determineSeatType(roomType, row, seatNum);
                String status = "Available";
                
                SeatM seat = new SeatM();
                seat.setRoomID(roomID);
                seat.setSeatRow(seatRow);
                seat.setSeatNumber(String.valueOf(seatNum));
                seat.setSeatType(seatType);
                seat.setStatus(status);
                
                seats.add(seat);
                System.out.println("Created seat: " + seatRow + seatNum + " - " + seatType);
            }
        }
        
        this.generatedSeats = seats;
        System.out.println("Total seats generated: " + seats.size());
        return seats;
    }

    // Chuyển số row thành chữ cái (0->A, 1->B, ..., 26->AA, etc.)
    private String toRowString(int rowIndex) {
        if (rowIndex < 26) {
            return String.valueOf((char) ('A' + rowIndex));
        } else {
            int firstChar = rowIndex / 26 - 1;
            int secondChar = rowIndex % 26;
            return String.valueOf((char) ('A' + firstChar)) + 
                   (char) ('A' + secondChar);
        }
    }

    // Xác định loại ghế dựa trên vị trí
    private String determineSeatType(String roomType, int row, int seatNum) {
        if (roomType == null) roomType = "Standard";
        
        switch (roomType.toUpperCase()) {
            case "VIP":
                // Hàng đầu (0,1) là VIP
                if (row <= 1) return "VIP";
                // Ghế giữa các hàng là Standard
                return "Standard";
                
            case "3D":
                // Hàng cuối là Couple seats
                if (row == totalRows - 1) return "Couple";
                // 2 ghế đầu mỗi hàng cho disabled
                if (seatNum <= 2) return "Disabled";
                return "Standard";
                
            case "COUPLE":
                // Hàng cuối 2 là couple seats
                if (row >= totalRows - 2) return "Couple";
                return "Standard";
                
            default: // STANDARD
                // 2 ghế đầu mỗi hàng cho disabled
                if (seatNum <= 2) return "Disabled";
                return "Standard";
        }
    }

    // Lấy template dựa trên room type
    private RoomLayoutTemplate getTemplateForRoomType(String roomType) {
        if (roomType == null) return RoomLayoutTemplate.STANDARD;
        
        switch (roomType.toUpperCase()) {
            case "IMAX": return RoomLayoutTemplate.IMAX;
            case "VIP": return RoomLayoutTemplate.VIP;
            case "3D": return RoomLayoutTemplate.STANDARD;
            case "COUPLE": return RoomLayoutTemplate.COUPLE;
            default: return RoomLayoutTemplate.STANDARD;
        }
    }

    // Tính tổng số ghế
    public int getTotalSeats() {
        return totalRows * seatsPerRow;
    }

    // Tạo layout custom
    public List<SeatM> generateCustomSeats(int roomID, int rows, int seatsPerRow, String defaultSeatType) {
        this.totalRows = rows;
        this.seatsPerRow = seatsPerRow;
        
        List<SeatM> seats = new ArrayList<>();
        
        for (int row = 0; row < rows; row++) {
            String seatRow = toRowString(row);
            
            for (int seatNum = 1; seatNum <= seatsPerRow; seatNum++) {
                SeatM seat = new SeatM();
                seat.setRoomID(roomID);
                seat.setSeatRow(seatRow);
                seat.setSeatNumber(String.valueOf(seatNum));
                seat.setSeatType(defaultSeatType != null ? defaultSeatType : "Standard");
                seat.setStatus("Available");
                
                seats.add(seat);
            }
        }
        
        this.generatedSeats = seats;
        return seats;
    }

    // Method để visualize layout (cho console debugging)
    public void printLayout() {
        System.out.println("Seat Layout: " + totalRows + " rows x " + seatsPerRow + " seats");
        System.out.println("Total seats: " + getTotalSeats());
        
        for (SeatM seat : generatedSeats) {
            System.out.println(seat.getSeatPosition() + " - " + 
                             seat.getSeatType() + " - " + 
                             seat.getStatus());
        }
    }

    @Override
    public String toString() {
        return "SeatLayout{" +
                "totalRows=" + totalRows +
                ", seatsPerRow=" + seatsPerRow +
                ", totalSeats=" + getTotalSeats() +
                '}';
    }
}