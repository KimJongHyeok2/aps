<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>${broadcaster.nickname} : APS</title>
<jsp:include page="/resources/include/common/common_css.jsp"/>
<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/resources/css/include/common.css">
<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/resources/css/community/board/board_write.css">
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
<script src="${pageContext.request.contextPath}/resources/js/api/ckeditor.js"></script>
<script>
$(document).ready(function() {
    resize_board_write();
    var error = "${not empty error? error:'false'}";

    if(error != "false") {
    	if(error == "insertFail") {    		
    		modalToggle("#modal-type-4", "오류", "작성 중 오류가 발생하였습니다.");
    	} else if(error == "prevention") {
    		modalToggle("#modal-type-1", "안내", "과도한 게시글, 댓글 도배로 인해<br>15분 간 등록이 제한되었습니다.");
    	}
    }
});
$(window).resize(resize_board_write);
function resize_board_write() {
    var htmlHeight = $("html").height();
    var headerHeight = $(".header-wrapper").height();
    var navHeight = $(".nav-wrapper").height();
    var footerHeight = $(".footer-wrapper").height();
    
    $(".content-wrapper").css("min-height", htmlHeight - headerHeight - navHeight - footerHeight - 3 + "px");
}
function popUp(url) {
	var pop = window.open(url, "pop", "scrollbars=yes, resizable=yes");
}
function validWrite(obj) {
	var subject = obj["subject"].value;
	var content = myEditor.getData();
	
	if(subject == null || subject.length == 0) {
		modalToggle("#modal-type-1", "안내", "제목을 입력해주세요.");
		return false;
	}
	if(subject.length > 40) {
		modalToggle("#modal-type-1", "안내", "제목은 40자 이하로 입력해주세요.");
		return false;
	}
	if(content.length == 0) {
		modalToggle("#modal-type-1", "안내", "내용을 입력해주세요.");
		return false;		
	} else {
		if(content.length > 30000) {
			modalToggle("#modal-type-1", "안내", "내용은 30,000자 이하로 입력해주세요.");
			return false;
		} else {
			if(content.indexOf('<figure class="image">') != -1) {
				$("#image_flag").val(1);
			} else {
				$("#image_flag").val(0);
			}
			if(content.indexOf('<figure class="media">') != -1) {
				$("#media_flag").val(1);
			} else {
				$("#media_flag").val(0);
			}	
		}
	}
}
</script>
<!-- 게시판 글 작성  Form -->
<div class="content-wrapper">
    <div class="content-inner">
        <div class="content-inner-box">
            <div class="container">
				<jsp:include page="/resources/include/board/board_header.jsp"/>
                <form action="writeOk" method="post" onsubmit="return validWrite(this);">
	                <div class="write-content">
	                    <div class="input-box">
	                        <input type="text" id="subject" name="subject" maxlength="40" value="${dto.subject}" placeholder="제목을 입력해주세요."/>
	                    </div>
	                    <div class="input-box">
	                        <textarea id="content" name="content">${dto.content}</textarea>
	                    </div>
	                    <input type="hidden" id="image_flag" name="image_flag" value="0"/>
	                    <input type="hidden" id="media_flag" name="media_flag" value="0"/>
	                    <input type="hidden" id="user_id" name="user_id" value="${empty sessionScope.id? 0:sessionScope.id}"/>
	                    <input type="hidden" id="broadcaster_id" name="broadcaster_id" value="${broadcaster.id}"/>
	                    <input type="hidden" id="page" name="page" value="${param.page}"/>
	                    <s:csrfInput/>
	                </div>
	                <div class="input-info">
	                	<ul>
	                		<li>5MB 이하의(PNG, JPG, JPEG, GIT) 이미지 파일만  업로드 가능합니다.</li>
	                	</ul>
	                </div>
	                <div class="function">
	                    <button type="button" class="aps-button" onclick="history.back();">이전</button>
	                    <button type="submit" class="aps-button">완료</button>
	                </div>
                </form>
            </div>
        </div>
    </div>
</div>
<jsp:include page="/resources/include/footer.jsp"/>
<jsp:include page="/resources/include/modals.jsp"/>
<jsp:include page="/resources/include/mobile/sidebar.jsp"/>
<jsp:include page="/resources/include/board/board_socket.jsp"/>
<script>
ClassicEditor
	.create(document.querySelector("#content"), {
	    placeholder: "내용을 입력해주세요.",
		ckfinder: {
	        uploadUrl: '${pageContext.request.contextPath}/community/board/write/imageUpload?${_csrf.parameterName}=${_csrf.token}'
	    }
	})
	.then( editor => {
	    myEditor = editor;
	})
	.catch(error => {
	console.error(error);
});
</script>
</body>
</html>