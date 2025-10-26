package utils;

import dal.SeatDAO;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

/**
 * Background task to clean up expired seat reservations
 * Runs every 2 minutes
 */
@WebListener
public class ReservationCleanupTask implements ServletContextListener {
    
    private ScheduledExecutorService scheduler;
    private SeatDAO seatDAO;
    
    @Override
    public void contextInitialized(ServletContextEvent sce) {
        System.out.println("Starting Reservation Cleanup Task...");
        
        seatDAO = new SeatDAO();
        scheduler = Executors.newSingleThreadScheduledExecutor();
        
        // Schedule cleanup task to run every 2 minutes
        scheduler.scheduleAtFixedRate(
            this::cleanupExpiredReservations,
            0,  // Initial delay
            2,  // Period
            TimeUnit.MINUTES
        );
        
        System.out.println("Reservation Cleanup Task started successfully");
    }
    
    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        System.out.println("Stopping Reservation Cleanup Task...");
        
        if (scheduler != null && !scheduler.isShutdown()) {
            scheduler.shutdown();
            try {
                if (!scheduler.awaitTermination(10, TimeUnit.SECONDS)) {
                    scheduler.shutdownNow();
                }
            } catch (InterruptedException e) {
                scheduler.shutdownNow();
                Thread.currentThread().interrupt();
            }
        }
        
        System.out.println("Reservation Cleanup Task stopped");
    }
    
    /**
     * Clean up expired seat reservations
     */
    private void cleanupExpiredReservations() {
        try {
            int releasedCount = seatDAO.releaseExpiredReservations();
            if (releasedCount > 0) {
                System.out.println("Released " + releasedCount + " expired seat reservations");
            }
        } catch (Exception e) {
            System.err.println("Error cleaning up expired reservations: " + e.getMessage());
            e.printStackTrace();
        }
    }
}

