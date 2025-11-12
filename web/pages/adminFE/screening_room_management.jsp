<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<div id="screening-room-management-content">
    <c:choose>
        <c:when test="${param.action == 'editSeat'}">
            <!-- Khi edit seat, include edit_seat.jsp -->
            <jsp:include page="edit_seat.jsp"/>
        </c:when>
        <c:when test="${empty param.action || param.action == 'list'}">
            <jsp:include page="screening_room_list.jsp"/>
        </c:when>
        <c:when test="${param.action == 'view' || param.action == 'edit' || param.action == 'create'}">
            <jsp:include page="screening_room_detail.jsp"/>
        </c:when>
        <c:otherwise>
            <jsp:include page="screening_room_list.jsp"/>
        </c:otherwise>
    </c:choose>
</div>