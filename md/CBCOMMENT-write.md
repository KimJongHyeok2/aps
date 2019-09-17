## Demo
<img src="https://user-images.githubusercontent.com/47962660/65042878-c7ae8000-d994-11e9-90a7-07881ceb4e45.gif"/>

## CombineView(Client)
```javascript
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
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/webapp/WEB-INF/views/community/combine/combine_view.jsp">combine_view.jsp</a>
</pre>
## CommunityController
```java
@Inject
private CommunityService communityService;

// 통합 게시판 글의 댓글 작성
@PostMapping("/combine/comment/write")
public @ResponseBody String combineBoardWriteCommentWrite(CommentDTO dto, BindingResult result,
  HttpServletRequest request) {
		
  CombineCommentValidator validation = new CombineCommentValidator();
  validation.setRequest(request);

  String resultMsg = "Fail";
		
  // 파라미터 유효성 검사
  if(validation.supports(dto.getClass())) {
    dto.setIp(request.getRemoteAddr());
    Integer userId = request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id");
			
    if(dto.getComment_type().equals("user") && userId != 0) { // 회원이 작성한 글이라면
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
					
        resultMsg = communityService.insertCombineBoardWriteComment(dto); // 댓글 작성
					
        if(resultMsg.equals("Success")) { // 댓글 Push
          if(dto.getBoardUserId() != 0 && dto.getBoardSubject() != null) {							
            request.setAttribute("type", 6);
            request.setAttribute("dto", dto);
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
public String insertCombineBoardWriteComment(CommentDTO dto) throws Exception { // 통합 게시판 글의 댓글 등록

  String result = "Fail";
		 
  int successCount = 0;
		 
  if(!dto.isPrevention()) { 
    successCount = dao.insertCombineBoardWriteComment(dto);
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
  <insert id="insertCombineBoardWriteComment" parameterType="com.kjh.aps.domain.CommentDTO">
    <choose>
      <when test='comment_type.equals("non")'>
        INSERT INTO combine_board_comment(combine_board_id, nickname, password, ip, content, type)
        VALUE(#{combine_board_id}, #{nickname}, #{password}, #{ip}, #{content}, #{comment_type})
      </when>
      <when test='comment_type.equals("user") and user_id != 0'>
        INSERT INTO combine_board_comment(combine_board_id, user_id, ip, nickname, profile, level, content, user_type, type)
        VALUE(#{combine_board_id}, #{user_id}, #{ip}, #{nickname}, #{profile}, #{level}, #{content}, #{userType}, #{comment_type})
      </when>
    </choose>
  </insert>
</mapper>
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/mapper/CommunityDAO.xml">CommunityDAO.xml</a>
</pre>
