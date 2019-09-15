<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="s" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>통합 게시판 : APS</title>
<jsp:include page="/resources/include/common/common_css.jsp"/>
<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/resources/css/include/common.css">
<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/resources/css/community/combine/combine_view.css">
<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/resources/css/community/board/board.css">
<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/resources/css/community/comment.css">
<!-- Global site tag (gtag.js) - Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=UA-145699819-1"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());

  gtag('config', 'UA-145699819-1');
</script>
<s:csrfMetaTags/>
</head>
<body>
<jsp:include page="/resources/include/common/common_js.jsp"/>
<jsp:include page="/resources/include/header.jsp"/>
<script src="${pageContext.request.contextPath}/resources/js/api/ckeditor.js"></script>
<script async charset="utf-8" src="//cdn.embedly.com/widgets/platform.js"></script>
<script>
var header = $("meta[name='_csrf_header']").attr("content");
var token = $("meta[name='_csrf']").attr("content");
$(document).ready(function() {
    dateFormat();
    boardListDateFormat();
    viewCountFormat();
    selectComment();

    var hasError = "${not empty param.error? true:false}";

    if(hasError == "true") {
    	modalToggle("#modal-type-4", "오류", "삭제 중 오류가 발생하였습니다.");
    }

    if("${board.media_flag}" == "true") { // 해당 글에 동영상이 존재한다면
    	$("oembed[url]").each(function() {
    		 const anchor = document.createElement("a");
    		 anchor.setAttribute('href', $(this).attr("url"));
    		 anchor.className = 'embedly-card';
    		 $(this).css("width", "100%");
    		 
    		 $(this).append(anchor);
    	});
    }
    resize_board_view();
});
$(window).resize(resize_board_view);
function resize_board_view() {
    var htmlHeight = $("html").height();
    var headerHeight = $(".header-wrapper").height();
    var navHeight = $(".nav-wrapper").height();
    var footerHeight = $(".footer-wrapper").height();
    
    var documentWidth = $(window).width();
    
    var writeBoxWidth = Math.round($(".bl-default .write-box").width());
    /* var badgeWidth = Math.round($(".bl-default .board-badge").width()); */
    var writerBoxWidth = Math.round($(".bl-default .writer-box").width());
    var otherBoxWidth =  Math.round($(".bl-default .other-box").width());
    
    if(documentWidth >= 1000) {
    	$(".bl-default .subject-box").css("max-width", writeBoxWidth - writerBoxWidth - otherBoxWidth - 10 + "px");
    } else if(documentWidth < 1000 && documentWidth > 767) {
    	$(".bl-default .subject-box").css("max-width", writeBoxWidth - 10 + "px");	
    } else if(documentWidth <= 767) {
    	$(".bl-default .subject-box").css("max-width", writeBoxWidth - 50 + "px");
    }
 
    $(".content-wrapper").css("min-height", htmlHeight - headerHeight - navHeight - footerHeight - 2 + "px");
}
function popUp(url) {
	var pop = window.open(url, "pop", "scrollbars=yes, resizable=yes");
}
// 페이지 이동
function moveBoardPage(page) {
	var listType = $("#listType").val();
	
	if("${not empty param.searchType}" == "true") {
		location.href = "${pageContext.request.contextPath}/community/combine?listType=" + listType + "&page=" + page + "&searchValue=${param.searchValue}&searchType=${param.searchType}";
	} else {
		location.href = "${pageContext.request.contextPath}/community/combine?listType=" + listType + "&page=" + page;
	}
}
// 게시글 추천/비추천
function recommend(type) {
	var id = "${board.id}";
	var userId = "${empty sessionScope.id? 0:sessionScope.id}";
	
	$.ajax({
		url: "${pageContext.request.contextPath}/community/combine/recommend",
		type: "POST",
		cache: false,
		data: {
			"id" : id,
			"type" : type
		},
		beforeSend: function(xhr) {
			xhr.setRequestHeader(header, token);
		},
		success: function(data, status) {
			if(status == "success") {
				if(data == "Success") {
					if(type == "up") {
						modalToggle("#modal-type-1", "안내", "추천을 누르셨습니다.");
						$("#up").html(parseInt($("#up").html()) + 1);
						$("#up").parent("button").addClass("active");
					} else if(type == "down") {
						modalToggle("#modal-type-1", "안내", "비추천을 누르셨습니다.");
						$("#down").html(parseInt($("#down").html()) + 1);
						$("#down").parent("button").addClass("active");
					}
				} else if(data == "Already Press Up") {
					modalToggle("#modal-type-1", "안내", "오늘은 이미 추천을 누르셨습니다.");
				} else if(data == "Already Press Down") {
					modalToggle("#modal-type-1", "안내", "오늘은 이미 비추천을 누르셨습니다.");
				} else if(data == "Login Required") {
					modalToggle("#modal-type-2", "확인", "로그인이 필요한 기능입니다.");
					$("#modal-type-2 #2-identify-button").html("로그인");
					$("#modal-type-2 #2-identify-button").attr("onclick", "pageMove('login')");
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
// 굴 수정
function modifyBoardWrite() {
	var form = $("<form></form>");
	form.attr("action", "${pageContext.request.contextPath}/community/combine/modify/${board.id}");
	form.attr("method", "post");
	form.append("<input type='hidden' id='page' name='page' value='${pagination.page}'/>");
	form.append('<s:csrfInput/>');
	form.appendTo("body");
	form.submit();
}
// 글 삭제 컨펌
function deleteBoardWrite() {
	modalToggle("#modal-type-2", "확인", "정말로 삭제하시겠습니까?");
	$("#2-identify-button").attr("onclick", "deleteBoardWriteOk();");
}
// 글 삭제
function deleteBoardWriteOk() {
	var form = $("<form></form>");
	form.attr("action", "${pageContext.request.contextPath}/community/combine/deleteOk");
	form.attr("method", "post");
	form.append("<input type='hidden' id='id' name='id' value='${board.id}'/>");
	form.append("<input type='hidden' id='page' name='page' value='${pagination.page}'/>");
	form.append('<s:csrfInput/>');
	form.appendTo("body");
	form.submit();
}
function setCommentListType(listType) {
	$("#comment-list-type").val(listType);
	if(listType == "popular") {
		$("#comment-list-type-" + listType).addClass("active");
		$("#comment-list-type-new").removeClass("active");
	} else {
		$("#comment-list-type-" + listType).addClass("active");
		$("#comment-list-type-popular").removeClass("active");		
	}
	selectComment();
}
// 댓글 불러오기
function selectComment(page) {
	var combineBoardId = "${board.id}";
	var listType = $("#comment-list-type").val();
	
	if(page == null) {
		page = 1;
	}
	
	$("#comment-spinner").addClass("on");
	$("#comment-list-box").html("");
	
	$.ajax({
		url: "${pageContext.request.contextPath}/community/combine/comment/list",
		type: "POST",
		cache: false,
		data: {
			"combineBoardId" : combineBoardId,
			"page" : page,
			"listType" : listType
		},
		beforeSend: function(xhr) {
			xhr.setRequestHeader(header, token);
		},
		success: function(data, status) {
			if(status == "success") {
				if(data.status == "Success" && data.count != 0) {
					var tempHTML = "";
					var countFlag = false;
					$("#list-type-box").css("display", "none");
					$("#comment-pagination-inner-box").css("display", "none");
					for(var i=0; i<data.count; i++) {
						if(data.comments[i].status == 1) {
							countFlag = true;
							tempHTML += "<ul class='comment-list animated tdFadeIn'>";
								tempHTML += "<li id='cl-default-" + data.comments[i].id + "' class='cl-default'>";
										tempHTML += "<div class='comment-box'>";
											tempHTML += "<div class='comment-title'>";
												if(listType == "popular" && data.comments[i].no <= 3) {
													tempHTML += "<div class='popular-top'>BEST</div>";
												}
												tempHTML += "<div class='comment-info'>";
													if(data.comments[i].profile != null) {												
														tempHTML += "<div class='info-image'><img class='img-fluid' src='https://kr.object.ncloudstorage.com/aps/profile/" + data.comments[i].profile + "'/></div>";
													} else {														
														tempHTML += "<div class='info-image'><i class='far fa-user fa-2x'></i></div>";
													}
													if(data.comments[i].userType == 10) {
														tempHTML += "<div class='info-name'><span class='nickname'>" + data.comments[i].nickname + "</span><span class='master'>M</span></div>";
													} else {
														/* tempHTML += "<div class='info-name'><span class='nickname'>" + data.comments[i].nickname + "</span><span class='level'>lv." + data.comments[i].level + "</span></div>"; */
														tempHTML += "<div class='info-name'><span class='nickname'>" + data.comments[i].nickname + "</span>";
														if(data.comments[i].userType != 0) {															
															tempHTML += "<span class='level'>lv." + data.comments[i].level + "</span>";
														}
														tempHTML += "</div>";
													}
													tempHTML += "<div class='info-regdate'>" + commentDateFormat(data.comments[i].register_date) + "</div>";
													tempHTML += "<div class='info-ip'>" + data.comments[i].ip + "</div>";
												tempHTML += "</div>";
											if(data.comments[i].comment_type == "non") {
												tempHTML += "<div class='ellipsis' onclick=$('#comment-dropdown-" + data.comments[i].id + "').toggle();>";
													tempHTML += "<i class='fas fa-ellipsis-v'>";
														tempHTML += "<ul class='dropdown' id='comment-dropdown-" + data.comments[i].id + "'>";
															tempHTML += "<li class='dd-default' onclick=modifyComment('" + data.comments[i].id + "','" + data.comments[i].comment_type + "');><i class='fas fa-pen'></i></li>";
															tempHTML += "<li class='dd-default' onclick=deleteComment('" + data.comments[i].id + "','" + data.comments[i].comment_type + "');><i class='fas fa-trash'></i></li>";
														tempHTML += "</ul>";
													tempHTML += "</i>";
												tempHTML += "</div>";
											} else if(data.comments[i].comment_type == "user") {
												tempHTML += "<s:authorize access='isAuthenticated()'>";
													if(data.comments[i].user_id == parseInt("${empty sessionScope.id? 0:sessionScope.id}")) {
														tempHTML += "<div class='ellipsis' onclick=$('#comment-dropdown-" + data.comments[i].id + "').toggle();>";
															tempHTML += "<i class='fas fa-ellipsis-v'>";
																tempHTML += "<ul class='dropdown' id='comment-dropdown-" + data.comments[i].id + "'>";
																	tempHTML += "<li class='dd-default' onclick=modifyComment('" + data.comments[i].id + "','" + data.comments[i].comment_type + "');><i class='fas fa-pen'></i></li>";
																	tempHTML += "<li class='dd-default' onclick=deleteComment('" + data.comments[i].id + "','" + data.comments[i].comment_type + "');><i class='fas fa-trash'></i></li>";
																tempHTML += "</ul>";
															tempHTML += "</i>";
														tempHTML += "</div>";
													}
												tempHTML += "</s:authorize>";
											}
											tempHTML += "</div>"
											tempHTML += "<div class='comment-content'>";
												tempHTML += "<span class='content'>" + data.comments[i].content + "</span>";
											tempHTML += "</div>";
											tempHTML += "<div class='mobile-comment-info'>";
												tempHTML += "<div class='mobile-info-regdate'>" + commentDateFormat(data.comments[i].register_date) + "</div>";
												tempHTML += "<div class='mobile-info-ip'>" + data.comments[i].ip + "</div>";
											tempHTML += "</div>";
											tempHTML += "<div class='comment-function'>";
												tempHTML += "<div class='reply-box'>";
													tempHTML += "<button class='reply-button' onclick='replyOn(" + data.comments[i].id + ")'>답글(<span id='reply-count-" + data.comments[i].id + "'>" + countFormat(data.comments[i].replyCount) + "</span>)</button>";
												tempHTML += "</div>";
												tempHTML += "<div class='recommend-box'>";
													tempHTML += "<div class='up " + (data.comments[i].recommendType==1? "active":"") + "' onclick=recommendComment('" + data.comments[i].id + "','up');><i class='far fa-thumbs-up'></i> <span id='comment-up-" + data.comments[i].id + "'>" + countFormat(data.comments[i].up) + "</span></div>";
													tempHTML += "<div class='down " + (data.comments[i].recommendType==2? "active":"") + "' onclick=recommendComment('" + data.comments[i].id + "','down');><i class='far fa-thumbs-down'></i> <span id='comment-down-" + data.comments[i].id + "'>" + countFormat(data.comments[i].down) + "</span></div>";
												tempHTML += "</div>";
											tempHTML += "</div>";
										tempHTML += "</div>";
									tempHTML += "</li>";
									tempHTML += "<li id='reply-list-box-" + data.comments[i].id + "' class='reply-list-box'>";
									tempHTML += "<s:authorize access='isAuthenticated()'>";
										tempHTML += "<ul class='reply-list'>";
											tempHTML += "<li class='rl-default'>";
												tempHTML += "<div class='input-box'>";
													tempHTML += "<textarea id='comment-reply-content-" + data.comments[i].id + "' placeholder='내용을 입력해주세요.'></textarea><button class='reply-button' onclick=writeCommentReply('" + data.comments[i].id + "','user');>등록</button>";
													tempHTML += "<input type='hidden' id='comment-reply-row-" + data.comments[i].id + "' value='10'/>";
												tempHTML += "</div>";
											tempHTML += "</li>";
										tempHTML += "</ul>";
									tempHTML += "</s:authorize>";
									tempHTML += "<s:authorize access='!isAuthenticated()'>";
										tempHTML += "<ul class='reply-list'>";
											tempHTML += "<li class='rl-default'>";
												tempHTML += "<div class='input-box non'>";
													tempHTML += "<div class='input'>";
														tempHTML += "<input type='text' id='comment-reply-nickname-" + data.comments[i].id + "' placeholder='닉네임을 입력해주세요.'/>";
													tempHTML += "</div>";
													tempHTML += "<div class='input'>";
														tempHTML += "<input type='password' id='comment-reply-password-" + data.comments[i].id + "' placeholder='비밀번호를 입력해주세요.'/>";
													tempHTML += "</div>";
												tempHTML += "</div>";
												tempHTML += "<div class='input-box'>";
													tempHTML += "<textarea id='comment-reply-content-" + data.comments[i].id + "' placeholder='내용을 입력해주세요.'></textarea><button class='reply-button' onclick=writeCommentReply('" + data.comments[i].id + "','non');>등록</button>";
													tempHTML += "<input type='hidden' id='comment-reply-row-" + data.comments[i].id + "' value='10'/>";
												tempHTML += "</div>";
											tempHTML += "</li>";
										tempHTML += "</ul>";
									tempHTML += "</s:authorize>";
									tempHTML += "</li>";
									tempHTML += "<input type='hidden' id='comment-status-" + data.comments[i].id + "' value='" + data.comments[i].status + "'/>";
								tempHTML += "</ul>";
							} else {
								if(data.comments[i].replyCount != 0) {
									tempHTML += "<ul class='comment-list animated tdFadeIn'>";
										tempHTML += "<li id='cl-default-" + data.comments[i].id + "' class='cl-default'>";
											tempHTML += "<div class='comment-box'>";
												tempHTML += "<div class='comment-delete'>사용자의 요청에 의해 삭제된 댓글입니다.</div>";
												tempHTML += "<div class='comment-function'>";
													tempHTML += "<div class='reply-box'>";
														tempHTML += "<div class='reply-button' onclick='replyOn(" + data.comments[i].id + ")'>답글(<span id='reply-count-" + data.comments[i].id + "'>" + countFormat(data.comments[i].replyCount) + "</span>)</div>";
														tempHTML += "<input type='hidden' id='comment-reply-row-" + data.comments[i].id + "' value='10'/>";
														tempHTML += "<input type='hidden' id='comment-status-" + data.comments[i].id + "' value='" + data.comments[i].status + "'/>";
													tempHTML += "</div>";
													tempHTML += "<div class='recommend-box'>";
														tempHTML += "<div class='up'><i class='far fa-thumbs-up'></i> <span>" + countFormat(data.comments[i].up) + "</span></div>";
														tempHTML += "<div class='down'><i class='far fa-thumbs-down'></i> <span>" + countFormat(data.comments[i].down) + "</span></div>";
													tempHTML += "</div>";
												tempHTML += "</div>";
											tempHTML += "</div>";
										tempHTML += "</li>";
										tempHTML += "<li id='reply-list-box-" + data.comments[i].id + "' class='reply-list-box'>";
										tempHTML += "</li>";
									tempHTML += "</ul>";
								}
							}
					}
					if(countFlag) {
						$("#list-type-box").css("display", "flex");
						$("#comment-pagination-inner-box").css("display", "block");
					}
					$("#comment-list-box").html(tempHTML);
					$(".comment-content .image img").addClass("img-fluid");
					tempHTML = "";
					tempHTML += "<ul class='pagination-list'>";
					if(data.pagination.startPage > data.pagination.pageBlock) {
						tempHTML += "<li class='pt-default' onclick='selectComment(" + (data.pagination.startPage - data.pagination.pageBlock) + ");'><i class='fas fa-chevron-left'></i></li>"; 
					}
					for(var i=data.pagination.startPage; i<=data.pagination.endPage; i++) {
						if(i == data.pagination.page) {
							tempHTML += "<li class='pt-default active'>" + i + "</li>";
							$("#comment-page").val(i);
						} else {
							tempHTML += "<li class='pt-default' onclick='selectComment(" + i + ");'>" + i + "</li>";
						}
					}
					if(data.pagination.endPage < data.pagination.pageCount) {
						tempHTML += "<li class='pt-default' onclick='selectComment(" + (data.pagination.startPage + data.pagination.pageBlock) + ");'><i class='fas fa-chevron-right'></i></li>"; 
					}
					tempHTML += "</ul>";
					$("#comment-pagination-inner-box").html(tempHTML);
				} else if(listType == "popular" && data.count == 0) {
					var tempHTML = "";
					tempHTML += "<ul class='comment-list animated tdFadeIn'>";
						tempHTML += "<li class='cl-default empty-comment'>";
							tempHTML += "<div class='comment-box'>";
								tempHTML += "<div class='info-circle'>";
									tempHTML += "<i class='fas fa-comment-alt fa-2x'></i>";
								tempHTML += "</div>";
								tempHTML += "<div class='text'>";
									tempHTML += "인기 댓글이 없습니다.";
								tempHTML += "</div>";
							tempHTML += "</div>";
						tempHTML += "</li>";
					tempHTML += "</ul>";
					$("#comment-list-box").html(tempHTML);
					/* $("#list-type-box").css("display", "none"); */
					$("#comment-pagination-inner-box").css("display", "none");
				} else {
					var tempHTML = "";
					if(data.status == "Fail") {
						modalToggle("#modal-type-4", "오류", "알 수 없는 오류입니다.");
					}
					$("#comment-list-box").html(tempHTML);
					$("#list-type-box").css("display", "none");
					$("#comment-pagination-inner-box").css("display", "none");
				}
			}
		},
		error: function() {
			modalToggle("#modal-type-4", "오류", "알 수 없는 오류입니다.");
		},
		complete: function() {
			$("#comment-spinner").removeClass("on");
		}
	});
}
// 댓글 작성
function writeComment(type) {
	var content = myEditor.getData();
	var combineBoardId = "${board.id}";
	var boardUserId = "${board.user_id}";
	var boardSubject = "${board.subject}";
	
	if(type == "user") {
		if(content == null || content.length == 0) {
			modalToggle("#modal-type-1", "안내", "내용을 입력해주세요.");
			return false;
		} else {
			if(content.length > 5000) {
				modalToggle("#modal-type-1", "안내", "내용은 5000자 이하로 입력해주세요.");
				return false;			
			} else {
				$.ajax({
					url: "${pageContext.request.contextPath}/community/combine/comment/write",
					type: "POST",
					cache: false,
					data: {
						"combine_board_id" : combineBoardId,
						"boardUserId" : boardUserId,
						"boardSubject" : boardSubject, 
						"content" : content,
						"comment_type" : type
					},
					beforeSend: function(xhr) {
						xhr.setRequestHeader(header, token);
					},
					success: function(data, status) {
						if(status == "success") {
							if(data == "Success") {
								myEditor.setData("");
								selectComment();
							} else if(data == "prevention") {
								modalToggle("#modal-type-1", "안내", "과도한 게시글, 댓글 도배로 인해<br>15분 간 등록이 제한되었습니다.");
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
	} else if(type == "non") {
		var pattern_spc = /^[0-9|a-z|A-Z|ㄱ-ㅎ|ㅏ-ㅣ|가-힝]*$/;
		var pattern_con = /^.*[ㄱ-ㅎㅏ-ㅣ]+.*$/;
		var nickname = $("#nickname").val();
		var password = $("#password").val();
		if(content == null || content.length == 0) {
			modalToggle("#modal-type-1", "안내", "내용을 입력해주세요.");
			return false;
		} else {
			if(content.length > 5000) {
				modalToggle("#modal-type-1", "안내", "내용은 5000자 이하로 입력해주세요.");
				return false;			
			}
			if(nickname == null || nickname.length < 2 || nickname.length > 6) {
				modalToggle("#modal-type-1", "안내", "닉네임은 2자 이상 6자 이하로 입력해주세요.");
				return false;
			}
			if(!new RegExp(pattern_spc).test(nickname)) {
				modalToggle("#modal-type-1", "안내", "닉네임에 특수문자는 포함할 수 없습니다.");	
				return false;
			} else if(new RegExp(pattern_con).test(nickname)) {
				modalToggle("#modal-type-1", "안내", "닉네임을 자음 또는 모음으로 설정할 수 없습니다.");	
				return false;
			}
			if(password == null || password.length < 4 || password.length > 20) {
				modalToggle("#modal-type-1", "안내", "비밀번호는 4자 이상 20자 이하로 입력해주세요.");
				return false;
			}
		}
		$.ajax({
			url: "${pageContext.request.contextPath}/community/combine/comment/write",
			type: "POST",
			cache: false,
			data: {
				"combine_board_id" : combineBoardId,
				"boardUserId" : boardUserId,
				"boardSubject" : boardSubject,
				"nickname" : nickname,
				"password" : password,
				"content" : content,
				"comment_type" : type
			},
			beforeSend: function(xhr) {
				xhr.setRequestHeader(header, token);
			},
			success: function(data, status) {
				if(status == "success") {
					if(data == "Success") {
						myEditor.setData("");
						selectComment();
					} else if(data == "prevention") {
						modalToggle("#modal-type-1", "안내", "과도한 게시글, 댓글 도배로 인해<br>15분 간 등록이 제한되었습니다.");
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
// 댓글 수정
function modifyComment(id, type) {
	if(type == "non") {		
		var pop = window.open("${pageContext.request.contextPath}/community/combine/comment/confirm?id=" + id + "&type=modify", "pop", "width=500, height=712, scrollbars=yes, resizable=yes");
	} else {
		window.open("${pageContext.request.contextPath}/community/combine/comment/modify/id=" + id, "pop", "width=500, height=712, scrollbars=yes, resizable=yes");
		var form = $("<form></form>");
		form.attr("action", "${pageContext.request.contextPath}/community/combine/comment/modify/" + id);
		form.attr("method", "post");
		form.attr("target", "pop");
		form.append('<s:csrfInput/>');
		form.appendTo("body");
		form.submit();
	}
}
function modifyCommentOk(data) {
	if(data == "Success") {
		var commentPage = $("#comment-page").val();
		selectComment(commentPage);
	}
}
// 댓글 삭제
function deleteComment(id, type) {
	if(type == "non") {
		var pop = window.open("${pageContext.request.contextPath}/community/combine/comment/confirm?id=" + id + "&type=delete", "pop", "width=500, height=712, scrollbars=yes, resizable=yes");
	} else {
		modalToggle("#modal-type-2", "확인", "정말로 삭제하시겠습니까?");
		$("#modal-type-2 #2-identify-button").attr("onclick", "deleteCommentOk('" + id + "');");
	}
}
function deleteCommentOk(id) {
	var userId = "${empty sessionScope.id? 0:sessionScope.id}";
	
	if(userId == 0) {
		modalToggle("#modal-type-2", "확인", "로그인이 필요한 기능입니다.");
		$("#modal-type-2 #2-identify-button").html("로그인");
		$("#modal-type-2 #2-identify-button").attr("onclick", "pageMove('login')");
		return false;
	} else {
		$.ajax({
			url: "${pageContext.request.contextPath}/community/combine/comment/deleteOk",
			type: "POST",
			cache: false,
			data: {
				"id" : id
			},
			beforeSend: function(xhr) {
				xhr.setRequestHeader(header, token);
			},
			success: function(data, status) {
				if(status == "success") {
					if(data == "Success") {
						modalToggle('#modal-type-2');
						selectComment();
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
function nonCommentDeleteOk(data) {
	if(data == "Success") {
		var commentPage = $("#comment-page").val();
		selectComment(commentPage);
	}
}
// 답글 열기
function replyOn(id) {
 	var row = $("#comment-reply-row-" + id).val();
	selectCommentReply(id, row);
	if($("#cl-default-" + id).attr("class").indexOf("replyOn") > 0) {
		$("#cl-default-" + id).removeClass("replyOn");
	} else {
		$("#cl-default-" + id).addClass("replyOn");
	}
	$("#reply-list-box-" + id).toggle();
}
// 답글 불러오기
function selectCommentReply(id, row) {
	var replyCount = parseInt($("#reply-count-" + id).html().trim());

	if(replyCount != 0) {
		$.ajax({
			url: "${pageContext.request.contextPath}/community/combine/commentReply/list",
			type: "POST",
			cache: false,
			data: {
				"combineBoardCommentId" : id,
				"row" : row
			},
			beforeSend: function(xhr) {
				xhr.setRequestHeader(header, token);
			},
			success: function(data, status) {
				if(status == "success") {
					if(data.status == "Success") {
						$("#reply-list-box-" + id).html("");
						var tempHTML = "";
						tempHTML += "<ul class='reply-list'>";
						for(var i=0; i<data.count; i++) {
							tempHTML += "<li class='rl-default'>";
								tempHTML += "<div class='comment-box'>";
									tempHTML += "<div class='comment-title'>";
										tempHTML += "<div class='comment-info'>";
											if(data.commentReplys[i].profile != null) {												
												tempHTML += "<div class='info-image'><img class='img-fluid' src='https://kr.object.ncloudstorage.com/aps/profile/" + data.commentReplys[i].profile + "'/></div>";
											} else {														
												tempHTML += "<div class='info-image'><i class='far fa-user fa-2x'></i></div>";
											}
											if(data.commentReplys[i].userType == 10) {
												tempHTML += "<div class='info-name'><span class='nickname'>" + data.commentReplys[i].nickname + "</span><span class='master'>M</span></div>";
											} else {
												tempHTML += "<div class='info-name'><span class='nickname'>" + data.commentReplys[i].nickname + "</span>";
												if(data.commentReplys[i].userType != 0) {															
													tempHTML += "<span class='level'>lv." + data.commentReplys[i].level + "</span>";
												}
												tempHTML += "</div>";
											}
											tempHTML += "<div class='info-regdate'>" + commentDateFormat(data.commentReplys[i].register_date) + "</div>";
											tempHTML += "<div class='info-ip'>" + data.commentReplys[i].ip + "</div>";
										tempHTML += "</div>";
										if(data.commentReplys[i].commentReply_type == "non") {
											tempHTML += "<div class='ellipsis' onclick=$('#comment-reply-dropdown-" + data.commentReplys[i].id + "').toggle();>";
												tempHTML += "<i class='fas fa-ellipsis-v'>";
													tempHTML += "<ul class='dropdown' id='comment-reply-dropdown-" + data.commentReplys[i].id + "'>";
														tempHTML += "<li class='dd-default' onclick=deleteCommentReply('" + data.commentReplys[i].id + "','" + data.commentReplys[i].combine_board_comment_id + "','" + data.commentReplys[i].commentReply_type + "');><i class='fas fa-trash'></i></li>";
													tempHTML += "</ul>";
												tempHTML += "</i>";
											tempHTML += "</div>";
										} else if(data.commentReplys[i].commentReply_type == "user") {
											tempHTML += "<s:authorize access='isAuthenticated()'>";
												if(data.commentReplys[i].user_id == parseInt("${empty sessionScope.id? 0:sessionScope.id}")) {
													tempHTML += "<div class='ellipsis' onclick=$('#comment-reply-dropdown-" + data.commentReplys[i].id + "').toggle();>";
														tempHTML += "<i class='fas fa-ellipsis-v'>";
															tempHTML += "<ul class='dropdown' id='comment-reply-dropdown-" + data.commentReplys[i].id + "'>";
																tempHTML += "<li class='dd-default' onclick=deleteCommentReply('" + data.commentReplys[i].id + "','" + data.commentReplys[i].combine_board_comment_id + "','" + data.commentReplys[i].commentReply_type + "');><i class='fas fa-trash'></i></li>";
															tempHTML += "</ul>";
														tempHTML += "</i>";
													tempHTML += "</div>";
												}
											tempHTML += "</s:authorize>";
										}
									tempHTML += "</div>";
									tempHTML += "<div class='comment-content'>";
										tempHTML += "<span class='reply-id'></span><span class='content'>" + data.commentReplys[i].content.replace(/\n/g, "<br>") + "</span>";
									tempHTML += "</div>";
									tempHTML += "<div class='mobile-comment-info'>";
										tempHTML += "<div class='mobile-info-regdate'>" + commentDateFormat(data.commentReplys[i].register_date) + "</div>";
										tempHTML += "<div class='mobile-info-ip'>" + data.commentReplys[i].ip + "</div>";
									tempHTML += "</div>";
								tempHTML += "</div>";
							tempHTML += "</li>";
						}
						if(data.replyCount > data.count) {
							tempHTML += "<li class='rl-default add-list' onclick='addCommentReply(" + id + ")'>더 보기 <i class='fas fa-caret-down'></i></li>";	
						}
						var commentStatus = $("#comment-status-" + id).val();
						if(commentStatus == 1) {
							tempHTML += "<s:authorize access='isAuthenticated()'>";
								tempHTML += "<li class='rl-default'>";
									tempHTML += "<div class='input-box'>";
										tempHTML += "<textarea id='comment-reply-content-" + id + "' placeholder='내용을 입력해주세요.'></textarea><button class='reply-button' onclick=writeCommentReply('" + id + "','user');>등록</button>";
										tempHTML += "<input type='hidden' id='comment-reply-row-" + id + "' value='" + row + "'/>";
									tempHTML += "</div>";
								tempHTML += "</li>";
							tempHTML += "</s:authorize>";
							tempHTML += "<s:authorize access='!isAuthenticated()'>";
								tempHTML += "<li class='rl-default'>";
									tempHTML += "<div class='input-box non'>";
										tempHTML += "<div class='input'>";
												tempHTML += "<input type='text' id='comment-reply-nickname-" + id + "' placeholder='닉네임을 입력해주세요.'/>";
										tempHTML += "</div>";
										tempHTML += "<div class='input'>";
												tempHTML += "<input type='password' id='comment-reply-password-" + id + "' placeholder='비밀번호를 입력해주세요.'/>";
										tempHTML += "</div>";
									tempHTML += "</div>";
									tempHTML += "<div class='input-box'>";
											tempHTML += "<textarea id='comment-reply-content-" + id + "' placeholder='내용을 입력해주세요.'></textarea><button class='reply-button' onclick=writeCommentReply('" + id + "','non');>등록</button>";
											tempHTML += "<input type='hidden' id='comment-reply-row-" + id + "' value='10'/>";
									tempHTML += "</div>";
								tempHTML += "</li>";
							tempHTML += "</s:authorize>";
						}
						tempHTML += "</ul>";
						$("#reply-list-box-" + id).html(tempHTML);
						$("#reply-count-" + id).html(data.replyCount);
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
// 답글 더 보기
function addCommentReply(id) {
	$("#comment-reply-row-" + id).val(parseInt($("#comment-reply-row-" + id).val()) + 10);
	var row = $("#comment-reply-row-" + id).val();
	selectCommentReply(id, row);
}
// 답글 등록
function writeCommentReply(id, type) {
	var content = $("#comment-reply-content-" + id).val();
	var combineBoardId = "${board.id}";
	var boardUserId = "${board.user_id}";
	var boardSubject = "${board.subject}";

	if(type == "user") {
		if(content == null || content.length == 0) {
			modalToggle("#modal-type-1", "안내", "내용을 입력해주세요.");
			return false;
		} else {
			if(content.length > 2500) {
				modalToggle("#modal-type-1", "안내", "내용은 2500자 이하로 입력해주세요.");
				return false;
			} else {
				$.ajax({
					url: "${pageContext.request.contextPath}/community/combine/commentReply/write",
					type: "POST",
					cache: false,
					data: {
						"boardUserId" : boardUserId,
						"boardSubject" : boardSubject, 
						"combine_board_id" : combineBoardId,
						"combine_board_comment_id" : id,
						"content" : content,
						"commentReply_type" : type
					},
					beforeSend: function(xhr) {
						xhr.setRequestHeader(header, token);
					},
					success: function(data, status) {
						if(status == "success") {
							if(data == "Success") {
								$("#comment-reply-content-" + id).val("");
								var row = $("#comment-reply-row-" + id).val();
								var replyCount = parseInt($("#reply-count-" + id).html().trim());
								if(replyCount == 0) {
									$("#reply-count-" + id).html(1);
								}
								selectCommentReply(id, row);
							} else if(data == "prevention") {
								modalToggle("#modal-type-1", "안내", "과도한 게시글, 댓글 도배로 인해<br>15분 간 등록이 제한되었습니다.");
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
	} else if(type == "non") {
		var pattern_spc = /^[0-9|a-z|A-Z|ㄱ-ㅎ|ㅏ-ㅣ|가-힝]*$/;
		var pattern_con = /^.*[ㄱ-ㅎㅏ-ㅣ]+.*$/;
		var nickname = $("#comment-reply-nickname-" + id).val();
		var password = $("#comment-reply-password-" + id).val();
		if(content == null || content.length == 0) {
			modalToggle("#modal-type-1", "안내", "내용을 입력해주세요.");
			return false;
		} else {
			if(content.length > 2500) {
				modalToggle("#modal-type-1", "안내", "내용은 2500자 이하로 입력해주세요.");
				return false;			
			}
			if(nickname == null || nickname.length < 2 || nickname.length > 6) {
				modalToggle("#modal-type-1", "안내", "닉네임은 2자 이상 6자 이하로 입력해주세요.");
				return false;
			}
			if(!new RegExp(pattern_spc).test(nickname)) {
				modalToggle("#modal-type-1", "안내", "닉네임에 특수문자는 포함할 수 없습니다.");	
				return false;
			} else if(new RegExp(pattern_con).test(nickname)) {
				modalToggle("#modal-type-1", "안내", "닉네임을 자음 또는 모음으로 설정할 수 없습니다.");	
				return false;
			}
			if(password == null || password.length < 4 || password.length > 20) {
				modalToggle("#modal-type-1", "안내", "비밀번호는 4자 이상 20자 이하로 입력해주세요.");
				return false;
			}
			$.ajax({
				url: "${pageContext.request.contextPath}/community/combine/commentReply/write",
				type: "POST",
				cache: false,
				data: {
					"boardUserId" : boardUserId,
					"boardSubject" : boardSubject,
					"combine_board_comment_id" : id,
					"nickname" : nickname,
					"password" : password,
					"content" : content,
					"commentReply_type" : type
				},
				beforeSend: function(xhr) {
					xhr.setRequestHeader(header, token);
				},
				success: function(data, status) {
					if(status == "success") {
						if(data == "Success") {
							$("#comment-reply-content-" + id).val("");
							var row = $("#comment-reply-row-" + id).val();
							var replyCount = parseInt($("#reply-count-" + id).html().trim());
							if(replyCount == 0) {
								$("#reply-count-" + id).html(1);
							}
							selectCommentReply(id, row);
						} else if(data == "prevention") {
							modalToggle("#modal-type-1", "안내", "과도한 게시글, 댓글 도배로 인해<br>15분 간 등록이 제한되었습니다.");
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
// 답글 삭제
function deleteCommentReply(id, combineCommentId, type) {
	if(type == "non") {
		var pop = window.open("${pageContext.request.contextPath}/community/combine/comment/confirm?id=" + id + "&combineCommentId=" + combineCommentId + "&type=deleteReply", "pop", "width=500, height=712, scrollbars=yes, resizable=yes");
	} else {
		modalToggle("#modal-type-2", "확인", "정말로 삭제하시겠습니까?");
		$("#modal-type-2 #2-identify-button").attr("onclick", "deleteCommentReplyOk('" + id + "','" + combineCommentId + "');");
	}
}
function deleteCommentReplyOk(id, combineCommentId) {
	var userId = "${empty sessionScope.id? 0:sessionScope.id}";
	
	if(userId == 0) {
		modalToggle("#modal-type-2", "확인", "로그인이 필요한 기능입니다.");
		$("#modal-type-2 #2-identify-button").html("로그인");
		$("#modal-type-2 #2-identify-button").attr("onclick", "pageMove('login')");
		return false;
	} else {
		$.ajax({
			url: "${pageContext.request.contextPath}/community/combine/commentReply/deleteOk",
			type: "POST",
			cache: false,
			data: {
				"id" : id
			},
			beforeSend: function(xhr) {
				xhr.setRequestHeader(header, token);
			},
			success: function(data, status) {
				if(status == "success") {
					if(data == "Success") {
						modalToggle('#modal-type-2');
						var row = $("#comment-reply-row-" + combineCommentId).val();
						selectCommentReply(combineCommentId, row);
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
function nonCommentReplyDeleteOk(data, combineCommentId) {
	if(data == "Success") {
		var row = $("#comment-reply-row-" + combineCommentId).val();
		selectCommentReply(combineCommentId, row);
	}
}
// 댓글 추천
function recommendComment(id, type) {
	$.ajax({
		url: "${pageContext.request.contextPath}/community/combine/comment/recommend",
		type: "POST",
		cache: false,
		data: {
			"id" : id,
			"type" : type
		},
		beforeSend: function(xhr) {
			xhr.setRequestHeader(header, token);
		},
		success: function(data, status) {
			if(status == "success") {
				if(data == "Success") {
					if(type == "up") {
						modalToggle("#modal-type-1", "안내", "추천을 누르셨습니다.");
						$("#comment-up-" + id).html(parseInt($("#comment-up-" + id).html()) + 1);
						$("#comment-up-" + id).parent(".up").addClass("active");
					} else if(type == "down") {
						modalToggle("#modal-type-1", "안내", "비추천을 누르셨습니다.");
						$("#comment-down-" + id).html(parseInt($("#comment-down-" + id).html()) + 1);
						$("#comment-down-" + id).parent(".down").addClass("active");
					}
				} else if(data == "Already Press Up") {
					modalToggle("#modal-type-1", "안내", "오늘은 이미 추천을 누르셨습니다.");
				} else if(data == "Already Press Down") {
					modalToggle("#modal-type-1", "안내", "오늘은 이미 비추천을 누르셨습니다.");
				} else if(data == "Login Required") {
					modalToggle("#modal-type-2", "확인", "로그인이 필요한 기능입니다.");
					$("#modal-type-2 #2-identify-button").html("로그인");
					$("#modal-type-2 #2-identify-button").attr("onclick", "pageMove('login')");
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
// 게시글 정렬 타입
function setBoardListType(type) {
	$("#listType").val(type);
	$(".tab-button").removeClass("active");
	$("#board-list-type-" + type).addClass("active");
	moveBoardPage(1);
}
// 게시글 검색
function searchBoard() {
	var searchValue = $("#searchValue").val();
	var searchType = $("#searchType option:selected").val();
	var listType = $("#listType").val();
	
	if(searchValue == null || searchValue.length == 0) {
		modalToggle("#modal-type-1", "안내", "검색할 내용을 입력해주세요.");
		return false;
	}

	searchValue = urlEncode(searchValue);
	location.href = "${pageContext.request.contextPath}/community/board?id=${broadcaster.id}&listType=" + listType + "&page=${pagination.page}&searchValue=" + searchValue + "&searchType=" + searchType;
}
function urlEncode(str) {
    str = (str + '').toString();
    return encodeURIComponent(str)
        .replace(/!/g, '%21')
        .replace(/'/g, '%27')
        .replace(/\(/g, '%28')
        .replace(/\)/g, '%29')
        .replace(/\*/g, '%2A')
        .replace(/%20/g, '+');
}
// 게시글 등록일시 포맷
function dateFormat() {
	var boardDate = new Date($("#register_date").html().trim().replace(/-/g, "/").replace(".0", ""));

	var boardYear = boardDate.getFullYear();
	var boardMonth = boardDate.getMonth()+1;
	boardMonth = ((boardMonth + "").length == 1? ("0" + boardMonth):boardMonth);
	var boardDay = boardDate.getDate();
	boardDay = ((boardDay + "").length == 1? ("0" + boardDay):boardDay);
	var boardHour = boardDate.getHours();
	boardHour = ((boardHour + "").length == 1? ("0" + boardHour):boardHour);
	var boardMinute = boardDate.getMinutes();
	boardMinute = ((boardMinute + "").length == 1? ("0" + boardMinute):boardMinute);
	
	$("#register_date").html(boardYear + "-" + boardMonth + "-" + boardDay + " " + boardHour + ":" + boardMinute);
	$("#mobile_register_date").html(boardYear + "-" + boardMonth + "-" + boardDay + " " + boardHour + ":" + boardMinute);
}
//게시글 리스트 등록일시 포맷
function boardListDateFormat() {
	var boardLength = parseInt("${fn:length(boardList)}");
	
	for(var i=0; i<boardLength; i++) {
		var nowDate = new Date();
		var boardDate = new Date($("#register_date_" + i).html().trim().replace(/-/g, "/").replace(".0", ""));
		
		var nowYear = nowDate.getFullYear();
		var nowMonth = nowDate.getMonth()+1;
		nowMonth = ((nowMonth + "").length == 1? ("0" + nowMonth):nowMonth);
		var nowDay = nowDate.getDate();
		nowDay = ((nowDay + "").length == 1? ("0" + nowDay):nowDay);
		var nowHour = nowDate.getHours();
		nowHour = ((nowHour + "").length == 1? ("0" + nowHour):nowHour);
		var nowMinute = nowDate.getMinutes();
		nowMinute = ((nowMinute + "").length == 1? ("0" + nowMinute):nowMinute);
		
		var nowFullDate = nowYear + "-" + nowMonth + "-" + nowDay;
		
		var boardYear = boardDate.getFullYear();
		var boardMonth = boardDate.getMonth()+1;
		boardMonth = ((boardMonth + "").length == 1? ("0" + boardMonth):boardMonth);
		var boardDay = boardDate.getDate();
		boardDay = ((boardDay + "").length == 1? ("0" + boardDay):boardDay);
		var boardHour = boardDate.getHours();
		boardHour = ((boardHour + "").length == 1? ("0" + boardHour):boardHour);
		var boardMinute = boardDate.getMinutes();
		boardMinute = ((boardMinute + "").length == 1? ("0" + boardMinute):boardMinute);
		
		var boardFullDate = boardYear + "-" + boardMonth + "-" + boardDay;
		
		if(nowFullDate == boardFullDate) {
			$("#register_date_" + i).html(boardHour + ":" + boardMinute);
			$("#mobile_register_date_" + i).html(boardHour + ":" + boardMinute);
			$("#badge-" + i).addClass("on");
		} else if(nowYear == boardYear) {
			$("#register_date_" + i).html(boardMonth + "-" + boardDay);
			$("#mobile_register_date_" + i).html(boardMonth + "-" + boardDay);
		} else {
			$("#register_date_" + i).html((boardYear + "").substring(2, 4) + "-" + boardMonth + "-" + boardDay);
			$("#mobile_register_date_" + i).html((boardYear + "").substring(2, 4) + "-" + boardMonth + "-" + boardDay);
		}
	}
}
function viewCountFormat() {
	$("#viewcount").html(($("#viewcount").html() + "").replace(/\B(?=(\d{3})+(?!\d))/g, ","));
	$("#mobile_viewcount").html(($("#mobile_viewcount").html() + "").replace(/\B(?=(\d{3})+(?!\d))/g, ","));
	$("#up").html(($("#up").html() + "").replace(/\B(?=(\d{3})+(?!\d))/g, ","));
	$("#down").html(($("#down").html() + "").replace(/\B(?=(\d{3})+(?!\d))/g, ","));
	$("#borad_comment").html(($("#borad_comment").html() + "").replace(/\B(?=(\d{3})+(?!\d))/g, ","));
	
	var boardLength = parseInt("${fn:length(boardList)}");
	
	for(var i=0; i<boardLength; i++) {
		$("#viewcount_" + i).html(($("#viewcount_" + i).html() + "").replace(/\B(?=(\d{3})+(?!\d))/g, ","));
		$("#mobile_viewcount_" + i).html(($("#mobile_viewcount_" + i).html() + "").replace(/\B(?=(\d{3})+(?!\d))/g, ","));
		$("#comment_count_" + i).html(($("#comment_count_" + i).html() + "").replace(/\B(?=(\d{3})+(?!\d))/g, ","));
		$("#mobile_comment_count-" + i).html(($("#mobile_comment_count_" + i).html() + "").replace(/\B(?=(\d{3})+(?!\d))/g, ","));
		$("#mobile_viewcount2_" + i).html(($("#mobile_viewcount2_" + i).html() + "").replace(/\B(?=(\d{3})+(?!\d))/g, ","));
	}
}
function countFormat(value) {
	return (value + "").replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}
// 댓글 등록일시 포맷
function commentDateFormat(date) {
	var commentDate = new Date(date);
	
	var commentYear = commentDate.getFullYear();
	var commentMonth = commentDate.getMonth()+1;
	commentMonth = ((commentMonth + "").length == 1? ("0" + commentMonth):commentMonth);
	var commentDay = commentDate.getDate();
	commentDay = ((commentDay + "").length == 1? ("0" + commentDay):commentDay);
	var commentHour = commentDate.getHours();
	commentHour = ((commentHour + "").length == 1? ("0" + commentHour):commentHour);
	var commentMinute = commentDate.getMinutes();
	commentMinute = ((commentMinute + "").length == 1? ("0" + commentMinute):commentMinute);
	
	return commentYear + "-" + commentMonth + "-" + commentDay + " " + commentHour + ":" + commentMinute;
}
</script>
<!-- 게시판 글 상세보기 -->
<div class="content-wrapper">
    <div class="content-inner">
        <div class="content-inner-box">
            <div class="container">
				<jsp:include page="/resources/include/combine/combine_header.jsp"/>
                <!-- 게시판 내용 -->
                <div class="board-content">
                    <div class="header">
                        <div class="title-box">
                            <!-- <div class="normal-type">일반</div> -->
                            <c:if test="${listType == 'today' || listType == 'week' || listType == 'month'}">
                            	<div class="popular-type">인기</div>
                            </c:if>
                            <div class="subject">${board.subject}</div>
                        </div>
                        <div class="writer-box">
                            <div class="writer-info">
                                <div class="profile-img">
                                	<c:if test="${not empty board.profile}">
                                		<img class="img-fluid" src="https://kr.object.ncloudstorage.com/aps/profile/${board.profile}"/>
                                	</c:if>
                                	<c:if test="${empty board.profile}">
                                		<i class="far fa-user"></i>
                                	</c:if>
                                </div>
                                <div class="nickname">${board.nickname}</div>
								<c:choose>
									<c:when test="${board.userType == 10}">
                                		<div class="master">M</div>
									</c:when>
									<c:otherwise>
										<c:if test="${board.userType != 0}">
                                			<div class="level">lv.${board.level}</div>
										</c:if>
									</c:otherwise>
								</c:choose>
                            </div>
                            <div class="other-box">
                            	<div><i class="fas fa-info-circle"></i> <span>${board.ip}</span></div>&nbsp;
                                <div><i class="fas fa-clock"></i> <span id="register_date">${board.register_date}</span></div>&nbsp;
                                <div><i class="far fa-eye"></i> <span id="viewcount">${board.view}</span></div>
                            </div>
                        </div>
                    </div>
                    <div class="mobile-writer-box">
                    	<div><i class="fas fa-info-circle"></i> <span>${board.ip}</span></div>&nbsp;
                        <div><i class="far fa-clock"></i> <span id="mobile_register_date">${board.register_date}</span></div>&nbsp;
                        <div><i class="far fa-eye"></i> <span id="mobile_viewcount">${board.view}</span></div>
                    </div>
                    <div class="content">
                       	 ${board.content}
                    </div>
                    <div class="recommend">
                        <button class="thumbs-up-button ${board.type == 1? 'active':''}" onclick="recommend('up');"><i class="far fa-thumbs-up"></i><br><span id="up">${board.up}</span></button>
                        <button class="thumbs-down-button ${board.type == 2? 'active':''}" onclick="recommend('down');"><i class="far fa-thumbs-down"></i><br><span id="down">${board.down}</span></button>
                    </div>
                </div>
                <!-- 게시글 기능 -->
                <div class="board-function">
                    <button class="aps-button" onclick="location.href='${pageContext.request.contextPath}/community/combine?page=${pagination.page}'"><i class="fas fa-list"></i> 목록</button>
                	<c:if test="${board.board_type == 'non'}">
						<button class="aps-button" onclick="location.href='${pageContext.request.contextPath}/community/combine/confirm?id=${board.id}&type=modify&page=${pagination.page}'"><i class="fas fa-edit"></i> 수정</button>
                		<button class="aps-button" onclick="location.href='${pageContext.request.contextPath}/community/combine/confirm?id=${board.id}&type=delete&page=${pagination.page}'"><i class="fas fa-trash-alt"></i> 삭제</button>
                	</c:if>
                    <s:authorize access="isAuthenticated()">
                    	<c:if test="${board.user_id == sessionScope.id && board.board_type == 'user'}">
                    		<button class="aps-button" onclick="modifyBoardWrite();"><i class="fas fa-edit"></i> 수정</button>
                    		<button class="aps-button" onclick="deleteBoardWrite();"><i class="fas fa-trash-alt"></i> 삭제</button>
                    	</c:if>
                    </s:authorize>
                </div>
                <div class="board-neighbor">
                    <div class="neighbor-box">
                    	<c:if test="${board.next_id != 0 && not empty board.next_subject}">
                        	<div class="indicator"><i class="fas fa-chevron-up"></i> 다음글</div><div class="subject" onclick="location.href='${pageContext.request.contextPath}/community/combine/view/${board.next_id}?page=${pagination.page}'">${board.next_subject}</div>
                        </c:if>
                    </div>
                    <div class="neighbor-box">
                    	<c:if test="${board.prev_id != 0 && not empty board.prev_subject}">
                        	<div class="indicator"><i class="fas fa-chevron-down"></i> 이전글</div><div class="subject" onclick="location.href='${pageContext.request.contextPath}/community/combine/view/${board.prev_id}?page=${pagination.page}'">${board.prev_subject}</div>
                        </c:if>
                    </div>
                </div>
                <!-- 댓글 -->
                <div class="board-comment">
                    <div class="title">
                        <i class="fas fa-comments"></i>&nbsp;댓글&nbsp;<span id="board_comment">${board.commentCount}</span>개
                    </div>
                    <s:authorize access="isAuthenticated()">
	                    <div class="write-box">
	                        <div class="top">
	                            <textarea id="comment"></textarea>
	                        </div>
	                        <div class="bottom">
	                            <button class="write-button" onclick="writeComment('user');">등록</button>
	                        </div>
	                    </div>
                    </s:authorize>
                    <s:authorize access="!isAuthenticated()">
	                    <div class="write-box">
	                        <div class="top">
	                            <textarea id="comment"></textarea>
	                        </div>
	                        <div class="bottom row">
	                        	<div class="box col-12 col-sm-8">
	                        		<div class="input row">
		                        		<input class="col-6" type="text" id="nickname" placeholder="닉네임을 입력해주세요."/>
		                        		<input class="col-6" type="password" id="password" placeholder="비밀번호를 입력해주세요."/>
	                        		</div>
	                        	</div>
	                        	<div class="box col-12 col-sm-4">
	                            	<button class="write-button" onclick="writeComment('non');">등록</button>
	                            </div>
	                        </div>
	                    </div>
                    </s:authorize>
                    <div class="comment-list-wrapper border-bottom-none margin-bottom">
                        <div class="comment-list-inner">
                            <div class="comment-list-inner-box margin-bottom-box">
					        	<div id="comment-spinner" class="comment-spinner on animated tdFadeIn">
					        		<div class="sk-folding-cube">
						        		<div class="sk-cube1 sk-cube"></div>
										<div class="sk-cube2 sk-cube"></div>
										<div class="sk-cube4 sk-cube"></div>
										<div class="sk-cube3 sk-cube"></div>
									</div>
								</div>
                                <div id="list-type-box" class="list-type-box">
                                    <div class="list-type">
                                        <span id="comment-list-type-new" class="active" onclick="setCommentListType('new');"><i class="fas fa-check"></i> 최신순</span>
                                        <span id="comment-list-type-popular" onclick="setCommentListType('popular');"><i class="fas fa-check"></i> 인기순</span>
                                        <input type="hidden" id="comment-list-type" value="new"/>
                                    </div>
                                </div>
                                <div id="comment-list-box" class="comment-list-box">
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="comment-pagination-wrapper">
                        <div class="comment-pagination-inner">
                            <div id="comment-pagination-inner-box" class="comment-pagination-inner-box animated tdFadeIn">
                                <ul class="pagination-list">
                                </ul>
                            </div>
                            <input type="hidden" id="comment-page" value="1"/>
                        </div>
                    </div>
                </div>
                <div class="board-content section-2">
                    <div class="board-tab-box">
                        <div id="board-list-type-new" class="tab-button ${empty listType || (listType != 'today' && listType != 'week' && listType != 'month') || listType == 'new'? 'active':''}" onclick="setBoardListType('new');">최신순</div>
                        <div id="board-list-type-today" class="tab-button ${listType == 'today'? 'active':''}" onclick="setBoardListType('today');">일일 인기순</div>
                        <div id="board-list-type-week" class="tab-button ${listType == 'week'? 'active':''}" onclick="setBoardListType('week');">주간 인기순</div>
                        <div id="board-list-type-month" class="tab-button ${listType == 'month'? 'active':''}" onclick="setBoardListType('month');">월간 인기순</div>
                        <input type="hidden" id="listType" value="${listType}"/>
                    </div>
                    <div class="board-list-box">
                        <ul class="board-list animated tdFadeIn">
                        	<c:choose>
                        		<c:when test="${not empty boardList}">
                        			<c:forEach var="i" items="${boardList}" varStatus="index">
			                            <li class="bl-default" onclick="location.href='${pageContext.request.contextPath}/community/combine/view/${i.id}?listType=${listType}&page=${pagination.page}'">
			                                <div class="write-box">
 			                                	<div class="badge">
			                                		<c:choose>
			                                			<c:when test="${listType == 'today' || listType == 'week' || listType == 'month'}">
			                                				<div id="badge-${index.index}" class="best"><img src="${pageContext.request.contextPath}/resources/image/icon/badge-best.png"/></div>
			                                			</c:when>
			                                			<c:otherwise>
			                                				<div id="badge-${index.index}" class="new"><img src="${pageContext.request.contextPath}/resources/image/icon/badge-new.png"/></div>
			                                			</c:otherwise>
			                                		</c:choose>
			                                	</div>
			                                    <div class="number">${i.id}</div>
<%-- 			                                	<c:choose>
			                                		<c:when test="${listType == 'today' || listType == 'week' || listType == 'month'}">
			                                			<div id="badge-new-${index.index}" class="best"><img src="${pageContext.request.contextPath}/resources/image/icon/badge-best.png"/></div>
			                                    		<div class="board-badge"><div class="badge-popluar">인기</div></div>
			                                		</c:when>
				                                	<c:otherwise>
			                                    		<div id="board-badge-${index.index}" class="board-badge"></div>
				                                	</c:otherwise>
			                                	</c:choose> --%>
			                                    <div class="subject-box">
			                                        <div class="subject">
			                                            <a href="${pageContext.request.contextPath}/community/combine/view/${i.id}?listType=${listType}&page=${pagination.page}">${i.subject}</a>
			                                        </div>
			                                        <div class="info">
			                                            [<span id="comment_count_${index.index}" class="count">${i.commentCount}</span>]
			                                            <c:if test="${i.image_flag == true}">
				                                            <i class="fas fa-image"></i>
			                                            </c:if>
			                                            <c:if test="${i.media_flag == true}">
				                                            <i class="fas fa-video"></i>
			                                            </c:if>
			                                        </div>
			                                    </div>
			                                    <div class="writer-box">
			                                        <div class="profile-img">
			                                        	<c:choose>
			                                        		<c:when test="${not empty i.profile && i.userType != 0}">
				                                        		<img class="img-fluid" src="https://kr.object.ncloudstorage.com/aps/profile/${i.profile}"/>
			                                        		</c:when>
			                                        		<c:otherwise>
			                                        			<i class="far fa-user"></i>
			                                        		</c:otherwise>
			                                        	</c:choose>
			                                        </div>
			                                        <div class="nickname">${i.nickname}</div>
			                                        <c:choose>
			                                        	<c:when test="${i.userType == 10}">
			                                        		<div class="master">M</div>
			                                        	</c:when>
			                                        	<c:otherwise>
			                                        		<c:if test="${i.userType != 0}">
			                                        			<div class="level">lv.${i.level}</div>
			                                        		</c:if>
			                                        	</c:otherwise>
			                                        </c:choose>
			                                    </div>
			                                    <div class="other-box">
			                                        <div id="register_date_${index.index}" class="regdate">${i.register_date}</div>
			                                        <div id="viewcount_${index.index}" class="viewcount">${i.view}</div>
			                                    </div>
			                                </div>
			                                <div class="mobile-box">
			                                    <div class="mobile-write-box">
			                                        <div class="profile-img">
			                                        	<c:choose>
			                                        		<c:when test="${not empty i.profile && i.userType != 0}">
				                                        		<img class="img-fluid" src="https://kr.object.ncloudstorage.com/aps/profile/${i.profile}"/>
			                                        		</c:when>
			                                        		<c:otherwise>
			                                        			<i class="far fa-user"></i>
			                                        		</c:otherwise>
			                                        	</c:choose>
			                                        </div>
			                                        <div class="nickname">${i.nickname}</div>
			                                        <c:choose>
			                                        	<c:when test="${i.userType == 10}">
			                                        		<div class="master">M</div>
			                                        	</c:when>
			                                        	<c:otherwise>
			                                        		<c:if test="${i.userType != 0}">
			                                        			<div class="level">lv.${i.level}</div>
			                                        		</c:if>
			                                        	</c:otherwise>
			                                        </c:choose>
			                                    </div>
			                                    <div id="mobile_register_date_${index.index}" class="mobile-regdate">${i.register_date}</div>
			                                    <div id="mobile_viewcount_${index.index}" class="mobile-viewcount">${i.view}</div>
			                                </div>
			                                <div class="mobile-info-box">
			                                    <div class="mobile-info-inner">
			                                        <div id="mobile_comment_count_${index.index}" class="comment-count-box">[<span class="count">${i.commentCount}</span>]</div>
			                                        <div class="icon-box">
			                                            <c:if test="${i.image_flag == true}">
				                                            <i class="fas fa-image"></i>
			                                            </c:if>
			                                            <c:if test="${i.media_flag == true}">
				                                            <i class="fas fa-video"></i>
			                                            </c:if>
			                                        </div>
			                                        <div class="view-count-box"><span id="mobile_viewcount2_${index.index}" class="count">${i.view}</span></div>
			                                    </div>
			                                </div>
			                            </li>
                        			</c:forEach>
                        		</c:when>
                        		<c:otherwise>
		                        	<li class="empty-board">
		                        		<div class="info-circle"><i class="fas fa-info fa-2x"></i></div>
		                        		<div class="text">등록된 게시글이 없습니다.</div>
		                        	</li>
                        		</c:otherwise>
                        	</c:choose>
                        </ul>
                    </div>
                    <div class="function-wrapper">
                        <button class="aps-button" onclick="location.href='${pageContext.request.contextPath}/community/combine/write?page=${pagination.page}'"><i class="fas fa-pen"></i> 글쓰기</button>
                    </div>
                    <c:if test="${pagination.pageCount > 0}">
	                    <div class="pagination-wrapper">
	                        <div class="pagination-inner">
	                            <div class="pagination-inner-box animated tdFadeIn">
	                                <ul class="pagination-list">
	                                	<c:if test="${pagination.startPage > pagination.pageBlock}">
	                                		<li class="pt-default" onclick="moveBoardPage('${pagination.startPage - pagination.pageBlock}');"><i class="fas fa-chevron-left"></i></li>
	                                	</c:if>
	                                	<c:forEach var="i" begin="${pagination.startPage}" end="${pagination.endPage}">
	                                		<c:choose>
	                                			<c:when test="${pagination.page == i}">
	                                				<li class="pt-default active">${i}</li>	
	                                			</c:when>
	                                			<c:otherwise>
	                                				<li class="pt-default" onclick="moveBoardPage('${i}');">${i}</li>
	                                			</c:otherwise>
	                                		</c:choose>
	                                    </c:forEach>
	                                	<c:if test="${pagination.endPage < pagination.pageCount}">
	                                		<li class="pt-default" onclick="moveBoardPage('${pagination.startPage + pagination.pageBlock}');"><i class="fas fa-chevron-right"></i></li>
	                                	</c:if>
	                                </ul>
	                            </div>
	                        </div>
	                    </div>
                    </c:if>
                    <!-- 게시글 검색 -->
	                <div class="search-wrapper">
	                	<div class="search-box animated tdFadeIn">
	                		<div class="select">
	                			<select id="searchType">
	                				<option class="options" value="1">제목</option>
	                			</select>
	                		</div>
	                		<div class="input">
	                			<input type="text" id="searchValue" onkeypress="if(event.keyCode==13) { searchBoard(); }"/>
	                		</div>
	                		<div class="button">
	                			<button onclick="searchBoard();"><i class="fas fa-search"></i></button>
	                		</div>
	                	</div>
	                </div>
                </div>
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
</body>
</html>