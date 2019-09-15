<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.0/jquery.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js"></script>
<script>
$(document).ready(function() {
	/* 부모요소 이벤트 전파 방지 */
    $(".sidebar-wrapper").click(function(e) {
        e.stopPropagation();
    });
});
function headerToggle(type) {
	$(type).toggle();
	if(type == ".menu-list") {
		$(".push-list").css("display", "none");
		$(".user-push").removeClass("active");
		if($(".user-info").attr("class").indexOf("active") > 0) {
			$(".user-info").removeClass("active");
		} else {
			$(".user-info").addClass("active");
		}
	} else if(type == ".push-list") {
		$(".menu-list").css("display", "none");
		$(".user-info").removeClass("active");
		if($(".user-push").attr("class").indexOf("active") > 0) {
			$(".user-push").removeClass("active");
		} else {
			$(".user-push").addClass("active");
		}
	}
}
function pageMove(type) {
	if(type == "login") {
		location.href = "${pageContext.request.contextPath}/login";	
	} else if(type == "find") {
		var pop = window.open("${pageContext.request.contextPath}/login/find/username", "pop", "width=500,height=350, scrollbars=yes, resizable=yes");
	} else if(type == "join") {
		location.href = "${pageContext.request.contextPath}/join/policy";
	} else if(type == "community") {
		location.href = "${pageContext.request.contextPath}/community";
	} else if(type == "mypage") {
		location.href = "${pageContext.request.contextPath}/mypage";
	} else if(type == "logout") {
		$("#logout").submit();
	} else if(type == "notice") {
		location.href = "${pageContext.request.contextPath}/customerService/notice";
	} else if(type == 'rank') {
		location.href = "${pageContext.request.contextPath}/rank";
	}
}
/* 모달 토글 */
function modalToggle(type, title, content) {
    $(type).toggle();
    if(title != null && content != null) {
	    $(type + " .aps-modal-header .title span").html(title);
	    $(type + " .aps-modal-body .body-text").html(content);
    }
}
/* 모바일 사이드바 토글 */
function sidebarToggle(type) {
	$(type).toggle();
}
</script>