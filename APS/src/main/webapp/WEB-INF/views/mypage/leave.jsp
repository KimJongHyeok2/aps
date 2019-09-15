<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="s" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>회원탈퇴 : APS</title>
<jsp:include page="/resources/include/common/common_css.jsp"/>
<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/resources/css/include/common.css">
<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/resources/css/mypage/leave.css">
</head>
<body>
<jsp:include page="/resources/include/common/common_js.jsp"/>
<jsp:include page="/resources/include/header.jsp"/>
<script>
$(document).ready(function() {
	resize_mypage_leave();
});
$(window).resize(resize_mypage_leave);
function resize_mypage_leave() {
    var htmlHeight = $("html").height();
    var headerHeight = $(".header-wrapper").height();
    var navHeight = $(".nav-wrapper").height();
    var footerHeight = $(".footer-wrapper").height();
    
    $(".content-wrapper").css("min-height", htmlHeight - headerHeight - navHeight - footerHeight - 3 + "px");
}
function checkPolicy(obj) {
	$("#policy").click();
	
	if($("input[type='checkbox'][id='policy']").is(":checked")) {
		$(obj).addClass("active");
	} else {
		$(obj).removeClass("active");		
	}
}
function validPolicy() {
	if(!($("input[type='checkbox'][id='policy']").is(":checked"))) {
		modalToggle("#modal-type-1", "안내", "주의사항을 모두 확인하신 후 동의하셔야 합니다.");
		return false;
	}
}
</script>
<div class="content-wrapper">
    <div class="content-inner">
        <div class="content-inner-box">
        	<div class="title">
        		<div class="info-circle"><i class="far fa-list-alt fa-3x"></i></div>
        		<div class="text">회원탈퇴 주의사항</div>
        	</div>
        	<div class="content">
        		<ul class="check-list">
        			<li class="cl-default">
        				<i class="fas fa-check"></i> 회원정보 및 서비스 이용 기록
        				<ul>
        					<li>내부 방침(회원탈퇴일로부터 30일 보유) 또는 관계법령에 따라 명시된 기간 동안 보관된 후 영구적으로 삭제됩니다.</li>
        				</ul>
        			</li>
        			<li class="cl-default">
        				<i class="fas fa-check"></i> 작성한 모든 게시글 및 댓글/답글
        				<ul>
        					<li>내부 방침(회원탈퇴일로부터 30일 보유) 또는 관계법령에 따라 명시된 기간 동안 보관된 후 영구적으로 삭제됩니다.</li>
        				</ul>
        			</li>
        			<li class="cl-default">
        				<i class="fas fa-check"></i>  회원탈퇴 취소
        				<ul>
        					<li>회원탈퇴 후 30일 이내 로그인 시 회원탈퇴가 자동으로 취소됩니다.</li>
        				</ul>
        			</li>
        		</ul>
        	</div>
        	<form action="leaveOk" method="post" onsubmit="return validPolicy();">
	        	<div class="function">
	        		<div class="policy" onclick="checkPolicy(this);"><label class="policy-label"><i class="fas fa-check"></i></label> 모두 확인하였으며 동의합니다.</div>
	        		<input type="checkbox" id="policy" name="policy" class="policy-checkbox"/>
	        		<s:csrfInput/>
	        	</div>
	        	<div class="button">
	        		<button type="submit" class="aps-button">탈퇴하기</button>
	        	</div>
        	</form>
        </div>
    </div>
</div>
<jsp:include page="/resources/include/footer.jsp"/>
<jsp:include page="/resources/include/mobile/sidebar.jsp"/>
<jsp:include page="/resources/include/modals.jsp"/>
</body>
</html>