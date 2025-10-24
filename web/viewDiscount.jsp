<%-- 
    Document   : viewDiscount
    Created on : 23 thg 10, 2025, 23:16:20
    Author     : admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Chi tiết chương trình khuyến mại</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    </head>
    <body class="bg-light">
        <div id="layoutSidenav_content">
            <main class="p-4">
                <div class="container-fluid">
                    <div class="card shadow-lg border-0 rounded-4 mx-auto" style="max-width: 800px;">
                        <div class="card-header bg-primary text-white text-center">
                            <h4 class="mb-0">Thông tin chi tiết CTKM</h4>
                        </div>
                        <div class="card-body p-4">
                            <c:if test="${not empty discount}">
                                <table class="table table-bordered">
                                    <tr><th>Mã CTKM</th><td>${discount.code}</td></tr>
                                    <tr><th>Phần trăm giảm</th><td>${discount.discountPercentage}%</td></tr>
                                    <tr>
                                        <th>Thời điểm áp dụng</th>
                                        <td>
                                            <fmt:formatDate value="${startDate}" pattern="dd/MM/yyyy HH:mm"/> → 
                                            <fmt:formatDate value="${endDate}" pattern="dd/MM/yyyy HH:mm"/>
                                        </td>
                                    </tr>
                                    <tr><th>Thời lượng</th><td>${duration} ngày</td></tr>
                                    <tr>
                                        <th>Trạng thái</th>
                                        <td>${discount.status}</td>
                                    </tr>
                                    <tr><th>Số lần sử dụng / Tối đa</th><td>${discount.usageCount} / ${discount.maxUsage}</td></tr>
                                </table>

                                <div class="text-center mt-4">
                                    <a href="listDiscount" class="btn btn-secondary px-4">Quay lại</a>
                                </div>
                            </c:if>
                        </div>
                    </div>
                </div>
            </main>
        </div>


    </body>
</html>

