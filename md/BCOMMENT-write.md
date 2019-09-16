## Demo
<img src="https://user-images.githubusercontent.com/47962660/64952839-51d6e580-d8bc-11e9-8b57-c3007da4164f.gif"/>

## BoardView(Client)
```javascript
function writeComment() {
  var content = myEditor.getData();
  var broadcasterId = "${broadcaster.id}";
  var broadcasterBoardId = "${board.id}";
  var boardUserId = "${board.user_id}";
  var boardSubject = "${board.subject}";
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
          url: "${pageContext.request.contextPath}/community/board/comment/write",
          type: "POST",
          cache: false,
          data: {
            "broadcaster_id" : broadcasterId,
            "broadcaster_board_id" : broadcasterBoardId,
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
  }
}
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/webapp/WEB-INF/views/community/board/board_view.jsp">board_view.jsp</a>
</pre>
## CommunityController
```java
@Inject
private CommunityService communityService;
  
// 방송인 커뮤니티 게시판 글 댓글 작성
@PostMapping("/board/comment/write")
public @ResponseBody String boardCommentWrite(CommentDTO dto, BindingResult result,
  String broacasterId, HttpServletRequest request) {
		
  CommentValidator validation = new CommentValidator();
  validation.setRequest(request);

  String resultMsg = "Fail";
		
  // 파라미터 유효성 검사
  if(validation.supports(dto.getClass())) {
    validation.validate(dto, result);
			
    // 오류가 존재하지 않다면
    if(!result.hasErrors()) {
      dto.setIp(request.getRemoteAddr());

      try {
        if(request.getSession().getAttribute("prevention") != null) { // 도배방지 세션 값이 존재하다면
          dto.setPrevention(true);
        }
					
        resultMsg = communityService.insertBoardWriteComment(dto); // 댓글 작성

        if(resultMsg.equals("Success")) { // 댓글 Push
          request.setAttribute("type", 1);
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
## CommunityService
```java
@Inject
private CommunityDAO dao;
  
@Override
public String insertBoardWriteComment(CommentDTO dto) throws Exception { // 방송인 커뮤니티 게시판 글 댓글 작성
		
  String result = "Fail";
		 
  int successCount = 0;
		 
  if(!dto.isPrevention()) { 
    successCount = dao.insertBoardWriteComment(dto);
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
  <insert id="insertBoardWriteComment" parameterType="com.kjh.aps.domain.CommentDTO" useGeneratedKeys="true" keyProperty="id" keyColumn="id">
    INSERT INTO broadcaster_board_comment(broadcaster_board_id, user_id, ip, content) VALUES(#{broadcaster_board_id}, #{user_id}, #{ip}, #{content})
  </insert>
</mapper>
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/mapper/CommunityDAO.xml">CommunityDAO.xml</a>
</pre>
