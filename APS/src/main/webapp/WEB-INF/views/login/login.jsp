<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>로그인 : APS</title>
<jsp:include page="/resources/include/common/common_css.jsp"/>
<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/resources/css/include/common.css">
<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/resources/css/login/login.css">
</head>
<body>
<script type="text/javascript" src="https://static.nid.naver.com/js/naveridlogin_js_sdk_2.0.0.js" charset="utf-8"></script>
<jsp:include page="/resources/include/common/common_js.jsp"/>
<script>
$(document).ready(function() {
    resize_login();
    var errorMsg = "${errorMsg}";
    
    if(errorMsg.length > 0) {
    	modalToggle("#modal-type-1", "안내", errorMsg);
    }
});
$(window).resize(resize_login);
function resize_login() {
    var htmlHeight = $("html").height();
    
    $(".content-wrapper").css("min-height", htmlHeight + "px");    
}
// 로그인 유효성 검사
function validLogin(obj) {
	var username = obj["username"].value;
	var password = obj["password"].value;
	
	if(username == null || username.length == 0) {
		modalToggle("#modal-type-1", "안내", "아이디를 입력해주세요.");
		return false;
	}
	if(password == null || password.length == 0) {
		modalToggle("#modal-type-1", "안내", "비밀번호를 입력해주세요.");
		return false;
	}
}
function socialLogin(result) {
	var results = result.split(",");
	if(results == "Already Email") {
		modalToggle("#modal-type-1", "안내", "이미 가입된 이메일입니다.");
	} else if(results[0] == "Success") {
		var form = $("<form></form>");
		form.attr("action", "<c:url value='/loginOk'/>");
		form.attr("method", "post");
		form.append("<input type='hidden' id='username' name='username' value='" + results[1] + "' autocomplete='off'/>");
		form.append("<input type='hidden' id='password' name='password' value='" + results[2] + "' autocomplete='off'/>");
		form.append('<s:csrfInput/>');
		form.appendTo("body");
		form.submit();
	}
}
function socialLoginPopUp(url) {
	var pop = window.open(url, "pop", "width=600,height=600, scrollbars=yes, resizable=yes");
}
</script>
<!-- 로그인 Form -->
<div class="content-wrapper">
    <div class="content-inner">
        <div class="row">
            <div class="content-inner-left col-12 col-sm-12">
                <div class="logo-box">
                    <a href="${pageContext.request.contextPath}/"><img class="img-fluid" src="${pageContext.request.contextPath}/resources/image/logo/join_logo.png"></a>
                </div>
                <form id="loginForm" action="<c:url value='/loginOk'/>" method="post" onsubmit="return validLogin(this);">
	                <div class="input-box">
	                    <input type="text" id="username" name="username" placeholder="아이디" autocomplete="off"/>
	                </div>
	                <div class="input-box">
	                    <input type="password" id="password" name="password" placeholder="비밀번호" autocomplete="off"/>
	                </div>
	                <div class="input-box">
	                    <button class="aps-button">로그인</button>
	                </div>
	                <s:csrfInput/>
                </form>
                <div class="find-box">
                    <span onclick="pageMove('find');">아이디, 비밀번호 찾기</span> / <span onclick="pageMove('join');">회원가입</span>
                </div>
            </div>
            <div class="content-inner-right col-12 col-sm-12">
                <div class="social-wrapper">
	                <div class="title-box margin-top">간편하게 로그인해보세요!</div>
	                <div class="social-box margin-top">
	                    <!-- <div id="naverIdLogin"></div> -->
	                    <img class="social-login naver" onclick="socialLoginPopUp('${naverUrl}');" src="${pageContext.request.contextPath}/resources/image/icon/naver.PNG">
	                    <%-- <img class="social-login" src="${pageContext.request.contextPath}/resources/image/icon/facebook.png"/> --%>
	                    <img class="social-login" onclick="socialLoginPopUp('${googleUrl}');" src="${pageContext.request.contextPath}/resources/image/icon/google.png"/>
	                </div>
                </div>
            </div>
        </div>
    </div>
</div>
<jsp:include page="/resources/include/modals.jsp"/>
</body>
</html>