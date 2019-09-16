## Demo
<img src="https://user-images.githubusercontent.com/47962660/64971943-611d5980-d8e3-11e9-9f67-7b8fe859ea87.gif"/>

## Review(Client)
```javascript
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
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/webapp/WEB-INF/views/community/review.jsp">review.jsp</a>
</pre>
## CommunityController
```java
@Inject
private CommunityService communityService;

// 방송인 민심평가 답글 등록
@PostMapping("/reviewReply/write")
public @ResponseBody String reviewReplywWrite(CommentReplyDTO dto, BindingResult result,
  HttpServletRequest request) {
  String resultMsg = "Fail";
		
  CommentReplyValidator validation = new CommentReplyValidator();
  validation.setRequest(request);
		
  // 파라미터 유효성 검사
  if(validation.supports(dto.getClass())) {
    validation.validate(dto, result);
    dto.setIp(request.getRemoteAddr());
			
    // 오류가 존재하지 않다면
    if(!result.hasErrors()) {
      try {
        if(request.getSession().getAttribute("prevention") != null) { // 도배방지 세션 값이 존재하다면
          dto.setPrevention(true);
        }
					
        resultMsg = communityService.insertBroadcasterReviewReply(dto);
					
        if(resultMsg.equals("Success")) {
          request.setAttribute("type", 3);
          request.setAttribute("dto", dto);
        }
      } catch (Exception e) {
        throw new ResponseBodyException(e);
      }
    }
  }
		
  return resultMsg;
}
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/controller/CommunityController.java">CommunityController.java</a>
</pre>
## CommunityServiceImpl
```java
@Inject
private CommunityDAO dao;

@Override
public String insertBroadcasterReviewReply(CommentReplyDTO dto) throws Exception { // 방송인 평가 답글 등록
		
  String result = "Fail";
		
  int successCount = 0;
		
  if(!dto.isPrevention()) {
    successCount = dao.insertBroadcasterReviewReply(dto);			
  } else {
    result = "prevention";
  }
		
  if(successCount == 1) {
    result = "Success";
  }
		
  return result;
}
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/service/CommunityServiceImpl.java">CommunityServiceImpl.java</a>
</pre>
## CommunityMapper
```xml
<mapper namespace="community">
  <insert id="insertBroadcasterReviewReply" parameterType="com.kjh.aps.domain.CommentReplyDTO">
    INSERT INTO broadcaster_review_reply(broadcaster_review_id, user_id, ip, content) VALUES(#{broadcaster_review_id}, #{user_id}, #{ip}, #{content})
  </insert>
</mapper>
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/mapper/CommunityDAO.xml">CommunityDAO.xml</a>
</pre>
