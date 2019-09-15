<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>아프리카 민심 : APS</title>
<jsp:include page="/resources/include/common/common_css.jsp"/>
<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/resources/css/include/common.css">
<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/resources/css/main.css">
<style type="text/css">
.sk-cube-grid {
  width: 40px;
  height: 40px;
  margin: 100px auto;
}

.sk-cube-grid .sk-cube {
  width: 33%;
  height: 33%;
  background-color: #333;
  float: left;
  -webkit-animation: sk-cubeGridScaleDelay 1.3s infinite ease-in-out;
          animation: sk-cubeGridScaleDelay 1.3s infinite ease-in-out; 
}
.sk-cube-grid .sk-cube1 {
  -webkit-animation-delay: 0.2s;
          animation-delay: 0.2s; }
.sk-cube-grid .sk-cube2 {
  -webkit-animation-delay: 0.3s;
          animation-delay: 0.3s; }
.sk-cube-grid .sk-cube3 {
  -webkit-animation-delay: 0.4s;
          animation-delay: 0.4s; }
.sk-cube-grid .sk-cube4 {
  -webkit-animation-delay: 0.1s;
          animation-delay: 0.1s; }
.sk-cube-grid .sk-cube5 {
  -webkit-animation-delay: 0.2s;
          animation-delay: 0.2s; }
.sk-cube-grid .sk-cube6 {
  -webkit-animation-delay: 0.3s;
          animation-delay: 0.3s; }
.sk-cube-grid .sk-cube7 {
  -webkit-animation-delay: 0s;
          animation-delay: 0s; }
.sk-cube-grid .sk-cube8 {
  -webkit-animation-delay: 0.1s;
          animation-delay: 0.1s; }
.sk-cube-grid .sk-cube9 {
  -webkit-animation-delay: 0.2s;
          animation-delay: 0.2s; }

@-webkit-keyframes sk-cubeGridScaleDelay {
  0%, 70%, 100% {
    -webkit-transform: scale3D(1, 1, 1);
            transform: scale3D(1, 1, 1);
  } 35% {
    -webkit-transform: scale3D(0, 0, 1);
            transform: scale3D(0, 0, 1); 
  }
}

@keyframes sk-cubeGridScaleDelay {
  0%, 70%, 100% {
    -webkit-transform: scale3D(1, 1, 1);
            transform: scale3D(1, 1, 1);
  } 35% {
    -webkit-transform: scale3D(0, 0, 1);
            transform: scale3D(0, 0, 1);
  } 
}
.spinner {
  margin: 100px auto;
  width: 50px;
  height: 40px;
  text-align: center;
  font-size: 10px;
}

.spinner > div {
  background-color: green;
  height: 100%;
  width: 6px;
  display: inline-block;
  
  -webkit-animation: sk-stretchdelay 1.2s infinite ease-in-out;
  animation: sk-stretchdelay 1.2s infinite ease-in-out;
}

.spinner .rect2 {
  -webkit-animation-delay: -1.1s;
  animation-delay: -1.1s;
}

.spinner .rect3 {
  -webkit-animation-delay: -1.0s;
  animation-delay: -1.0s;
}

.spinner .rect4 {
  -webkit-animation-delay: -0.9s;
  animation-delay: -0.9s;
}

.spinner .rect5 {
  -webkit-animation-delay: -0.8s;
  animation-delay: -0.8s;
}

@-webkit-keyframes sk-stretchdelay {
  0%, 40%, 100% { -webkit-transform: scaleY(0.4) }  
  20% { -webkit-transform: scaleY(1.0) }
}

@keyframes sk-stretchdelay {
  0%, 40%, 100% { 
    transform: scaleY(0.4);
    -webkit-transform: scaleY(0.4);
  }  20% { 
    transform: scaleY(1.0);
    -webkit-transform: scaleY(1.0);
  }
}

.sk-circle {
  margin: 100px auto;
  width: 40px;
  height: 40px;
  position: relative;
}
.sk-circle .sk-child {
  width: 100%;
  height: 100%;
  position: absolute;
  left: 0;
  top: 0;
}
.sk-circle .sk-child:before {
  content: '';
  display: block;
  margin: 0 auto;
  width: 15%;
  height: 15%;
  background-color: #333;
  border-radius: 100%;
  -webkit-animation: sk-circleBounceDelay 1.2s infinite ease-in-out both;
          animation: sk-circleBounceDelay 1.2s infinite ease-in-out both;
}
.sk-circle .sk-circle2 {
  -webkit-transform: rotate(30deg);
      -ms-transform: rotate(30deg);
          transform: rotate(30deg); }
.sk-circle .sk-circle3 {
  -webkit-transform: rotate(60deg);
      -ms-transform: rotate(60deg);
          transform: rotate(60deg); }
.sk-circle .sk-circle4 {
  -webkit-transform: rotate(90deg);
      -ms-transform: rotate(90deg);
          transform: rotate(90deg); }
.sk-circle .sk-circle5 {
  -webkit-transform: rotate(120deg);
      -ms-transform: rotate(120deg);
          transform: rotate(120deg); }
.sk-circle .sk-circle6 {
  -webkit-transform: rotate(150deg);
      -ms-transform: rotate(150deg);
          transform: rotate(150deg); }
.sk-circle .sk-circle7 {
  -webkit-transform: rotate(180deg);
      -ms-transform: rotate(180deg);
          transform: rotate(180deg); }
.sk-circle .sk-circle8 {
  -webkit-transform: rotate(210deg);
      -ms-transform: rotate(210deg);
          transform: rotate(210deg); }
.sk-circle .sk-circle9 {
  -webkit-transform: rotate(240deg);
      -ms-transform: rotate(240deg);
          transform: rotate(240deg); }
.sk-circle .sk-circle10 {
  -webkit-transform: rotate(270deg);
      -ms-transform: rotate(270deg);
          transform: rotate(270deg); }
.sk-circle .sk-circle11 {
  -webkit-transform: rotate(300deg);
      -ms-transform: rotate(300deg);
          transform: rotate(300deg); }
.sk-circle .sk-circle12 {
  -webkit-transform: rotate(330deg);
      -ms-transform: rotate(330deg);
          transform: rotate(330deg); }
.sk-circle .sk-circle2:before {
  -webkit-animation-delay: -1.1s;
          animation-delay: -1.1s; }
.sk-circle .sk-circle3:before {
  -webkit-animation-delay: -1s;
          animation-delay: -1s; }
.sk-circle .sk-circle4:before {
  -webkit-animation-delay: -0.9s;
          animation-delay: -0.9s; }
.sk-circle .sk-circle5:before {
  -webkit-animation-delay: -0.8s;
          animation-delay: -0.8s; }
.sk-circle .sk-circle6:before {
  -webkit-animation-delay: -0.7s;
          animation-delay: -0.7s; }
.sk-circle .sk-circle7:before {
  -webkit-animation-delay: -0.6s;
          animation-delay: -0.6s; }
.sk-circle .sk-circle8:before {
  -webkit-animation-delay: -0.5s;
          animation-delay: -0.5s; }
.sk-circle .sk-circle9:before {
  -webkit-animation-delay: -0.4s;
          animation-delay: -0.4s; }
.sk-circle .sk-circle10:before {
  -webkit-animation-delay: -0.3s;
          animation-delay: -0.3s; }
.sk-circle .sk-circle11:before {
  -webkit-animation-delay: -0.2s;
          animation-delay: -0.2s; }
.sk-circle .sk-circle12:before {
  -webkit-animation-delay: -0.1s;
          animation-delay: -0.1s; }

@-webkit-keyframes sk-circleBounceDelay {
  0%, 80%, 100% {
    -webkit-transform: scale(0);
            transform: scale(0);
  } 40% {
    -webkit-transform: scale(1);
            transform: scale(1);
  }
}

@keyframes sk-circleBounceDelay {
  0%, 80%, 100% {
    -webkit-transform: scale(0);
            transform: scale(0);
  } 40% {
    -webkit-transform: scale(1);
            transform: scale(1);
  }
}

.sk-folding-cube {
  margin: 20px auto;
  width: 40px;
  height: 40px;
  position: relative;
  -webkit-transform: rotateZ(45deg);
          transform: rotateZ(45deg);
}

.sk-folding-cube .sk-cube {
  float: left;
  width: 50%;
  height: 50%;
  position: relative;
  -webkit-transform: scale(1.1);
      -ms-transform: scale(1.1);
          transform: scale(1.1); 
}
.sk-folding-cube .sk-cube:before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: #333;
  -webkit-animation: sk-foldCubeAngle 2.4s infinite linear both;
          animation: sk-foldCubeAngle 2.4s infinite linear both;
  -webkit-transform-origin: 100% 100%;
      -ms-transform-origin: 100% 100%;
          transform-origin: 100% 100%;
}
.sk-folding-cube .sk-cube2 {
  -webkit-transform: scale(1.1) rotateZ(90deg);
          transform: scale(1.1) rotateZ(90deg);
}
.sk-folding-cube .sk-cube3 {
  -webkit-transform: scale(1.1) rotateZ(180deg);
          transform: scale(1.1) rotateZ(180deg);
}
.sk-folding-cube .sk-cube4 {
  -webkit-transform: scale(1.1) rotateZ(270deg);
          transform: scale(1.1) rotateZ(270deg);
}
.sk-folding-cube .sk-cube2:before {
  -webkit-animation-delay: 0.3s;
          animation-delay: 0.3s;
}
.sk-folding-cube .sk-cube3:before {
  -webkit-animation-delay: 0.6s;
          animation-delay: 0.6s; 
}
.sk-folding-cube .sk-cube4:before {
  -webkit-animation-delay: 0.9s;
          animation-delay: 0.9s;
}
@-webkit-keyframes sk-foldCubeAngle {
  0%, 10% {
    -webkit-transform: perspective(140px) rotateX(-180deg);
            transform: perspective(140px) rotateX(-180deg);
    opacity: 0; 
  } 25%, 75% {
    -webkit-transform: perspective(140px) rotateX(0deg);
            transform: perspective(140px) rotateX(0deg);
    opacity: 1; 
  } 90%, 100% {
    -webkit-transform: perspective(140px) rotateY(180deg);
            transform: perspective(140px) rotateY(180deg);
    opacity: 0; 
  } 
}

@keyframes sk-foldCubeAngle {
  0%, 10% {
    -webkit-transform: perspective(140px) rotateX(-180deg);
            transform: perspective(140px) rotateX(-180deg);
    opacity: 0; 
  } 25%, 75% {
    -webkit-transform: perspective(140px) rotateX(0deg);
            transform: perspective(140px) rotateX(0deg);
    opacity: 1; 
  } 90%, 100% {
    -webkit-transform: perspective(140px) rotateY(180deg);
            transform: perspective(140px) rotateY(180deg);
    opacity: 0; 
  }
}

/* .spinner {
  margin: 100px auto 0;
  width: 70px;
  text-align: center;
}

.spinner > div {
  width: 18px;
  height: 18px;
  background-color: #333;

  border-radius: 100%;
  display: inline-block;
  -webkit-animation: sk-bouncedelay 1.4s infinite ease-in-out both;
  animation: sk-bouncedelay 1.4s infinite ease-in-out both;
}

.spinner .bounce1 {
  -webkit-animation-delay: -0.32s;
  animation-delay: -0.32s;
}

.spinner .bounce2 {
  -webkit-animation-delay: -0.16s;
  animation-delay: -0.16s;
}

@-webkit-keyframes sk-bouncedelay {
  0%, 80%, 100% { -webkit-transform: scale(0) }
  40% { -webkit-transform: scale(1.0) }
}

@keyframes sk-bouncedelay {
  0%, 80%, 100% { 
    -webkit-transform: scale(0);
    transform: scale(0);
  } 40% { 
    -webkit-transform: scale(1.0);
    transform: scale(1.0);
  }
} */
</style>
</head>
<body>
<jsp:include page="/resources/include/common/common_js.jsp"/>
<jsp:include page="/resources/include/header.jsp"/>
<script>
$(document).ready(function() {
    resize_main();
});
$(window).resize(resize_main);
function resize_main() {
    var htmlHeight = $("html").height();
    var headerHeight = $(".header-wrapper").height();
    var navHeight = $(".nav-wrapper").height();
    var footerHeight = $(".footer-wrapper").height();
    
    $(".content-wrapper").css("min-height", htmlHeight - headerHeight - navHeight - footerHeight - 23 + "px");
}
</script>
<!-- 메인 -->
<div class="content-wrapper">
    <div class="content-inner">
        <div class="container-fluid">
            <div class="today-aps-section">
                <div class="title">
                    <h4>일일 민심 BEST</h4>
                </div>
                <div class="row">
                    <div class="card-box col-6 col-sm-6 col-md-4">
                        <div class="card">
                            <div class="profile-img">
                                <img class="img-fluid" src="${pageContext.request.contextPath}/resources/image/broadcaster/gamst.jpg"/>
                            </div>
                            <div class="profile-name">감스트</div>
                            <div class="profile-ps">
                                <i class="fas fa-star fa-2x"></i> <span class="ps">5.0</span>
                            </div>
                            <img class="profile-best" src="${pageContext.request.contextPath}/resources/image/icon/gold-medal.png"/>
                        </div>
                    </div>
                    <div class="card-box col-6 col-sm-6 col-md-4">
                        <div class="card">
                            <div class="profile-img">
                                <img class="img-fluid" src="${pageContext.request.contextPath}/resources/image/broadcaster/bongjun.jpg"/>
                            </div>
                            <div class="profile-name">와꾸대장봉준</div>
                            <div class="profile-ps">
                                <i class="fas fa-star fa-2x"></i> <span class="ps">5.0</span>
                            </div>
                            <img class="profile-best" src="${pageContext.request.contextPath}/resources/image/icon/silver-medal.png"/>
                        </div>
                    </div>
                    <div class="card-box bronze col-6 col-sm-6 col-md-4">
                        <div class="card last-card">
                            <div class="profile-img">
                                <img class="img-fluid" src="${pageContext.request.contextPath}/resources/image/broadcaster/namsun.jpg"/>
                            </div>
                            <div class="profile-name">남순</div>
                            <div class="profile-ps">
                                <i class="fas fa-star fa-2x"></i> <span class="ps">5.0</span>
                            </div>
                            <img class="profile-best" src="${pageContext.request.contextPath}/resources/image/icon/bronze-medal.png"/>
                        </div>
                    </div>
                </div>
            </div>
            <div class="week-aps-section">
                <div class="title margin-top">
                    <h4>주간 민심 BEST</h4>
                </div>
                <div class="row">
                    <div class="card-box col-6 col-sm-6 col-md-4">
                        <div class="card">
                            <div class="profile-img">
                                <img class="img-fluid" src="${pageContext.request.contextPath}/resources/image/broadcaster/gamst.jpg"/>
                            </div>
                            <div class="profile-name">감스트</div>
                            <div class="profile-ps">
                                <i class="fas fa-star fa-2x"></i> <span class="ps">5.0</span>
                            </div>
                            <img class="profile-best" src="${pageContext.request.contextPath}/resources/image/icon/gold-medal.png"/>
                        </div>
                    </div>
                    <div class="card-box col-6 col-sm-6 col-md-4">
                        <div class="card">
                            <div class="profile-img">
                                <img class="img-fluid" src="${pageContext.request.contextPath}/resources/image/broadcaster/bongjun.jpg"/>
                            </div>
                            <div class="profile-name">와꾸대장봉준</div>
                            <div class="profile-ps">
                                <i class="fas fa-star fa-2x"></i> <span class="ps">5.0</span>
                            </div>
                            <img class="profile-best" src="${pageContext.request.contextPath}/resources/image/icon/silver-medal.png"/>
                        </div>
                    </div>
                    <div class="card-box bronze col-6 col-sm-6 col-md-4">
                        <div class="card last-card">
                            <div class="profile-img">
                                <img class="img-fluid" src="${pageContext.request.contextPath}/resources/image/broadcaster/namsun.jpg"/>
                            </div>
                            <div class="profile-name">남순</div>
                            <div class="profile-ps">
                                <i class="fas fa-star fa-2x"></i> <span class="ps">5.0</span>
                            </div>
                            <img class="profile-best" src="${pageContext.request.contextPath}/resources/image/icon/bronze-medal.png"/>
                        </div>
                    </div>
                </div>
            </div>
            <div class="board-section">
                <div class="title margin-top">
                    <h4>커뮤니티 인기글</h4>
                </div>
                <div class="row">
                    <div class="board-box col-md-12 col-lg-6">
                        <ul class="board-list">
                            <li class="bl-default last-list">
                                <div class="row">
                                    <div class="subject-box col-lg-8">
                                        <div class="subject">제목입니다. 안녕하세요!!!!dwqdwqdwqdwqdwqddqwd</div>
                                        <div class="comment-count">[51]</div>
                                        <div class="icon-box"><i class="fas fa-image"></i> <i class="fas fa-video"></i></div>
                                    </div>
                                    <div class="other-box col-lg-4">
                                        <div class="nickname">닉네임입니다</div><div class="level">lv.50</div>
                                    </div>
                                </div>
                            </li>
                        </ul>
                    </div>
                    <div class="board-box col-md-12 col-lg-6">
                        <ul class="board-list last-board">
                            <li class="bl-default">
                                <div class="row">
                                    <div class="subject-box col-lg-8">
                                        <div class="subject">정기구독자 방송이 오늘 출시되었습니다.</div>
                                        <div class="comment-count">[51]</div>
                                        <div class="icon-box"><i class="fas fa-image"></i> <i class="fas fa-video"></i></div>
                                    </div>
                                    <div class="other-box col-lg-4">
                                        <div class="nickname">닉네임입니다</div><div class="level">lv.50</div>
                                    </div>
                                </div>
                            </li>
                            <li class="bl-default last-list">
                                <div class="row">
                                    <div class="subject-box col-lg-8">
                                        <div class="subject">제목입니다. 안녕하세요!!!!</div>
                                        <div class="comment-count">[51]</div>
                                        <div class="icon-box"><i class="fas fa-image"></i> <i class="fas fa-video"></i></div>
                                    </div>
                                    <div class="other-box col-lg-4">
                                        <div class="nickname">닉네임입니다</div><div class="level">lv.50</div>
                                    </div>
                                </div>
                            </li>
                        </ul>
                    </div>
                </div>
            </div>
            <div class="notice-more-section margin-top">
                <span>더 보기 <i class="fas fa-chevron-right"></i></span>
            </div>
            <div class="notice-section">
                <div class="notice-list">
                    <div class="type-box">
                        <div class="type-normal">일반</div>
                    </div>
                    <div class="subject-box">
                        <div class="subject">
                           	 안녕하세요. 오픈 공지사항입니다.
                        </div>
                        <div class="comment-count">[51]</div>
                        <div class="icon-box">
                            <i class="fas fa-image"></i> <i class="fas fa-video"></i>
                        </div>
                    </div>
                    <div class="regdate-box">2019-06-17</div>
                </div>
            </div>
            <div>
				<div class="sk-cube-grid">
				  <div class="sk-cube sk-cube1"></div>
				  <div class="sk-cube sk-cube2"></div>
				  <div class="sk-cube sk-cube3"></div>
				  <div class="sk-cube sk-cube4"></div>
				  <div class="sk-cube sk-cube5"></div>
				  <div class="sk-cube sk-cube6"></div>
				  <div class="sk-cube sk-cube7"></div>
				  <div class="sk-cube sk-cube8"></div>
				  <div class="sk-cube sk-cube9"></div>
				</div>
            </div>
            <div>
				<div class="spinner">
				  <div class="rect1"></div>
				  <div class="rect2"></div>
				  <div class="rect3"></div>
				  <div class="rect4"></div>
				  <div class="rect5"></div>
				</div>
            </div>
            <div>
				<div class="sk-circle">
				  <div class="sk-circle1 sk-child"></div>
				  <div class="sk-circle2 sk-child"></div>
				  <div class="sk-circle3 sk-child"></div>
				  <div class="sk-circle4 sk-child"></div>
				  <div class="sk-circle5 sk-child"></div>
				  <div class="sk-circle6 sk-child"></div>
				  <div class="sk-circle7 sk-child"></div>
				  <div class="sk-circle8 sk-child"></div>
				  <div class="sk-circle9 sk-child"></div>
				  <div class="sk-circle10 sk-child"></div>
				  <div class="sk-circle11 sk-child"></div>
				  <div class="sk-circle12 sk-child"></div>
				</div>
            </div>
            <div>
				<div class="sk-folding-cube">
				  <div class="sk-cube1 sk-cube"></div>
				  <div class="sk-cube2 sk-cube"></div>
				  <div class="sk-cube4 sk-cube"></div>
				  <div class="sk-cube3 sk-cube"></div>
				</div>
            </div>
<!--             <div>
				<div class="spinner">
				  <div class="bounce1"></div>
				  <div class="bounce2"></div>
				  <div class="bounce3"></div>
				</div>
            </div> -->
            <div>
            	<div id="loading"></div>
            </div>
        </div>
    </div>
</div>
<jsp:include page="/resources/include/footer.jsp"/>
<jsp:include page="/resources/include/mobile/sidebar.jsp"/>
</body>
</html>