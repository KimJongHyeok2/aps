## Demo
<img src="https://user-images.githubusercontent.com/47962660/64955319-e80e0a00-d8c2-11e9-9f70-84f7d5d55380.gif"/>

## BoardView(Client)
```javascript
function modifyComment(id) {
  var pop = window.open("${pageContext.request.contextPath}/community/board/comment/modify/" + id + "?broadcasterBoardId=${board.id}", "pop", "width=500, height=712, scrollbars=yes, resizable=yes");
}
function modifyCommentOk(data) {
  if(data == "Success") {
    var commentPage = $("#comment-page").val();
    selectComment(commentPage);
  }
}
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/webapp/WEB-INF/views/community/board/board_view.jsp">board_view.jsp</a>
</pre>
## CommentModify(Client)
```javascript
var header = $("meta[name='_csrf_header']").attr("content");
var token = $("meta[name='_csrf']").attr("content");

function modifyCommentOk() {
  var content = myEditor.getData();
  var broadcasterBoardId = "${comment.broadcaster_board_id}";
  var broadcasterBoardCommentId = "${comment.id}";
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
          url: "${pageContext.request.contextPath}/community/board/comment/modifyOk",
          type: "POST",
          cache: false,
          data: {
            "broadcaster_board_id" : broadcasterBoardId,
            "id" : broadcasterBoardCommentId,
            "user_id" : userId,
            "content" : content
          },
          beforeSend: function(xhr) {
            xhr.setRequestHeader(header, token);
          },
          success: function(data, status) {
            if(status == "success") {
              if(data == "Success") {
                opener.modifyCommentOk(data);
                window.close();
              } else {
                modalToggle("#modal-type-4", "오류", "알 수 없는 오류입니다.");
              }
            }
          }
        });
      }
    }
  }
}
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/webapp/WEB-INF/views/community/board/comment_modify.jsp">comment_modify.jsp</a>
</pre>
## CommunityController
```java
@Inject
private CommunityService communityService;
  
// 방송인 커뮤니티 게시판 글 댓글 수정 페이지
@GetMapping("/board/comment/modify/{id}")
public String boardCommentModify(@PathVariable int id, int broadcasterBoardId, 
  HttpServletRequest request, Model model) {
		
  try {
    Map<String, Integer> map = new HashMap<>();
    map.put("id", id);
    map.put("broadcaster_board_id", broadcasterBoardId);
    map.put("userId", request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id"));

    Object object = communityService.selectBoardWriteCommentByMap(map); // 수정할 댓글
			
    if(object instanceof String) {
      String resultMsg = (String)object;
				
      if(resultMsg.equals("not_exist")) {
        return "confirm/" + resultMsg;
      } else if(resultMsg.equals("error_405")) {
        return "confirm/" + resultMsg;
      }
    } else if(object instanceof CommentDTO) { // 정상적으로 불러왔다면
      model.addAttribute("comment", (CommentDTO)object);
    }
  } catch (Exception e) {
    throw new RuntimeException(e);
  }
		
  return "community/board/comment_modify";
}
	
// 방송인 커뮤니티 게시판 글 댓글 수정
@PostMapping("/board/comment/modifyOk")
public @ResponseBody String boardCommentModifyOk(CommentDTO dto, BindingResult result,
  HttpServletRequest request) {
		
  CommentValidator validation = new CommentValidator();
  validation.setRequest(request);
		
  String resultMsg = "Fail";
		
  // 파라미터 유효성 검사
    if(validation.supports(dto.getClass())) {
      validation.validate(dto, result);
			
      // 오류가 존재하지 않다면
      if(!result.hasErrors()) {
        dto.setIp(request.getRemoteAddr());
        Integer userId = request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id");
        dto.setUser_id(userId);
				
        try {
          resultMsg = communityService.updateBoardWriteComment(dto); // 글 수정
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
@Transactional(readOnly = true)
public Object selectBoardWriteCommentByMap(Map<String, Integer> map) throws Exception { // 방송인 커뮤니티 게시판 글 댓글 조회
		
  Object result = "Fail";
		
  CommentDTO comment = dao.selectBoardWriteCommentByMap(map);
		
  if(comment == null) {
    result = "not_exist";
  } else {
    if(comment.getUser_id() == map.get("userId")) {
      result = comment;
    } else {
      result = "error_405";
    }
  }
		
  return result; 
}

@Override
public String updateBoardWriteComment(CommentDTO dto) throws Exception { // 방송인 커뮤니티 게시판 글 댓글 수정
		
  String result = "Fail";
		
  int successCount = dao.updateBoardWriteComment(dto);
		
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
  <select id="selectBoardWriteCommentByMap" resultType="com.kjh.aps.domain.CommentDTO">
    SELECT * FROM broadcaster_board_comment WHERE (broadcaster_board_id = #{broadcaster_board_id}) AND id = #{id} AND status = 1
  </select>
  <update id="updateBoardWriteComment">
    UPDATE broadcaster_board_comment SET ip = #{ip}, content = #{content} WHERE (broadcaster_board_id = #{broadcaster_board_id}) AND id = #{id} AND user_id = #{user_id} AND status = 1
  </update>
</mapper>
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/mapper/CommunityDAO.xml">CommunityDAO.xml</a>
</pre>
