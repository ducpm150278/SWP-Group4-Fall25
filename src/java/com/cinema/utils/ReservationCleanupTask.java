package com.cinema.utils;


import com.cinema.dal.SeatDAO;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

/**
 * Task chạy nền để dọn dẹp các reservation ghế đã hết hạn
 * 
 * Vấn đề giải quyết:
 * - Khi người dùng chọn ghế, ghế được đặt trước (reserved) trong một khoảng thời gian
 * - Nếu người dùng không thanh toán trong thời gian quy định, ghế cần được giải phóng
 * - Task này tự động chạy mỗi 2 phút để giải phóng các ghế đã hết hạn
 * 
 * Lifecycle:
 * - contextInitialized: Khởi tạo scheduler và bắt đầu task
 * - contextDestroyed: Dừng scheduler khi ứng dụng shutdown
 * 
 * Lưu ý: Task chạy trong background thread riêng, không ảnh hưởng đến request handling
 */
@WebListener
public class ReservationCleanupTask implements ServletContextListener {
    
    private ScheduledExecutorService scheduler;  // Scheduler để chạy task định kỳ
    private SeatDAO seatDAO;                    // DAO để truy cập database
    
    /**
     * Khởi tạo khi ứng dụng bắt đầu
     * Tạo scheduler và lên lịch chạy cleanup task mỗi 2 phút
     * 
     * @param sce ServletContextEvent chứa thông tin context
     */
    @Override
    public void contextInitialized(ServletContextEvent sce) {
        // Khởi tạo SeatDAO để truy cập database
        seatDAO = new SeatDAO();
        
        // Tạo single-thread scheduler (chỉ 1 thread chạy task)
        scheduler = Executors.newSingleThreadScheduledExecutor();
        
        // Lên lịch chạy cleanup task:
        // - Initial delay: 0 (chạy ngay lập tức)
        // - Period: 2 phút (chạy lại mỗi 2 phút)
        scheduler.scheduleAtFixedRate(
            this::cleanupExpiredReservations,  // Method cần chạy
            0,                                 // Initial delay (0 = chạy ngay)
            2,                                 // Period (2 phút)
            TimeUnit.MINUTES                   // Đơn vị thời gian
        );
    }
    
    /**
     * Dọn dẹp khi ứng dụng shutdown
     * Dừng scheduler một cách graceful để tránh mất dữ liệu
     * 
     * @param sce ServletContextEvent chứa thông tin context
     */
    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (scheduler != null && !scheduler.isShutdown()) {
            // Bước 1: Yêu cầu shutdown (không nhận task mới)
            scheduler.shutdown();
            
            try {
                // Bước 2: Đợi các task đang chạy hoàn thành (tối đa 10 giây)
                if (!scheduler.awaitTermination(10, TimeUnit.SECONDS)) {
                    // Bước 3: Nếu quá 10 giây vẫn chưa xong, force shutdown
                    scheduler.shutdownNow();
                }
            } catch (InterruptedException e) {
                // Bước 4: Nếu thread bị interrupt, force shutdown ngay
                scheduler.shutdownNow();
                Thread.currentThread().interrupt();  // Restore interrupt status
            }
        }
    }
    
    /**
     * Dọn dẹp các reservation ghế đã hết hạn
     * Gọi SeatDAO để giải phóng các ghế đã quá thời gian reservation
     * 
     * Lưu ý: Method này được gọi tự động mỗi 2 phút bởi scheduler
     * Nếu có lỗi, sẽ bị bỏ qua để không làm gián đoạn ứng dụng
     */
    private void cleanupExpiredReservations() {
        try {
            // Gọi DAO để giải phóng các ghế đã hết hạn
            seatDAO.releaseExpiredReservations();
        } catch (Exception e) {
            // Bỏ qua lỗi - background task không nên làm gián đoạn ứng dụng
            // Trong production, có thể log lỗi vào file log
        }
    }
}

