## Demo
<img src="https://user-images.githubusercontent.com/47962660/65051164-98533f80-d9a3-11e9-9b1c-bb16576e901b.gif"/>

## CombineView(Client)
```javascript
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
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/webapp/WEB-INF/views/community/combine/combine_view.jsp">combine_view.jsp</a>
</pre>
## CommunityController
```java
@Inject
private CommunityService communityService;
  
// 통합 게시판 글 댓글의 답글 작성
@PostMapping("/combine/commentReply/write")
public @ResponseBody String combineBoardWriteCommentReplyWrite(CommentReplyDTO dto, BindingResult result,
  HttpServletRequest request) {
		
  CombineCommentReplyValidator validation = new CombineCommentReplyValidator();
  validation.setRequest(request);

  String resultMsg = "Fail";
		
  // 파라미터 유효성 검사
  if(validation.supports(dto.getClass())) {
    dto.setIp(request.getRemoteAddr());
    Integer userId = request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id");
			
    if(dto.getCommentReply_type().equals("user") && userId != 0) { // 회원이 작성한 글이라면
      dto.setUser_id(userId);
      dto.setNickname((String)request.getSession().getAttribute("nickname"));
      dto.setProfile((String)request.getSession().getAttribute("profile"));
      dto.setLevel((Integer)request.getSession().getAttribute("level"));
      dto.setUserType((Integer)request.getSession().getAttribute("userType"));
    }
    validation.validate(dto, result);
			
    // 오류가 존재하지 않다면
    if(!result.hasErrors()) {
      dto.setIp(request.getRemoteAddr());

      try {
        if(request.getSession().getAttribute("prevention") != null) { // 도배방지 세션 값이 존재하다면
          dto.setPrevention(true);
        }
					
        resultMsg = communityService.insertCombineBoardWriteCommentReply(dto); // 댓글 작성
					
        if(resultMsg.equals("Success")) { // 답글 Push
          if(dto.getCommentReply_type().equals("user")) {							
            request.setAttribute("dto", dto);
            request.setAttribute("type", 7);
          }
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
public String insertCombineBoardWriteCommentReply(CommentReplyDTO dto) throws Exception { // 통합 게시판 글의 답글 등록

  String result = "Fail";
  int successCount = 0;
		
  if(!dto.isPrevention()) { 
    successCount = dao.insertCombineBoardWriteCommentReply(dto);
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
  <insert id="insertCombineBoardWriteCommentReply" parameterType="com.kjh.aps.domain.CommentDTO">
    <choose>
      <when test='commentReply_type.equals("non")'>
        INSERT INTO combine_board_comment_reply(combine_board_comment_id, nickname, password, ip, content, type)
        VALUE(#{combine_board_comment_id}, #{nickname}, #{password}, #{ip}, #{content}, #{commentReply_type})
      </when>
      <when test='commentReply_type.equals("user") and user_id != 0'>
        INSERT INTO combine_board_comment_reply(combine_board_comment_id, user_id, ip, nickname, profile, level, content, user_type, type)
        VALUE(#{combine_board_comment_id}, #{user_id}, #{ip}, #{nickname}, #{profile}, #{level}, #{content}, #{userType}, #{commentReply_type})
      </when>
    </choose>
  </insert>
</mapper>
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/mapper/CommunityDAO.xml">CommunityDAO.xml</a>
</pre>
