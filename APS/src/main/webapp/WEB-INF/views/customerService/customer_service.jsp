<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="s" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>고객센터 : APS</title>
<meta property="og:title" content="고객센터 : APS"/>
<meta name="author" content="아프리카 민심"/>
<meta name="description" content="인터넷방송 플랫폼 아프리카TV 커뮤니티 APS 고객센터입니다."/>
<meta property="og:description" content="인터넷방송 플랫폼 아프리카TV 커뮤니티 APS 고객센터입니다."/>
<meta property="og:image" content="https://www.afreecaps.com/resources/image/logo/header_logo.png"/>
<link rel="canonical" href="https://www.afreecaps.com/customerService/notice">
<meta property="og:url" content="https://www.afreecaps.com/customerService/notice"/>
<meta property="og:type" content="website">
<jsp:include page="/resources/include/common/common_css.jsp"/>
<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/resources/css/include/common.css">
<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/resources/css/customerService/customer_service.css">
<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/resources/css/community/comment.css">
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
<script src="${pageContext.request.contextPath}/resources/js/api/ckeditor.js"></script>
<script async charset="utf-8" src="//cdn.embedly.com/widgets/platform.js"></script>
<script>
var header = $("meta[name='_csrf_header']").attr("content");
var token = $("meta[name='_csrf']").attr("content");
$(document).ready(function() {
    resize_board_list();
    resize_board_subject();
    $(".view").click(function(e) {
    	e.stopPropagation();
    });
    
    $("oembed[url]").each(function() {
    	const anchor = document.createElement("a");
    	anchor.setAttribute('href', $(this).attr("url"));
    	anchor.className = 'embedly-card';
    	$(this).css("width", "100%");
    	$(this).append(anchor);
    });
    
    boardCountFormat();
    dateFormat();
    if("${not empty param.id}" == "true") {
    	openContent("${param.id}");
    }
});
$(window).resize(function() {
	resize_board_list();
	resize_board_subject();
});
function resize_board_list() {
    var htmlHeight = $("html").height();
    var headerHeight = $(".header-wrapper").height();
    var navHeight = $(".nav-wrapper").height();
    var footerHeight = $(".footer-wrapper").height();
    
    $(".content-wrapper").css("min-height", htmlHeight - headerHeight - navHeight - footerHeight - 3 + "px");
}
function resize_board_subject() {
	var contentTopWidth = $(".cc-default .top").width();
	/* var contentTopTypeWidth = $(".cc-default .top .type").width(); */
	var contentTopSubjectInfoWidth = $(".cc-default .top .subject-box .info").width();
	
	var documentWidth = $(window).width();
	
/* 	if(documentWidth <= 575) {
		$(".cc-default .top .subject-box .subject").css("max-width", contentTopWidth - contentTopSubjectInfoWidth - 12 + "px");
	} else {
	} */
	$(".cc-default .top .subject-box .subject").css("max-width", contentTopWidth - contentTopSubjectInfoWidth - 12 + "px");		
}
// 페이지 이동
function moveBoardPage(page) {
	if("${not empty param.searchType}" == "true") {
		location.href = "${pageContext.request.contextPath}/customerService/${categoryId}?page=" + page + "&searchValue=${param.searchValue}&searchType=${param.searchType}";
	} else {		
		location.href = "${pageContext.request.contextPath}/customerService/${categoryId}?page=" + page;	
	}
}
// 글 상세보기
function openContent(id) {
	/* $("#cc-default-" + id).attr("onclick", "closeContent('" + id + "')"); */
	$(".view").css("display", "none");
	$(".subject-box .subject").removeClass("on");
	$(".subject-box .info").css("display", "inline-block");
	$(".cc-default").removeClass("on");
	
	$("#cc-default-" + id).addClass("on");
	$("#info-" + id).toggle();
	$("#cc-view-" + id).toggle();
	if($("#subject-" + id).attr("class").indexOf("on") >= 0) {
		$("#subject-" + id).removeClass("on");
	} else {
		$("#subject-" + id).addClass("on");
	}
	selectComment(id, 1);
	$.ajax({
		url: "${pageContext.request.contextPath}/customerService/view",
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
				if(data.result == "Success") {
					$("#view-count-box-" + id).find("span").html((data.view + "").replace(/\B(?=(\d{3})+(?!\d))/g, ","));
				}
			}
		},
		error: function() {
			modalToggle("#modal-type-4", "오류", "알 수 없는 오류입니다.");
		}
	});
}
// 글 닫기
function closeContent(id) {
	$("#cc-default-" + id).attr("onclick", "openContent('" + id + "')");
	$("#info-" + id).toggle();
	$("#cc-view-" + id).toggle();
	$(".cc-default").removeClass("on");
	if($("#subject-" + id).attr("class").indexOf("on") >= 0) {
		$("#subject-" + id).removeClass("on");
	} else {
		$("#subject-" + id).addClass("on");
	}
}
// 글 작성 시 카테고리 설정
function setCategory(obj) {
	$(".cc-write .category-box .category").removeClass("active");
	$(obj).addClass("active");
	$(obj).find("input[type='radio'][name='category_id']").prop("checked", true);
}
// 글 작성 유효성 검사
function validWrite() {
	var subject = $("#subject").val()
	var content = myEditor.getData();
	var categoryCount = 0;
	
	$("input[type='radio'][name='category_id']").each(function() {
		if($(this).is(":checked")) {
			categoryCount += 1;
		}
	});
	
	if(categoryCount != 1) {
		modalToggle("#modal-type-1", "안내", "카테고리를 선택해주세요.");
		return false;
	}

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
			$("#writeForm").submit();
		}
	}
}
// 댓글 수정
function modifyComment(id, noticeId) {
	var pop = window.open("${pageContext.request.contextPath}/customerService/comment/modify/" + id + "?noticeId=" + noticeId, "pop", "width=500, height=712, scrollbars=yes, resizable=yes");
}
function modifyCommentOk(data, noticeId) {
	if(data == "Success") {
		var commentPage = $("#comment-page-" + noticeId).val();
		selectComment(noticeId, commentPage);
	}
}
// 댓글 삭제
function deleteComment(id, noticeId) {
	modalToggle("#modal-type-2", "확인", "정말로 삭제하시겠습니까?");
	$("#modal-type-2 #2-identify-button").attr("onclick", "deleteCommentOk('" + id + "','" + noticeId + "');");
}
function deleteCommentOk(id, noticeId) {
	var userId = "${empty sessionScope.id? 0:sessionScope.id}";
	
	if(userId == 0) {
		modalToggle("#modal-type-2", "확인", "로그인이 필요한 기능입니다.");
		$("#modal-type-2 #2-identify-button").html("로그인");
		$("#modal-type-2 #2-identify-button").attr("onclick", "pageMove('login')");
		return false;
	} else {
		$.ajax({
			url: "${pageContext.request.contextPath}/customerService/comment/deleteOk",
			type: "POST",
			cache: false,
			data: {
				"noticeId" : noticeId,
				"id" : id
			},
			beforeSend: function(xhr) {
				xhr.setRequestHeader(header, token);
			},
			success: function(data, status) {
				if(status == "success") {
					if(data == "Success") {
						modalToggle('#modal-type-2');
						selectComment(noticeId);
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
// 글 삭제 컨펌
function deleteBoardWrite(id) {
	modalToggle("#modal-type-2", "확인", "정말로 삭제하시겠습니까?");
	$("#2-identify-button").attr("onclick", "deleteBoardWriteOk('" + id + "');");
}
// 글 삭제
function deleteBoardWriteOk(id) {
	var form = $("<form></form>");
	form.attr("action", "${pageContext.request.contextPath}/customerService/deleteOk");
	form.attr("method", "post");
	form.append("<input type='hidden' id='id' name='id' value='" + id + "'/>");
	form.append("<input type='hidden' id='categoryId' name='categoryId' value='${categoryId}'/>");
	form.append('<s:csrfInput/>');
	form.appendTo("body");
	form.submit();
}
// 댓글 정렬 타입
function setCommentListType(noticeId, listType) {
	$("#comment-list-type-" + noticeId).val(listType);
	if(listType == "popular") {
		$("#comment-list-type-" + noticeId + "-" + listType).addClass("active");
		$("#comment-list-type-" + noticeId + "-new").removeClass("active");
	} else {
		$("#comment-list-type-" + noticeId + "-" + listType).addClass("active");
		$("#comment-list-type-" + noticeId + "-popular").removeClass("active");		
	}
	selectComment(noticeId);
}
// 댓글 불러오기
function selectComment(noticeId, page) {
	var listType = $("#comment-list-type-" + noticeId).val();
	
	if(page == null) {
		page = 1;
	}
	
	$("#comment-spinner-" + noticeId).addClass("on");
	$("#comment-list-box-" + noticeId).html("");
	
	$.ajax({
		url: "${pageContext.request.contextPath}/customerService/comment/list",
		type: "POST",
		cache: false,
		data: {
			"noticeId" : noticeId,
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
					$("#list-type-box-" + noticeId).css("display", "none");
					$("#comment-pagination-inner-box-" + noticeId).css("display", "none");
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
														tempHTML += "<div class='info-name'><span class='nickname'>" + data.comments[i].nickname + "</span><span class='level'>lv." + data.comments[i].level + "</span></div>";														
													}
													tempHTML += "<div class='info-regdate'>" + commentDateFormat(data.comments[i].register_date) + "</div>";
													tempHTML += "<div class='info-ip'>" + data.comments[i].ip + "</div>";
												tempHTML += "</div>";
												tempHTML += "<s:authorize access='isAuthenticated()'>";
													if(data.comments[i].user_id == parseInt("${empty sessionScope.id? 0:sessionScope.id}")) {
														tempHTML += "<div class='ellipsis' onclick=$('#comment-dropdown-" + data.comments[i].id + "').toggle();>";
															tempHTML += "<i class='fas fa-ellipsis-v'>";
																tempHTML += "<ul class='dropdown' id='comment-dropdown-" + data.comments[i].id + "'>";
																	tempHTML += "<li class='dd-default' onclick=modifyComment('" + data.comments[i].id + "','" + noticeId + "');><i class='fas fa-pen'></i></li>";
																	tempHTML += "<li class='dd-default' onclick=deleteComment('" + data.comments[i].id + "','" + noticeId + "');><i class='fas fa-trash'></i></li>";
																tempHTML += "</ul>";
															tempHTML += "</i>";
														tempHTML += "</div>";
													}
												tempHTML += "</s:authorize>";
											tempHTML += "</div>"
											tempHTML += "<div class='comment-content'>";
												tempHTML += "<span class='content'>" + data.comments[i].content.replace(/\n/g, "<br>") + "</span>";
											tempHTML += "</div>";
											tempHTML += "<div class='mobile-comment-info'>";
												tempHTML += "<div class='mobile-info-regdate'>" + commentDateFormat(data.comments[i].register_date) + "</div>";
												tempHTML += "<div class='mobile-info-ip'>" + data.comments[i].ip + "</div>";
											tempHTML += "</div>";
											tempHTML += "<div class='comment-function'>";
												tempHTML += "<div class='reply-box'>";
													tempHTML += "<button class='reply-button' onclick=replyOn('" + data.comments[i].id + "','" + noticeId + "')>답글(<span id='reply-count-" + data.comments[i].id + "'>" + countFormat(data.comments[i].replyCount) + "</span>)</button>";
												tempHTML += "</div>";
												tempHTML += "<div class='recommend-box'>";
													tempHTML += "<div class='up " + (data.comments[i].type==1? "active":"") + "' onclick=recommendComment('" + data.comments[i].id + "','up');><i class='far fa-thumbs-up'></i> <span id='comment-up-" + data.comments[i].id + "'>" + countFormat(data.comments[i].up) + "</span></div>";
													tempHTML += "<div class='down " + (data.comments[i].type==2? "active":"") + "' onclick=recommendComment('" + data.comments[i].id + "','down');><i class='far fa-thumbs-down'></i> <span id='comment-down-" + data.comments[i].id + "'>" + countFormat(data.comments[i].down) + "</span></div>";
												tempHTML += "</div>";
											tempHTML += "</div>";
										tempHTML += "</div>";
									tempHTML += "</li>";
									tempHTML += "<li id='reply-list-box-" + data.comments[i].id + "' class='reply-list-box'>";
									tempHTML += "<s:authorize access='isAuthenticated()'>";
										tempHTML += "<ul class='reply-list'>";
											tempHTML += "<li class='rl-default'>";
												tempHTML += "<div class='input-box'>";
													tempHTML += "<textarea id='comment-reply-content-" + data.comments[i].id + "' placeholder='내용을 입력해주세요.'></textarea><button class='reply-button' onclick=writeCommentReply('" + data.comments[i].id + "','" + noticeId + "');>등록</button>";
													tempHTML += "<input type='hidden' id='comment-reply-row-" + data.comments[i].id + "' value='10'/>";
												tempHTML += "</div>";
											tempHTML += "</li>";
										tempHTML += "</ul>";
									tempHTML += "</s:authorize>";
									tempHTML += "<s:authorize access='!isAuthenticated()'>";
 										tempHTML += "<ul class='reply-list'>";
											tempHTML += "<li class='rl-default'>";
 												tempHTML += "<div class='input-box'>";
													tempHTML += "<div class='not-authenticated'>";
														tempHTML += "<div class='info-circle'><i class='fas fa-info fa-2x'></i></div>";
														tempHTML += "<div class='text'>답글을 등록하려면 로그인이 필요합니다.</div>";
														tempHTML += "<input type='hidden' id='comment-reply-row-" + data.comments[i].id + "' value='10'/>";
  													tempHTML += "</div>";
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
														tempHTML += "<div class='reply-button' onclick=replyOn('" + data.comments[i].id + "','" + noticeId + "')>답글(<span id='reply-count-" + data.comments[i].id + "'>" + countFormat(data.comments[i].replyCount) + "</span>)</div>";
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
						$("#list-type-box-" + noticeId).css("display", "flex");
						$("#comment-pagination-inner-box-" + noticeId).css("display", "block");
					}
					$("#comment-list-box-" + noticeId).html(tempHTML);
					$(".comment-content .image img").addClass("img-fluid");
					tempHTML = "";
					tempHTML += "<ul class='pagination-list'>";
					if(data.pagination.startPage > data.pagination.pageBlock) {
						tempHTML += "<li class='pt-default' onclick=selectComment('" + noticeId + "'," + (data.pagination.startPage - data.pagination.pageBlock) + ");><i class='fas fa-chevron-left'></i></li>"; 
					}
					for(var i=data.pagination.startPage; i<=data.pagination.endPage; i++) {
						if(i == data.pagination.page) {
							tempHTML += "<li class='pt-default active'>" + i + "</li>";
							$("#comment-page-" + noticeId).val(i);
						} else {
							tempHTML += "<li class='pt-default' onclick=selectComment('" + noticeId + "','" + i + "');>" + i + "</li>";
						}
					}
					if(data.pagination.endPage < data.pagination.pageCount) {
						tempHTML += "<li class='pt-default' onclick=selectComment('" + noticeId + "','" + (data.pagination.startPage + data.pagination.pageBlock) + "');><i class='fas fa-chevron-right'></i></li>"; 
					}
					tempHTML += "</ul>";
					$("#comment-pagination-inner-box-" + noticeId).html(tempHTML);
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
					$("#comment-list-box-" + noticeId).html(tempHTML);
					/* $("#list-type-box").css("display", "none"); */
					$("#comment-pagination-inner-box-" + noticeId).css("display", "none");
				} else {
					var tempHTML = "";
					if(data.status == "Fail") {
						modalToggle("#modal-type-4", "오류", "알 수 없는 오류입니다.");
					}
					$("#comment-list-box-" + noticeId).html(tempHTML);
					$("#list-type-box-" + noticeId).css("display", "none");
					$("#comment-pagination-inner-box-" + noticeId).css("display", "none");
				}
			}
		},
		error: function() {
			modalToggle("#modal-type-4", "오류", "알 수 없는 오류입니다.");
		},
		complete: function() {
			$("#comment-spinner-" + noticeId).removeClass("on");
		}
	});
}
// 댓글 작성
function writeComment(noticeId, boardUserId) {
	var content = $("#comment-" + noticeId).val();
	var boardSubject = $("#subject-" + noticeId).html();
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
					url: "${pageContext.request.contextPath}/customerService/comment/write",
					type: "POST",
					cache: false,
					data: {
						"notice_id" : noticeId,
						"category_id" : "${categoryId}",
						"boardUserId" : boardUserId,
						"boardSubject" : boardSubject, 
						"user_id" : userId,
						"content" : content
					},
					beforeSend: function(xhr) {
						xhr.setRequestHeader(header, token);
					},
					success: function(data, status) {
						if(status == "success") {
							if(data == "Success") {
								$("#comment-" + noticeId).val("");
								var commentPage = $("#comment-page-" + noticeId).val();
								selectComment(noticeId, commentPage);
							} else if(data = "prevention") {								
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
}
// 댓글 추천
function recommendComment(id, type) {
	var userId = "${empty sessionScope.id? 0:sessionScope.id}";
	
	if(userId == 0) {
		modalToggle("#modal-type-2", "확인", "로그인이 필요한 기능입니다.");
		$("#modal-type-2 #2-identify-button").html("로그인");
		$("#modal-type-2 #2-identify-button").attr("onclick", "pageMove('login')");
		return false;
	} else {
		$.ajax({
			url: "${pageContext.request.contextPath}/customerService/comment/recommend",
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
}
// 답글 열기
function replyOn(id, noticeId) {
 	var row = $("#comment-reply-row-" + id).val();
	selectCommentReply(id, row, noticeId);
	if($("#cl-default-" + id).attr("class").indexOf("replyOn") > 0) {
		$("#cl-default-" + id).removeClass("replyOn");
	} else {
		$("#cl-default-" + id).addClass("replyOn");
	}
	$("#reply-list-box-" + id).toggle();
}
// 답글 등록
function writeCommentReply(id, noticeId) {
	var content = $("#comment-reply-content-" + id).val();
	var boardSubject = $("#subject-" + noticeId).html();
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
			if(content.length > 2500) {
				modalToggle("#modal-type-1", "안내", "내용은 2500자 이하로 입력해주세요.");
				return false;
			} else {
				$.ajax({
					url: "${pageContext.request.contextPath}/customerService/commentReply/write",
					type: "POST",
					cache: false,
					data: {
						"category_id" : "${categoryId}",
						"notice_comment_id" : id,
						"notice_id" : noticeId,
						"boardSubject" : boardSubject,
						"user_id" : userId,
						"content" : content
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
								selectCommentReply(id, row, noticeId);
							} else if(data = "prevention") {								
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
}
// 답글 삭제
function deleteCommentReply(commentId, id, noticeId) {
	modalToggle("#modal-type-2", "확인", "정말로 삭제하시겠습니까?");
	$("#modal-type-2 #2-identify-button").attr("onclick", "deleteCommentReplyOk('" + commentId + "', '" + id + "','" + noticeId + "');");
}
function deleteCommentReplyOk(commentId, id, noticeId) {
	var userId = "${empty sessionScope.id? 0:sessionScope.id}";
	
	if(userId == 0) {
		modalToggle("#modal-type-2", "확인", "로그인이 필요한 기능입니다.");
		$("#modal-type-2 #2-identify-button").html("로그인");
		$("#modal-type-2 #2-identify-button").attr("onclick", "pageMove('login')");
		return false;
	} else {
		$.ajax({
			url: "${pageContext.request.contextPath}/customerService/commentReply/deleteOk",
			type: "POST",
			cache: false,
			data: {
				"noticeCommentId" : commentId,
				"id" : id
			},
			beforeSend: function(xhr) {
				xhr.setRequestHeader(header, token);
			},
			success: function(data, status) {
				if(status == "success") {
					if(data == "Success") {
						modalToggle('#modal-type-2');
						var row = $("#comment-reply-row-" + commentId).val();
						selectCommentReply(commentId, row, noticeId);
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
// 답글 불러오기
function selectCommentReply(id, row, noticeId) {
	var replyCount = parseInt($("#reply-count-" + id).html().trim());
	
	if(replyCount != 0) {
		$.ajax({
			url: "${pageContext.request.contextPath}/customerService/commentReply/list",
			type: "POST",
			cache: false,
			data: {
				"noticeCommentId" : id,
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
												tempHTML += "<div class='info-name'><span class='nickname'>" + data.commentReplys[i].nickname + "</span><span class='level'>lv." + data.commentReplys[i].level + "</span></div>";														
											}
											tempHTML += "<div class='info-regdate'>" + commentDateFormat(data.commentReplys[i].register_date) + "</div>";
											tempHTML += "<div class='info-ip'>" + data.commentReplys[i].ip + "</div>";
										tempHTML += "</div>";
										tempHTML += "<s:authorize access='isAuthenticated()'>";
											if(data.commentReplys[i].user_id == parseInt("${empty sessionScope.id? 0:sessionScope.id}")) {
												tempHTML += "<div class='ellipsis' onclick=$('#comment-reply-dropdown-" + data.commentReplys[i].id + "').toggle();>";
													tempHTML += "<i class='fas fa-ellipsis-v'>";
														tempHTML += "<ul id='comment-reply-dropdown-" + data.commentReplys[i].id + "' class='dropdown'>";
															tempHTML += "<li class='dd-default' onclick=deleteCommentReply('" + data.commentReplys[i].notice_comment_id + "','" + data.commentReplys[i].id + "','" + noticeId + "');><i class='fas fa-trash'></i></li>";
														tempHTML += "</ul>";
													tempHTML += "</i>";
												tempHTML += "</div>";
											}
										tempHTML += "</s:authorize>";
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
										tempHTML += "<textarea id='comment-reply-content-" + id + "' placeholder='내용을 입력해주세요.'></textarea><button class='reply-button' onclick=writeCommentReply('" + id + "','" + noticeId + "');>등록</button>";
										tempHTML += "<input type='hidden' id='comment-reply-row-" + id + "' value='" + row + "'/>";
									tempHTML += "</div>";
								tempHTML += "</li>";
							tempHTML += "</s:authorize>";
							tempHTML += "<s:authorize access='!isAuthenticated()'>";
  								tempHTML += "<li class='rl-default'>";
 									tempHTML += "<div class='input-box'>";
										tempHTML += "<div class='not-authenticated'>";
											tempHTML += "<div class='info-circle'><i class='fas fa-info fa-2x'></i></div>";
											tempHTML += "<div class='text'>답글을 등록하려면 로그인이 필요합니다.</div>";
											tempHTML += "<input type='hidden' id='comment-reply-row-" + id + "' value='" + row + "'/>";
  										tempHTML += "</div>";
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
// 게시글 검색
function searchBoard() {
	var searchValue = $("#searchValue").val();
	var searchType = $("#searchType option:selected").val();
	
	if(searchValue == null || searchValue.length == 0) {
		modalToggle("#modal-type-1", "안내", "검색할 내용을 입력해주세요.");
		return false;
	}
	
	searchValue = urlEncode(searchValue);
	location.href = "${pageContext.request.contextPath}/customerService/${categoryId}?page=${pagination.page}&searchValue=" + searchValue + "&searchType=" + searchType;
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
function boardCountFormat() {
	var boardLength = parseInt("${fn:length(boardWrites.boards)}");
	
	for(var i=0; i<boardLength; i++) {
		$("#comment-count-1-"+ i).html($("#comment-count-1-"+ i).html().replace(/\B(?=(\d{3})+(?!\d))/g, ","));
		$("#comment-count-2-"+ i).html($("#comment-count-2-"+ i).html().replace(/\B(?=(\d{3})+(?!\d))/g, ","));
		$("#view-count-"+ i).html($("#view-count-"+ i).html().replace(/\B(?=(\d{3})+(?!\d))/g, ","));
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
//게시글 리스트 등록일시 포맷
function dateFormat() {
	var boardLength = parseInt("${fn:length(boardWrites.boards)}");
	
	for(var i=0; i<boardLength; i++) {
		var nowDate = new Date();
		var boardDate = new Date($("#view-register-date-" + i).html().trim().replace(/-/g, "/").replace(".0", ""));
		
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
			$("#view-register-date-" + i).html(boardHour + ":" + boardMinute);
			$("#new-badge-" + i).addClass("on");
		} else if(nowYear == boardYear) {
			$("#view-register-date-" + i).html(boardMonth + "-" + boardDay);
			$("#new-badge-" + i).remove();
		} else {
			$("#view-register-date-" + i).html((boardYear + "").substring(2, 4) + "-" + boardMonth + "-" + boardDay);		
			$("#new-badge-" + i).remove();
		}
	}
}
</script>
<div class="content-wrapper">
    <div class="content-inner">
        <div class="content-inner-box">
        	<div class="container-fluid">
        		<div class="row">
        			<div class="cs-menu-wrapper col-sm-12 col-lg-3">
        				<ul class="cs-menu">
        					<li class="cm-title">
        						<i class="fas fa-list"></i> 메뉴
        					</li>
        					<li class="cm-default row">
        						<div class="menu col-4 col-sm-4 col-lg-12 ${categoryId=='notice' || (categoryId != 'update' && categoryId != 'event')? 'active':''}" onclick="location.href='${pageContext.request.contextPath}/customerService/notice'">공지사항 <i class="fas fa-check"></i></div>
        						<div class="menu col-4 col-sm-4 col-lg-12 ${categoryId=='update'? 'active':''}" onclick="location.href='${pageContext.request.contextPath}/customerService/update'">업데이트 <i class="fas fa-check"></i></div>
        						<div class="menu col-4 col-sm-4 col-lg-12 ${categoryId=='event'? 'active':''}" onclick="location.href='${pageContext.request.contextPath}/customerService/event'">이벤트 <i class="fas fa-check"></i></div>
        					</li>
        				</ul>
        			</div>
        			<div class="cs-content-wrapper col-sm-12 col-lg-9 animated tdFadeIn">
        				<ul class="cc-content">
        					<li class="cc-title">
        						<c:choose>
        							<c:when test="${categoryId == 'notice'}">
		        						<div class="title">공지사항</div>
		        						<div class="title-sub">APS의 새로운 소식을 전해드립니다.</div>
        							</c:when>
        							<c:when test="${categoryId == 'update'}">
		        						<div class="title">업데이트</div>
		        						<div class="title-sub">APS의 변경/개선점을 안내해드립니다.</div>
        							</c:when>
        							<c:when test="${categoryId == 'event'}">
		        						<div class="title">이벤트</div>
		        						<div class="title-sub">APS에서 진행 중인 이벤트 목록입니다.</div>
        							</c:when>
        							<c:when test="${categoryId == 'write'}">
		        						<div class="title">고객센터 글 작성</div>
		        						<div class="title-sub">회원분들에게 전달할 내용을 작성합니다.</div>
        							</c:when>
        							<c:otherwise>
		        						<div class="title">공지사항</div>
		        						<div class="title-sub">APS의 새로운 소식을 전해드립니다.</div>
        							</c:otherwise>
        						</c:choose>
        					</li>
        					<c:choose>
        						<c:when test="${categoryId == 'write' || categoryId == 'modify'}">
		        					<li class="cc-write">
		        						<form id="writeForm" action="${categoryId=='write'? 'writeOk':pageContext.request.contextPath += '/customerService/modifyOk'}" method="post">
			        						<div class="row">
			        							<div class="category-box col-4">
			        								<div class="category" onclick="setCategory(this);">공지사항
			        								<input type="radio" name="category_id" id="category_id" value="notice"/>
			        								</div>
			        							</div>
			        							<div class="category-box col-4">
			        								<div class="category" onclick="setCategory(this);">업데이트
			        								<input type="radio" name="category_id" id="category_id" value="update"/>
			        								</div>
			        							</div>
			        							<div class="category-box col-4">
			        								<div class="category last" onclick="setCategory(this);">이벤트
			        								<input type="radio" name="category_id" id="category_id" value="event"/>
			        								</div>
			        							</div>
			        						</div>
			        						<div class="subject-input">
			        							<input type="text" id="subject" name="subject" value="${board.subject}" placeholder="제목을 입력해주세요."/>
			        						</div>
			        						<div class="content-input">
			        							<textarea id="content" name="content">${board.content}</textarea>
			        						</div>
						                    <input type="hidden" id="image_flag" name="image_flag" value="0"/>
						                    <input type="hidden" id="media_flag" name="media_flag" value="0"/>
						                    <c:if test="${categoryId == 'modify'}">
							                    <input type="hidden" id="id" name="id" value="${board.id}"/>
							                    <%-- <input type="hidden" id="category_id" name="category_id" value="${board.category_id}"/> --%>
						                    </c:if>
						                    <input type="hidden" id="user_id" name="user_id" value="${empty sessionScope.id? 0:sessionScope.id}"/>
						                    <s:csrfInput/>
		        						</form>
		        					</li>
        						</c:when>
        						<c:otherwise>
        							<c:choose>
        								<c:when test="${not empty boardWrites.boards}">
        									<c:forEach var="i" varStatus="index" items="${boardWrites.boards}">
					        					<li id="cc-default-${i.id}" class="cc-default" onclick="openContent('${i.id}');">
					        						<div class="top">
														<div class="type normal">일반</div>
														<div class="subject-box">
															<div id="subject-${i.id}" class="subject">${i.subject}</div>
															<div id="info-${i.id}" class="info">
																[<span id="comment-count-1-${index.index}">${i.commentCount}</span>]
																<c:if test="${i.image_flag == true}">
																	<i class="fas fa-image"></i>
																</c:if>
																<c:if test="${i.media_flag == true}">
																	<i class="fas fa-video"></i>
																</c:if>
															</div>
														</div>
					        						</div>
					        						<div class="bottom">
														<div class="writer">
															<c:choose>
																<c:when test="${not empty i.profile}">
																	<img class="img-fluid" src="https://kr.object.ncloudstorage.com/aps/profile/${i.profile}"/> 
																</c:when>
																<c:otherwise>
																	<i class="far fa-user"></i>
																</c:otherwise>
															</c:choose>
															<span class="nickname">${i.nickname}</span>
															<c:choose>
																<c:when test="${i.userType == 10}">
																	<span class="master">M</span>
																</c:when>
																<c:otherwise>
																	<span class="level">Lv.${i.level}</span>
																</c:otherwise>
															</c:choose>
														</div>
														<div class="other-info">
															<div id="new-badge-${index.index}" class="new-badge">NEW</div>
															<div id="view-register-date-${index.index}">${i.register_date}</div>
															<div id="view-count-box-${i.id}">조회 <span id="view-count-${index.index}">${i.view}</span></div>
														</div>
					        						</div>
					        						<div id="cc-view-${i.id}" class="view animated tdFadeInDown">
					        							<div class="view-content">
					        								${i.content}
					        							</div>
					        							<div class="comment-count">
					                        				<i class="fas fa-comments"></i>&nbsp;댓글&nbsp;<span id="comment-count-2-${index.index}">${i.commentCount}</span>개
					        							</div>
					        							<s:authorize access="hasAnyRole('ROLE_USER', 'ROLE_ADMIN')">
						        							<div class="comment-input">
						        								<div><textarea id="comment-${i.id}" placeholder="내용을 입력해주세요."></textarea></div>
						        								<div class="button"><button class="aps-button" onclick="writeComment('${i.id}','${i.user_id}')">등록</button></div>
						        							</div>
					        							</s:authorize>
					        							<s:authorize access="!isAuthenticated()">
			        										<div class="info-circle"><i class="fas fa-info fa-2x"></i></div>
			        										<div class="text">댓글을 등록하려면 로그인이 필요합니다.</div>
					        							</s:authorize>
														<div class="comment-list-wrapper border-bottom-none margin-bottom">
														    <div class="comment-list-inner">
														        <div class="comment-list-inner-box margin-bottom-box">
														        	<div id="comment-spinner-${i.id}" class="comment-spinner on animated tdFadeIn">
																		<div class="sk-folding-cube">
																		  <div class="sk-cube1 sk-cube"></div>
																		  <div class="sk-cube2 sk-cube"></div>
																		  <div class="sk-cube4 sk-cube"></div>
																		  <div class="sk-cube3 sk-cube"></div>
																		</div>
														        	</div>
														            <div id="list-type-box-${i.id}" class="list-type-box">
														                <div class="list-type">
																			<span id="comment-list-type-${i.id}-new" class="active" onclick="setCommentListType('${i.id}','new');"><i class="fas fa-check"></i> 최신순</span>
																			<span id="comment-list-type-${i.id}-popular" onclick="setCommentListType('${i.id}','popular');"><i class="fas fa-check"></i> 인기순</span>
																			<input type="hidden" id="comment-list-type-${i.id}" value="new"/>
														                </div>
														            </div>
								        							<div id="comment-list-box-${i.id}" class="comment-list-box">
<%-- 														                 <ul class="comment-list">
														                    <li class="cl-default">
														                        <div class="comment-box">
														                            <div class="comment-title">
														                                <div class="comment-info">
														                                    <div class="info-image"><i class="far fa-user fa-2x"></i></div>
														                                    <div class="info-name"><span class="nickname">테스트</span><span class="level">lv.1</span></div>
														                                    <div class="info-regdate">2019-06-17 01:12</div>
														                                    <div class="info-ip">123.123.***.***</div>
														                                </div>
														                                <div class="ellipsis">
														                                    <i class="fas fa-ellipsis-v">
															                                    <ul class="dropdown">
															                                    	<li class="dd-default"><i class="fas fa-pen"></i></li>
															                                    	<li class="dd-default"><i class="fas fa-trash"></i></li>
															                                    </ul>                   									                                    
														                                    </i>
														                                </div>
														                            </div>
														                            <div class="comment-content">
														                                <span class="icon">BEST</span><span class="content">안녕하세요. 댓글 입력입니다.</span>
														                            </div>
														                            <div class="mobile-comment-info">
														                                <div class="mobile-info-regdate">2019-06-17 01:12</div>
														                                <div class="mobile-info-ip">123.123.***.***</div>
														                            </div>
														                            <div class="comment-function">
														                                <div class="reply-box">
														                                    <div class="reply-button">답글(<span id="reply-count-${i.id}">0</span>)</div>
														                                </div>
														                                <div class="recommend-box">
														                                    <div class="up"><i class="far fa-thumbs-up"></i> <span>0</span></div>
														                                    <div class="down"><i class="far fa-thumbs-down"></i> <span>0</span></div>
														                                </div>
														                            </div>
														                        </div>
														                    </li>
														                    <li class="reply-list-box">
														                        <ul class="reply-list">
														                            <li class="rl-default">
														                                <div class="comment-box">
														                                    <div class="comment-title">
														                                        <div class="comment-info">
														                                            <div class="info-image"><i class="far fa-user fa-2x"></i></div>
														                                            <div class="info-name"><span class="nickname">테스트</span><span class="level">lv.1</span></div>
														                                            <div class="info-regdate">2019-06-17 01:12</div>
														                                            <div class="info-ip">123.123.***.***</div>
														                                        </div>
														                                        <div class="ellipsis">
														                                            <i class="fas fa-ellipsis-v"></i>
														                                            <ul class="dropdown">
														                                            	<li class="dd-default"><i class="fas fa-pen"></i></li>
														                                            	<li class="dd-default"><i class="fas fa-trash"></i></li>
														                                            </ul>                            
														                                        </div>
														                                    </div>
														                                    <div class="comment-content">
														                                        <span class="reply-id"></span><span class="content">안녕하세요. 댓글 입력입니다.</span>
														                                    </div>
														                                    <div class="mobile-comment-info">
														                                        <div class="mobile-info-regdate">2019-06-17 01:12</div>
														                                        <div class="mobile-info-ip">123.123.***.***</div>
														                                    </div>
														                                </div>
														                            </li>
														                            <li class="rl-default">
														                                <div class="comment-box">
														                                    <div class="comment-title">
														                                        <div class="comment-info">
														                                            <div class="info-image"><i class="far fa-user fa-2x"></i></div>
														                                            <div class="info-name"><span class="nickname">테스트</span><span class="level">lv.1</span></div>
														                                            <div class="info-regdate">2019-06-17 01:12</div>
														                                            <div class="info-ip">123.123.***.***</div>
														                                        </div>
														                                        <div class="ellipsis">
														                                            <i class="fas fa-ellipsis-v"></i>
														                                            <ul class="dropdown">
														                                            	<li class="dd-default"><i class="fas fa-pen"></i></li>
														                                            	<li class="dd-default"><i class="fas fa-trash"></i></li>
														                                            </ul>           
														                                        </div>
														                                    </div>
														                                    <div class="comment-content">
														                                        <span class="reply-id"></span><span class="content">안녕하세요. 댓글 입력입니다.</span>
														                                    </div>
														                                    <div class="mobile-comment-info">
														                                        <div class="mobile-info-regdate">2019-06-17 01:12</div>
														                                        <div class="mobile-info-ip">123.123.***.***</div>
														                                    </div>
														                                </div>
														                            </li>
														                            <li class="rl-default add-list">더 보기 <i class="fas fa-caret-down"></i></li>
														                            <li class="rl-default">
														                                <div class="input-box">
														                                    <textarea placeholder="내용을 입력해주세요."></textarea><button class="reply-button">등록</button>
														                                </div>
														                            </li>
														                        </ul>
														                    </li>
														                </ul> --%>
								        							</div>
														        </div>
															</div>
					        							</div>
														<div class="comment-pagination-wrapper">
														    <div class="comment-pagination-inner">
														        <div id="comment-pagination-inner-box-${i.id}" class="comment-pagination-inner-box animated tdFadeIn">
														            <ul class="pagination-list">
														            	<li class="pt-default active">1</li>
														            </ul>
														        </div>
														        <input type="hidden" id="comment-page-${i.id}" value="1"/>
														    </div>
														</div>
														<div class="view-function">
															<button class="aps-button" onclick="closeContent('${i.id}');"><i class="fas fa-caret-up"></i> 숨김</button>
															<s:authorize access="hasRole('ROLE_ADMIN')">
																<c:if test="${sessionScope.id == i.user_id}">
																	<button class="aps-button" onclick="location.href='${pageContext.request.contextPath}/customerService/modify/${i.id}?categoryId=${categoryId}'"><i class="fas fa-edit"></i> 수정</button><button class="aps-button" onclick="deleteBoardWrite('${i.id}');"><i class="fas fa-trash-alt"></i> 삭제</button>
																</c:if>
															</s:authorize>
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
        						</c:otherwise>
        					</c:choose>
        				</ul>
	                    <div class="function-wrapper">
	                    	<c:choose>
	                    		<c:when test="${categoryId == 'write' || categoryId == 'modify'}">
			                    	<s:authorize access="hasRole('ROLE_ADMIN')">
			                        	<button class="aps-button write" onclick="history.back();">이전</button>
			                        	<button type="submit" class="aps-button write" onclick="validWrite();">완료</button>
			                    	</s:authorize>
	                    		</c:when>
	                    		<c:otherwise>
			                    	<s:authorize access="hasRole('ROLE_ADMIN')">
			                        	<button class="aps-button" onclick="location.href='${pageContext.request.contextPath}/customerService/write'"><i class="fas fa-pen"></i> 글쓰기</button>
			                    	</s:authorize>
	                    		</c:otherwise>
	                    	</c:choose>
	                    </div>
	                    <c:if test="${categoryId != 'write'}">
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
	                                <input type="text" id="searchValue" value="${param.searchValue}" onkeypress="if(event.keyCode==13) { searchBoard(); }"/>
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
</div>
<jsp:include page="/resources/include/footer.jsp"/>
<jsp:include page="/resources/include/modals.jsp"/>
<jsp:include page="/resources/include/mobile/sidebar.jsp"/>
<c:if test="${categoryId == 'write' || categoryId == 'modify'}">
<script>
ClassicEditor
	.create(document.querySelector("#content"), {
	    placeholder: "내용을 입력해주세요.",
		ckfinder: {
	        uploadUrl: '${pageContext.request.contextPath}/customerService/write/imageUpload?${_csrf.parameterName}=${_csrf.token}'
	    }
	})
	.then( editor => {
	    myEditor = editor;
	})
	.catch(error => {
	console.error(error);
});
</script>
</c:if>
</body>
</html>