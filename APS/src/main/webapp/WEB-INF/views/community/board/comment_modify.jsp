<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="s" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>댓글 수정 : APS</title>
<jsp:include page="/resources/include/common/common_css.jsp"/>
<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/resources/css/include/common.css">
<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/resources/css/community/comment_modify.css">
<s:csrfMetaTags/>
</head>
<body>
<jsp:include page="/resources/include/common/common_js.jsp"/>
<script src="${pageContext.request.contextPath}/resources/js/api/ckeditor.js"></script>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.0/jquery.min.js"></script>
<script>
var header = $("meta[name='_csrf_header']").attr("content");
var token = $("meta[name='_csrf']").attr("content");
$(document).ready(function() {
	resize_comment_modify();
});
$(window).resize(resize_comment_modify);
function resize_comment_modify() {
    var htmlHeight = $("html").height();
    var headerHeight = $(".header-wrapper").height();
    var footerHeight = $(".footer-wrapper").height();
    
    $(".content-wrapper").css("min-height", htmlHeight - headerHeight - footerHeight - 91 + "px");
}
function modifyCommentOk() {
	var content = myEditor.getData();
	var broadcasterBoardId = "${comment.broadcaster_board_id}";
	var broadcasterBoardCommentId = "${comment.id}";
	var userId = "${empty sessionScope.id? 0:sessionScope.id}";
	
	if(userId == 0) {
		modalToggle("#modal-type-2", "확인", "로그인이 필요한 기능입니다.");
		$("#modal-type-2 #2-identify-button").html("로그인");
		$("#modal-type-2 #2-identify-button").attr("onclick", "pageMove('login')");
		return false;
	} else {
		if(content == null || content.length == 0) {
			modalToggle("#modal-type-1", "안내", "내용을 입력해주세요.");
			return false;
		} else {
			if(content.length > 5000) {
				modalToggle("#modal-type-1", "안내", "내용은 5000자 이하로 입력해주세요.");
				return false;			
			} else {
				$.ajax({
					url: "${pageContext.request.contextPath}/community/board/comment/modifyOk",
					type: "POST",
					cache: false,
					data: {
						"broadcaster_board_id" : broadcasterBoardId,
						"id" : broadcasterBoardCommentId,
						"user_id" : userId,
						"content" : content
					},
					beforeSend: function(xhr) {
						xhr.setRequestHeader(header, token);
					},
					success: function(data, status) {
						if(status == "success") {
							if(data == "Success") {
								opener.modifyCommentOk(data);
								window.close();
							} else {
								modalToggle("#modal-type-4", "오류", "알 수 없는 오류입니다.");
							}
						}
					}
				});
			}
		}
	}
}
</script>
<div class="header-wrapper"><i class="far fa-comment-dots"></i> 댓글 수정</div>
<div class="container-fluid">
	<div class="content-wrapper">
		<textarea id="comment">${comment.content}</textarea>
	</div>
	<div class="footer-wrapper">
		<div class="row">
			<div class="button-box col-6">
				<button class="aps-button" onclick="modifyCommentOk();">완료</button>
			</div>
			<div class="button-box col-6">
				<button class="aps-button" onclick="window.close();">취소</button>
			</div>
		</div>
	</div>
</div>
<s:authorize access="isAuthenticated()">
	<script>
	ClassicEditor
		.create(document.querySelector("#comment"), {
		    placeholder: "내용을 입력해주세요.",
		    removePlugins: ["MediaEmbed", "Heading"],
		    toolbar: ["Bold", "Link", "bulletedList", "numberedList", "blockQuote", "insertTable", "ImageUpload"],
			ckfinder: {
		        uploadUrl: '${pageContext.request.contextPath}/community/board/comment/write/imageUpload?${_csrf.parameterName}=${_csrf.token}'
		    }
		})
		.then( editor => {
		    myEditor = editor;
		})
		.catch(error => {
		console.error(error);
	});
	</script>
</s:authorize>
<jsp:include page="/resources/include/modals.jsp"/>
</body>
</html>