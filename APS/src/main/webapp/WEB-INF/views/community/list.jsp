<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="s" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>아프리카 민심 : APS</title>
<meta property="og:title" content="아프리카 민심 : APS"/>
<meta name="author" content="아프리카 민심"/>
<meta name="description" content="인터넷방송 플랫폼 아프리카TV 커뮤니티입니다. APS의 컨텐츠를 이용하여 모두가 BJ, 방송에 대해 소통하며 자신의 의견을 제시할 수 있습니다."/>
<meta property="og:description" content="인터넷방송 플랫폼 아프리카TV 커뮤니티입니다. APS의 컨텐츠를 이용하여 모두가 BJ, 방송에 대해 소통하며 자신의 의견을 제시할 수 있습니다."/>
<meta property="og:image" content="https://www.afreecaps.com/resources/image/logo/header_logo.png"/>
<link rel="canonical" href="https://www.afreecaps.com/">
<meta property="og:url" content="https://www.afreecaps.com"/>
<meta property="og:type" content="website">
<jsp:include page="/resources/include/common/common_css.jsp"/>
<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/resources/css/include/common.css">
<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/resources/css/community/list.css">
<script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>
<!-- Google Adsense -->
<script>
  (adsbygoogle = window.adsbygoogle || []).push({
    google_ad_client: "ca-pub-5809905264951057",
    enable_page_level_ads: true
  });
</script>
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
var eqNo = 1;
$(document).ready(function() {
    resize_board_list();
    resize_notice_subject();
    dateFormat();
	if("${fn:length(noticeList)}" > 1) {
		setInterval(noticeSlide, 10000);		
	}

	if("${empty param.type}" == "true") {
		$("#nickname").attr("placeholder", "BJ명을 입력해주세요.");		
	} else if("${param.type=='group'}" == "true") {
		$("#nickname").attr("placeholder", "크루명을 입력해주세요.");
	} else if("${param.type=='issue'}" == "true") {
		$("#nickname").attr("placeholder", "이슈명을 입력해주세요.");
	}
	
});
$(window).resize(function() {
	resize_board_list();
	resize_notice_subject();
});
function resize_board_list() {
    var htmlHeight = $("html").height();
    var headerHeight = $(".header-wrapper").height();
    var navHeight = $(".nav-wrapper").height();
    var footerHeight = $(".footer-wrapper").height();
    
    $(".content-wrapper").css("min-height", htmlHeight - headerHeight - navHeight - footerHeight - 3 + "px");
}
function resize_notice_subject() {
    var noticeWidth = $(".notice-box .notice-list .notice .box").width();
    var noticeRegDateWidth = $(".notice-box .notice-list .notice .box .regdate").width();
    var noticeBadgeWidth = $(".notice-box .notice-list .notice .box .new-badge").width();

    var documentWidth = $(window).width();
    
    if(documentWidth <= 767) {
    	$(".notice-box .notice-list .notice .box .subject").css("max-width", noticeWidth - noticeBadgeWidth - 20 + "px");
    } else {
    	$(".notice-box .notice-list .notice .box .subject").css("max-width", noticeWidth - noticeRegDateWidth - noticeBadgeWidth - 20 + "px");    	
    }
}
function noticeSlide() {
	if(eqNo > 0) {
		$(".notice-box .notice-list .notice .box").eq(eqNo-1).animate({"opacity":"0"}, 1000, function() { $(".notice-box .notice-list .notice .box").eq(eqNo-1).removeClass("on first"); noticeShow(); });
	} else {
		noticeShow();
	}
	
	function noticeShow() {
		setTimeout(function(){			
			if(eqNo >= "${fn:length(noticeList)}") {
				eqNo = 0;
				$(".notice-box .notice-list .notice .box").removeClass("on first");
			}
			$(".notice-box .notice-list .notice .box").eq(eqNo).addClass("on").animate({"opacity":"1"}, 1000, function() { eqNo += 1; });
		}, 100);
	}
}
function communityType(type) {
	if(type == "bj") {
		location.href = "${pageContext.request.contextPath}/community";
	} else if(type == "combine") {
		location.href = "${pageContext.request.contextPath}/community/combine";
	} else {
		location.href = "${pageContext.request.contextPath}/community?type=" + type;		
	}
}
function validSearch() {
	var nickname = $("#nickname").val();
	
	if(nickname == null || nickname.length == 0) {
		modalToggle("#modal-type-1", "안내", "BJ명을 입력해주세요.");
		return false;
	}
	
	nickname = urlEncode(nickname);
	
	$("#search-form").submit();
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
// 공지목록 등록일시 포맷
function dateFormat() {
	var boardLength = parseInt("${fn:length(noticeList)}");
	
	for(var i=0; i<boardLength; i++) {
		var nowDate = new Date();
		var boardDate = new Date($("#notice-regdate-" + i).html().trim().replace(/-/g, "/").replace(".0", ""));
		
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
			$("#notice-regdate-" + i).html(boardHour + ":" + boardMinute);
			$("#notice-badge-" + i).addClass("on");
		} else if(nowYear == boardYear) {
			$("#notice-regdate-" + i).html(boardMonth + "월 " + boardDay + "일");
		} else {
			$("#notice-regdate-" + i).html((boardYear + "").substring(2, 4) + "-" + boardMonth + "-" + boardDay);
		}
	}
}
</script>
<!-- 게시판 리스트 -->
<div class="content-wrapper">
    <div class="content-inner">
        <div class="content-inner-box">
            <div class="container">
            	<div class="notice-box">
            		<div class="title"><i class="fas fa-bullhorn"></i> <span class="title-text">알려드립니다</span></div>
            		<div class="notice-list">
            			<c:choose>
            				<c:when test="${not empty noticeList}">
            					<c:forEach var="i" items="${noticeList}" varStatus="index">
			            			<div class="notice">
			            				<div class="box ${index.first? 'on first':''}">
					            			<div id="notice-regdate-${index.index}" class="regdate">${i.register_date}</div>
					            			<div class="subject" onclick="$('#n-view-${index.index}').submit();">${i.subject}
					            				<form id="n-view-${index.index}" action="${pageContext.request.contextPath}/customerService/${i.category_id}" method="post">
					            					<input type="hidden" id="id" name="id" value="${i.id}"/>
					            					<s:csrfInput/>
					            				</form>
					            			</div>
					            			<div id="notice-badge-${index.index}" class="new-badge">NEW</div>
				            			</div>
			            			</div>
		            			</c:forEach>
            				</c:when>
            				<c:otherwise>
		            			<div class="notice">
		            				<div class="box first">
				            			<div class="subject">등록된 공지사항이 없습니다.</div>
			            			</div>
		            			</div>
            				</c:otherwise>
            			</c:choose>
            		</div>
            		<div class="button">
            			<button onclick="location.href='${pageContext.request.contextPath}/customerService/notice'">더보기 <i class="fas fa-arrow-right"></i></button>
            		</div>
            	</div>
                <div class="search-box">
                	<div class="input-box">
	                    <form id="search-form" action="" method="post">
	                    	<input type="text" id="nickname" name="nickname"/>
							<s:csrfInput/>
		                </form>
	                </div>
	               	<div class="input-box">
	                    <button class="search-button" onclick="validSearch();"><i class="fas fa-search"></i></button>
	                </div>
                </div>
                <div class="list-type-box">
                	<div class="list-tab" onclick="communityType('combine');"><i class="fas fa-crown"></i> 통합 게시판</div>
                	<!-- <div class="or">OR</div> -->
                	<div class="list-tab ${empty param.type? 'active':''}" onclick="communityType('bj');">BJ</div>
                	<div class="list-tab ${param.type=='group'? 'active':''}" onclick="communityType('group');">크루</div>
                	<div class="list-tab ${param.type=='issue'? 'active':''}" onclick="communityType('issue');">이슈</div>
                </div>
                <div class="line">
                    <hr>
                    <div class="line-text">목록</div>
                </div>
                <div class="list-box">
                    <div class="row">
                    	<c:choose>
                    		<c:when test="${not empty broadcasterList}">
                    			<c:forEach var="i" items="${broadcasterList}">
			                        <div class="card-box col-6 col-sm-4 col-md-3">
			                            <div class="card animated tdFadeInDown">
			                                <div class="profile-img">
			                                	<c:choose>
				                                	<c:when test="${not empty i.profile}">
				                                		<img class="img-fluid" src="${pageContext.request.contextPath}/resources/image/broadcaster/${i.profile}"/>
				                                	</c:when>
				                                	<c:otherwise>
				                                		<i class="far fa-user fa-9x default"></i>
				                                	</c:otherwise>
				                                </c:choose>
				                                <div class="name-tag">${i.nickname}</div>
			                                </div>
			                                <div class="function-box">
			                                    <div class="row">
			                                        <div class="function-button col-6" onclick="location.href='${pageContext.request.contextPath}/community/board?id=${i.id}&page=1'">게시판</div>
			                                        <div class="function-button col-6" onclick="location.href='${pageContext.request.contextPath}/community/review/${i.id}'">민심평가</div>
			                                    </div>
			                                </div>
			                            </div>
			                        </div>
		                        </c:forEach>
	                        </c:when>
	                        <c:otherwise>
	                        	<div class="empty-community">
	                        		<div class="info-circle"><i class="fas fa-info fa-2x"></i></div>
	                        		<div class="text">등록된 커뮤니티가 없습니다.</div>
	                        	</div>
	                        </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<jsp:include page="/resources/include/footer.jsp"/>
<jsp:include page="/resources/include/modals.jsp"/>
<jsp:include page="/resources/include/mobile/sidebar.jsp"/>
</body>
</html>