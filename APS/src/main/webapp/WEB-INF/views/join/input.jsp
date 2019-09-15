<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="s" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>회원가입 : APS</title>
<jsp:include page="/resources/include/common/common_css.jsp"/>
<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/resources/css/include/common.css">
<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/resources/css/join/input.css">
<s:csrfMetaTags/>
</head>
<body>
<jsp:include page="/resources/include/common/common_js.jsp"/>
<script>
var name_flag = false;
var username_flag = false;
var password_flag = false;
var password_confirm_flag = false;
var email_flag = false;
var email_access_flag = false;
var access_email;
var header = $("meta[name='_csrf_header']").attr("content");
var token = $("meta[name='_csrf']").attr("content");
// 이름 유효성 검사
function validName(obj) {
	var name = obj.value;
	var pattern = /^[가-힣]{2,4}$/;
	
	// Confirm 메시지 ON
	$(obj).parent(".input-data").parent(".input-box").find(".confirmMsg").addClass("on");
	
	if(new RegExp(pattern).test(name)) { // 정규식에 일치한다면
		$(obj).parent(".input-data").parent(".input-box").find(".confirmMsg").removeClass("invalid");
		$(obj).parent(".input-data").parent(".input-box").find(".confirmMsg").html("확인되었습니다.");
		name_flag = true;
	} else { // 정규식에 일치하지 않다면
		$(obj).parent(".input-data").parent(".input-box").find(".confirmMsg").addClass("invalid");
		$(obj).parent(".input-data").parent(".input-box").find(".confirmMsg").html("올바른 이름을 입력해주세요.");
		name_flag = false;
	}
}
// 아이디 유효성 검사
function validUsername(obj) {
	var username = obj.value;
	var pattern = /^([a-zA-Z\d]{5,10})$/;
	
	// Confirm 메시지 ON
	$(obj).parent(".input-data").parent(".input-box").find(".confirmMsg").addClass("on");
	
	if(new RegExp(pattern).test(username)) { // 정규식에 일치한다면
		$.ajax({ // 아이디 중복확인
			url: "${pageContext.request.contextPath}/join/input/overlap",
			type : "POST",
			cache: false,
			data: {
				"value" : username,
				"type" : "username"
			},
			beforeSend: function(xhr) {
				xhr.setRequestHeader(header, token);
			},
			success: function(data, status) {
				if(status == "success") {
					if(data == "Success") {
						$(obj).parent(".input-data").parent(".input-box").find(".confirmMsg").removeClass("invalid");
						$(obj).parent(".input-data").parent(".input-box").find(".confirmMsg").html("사용 가능한 아이디입니다.");
						username_flag = true;
					} else {
						$(obj).parent(".input-data").parent(".input-box").find(".confirmMsg").addClass("invalid");
						$(obj).parent(".input-data").parent(".input-box").find(".confirmMsg").html("이미 사용 중인 아이디입니다.");
						username_flag = false;
					}
				}
			}
		});
	} else { // 정규식에 일치하지 않다면
		$(obj).parent(".input-data").parent(".input-box").find(".confirmMsg").addClass("invalid");
		$(obj).parent(".input-data").parent(".input-box").find(".confirmMsg").html("영문 또는 숫자 5자 이상 10자 이하로 입력해주세요.");
		username_flag = false;
	}
}
// 비밀번호 유효성 검사
function validPassword(obj) {
	var password = obj.value;
	var pattern = /^(?=.*\d)(?=.*\W)(?=.*[a-zA-Z]).{8,20}$/;
	
	// Confirm 메시지 ON
	$(obj).parent(".input-data").parent(".input-box").find(".confirmMsg").addClass("on");
	
	if(new RegExp(pattern).test(password)) { // 정규식에 일치한다면
		$(obj).parent(".input-data").parent(".input-box").find(".confirmMsg").removeClass("invalid");
		$(obj).parent(".input-data").parent(".input-box").find(".confirmMsg").html("사용 가능한 비밀번호입니다.");
		password_flag = true;
	} else { // 정규식에 일치하지 않다면
		$(obj).parent(".input-data").parent(".input-box").find(".confirmMsg").addClass("invalid");
		$(obj).parent(".input-data").parent(".input-box").find(".confirmMsg").html("영문, 숫자, 특수문자 포함 8자 이상 20자 이하로 입력해주세요.");
		password_flag = false;
	}
}
// 비밀번호 확인 유효성 검사
function validPasswordConfirm(obj) {
	var password = $("#password").val();
	var password_confirm = obj.value;
	var pattern = /^(?=.*\d)(?=.*\W)(?=.*[a-zA-Z]).{8,20}$/;
	
	// Confirm 메시지 ON
	$(obj).parent(".input-data").parent(".input-box").find(".confirmMsg").addClass("on");
	
	if(password == password_confirm && new RegExp(pattern).test(password_confirm)) { // 1차로 입력한 비밀번호와 정규식에 일치하다면
		$(obj).parent(".input-data").parent(".input-box").find(".confirmMsg").removeClass("invalid");
		$(obj).parent(".input-data").parent(".input-box").find(".confirmMsg").html("비밀번호가 일치합니다.");
		password_confirm_flag = true;
	} else { // 정규식에 일치하지 않다면
		$(obj).parent(".input-data").parent(".input-box").find(".confirmMsg").addClass("invalid");
		$(obj).parent(".input-data").parent(".input-box").find(".confirmMsg").html("비밀번호가 일치하지 않거나 올바르지 않습니다.");
		password_confirm_flag = false;
	}
}
// 이메일 유효성 검사
function validEmail(obj) {
	var email = obj.value;
	var pattern = /^(([a-zA-Z\d][-_]?){3,15})@([a-zA-z\d]{5,15})\.([a-z]{2,3})$/;
	
	// Confirm 메시지 ON
	$(obj).parent(".input-data").parent(".input-box").find(".confirmMsg").addClass("on");
	
	if(new RegExp(pattern).test(email)) { // 정규식에 일치한다면
		$.ajax({ // 이메일 중복확인
			url: "${pageContext.request.contextPath}/join/input/overlap",
			type : "POST",
			cache: false,
			data: {
				"value" : email,
				"type" : "email"
			},
			beforeSend: function(xhr) {
				xhr.setRequestHeader(header, token);
			},
			success: function(data, status) {
				if(status == "success") {
					if(data == "Success") {
						$(obj).parent(".input-data").parent(".input-box").find(".confirmMsg").removeClass("invalid");
						$(obj).parent(".input-data").parent(".input-box").find(".confirmMsg").html("사용 가능한 이메일입니다.");
						email_flag = true;
					} else {
						$(obj).parent(".input-data").parent(".input-box").find(".confirmMsg").addClass("invalid");
						$(obj).parent(".input-data").parent(".input-box").find(".confirmMsg").html("이미 가입된 이메일입니다.");
						email_flag = false;
					}
				}
			}
		});
		$(obj).parent(".input-data").parent(".input-box").find(".confirmMsg").removeClass("invalid");
		$(obj).parent(".input-data").parent(".input-box").find(".confirmMsg").html("사용 가능한 이메일입니다.");
		email_flag = true;
	} else { // 정규식에 일치하지 않다면
		$(obj).parent(".input-data").parent(".input-box").find(".confirmMsg").addClass("invalid");
		$(obj).parent(".input-data").parent(".input-box").find(".confirmMsg").html("이메일 형식이 올바르지 않습니다.");
		email_flag = false;
	}
}
// 이메일 인증 요청
function requestEmailAccess(obj) {
	if(email_flag) {
		/* $(obj).html("<div class='spinner-border spinner-aps'></div>"); */
		$(obj).html('<div class="spinner"><div class="bounce1"></div><div class="bounce2"></div><div class="bounce3"></div></div>');
		modalToggle("#modal-type-3");
		$("#email").attr("disabled", "disabled");
		$.ajax({
			url: "${pageContext.request.contextPath}/join/input/emailAccess",
			type: "POST",
			cache: false,
			data: {
				"email" : $("#email").val()
			},
			beforeSend: function(xhr) {
				xhr.setRequestHeader(header, token);
			},
			success: function(data, status) {
				if(status == "success") {
					if(data == "Fail") {
						modalToggle("#modal-type-4", "오류", "이메일 전송에 실패하였습니다.");
					} else {
						$("#modal-type-3 .aps-modal-footer .aps-modal-button").attr("onclick", "requestEmailAccessOk(" + data + ");");
					}
				}
			}
		});
	} else {
		modalToggle("#modal-type-1", "안내", "올바른 이메일을 입력해주세요.");
	}
}
// 이메일 인증 재요청
function retryEmailAccess() {
	$.ajax({
		url: "${pageContext.request.contextPath}/join/input/emailAccess",
		type: "POST",
		cache: false,
		data: {
			"email" : $("#email").val()
		},
		beforeSend: function(xhr) {
			$(".re-access-button i").css("color", "#0545B1");
			$(".re-access-button i").css("transform", "rotate(360deg)");
			xhr.setRequestHeader(header, token);
		},
		complete: function() {
			$(".re-access-button i").css("transform", "rotate(-360deg)");
			$(".re-access-button i").css("color", "gray");
		},
		success: function(data, status) {
			if(status == "success") {
				if(data == "Fail") {
					modalToggle("#modal-type-4", "오류", "이메일 전송에 실패하였습니다.");
				} else {
					$("#modal-type-3 .aps-modal-footer .aps-modal-button").attr("onclick", "requestEmailAccessOk(" + data + ");");
				}
			}
		}
	});
}
// 이메일 인증키 확인 요청
function requestEmailAccessOk(id) {
	var accesskey = $("#email_accesskey").val();
	
	if(accesskey != null && accesskey.length != 0) {
		$.ajax({
			url: "${pageContext.request.contextPath}/join/input/emailAccessOk",
			type: "POST",
			cache: false,
			data: {
				"id" : id,
				"accesskey" : accesskey
			},
			beforeSend: function(xhr) {
				xhr.setRequestHeader(header, token);
			},
			success: function(data, status) {
				if(status == "success") {
					if(data == "Success") {
						$(".access-button").html("<i class='fas fa-check fa-2x'></i>");
						$(".access-button").removeAttr("onclick");
						modalToggle("#modal-type-3");
						email_access_flag = true;
						access_email = $("#email").val();
					} else {
						$("#modal-type-3 .body-text .confirmMsg").css("display", "inline-block");
						email_access_flag = false;
					}
				}
			}
		});
	}
}
// 회원가입
function requestJoin() {
	validName(document.getElementById("name")); validUsername(document.getElementById("username")); validPassword(document.getElementById("password"));
	validPasswordConfirm(document.getElementById("password_confirm")); validEmail(document.getElementById("email"));
	if(name_flag && username_flag && password_flag && password_confirm_flag && email_flag && email_access_flag) {
		$.ajax({
			url: "${pageContext.request.contextPath}/join/input/user",
			type: "POST",
			cache: false,
			data: {
				"name" : $("#name").val(),
				"username" : $("#username").val(),
				"password" : $("#password_confirm").val(),
				"email" : access_email
			},
			beforeSend: function(xhr) {
				xhr.setRequestHeader(header, token);
			},
			success: function(data, status) {
				if(status == "success") {
					if(data == "Success") {
						modalToggle("#modal-type-1", "안내", "가입되었습니다.");
						$("#modal-type-1 .aps-modal-header .close-button").attr("onclick", "location.href='${pageContext.request.contextPath}/login'");
						$("#modal-type-1 .aps-modal-footer .aps-modal-button").attr("onclick", "location.href='${pageContext.request.contextPath}/login'");    
					} else {
						modalToggle("#modal-type-4", "오류", "가입에 실패하였습니다.");
					}
				}
			}
		});
	} else {
		modalToggle("#modal-type-1", "안내", "입력한 정보를 다시 한번 확인해주세요.");
	}
}
</script>
<!-- 회원가입 정보입력 -->
<div class="content-wrapper">
    <div class="content-inner">
        <div class="content-inner-box">
            <div class="join-logo">
                <a href="${pageContext.request.contextPath}/"><img class="img-fluid" src="${pageContext.request.contextPath}/resources/image/logo/join_logo.png"/></a>
            </div>
            <div class="join-content">
                <div class="input-box">
                    <div class="input-title">이름</div>
                    <div class="input-data">
                        <input type="text" id="name" onkeyup="validName(this);"/>
                    </div>
                    <label class="confirmMsg">확인되었습니다.</label>
                </div>
                <div class="input-box">
                    <div class="input-title">아이디</div>
                    <div class="input-data">
                        <input type="text" id="username" onkeyup="validUsername(this);"/>
                    </div>
                    <label class="confirmMsg">확인되었습니다.</label>
                </div>
                <div class="input-box">
                    <div class="input-title">비밀번호</div>
                    <div class="input-data">
                        <input type="password" id="password" onkeyup="validPassword(this);"/>
                    </div>
                    <label class="confirmMsg">확인되었습니다.</label>
                </div>
                <div class="input-box">
                    <div class="input-title">비밀번호 재확인</div>
                    <div class="input-data">
                        <input type="password" id="password_confirm" onkeyup="validPasswordConfirm(this);"/>
                    </div>
                    <label class="confirmMsg">확인되었습니다.</label>
                </div>
                <div class="input-box">
                    <div class="input-title">본인확인 이메일</div>
                    <div class="input-data email">
                        <input type="email" id="email" onkeyup="validEmail(this);"/><button class="access-button" onclick="requestEmailAccess(this);">인증요청</button>
                    </div>
                    <label class="confirmMsg">확인되었습니다.</label>
                </div>
            </div>
            <button class="aps-button" onclick="requestJoin();">가입</button>
			<jsp:include page="/resources/include/footer.jsp"/>
        </div>
    </div>
</div>
<jsp:include page="/resources/include/modals.jsp"/>
</body>
</html>