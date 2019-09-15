<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" uri="http://www.springframework.org/security/tags" %>
<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/resources/css/include/mobile/sidebar.css">
<script>
function mobileMenuToggle(obj, type) {
	$(type).toggle();
	if($(obj).attr("class").indexOf("active") > 0) {
		$(obj).removeClass("active");
	} else {
		$(obj).addClass("active");
	}
}
</script>
<!-- 모바일 사이드바 -->
<div class="mobile-sidebar-panel" onclick="sidebarToggle('.mobile-sidebar-panel');">
    <div class="sidebar-wrapper animated fadeInLeftBig">
        <div class="sidebar-inner">
            <div class="login-box">
                <div class="m-login-button">
                	<s:authorize access="!isAuthenticated()">
                		<a onclick="pageMove('login');"><i class="fas fa-sign-in-alt"></i> 로그인</a>
                	</s:authorize>
                	<s:authorize access="isAuthenticated()">
                		${sessionScope.nickname}
                	</s:authorize>
                </div>
                <div class="m-close-button" onclick="sidebarToggle('.mobile-sidebar-panel');">
                    <i class="fas fa-times"></i>
                </div>
            </div>
            <s:authorize access="isAuthenticated()">
	            <div class="profile-box">
	            	<c:choose>
	            		<c:when test="${not empty sessionScope.profile}">
			            	<div class="profile-img">
			            		<img class="img-fluid" src="https://kr.object.ncloudstorage.com/aps/profile/${sessionScope.profile}"/>
			            	</div>
	            		</c:when>
	            		<c:otherwise>
	            			<i class="far fa-user fa-5x"></i>
	            		</c:otherwise>
	            	</c:choose>
	            	<div class="other-box">
	            		<c:choose>
	            			<c:when test="${sessionScope.userType == 10}">
	            				<div class="master">M</div>
	            			</c:when>
	            			<c:otherwise>
	            				<div class="level">Lv.${sessionScope.level}</div>
	            			</c:otherwise>
	            		</c:choose>
	            	</div>
	            </div>
	            <div class="myinfo-box">
	                <div class="container">
	                    <div class="row">
	                        <div class="myinfo-list col-3 col-sm-3" onclick="pageMove('mypage');">
	                            <div><i class="fas fa-user-edit fa-2x"></i></div>
	                            <div class="name mypage">마이페이지</div>
	                        </div>
	                        <div class="myinfo-list col-3 col-sm-3" onclick="mobileMenuToggle(this,'.push-box');">
	                            <div class="mobile-user-push">
	                            	<i id="mobile-push-bell" class="fas fa-bell fa-2x">
	                            		<span id="mobile-push-count" class="push-count">0</span>
	                            	</i>
	                            </div>
	                            <div class="name">알림</div>
	                        </div>
	                        <div class="myinfo-list col-3 col-sm-3" onclick="pageMove('logout');">
	                            <div><i class="fas fa-sign-in-alt fa-2x"></i></div>
	                            <div class="name">로그아웃</div>
	                        </div>
	                        <div class="myinfo-list last-myinfo col-3 col-sm-3">
	                            <div><i class="far fa-comment-alt fa-2x"></i></div>
	                            <div class="name">준비 중</div>
	                        </div>
	                    </div>
	                </div>
	            </div>
	            <div class="push-box">
            		<ul id="mobile-push-list" class="push-list animated tdFadeInDown">
            			<li class="pl-head">
            				<div class="title">알림</div>
            				<div class="function">
            					<button class="push-button" onclick="deletePush('0','readOnly');">읽은 알림 삭제</button>
            					<button class="push-button" onclick="deletePush('0','all');">전체삭제</button>
            				</div>
            			</li>
              			<li id="mobile-pl-default" class="pl-default">
            			</li>
             			<li id="mobile-empty-push-list" class="empty-push-list">
            				<div class="info-circle"><i class="fas fa-info"></i></div>
            				<div class="text">알림이 없습니다.</div>
            			</li>
             			<li id="mobile-error-push-list" class="error-push-list">
            				<div class="info-circle"><i class="fas fa-exclamation-triangle"></i></div>
            				<div class="text">알 수 없는 오류입니다.</div>
            			</li>
            		</ul>
	            </div>
            </s:authorize>
            <s:authorize access="!isAuthenticated()">
             	<div class="m-not-authenticated">
            		<div class="m-info-circle"><i class="fas fa-info"></i></div>
            		<div class="m-text">로그인이 필요합니다.</div>
            	</div>
            </s:authorize>
            <div class="nav-box">
                <div class="container">
                    <div class="nav-title">
                    	<i class="fas fa-list"></i> 전체메뉴
                    </div>
                    <div class="row">
                        <div class="nav-list col-12 col-sm-4" onclick="pageMove('community');">커뮤니티</div>
                        <div class="nav-list col-12 col-sm-4" onclick="pageMove('rank');">민심순위</div>
                        <div class="nav-list last-nav col-12 col-sm-4" onclick="pageMove('notice');">고객센터</div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>