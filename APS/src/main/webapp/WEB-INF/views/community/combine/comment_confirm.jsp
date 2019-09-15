<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>통합 게시판 : APS</title>
<jsp:include page="/resources/include/common/common_css.jsp"/>
<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/resources/css/include/common.css">
<!-- Global site tag (gtag.js) - Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=UA-145699819-1"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());

  gtag('config', 'UA-145699819-1');
</script>
<style type="text/css">
.content-wrapper {
	display: flex;
	align-items: center;
}
.content-wrapper .content-inner {
	width: 100%;
	max-width: 1000px;
	margin: auto;
}
.content-wrapper .content-inner .content-inner-box {
	margin: 10px 0;
}
.content-wrapper .content-inner .content-inner-box .container {
	max-width: 100%;
	margin: 0;
	padding: 0;
}
.content-wrapper .content-inner .content-inner-box .container .board-header {
	padding-bottom: 10px;
	border-bottom: 2px solid #EAEAEA;
}
.content-wrapper .content-inner .content-inner-box .container .board-header .info {
	display: flex;
	align-items: center;
	justify-content: space-between;
}
.content-wrapper .content-inner .content-inner-box .container .board-header .info .name {
	font-size: 20pt;
	font-family: "나눔스퀘어";	
}
.content-wrapper .content-inner .content-inner-box .container .board-header .info .other .other-button {
	padding: 5px;
	border: 1px solid #2e6afd;
	border-radius: 5px;
	background-color: #2e6afd;
	color: white;
}
.content-wrapper .content-inner .content-inner-box .container .content {
	display: flex;
	align-items: center;
	justify-content: center;
}
.content-wrapper .content-inner .content-inner-box .container .content form {
	width: 100%;
}
.content-wrapper .content-inner .content-inner-box .container .content .confirm-box {
	max-width: 350px;
	margin: auto;
	padding: 20px;
	border: 1px solid #D5D5D5;
}
.content-wrapper .content-inner .content-inner-box .container .content .confirm-box .head i.modify {
	vertical-align: middle;
	margin-right: 5px;
	padding: 10px 20px;
	border: 1px solid #0545B1;
	border-radius: 50%;
	color: #0545B1;
}
.content-wrapper .content-inner .content-inner-box .container .content .confirm-box .head i.delete {
	vertical-align: middle;
	margin-right: 5px;
	padding: 10px 15px;
	border: 1px solid #F15F5F;
	border-radius: 50%;
	color: #F15F5F;
}
.content-wrapper .content-inner .content-inner-box .container .content .confirm-box .head span {
	font-family: "나눔스퀘어";
	font-size: 20px;
}
.content-wrapper .content-inner .content-inner-box .container .content .confirm-box .input {
	margin: 10px 0;
}
.content-wrapper .content-inner .content-inner-box .container .content .confirm-box .input input {
	width: 100%;
	padding: 10px;
	border: 1px solid #D5D5D5;
	outline: 0;
	transition-property: border-color;
	transition-duration: 0.5s;
}
.content-wrapper .content-inner .content-inner-box .container .content .confirm-box .input input:focus {
	border: 1px solid #0545B1;
}
.content-wrapper .content-inner .content-inner-box .container .content .confirm-box .button {
	display: flex;
	justify-content: space-between;
	margin: 0 -1px;
}
.content-wrapper .content-inner .content-inner-box .container .content .confirm-box .button .btn {
	padding: 0;
}
.content-wrapper .content-inner .content-inner-box .container .content .confirm-box .button .btn button {
	padding: 5px 10px;
	border: 1px solid #D5D5D5;
	background-color: white;
	color: gray;
	transition-property: color, border-color;
	transition-duration: 0.5s;
}
.content-wrapper .content-inner .content-inner-box .container .content .confirm-box .button .btn button:hover {
	border: 1px solid #0545B1;
	color: #0545B1;
}

/* 통합 게시판 헤더 반응형 */
@media(max-width:1000px) {
	.content-wrapper .content-inner .content-inner-box .container .board-header {
		margin: 0 10px;
	}
	.content-wrapper .content-inner .content-inner-box {
		margin: 10px;
	}
}
@media(max-width:575px) {
	.content-wrapper .content-inner .content-inner-box .container .board-header .info .name {
		font-size: 20px;
	}
}
</style>
<s:csrfMetaTags/>
</head>
<body>
<jsp:include page="/resources/include/common/common_js.jsp"/>
<script>
var header = $("meta[name='_csrf_header']").attr("content");
var token = $("meta[name='_csrf']").attr("content");
$(document).ready(function() {
    resize_confirm();
    var error = "${not empty error? error:'false'}";

    if(error != "false") {
    	if(error == "Password Wrong") {    		
    		modalToggle("#modal-type-1", "안내", "비밀번호를 다시 한번 확인해주세요.");
    	}
    }
});
$(window).resize(resize_confirm);
function resize_confirm() {
    var htmlHeight = $("html").height();
    
    $(".content-wrapper .container .content").css("height", htmlHeight - 20 + "px");
}
function validModify(obj) {
	var password = obj["password"].value;
	
	if(password == null || password.length == 0) {
		modalToggle("#modal-type-1", "안내", "비밀번호를 입력해주세요.");
		return false;
	}
}
function deleteComment(id) {
	var password = $("#password").val();
	
	if(password == null || password.length == 0) {
		modalToggle("#modal-type-1", "안내", "비밀번호를 입력해주세요.");
		return false;
	} else {
		$.ajax({
			url: "${pageContext.request.contextPath}/community/combine/comment/deleteOk",
			type: "POST",
			cache: false,
			data: {
				"id" : id,
				"password" : password
			},
			beforeSend: function(xhr) {
				xhr.setRequestHeader(header, token);
			},
			success: function(data, status) {
				if(status == "success") {
					if(data == "Success") {
						opener.nonCommentDeleteOk(data);
						window.close();
					} else if(data == "Password Wrong") {
						modalToggle("#modal-type-1", "안내", "비밀번호를 다시 한번 확인해주세요.");
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
function deleteCommentReply(id, combineCommentId) {
	var password = $("#password").val();
	
	if(password == null || password.length == 0) {
		modalToggle("#modal-type-1", "안내", "비밀번호를 입력해주세요.");
		return false;
	} else {
		$.ajax({
			url: "${pageContext.request.contextPath}/community/combine/commentReply/deleteOk",
			type: "POST",
			cache: false,
			data: {
				"id" : id,
				"password" : password
			},
			beforeSend: function(xhr) {
				xhr.setRequestHeader(header, token);
			},
			success: function(data, status) {
				if(status == "success") {
					if(data == "Success") {
						opener.nonCommentReplyDeleteOk(data, combineCommentId);
						window.close();
					} else if(data == "Password Wrong") {
						modalToggle("#modal-type-1", "안내", "비밀번호를 다시 한번 확인해주세요.");
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
</script>
<div class="content-wrapper">
    <div class="content-inner">
        <div class="content-inner-box">
        	<div class="container">
				<%-- <jsp:include page="/resources/include/combine/combine_header.jsp"/> --%>
				<div class="content">
					<c:choose>
						<c:when test="${type == 'modify' || type == 'delete'}">
							<form action="${pageContext.request.contextPath += '/community/combine/comment/' += (type=='modify'? 'modify/' += id:'/deleteOk')}" method="post" onsubmit="validModify(this);">
								<div class="confirm-box">
									<div class="head">
										<c:if test="${type == 'modify'}">
											<i class="fas fa-exclamation fa-2x modify"></i> <span>댓글 수정</span>
										</c:if>
										<c:if test="${type == 'delete'}">
											<i class="far fa-trash-alt fa-2x delete"></i> <span>댓글 삭제</span>
										</c:if>
									</div>
									<div class="input">
										<input type="password" id="password" name="password" placeholder="비밀번호를 입력해주세요."/>
									</div>
									<div class="button">
										<div class="btn">
											<button type="button" onclick="window.close();">취소</button>
										</div>
										<div class="btn">
											<c:if test="${type == 'modify'}">
												<button type="submit">확인</button>
											</c:if>
											<c:if test="${type == 'delete'}">
												<button type="button" onclick="deleteComment('${id}');">확인</button>
											</c:if>
										</div>
									</div>
								</div>
								<s:csrfInput/>
							</form>
						</c:when>
						<c:when test="${type == 'deleteReply'}">
							<form>
								<div class="confirm-box">
									<div class="head">
										<i class="far fa-trash-alt fa-2x delete"></i> <span>답글 삭제</span>
									</div>
									<div class="input">
										<input type="password" id="password" name="password" placeholder="비밀번호를 입력해주세요."/>
									</div>
									<div class="button">
										<div class="btn">
											<button type="button" onclick="window.close();">취소</button>
										</div>
										<div class="btn">
											<button type="button" onclick="deleteCommentReply('${id}','${combineCommentId}');">확인</button>
										</div>
									</div>
								</div>
							</form>
						</c:when>
					</c:choose>
				</div>
        	</div>
        </div>
	</div>
</div>
<jsp:include page="/resources/include/modals.jsp"/>
</body>
</html>