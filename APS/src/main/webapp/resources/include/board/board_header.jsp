<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/resources/css/community/board/board_header.css">
<!-- 게시판 헤더 -->
<script>
$(document).ready(function() {
    $('[data-toggle="conn-users-tooltip"]').tooltip();
});
</script>
<div class="board-header">
	<div class="profile-img">
		<c:choose>
			<c:when test="${not empty broadcaster.profile}">
				<img class="img-fluid" src="${pageContext.request.contextPath}/resources/image/broadcaster/${broadcaster.profile}"/>
			</c:when>
			<c:otherwise>
				<i class="far fa-user fa-5x"></i>
			</c:otherwise>
		</c:choose>
		<div class="medal">
			<c:if test="${broadcaster.best_flag == true}">
				<span class="best">B</span>
			</c:if>
			<c:if test="${broadcaster.partner_flag == true}">
				<span class="partner">P</span>
			</c:if>
		</div>
	</div>
	<div class="profile-info">
		<div class="name">${broadcaster.nickname}</div>
		<hr>
		<div class="other-box">
			<c:if test="${not empty broadcaster.afreeca}">
				<div class="other-button" onclick="popUp('${broadcaster.afreeca}');">
					<i class="fas fa-broadcast-tower"></i>
				</div>
			</c:if>
			<c:if test="${not empty broadcaster.youtube}">
				<div class="other-button" onclick="popUp('${broadcaster.youtube}');">
					<i class="fab fa-youtube"></i>
				</div>
			</c:if>
			<div class="other-button users" data-toggle="conn-users-tooltip" data-placement="bottom" title="접속 중인 이용자">
				<i class="fas fa-users"></i> <span id="conn-users">0</span>
			</div>
		</div>
	</div>
</div>