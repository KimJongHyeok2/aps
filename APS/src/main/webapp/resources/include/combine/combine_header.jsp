<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/resources/css/community/combine/combine_header.css">
<!-- 통합 게시판 헤더 -->
<script>
$(document).ready(function() {
    $('[data-toggle="conn-users-tooltip"]').tooltip();
});
</script>
<div class="board-header">
	<div class="info">
		<div class="name">통합 게시판</div>
		<div class="other">
			<div class="other-button users" data-toggle="conn-users-tooltip" data-placement="bottom" title="접속 중인 이용자">
				<i class="fas fa-users"></i> <span id="conn-users">0</span>
			</div>
		</div>
	</div>
</div>