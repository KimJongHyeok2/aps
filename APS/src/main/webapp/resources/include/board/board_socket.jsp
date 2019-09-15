<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/resources/css/community/board/board_socket.css">
<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/sockjs-client/1.1.5/sockjs.min.js"></script>
<script>
var socket;
socket = new SockJS('<c:url value="/BoardWritePush"/>');
socket.onopen = onOpen;
socket.onmessage = onMessage;
socket.onclose = onClose;

function onOpen() {
	socket.send("${broadcaster.id}");
}
function onMessage(msg) {
	var message = msg.data.split(",");
	if(message[0] == "${broadcaster.id}") { // 접속 중인 방송인 커뮤니티 게시판의 알림일 경우만
		if(message.length == 3) {
			var tempHTML = "";
			tempHTML += "<div id='session-message-" + message[1] + "' class='session-message animated tdFadeInLeft' onclick=moveNewBoardWrite('" + message[0] + "','" + message[1] + "');>";
				tempHTML += "<div class='icon'><i class='fas fa-info-circle fa-3x'></i></div>";
				tempHTML += "<div class='content'>";
					tempHTML += "<div class='title'>새 글이 등록되었습니다.</div>";
					tempHTML += "<div class='subject'>" + message[2] + "</div>";
				tempHTML += "</div>";
			tempHTML += "</div>";
			$(".session-message-box").append(tempHTML);
			setTimeout(function() { $("#session-message-" + message[1]).addClass("animated tdFadeOutRight"); }, 5000);
			setTimeout(function() { $("#session-message-" + message[1]).remove(); }, 5500);
		} else {
			$("#conn-users").html(message[1].replace(/\B(?=(\d{3})+(?!\d))/g, ","));
		}
	} else if(message[0] == "combine") {
		if(message.length == 3) {
			var tempHTML = "";
			tempHTML += "<div id='session-message-" + message[1] + "' class='session-message animated tdFadeInLeft' onclick=moveNewBoardWrite('" + message[0] + "','" + message[1] + "');>";
				tempHTML += "<div class='icon'><i class='fas fa-info-circle fa-3x'></i></div>";
				tempHTML += "<div class='content'>";
					tempHTML += "<div class='title'>새 글이 등록되었습니다.</div>";
					tempHTML += "<div class='subject'>" + message[2] + "</div>";
				tempHTML += "</div>";
			tempHTML += "</div>";
			$(".session-message-box").append(tempHTML);
			setTimeout(function() { $("#session-message-" + message[1]).addClass("animated tdFadeOutRight"); }, 5000);
			setTimeout(function() { $("#session-message-" + message[1]).remove(); }, 5500);
		} else {
			$("#conn-users").html(message[1].replace(/\B(?=(\d{3})+(?!\d))/g, ","));
		}
	}
}
function onClose(evt) {
	var tempHTML = "";
	tempHTML += "<div id='session-message-error' class='session-message animated tdFadeInLeft'>";
		tempHTML += "<div class='icon'><i class='fas fa-exclamation-triangle fa-3x'></i></div>";
		tempHTML += "<div class='content'>";
			tempHTML += "<div class='title'>연결이 종료되었습니다.</div>";
			tempHTML += "<div class='subject'>새로고침을 진행해주세요.</div>";
		tempHTML += "</div>";
	tempHTML += "</div>";
	$(".session-message-box").html(tempHTML);
	setTimeout(function() { $("#session-message-error").addClass("animated tdFadeOutRight"); }, 5000);
	setTimeout(function() { $("#session-message-error").remove(); }, 5500)
}
function moveNewBoardWrite(type, id) {
	if(type == "combine") {
		location.href= "${pageContext.request.contextPath}/community/combine/view/" + id;
	} else {
		location.href= "${pageContext.request.contextPath}/community/board/view/" + id + "?broadcasterId=" + broadcasterId;
	}
}
</script>
<div class="session-message-box">
</div>