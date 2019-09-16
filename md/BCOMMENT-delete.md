## Demo
<img src="https://user-images.githubusercontent.com/47962660/64964007-2c0a0a80-d8d5-11e9-923b-c80e84864077.gif"/>

## BoardView(Client)
```javascript
function deleteComment(id) {
  modalToggle("#modal-type-2", "확인", "정말로 삭제하시겠습니까?");
  $("#modal-type-2 #2-identify-button").attr("onclick", "deleteCommentOk('" + id + "');");
}
function deleteCommentOk(id) {
  var broadcasterBoardId = "${board.id}";
  var userId = "${empty sessionScope.id? 0:sessionScope.id}";
	
  if(userId == 0) {
    modalToggle("#modal-type-2", "확인", "로그인이 필요한 기능입니다.");
    $("#modal-type-2 #2-identify-button").html("로그인");
    $("#modal-type-2 #2-identify-button").attr("onclick", "pageMove('login')");
    return false;
  } else {
    $.ajax({
      url: "${pageContext.request.contextPath}/community/board/comment/deleteOk",
      type: "POST",
      cache: false,
      data: {
        "broadcasterBoardId" : broadcasterBoardId,
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
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/webapp/WEB-INF/views/community/board/board_view.jsp">board_view.jsp</a>
</pre>
## CommunityController
```java
@Inject
private CommunityService communityService;

// 방송인 커뮤니티 게시판 글 댓글 삭제
@PostMapping("/board/comment/deleteOk")
public @ResponseBody String boardCommentDeleteOk(int broadcasterBoardId, int id, HttpServletRequest request) {

  String resultMsg = "Fail";
		
  try {
    Map<String, Integer> map = new HashMap<>();
    map.put("broadcaster_board_id", broadcasterBoardId);
    map.put("id", id);
    map.put("userId", request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id"));
			
    resultMsg = communityService.deleteBoardWriteComment(map);
  } catch (Exception e) {
    throw new ResponseBodyException(e);
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
public String deleteBoardWriteComment(Map<String, Integer> map) throws Exception { // 방송인 커뮤니티 게시판 글 댓글 삭제
		
  String result = "Fail";
		
  Integer commentUserId = dao.selectBoardWriteCommentUserIdByMap(map);
		
  if(commentUserId != null) { // 정상적으로 불러왔다면
    Integer userId = map.get("userId");
			
    if(commentUserId == userId) { // 삭제를 요청한 회원의 고유번호와 일치한다면
      map.put("user_id", userId);
				
      int successCount = dao.deleteBoardWriteComment(map);
				
      if(successCount == 1) { // 정상적으로 삭제처리 되었다면
        result = "Success";
      }
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
  <select id="selectBoardWriteCommentUserIdByMap" resultType="Integer">
    SELECT user_id FROM broadcaster_board_comment WHERE (broadcaster_board_id = #{broadcaster_board_id}) AND id = #{id} AND status = 1
  </select>
  <update id="deleteBoardWriteComment">
    UPDATE broadcaster_board_comment SET status = 0, delete_date = CURRENT_TIMESTAMP WHERE (broadcaster_board_id = #{broadcaster_board_id}) AND id = #{id} AND user_id = #{user_id}
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
public void deleteExpireBroadcasterComment() throws Exception { // 방송인 커뮤니티 게시판 글의 삭제 요청 댓글 및 답글 30일 보관 기한 만료 시 영구삭제
  dao.deleteExpireBoardWriteCommentIndivReply(EXPIRE_DELETE_DAY);
  dao.deleteExpireBoardWriteCommentReplyIndiv(EXPIRE_DELETE_DAY);
  dao.deleteExpireBoardWriteCommentIndivRecommendHistory(EXPIRE_DELETE_DAY);
  dao.deleteExpireBoardWriteCommentIndiv(EXPIRE_DELETE_DAY);
}
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/service/CommonServiceImpl.java">CommonServiceImpl.java</a>
</pre>
## CommonMapper
```xml
<mapper namespace="common">
  <delete id="deleteExpireBoardWriteCommentIndivReply">
    DELETE FROM broadcaster_board_comment_reply WHERE broadcaster_board_comment_id IN (SELECT bc.id FROM (SELECT id, delete_date, datediff(CURRENT_TIMESTAMP, delete_date) datediff FROM broadcaster_board_comment WHERE status = 0) bc WHERE bc.datediff >= #{param1})
  </delete>
  <delete id="deleteExpireBoardWriteCommentReplyIndiv">
    DELETE FROM broadcaster_board_comment_reply WHERE id IN (SELECT bc_r.id FROM (SELECT id, delete_date, datediff(CURRENT_TIMESTAMP, delete_date) datediff FROM broadcaster_board_comment_reply WHERE status = 0) bc_r WHERE bc_r.datediff >= #{param1})
  </delete>
  <delete id="deleteExpireBoardWriteCommentIndivRecommendHistory">	
    DELETE FROM broadcaster_board_comment_recommend_history WHERE broadcaster_board_comment_id IN (SELECT bc.id FROM (SELECT id, delete_date, datediff(CURRENT_TIMESTAMP, delete_date) datediff FROM broadcaster_board_comment WHERE status = 0) bc WHERE bc.datediff >= #{param1})
  </delete>
  <delete id="deleteExpireBoardWriteCommentIndiv">
    DELETE FROM broadcaster_board_comment WHERE id IN (SELECT bc.id FROM (SELECT id, delete_date, datediff(CURRENT_TIMESTAMP, delete_date) datediff FROM broadcaster_board_comment WHERE status = 0) bc WHERE bc.datediff >= #{param1})	
  </delete>
</mapper>
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/mapper/CommonDAO.xml">CommonDAO.xml</a>
</pre>
