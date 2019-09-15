<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="s" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<s:csrfMetaTags/>
<title>아이디 찾기 : APS</title>
<jsp:include page="/resources/include/common/common_css.jsp"/>
<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/resources/css/include/common.css">
<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/resources/css/login/find.css">
</head>
<body>
<jsp:include page="/resources/include/common/common_js.jsp"/>
<script>
var header = $("meta[name='_csrf_header']").attr("content");
var token = $("meta[name='_csrf']").attr("content");
$(document).ready(function() {
    resize_find_username();
});
$(window).resize(resize_find_username);
function resize_find_username() {
    var htmlHeight = $("html").height();

    $(".content-wrapper").css("height", htmlHeight + "px");
}
function findUsername() {
	var name = $("#name").val();
	var email = $("#email").val();
	
	if(name == null || name.length == 0) {
		$(".confirmMsg").html("이름을 입력해주세요.");
		$(".confirmMsg").css("display", "block");
		return false;
	}
	if(email == null || email.length == 0) {
		$(".confirmMsg").html("이메일을 입력해주세요.");
		$(".confirmMsg").css("display", "block");
		return false;
	}
	
	$.ajax({
		url: "${pageContext.request.contextPath}/login/find/username",
		type: "POST",
		cache: false,
		data: {
			"name" : name,
			"email" : email
		},
		beforeSend: function(xhr) {
			xhr.setRequestHeader(header, token);
			$(".find-content-box .aps-button").html("<div class='spinner-border spinner-aps'></div>");
		},
		complete: function() {
			$(".find-content-box .aps-button").html("확인");
		},
		success: function(data, status) {
			if(status == "success") {
				if(data == "Success") {
					modalToggle("#modal-type-1", "안내", "회원님의 이메일로 아이디를 전송하였습니다.");
				} else {
					modalToggle("#modal-type-4", "오류", "존재하지 않는 회원정보입니다.");
				}
			}
		}
	});
}
</script>
<div class="content-wrapper">
    <div class="content-inner">
        <div class="content-inner-box">
            <div class="find-tab-box">
                <ul class="find-tab">
                    <li class="fl-default active" onclick="location.href='${pageContext.request.contextPath}/login/find/username'">아이디 찾기</li>
                    <li class="fl-default" onclick="location.href='${pageContext.request.contextPath}/login/find/password'">비밀번호 찾기</li>
                </ul>
            </div>
            <div class="find-content-box">
                <div class="input-box">
                    <input type="text" id="name" placeholder="이름" autocomplete="off"/>
                </div>
                <div class="input-box">
                    <input type="email" id="email" placeholder="이메일" autocomplete="off"/>
                </div>
                <label class="confirmMsg"></label>
                <button class="aps-button" onclick="findUsername();">확인</button>
            </div>
        </div>
    </div>
</div>
<jsp:include page="/resources/include/modals.jsp"/>
</body>
</html>