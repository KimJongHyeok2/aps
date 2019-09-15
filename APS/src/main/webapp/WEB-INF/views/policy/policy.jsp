<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>아프리카 민심 : APS</title>
<jsp:include page="/resources/include/common/common_css.jsp"/>
<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/resources/css/include/common.css">
<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/resources/css/policy/policy.css">
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
    resize_policy();
});
$(window).resize(resize_policy);
function resize_policy() {
    var htmlHeight = $("html").height();
    var headerHeight = $(".header-wrapper").height();
    var navHeight = $(".nav-wrapper").height();
    var footerHeight = $(".footer-wrapper").height();
    
    $(".content-wrapper").css("min-height", htmlHeight - headerHeight - navHeight - footerHeight - 3 + "px");
}
</script>
<div class="content-wrapper">
    <div class="content-inner">
        <div class="content-inner-box">
        	<div class="container-fluid">
	        	<div class="policy-tab">
	        		<div class="row">
	        			<div class="menu-box col-6">
	        				<div class="menu ${type=='policy'? 'active':''}" onclick="location.href='${pageContext.request.contextPath}/policy/policy'">이용약관</div>
	        			</div>
	        			<div class="menu-box col-6">
	        				<div class="menu ${type=='privacy'? 'active':''}" onclick="location.href='${pageContext.request.contextPath}/policy/privacy'">개인정보처리방침</div>
	        			</div>
	        		</div>
	        	</div>
	        	<c:choose>
	        		<c:when test="${type == 'policy'}">
	        			<div class="policy-title">이용약관</div>
			        	<div class="policy-content policy">
	                        <span class="title">제1조 (목적)</span><br>
	                        <span class="content">본 회원약관은 APS가 운영하는 인터넷관련 서비스(이하 '서비스'라 한다)를 이용함에 있어 관리자와 이용자(이하 '회원'이라 한다)의 권리, 의무 및 책임사항을 규정함을 목적으로 합니다.</span><br><br>
	                        <span class="title">제2조 (약관의 효력)</span><br>
	                        <span class="content">
		                        ① 본 약관은 APS에 회원가입 시 회원들에게 통지함으로써 효력을 발생합니다.<br>
		                        ② APS는 이 약관의 내용을 변경할 수 있으며, 변경된 약관은 제1항과 같은 방법으로 공지 또는 통지함으로써 효력을 발생합니다.<br>
		                        ③ 약관의 변경사항 및 내용은 APS의 홈페이지에 게시하는 방법으로 공시합니다.
	                        </span><br><br>
	                        <span class="title">제3조 (약관 이외의 준칙)</span><br>
	                        <span class="content">이 약관에 명시되지 않은 사항이 전기 통신 기본법, 전기통신 사업법, 기타 관련 법령에 규정되어 있는 경우 그 규정에 따릅니다.</span><br><br>
	                        <span class="title">제4조 (용어의 정의)</span><br>
	                        <span class="content">	                        
		                        ① 회원 : APS가 제공하는 서비스에 접속하여 본 약관에 따라 APS의 이용절차에 동의하고 APS가 제공하는 서비스를 이용하는 이용자를 말합니다.<br>
		                        ② 아이디(ID) : 회원 식별과 회원의 서비스 이용을 위하여 회원이 선정하고 APS가 승인하는 문자와 숫자의 조합<br>
		                        ③ 비밀번호 : 회원이 통신상의 자신의 비밀을 보호하기 위해 선정한 문자와 숫자의 조합<br>
		                        ④ 닉네임 : 서비스 이용을 위하여 회원이 선정하고 APS가 승인한 문자나 숫자 혹은 그 조합으로 서비스 이용 시 회원을 구분하고 지칭하고 나타내는 명칭을 말합니다.<br>
								⑤ 프로필 사진 : 서비스 이용을 위하여 회원이 선정하고 APS가 승인하여 업로드된 사진으로 서비스 이용 시 회원을 구분하고 지칭하고 나타내는 명칭을 말합니다.
	                        </span><br><br>
	                        <span class="title">제5조 (회원가입)</span><br>
	                        <span class="content">
		                        ① 회원이 되고자 하는 자는 APS가 정한 가입 양식에 따라 회원정보를 기입하고 '확인', '가입' 등의 버튼을 누르는 방법으로 회원가입을 신청합니다.<br>
		                        ② 제1항과 같이 회원으로 가입할 것을 신청한 자가 다음 각 호에 해당하지 않는 한 신청한 자를 회원으로 등록합니다.<br>
		                        &nbsp;1. 등록 내용에 허위, 기재누락, 오기가 있는 경우<br>
		                        &nbsp;2. 기타 회원으로 등록하는 것이 APS의 서비스 운영 및 기술상 현저히 지장이 있다고 판단되는 경우<br>
		                        ③ 회원가입계약의 성립시기는 APS의 승낙이 가입 신청자에게 도달한 시점으로 합니다.
	                        </span><br><br>
	                        <span class="title">제6조 (회원탈퇴 및 자격 상실 등)</span><br>
	                        <span class="content">
		                        ① 회원은 APS에 언제든지 자신의 회원 등록 말소(회원탈퇴)를 요청할 수 있으며 APS는 위 요청을 받은 즉시 해당 회원의 회원 등록 말소를 위한 절차를 밟습니다.<br>
		                        ② 회원탈퇴가 이루어지면 내부 방침에 따라 30일  또는 관계법령에 명시된 기한에 따라 보관된 후  영구적으로 삭제됩니다.<br>
		                        ③ 회원이 다음 각 호의 사유에 해당하거나 제12조 규정에 위반되는 경우, APS는 회원의 회원자격을 적절한 방법으로 제한 및 정지, 상실시킬 수 있습니다.<br>
		                        &nbsp;1. 가입 신청 시에 허위 이름, 이메일을 등록한 경우<br>
		                        &nbsp;2. 다른 사람의 서비스 이용을 방해하거나 그 정보를 도용하는 경우<br>
		                        &nbsp;3. 서비스를 이용하여 법령과 본 약관이 금지하거나 공서양속에 반하는 행위를 하는 경우<br>
		                        &nbsp;4. 저작권법 및 컴퓨터프로그램보호법을 위반한 불법프로그램의 제공 및 운영방해, 정보통신망법을 위반한 불법통신 및 해킹, 악성프로그램의 배포, 접속권한 초과행위 등과 같이 관련법을 위반한 경우<br>
		                        ④ APS가 회원의 회원자격을 상실시키기로 결정한 경우에는 회원등록을 말소합니다.<br>
		                        ⑤ 이용자가 본 약관에 의해서 회원 가입 후 서비스를 이용하는 도중, 연속하여 1년 동안 서비스를 이용하기 위해 로그인 기록이 없는 경우, APS는 회원의 회원자격을 상실시킬 수 있습니다.
	                        </span><br><br>
	                        <span class="title">제7조 (서비스의 제공 및 변경)</span><br>
	                        <span class="content">
		                        ① APS는 회원에게 아래와 같은 서비스를 제공합니다.<br>
		                        &nbsp;1. 커뮤니티 서비스(일반 게시판, 민심평가, 민심순위 등)<br>
		                        ② APS는 서비스의 내용 및 제공일자를 제9조 제1항에서 정한 방법으로 회원에게 통지하고, 제 1항에 정한 서비스를 변경하여 제공할 수 있습니다.
	                        </span><br><br>
	                        <span class="title">제8조 (서비스 제공의 중지)</span><br>
	                        <span class="content">
		                        ① APS는 컴퓨터 등 정보통신설비의 보수점검·교체 및 고장, 통신의 두절 등의 사유가 발생한 경우에는 서비스의 제공을 일시적으로 중단할 수 있고, 새로운 서비스로의 교체, 기타 APS가 적절하다고 판단하는 사유에 기하여 현재 제공되는 서비스를 완전히 중단할 수 있습니다.<br>
		                        ② 제1항에 의한 서비스 중단의 경우에 APS는 제9조 제1항에서 정한 방법으로 회원에게 통지합니다. 다만, APS가 통제할 수 없는 사유로 인한 서비스의 중단(시스템 관리자의 고의, 과실이 없는 디스크 장애, 시스템 다운 등)으로 인하여 사전 통지가 불가능한 경우에는 그러하지 아니합니다.
	                        </span><br><br>
	                        <span class="title">제9조 (회원에 대한 통지)</span><br>
	                        <span class="content">
		                        ① APS가 특정 회원에게 서비스에 관한 통지를 하는 경우 회원정보에 등록된 메일주소를 사용할 수 있습니다.<br>
		                        ② APS가 불특정다수 회원에 대한 통지를 하는 경우 7일 이상 공지사항 게시판에 게시함으로써 개별 통지에 같음할 수 있습니다.
	                        </span><br><br>
	                        <span class="title">제10조 (APS의 의무)</span><br>
	                        <span class="content">
		                        ① APS는 법령과 본 약관이 금지하거나 공서양속에 반하는 행위를 하지 않으며 본 약관이 정하는 바에 따라 지속적이고, 안정적으로 서비스를 제공하기 위해 노력합니다.<br>
		                        ② APS는 회원이 안전하고 편리하게 서비스를 이용할 수 있도록 시스템을 구축합니다.<br>
		                        ③ APS는 회원이 원하지 않는 영리목적의 광고성 전자우편을 발송하지 않습니다.
	                        </span><br><br>
	                        <span class="title">제11조 (개인정보보호)</span><br>
	                        <span class="content">
		                        ① APS는 이용자의 정보수집시 서비스의 제공에 필요한 최소한의 정보를 수집합니다.<br>
		                        ② 제공된 개인정보는 당해 이용자의 동의없이 목적 외의 이용이나 제3자에게 제공할 수 없으며, 이에 대한 모든 책임은 APS가 집니다. 다만, 다음의 경우에는 예외로 합니다.<br>
		                        &nbsp;1. 통계작성, 학술연구 또는 시장조사를 위하여 필요한 경우로서 특정 개인을 식별할 수 없는 형태로 제공하는 경우<br>
		                        &nbsp;2. 전기통신기본법 등 법률의 규정에 의해 국가기관의 요구가 있는 경우<br>
		                        &nbsp;3. 범죄에 대한 수사상의 목적이 있거나 정보통신윤리 위원회의 요청이 있는 경우<br>
		                        &nbsp;4. 기타 관계법령에서 정한 절차에 따른 요청이 있는 경우<br>
		                        ③ 회원은 언제든지 APS가 가지고 있는 자신의 개인정보에 대해 열람 및 오류정정을 요구할 수 있으며 APS는 이에 대해 지체없이 처리합니다.
	                        </span><br><br>
	                        <span class="title">제12조 (회원의 의무)</span><br>
	                        <span class="content">	                        
		                        ① 회원은 관계법령, 이 약관의 규정, 이용안내 및 주의사항 등 APS가 통지하는 사항을 준수하여야 하며, 기타 APS의 업무에 방해되는 행위를 하여서는 안됩니다.<br>
		                        ② 회원은 APS의 사전 승낙 없이 서비스를 이용하여 어떠한 영리 행위도 할 수 없습니다.<br>
		                        ③ 회원은 서비스를 이용하여 얻은 정보를 APS의 사전 승낙 없이 복사, 복제, 변경, 번역, 출판,방송 기타의 방법으로 사용하거나 이를 타인에게 제공할 수 없습니다.<br>
		                        ④ 회원은 서비스 이용과 관련하여 다음 각 호의 행위를 하여서는 안됩니다.<br>
		                        &nbsp;1. 다른 회원의 아이디(ID)를 부정 사용하는 행위<br>
		                        &nbsp;2. 범죄행위를 목적으로 하거나 모든 범죄행위와 관련된 행위<br>
		                        &nbsp;3. 선량한 풍속, 기타 사회질서를 해하는 행위<br>
		                        &nbsp;4. 타인의 명예를 훼손하거나 모욕하는 행위<br>
		                        &nbsp;5. 타인의 지적재산권 등의 권리를 침해하는 행위<br>
		                        &nbsp;6. 음란물, 욕설 등 공서양속에 위반되는 내용의 정보, 문장, 도형 등을 유포하는 행위<br> 
		                        &nbsp;7. 저작권법 및 컴퓨터프로그램보호법을 위반한 불법프로그램의 제공 및 운영방해, 정보통신망법을 위반한 불법통신 및 해킹, 악성프로그램의 배포, 접속권한 초과행위 등과 같은 관련법 위반 행위<br>
		                        &nbsp;8. 타인의 의사에 반하여 광고성 정보 등 일정한 내용을 지속적으로 전송 또는 타 사이트를 링크하는 행위<br>
		                        &nbsp;9. 서비스의 안전적인 운영에 지장을 주거나 줄 우려가 있는 일체의 행위<br>
		                        &nbsp;10. 기타 관계법령에 위배되는 행위<br>
		                        &nbsp;11. 서비스를 통한 상업적 광고홍보 또는 상거래 행위<br>
		                        &nbsp;12. 닉네임 또는 프로필 사진이 회원이나 제 3자의 개인정보를 포함하고 있는 경우<br>
		                        &nbsp;13. 닉네임 또는 프로필 사진이 타인에게 혐오감을 주는 경우<br>
		                        &nbsp;14. 닉네임 또는 프로필 사진이 욕설이나 범죄에 대한 내용이 포함된 경우<br>
		                        &nbsp;15. 닉네임 또는 프로필 사진이 미풍양속에 반하는 경우<br>
		                        &nbsp;16. 닉네임 또는 프로필 사진이 제3자를 비방하거나 분쟁을 야기하는 내용이 포함된 경우
	                        </span><br><br>
	                        <span class="title">제13조 (게시물 또는 내용물의 삭제)</span><br>
	                        <span class="content">APS는 서비스의 게시물 또는 내용물이 제12조의 규정에 위반되거나 소정의 게시기간을 초과하는 경우 사전 통지나 동의 없이 이를 삭제할 수 있습니다.</span><br><br>
	                        <span class="title">제14조 (게시물에 대한 권리·의무)</span><br>
	                        <span class="content">
								① 게시물에 대한 저작권을 포함한 모든 권리 및 책임은 이를 게시한 회원에게 있습니다. 단, APS는 서비스의 운영, 전시, 전송, 배포, 홍보의 목적으로 회원의 별도의 허락 없이 무상으로 저작권법에 규정하는 공정한 관행에 합치되게 합리적인 범위 내에서 다음과 같이 회원이 등록한 게시물을 사용할 수 있습니다.<br>
								&nbsp;1. 서비스 내에서 회원 게시물의 복제, 수정, 개조, 전시, 전송, 배포 및 저작물성을 해치지 않는 범위 내에서의 편집 저작물 작성<br>
								&nbsp;2. 미디어, 통신사 등 서비스 제휴 파트너에게 회원의 게시물 내용을 제공, 전시 혹은 홍보하게 하는 것. 단, 이 경우 APS는 별도의 동의 없이 회원의 이용자ID 외에 회원의 개인정보를 제공하지 않습니다.<br>
								&nbsp;3. APS는 전항 이외의 방법으로 회원의 게시물을 이용하고자 하는 경우, 전화, 팩스, 전자우편 등의 방법을 통해 사전에 회원의 동의를 얻어야 합니다.<br>
								③ 회원은 APS가 제공하는 서비스를 이용함으로써 얻은 정보를 APS의 사전승낙 없이 복제, 전송, 출판, 배포, 방송, 기타 방법에 의하여 영리목적으로 이용하거나 제3자에게 이용하게 하여서는 안됩니다.
	                        </span><br><br>
	                        <span class="title">제15조 (양도금지)</span><br>
	                        <span class="content">회원이 서비스의 이용권한, 기타 이용계약상 지위를 타인에게 양도, 증여할 수 없으며, 이를 담보로 제공할 수 없습니다.</span><br><br>
	                        <span class="title">제16조 (면책·배상)</span><br>
	                        <span class="content">
		                        ① APS는 회원이 서비스에 게재한 정보, 자료, 사실의 정확성, 신뢰성 등 그 내용에 관하여는 어떠한 책임을 부담하지 아니하고,  회원은 자기의 책임아래 서비스를 이용하며, 서비스를 이용하여 게시 또는 전송한 자료 등에 관하여 손해가 발생하거나 자료의 취사 선택, 기타서비스 이용과 관련하여 어떠한 불이익이 발생 하더라도 이에 대한 모든 책임은 회원에게 있습니다.<br>
		                        ② APS는 제12조의 규정에 위반하여 회원간 또는 회원과 제3자간에 서비스를 매개로 하여 물품거래 등과 관련하여 어떠한 책임도 부담하지 아니하고, 회원이 서비스의 이용과 관련하여 기대하는 이익에 관하여 책임을 부담하지 않습니다. <br>
		                        ③ 회원 아이디(ID)와 비밀번호의 관리 및 이용상의 부주의로 인하여 발생 되는 손해 또는 제3자에 의한 부정사용 등에 대한 책임은 모두 회원에게 있습니다.<br>
		                        ④ 회원이 제12조, 기타 이 약관의 규정을 위반함으로 인하여 APS가 회원 또는 제3자에 대하여 책임을 부담하게 되고, 이로써 APS에게 손해가 발생하게 되는 경우, 이 약관을 위반한 회원은 APS에게 발생하는 모든 손해를 배상하여야 하며, 동 손해로부터 APS를 면책시켜야 합니다.
	                        </span><br><br>
	                        <span class="title">제17조 (광고게재 및 광고주와의 거래)</span><br>
	                        <span class="content">	                        
								① APS는 천재지변 또는 이에 준하는 불가항력으로 인하여 서비스를 제공할 수 없는 경우에는 서비스 제공 장애로 인한 관한 책임이 면제됩니다.<br>
								② APS는 회원의 귀책사유로 인한 서비스 이용의 장애에 대하여 책임을 지지 않습니다.<br>
								③ APS는 회원이 서비스와 관련하여 게재한 정보, 자료, 사실의 신뢰도, 정확성 등의 내용에 관하여 책임을 지지 않습니다.<br>
								④ APS는 서비스를 매개로 한 회원 간 거래 또는 회원과 제3자 상호간 거래에 대하여 책임을 지지 않습니다.<br>
								⑤ APS는 서비스 이용과 관련하여 가입자에게 발생한 손해 가운데 회원의 고의, 과실에 의한 손해에 대하여 책임을 지지 않습니다.
	                        </span><br><br>
							<span class="title">제18조 (재판관할)</span><br>
							<span class="content">APS와 회원 간에 발생한 서비스 이용에 관한 분쟁에 대하여는 대한민국 법을 적용하며, 본 분쟁으로 인한 소는 민사소송법상의 관한을 가지는 대한민국의 법원에 제기합니다.</span><br><br>
	                        <span class="title">부  칙</span><br>
	                        <span class="content">본 약관은 2019년 8월 15일부터 시행합니다.</span>
			        	</div>
			        	<div class="policy-regdate">시행일: 2019년 8월 15일</div>
	        		</c:when>
	        		<c:when test="${type == 'privacy'}">
	        			<div class="policy-title">개인정보처리방침</div>
			        	<div class="policy-content privacy">
			        		<span>APS는 회원의 개인 정보보호를 매우 중요시하며 "정보통신망 이용촉진 및 정보보호 등에 관한 법률", "개인정보 보호법" 등 개인정보 보호 법령을 준수하고 있습니다. 관련 법률 및 정부 지침의 변경과 APS의 약관 및 내부 방침에 따라 개인정보처리방침을 변경할 수 있으며 이를 개정하는 경우 APS는 홈페이지 공지를 통해 회원에게 고지합니다.</span>
			        		<div class="toc">
			        			<div class="row">
			        				<div class="col-6">1. 개인정보 수집에 대한 동의</div>
			        				<div class="col-6">5. 개인정보의 파기절차 및 방법</div>
			        				<div class="col-6">2. 개인정보 수집항목 및 수집방법</div>
			        				<div class="col-6">6. 개인정보 보관 및 보호를 위한 기술적, 관리적 대책</div>
			        				<div class="col-6">3. 개인정보의 수집목적 및 이용목적</div>
			        				<div class="col-6">7. 개인정보 자동 수집 장치의 설치•운영 및 거부에 관한 사항</div>
			        				<div class="col-6">4. 개인정보의 처리 및 보유 기간</div>
			        				<div class="col-6">8. 개인정보 보호책임자</div>
			        			</div>
			        		</div>
			        		<div class="toc-m">
			        			<div class="row">
			        				<div class="col-12">1. 개인정보 수집에 대한 동의</div>
			        				<div class="col-12">2. 개인정보 수집항목 및 수집방법</div>
			        				<div class="col-12">3. 개인정보의 수집목적 및 이용목적</div>
			        				<div class="col-12">4. 개인정보의 처리 및 보유 기간</div>
			        				<div class="col-12">5. 개인정보의 파기절차 및 방법</div>
			        				<div class="col-12">6. 개인정보 보관 및 보호를 위한 기술적, 관리적 대책</div>
			        				<div class="col-12">7. 개인정보 자동 수집 장치의 설치•운영 및 거부에 관한 사항</div>
			        				<div class="col-12">8. 개인정보 보호책임자</div>
			        			</div>
			        		</div>
			        		<span class="title">1. 개인정보 수집에 대한 동의</span><br>
			        		<span class="content">APS는 이용자로부터 개인정보 수집에 대한 동의를 받고 있습니다. APS는 회원가입 절차에서 개인정보처리방침과 이용약관에 대한 동의 절차를 마련하고 있으며, 이용자가 동의를 클릭하면 개인정보 수집에 동의한 것으로 간주합니다.</span><br><br>
			        		<span class="title">2. 개인정보 수집항목 및 수집방법</span><br>
			        		<span class="content">
			        			APS는 원활한 서비스 제공을 위해 최소한의 개인정보를 수집하고있습니다.<br><br>
			        			[일반 회원가입]<br>
			        			- 개인 식별용값, 이름, 아이디, 비밀번호, 닉네임, 이메일<br>
			        			[SNS 회원가입]<br>
			        			- 개인 식별용값, 이름, 이메일<br>
			        			[서비스 이용]<br>
			        			- 서비스 이용 기록, IP주소
			        		</span><br><br>
			        		<span class="title">3. 개인정보의 수집목적 및 이용목적</span><br>
			          		<span class="content">
			          			APS는 다음의 목적을 위하여 개인정보를 처리하고 있으며, 다음의 목적 이외의 용도로는 이용하지 않습니다.<br><br>
			          			[이름, 아이디, 비밀번호]<br>
			          			- 본인 확인 및 개인 식별, 중복가입 방지<br>
			          			[이메일]<br>
			          			- 고지사항 및 서비스 이용 관련 사항 전달 등 의사소통<br>
			          			[닉네임]<br>
			          			- 서비스 기본 이용<br>
			          			[IP주소, 접속 로그, 서비스 이용 기록]<br>
			          			- 부정 이용 방지, 통계학적 분석에 사용
			          		</span><br><br>
			          		<span class="title">4. 개인정보 처리 및 보유 기간</span><br>
			          		<span class="content">
			          			APS는 회원의 회원가입일로부터 회원탈퇴와 같은 개인정보 수집, 이용, 제공에 대한 동의 철회 시까지 회원의 개인정보를 보유 및 이용하게 됩니다.<br>
			          			회원의 개인정보는 원칙적으로 개인정보의  수집 및 이용 목적이 달성된 시점에 지체없이 파기합니다.<br><br>
			          			[수집 및 이용 목적이 달성된 시점]<br>
			          			- 회원가입 정보 : 회원탈퇴와 같은 개인정보 수집, 이용, 제공에 대한 동의 철회 시<br><br>
			          			단, 다음의 정보에 대해서는 내부 방침(회원탈퇴일로부터 30일 보유) 및 관계법령에 따라 명시한 기간 동안 보관 후 파기합니다.<br>
			          			- 개인 식별용값, 아이디, 이름, 닉네임, 이메일<br>
			          			- 서비스를 불법/부정한 형태로 이용한 기록<br><br>
			          			관계볍령의 규정에 의하여 보관할 필요가 있는 경우 APS는 아래와 같이 관계법령에서 정한 일정한 기간 동안 회원정보를 보관 후 파기합니다.<br>
			          			- 서비스 이용 기록(저작물 작성시 IP), 회원 접속 정보(최종 접속 시간): 3개월 (통신비밀보호법)<br>
			          			- 표시/광고에 관한 기록: 6개월 (전자상거래등에서의 소비자보호에 관한 법률)<br>
			          			- 계약 또는 청약철회 등에 관한 기록: 5년 (전자상거래등에서의 소비자보호에 관한 법률)<br>
			          			- 대금결제 및 재화 등의 공급에 관한 기록: 5년 (전자상거래등에서의 소비자보호에 관한 법률)<br>
			          			- 소비자의 불만 또는 분쟁처리에 관한 기록: 3년 (전자상거래등에서의 소비자보호에 관한 법률)
			          		</span><br><br>
			          		<span class="title">5. 개인정보의 파기절차 및 방법</span><br>
			          		<span class="content">
			          			APS의 개인정보 파기절차 및 방법은 다음과 같습니다.<br><br>
			          			[절차]<br>
			          			- 회원가입 등의 입력하신 정보는 목적이 달성된 후 내부 방침 및 기타 관련 법령에 의한 정보보호 사유에 따라 일정 기간 저장된 후 파기됩니다.<br>
			          			- 개인정보는 법률에 의한 경우를 제외하고서 보유되는 목적 이외의 다른 목적으로 이용되지 않습니다.<br>
			          			[방법]<br>
			          			- 종이에 출력된 개인정보는 분쇄기로 분쇄하거나 소각을 통하여 파기합니다.<br>
			          			- 전자적 파일 형태로 저장된 개인정보는 기록을 재생할 수 없는 기술적 방법을 사용하여 삭제합니다.
			          		</span><br><br>
			          		<span class="title">6. 개인정보 보관 및 보호를 위한 기술적, 관리적 대책</span><br>
			          		<span class="content">
			          			APS는 회원의 개인정보를 취급함에 있어 개인정보 분실, 도단, 누출, 변조 또는 훼손되지 않도록 안정성 확보를 위하여 다음과 같은 기술적, 관리적 대책을 강구합니다.<br>
			          			- 회원가입 및 로그인 시 암호 알고리즘을 이용하여 네트워크상의 개인정보를 안전하게 전송할 수 있도록 Secured Socket Layer(SSL)를 채택하고 있습니다.<br>
			          			- 회원의 비밀번호는 암호화 되어 저장 및 관리되고 있어, 본인만이 알 수 있습니다.<br>
			          			- 개인정보에 대한 접근권한을 개인정보보호 책임자, 기타 업무상 개인정보의 처리가 불가피한 자로 제한하며, 그 이외의 인원이 개인정보에 접근하는 것을 허용하지 않습니다.
			          		</span><br><br>
			          		<span class="title">7. 개인정보 자동 수집 장치의 설치, 운영 및 거부에 관한 사항</span><br>
			          		<span class="content">
								APS는 이용자들에게 특화된 서비스를 제공하기 위해 이용자들의 정보를 저장하고 수시로 불러오는 '쿠키(cookie)'를 사용합니다.<br><br>
								[쿠키란?]<br>
								- 웹사이트를 운영에 이용되는 서버가 이용자의 웹브라우저에게 보내는 아주 작은 텍스트 파일로 이용자들이 사용하는 기기(PC, 노트북 , 스마트폰, 태블릿 등)에 저장됩니다.<br>
								[사용 목적]<br>
								- 회원 인증 허가 및 이용자들의 접속 빈도, 방문 시간, 이용 서비스 등을 분석하여 이용자의 취향 및 관심 분야를 파악하는 용도로 사용됩니다.<br>
								[구글 애널리틱스]<br>
								- APS는 구글 애널리틱스(Google Analytics)를 이용하여 로그를 분석하고 있습니다. 이용자를 식별할 수 없으며 전체적인 로그 분석에만 이용합니다.<br>
								[쿠키의 설치 운영 및 거부]<br>
								- 이용자는 쿠키 설치에 대한 선택권을 가지고 있으며, 웹브라우저에서 옵션을 설정함으로써 쿠키를 허용하거나 설치를 거부할 수 있습니다.<br>
								- 단, 쿠키의 설치를 거부할 경우 APS의 일부 서비스 이용에 어려움이 있을 수 있습니다.
							</span><br><br>
			          		<span class="title">8. 개인정보 보호책임자</span><br>
			          		<span class="content">
			          			APS는 회원의 개인정보를 보호하고 개인정보와 관련한 불만을 처리하기 위하여 개인정보 보호책임자를 지정하고 있습니다.<br><br>
			          			- 이름 : 김종혁<br>
			          			- 직위 : 관리자<br>
			          			- 메일 : apshelp200@gmail.com
			          		</span><br><br>
			          		<span>기타 개인정보침해에 대한 신고나 상담이 필요한 경우에는 아래 기관에 문의하시기 바랍니다.</span><br>
			          		<span class="content">
			          			- 개인정보침해신고센터 (국번없이 118 / <a href="https://privacy.kisa.or.kr">https://privacy.kisa.or.kr</a>)<br>
			          			- 대검찰청 사이버수사과 (국번없이 1301 / <a href="https://www.spo.go.kr">https://www.spo.go.kr</a>)<br>
			          			- 경찰청 사이버안전국 (국번없이 182 / <a href="(https://cyberbureau.police.go.kr">https://cyberbureau.police.go.kr</a>)
			          		</span><br><br>
			          		<span class="title">부칙</span><br>
			          		<span class="content">이 개인정보처리방침은 2019년 8월 15일부터 적용되며, 개인정보처리방침 내용에 변경이 있을 경우 개정 최소 7일전, 회원의 권리에 중대한 변경이 발생할 경우에는 최소 30일전에 APS 홈페이지를 통해 고지합니다.</span>
			        	</div>
			        	<div class="policy-regdate">시행일 : 2019년 8월 15일</div>
	        		</c:when>
	        	</c:choose>
        	</div>
        </div>
    </div>
</div>
<jsp:include page="/resources/include/footer.jsp"/>
<jsp:include page="/resources/include/modals.jsp"/>
<jsp:include page="/resources/include/mobile/sidebar.jsp"/>
</body>
</html>