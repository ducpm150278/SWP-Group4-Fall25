package entity;

public class TopItemDTO {
    private String name; 
    private int ticketCount;
    private double totalRevenue;
    
    public TopItemDTO(String name, int ticketCount, double totalRevenue) {
        this.name = name;
        this.ticketCount = ticketCount;
        this.totalRevenue = totalRevenue;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getTicketCount() {
        return ticketCount;
    }

    public void setTicketCount(int ticketCount) {
        this.ticketCount = ticketCount;
    }

    public double getTotalRevenue() {
        return totalRevenue;
    }

    public void setTotalRevenue(double totalRevenue) {
        this.totalRevenue = totalRevenue;
    }


}