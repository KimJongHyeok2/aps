## Demo
<img src="https://user-images.githubusercontent.com/47962660/65048006-5ecc0580-d99e-11e9-9de9-4d776f46eac4.gif"/>

## CombineView(Client)
```javascript
// 댓글 삭제
function deleteComment(id, type) {
  if(type == "non") {
    var pop = window.open("${pageContext.request.contextPath}/community/combine/comment/confirm?id=" + id + "&type=delete", "pop", "width=500, height=712, scrollbars=yes, resizable=yes");
  } else {
    modalToggle("#modal-type-2", "확인", "정말로 삭제하시겠습니까?");
    $("#modal-type-2 #2-identify-button").attr("onclick", "deleteCommentOk('" + id + "');");
  }
}
function deleteCommentOk(id) {
  var userId = "${empty sessionScope.id? 0:sessionScope.id}";
	
  if(userId == 0) {
    modalToggle("#modal-type-2", "확인", "로그인이 필요한 기능입니다.");
    $("#modal-type-2 #2-identify-button").html("로그인");
    $("#modal-type-2 #2-identify-button").attr("onclick", "pageMove('login')");
    return false;
  } else {
    $.ajax({
      url: "${pageContext.request.contextPath}/community/combine/comment/deleteOk",
      type: "POST",
      cache: false,
      data: {
        "id" : id
      },
      beforeSend: function(xhr) {
        xhr.setRequestHeader(header, token);
      },
      success: function(data, status) {
        if(status == "success") {
          if(data == "Success") {
            modalToggle('#modal-type-2');
            selectComment();
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
## CommentConfirm(Client)
```javascript
function deleteComment(id) {
  var password = $("#password").val();
	
  if(password == null || password.length == 0) {
    modalToggle("#modal-type-1", "안내", "비밀번호를 입력해주세요.");
    return false;
  } else {
    $.ajax({
      url: "${pageContext.request.contextPath}/community/combine/comment/deleteOk",
      type: "POST",
      cache: false,
      data: {
        "id" : id,
        "password" : password
      },
      beforeSend: function(xhr) {
        xhr.setRequestHeader(header, token);
      },
      success: function(data, status) {
        if(status == "success") {
          if(data == "Success") {
            opener.nonCommentDeleteOk(data);
            window.close();
          } else if(data == "Password Wrong") {
            modalToggle("#modal-type-1", "안내", "비밀번호를 다시 한번 확인해주세요.");
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
function deleteCommentReply(id, combineCommentId) {
  var password = $("#password").val();
	
  if(password == null || password.length == 0) {
    modalToggle("#modal-type-1", "안내", "비밀번호를 입력해주세요.");
    return false;
  } else {
    $.ajax({
      url: "${pageContext.request.contextPath}/community/combine/commentReply/deleteOk",
      type: "POST",
      cache: false,
      data: {
        "id" : id,
        "password" : password
      },
      beforeSend: function(xhr) {
        xhr.setRequestHeader(header, token);
      },
      success: function(data, status) {
        if(status == "success") {
          if(data == "Success") {
            opener.nonCommentReplyDeleteOk(data, combineCommentId);
            window.close();
          } else if(data == "Password Wrong") {
            modalToggle("#modal-type-1", "안내", "비밀번호를 다시 한번 확인해주세요.");
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
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/webapp/WEB-INF/views/community/combine/comment_confirm.jsp">comment_confirm.jsp</a>
</pre>
## CommunityController
```java
@Inject
private CommunityService communityService;
  
// 통합 게시판 글의 댓글 수정 또는 삭제 전 Confirm 페이지
@GetMapping("/combine/comment/confirm")
public String combineCommentConfirm(@RequestParam(value = "id", defaultValue = "0") int id,
  Integer combineCommentId, String type, Model model) {
  String resultView = "confirm/not_exist";
		
  if(id != 0 && type != null && (type.equals("modify") || type.equals("delete") || type.equals("deleteReply"))) {
    try {					
      String commentType = null;
				
      if(type.equals("modify") || type.equals("delete")) {					
        commentType = communityService.selectCombineBoardWriteCommentTypeById(id);
      } else if(type.equals("deleteReply")) {
        commentType = communityService.selectCombineBoardWriteCommentReplyTypeById(id);
        if(combineCommentId != null) { model.addAttribute("combineCommentId", combineCommentId); }
      }
				
      if(commentType.equals("non")) {
        resultView = "community/combine/comment_confirm";
        model.addAttribute("type", type);
      }
        model.addAttribute("id", id);
      } catch (Exception e) {
        throw new RuntimeException(e);
      }
    }
		
    return resultView;
}
  
// 통합 게시판 글의 댓글 삭제
@PostMapping("/combine/comment/deleteOk")
public @ResponseBody String combineBoardWriteCommentDeleteOk(@RequestParam(value = "id", defaultValue = "0") int id,
  String password, HttpServletRequest request, Model model) {

  String resultMsg = "Fail";
		
  try {
    Map<String, String> map = new HashMap<>();
    map.put("id", String.valueOf(id));
    map.put("user_id", String.valueOf(request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id")));
    map.put("password", password);
			
    resultMsg = communityService.deleteCombineBoardWriteComment(map); // 글 삭제(상태값 변경)
  } catch (Exception e) {
    throw new RuntimeException(e);
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
public String selectCombineBoardWriteCommentTypeById(int id) throws Exception { // 통합 게시판 글의 댓글 타입
  return dao.selectCombineBoardWriteCommentTypeById(id);
}
  
@Override
public String deleteCombineBoardWriteComment(Map<String, String> map) throws Exception { // 통합 게시판 글의 댓글 삭제(상태값 변경)

  String result = "Fail";
		
  String commentType = dao.selectCombineBoardWriteCommentTypeById(Integer.parseInt(map.get("id")));
		
  if(commentType != null) {
    map.put("comment_type", commentType);
    int successCount = dao.deleteCombineBoardWriteComment(map);
			
    if(successCount == 0) {
      if(commentType.equals("non")) {
        result = "Password Wrong";
      }
    } else {
      result = "Success";
    }
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
  <select id="selectCombineBoardWriteCommentTypeById" resultType="String">
    SELECT type FROM combine_board_comment WHERE id = #{param1} AND status = 1
  </select>
  <update id="deleteCombineBoardWriteComment">
    <choose>
      <when test='comment_type.equals("non")'>
        UPDATE combine_board_comment SET status = 0, delete_date = CURRENT_TIMESTAMP WHERE id = #{id} AND password = #{password} AND type = #{comment_type}
      </when>
      <when test='comment_type.equals("user")'>
        UPDATE combine_board_comment SET status = 0, delete_date = CURRENT_TIMESTAMP WHERE id = #{id} AND user_id = #{user_id} AND type = #{comment_type}
      </when>
    </choose>
  </update>
</mapper>
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/mapper/CommunityDAO.xml">CommunityDAO.xml</a>
</pre>
## CommonServiceImpl
```java
@Inject
private CommonDAO dao;
  
private final int EXPIRE_DELETE_DAY = 30;
  
@Override
@Transactional(isolation=Isolation.READ_COMMITTED)
@Scheduled(cron="0 0 0 * * *")
public void deleteExpireCombineBoardWriteComment() throws Exception { // 통합 게시판의 삭제 요청 댓글 및 답글 30일 보관 기한 만료 시 영구삭제
  dao.deleteExpireCombineBoardWriteCommentIndivReply(EXPIRE_DELETE_DAY);
  dao.deleteExpireCombineBoardWriteCommentReplyIndiv(EXPIRE_DELETE_DAY);
  dao.deleteExpireCombineBoardWriteCommentIndivRecommendHistory(EXPIRE_DELETE_DAY);
  dao.deleteExpireCombineBoardWriteCommentIndiv(EXPIRE_DELETE_DAY);
}
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/service/CommonServiceImpl.java">CommonServiceImpl.java</a>
</pre>
## CommonMapper
```xml
<mapper namespace="common">
  <delete id="deleteExpireCombineBoardWriteCommentIndivReply">
    DELETE FROM combine_board_comment_reply WHERE combine_board_comment_id IN (SELECT bc.id FROM (SELECT id, delete_date, datediff(CURRENT_TIMESTAMP, delete_date) datediff FROM combine_board_comment WHERE status = 0) bc WHERE bc.datediff >= #{param1})
  </delete>
  <delete id="deleteExpireCombineBoardWriteCommentReplyIndiv">
    DELETE FROM combine_board_comment_reply WHERE id IN (SELECT bc_r.id FROM (SELECT id, delete_date, datediff(CURRENT_TIMESTAMP, delete_date) datediff FROM combine_board_comment_reply WHERE status = 0) bc_r WHERE bc_r.datediff >= #{param1})
  </delete>
  <delete id="deleteExpireCombineBoardWriteCommentIndivRecommendHistory">	
    DELETE FROM combine_board_comment_recommend_history WHERE combine_board_comment_id IN (SELECT bc.id FROM (SELECT id, delete_date, datediff(CURRENT_TIMESTAMP, delete_date) datediff FROM combine_board_comment WHERE status = 0) bc WHERE bc.datediff >= #{param1})
  </delete>
  <delete id="deleteExpireCombineBoardWriteCommentIndiv">
    DELETE FROM combine_board_comment WHERE id IN (SELECT bc.id FROM (SELECT id, delete_date, datediff(CURRENT_TIMESTAMP, delete_date) datediff FROM combine_board_comment WHERE status = 0) bc WHERE bc.datediff >= #{param1})	
  </delete>
</mapper>
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/mapper/CommonDAO.xml">CommonDAO.xml</a>
</pre>
