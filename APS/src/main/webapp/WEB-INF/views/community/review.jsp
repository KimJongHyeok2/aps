<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>민심평가(${broadcaster.nickname}) : APS</title>
<meta property="og:title" content="민심평가(${broadcaster.nickname}) : APS"/>
<meta name="author" content="아프리카 민심"/>
<meta name="description" content="인터넷방송 플랫폼 아프리카TV 커뮤니티 ${braodcaster.nickname} 민심평가"/>
<meta property="og:description" content="인터넷방송 플랫폼  아프리카TV 커뮤니티 ${braodcaster.nickname} 민심평가"/>
<meta property="og:image" content="https://www.afreecaps.com/resources/image/logo/header_logo.png"/>
<link rel="canonical" href="https://www.afreecaps.com/community/review/${broadcaster.id}">
<meta property="og:url" content="https://www.afreecaps.com/community/review/${broadcaster.id}"/>
<meta property="og:type" content="website">
<jsp:include page="/resources/include/common/common_css.jsp"/>
<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/resources/css/include/common.css">
<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/resources/css/community/review.css">
<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/resources/css/community/comment.css">
<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/resources/css/api/jquery.rateyo.css">
<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/sockjs-client/1.1.5/sockjs.min.js"></script>
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
<script src="https://cdn.jsdelivr.net/npm/chart.js@2.8.0"></script>
<script src="${pageContext.request.contextPath}/resources/js/api/jquery.rateyo.js"></script>
<script>
var header = $("meta[name='_csrf_header']").attr("content");
var token = $("meta[name='_csrf']").attr("content");
var reviewChart;
var reviewSocketSendFlag = false;
$(document).ready(function() {
    $("#rate").rateYo({
       starWidth: "30px",
       normalFill: "rgb(246, 246, 246)",
       ratedFill: "#F2CB61",
       onChange: function (rating, rateYoInstance) {
          $(this).next().text(rating);
       }
    });
    selectReviewGradePointAverage();
    selectReview();
    $('[data-toggle="conn-users-tooltip"]').tooltip();
});
function popUp(url) {
	var pop = window.open(url, "pop", "scrollbars=yes, resizable=yes");
}
function selectReviewGradePointAverage() {
	var broadcasterId = "${broadcaster.id}";
	var chartType = $("#chartType").val();
	var dataType = $("#dataType").val();

	$.ajax({
		url: "${pageContext.request.contextPath}/community/review/gpa",
		type: "POST",
		data: {
			"broadcasterId" : broadcasterId,
			"dataType" : dataType
		},
		beforeSend: function(xhr) {
			xhr.setRequestHeader(header, token);
		},
		success: function(data, status) {
			if(status == "success") {
				var labels = new Array();
				var datas = new Array();
				for(var i=0; i<data.count; i++) {
					labels.push(data.gradePointAverages[i].gp_date);
					datas.push(data.gradePointAverages[i].gp_avg);
				}
				setChart(labels, datas, chartType);
			}
		},
		error: function() {
			modalToggle("#modal-type-4", "오류", "알 수 없는 오류입니다.");
		}
	});
}
function setChart(labels, datas, chartType) {
	/* 민심 차트 */
	$("#chart-content").html("<canvas id='reviewChart'></canvas>");
    var ctx = $("#reviewChart");
    if(chartType == "line") {
	    reviewChart = new Chart(ctx, {
	        type: chartType,
	        data: {
	            labels: labels,
	            datasets: [{
	                label: '민심 평균',
	                data: datas,
	                backgroundColor: 'rgba(0, 0, 0, 0)',
	                borderColor: 'rgba(5, 69, 177, 0.7)',
	                borderWidth: 2
	            }]
	        },
	        options: {
	            scales: {
	                yAxes: [{
	                    ticks: {
	                        beginAtZero: true
	                    }
	                }]
	            },
	            legend: {
	            	labels: {
	            		fontFamily: "나눔바른고딕"
	            	}
	            }
	        }
	    });    	
    } else {
	    reviewChart = new Chart(ctx, {
	        type: chartType,
	        data: {
	            labels: labels,
	            datasets: [{
	                label: '민심 평균',
	                data: datas,
	                backgroundColor: [
/* 	                	'rgba(5, 69, 177, 0.3)',
	                	'rgba(54, 162, 235, 0.3)',
	                	'rgba(255, 206, 86, 0.3)',
	                	'rgba(255, 99, 132, 0.3)',
	                	'rgba(75, 192, 192, 0.3)',
	                	'rgba(153, 102, 255, 0.3)',
	                	'rgba(250, 237, 125, 0.3)',
	                	'rgba(12, 86, 42, 0.3)',
	                	'rgba(64, 58, 0, 0.3)',
	                	'rgba(189, 189, 189, 0.3)',
	                	'rgba(103, 153, 255, 0.3)',
	                	'rgba(47, 157, 39, 0.3)' */
	                	'rgba(5, 69, 177, 0.1)',
	                	'rgba(5, 69, 177, 0.1)',
	                	'rgba(5, 69, 177, 0.2)',
	                	'rgba(5, 69, 177, 0.2)',
	                	'rgba(5, 69, 177, 0.3)',
	                	'rgba(5, 69, 177, 0.4)',
	                	'rgba(5, 69, 177, 0.5)',
	                	'rgba(5, 69, 177, 0.6)',
	                	'rgba(5, 69, 177, 0.7)',
	                	'rgba(5, 69, 177, 0.8)',
	                	'rgba(5, 69, 177, 0.9)',
	                	'rgba(5, 69, 177, 1)'
	                ],
	                borderWidth: 1
	            }]
	        },
	        options: {
	            scales: {
	                yAxes: [{
	                    ticks: {
	                        beginAtZero: true
	                    }
	                }]
	            },
	            legend: {
	            	labels: {
	            		fontFamily: "나눔바른고딕"
	            	}
	            }
	        }
	    });
    }
}
function setChartType(obj, chartType) {
	$("#chartType").val(chartType);
	$(".chart-type").removeClass("active");
	if(!($(obj).attr("class").indexOf("active") >= 0)) {
		$(obj).addClass("active");
	}
	selectReviewGradePointAverage();
}
function setDataType(obj, dataType) {
	$("#dataType").val(dataType);
	$(".data-type").removeClass("active");
	if(!($(obj).attr("class").indexOf("active") >= 0)) {
		$(obj).addClass("active");
	}
	selectReviewGradePointAverage();
}
function writeReview() {
	var rating = $("#rate").rateYo("option", "rating");
	var content = $("#comment").val();
	var broadcasterId = "${broadcaster.id}";
	var userId = "${empty sessionScope.id? 0:sessionScope.id}";
	
	if(userId == 0) {
		modalToggle("#modal-type-2", "확인", "로그인이 필요한 기능입니다.");
		$("#modal-type-2 #2-identify-button").html("로그인");
		$("#modal-type-2 #2-identify-button").attr("onclick", "pageMove('login')");
		return false;
	} else {
		if(rating == 0) {
			modalToggle("#modal-type-1", "안내", "0점 이상을 입력해주세요.");
			return false;
		}
		if(content == null || content.length == 0) {
			modalToggle("#modal-type-1", "안내", "의견을 입력해주세요.");
			return false;
		} else {
			if(content.length > 5000) {
				modalToggle("#modal-type-1", "안내", "의견은 5000자 이하로 입력해주세요.");
				return false;
			} else {
				$.ajax({
					url: "${pageContext.request.contextPath}/community/review/write",
					type: "POST",
					cache: false,
					data: {
						"broadcaster_id" : broadcasterId,
						"user_id" : userId,
						"gp" : rating,
						"content" : content
					},
					beforeSend: function(xhr) {
						xhr.setRequestHeader(header, token);
					},
					success: function(data, status) {
						if(status == "success") {
							if(data == "Success") {
								$("#comment").val("");
								$("#rate").rateYo("option", "rating", 0);
								$("#counter").html("0");
								selectReview();
								setTimeout(function() { selectReviewGradePointAverage() }, 1000);
								reviewSocket.send("write,${broadcaster.id}");
							} else if(data == "Already Review Write") {
								modalToggle("#modal-type-1", "안내", "오늘은 이미 해당 BJ의 민심평가를 진행하셨습니다.");
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
//댓글 수정
function modifyReview(id) {
	var pop = window.open("${pageContext.request.contextPath}/community/review/modify/" + id + "?broadcasterId=${broadcaster.id}", "pop", "width=500, height=712, scrollbars=yes, resizable=yes");
}
function modifyReviewOk(data) {
	if(data == "Success") {
 		var commentPage = $("#comment-page").val();
		selectReview(commentPage);
	}
}
function deleteReview(id) {
	modalToggle("#modal-type-2", "확인", "정말로 삭제하시겠습니까?");
	$("#modal-type-2 #2-identify-button").attr("onclick", "deleteReviewOk('" + id + "');");
}
function deleteReviewOk(id) {
	var broadcasterId = "${broadcaster.id}";
	var userId = "${empty sessionScope.id? 0:sessionScope.id}";

	if(userId == 0) {
		modalToggle("#modal-type-2", "확인", "로그인이 필요한 기능입니다.");
		$("#modal-type-2 #2-identify-button").html("로그인");
		$("#modal-type-2 #2-identify-button").attr("onclick", "pageMove('login')");
		return false;
	} else {
		$.ajax({
			url: "${pageContext.request.contextPath}/community/review/deleteOk",
			type: "POST",
			cache: false,
			data: {
				"broadcasterId" : broadcasterId,
				"id" : id
			},
			beforeSend: function(xhr) {
				xhr.setRequestHeader(header, token);
			},
			success: function(data, status) {
				if(status == "success") {
					if(data == "Success") {
						modalToggle('#modal-type-2');
						selectReview();
						setTimeout(function() { selectReviewGradePointAverage() }, 1000);
						reviewSocket.send("write,${broadcaster.id}");
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
// 평가 불러오기
function selectReview(page) {
	var listType1 = $("#list-type1").val();
	var listType2 = $("#list-type2").val();
	var broadcasterId = "${broadcaster.id}";
	
	$("#list-type-box").css("display", "none");
	$("#comment-pagination-inner-box").css("display", "none");
	
	if(page == null) {
		page = 1;
	}
	
	$("#comment-spinner").addClass("on");
	$("#comment-list-box").html("");
	setTimeout(function() {
	$.ajax({
		url: "${pageContext.request.contextPath}/community/review/list",
		type: "POST",
		cache: false,
		data: {
			"broadcasterId" : broadcasterId,
			"listType1" : listType1,
			"listType2" : listType2,
			"page" : page
		},
		beforeSend: function(xhr) {
			xhr.setRequestHeader(header, token);
		},
		success: function(data, status) {
			if(status == "success") {
				if(data.status == "Success" && data.count != 0) {
					var tempHTML = "";
					var countFlag = false;
					for(var i=0; i<data.count; i++) {
						if(data.comments[i].status == 1) {
							countFlag = true;
							tempHTML += "<ul class='comment-list animated tdFadeIn'>";
								tempHTML += "<li id='cl-default-" + data.comments[i].id + "' class='cl-default'>";
										tempHTML += "<div class='comment-box'>";
											tempHTML += "<div class='comment-title'>";
												if(listType2 == "popular" && data.comments[i].no <= 3) {
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
													tempHTML += "<div class='info-regdate'>" + reviewDateFormat(data.comments[i].register_date) + "</div>";
													tempHTML += "<div class='info-ip'>" + data.comments[i].ip + "</div>";
												tempHTML += "</div>";
												tempHTML += "<s:authorize access='isAuthenticated()'>";
													if(data.comments[i].user_id == parseInt("${empty sessionScope.id? 0:sessionScope.id}")) {
														tempHTML += "<div class='ellipsis' onclick=$('#comment-dropdown-" + data.comments[i].id + "').toggle();>";
															tempHTML += "<i class='fas fa-ellipsis-v'>";
																tempHTML += "<ul class='dropdown' id='comment-dropdown-" + data.comments[i].id + "'>";
																	tempHTML += "<li class='dd-default' onclick=modifyReview('" + data.comments[i].id + "');><i class='fas fa-pen'></i></li>";
																	tempHTML += "<li class='dd-default' onclick=deleteReview('" + data.comments[i].id + "');><i class='fas fa-trash'></i></li>";
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
												tempHTML += "<div class='mobile-info-regdate'>" + reviewDateFormat(data.comments[i].register_date) + "</div>";
												tempHTML += "<div class='mobile-info-ip'>" + data.comments[i].ip + "</div>";
											tempHTML += "</div>";
											tempHTML += "<div class='comment-function'>";
												tempHTML += "<div class='reply-box'>";
													tempHTML += "<button class='reply-button' onclick='replyOn(" + data.comments[i].id + ")'>답글(<span id='reply-count-" + data.comments[i].id + "'>" + countFormat(data.comments[i].replyCount) + "</span>)</button>";
													tempHTML += "<div class='gp'><i class='fas fa-star'></i> " + data.comments[i].gp + "</div>";
												tempHTML += "</div>";
												tempHTML += "<div class='recommend-box'>";
													/* tempHTML += "<div class='gp'><i class='fas fa-star'></i> " + data.comments[i].gp + "</div>"; */
													tempHTML += "<div class='up " + (data.comments[i].type==1? "active":"") + "' onclick=recommendReview('" + data.comments[i].id + "','up');><i class='far fa-thumbs-up'></i> <span id='comment-up-" + data.comments[i].id + "'>" + countFormat(data.comments[i].up) + "</span></div>";
													tempHTML += "<div class='down " + (data.comments[i].type==2? "active":"") + "' onclick=recommendReview('" + data.comments[i].id + "','down');><i class='far fa-thumbs-down'></i> <span id='comment-down-" + data.comments[i].id + "'>" + countFormat(data.comments[i].down) + "</span></div>";
												tempHTML += "</div>";
											tempHTML += "</div>";
										tempHTML += "</div>";
									tempHTML += "</li>";
									tempHTML += "<li id='reply-list-box-" + data.comments[i].id + "' class='reply-list-box'>";
									tempHTML += "<s:authorize access='isAuthenticated()'>";
										tempHTML += "<ul class='reply-list'>";
											tempHTML += "<li class='rl-default'>";
												tempHTML += "<div class='input-box'>";
													tempHTML += "<textarea id='comment-reply-content-" + data.comments[i].id + "' placeholder='내용을 입력해주세요.'></textarea><button class='reply-button' onclick='writeReviewReply(" + data.comments[i].id + ");'>등록</button>";
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
														tempHTML += "<div class='reply-button' onclick='replyOn(" + data.comments[i].id + ")'>답글(<span id='reply-count-" + data.comments[i].id + "'>" + countFormat(data.comments[i].replyCount) + "</span>)</div>";
														tempHTML += "<div class='gp'><i class='fas fa-star'></i> " + data.comments[i].gp + "</div>";
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
 					tempHTML = "";
					tempHTML += "<ul class='pagination-list'>";
					if(data.pagination.startPage > data.pagination.pageBlock) {
						tempHTML += "<li class='pt-default' onclick='selectReview(" + (data.pagination.startPage - data.pagination.pageBlock) + ");'><i class='fas fa-chevron-left'></i></li>"; 
					}
					for(var i=data.pagination.startPage; i<=data.pagination.endPage; i++) {
						if(i == data.pagination.page) {
							tempHTML += "<li class='pt-default active'>" + i + "</li>";
							$("#comment-page").val(i);
						} else {
							tempHTML += "<li class='pt-default' onclick='selectReview(" + i + ");'>" + i + "</li>";
						}
					}
					if(data.pagination.endPage < data.pagination.pageCount) {
						tempHTML += "<li class='pt-default' onclick='selectReview(" + (data.pagination.startPage + data.pagination.pageBlock) + ");'><i class='fas fa-chevron-right'></i></li>"; 
					}
					tempHTML += "</ul>";
					$("#comment-pagination-inner-box").html(tempHTML);
				} else {
					var tempHTML = "";
					tempHTML += "<ul class='comment-list animated tdFadeIn'>";
						tempHTML += "<li class='cl-default empty-comment'>";
							tempHTML += "<div class='comment-box'>";
								tempHTML += "<div class='info-circle'>";
									tempHTML += "<i class='fas fa-comment-alt fa-2x'></i>";
								tempHTML += "</div>";
								tempHTML += "<div class='text'>";
									tempHTML += "등록된 평가가 없습니다.";
								tempHTML += "</div>";
							tempHTML += "</div>";
						tempHTML += "</li>";
					tempHTML += "</ul>";
					$("#comment-list-box").html(tempHTML);
					/* $("#list-type-box").css("display", "none"); */
					$("#comment-pagination-inner-box").css("display", "none");
				}
				$("#review-count").html(countFormat(data.reviewCount));
			}
		},
		error: function() {
			modalToggle("#modal-type-4", "오류", "알 수 없는 오류입니다.");
		},
		complete: function() {
			$("#comment-spinner").removeClass("on");
		}
	});
	}, 2000);
}
// 평가 추천
function recommendReview(id, type) {
	var broadcasterId = "${broadcaster.id}";
	var userId = "${empty sessionScope.id? 0:sessionScope.id}";
	
	if(userId == 0) {
		modalToggle("#modal-type-2", "확인", "로그인이 필요한 기능입니다.");
		$("#modal-type-2 #2-identify-button").html("로그인");
		$("#modal-type-2 #2-identify-button").attr("onclick", "pageMove('login')");
		return false;
	} else {
		$.ajax({
			url: "${pageContext.request.contextPath}/community/review/recommend",
			type: "POST",
			cache: false,
			data: {
				"broadcasterId" : broadcasterId,
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
// 평가 목록 타입
function setReviewListType1(obj, listType) {
	$(".cl-default").removeClass("active");
	$(obj).addClass("active");
	$("#list-type1").val(listType);
	setReviewListType2("new");
	/* selectReview(); */
}
// 평가 정렬 타입
function setReviewListType2(listType) {
	$("#list-type2").val(listType);
	if(listType == "popular") {
		$("#comment-list-type-" + listType).addClass("active");
		$("#comment-list-type-new").removeClass("active");
	} else {
		$("#comment-list-type-" + listType).addClass("active");
		$("#comment-list-type-popular").removeClass("active");		
	}
	selectReview();
}
// 답글 열기
function replyOn(id) {
 	var row = $("#comment-reply-row-" + id).val();
	selectReviewReply(id, row);
	if($("#cl-default-" + id).attr("class").indexOf("replyOn") > 0) {
		$("#cl-default-" + id).removeClass("replyOn");
	} else {
		$("#cl-default-" + id).addClass("replyOn");
	}
	$("#reply-list-box-" + id).toggle();
}
// 평가 답글 삭제
function deleteReviewReply(reviewId, id) {
	modalToggle("#modal-type-2", "확인", "정말로 삭제하시겠습니까?");
	$("#modal-type-2 #2-identify-button").attr("onclick", "deleteReviewReplyOk('" + reviewId + "','" + id + "');");
}
function deleteReviewReplyOk(reviewId, id) {
	var userId = "${empty sessionScope.id? 0:sessionScope.id}";

	if(userId == 0) {
		modalToggle("#modal-type-2", "확인", "로그인이 필요한 기능입니다.");
		$("#modal-type-2 #2-identify-button").html("로그인");
		$("#modal-type-2 #2-identify-button").attr("onclick", "pageMove('login')");
		return false;
	} else {
		$.ajax({
			url: "${pageContext.request.contextPath}/community/reviewReply/deleteOk",
			type: "POST",
			cache: false,
			data: {
				"broadcasterReviewId" : reviewId,
				"id" : id
			},
			beforeSend: function(xhr) {
				xhr.setRequestHeader(header, token);
			},
			success: function(data, status) {
				if(status == "success") {
					if(data == "Success") {
						modalToggle('#modal-type-2');
						var row = $("#comment-reply-row-" + reviewId).val();
						selectReviewReply(reviewId, row);
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
function selectReviewReply(id, row) {
	var replyCount = parseInt($("#reply-count-" + id).html().trim());
	
	if(replyCount != 0) {
		$.ajax({
			url: "${pageContext.request.contextPath}/community/reviewReply/list",
			type: "POST",
			cache: false,
			data: {
				"broadcasterReviewId" : id,
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
											tempHTML += "<div class='info-regdate'>" + reviewDateFormat(data.commentReplys[i].register_date) + "</div>";
											tempHTML += "<div class='info-ip'>" + data.commentReplys[i].ip + "</div>";
										tempHTML += "</div>";
										tempHTML += "<s:authorize access='isAuthenticated()'>";
											if(data.commentReplys[i].user_id == parseInt("${empty sessionScope.id? 0:sessionScope.id}")) {
												tempHTML += "<div class='ellipsis' onclick=$('#comment-reply-dropdown-" + data.commentReplys[i].id + "').toggle();>";
													tempHTML += "<i class='fas fa-ellipsis-v'>";
														tempHTML += "<ul id='comment-reply-dropdown-" + data.commentReplys[i].id + "' class='dropdown'>";
															tempHTML += "<li class='dd-default' onclick='deleteReviewReply(" + data.commentReplys[i].broadcaster_review_id + ", " + data.commentReplys[i].id + ");'><i class='fas fa-trash'></i></li>";
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
										tempHTML += "<div class='mobile-info-regdate'>" + reviewDateFormat(data.commentReplys[i].register_date) + "</div>";
										tempHTML += "<div class='mobile-info-ip'>" + data.commentReplys[i].ip + "</div>";
									tempHTML += "</div>";
								tempHTML += "</div>";
							tempHTML += "</li>";
						}
						if(data.replyCount > data.count) {
							tempHTML += "<li class='rl-default add-list' onclick='addReviewReply(" + id + ")'>더 보기 <i class='fas fa-caret-down'></i></li>";	
						}
						var commentStatus = $("#comment-status-" + id).val();
						if(commentStatus == 1) {
							tempHTML += "<s:authorize access='isAuthenticated()'>";
								tempHTML += "<li class='rl-default'>";
									tempHTML += "<div class='input-box'>";
										tempHTML += "<textarea id='comment-reply-content-" + id + "' placeholder='내용을 입력해주세요.'></textarea><button class='reply-button' onclick='writeReviewReply(" + id + ");'>등록</button>";
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
function addReviewReply(id) {
	$("#comment-reply-row-" + id).val(parseInt($("#comment-reply-row-" + id).val()) + 10);
	var row = $("#comment-reply-row-" + id).val();
	selectReviewReply(id, row);
}
// 답글 등록
function writeReviewReply(id) {
	var content = $("#comment-reply-content-" + id).val();
	var broadcasterId = "${broadcaster.id}";
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
					url: "${pageContext.request.contextPath}/community/reviewReply/write",
					type: "POST",
					cache: false,
					data: {
						"broadcaster_id" : broadcasterId,
						"broadcaster_review_id" : id,
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
								selectReviewReply(id, row);
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
function countFormat(value) {
	return (value + "").replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}
// 평가 등록일시 포맷
function reviewDateFormat(date) {
	var reviewDate = new Date(date);
	
	var reviewYear = reviewDate.getFullYear();
	var reviewMonth = reviewDate.getMonth()+1;
	reviewMonth = ((reviewMonth + "").length == 1? ("0" + reviewMonth):reviewMonth);
	var reviewDay = reviewDate.getDate();
	reviewDay = ((reviewDay + "").length == 1? ("0" + reviewDay):reviewDay);
	var reviewHour = reviewDate.getHours();
	reviewHour = ((reviewHour + "").length == 1? ("0" + reviewHour):reviewHour);
	var reviewMinute = reviewDate.getMinutes();
	reviewMinute = ((reviewMinute + "").length == 1? ("0" + reviewMinute):reviewMinute);
	
	return reviewYear + "-" + reviewMonth + "-" + reviewDay + " " + reviewHour + ":" + reviewMinute;
}
</script>
<!-- 해당 방송인 정보 -->
<div class="user-wrapper">
    <div class="user-inner">
        <div class="user-inner-box">
            <div class="container">
                <div class="row">
                    <div class="profile-img col-4 col-sm-3">
                    	<c:choose>
                    		<c:when test="${not empty broadcaster.profile}">
                    			<img class="img-fluid" src="${pageContext.request.contextPath}/resources/image/broadcaster/${broadcaster.profile}"/>
                    		</c:when>
                    		<c:otherwise>
                    			<i class="far fa-user fa-10x"></i>
                    		</c:otherwise>
                    	</c:choose>
                        <div class="medal">
                        	<c:if test="${broadcaster.best_flag == true}">
                            	<span class="best">B</span>
                        	</c:if>
                        	<c:if test="${broadcaster.partner_flag == true}">
	                            <span class="partner">P</span>
                        	</c:if>
                        </div>
                    </div>
                    <div class="profile-info col-8 col-sm-9">
                        <div class="profile-info-name">${broadcaster.nickname}</div>
                        <div class="profile-info-other">
                        	<c:if test="${not empty broadcaster.afreeca}">
                            	<div class="other-button" onclick="popUp('${broadcaster.afreeca}');"><i class="fas fa-broadcast-tower"></i></div>
                        	</c:if>
                        	<c:if test="${not empty broadcaster.youtube}">
                            	<div class="other-button" onclick="popUp('${broadcaster.youtube}');"><i class="fab fa-youtube"></i></div>
                        	</c:if>
							<div class="other-button users" data-toggle="conn-users-tooltip" data-placement="bottom" title="접속 중인 회원">
								<i class="fas fa-users"></i> <span id="conn-users">0</span>
							</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<!-- 일일, 주간, 월간민심 -->
<div class="stats-wrapper">
    <div class="stats-inner">
        <div class="stats-inner-box">
            <div class="container">
                <div class="row">
                    <div class="stat-box col-4">
                        <div class="stat-content">
                            <div class="title">일일민심</div>
                            <div id="stat-avg-today" class="stat-avg">
                                <i class="fas fa-minus animated tdFadeIn"></i> <i class="fas fa-caret-square-up animated tdFadeInUp"></i> <i class="fas fa-caret-square-down animated tdFadeInDown"></i> <i class="fas fa-star"></i> <span id="gp-avg-today">0</span>
                            </div>
                        </div>
                    </div>
                    <div class="stat-box col-4">
                        <div class="stat-content">
                            <div class="title">주간민심</div>
                            <div id="stat-avg-week" class="stat-avg">
                                <i class="fas fa-minus animated tdFadeIn"></i> <i class="fas fa-caret-square-up animated tdFadeInUp"></i> <i class="fas fa-caret-square-down animated tdFadeInDown"></i> <i class="fas fa-star"></i> <span id="gp-avg-week">0</span>
                            </div>
                        </div>
                    </div>
                    <div class="stat-box col-4">
                        <div class="stat-content last-stat">
                        	<div class="title">월간민심</div>
                            <div id="stat-avg-month" class="stat-avg">
                                <i class="fas fa-minus animated tdFadeIn"></i> <i class="fas fa-caret-square-up animated tdFadeInUp"></i> <i class="fas fa-caret-square-down animated tdFadeInDown"></i> <i class="fas fa-star"></i> <span id="gp-avg-month">0</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<!-- 주간, 월간 민심 차트 -->
<div class="chart-wrapper">
    <div class="chart-inner">
        <div class="chart-inner-box">
            <div class="chart-box">
                <div class="title">
                	<div class="chart-type-box">
                		<div class="chart-type active" onclick="setChartType(this,'bar');">Bar</div>
                		<div class="chart-type" onclick="setChartType(this,'line');">Line</div>
                		<div class="chart-type" onclick="setChartType(this,'pie');">Pie</div>
                		<div class="chart-type" onclick="setChartType(this,'polarArea');">Pa</div>
                	</div>
                	<div class="data-type-box">
	                    <div class="data-type active" onclick="setDataType(this,'week');">일별</div>
	                    <div class="data-type" onclick="setDataType(this,'month');">월별</div>
                    </div>
                    <input type="hidden" id="dataType" value="week"/>
                </div>
<!-- 	        	<div id="chart-spinner" class="chart-spinner on animated tdFadeIn">
	        		<div class="sk-folding-cube">
		        		<div class="sk-cube1 sk-cube"></div>
						<div class="sk-cube2 sk-cube"></div>
						<div class="sk-cube4 sk-cube"></div>
						<div class="sk-cube3 sk-cube"></div>
					</div>
				</div> -->
                <div id="chart-content" class="content">
                    <canvas id="reviewChart"></canvas>
                </div>
                <input type="hidden" id="chartType" value="bar"/>
            </div>
        </div>
    </div>
</div>
<!-- 민심평가 -->
<s:authorize access="isAuthenticated()">
	<div class="review-write-wrapper">
		<div class="review-write-inner">
			<div class="review-write-inner-box">
				<div class="review-input-box">
					<textarea id="comment" maxlength="5000" placeholder="자신의 의견과 평점을 입력해주세요."></textarea>
				</div>
				<div class="review-other-box">
					<div class="rate">
						<div id="rate"></div>
						<div id="counter">0</div>
					</div>
					<div class="button">
						<button class="review-button" onclick="writeReview();">등록</button>
					</div>
				</div>
			</div>
		</div>
	</div>
</s:authorize>
<s:authorize access="!isAuthenticated()">
	<div class="review-write-wrapper">
		<div class="review-write-inner">
			<div class="review-write-inner-box not">
				<div class="review-not-authenticated">
					<div class="info-circle"><i class="fas fa-info fa-2x"></i></div>
					<div class="text">평가를 등록하려면 로그인이 필요합니다.</div>
				</div>
			</div>
		</div>
	</div> 
</s:authorize>
<!-- 일일, 주간, 월간 민심평가 리스트 탭 -->
<div class="comment-list-wrapper">
    <div class="comment-list-inner">
        <div class="comment-list-inner-box">
            <div class="comment-list-tab-list-box">
                <ul class="comment-list-tab-list">
                    <li class="cl-default active" onclick="setReviewListType1(this,'today');">일일</li>
                    <li class="cl-default" onclick="setReviewListType1(this,'week');">주간</li>
                    <li class="cl-default" onclick="setReviewListType1(this,'month');">월간</li>
                </ul>
               	<input type="hidden" id="list-type1" value="today"/>
            </div>
        </div>
    </div>
</div>
<!-- 일일, 주간, 월간 민심평가 리스트 -->
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
					<span id="comment-list-type-new" class="active" onclick="setReviewListType2('new');"><i class="fas fa-check"></i> 최신순</span>
					<span id="comment-list-type-popular" onclick="setReviewListType2('popular');"><i class="fas fa-check"></i> 인기순</span>
					<input type="hidden" id="list-type2" value="new"/>
                </div>
                <div class="count-box">
                    <i class="fas fa-comments"></i>&nbsp;평가&nbsp;<span id="review-count">0</span>개
                </div>
            </div>
            <div id="comment-list-box" class="comment-list-box">
<%--                 <ul class="comment-list">
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
                                    <div class="reply-button">답글(<span>0</span>)</div>
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
                                            <i class="fas fa-ellipsis-v">
                                                <ul class="dropdown">
                                                    <li class="dd-default"><i class="fas fa-pen"></i></li>
                                                    <li class="dd-default"><i class="fas fa-trash"></i></li>
                                                </ul>                            
                                            </i>
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
                                            <i class="fas fa-ellipsis-v">
                                                <ul class="dropdown">
                                                    <li class="dd-default"><i class="fas fa-pen"></i></li>
                                                    <li class="dd-default"><i class="fas fa-trash"></i></li>
                                                </ul>           
                                            </i>
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
        <div id="comment-pagination-inner-box" class="comment-pagination-inner-box animated tdFadeIn">
            <ul class="pagination-list">
            </ul>
        </div>
        <input type="hidden" id="comment-page" value="1"/>
    </div>
</div>
<jsp:include page="/resources/include/footer.jsp"/>
<jsp:include page="/resources/include/modals.jsp"/>
<jsp:include page="/resources/include/mobile/sidebar.jsp"/>
<jsp:include page="/resources/include/board/board_socket.jsp"/>
<script>
var reviewSocket;
reviewSocket = new SockJS('<c:url value="/GradePointAverage"/>');
reviewSocket.onopen = reviewOnOpen;
reviewSocket.onmessage = reviewOnMessage;
reviewSocket.onclose = reviewOnClose;

function reviewOnOpen() {
	reviewSocket.send("open,${broadcaster.id}");
}
function reviewOnMessage(msg) {
	var message = msg.data.split(",");
	var prevTodayGpAvg = parseFloat($("#gp-avg-today").html().trim());
	var prevWeekGpAvg = parseFloat($("#gp-avg-week").html().trim());
	var prevMonthGpAvg = parseFloat($("#gp-avg-month").html().trim());
	
	var newTodayGpAvg = parseFloat(message[0]);
	var newWeekGpAvg = parseFloat(message[1]);
	var newMonthGpAvg = parseFloat(message[2]);
	
	var broadcasterId = message[3];
	
	if("${broadcaster.id}" == broadcasterId) {
		$("#gp-avg-today").html(newTodayGpAvg);
		$("#gp-avg-week").html(newWeekGpAvg);
		$("#gp-avg-month").html(newMonthGpAvg);
		
		$(".stat-content .stat-avg i").removeClass("on");
		
		if(!reviewSocketSendFlag) {
			$(".stat-content .stat-avg .fa-minus").addClass("on");
			reviewSocketSendFlag = true;
		} else {
			gpAvgCompare("today", prevTodayGpAvg, newTodayGpAvg);
			gpAvgCompare("week", prevWeekGpAvg, newWeekGpAvg);
			gpAvgCompare("month", prevMonthGpAvg, newMonthGpAvg);
		}		
	}
}
function gpAvgCompare(type, prevGpAvg, newGpAvg) {
	if(prevGpAvg > newGpAvg) {
		$("#stat-avg-" +  type + " .fa-caret-square-down").addClass("on");
	} else if(prevGpAvg < newGpAvg) {
		$("#stat-avg-" +  type + " .fa-caret-square-up").addClass("on");		
	} else {
		$("#stat-avg-" +  type + " .fa-minus").addClass("on");				
	}
}
function reviewOnClose(evt) {
	var tempHTML = "";
	tempHTML += "<div id='session-message-error' class='session-message animated tdFadeInLeft'>";
		tempHTML += "<div class='icon'><i class='fas fa-exclamation-triangle fa-3x'></i></div>";
		tempHTML += "<div class='content'>";
			tempHTML += "<div class='title'>연결이 종료되었습니다.</div>";
			tempHTML += "<div class='subject'>새로고침을 진행해주세요.</div>";
		tempHTML += "</div>";
	tempHTML += "</div>";
	$(".session-message-box").html(tempHTML);
	setTimeout(function() { $("#session-message-error").addClass("animated tdFadeOutRight"); }, 5000);
	setTimeout(function() { $("#session-message-error").remove(); }, 5500)
}
</script>
</body>
</html>