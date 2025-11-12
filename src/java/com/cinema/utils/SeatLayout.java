package com.cinema.utils;


import com.cinema.entity.SeatM;
import java.util.ArrayList;
import java.util.List;

public class SeatLayout {

    private List<SeatM> generatedSeats;

    public SeatLayout() {
        this.generatedSeats = new ArrayList<>();
    }

    public List<SeatM> generateSeats(int roomID, String roomType) {
        List<SeatM> seats = new ArrayList<>();

        System.out.println("=== GENERATING SEATS FOR ROOM " + roomID + " TYPE: " + roomType + " ===");

        if (roomType == null) {
            roomType = "Standard";
        }

        switch (roomType.toUpperCase()) {
            case "STANDARD":
                seats = generateStandardLayout(roomID);
                break;
            case "IMAX":
                seats = generateIMAXLayout(roomID);
                break;
            case "VIP":
                seats = generateVIPLayout(roomID);
                break;
            case "3D":
                seats = generate3DLayout(roomID);
                break;
            default:
                seats = generateStandardLayout(roomID);
                break;
        }

        this.generatedSeats = seats;
        System.out.println("Total seats generated: " + seats.size());
        return seats;
    }

    // STANDARD: 5 rows x 8 seats - all Standard
    private List<SeatM> generateStandardLayout(int roomID) {
        List<SeatM> seats = new ArrayList<>();
        int rowCount = 5;
        int seatsPerRow = 8;

        System.out.println("Generating STANDARD layout: " + rowCount + " rows x " + seatsPerRow + " seats");

        for (int row = 0; row < rowCount; row++) {
            String seatRow = toRowString(row);
            for (int seatNum = 1; seatNum <= seatsPerRow; seatNum++) {
                SeatM seat = createSeat(roomID, seatRow, seatNum, "Standard", "Available");
                seats.add(seat);
            }
        }
        return seats;
    }

    // IMAX: 
    // - 2 rows x 8 seats Standard
    // - 2 rows x 8 seats VIP  
    // - 2 rows x 4 seats Couple
    // - 1 row x 6 seats Standard
    private List<SeatM> generateIMAXLayout(int roomID) {
        List<SeatM> seats = new ArrayList<>();
        
        System.out.println("Generating IMAX layout");

        // Row A-B: 2 rows x 8 seats Standard
        for (int row = 0; row < 2; row++) {
            String seatRow = toRowString(row);
            for (int seatNum = 1; seatNum <= 8; seatNum++) {
                SeatM seat = createSeat(roomID, seatRow, seatNum, "Standard", "Available");
                seats.add(seat);
            }
        }

        // Row C-D: 2 rows x 8 seats VIP
        for (int row = 2; row < 4; row++) {
            String seatRow = toRowString(row);
            for (int seatNum = 1; seatNum <= 8; seatNum++) {
                SeatM seat = createSeat(roomID, seatRow, seatNum, "VIP", "Available");
                seats.add(seat);
            }
        }

        // Row E-F: 2 rows x 4 seats Couple (centered)
        for (int row = 4; row < 6; row++) {
            String seatRow = toRowString(row);
            // Center the 4 couple seats (positions 3-6 in an 8-seat row)
            for (int i = 1; i <= 4; i++) {
                int seatNum = i + 2; // Positions 3,4,5,6
                SeatM seat = createSeat(roomID, seatRow, seatNum, "Couple", "Available");
                seats.add(seat);
            }
        }

        // Row G: 1 row x 6 seats Standard (centered)
        String lastRow = toRowString(6);
        for (int i = 1; i <= 6; i++) {
            int seatNum = i + 1; // Positions 2,3,4,5,6,7
            SeatM seat = createSeat(roomID, lastRow, seatNum, "Standard", "Available");
            seats.add(seat);
        }

        return seats;
    }

    // VIP: 4 rows x 5 seats - all VIP
    private List<SeatM> generateVIPLayout(int roomID) {
        List<SeatM> seats = new ArrayList<>();
        int rowCount = 4;
        int seatsPerRow = 5;

        System.out.println("Generating VIP layout: " + rowCount + " rows x " + seatsPerRow + " seats");

        for (int row = 0; row < rowCount; row++) {
            String seatRow = toRowString(row);
            for (int seatNum = 1; seatNum <= seatsPerRow; seatNum++) {
                SeatM seat = createSeat(roomID, seatRow, seatNum, "VIP", "Available");
                seats.add(seat);
            }
        }
        return seats;
    }

    // 3D:
    // - 3 rows x 6 seats Standard
    // - 1 row x 6 seats VIP
    // - 1 row x 3 seats Couple
    // - 1 row x 5 seats Standard
    private List<SeatM> generate3DLayout(int roomID) {
        List<SeatM> seats = new ArrayList<>();
        
        System.out.println("Generating 3D layout");

        // Row A-C: 3 rows x 6 seats Standard
        for (int row = 0; row < 3; row++) {
            String seatRow = toRowString(row);
            for (int seatNum = 1; seatNum <= 6; seatNum++) {
                SeatM seat = createSeat(roomID, seatRow, seatNum, "Standard", "Available");
                seats.add(seat);
            }
        }

        // Row D: 1 row x 6 seats VIP
        String vipRow = toRowString(3);
        for (int seatNum = 1; seatNum <= 6; seatNum++) {
            SeatM seat = createSeat(roomID, vipRow, seatNum, "VIP", "Available");
            seats.add(seat);
        }

        // Row E: 1 row x 3 seats Couple (centered)
        String coupleRow = toRowString(4);
        for (int i = 1; i <= 3; i++) {
            int seatNum = i + 2; // Positions 3,4,5
            SeatM seat = createSeat(roomID, coupleRow, seatNum, "Couple", "Available");
            seats.add(seat);
        }

        // Row F: 1 row x 5 seats Standard (centered)
        String lastRow = toRowString(5);
        for (int i = 1; i <= 5; i++) {
            int seatNum = i + 1; // Positions 2,3,4,5,6
            SeatM seat = createSeat(roomID, lastRow, seatNum, "Standard", "Available");
            seats.add(seat);
        }

        return seats;
    }

    // Helper method to create seat
    private SeatM createSeat(int roomID, String seatRow, int seatNumber, String seatType, String status) {
        SeatM seat = new SeatM();
        seat.setRoomID(roomID);
        seat.setSeatRow(seatRow);
        seat.setSeatNumber(String.valueOf(seatNumber));
        seat.setSeatType(seatType);
        seat.setStatus(status);
        
        System.out.println("Created seat: " + seatRow + seatNumber + " - " + seatType);
        return seat;
    }

    // Chuyển số row thành chữ cái (0->A, 1->B, ...)
    private String toRowString(int rowIndex) {
        if (rowIndex < 26) {
            return String.valueOf((char) ('A' + rowIndex));
        } else {
            int firstChar = rowIndex / 26 - 1;
            int secondChar = rowIndex % 26;
            return String.valueOf((char) ('A' + firstChar)) + (char) ('A' + secondChar);
        }
    }

    // Getters
    public List<SeatM> getGeneratedSeats() {
        return generatedSeats;
    }

    public int getTotalSeats() {
        return generatedSeats.size();
    }

    // Method để debug
    public void printLayout() {
        System.out.println("=== SEAT LAYOUT DEBUG ===");
        System.out.println("Total seats: " + getTotalSeats());
        
        for (SeatM seat : generatedSeats) {
            System.out.println(seat.getSeatRow() + seat.getSeatNumber() + 
                " - Type: " + seat.getSeatType() + 
                " - Status: " + seat.getStatus());
        }
        System.out.println("=== END DEBUG ===");
    }
}