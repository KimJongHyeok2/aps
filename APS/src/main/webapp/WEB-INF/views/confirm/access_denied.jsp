<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>아프리카 민심 : APS</title>
<meta http-equiv="refresh" content="3;https://afreecaps.com"/>
<jsp:include page="/resources/include/common/common_css.jsp"/>
<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/resources/css/include/common.css">
<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/resources/css/confirm.css">
</head>
<body>
<jsp:include page="/resources/include/common/common_js.jsp"/>
<script>
$(document).ready(function() {
    resize_access_denied();
});
$(window).resize(resize_access_denied);
function resize_access_denied() {
    var htmlHeight = $("html").height();
    
    $(".content-wrapper").css("min-height", htmlHeight + "px");
}
</script>
<div class="content-wrapper">
    <div class="content-inner">
        <div class="content-inner-box">
        	<div class="error-box">
        		<div class="info-circle times"><i class="fas fa-times fa-4x"></i></div>
        		<div class="code">CODE : 403</div>
        		<div class="text">접근 권한이 없습니다.</div>
        		<div class="text-sub">잠시 후 자동으로 페이지가 이동됩니다.</div>
        	</div>
        </div>
	</div>
</div>
</body>
</html>