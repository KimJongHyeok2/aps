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
<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/resources/css/community/combine/combine_list.css">
<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/resources/css/community/board/board.css">
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
$(document).ready(function() {
    dateFormat();
    viewCountFormat();
    resize_board_list();
    $('[data-toggle="conn-users-tooltip"]').tooltip();
});
$(window).resize(resize_board_list);
function resize_board_list() {
    var htmlHeight = $("html").height();
    var headerHeight = $(".header-wrapper").height();
    var navHeight = $(".nav-wrapper").height();
    var footerHeight = $(".footer-wrapper").height();
 
    var documentWidth = $(window).width();
    
    var wrapperWidth = Math.round($(".bl-default .write-box").width());
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
    
    $(".content-wrapper").css("min-height", htmlHeight - headerHeight - navHeight - footerHeight - 3 + "px");
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
	location.href = "${pageContext.request.contextPath}/community/combine?listType=" + listType + "&searchValue=" + searchValue + "&searchType=" + searchType;
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
// 게시글 리스트 등록일시 포맷
function dateFormat() {
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
	var boardLength = parseInt("${fn:length(boardList)}");
	
	for(var i=0; i<boardLength; i++) {
		$("#viewcount_" + i).html(($("#viewcount_" + i).html() + "").replace(/\B(?=(\d{3})+(?!\d))/g, ","));
		$("#mobile_viewcount_" + i).html(($("#mobile_viewcount_" + i).html() + "").replace(/\B(?=(\d{3})+(?!\d))/g, ","));
		$("#comment_count_" + i).html(($("#comment_count_" + i).html() + "").replace(/\B(?=(\d{3})+(?!\d))/g, ","));
		$("#mobile_comment_count-" + i).html(($("#mobile_comment_count_" + i).html() + "").replace(/\B(?=(\d{3})+(?!\d))/g, ","));
		$("#mobile_viewcount2_" + i).html(($("#mobile_viewcount2_" + i).html() + "").replace(/\B(?=(\d{3})+(?!\d))/g, ","));
	}
}
</script>
<!-- 게시글 리스트 메인 -->
<div class="content-wrapper">
    <div class="content-inner">
        <div class="content-inner-box">
            <div class="container">
				<jsp:include page="/resources/include/combine/combine_header.jsp"/>
                <div class="board-content">
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
			                                        <div class="comment-count-box">[<span id="mobile_comment_count_${index.index}" class="count">${i.commentCount}</span>]</div>
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
<jsp:include page="/resources/include/footer.jsp"/>
<jsp:include page="/resources/include/modals.jsp"/>
<jsp:include page="/resources/include/mobile/sidebar.jsp"/>
<jsp:include page="/resources/include/board/board_socket.jsp"/>
</body>
</html>