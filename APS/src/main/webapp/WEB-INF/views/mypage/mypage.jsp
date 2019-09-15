<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>마이페이지 : APS</title>
<jsp:include page="/resources/include/common/common_css.jsp"/>
<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/resources/css/include/common.css">
<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/resources/css/mypage/mypage.css">
<s:csrfMetaTags/>
<!-- Global site tag (gtag.js) - Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=UA-145699819-1"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());

  gtag('config', 'UA-145699819-1');
</script>
</head>
<body>
<jsp:include page="/resources/include/common/common_js.jsp"/>
<jsp:include page="/resources/include/header.jsp"/>
<script>
var header = $("meta[name='_csrf_header']").attr("content");
var token = $("meta[name='_csrf']").attr("content");
$(document).ready(function() {
    resize_mypage();
    $('[data-toggle="recommend-count-tooltip"]').tooltip();
    if($("${not empty result}" == "true")) {
    	var result = "${result}";
    	if(result == "Success") {
			modalToggle("#modal-type-1", "안내", "변경되었습니다.");
			$("#modal-type-1 .aps-modal-header .close-button").attr("onclick", "location.href='${pageContext.request.contextPath}/mypage'");
			$("#modal-type-1 .aps-modal-footer .aps-modal-button").attr("onclick", "location.href='${pageContext.request.contextPath}/mypage'");
    	} else if(result == "Not Exist") {
			modalToggle("#modal-type-1", "안내", "현재 비밀번호가 올바르지 않습니다.");
			$("#modal-type-1 .aps-modal-header .close-button").attr("onclick", "location.href='${pageContext.request.contextPath}/mypage'");
			$("#modal-type-1 .aps-modal-footer .aps-modal-button").attr("onclick", "location.href='${pageContext.request.contextPath}/mypage'");    		
    	} else if(result == "Same") {
			modalToggle("#modal-type-1", "안내", "이전 비밀번호와 동일하게 변경할 수 없습니다.");
			$("#modal-type-1 .aps-modal-header .close-button").attr("onclick", "location.href='${pageContext.request.contextPath}/mypage'");
			$("#modal-type-1 .aps-modal-footer .aps-modal-button").attr("onclick", "location.href='${pageContext.request.contextPath}/mypage'");    		
    	} else if(result == "Fail") {
    		modalToggle("#modal-type-4", "오류", "알 수 없는 오류입니다.");
    		$("#modal-type-4 .aps-modal-header .close-button").attr("onclick", "location.href='${pageContext.request.contextPath}/mypage'");
    		$("#modal-type-4 .aps-modal-footer .aps-modal-button").attr("onclick", "location.href='${pageContext.request.contextPath}/mypage'");
    	}
    }
    
    thumbsCountFormat();
});
$(window).resize(resize_mypage);
function resize_mypage() {
    var htmlHeight = $("html").height();
    var headerHeight = $(".header-wrapper").height();
    var navHeight = $(".nav-wrapper").height();
    var footerHeight = $(".footer-wrapper").height();
    
    $(".content-wrapper").css("min-height", htmlHeight - headerHeight - navHeight - footerHeight - 3 + "px");
}
function thumbsCountFormat() {
	var currentLevel = "${user.level}";
	var thumbsCount = "${user.exp}";
	var userType = "${user.type}";
	
	if(userType != 10) {
		var levelUpdateStandard = 20;
		var percentage = 0;
		
		if(currentLevel != 0) {
			percentage = Math.floor((thumbsCount/((currentLevel * currentLevel) * levelUpdateStandard)) * 100);
			percentage = percentage>100? 100:percentage;
		}
		
		$("#current-thumbs-count").animate({width:percentage + "%"}, 500, function(){$("#current-thumbs-count").html(percentage + "%");});
	} else {
		$("#current-thumbs-count").animate({width:"100%"}, 500, function(){$("#current-thumbs-count").html("100%");});
	}
}
function modifyNickname(nickname) {
	var nickname = nickname.val();
	var pattern_spc = /^[0-9|a-z|A-Z|ㄱ-ㅎ|ㅏ-ㅣ|가-힝]*$/;
	var pattern_con = /^.*[ㄱ-ㅎㅏ-ㅣ]+.*$/;
	
	if(nickname == null || nickname.length < 2 || nickname.length > 6) {
		modalToggle("#modal-type-1", "안내", "닉네임은 2자 이상 6자 이하로 입력해주세요.");
		return false;
	} else {
		if(!new RegExp(pattern_spc).test(nickname)) {
			modalToggle("#modal-type-1", "안내", "닉네임에 특수문자는 포함할 수 없습니다.");	
			return false;
		} else if(new RegExp(pattern_con).test(nickname)) {
			modalToggle("#modal-type-1", "안내", "닉네임을 자음 또는 모음으로 설정할 수 없습니다.");	
			return false;
		} else {
			$.ajax({
				url: "${pageContext.request.contextPath}/mypage/modify/nickname",
				type: "POST",
				cache: false,
				data: {
					"nickname" : nickname
				},
				beforeSend: function(xhr) {
					xhr.setRequestHeader(header, token);
				},
				success: function(data, status) {
					if(status == "success") {
						if(data == "Success") {
							modalToggle("#modal-type-1", "안내", "수정되었습니다.");
							$("#modal-type-1 .aps-modal-header .close-button").attr("onclick", "location.reload();");
							$("#modal-type-1 .aps-modal-footer .aps-modal-button").attr("onclick", "location.reload();");
						} else if(data == "Ban") {
							modalToggle("#modal-type-1", "안내", "금지된 단어가 포함되어있습니다.");						
						} else {
							modalToggle("#modal-type-4", "오류", "알 수 없는 오류입니다.");
						}
					}
				},
				error: function() {
					modalToggle("#modal-type-4", "오류", "알 수 없는 오류입니다.");
				}
			});
		}
	}
}
function modifyProfileImage(obj) {
	var fileName = obj.files[0].name;
	var fileSize = obj.files[0].size;
	var maxPostSize = 3 * 1024 * 1024;
	var ext = fileName.substr(fileName.lastIndexOf(".")+1 , fileName.length);
	
	if(fileSize > maxPostSize) {
		modalToggle("#modal-type-1", "안내", "3MB 이하의 이미지 파일만 등록 가능합니다.");
		return false;
	} else if(!($.inArray(ext.toLowerCase(), ["jpg", "jpeg", "jpe", "png", "gif"]) >= 0)) {
		modalToggle("#modal-type-1", "안내", "허용되지 않은 파일 확장자입니다.");
		return false;
	}
	
	var formData = new FormData();
	formData.append("file", obj.files[0]);
	
	$.ajax({
		url: "${pageContext.request.contextPath}/mypage/modify/profileImage",
		type: "POST",
		cache: false,
		processData: false,
		contentType: false,
		data: formData,
		beforeSend: function(xhr) {
			xhr.setRequestHeader(header, token);
		},
		success: function(data, status) {
			if(status == "success") {
				if(data == "Success") {
					modalToggle("#modal-type-1", "안내", "수정되었습니다.");
					$("#modal-type-1 .aps-modal-header .close-button").attr("onclick", "location.reload();");
					$("#modal-type-1 .aps-modal-footer .aps-modal-button").attr("onclick", "location.reload();");
				} else {
					modalToggle("#modal-type-4", "오류", "알 수 없는 오류입니다.");					
				}
			}
		},
		error: function() {
			modalToggle("#modal-type-4", "오류", "알 수 없는 오류입니다.");
		}
	});
}
function modifyPassword(obj) {
	var currentPassword = obj["currentPassword"].value;
	var newPassword = obj["newPassword"].value;
	var newPasswordCheck = obj["newPasswordCheck"].value;
	
	var pattern = /^(?=.*\d)(?=.*\W)(?=.*[a-zA-Z]).{8,20}$/;
	
	if(currentPassword == null || currentPassword.length == 0) {
		modalToggle("#modal-type-1", "안내", "현재 비밀번호를 입력해주세요.");
		return false;
	}
	
	if(!new RegExp(pattern).test(newPassword)) {
		modalToggle("#modal-type-1", "안내", "새 비밀번호 입력이 올바르지 않습니다.");
		return false;		
	}
	if(!new RegExp(pattern).test(newPasswordCheck) || newPassword != newPasswordCheck) {
		modalToggle("#modal-type-1", "안내", "새 비밀번호 입력이 일치하지 않거나 올바르지 않습니다.");
		return false;
	}
}
function mypageMove(type) {
	if(type == "yet") {
		modalToggle("#modal-type-1", "안내", "준비 중인 기능입니다.");
	} else {
		location.href = "mypage/leave";
	}
}
</script>
<!-- 마이페이지 -->
<div class="content-wrapper">
    <div class="content-inner">
        <div class="content-inner-box">
            <div class="container">
                <div class="row">
                    <div class="level-box">
                    	<c:choose>
                    		<c:when test="${user.type == 10}">
		                        <div class="current-level">
		                            <div class="master">M</div>
		                            <i class="fas fa-arrow-alt-circle-right"></i>
		                            <div class="master">M</div>
		                        </div>
		                        <div class="aps-progress-bar">
		                            <div id="current-thumbs-count" class="current-thumbs" data-toggle="recommend-count-tooltip" data-placement="top" title="0 / 0">&nbsp;</div>
		<%--                             <div id="current-thumbs-count" class="current-thumbs">${(user.exp/(user.level * 20)) * 100}%</div> --%>
		                        </div>
                    		</c:when>
                    		<c:otherwise>
		                        <div class="current-level">
		                            <div class="level">
		                                lv.${user.level}
		                            </div>
		                            <i class="fas fa-arrow-alt-circle-right"></i>
		                            <div class="level next">
		                                lv.${user.level + 1}
		                            </div>
		                        </div>
		                        <div class="aps-progress-bar">
		                            <div id="current-thumbs-count" class="current-thumbs" data-toggle="recommend-count-tooltip" data-placement="top" title="${user.exp} / ${(user.level==0? (user.level+1):(user.level * user.level)) * 20}">&nbsp;</div>
		<%--                             <div id="current-thumbs-count" class="current-thumbs">${(user.exp/(user.level * 20)) * 100}%</div> --%>
		                        </div>                    		
                    		</c:otherwise>
                    	</c:choose>
                    </div>
                </div>
                <hr>
                <div class="row">
                    <div class="card-box col-12 col-sm-6 col-md-4">
                        <div class="card">
                            <div class="title"><i class="fas fa-user-edit"></i> 프로필 수정</div>
                            <div class="content">
                                <div class="row">
                                    <div class="profile-box col-12">
                                        <div class="profile-img">
                                        	<c:choose>
                                        		<c:when test="${not empty sessionScope.profile}">
                                            		<img class="img-fluid" src="https://kr.object.ncloudstorage.com/aps/profile/${sessionScope.profile}"/>
                                        		</c:when>
                                        		<c:otherwise>      		
                                            		<i class="far fa-user fa-4x"></i>
                                        		</c:otherwise>
                                        	</c:choose>
                                            <i class="fas fa-cog" onclick="$('#profile-img-modify').click();"></i>
                            				<input type="file" id="profile-img-modify" style="display: none;" onchange="modifyProfileImage(this);"/>
                                        </div>
                                    </div>
                                    <div class="profile-box col-12">
                                        <div class="input-box">
                                            <div class="input">
                                                <input type="text" id="nickname" value="${user.nickname}" placeholder="닉네임"/>
                                            </div>
                                            <div class="button">
                                                <button class="aps-button" onclick="modifyNickname($('#nickname'));">수정</button>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="card-box col-12 col-sm-6 col-md-4">
                        <div class="card">
                            <div class="title"><i class="fas fa-user-shield"></i> 개인정보</div>
                            <div class="content">
                                <table class="info-table">
                                    <tr>
                                        <td class="td-head">이름</td><td class="td-default">${user.name}</td>
                                    </tr>
                                    <c:if test="${user.type == 1}">
	                                    <tr>
	                                        <td class="td-head">아이디</td><td class="td-default">${user.username}</td>
	                                    </tr>
                                    </c:if>
                                    <tr>
                                        <td class="td-head">이메일</td><td class="td-default">${user.email}</td>
                                    </tr>
                                    <c:if test="${user.type >= 2}">
	                                    <tr>
	                                    	<c:choose>
	                                    		<c:when test="${user.type == 2}">
	                                        		<td class="td-head">타입</td><td class="td-default">네이버</td>
	                                    		</c:when>
	                                    		<c:when test="${user.type == 3}">
	                                    			<td class="td-head">타입</td><td class="td-default">구글</td>
	                                    		</c:when>
	                                    		<c:when test="${user.type == 10}">
	                                    			<td class="td-head">타입</td><td class="td-default">관리자</td>
	                                    		</c:when>
	                                        </c:choose>
	                                    </tr>
                                    </c:if>
                                </table>
                            </div>
                        </div>
                    </div>
                    <c:if test="${user.type == 1}">
	                    <div class="card-box col-12 col-sm-6 col-md-4">
	                        <div class="card">
	                            <div class="title"><i class="fas fa-lock"></i> 비밀번호 변경</div>
	                            <div class="content">
	                                <form action="mypage/modify/password" method="post" onsubmit="return modifyPassword(this);">
	                                    <div class="input-box">
	                                        <input type="password" id="currentPassword" name="currentPassword" placeholder="현재 비밀번호" autocomplete="off"/>
	                                        <input type="password" id="newPassword" name="newPassword" placeholder="새 비밀번호" autocomplete="off"/>
	                                        <input type="password" id="newPasswordCheck" name="newPasswordCheck" placeholder="새 비밀번호 확인" autocomplete="off"/>
	                                        <s:csrfInput/>
	                                    </div>
	                                    <button type="submit" class="change-button">변경</button>
	                                </form>
	                            </div>
	                        </div>
	                    </div>
                    </c:if>
                    <div class="card-box col-12 col-sm-6 col-md-4">
                        <div class="card yet" onclick="mypageMove('yet');">
                            <div class="title"><i class="fas fa-chart-bar"></i> 통계</div>
                        </div>
                    </div>
                    <div class="card-box col-12 col-sm-6 col-md-4">
                        <div class="card yet" onclick="mypageMove('yet');">
                            <div class="title"><i class="fas fa-user-cog"></i> 글 관리</div>
                        </div>
                    </div>
                    <div class="card-box col-12 col-sm-6 col-md-4">
                        <div class="card yet" onclick="mypageMove('leave');">
                            <div class="title"><i class="fas fa-door-open"></i> 회원탈퇴</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<jsp:include page="/resources/include/footer.jsp"/>
<jsp:include page="/resources/include/mobile/sidebar.jsp"/>
<jsp:include page="/resources/include/modals.jsp"/>
</body>
</html>