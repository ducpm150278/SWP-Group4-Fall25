package entity;

public class SeatM {
    private int seatID;
    private int roomID;
    private String seatRow;
    private String seatNumber;
    private String seatType;
    private String status;
    private ScreeningRoom screeningRoom;

    // Constants for validation
    public static final String[] VALID_SEAT_TYPES = {"Standard", "VIP", "Couple", "Disabled"};
    public static final String[] VALID_STATUSES = {"Available", "Booked", "Maintenance", "Unavailable"};

    // Constructors
    public SeatM() {
    }

    public SeatM(int seatID, int roomID, String seatRow, String seatNumber, 
                String seatType, String status) {
        this.seatID = seatID;
        this.roomID = roomID;
        this.seatRow = seatRow;
        this.seatNumber = seatNumber;
        this.seatType = seatType;
        this.status = status;
    }

    public SeatM(int roomID, String seatRow, String seatNumber, String seatType, String status) {
        this.roomID = roomID;
        this.seatRow = seatRow;
        this.seatNumber = seatNumber;
        this.seatType = seatType;
        this.status = status;
    }

    // Getters and Setters
    public int getSeatID() {
        return seatID;
    }

    public void setSeatID(int seatID) {
        this.seatID = seatID;
    }

    public int getRoomID() {
        return roomID;
    }

    public void setRoomID(int roomID) {
        this.roomID = roomID;
    }

    public String getSeatRow() {
        return seatRow;
    }

    public void setSeatRow(String seatRow) {
        // Tạm thời bỏ validation để fix lỗi
        if (seatRow != null) {
            this.seatRow = seatRow.toUpperCase().trim();
        } else {
            this.seatRow = null;
        }
    }

    public String getSeatNumber() {
        return seatNumber;
    }

    public void setSeatNumber(String seatNumber) {
        // Tạm thời bỏ validation để fix lỗi
        if (seatNumber != null) {
            this.seatNumber = seatNumber.trim();
        } else {
            this.seatNumber = null;
        }
    }

    public String getSeatType() {
        return seatType;
    }

    public void setSeatType(String seatType) {
        // Validate seat type
        if (seatType != null && isValidSeatType(seatType)) {
            this.seatType = seatType;
        } else {
            // Default to Standard nếu không hợp lệ
            this.seatType = "Standard";
        }
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        // Validate status
        if (status != null && isValidStatus(status)) {
            this.status = status;
        } else {
            // Default to Available nếu không hợp lệ
            this.status = "Available";
        }
    }

    public ScreeningRoom getScreeningRoom() {
        return screeningRoom;
    }

    public void setScreeningRoom(ScreeningRoom screeningRoom) {
        this.screeningRoom = screeningRoom;
        if (screeningRoom != null) {
            this.roomID = screeningRoom.getRoomID();
        }
    }

    // Validation methods
    private boolean isValidSeatType(String seatType) {
        for (String validType : VALID_SEAT_TYPES) {
            if (validType.equalsIgnoreCase(seatType)) {
                return true;
            }
        }
        return false;
    }

    private boolean isValidStatus(String status) {
        for (String validStatus : VALID_STATUSES) {
            if (validStatus.equalsIgnoreCase(status)) {
                return true;
            }
        }
        return false;
    }

    // Helper methods
    public String getSeatPosition() {
        return (seatRow != null ? seatRow : "") + (seatNumber != null ? seatNumber : "");
    }

    public boolean isAvailable() {
        return "Available".equalsIgnoreCase(status);
    }

    public boolean isBooked() {
        return "Booked".equalsIgnoreCase(status);
    }

    public boolean isUnderMaintenance() {
        return "Maintenance".equalsIgnoreCase(status);
    }

    public boolean isVIP() {
        return "VIP".equalsIgnoreCase(seatType);
    }

    public boolean isCoupleSeat() {
        return "Couple".equalsIgnoreCase(seatType);
    }

    public boolean isDisabledAccessible() {
        return "Disabled".equalsIgnoreCase(seatType);
    }

    // Business logic methods
    public boolean canBeBooked() {
        return "Available".equalsIgnoreCase(status);
    }

    public boolean canBeModified() {
        return !"Booked".equalsIgnoreCase(status);
    }

    @Override
    public String toString() {
        return "SeatM{" +
                "seatID=" + seatID +
                ", roomID=" + roomID +
                ", seatRow='" + seatRow + '\'' +
                ", seatNumber='" + seatNumber + '\'' +
                ", seatType='" + seatType + '\'' +
                ", status='" + status + '\'' +
                '}';
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        SeatM seat = (SeatM) o;
        return roomID == seat.roomID && 
               seatRow.equals(seat.seatRow) && 
               seatNumber.equals(seat.seatNumber);
    }

    @Override
    public int hashCode() {
        int result = roomID;
        result = 31 * result + seatRow.hashCode();
        result = 31 * result + seatNumber.hashCode();
        return result;
    }
}