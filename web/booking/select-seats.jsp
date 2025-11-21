<%-- File: select-seats.jsp Mô tả: Trang chọn ghế ngồi trong rạp chiếu phim Chức năng: - Hiển thị sơ đồ ghế của phòng
    chiếu - Cho phép người dùng chọn từ 1-8 ghế - Hiển thị các trạng thái ghế: trống, đã đặt, đang giữ, bảo trì - Phân
    biệt các loại ghế: thường, VIP, đôi - Tính toán tổng tiền dựa trên loại ghế - Auto-refresh để cập nhật trạng thái
    ghế real-time - Giữ chỗ tạm thời (5 phút) khi chọn ghế --%>
    <%@page contentType="text/html" pageEncoding="UTF-8" %>
        <%@page import="java.util.List" %>
            <%@page import="java.util.Map" %>
                <%@page import="java.util.HashMap" %>
                    <%@page import="entity.Seat" %>
                        <%@page import="entity.Screening" %>
                            <%@page import="entity.BookingSession" %>
                                <!DOCTYPE html>
                                <html lang="vi">

                                <head>
                                    <%-- Thiết lập encoding và responsive --%>
                                        <meta charset="UTF-8">
                                        <meta name="viewport" content="width=device-width, initial-scale=1.0">
                                        <title>Chọn Ghế - Cinema Booking</title>

                                        <%-- Import CSS frameworks và custom styles --%>
                                            <link
                                                href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
                                                rel="stylesheet">
                                            <link
                                                href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css"
                                                rel="stylesheet">
                                            <link rel="stylesheet"
                                                href="${pageContext.request.contextPath}/css/select-seats.css">
                                </head>

                                <body>
                                    <%-- Lấy dữ liệu từ request attributes: - screening: Thông tin suất chiếu được chọn
                                        - bookingSession: Phiên đặt vé hiện tại - allSeats: Danh sách tất cả ghế trong
                                        phòng chiếu - bookedSeatIDs: Danh sách ID ghế đã được đặt (confirmed) -
                                        reservedSeatIDs: Danh sách ID ghế đang được giữ tạm (reserved) --%>
                                        <% Screening screening=(Screening) request.getAttribute("screening");
                                            BookingSession bookingSession=(BookingSession)
                                            request.getAttribute("bookingSession"); List<Seat> allSeats = (List<Seat>)
                                                request.getAttribute("allSeats");
                                                List<Integer> bookedSeatIDs = (List<Integer>)
                                                        request.getAttribute("bookedSeatIDs");
                                                        List<Integer> reservedSeatIDs = (List<Integer>)
                                                                request.getAttribute("reservedSeatIDs");
                                                                %>

                                                                <%-- Loading Overlay - Hiển thị khi đang xử lý --%>
                                                                    <div class="loading-overlay" id="loadingOverlay">
                                                                        <div class="loading-spinner"></div>
                                                                    </div>

                                                                    <%-- Progress Steps - Thanh tiến trình đặt vé gồm 4
                                                                        bước --%>
                                                                        <div class="progress-container">
                                                                            <div class="progress-steps">
                                                                                <%-- Bước 1: Chọn suất chiếu (đã hoàn
                                                                                    thành) --%>
                                                                                    <div class="step completed"
                                                                                        onclick="window.location.href='${pageContext.request.contextPath}/booking/select-screening'"
                                                                                        title="Quay lại chọn suất chiếu">
                                                                                        <div class="step-circle"><i
                                                                                                class="fas fa-film"></i>
                                                                                        </div>
                                                                                        <span class="step-label">Chọn
                                                                                            Suất</span>
                                                                                    </div>

                                                                                    <%-- Bước 2: Chọn ghế (đang thực
                                                                                        hiện) --%>
                                                                                        <div class="step active">
                                                                                            <div class="step-circle"><i
                                                                                                    class="fas fa-couch"></i>
                                                                                            </div>
                                                                                            <span
                                                                                                class="step-label">Chọn
                                                                                                Ghế</span>
                                                                                        </div>

                                                                                        <%-- Bước 3: Chọn đồ ăn (chưa
                                                                                            thực hiện) --%>
                                                                                            <div class="step">
                                                                                                <div
                                                                                                    class="step-circle">
                                                                                                    <i
                                                                                                        class="fas fa-utensils"></i>
                                                                                                </div>
                                                                                                <span
                                                                                                    class="step-label">Đồ
                                                                                                    Ăn</span>
                                                                                            </div>

                                                                                            <%-- Bước 4: Thanh toán
                                                                                                (chưa thực hiện) --%>
                                                                                                <div class="step">
                                                                                                    <div
                                                                                                        class="step-circle">
                                                                                                        <i
                                                                                                            class="fas fa-credit-card"></i>
                                                                                                    </div>
                                                                                                    <span
                                                                                                        class="step-label">Thanh
                                                                                                        Toán</span>
                                                                                                </div>
                                                                            </div>
                                                                        </div>

                                                                        <%-- Main Content Container --%>
                                                                            <div class="main-container">
                                                                                <%-- Page Header --%>
                                                                                    <div class="page-header">
                                                                                        <h1><i class="fas fa-couch"></i>
                                                                                            Chọn Ghế Ngồi</h1>
                                                                                        <p>Chọn từ 1 đến 8 ghế để tiếp
                                                                                            tục đặt vé</p>
                                                                                    </div>

                                                                                    <%-- Booking Info Section - Hiển thị
                                                                                        thông tin suất chiếu đã chọn
                                                                                        --%>
                                                                                        <div class="info-section">
                                                                                            <div class="section-title">
                                                                                                <i
                                                                                                    class="fas fa-info-circle"></i>
                                                                                                <span>Thông Tin Suất
                                                                                                    Chiếu</span>
                                                                                            </div>
                                                                                            <div class="info-grid">
                                                                                                <div class="info-item">
                                                                                                    <div
                                                                                                        class="info-label">
                                                                                                        Phim</div>
                                                                                                    <div
                                                                                                        class="info-value">
                                                                                                        <%= bookingSession.getMovieTitle()
                                                                                                            %>
                                                                                                    </div>
                                                                                                </div>
                                                                                                <div class="info-item">
                                                                                                    <div
                                                                                                        class="info-label">
                                                                                                        Rạp</div>
                                                                                                    <div
                                                                                                        class="info-value">
                                                                                                        <%= bookingSession.getCinemaName()
                                                                                                            %>
                                                                                                    </div>
                                                                                                </div>
                                                                                                <div class="info-item">
                                                                                                    <div
                                                                                                        class="info-label">
                                                                                                        Phòng</div>
                                                                                                    <div
                                                                                                        class="info-value">
                                                                                                        <%= bookingSession.getRoomName()
                                                                                                            %>
                                                                                                    </div>
                                                                                                </div>
                                                                                                <%-- Hiển thị giờ chiếu
                                                                                                    (start time - end
                                                                                                    time) --%>
                                                                                                    <% if (screening
                                                                                                        !=null &&
                                                                                                        screening.getStartTime()
                                                                                                        !=null) {
                                                                                                        java.time.format.DateTimeFormatter
                                                                                                        timeFormatter=java.time.format.DateTimeFormatter.ofPattern("HH:mm");
                                                                                                        String
                                                                                                        startTime=screening.getStartTime().format(timeFormatter);
                                                                                                        String
                                                                                                        endTime=screening.getEndTime()
                                                                                                        !=null ?
                                                                                                        screening.getEndTime().format(timeFormatter)
                                                                                                        : "" ; String
                                                                                                        timeDisplay=endTime.isEmpty()
                                                                                                        ? startTime :
                                                                                                        startTime
                                                                                                        + " - " +
                                                                                                        endTime; %>
                                                                                                        <div
                                                                                                            class="info-item">
                                                                                                            <div
                                                                                                                class="info-label">
                                                                                                                Giờ
                                                                                                                chiếu
                                                                                                            </div>
                                                                                                            <div
                                                                                                                class="info-value">
                                                                                                                <%= timeDisplay
                                                                                                                    %>
                                                                                                            </div>
                                                                                                        </div>
                                                                                                        <% } %>
                                                                                                            <div
                                                                                                                class="info-item">
                                                                                                                <div
                                                                                                                    class="info-label">
                                                                                                                    Giá
                                                                                                                    vé
                                                                                                                </div>
                                                                                                                <div
                                                                                                                    class="info-value">
                                                                                                                    <%= String.format("%,.0f
                                                                                                                        VNĐ",
                                                                                                                        bookingSession.getTicketPrice())
                                                                                                                        %>
                                                                                                                </div>
                                                                                                            </div>
                                                                                            </div>
                                                                                        </div>

                                                                                        <%-- Error Message Display --%>
                                                                                            <% if
                                                                                                (request.getAttribute("error")
                                                                                                !=null) { %>
                                                                                                <div class="alert alert-danger"
                                                                                                    role="alert">
                                                                                                    <i
                                                                                                        class="fas fa-exclamation-circle"></i>
                                                                                                    <%= request.getAttribute("error")
                                                                                                        %>
                                                                                                </div>
                                                                                                <% } %>

                                                                                                    <%-- Screen Section
                                                                                                        - Thể hiện màn
                                                                                                        hình chiếu --%>
                                                                                                        <div
                                                                                                            class="screen-section">
                                                                                                            <div
                                                                                                                class="screen-label">
                                                                                                                MÀN HÌNH
                                                                                                            </div>
                                                                                                            <div
                                                                                                                class="screen">
                                                                                                            </div>
                                                                                                        </div>

                                                                                                        <%-- Seat Map
                                                                                                            Section - Sơ
                                                                                                            đồ ghế chính
                                                                                                            --%>
                                                                                                            <div
                                                                                                                class="seat-map-section">
                                                                                                                <form
                                                                                                                    method="post"
                                                                                                                    action="${pageContext.request.contextPath}/booking/select-seats"
                                                                                                                    id="seatForm">
                                                                                                                    <div class="seat-grid-container"
                                                                                                                        id="seatMap">
                                                                                                                        <%-- Render
                                                                                                                            sơ
                                                                                                                            đồ
                                                                                                                            ghế:
                                                                                                                            -
                                                                                                                            Group
                                                                                                                            ghế
                                                                                                                            theo
                                                                                                                            hàng
                                                                                                                            (A,
                                                                                                                            B,
                                                                                                                            C...)
                                                                                                                            -
                                                                                                                            Sort
                                                                                                                            ghế
                                                                                                                            theo
                                                                                                                            số
                                                                                                                            thứ
                                                                                                                            tự
                                                                                                                            trong
                                                                                                                            mỗi
                                                                                                                            hàng
                                                                                                                            -
                                                                                                                            Thêm
                                                                                                                            lối
                                                                                                                            đi
                                                                                                                            ở
                                                                                                                            giữa
                                                                                                                            nếu
                                                                                                                            hàng
                                                                                                                            có>
                                                                                                                            6
                                                                                                                            ghế
                                                                                                                            -
                                                                                                                            Hiển
                                                                                                                            thị
                                                                                                                            các
                                                                                                                            trạng
                                                                                                                            thái:
                                                                                                                            available,
                                                                                                                            booked,
                                                                                                                            reserved,
                                                                                                                            maintenance
                                                                                                                            -
                                                                                                                            Phân
                                                                                                                            biệt
                                                                                                                            loại
                                                                                                                            ghế:
                                                                                                                            Standard,
                                                                                                                            VIP,
                                                                                                                            Couple
                                                                                                                            --%>
                                                                                                                            <% if
                                                                                                                                (allSeats
                                                                                                                                !=null
                                                                                                                                &&
                                                                                                                                !allSeats.isEmpty())
                                                                                                                                {
                                                                                                                                //
                                                                                                                                Group
                                                                                                                                seats
                                                                                                                                by
                                                                                                                                row
                                                                                                                                -
                                                                                                                                normal
                                                                                                                                order
                                                                                                                                A->
                                                                                                                                Z
                                                                                                                                (front
                                                                                                                                to
                                                                                                                                back,
                                                                                                                                screen
                                                                                                                                is
                                                                                                                                above)
                                                                                                                                Map
                                                                                                                                <String,
                                                                                                                                    java.util.List<Seat>
                                                                                                                                    >
                                                                                                                                    seatsByRow
                                                                                                                                    =
                                                                                                                                    new
                                                                                                                                    java.util.TreeMap
                                                                                                                                    <>();
                                                                                                                                        for
                                                                                                                                        (Seat
                                                                                                                                        seat
                                                                                                                                        :
                                                                                                                                        allSeats)
                                                                                                                                        {
                                                                                                                                        String
                                                                                                                                        row
                                                                                                                                        =
                                                                                                                                        seat.getSeatRow();
                                                                                                                                        if
                                                                                                                                        (!seatsByRow.containsKey(row))
                                                                                                                                        {
                                                                                                                                        seatsByRow.put(row,
                                                                                                                                        new
                                                                                                                                        java.util.ArrayList
                                                                                                                                        <>());
                                                                                                                                            }
                                                                                                                                            seatsByRow.get(row).add(seat);
                                                                                                                                            }

                                                                                                                                            //
                                                                                                                                            Render
                                                                                                                                            each
                                                                                                                                            row
                                                                                                                                            for
                                                                                                                                            (Map.Entry
                                                                                                                                            <String,
                                                                                                                                                java.util.List<Seat>
                                                                                                                                                >
                                                                                                                                                entry
                                                                                                                                                :
                                                                                                                                                seatsByRow.entrySet())
                                                                                                                                                {
                                                                                                                                                String
                                                                                                                                                rowLabel
                                                                                                                                                =
                                                                                                                                                entry.getKey();
                                                                                                                                                java.util.List
                                                                                                                                                <Seat>
                                                                                                                                                    rowSeats
                                                                                                                                                    =
                                                                                                                                                    entry.getValue();

                                                                                                                                                    //
                                                                                                                                                    Sort
                                                                                                                                                    seats
                                                                                                                                                    by
                                                                                                                                                    seat
                                                                                                                                                    number
                                                                                                                                                    java.util.Collections.sort(rowSeats,
                                                                                                                                                    new
                                                                                                                                                    java.util.Comparator
                                                                                                                                                    <Seat>
                                                                                                                                                        ()
                                                                                                                                                        {
                                                                                                                                                        public
                                                                                                                                                        int
                                                                                                                                                        compare(Seat
                                                                                                                                                        s1,
                                                                                                                                                        Seat
                                                                                                                                                        s2)
                                                                                                                                                        {
                                                                                                                                                        try
                                                                                                                                                        {
                                                                                                                                                        int
                                                                                                                                                        num1
                                                                                                                                                        =
                                                                                                                                                        Integer.parseInt(s1.getSeatNumber());
                                                                                                                                                        int
                                                                                                                                                        num2
                                                                                                                                                        =
                                                                                                                                                        Integer.parseInt(s2.getSeatNumber());
                                                                                                                                                        return
                                                                                                                                                        Integer.compare(num1,
                                                                                                                                                        num2);
                                                                                                                                                        }
                                                                                                                                                        catch
                                                                                                                                                        (NumberFormatException
                                                                                                                                                        e)
                                                                                                                                                        {
                                                                                                                                                        return
                                                                                                                                                        s1.getSeatNumber().compareTo(s2.getSeatNumber());
                                                                                                                                                        }
                                                                                                                                                        }
                                                                                                                                                        });

                                                                                                                                                        int
                                                                                                                                                        totalSeats
                                                                                                                                                        =
                                                                                                                                                        rowSeats.size();
                                                                                                                                                        int
                                                                                                                                                        halfPoint
                                                                                                                                                        =
                                                                                                                                                        (totalSeats
                                                                                                                                                        +
                                                                                                                                                        1)
                                                                                                                                                        /
                                                                                                                                                        2;
                                                                                                                                                        //
                                                                                                                                                        Calculate
                                                                                                                                                        center
                                                                                                                                                        aisle
                                                                                                                                                        position
                                                                                                                                                        %>
                                                                                                                                                        <div
                                                                                                                                                            class="seat-row-container">
                                                                                                                                                            <%-- Label
                                                                                                                                                                hàng
                                                                                                                                                                ghế
                                                                                                                                                                (A,
                                                                                                                                                                B,
                                                                                                                                                                C...)
                                                                                                                                                                --%>
                                                                                                                                                                <div
                                                                                                                                                                    class="row-label">
                                                                                                                                                                    <%= rowLabel.trim()
                                                                                                                                                                        %>
                                                                                                                                                                </div>
                                                                                                                                                                <div
                                                                                                                                                                    class="seat-row">
                                                                                                                                                                    <% for
                                                                                                                                                                        (int
                                                                                                                                                                        i=0;
                                                                                                                                                                        i
                                                                                                                                                                        <
                                                                                                                                                                        rowSeats.size();
                                                                                                                                                                        i++)
                                                                                                                                                                        {
                                                                                                                                                                        Seat
                                                                                                                                                                        seat=rowSeats.get(i);
                                                                                                                                                                        //
                                                                                                                                                                        Add
                                                                                                                                                                        center
                                                                                                                                                                        aisle
                                                                                                                                                                        after
                                                                                                                                                                        half
                                                                                                                                                                        the
                                                                                                                                                                        seats
                                                                                                                                                                        if
                                                                                                                                                                        (i==halfPoint
                                                                                                                                                                        &&
                                                                                                                                                                        totalSeats>
                                                                                                                                                                        6)
                                                                                                                                                                        {
                                                                                                                                                                        %>
                                                                                                                                                                        <div
                                                                                                                                                                            class="seat-aisle">
                                                                                                                                                                        </div>
                                                                                                                                                                        <% } //
                                                                                                                                                                            Xác
                                                                                                                                                                            định
                                                                                                                                                                            class
                                                                                                                                                                            CSS
                                                                                                                                                                            cho
                                                                                                                                                                            ghế
                                                                                                                                                                            dựa
                                                                                                                                                                            trên
                                                                                                                                                                            trạng
                                                                                                                                                                            thái
                                                                                                                                                                            String
                                                                                                                                                                            seatClass="seat"
                                                                                                                                                                            ;
                                                                                                                                                                            boolean
                                                                                                                                                                            isBooked=bookedSeatIDs
                                                                                                                                                                            !=null
                                                                                                                                                                            &&
                                                                                                                                                                            bookedSeatIDs.contains(seat.getSeatID());
                                                                                                                                                                            boolean
                                                                                                                                                                            isReserved=reservedSeatIDs
                                                                                                                                                                            !=null
                                                                                                                                                                            &&
                                                                                                                                                                            reservedSeatIDs.contains(seat.getSeatID());
                                                                                                                                                                            boolean
                                                                                                                                                                            isSelected=bookingSession.getSelectedSeatIDs()
                                                                                                                                                                            !=null
                                                                                                                                                                            &&
                                                                                                                                                                            bookingSession.getSelectedSeatIDs().contains(seat.getSeatID());
                                                                                                                                                                            boolean
                                                                                                                                                                            isMaintenance="Maintenance"
                                                                                                                                                                            .equals(seat.getStatus());
                                                                                                                                                                            boolean
                                                                                                                                                                            isUnavailable="Unavailable"
                                                                                                                                                                            .equals(seat.getStatus());
                                                                                                                                                                            //
                                                                                                                                                                            Check
                                                                                                                                                                            if
                                                                                                                                                                            seat
                                                                                                                                                                            has
                                                                                                                                                                            unavailable
                                                                                                                                                                            status
                                                                                                                                                                            (from
                                                                                                                                                                            servlet
                                                                                                                                                                            attribute)
                                                                                                                                                                            @SuppressWarnings("unchecked")
                                                                                                                                                                            List<Integer>
                                                                                                                                                                            unavailableStatusSeatIDs
                                                                                                                                                                            =
                                                                                                                                                                            (List
                                                                                                                                                                            <Integer>
                                                                                                                                                                                )
                                                                                                                                                                                request.getAttribute("unavailableStatusSeatIDs");
                                                                                                                                                                                if
                                                                                                                                                                                (unavailableStatusSeatIDs
                                                                                                                                                                                !=
                                                                                                                                                                                null
                                                                                                                                                                                &&
                                                                                                                                                                                unavailableStatusSeatIDs.contains(seat.getSeatID()))
                                                                                                                                                                                {
                                                                                                                                                                                isUnavailable
                                                                                                                                                                                =
                                                                                                                                                                                true;
                                                                                                                                                                                }

                                                                                                                                                                                //
                                                                                                                                                                                Apply
                                                                                                                                                                                appropriate
                                                                                                                                                                                CSS
                                                                                                                                                                                classes
                                                                                                                                                                                if
                                                                                                                                                                                (isMaintenance)
                                                                                                                                                                                {
                                                                                                                                                                                seatClass
                                                                                                                                                                                +=
                                                                                                                                                                                "
                                                                                                                                                                                maintenance";
                                                                                                                                                                                }
                                                                                                                                                                                else
                                                                                                                                                                                if
                                                                                                                                                                                (isUnavailable)
                                                                                                                                                                                {
                                                                                                                                                                                seatClass
                                                                                                                                                                                +=
                                                                                                                                                                                "
                                                                                                                                                                                unavailable";
                                                                                                                                                                                }
                                                                                                                                                                                else
                                                                                                                                                                                if
                                                                                                                                                                                (isBooked)
                                                                                                                                                                                {
                                                                                                                                                                                seatClass
                                                                                                                                                                                +=
                                                                                                                                                                                "
                                                                                                                                                                                booked";
                                                                                                                                                                                }
                                                                                                                                                                                else
                                                                                                                                                                                if
                                                                                                                                                                                (isReserved)
                                                                                                                                                                                {
                                                                                                                                                                                seatClass
                                                                                                                                                                                +=
                                                                                                                                                                                "
                                                                                                                                                                                reserved";
                                                                                                                                                                                }
                                                                                                                                                                                else
                                                                                                                                                                                if
                                                                                                                                                                                (isSelected)
                                                                                                                                                                                {
                                                                                                                                                                                seatClass
                                                                                                                                                                                +=
                                                                                                                                                                                "
                                                                                                                                                                                selected";
                                                                                                                                                                                }

                                                                                                                                                                                //
                                                                                                                                                                                Add
                                                                                                                                                                                seat
                                                                                                                                                                                type
                                                                                                                                                                                classes
                                                                                                                                                                                (VIP,
                                                                                                                                                                                Couple)
                                                                                                                                                                                String
                                                                                                                                                                                seatType
                                                                                                                                                                                =
                                                                                                                                                                                seat.getSeatType();
                                                                                                                                                                                if
                                                                                                                                                                                ("VIP".equals(seatType))
                                                                                                                                                                                {
                                                                                                                                                                                seatClass
                                                                                                                                                                                +=
                                                                                                                                                                                "
                                                                                                                                                                                vip";
                                                                                                                                                                                }
                                                                                                                                                                                else
                                                                                                                                                                                if
                                                                                                                                                                                ("Couple".equals(seatType))
                                                                                                                                                                                {
                                                                                                                                                                                seatClass
                                                                                                                                                                                +=
                                                                                                                                                                                "
                                                                                                                                                                                couple";
                                                                                                                                                                                }
                                                                                                                                                                                %>
                                                                                                                                                                                <%-- Render
                                                                                                                                                                                    ghế
                                                                                                                                                                                    với
                                                                                                                                                                                    các
                                                                                                                                                                                    data
                                                                                                                                                                                    attributes:
                                                                                                                                                                                    -
                                                                                                                                                                                    data-seat-id:
                                                                                                                                                                                    ID
                                                                                                                                                                                    ghế
                                                                                                                                                                                    trong
                                                                                                                                                                                    database
                                                                                                                                                                                    -
                                                                                                                                                                                    data-seat-label:
                                                                                                                                                                                    Label
                                                                                                                                                                                    hiển
                                                                                                                                                                                    thị
                                                                                                                                                                                    (vd:
                                                                                                                                                                                    A1,
                                                                                                                                                                                    B5)
                                                                                                                                                                                    -
                                                                                                                                                                                    data-available:
                                                                                                                                                                                    Có
                                                                                                                                                                                    thể
                                                                                                                                                                                    chọn
                                                                                                                                                                                    được
                                                                                                                                                                                    không
                                                                                                                                                                                    -
                                                                                                                                                                                    data-price-multiplier:
                                                                                                                                                                                    Hệ
                                                                                                                                                                                    số
                                                                                                                                                                                    nhân
                                                                                                                                                                                    giá
                                                                                                                                                                                    (VIP=1.5,
                                                                                                                                                                                    Couple=2.0)
                                                                                                                                                                                    -
                                                                                                                                                                                    data-seat-type:
                                                                                                                                                                                    Loại
                                                                                                                                                                                    ghế
                                                                                                                                                                                    --%>
                                                                                                                                                                                    <div class="<%= seatClass %>"
                                                                                                                                                                                        data-seat-id="<%= seat.getSeatID() %>"
                                                                                                                                                                                        data-seat-label="<%= seat.getSeatRow().trim() %><%= seat.getSeatNumber() %>"
                                                                                                                                                                                        data-available="<%= !isBooked && !isReserved && !isMaintenance && !isUnavailable %>"
                                                                                                                                                                                        data-price-multiplier="<%= seat.getPriceMultiplier() %>"
                                                                                                                                                                                        data-seat-type="<%= seatType %>">
                                                                                                                                                                                        <%= seat.getSeatNumber()
                                                                                                                                                                                            %>
                                                                                                                                                                                    </div>
                                                                                                                                                                                    <% }
                                                                                                                                                                                        %>
                                                                                                                                                                </div>
                                                                                                                                                        </div>
                                                                                                                                                        <% } }
                                                                                                                                                            %>
                                                                                                                    </div>

                                                                                                                    <%-- Legend
                                                                                                                        -
                                                                                                                        Chú
                                                                                                                        thích
                                                                                                                        màu
                                                                                                                        sắc
                                                                                                                        và
                                                                                                                        trạng
                                                                                                                        thái
                                                                                                                        ghế
                                                                                                                        --%>
                                                                                                                        <div
                                                                                                                            class="legend-section">
                                                                                                                            <div
                                                                                                                                class="legend-item">
                                                                                                                                <div class="legend-box"
                                                                                                                                    style="background: #2a2d35; border: 1px solid #3a3d45;">
                                                                                                                                </div>
                                                                                                                                <span
                                                                                                                                    class="legend-text">Ghế
                                                                                                                                    thường</span>
                                                                                                                            </div>
                                                                                                                            <div
                                                                                                                                class="legend-item">
                                                                                                                                <div class="legend-box"
                                                                                                                                    style="background: #2f2d2a; border: 1px solid #6b5d3f;">
                                                                                                                                </div>
                                                                                                                                <span
                                                                                                                                    class="legend-text">Ghế
                                                                                                                                    VIP</span>
                                                                                                                            </div>
                                                                                                                            <div
                                                                                                                                class="legend-item">
                                                                                                                                <div class="legend-box"
                                                                                                                                    style="background: #2d2a2d; border: 1px solid #4a3d45; width: 50px;">
                                                                                                                                </div>
                                                                                                                                <span
                                                                                                                                    class="legend-text">Ghế
                                                                                                                                    đôi</span>
                                                                                                                            </div>
                                                                                                                            <div
                                                                                                                                class="legend-item">
                                                                                                                                <div class="legend-box"
                                                                                                                                    style="background: #e50914; border: 2px solid #e50914;">
                                                                                                                                </div>
                                                                                                                                <span
                                                                                                                                    class="legend-text">Đang
                                                                                                                                    chọn</span>
                                                                                                                            </div>
                                                                                                                            <div
                                                                                                                                class="legend-item">
                                                                                                                                <div class="legend-box"
                                                                                                                                    style="background: #1a1d24; border: 1px solid #1a1d24; opacity: 0.3;">
                                                                                                                                </div>
                                                                                                                                <span
                                                                                                                                    class="legend-text">Đã
                                                                                                                                    đặt</span>
                                                                                                                            </div>
                                                                                                                            <div
                                                                                                                                class="legend-item">
                                                                                                                                <div class="legend-box"
                                                                                                                                    style="background: linear-gradient(135deg, #ff9500 0%, #ff7b00 100%); border: 2px solid #ff9500; position: relative; display: flex; align-items: center; justify-content: center; font-family: 'Font Awesome 5 Free'; font-weight: 400;">
                                                                                                                                    <span
                                                                                                                                        style="color: rgba(255, 255, 255, 0.9); font-size: 12px;">&#xf017;</span>
                                                                                                                                </div>
                                                                                                                                <span
                                                                                                                                    class="legend-text">Đang
                                                                                                                                    giữ</span>
                                                                                                                            </div>
                                                                                                                        </div>
                                                                                                                </form>
                                                                                                            </div>

                                                                                                            <%-- Summary
                                                                                                                Section
                                                                                                                - Hiển
                                                                                                                thị ghế
                                                                                                                đã chọn
                                                                                                                và tổng
                                                                                                                tiền
                                                                                                                --%>
                                                                                                                <div
                                                                                                                    class="summary-section">
                                                                                                                    <div
                                                                                                                        class="summary-header">
                                                                                                                        <h3
                                                                                                                            class="section-title">
                                                                                                                            <i
                                                                                                                                class="fas fa-chair"></i>
                                                                                                                            <span>Ghế
                                                                                                                                Đã
                                                                                                                                Chọn</span>
                                                                                                                        </h3>
                                                                                                                        <%-- Hiển
                                                                                                                            thị
                                                                                                                            số
                                                                                                                            lượng
                                                                                                                            ghế
                                                                                                                            đã
                                                                                                                            chọn
                                                                                                                            /
                                                                                                                            tối
                                                                                                                            đa
                                                                                                                            --%>
                                                                                                                            <div
                                                                                                                                class="summary-count">
                                                                                                                                <span
                                                                                                                                    id="selectedCount">0</span>/8
                                                                                                                            </div>
                                                                                                                    </div>

                                                                                                                    <%-- Container
                                                                                                                        hiển
                                                                                                                        thị
                                                                                                                        các
                                                                                                                        tag
                                                                                                                        ghế
                                                                                                                        đã
                                                                                                                        chọn
                                                                                                                        --%>
                                                                                                                        <div class="seat-tags-container"
                                                                                                                            id="seatTagsContainer">
                                                                                                                            <span
                                                                                                                                class="empty-selection">Chưa
                                                                                                                                chọn
                                                                                                                                ghế
                                                                                                                                nào</span>
                                                                                                                        </div>

                                                                                                                        <%-- Tổng
                                                                                                                            thanh
                                                                                                                            toán
                                                                                                                            --%>
                                                                                                                            <div
                                                                                                                                class="total-section">
                                                                                                                                <div
                                                                                                                                    class="total-label">
                                                                                                                                    TỔNG
                                                                                                                                    THANH
                                                                                                                                    TOÁN
                                                                                                                                </div>
                                                                                                                                <div class="total-amount"
                                                                                                                                    id="totalAmount">
                                                                                                                                    0
                                                                                                                                    VNĐ
                                                                                                                                </div>
                                                                                                                            </div>
                                                                                                                </div>

                                                                                                                <%-- Action
                                                                                                                    Buttons
                                                                                                                    --%>
                                                                                                                    <div
                                                                                                                        class="action-section">
                                                                                                                        <%-- Nút
                                                                                                                            đặt
                                                                                                                            lại
                                                                                                                            (reset)
                                                                                                                            --%>
                                                                                                                            <button
                                                                                                                                type="button"
                                                                                                                                class="btn-action btn-reset"
                                                                                                                                onclick="resetSeats()">
                                                                                                                                <i
                                                                                                                                    class="fas fa-redo"></i>
                                                                                                                                Đặt
                                                                                                                                Lại
                                                                                                                            </button>
                                                                                                                            <%-- Nút
                                                                                                                                tiếp
                                                                                                                                tục
                                                                                                                                (disabled
                                                                                                                                khi
                                                                                                                                chưa
                                                                                                                                chọn
                                                                                                                                ghế)
                                                                                                                                --%>
                                                                                                                                <button
                                                                                                                                    type="button"
                                                                                                                                    class="btn-action btn-continue"
                                                                                                                                    id="continueBtn"
                                                                                                                                    disabled
                                                                                                                                    onclick="submitForm()">
                                                                                                                                    <i
                                                                                                                                        class="fas fa-arrow-right"></i>
                                                                                                                                    Tiếp
                                                                                                                                    Tục
                                                                                                                                </button>
                                                                                                                    </div>
                                                                            </div>

                                                                            <script
                                                                                src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
                                                                            <script>
                                                                                // ===== CONSTANTS =====
                                                                                const ticketPrice = <%= bookingSession.getTicketPrice() %>;  // Giá vé cơ bản
                                                                                const selectedSeatsData = new Map();  // Map lưu thông tin ghế đã chọn {seatId: {label, multiplier}}
                                                                                const maxSeats = 8;  // Số ghế tối đa có thể chọn

                                                                                // ===== INITIALIZATION =====
                                                                                /**
                                                                                 * Khởi tạo trang khi DOM đã load xong
                                                                                 */
                                                                                document.addEventListener('DOMContentLoaded', function () {
                                                                                    initializeSeats();  // Gắn event listeners cho các ghế
                                                                                    startAutoRefresh();  // Bắt đầu auto-refresh trạng thái ghế
                                                                                });

                                                                                /**
                                                                                 * Khởi tạo event listeners cho tất cả các ghế
                                                                                 */
                                                                                function initializeSeats() {
                                                                                    document.querySelectorAll('.seat').forEach(seat => {
                                                                                        seat.addEventListener('click', function () {
                                                                                            toggleSeat(this);
                                                                                        });
                                                                                    });
                                                                                    updateSummary();  // Cập nhật summary ban đầu
                                                                                }

                                                                                // ===== SEAT SELECTION =====
                                                                                /**
                                                                                 * Xử lý chọn/bỏ chọn ghế
                                                                                 * @param {HTMLElement} element - Phần tử ghế được click
                                                                                 */
                                                                                function toggleSeat(element) {
                                                                                    // Kiểm tra ghế có thể chọn không
                                                                                    if (element.dataset.available !== 'true') {
                                                                                        return;
                                                                                    }

                                                                                    const seatId = element.dataset.seatId;
                                                                                    const seatLabel = element.dataset.seatLabel;
                                                                                    const priceMultiplier = parseFloat(element.dataset.priceMultiplier) || 1.0;

                                                                                    // Nếu ghế đã được chọn -> bỏ chọn
                                                                                    if (selectedSeatsData.has(seatId)) {
                                                                                        selectedSeatsData.delete(seatId);
                                                                                        element.classList.remove('selected');
                                                                                    } else {
                                                                                        // Kiểm tra giới hạn số ghế
                                                                                        if (selectedSeatsData.size >= maxSeats) {
                                                                                            showNotification('Bạn chỉ có thể chọn tối đa ' + maxSeats + ' ghế!', 'warning');
                                                                                            return;
                                                                                        }

                                                                                        // Thêm ghế vào danh sách đã chọn
                                                                                        selectedSeatsData.set(seatId, {
                                                                                            label: seatLabel,
                                                                                            multiplier: priceMultiplier
                                                                                        });
                                                                                        element.classList.add('selected');
                                                                                    }

                                                                                    updateSummary();  // Cập nhật summary sau khi chọn/bỏ chọn
                                                                                }

                                                                                // ===== SUMMARY UPDATE =====
                                                                                /**
                                                                                 * Cập nhật phần summary (số ghế đã chọn, danh sách ghế, tổng tiền)
                                                                                 */
                                                                                function updateSummary() {
                                                                                    const count = selectedSeatsData.size;
                                                                                    document.getElementById('selectedCount').textContent = count;

                                                                                    // Cập nhật danh sách ghế đã chọn
                                                                                    const container = document.getElementById('seatTagsContainer');
                                                                                    if (count === 0) {
                                                                                        container.innerHTML = '<span class="empty-selection">Chưa chọn ghế nào</span>';
                                                                                    } else {
                                                                                        container.innerHTML = '';
                                                                                        selectedSeatsData.forEach(function (data, id) {
                                                                                            const tag = document.createElement('span');
                                                                                            tag.className = 'seat-tag';
                                                                                            tag.textContent = data.label;
                                                                                            container.appendChild(tag);
                                                                                        });
                                                                                    }

                                                                                    // Tính tổng tiền dựa trên loại ghế (VIP có hệ số 1.5, Couple có hệ số 2.0)
                                                                                    let total = 0;
                                                                                    selectedSeatsData.forEach(function (data) {
                                                                                        total += ticketPrice * data.multiplier;
                                                                                    });

                                                                                    // Cập nhật tổng tiền với animation
                                                                                    const totalElement = document.getElementById('totalAmount');
                                                                                    totalElement.style.transform = 'scale(1.1)';
                                                                                    setTimeout(function () {
                                                                                        totalElement.textContent = total.toLocaleString('vi-VN') + ' VNĐ';
                                                                                        totalElement.style.transform = 'scale(1)';
                                                                                    }, 150);

                                                                                    // Enable/disable nút tiếp tục
                                                                                    document.getElementById('continueBtn').disabled = count === 0;
                                                                                }

                                                                                // ===== ACTIONS =====
                                                                                /**
                                                                                 * Reset tất cả ghế đã chọn
                                                                                 */
                                                                                function resetSeats() {
                                                                                    if (selectedSeatsData.size === 0) return;

                                                                                    if (confirm('Bạn có chắc muốn bỏ chọn tất cả ghế?')) {
                                                                                        selectedSeatsData.clear();
                                                                                        document.querySelectorAll('.seat.selected').forEach(function (seat) {
                                                                                            seat.classList.remove('selected');
                                                                                        });
                                                                                        updateSummary();
                                                                                    }
                                                                                }

                                                                                /**
                                                                                 * Submit form để chuyển sang trang chọn đồ ăn
                                                                                 */
                                                                                function submitForm() {
                                                                                    if (selectedSeatsData.size === 0) {
                                                                                        showNotification('Vui lòng chọn ít nhất một ghế!', 'warning');
                                                                                        return;
                                                                                    }

                                                                                    // Hiển thị loading overlay
                                                                                    document.getElementById('loadingOverlay').style.display = 'flex';

                                                                                    // Thêm các seatID vào form
                                                                                    const form = document.getElementById('seatForm');
                                                                                    selectedSeatsData.forEach(function (data, seatId) {
                                                                                        const input = document.createElement('input');
                                                                                        input.type = 'hidden';
                                                                                        input.name = 'seatIDs';
                                                                                        input.value = seatId;
                                                                                        form.appendChild(input);
                                                                                    });

                                                                                    // Delay 500ms để hiển thị loading
                                                                                    setTimeout(function () {
                                                                                        form.submit();
                                                                                    }, 500);
                                                                                }

                                                                                // ===== AUTO REFRESH =====
                                                                                /**
                                                                                 * Bắt đầu auto-refresh trạng thái ghế mỗi 5 giây
                                                                                 */
                                                                                function startAutoRefresh() {
                                                                                    setInterval(function () {
                                                                                        refreshSeatAvailability();
                                                                                    }, 5000);
                                                                                }

                                                                                /**
                                                                                 * Gọi API để lấy trạng thái ghế mới nhất
                                                                                 */
                                                                                function refreshSeatAvailability() {
                                                                                    fetch('${pageContext.request.contextPath}/booking/select-seats?ajax=true&screeningID=<%= bookingSession.getScreeningID() %>')
                                                                                        .then(response => response.json())
                                                                                        .then(data => {
                                                                                            if (data.bookedSeats || data.reservedSeats) {
                                                                                                updateSeatStatus(data.bookedSeats, data.reservedSeats);
                                                                                            }
                                                                                        })
                                                                                        .catch(error => console.log('Auto-refresh error:', error));
                                                                                }

                                                                                /**
                                                                                 * Cập nhật trạng thái ghế dựa trên dữ liệu từ server
                                                                                 * @param {Array} bookedSeats - Danh sách ID ghế đã đặt
                                                                                 * @param {Array} reservedSeats - Danh sách ID ghế đang giữ
                                                                                 */
                                                                                function updateSeatStatus(bookedSeats, reservedSeats) {
                                                                                    let hasChanges = false;

                                                                                    document.querySelectorAll('.seat').forEach(function (seat) {
                                                                                        const seatId = parseInt(seat.dataset.seatId);

                                                                                        // Ghế đã được đặt (confirmed)
                                                                                        if (bookedSeats.includes(seatId)) {
                                                                                            if (!seat.classList.contains('booked')) {
                                                                                                seat.classList.remove('selected', 'reserved');
                                                                                                seat.classList.add('booked');
                                                                                                seat.dataset.available = 'false';

                                                                                                // Nếu ghế này đang được chọn bởi user -> xóa khỏi danh sách
                                                                                                if (selectedSeatsData.has(String(seatId))) {
                                                                                                    selectedSeatsData.delete(String(seatId));
                                                                                                    hasChanges = true;
                                                                                                }
                                                                                            }
                                                                                        }
                                                                                        // Ghế đang được giữ tạm (reserved)
                                                                                        else if (reservedSeats.includes(seatId)) {
                                                                                            if (!seat.classList.contains('reserved') && !seat.classList.contains('selected')) {
                                                                                                seat.classList.add('reserved');
                                                                                                seat.dataset.available = 'false';
                                                                                            }
                                                                                        }
                                                                                        // Ghế đã hết giữ chỗ -> trở về available
                                                                                        else if (seat.classList.contains('reserved') && !seat.classList.contains('selected')) {
                                                                                            seat.classList.remove('reserved');
                                                                                            seat.dataset.available = 'true';
                                                                                        }
                                                                                    });

                                                                                    // Nếu có ghế bị người khác đặt -> cập nhật lại summary và thông báo
                                                                                    if (hasChanges) {
                                                                                        updateSummary();
                                                                                        showNotification('Một số ghế đã bị người khác đặt!', 'warning');
                                                                                    }
                                                                                }

                                                                                // ===== NOTIFICATION =====
                                                                                /**
                                                                                 * Hiển thị thông báo tạm thời
                                                                                 * @param {string} message - Nội dung thông báo
                                                                                 * @param {string} type - Loại thông báo (warning, error, info)
                                                                                 */
                                                                                function showNotification(message, type) {
                                                                                    const alertClass = type === 'warning' ? 'alert-warning' :
                                                                                        type === 'error' ? 'alert-danger' : 'alert-info';

                                                                                    const notification = document.createElement('div');
                                                                                    notification.className = 'alert ' + alertClass;
                                                                                    notification.style.cssText = 'position: fixed; top: 20px; right: 20px; z-index: 10000; min-width: 300px; animation: slideIn 0.3s ease;';
                                                                                    notification.innerHTML = '<i class="fas fa-exclamation-circle"></i> ' + message;

                                                                                    document.body.appendChild(notification);

                                                                                    // Tự động ẩn sau 3 giây
                                                                                    setTimeout(function () {
                                                                                        notification.remove();
                                                                                    }, 3000);
                                                                                }

                                                                                // Thêm animation CSS cho notification
                                                                                const style = document.createElement('style');
                                                                                style.textContent = '@keyframes slideIn { from { transform: translateX(100%); opacity: 0; } to { transform: translateX(0); opacity: 1; } }';
                                                                                document.head.appendChild(style);
                                                                            </script>
                                </body>

                                </html>