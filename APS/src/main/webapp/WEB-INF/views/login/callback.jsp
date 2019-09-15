<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="s" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>소셜 로그인 : APS</title>
<jsp:include page="/resources/include/common/common_css.jsp"/>
<s:csrfMetaTags/>
</head>
<body>
<jsp:include page="/resources/include/common/common_js.jsp"/>
<script>
var header = $("meta[name='_csrf_header']").attr("content");
var token = $("meta[name='_csrf']").attr("content");
$(document).ready(function() {
	if("${status}" == "Success") {
		$.ajax({
			url: "${pageContext.request.contextPath}/join/input/socialUser",
			type: "POST",
			cache: false,
			data: {
				"username" : "${username}",
				"name" : "${name}",
				"email" : "${email}",
				"loginType" : "${loginType}"
			},
			beforeSend: function(xhr) {
				xhr.setRequestHeader(header, token);
			},
			success: function(data, status) {
				if(status == "success") {
					if(data.status == "Already Email") {
						opener.socialLogin(data.status);
					} else if(data.status == "Success") {
						opener.socialLogin(data.status + "," + data.username + "," + data.password);
					}
				}
				window.close();
			}
		});
	} else {
		modalToggle("#modal-type-4", "오류", "인증 오류가 발생하였습니다.");
		$("#modal-type-1 .aps-modal-header .close-button").attr("onclick", "window.close();");
		$("#modal-type-1 .aps-modal-footer .aps-modal-button").attr("onclick", "window.close();");
	}
});
</script>
<jsp:include page="/resources/include/modals.jsp"/>
</body>
</html>