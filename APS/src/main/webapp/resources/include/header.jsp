<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="s" uri="http://www.springframework.org/security/tags" %>
<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/resources/css/include/header.css">
<script>
var pushCount = 0;
var pushReadCount = 0;
$(document).ready(function() {
	if("${not empty sessionScope.id}" == "true") {
		selectPushList();
		setInterval(selectPushListPolling, 20000);
		$("#push-list").click(function(e) {
			e.stopPropagation();
		});
	}
});
function selectPushList() {
	var header = "${_csrf.headerName}";
	var token = "${_csrf.token}";
	$("#empty-push-list").css("display", "none");
	$("#error-push-list").css("display", "none");
	$("#mobile-empty-push-list").css("display", "none");
	$("#mobile-error-push-list").css("display", "none");
	$("#pl-default").html("");
	$("#mobile-pl-default").html("");
	$("#push-list").append("<li id='progress-push-list' class='progress-push-list'><div class='spinner-border spinner-aps'></div></li>");
	$("#mobile-push-list").append("<li id='mobile-progress-push-list' class='progress-push-list'><div class='spinner-border spinner-aps'></div></li>");
	$.ajax({
		url: "${pageContext.request.contextPath}/common/push",
		type: "POST",
		cache: false,
		beforeSend: function(xhr) {
			xhr.setRequestHeader(header, token);
		},
		complete: function() {
			$("#progress-push-list").remove();
			$("#mobile-progress-push-list").remove();
		},
		success: function(data, status) {
			if(status == "success") {
				if(data.status == "Success") {
					pushCount = 0;
					pushReadCount = 0;
					if(data.count != 0) {
						var tempHTML = "";
						setTimeout(function() { $("#push-bell").removeClass("animated swing"); $("#mobile-push-bell").removeClass("animated swing"); }, 2000);
						for(var i=0; i<data.count; i++) {
							if(data.userPushs[i].status == 1) {
								pushCount += 1;
							} else {
								pushReadCount += 1;
							}
							tempHTML += "<div class='pl-default-box " + (data.userPushs[i].status==1? "":"read") + "'>";
								tempHTML += "<div class='read-circle'></div>";
								tempHTML += "<div class='content'>";
									tempHTML += "<p class='subject' onclick=movePushPage('" + data.userPushs[i].id + "','" + data.userPushs[i].broadcaster_id + "','" + data.userPushs[i].content_id + "','" + data.userPushs[i].type + "');>" + pushSubjectFormat(data.userPushs[i].broadcaster_nickname,data.userPushs[i].subject,data.userPushs[i].type) + "</p>";
									tempHTML += "<p class='info'>";
										tempHTML += "<span>" + pushTypeFormat(data.userPushs[i].type) + "</span><span>" + (data.userPushs[i].nickname==null? data.userPushs[i].nonuser_nickname:data.userPushs[i].nickname) + "</span><span class='push-date'>" + pushDateFormat(data.userPushs[i].register_date) + "</span>";
									tempHTML += "</p>"
								tempHTML += "</div>";
								tempHTML += "<div class='button'>";
									tempHTML += "<button class='remove-button' onclick=deletePush('" + data.userPushs[i].id + "','one');>삭제</button>";
								tempHTML += "</div>";
							tempHTML += "</div>";
						}
						$("#pl-default").html(tempHTML);
						$("#mobile-pl-default").html(tempHTML);
					} else {
						$("#empty-push-list").css("display", "block");
						$("#mobile-empty-push-list").css("display", "block");
					}
					$("#push-count").html(pushCount>99? "99+":pushCount);
					$("#mobile-push-count").html(pushCount>99? "99+":pushCount);
				} else {
					$("#empty-push-list").css("display", "block");
					$("#mobile-empty-push-list").css("display", "block");
				}
				if(pushCount > 0) {
					$("#push-bell").addClass("animated swing");
					$("#push-bell").addClass("on");
					$("#mobile-push-bell").addClass("animated swing");
					$("#mobile-push-bell").addClass("on");
					$(".push-count").addClass("on");
				} else {
					$("#push-bell").removeClass("on");
					$("#mobile-push-bell").removeClass("on");
					$(".push-count").removeClass("on");
				}
			}
		},
		error: function() {
			$("#empty-push-list").css("display", "block");
			$("#mobile-empty-push-list").css("display", "block");
			location.reload();
		}
	});
}
function selectPushListPolling() {
	var header = "${_csrf.headerName}";
	var token = "${_csrf.token}";
	$("#empty-push-list").css("display", "none");
	$("#error-push-list").css("display", "none");
	$("#mobile-empty-push-list").css("display", "none");
	$("#mobile-error-push-list").css("display", "none");
	$("#pl-default").html("");
	$("#mobile-pl-default").html("");
	$("#push-list").append("<li id='progress-push-list' class='progress-push-list'><div class='spinner-border spinner-aps'></div></li>");
	$("#mobile-push-list").append("<li id='mobile-progress-push-list' class='progress-push-list'><div class='spinner-border spinner-aps'></div></li>");
	setTimeout(function() {
		$.ajax({
			url: "${pageContext.request.contextPath}/common/push",
			type: "POST",
			cache: false,
			beforeSend: function(xhr) {
				xhr.setRequestHeader(header, token);
			},
			complete: function() {
				$("#progress-push-list").remove();
				$("#mobile-progress-push-list").remove();
			},
			success: function(data, status) {
				if(status == "success") {
					if(data.status == "Success") {
						pushCount = 0;
						pushReadCount = 0;
						if(data.count != 0) {
							var tempHTML = "";
							setTimeout(function() { $("#push-bell").removeClass("animated swing"); $("#mobile-push-bell").removeClass("animated swing"); }, 2000);
							for(var i=0; i<data.count; i++) {
								if(data.userPushs[i].status == 1) {
									pushCount += 1;
								} else {
									pushReadCount += 1;
								}
								tempHTML += "<div class='pl-default-box " + (data.userPushs[i].status==1? "":"read") + "'>";
									tempHTML += "<div class='read-circle'></div>";
									tempHTML += "<div class='content'>";
										tempHTML += "<p class='subject' onclick=movePushPage('" + data.userPushs[i].id + "','" + data.userPushs[i].broadcaster_id + "','" + data.userPushs[i].content_id + "','" + data.userPushs[i].type + "');>" + pushSubjectFormat(data.userPushs[i].broadcaster_nickname,data.userPushs[i].subject,data.userPushs[i].type) + "</p>";
										tempHTML += "<p class='info'>";
											tempHTML += "<span>" + pushTypeFormat(data.userPushs[i].type) + "</span><span>" + (data.userPushs[i].nickname==null? data.userPushs[i].nonuser_nickname:data.userPushs[i].nickname) + "</span><span>" + pushDateFormat(data.userPushs[i].register_date) + "</span>";
										tempHTML += "</p>"
									tempHTML += "</div>";
									tempHTML += "<div class='button'>";
										tempHTML += "<button class='remove-button' onclick=deletePush('" + data.userPushs[i].id + "','one');>삭제</button>";
									tempHTML += "</div>";
								tempHTML += "</div>";
							}
							$("#pl-default").html(tempHTML);
							$("#mobile-pl-default").html(tempHTML);
						} else {
							$("#empty-push-list").css("display", "block");
							$("#mobile-empty-push-list").css("display", "block");
						}
						$("#push-count").html(pushCount>99? "99+":pushCount);
						$("#mobile-push-count").html(pushCount>99? "99+":pushCount);
					}
					if(pushCount > 0) {
						$("#push-bell").addClass("animated swing");
						$("#push-bell").addClass("on");
						$("#mobile-push-bell").addClass("animated swing");
						$("#mobile-push-bell").addClass("on");
						$(".push-count").addClass("on");
					} else {
						$("#push-bell").removeClass("on");
						$("#mobile-push-bell").removeClass("on");
						$(".push-count").removeClass("on")
					}
				}
			},
			error: function() {
				$("#error-push-list").css("display", "block");
				$("#mobile-error-push-list").css("display", "block");
				location.reload();
			}
		});
	}, 2000);
}
function pushSubjectFormat(nickname, subject, type) {
	if(type == 3) {
		return "민심평가(" + nickname + ")";
	} else {
		return subject;
	}
}
function pushTypeFormat(type) {
	if(type == 1 || type == 4 || type == 6) {
		return "댓글";
	} else if(type == 2 || type == 3 || type == 5 || type == 7) {
		return "답글";
	}
}
function movePushPage(id, broadcasterId, boardId, type) {
	var header = "${_csrf.headerName}";
	var token = "${_csrf.token}";
	$.ajax({
		url: "${pageContext.request.contextPath}/common/push/read",
		type: "POST",
		cache: false,
		data: {
			"id" : id
		},
		beforeSend: function(xhr) {
			xhr.setRequestHeader(header, token)
		},
		success: function(data, status) {
			if(status == "success") {
				if(data == "Success") {
					if(type == 1 || type == 2) { // 게시판 댓글, 답글
						location.href = "${pageContext.request.contextPath}/community/board/view/" + boardId + "?broadcasterId=" + broadcasterId;
					} else if(type == 3) { // 민심평가 답글
						location.href = "${pageContext.request.contextPath}/community/review/" + broadcasterId;
					} else if(type == 4 || type == 5) { // 고객센터 댓글, 답글
						location.href = "${pageContext.request.contextPath}/customerService/" + broadcasterId;
					} else if(type == 6 || type == 7) { // 통합 게시판 댓글 ,답글
						location.href = "${pageContext.request.contextPath}/community/combine/view/" + boardId;
					}
				}
			}
		}
	});
}
function deletePush(id, deleteType) {
	var header = "${_csrf.headerName}";
	var token = "${_csrf.token}";
	if(deleteType == "one") {
		$.ajax({
			url: "${pageContext.request.contextPath}/common/push/delete",
			type: "POST",
			cache: false,
			data: {
				"id" : id,
				"deleteType" : deleteType
			},
			beforeSend: function(xhr) {
				xhr.setRequestHeader(header, token);
			},
			success: function(data, status) {
				if(status == "success") {
					if(data == "Success") {
						selectPushList();
					}
				}
			}
		});
	} else if(deleteType == "readOnly") {
		if(pushReadCount != 0) {
			$.ajax({
				url: "${pageContext.request.contextPath}/common/push/delete",
				type: "POST",
				cache: false,
				data: {
					"id" : id,
					"deleteType" : deleteType
				},
				beforeSend: function(xhr) {
					xhr.setRequestHeader(header, token);
				},
				success: function(data, status) {
					if(status == "success") {
						if(data == "Success") {
							selectPushList();
						}
					}
				}
			});
		}
	} else {
		if(pushCount != 0) {
			$.ajax({
				url: "${pageContext.request.contextPath}/common/push/delete",
				type: "POST",
				cache: false,
				data: {
					"id" : id,
					"deleteType" : deleteType
				},
				beforeSend: function(xhr) {
					xhr.setRequestHeader(header, token);
				},
				success: function(data, status) {
					if(status == "success") {
						if(data == "Success") {
							selectPushList();
						}
					}
				}
			});
		}
	}
}
function pushDateFormat(date) {
	var pushDate = new Date(date);
	
	var pushYear = pushDate.getFullYear();
	var pushMonth = pushDate.getMonth() + 1;
	pushMonth = (pushMonth + "").length==1? ("0" + pushMonth):pushMonth
	var pushDay = pushDate.getDate();
	pushDay = (pushDay + "").length==1? ("0" + pushDay):pushDay;
	var pushHour = pushDate.getHours();
	pushHour = (pushHour + "").length==1? ("0" + pushHour):pushHour;
	var pushMinute = pushDate.getMinutes();
	pushMinute = (pushMinute + "").length==1? ("0" + pushMinute):pushMinute;
	
	return pushYear + "-" + pushMonth + "-" + pushDay + " " + pushHour + ":" + pushMinute;
}
</script>
<!-- 최상단 헤더 -->
<div class="header-wrapper">
    <div class="header-inner">
        <div class="mobile-menu">
            <button class="aps-button mobile" onclick="sidebarToggle('.mobile-sidebar-panel');"><i class="fas fa-bars"></i></button>
        </div>
        <div class="logo">
            <a class="pc-logo" href="${pageContext.request.contextPath}/"><img src="${pageContext.request.contextPath}/resources/image/logo/header_logo.png"/></a>
            <a class="mobile-logo" href="${pageContext.request.contextPath}/"><img src="${pageContext.request.contextPath}/resources/image/logo/mobile_logo.png"/></a>
        </div>
        <div class="user">
            <button class="aps-button search" onclick="alert('준비 중인 기능입니다.');"><i class="fas fa-search"></i></button>
            <s:authorize access="!isAuthenticated()">
            	<button class="aps-button login" onclick="pageMove('login');"><i class="fas fa-sign-in-alt"></i></button>
            </s:authorize>
            <s:authorize access="isAuthenticated()">
            	<div class="menu">
            		<div class="user-push" onclick="headerToggle('.push-list');">
            			<i id="push-bell" class="fas fa-bell fa-2x"></i> <i class="fas fa-caret-down"></i>
            			<span id="push-count" class="push-count">0</span>
            			<ul id="push-list" class="push-list animated tdFadeInDown">
            				<li class="pl-head">
            					<div class="title">알림</div>
            					<div class="function">
            						<button class="push-button" onclick="deletePush('0','readOnly');">읽은 알림 삭제</button>
            						<button class="push-button" onclick="deletePush('0','all');">전체삭제</button>
            					</div>
            				</li>
              				<li id="pl-default" class="pl-default">
            				</li>
             				<li id="empty-push-list" class="empty-push-list">
            					<div class="info-circle"><i class="fas fa-info"></i></div>
            					<div class="text">알림이 없습니다.</div>
            				</li>
             				<li id="error-push-list" class="error-push-list">
            					<div class="info-circle"><i class="fas fa-exclamation-triangle"></i></div>
            					<div class="text">알 수 없는 오류입니다.</div>
            				</li>
            			</ul>
            		</div>
            		<div class="user-info" onclick="headerToggle('.menu-list');">
            			<c:if test="${empty sessionScope.profile}">
            				<i class="far fa-user fa-2x"></i>
            			</c:if>
            			<c:if test="${not empty sessionScope.profile}">
            				<img class="profile-img" src="https://kr.object.ncloudstorage.com/aps/profile/${sessionScope.profile}"/>
            			</c:if>
            			<i class="fas fa-caret-down"></i>
	            		<ul class="menu-list animated tdFadeInDown">
	            			<li class="ml-head">
	            				<div class="info">
	            					<c:choose>
	            						<c:when test="${sessionScope.userType == 10}">
	            							<span class="nickname">${sessionScope.nickname}</span><span class="master">M</span>
	            						</c:when>
	            						<c:otherwise>
	            							<span class="nickname">${sessionScope.nickname}</span><span class="level">Lv.${sessionScope.level}</span>
	            						</c:otherwise>
	            					</c:choose>
	            				</div>
	            			</li>
	            			<li class="ml-default" onclick="pageMove('mypage');"><i class="fas fa-user-edit"></i> 마이페이지</li>
	            			<li class="ml-default" onclick="pageMove('logout');"><i class="fas fa-sign-out-alt"></i> 로그아웃
	            				<form id="logout" action="<c:url value='/logout'/>" method="post">
	            					<s:csrfInput/>
	            				</form>
	            			</li>
	            		</ul>
            		</div>
            	</div>
            </s:authorize>
        </div>
    </div>
</div>
<!-- 네비게이션 -->
<div class="nav-wrapper">
    <div class="nav-inner">
        <ul class="nav-list">
            <li class="nl-default ${fn:indexOf(pageContext.request.requestURL += '', 'community') >= 0? 'active':''}" onclick="pageMove('community');"><div>커뮤니티</div></li>
            <li class="nl-default ${fn:indexOf(pageContext.request.requestURL += '', 'rank') >= 0? 'active':''}" onclick="pageMove('rank');"><div>민심순위</div></li>
            <li class="nl-default ${fn:indexOf(pageContext.request.requestURL += '', 'customerService') >= 0? 'active':''}" onclick="pageMove('notice');"><div>고객센터</div></li>
        </ul>
    </div>
</div>