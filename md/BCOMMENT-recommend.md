## Demo
<img src="https://user-images.githubusercontent.com/47962660/64964386-ee59b180-d8d5-11e9-864f-a6067e6e818d.gif"/>

## BoardView(Client)
```javascript
function recommendComment(id, type) {
  var broadcasterBoardId = "${board.id}";
  var userId = "${empty sessionScope.id? 0:sessionScope.id}";
	
  if(userId == 0) {
    modalToggle("#modal-type-2", "확인", "로그인이 필요한 기능입니다.");
    $("#modal-type-2 #2-identify-button").html("로그인");
    $("#modal-type-2 #2-identify-button").attr("onclick", "pageMove('login')");
    return false;
  } else {
    $.ajax({
      url: "${pageContext.request.contextPath}/community/board/comment/recommend",
      type: "POST",
      cache: false,
      data: {
        "id" : id,
        "broadcasterBoardId" : broadcasterBoardId,
        "type" : type
      },
      beforeSend: function(xhr) {
        xhr.setRequestHeader(header, token);
      },
      success: function(data, status) {
        if(status == "success") {
          if(data == "Success") {
            if(type == "up") {
              modalToggle("#modal-type-1", "안내", "추천을 누르셨습니다.");
              $("#comment-up-" + id).html(parseInt($("#comment-up-" + id).html()) + 1);
              $("#comment-up-" + id).parent(".up").addClass("active");
            } else if(type == "down") {
              modalToggle("#modal-type-1", "안내", "비추천을 누르셨습니다.");
              $("#comment-down-" + id).html(parseInt($("#comment-down-" + id).html()) + 1);
              $("#comment-down-" + id).parent(".down").addClass("active");
            }
          } else if(data == "Already Press Up") {
            modalToggle("#modal-type-1", "안내", "오늘은 이미 추천을 누르셨습니다.");
          } else if(data == "Already Press Down") {
            modalToggle("#modal-type-1", "안내", "오늘은 이미 비추천을 누르셨습니다.");
          } else if(data == "Login Required") {
            modalToggle("#modal-type-2", "확인", "로그인이 필요한 기능입니다.");
            $("#modal-type-2 #2-identify-button").html("로그인");
            $("#modal-type-2 #2-identify-button").attr("onclick", "pageMove('login')");
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

// 방송인 커뮤니티 게시판 글 댓글 추천
@PostMapping("/board/comment/recommend")
public @ResponseBody String boardCommentRecommend(@RequestParam(value = "id", defaultValue = "0") int id,
  String broadcasterBoardId, String type, HttpServletRequest request) {
		
  String resultMsg = "Fail";
		
  // 파라미터 유효성 검사
  if(!(id == 0 || broadcasterBoardId == null || broadcasterBoardId.length() == 0 || type == null || type.equals("up") && type.equals("down"))) {
    Integer userId = (Integer)request.getSession().getAttribute("id");
    String ip = request.getRemoteAddr();
				
    if(userId == null) { // 로그인 여부
      resultMsg = "Login Required";
    } else {
      Map<String, String> map = new HashMap<>();
      map.put("id", String.valueOf(id));
      map.put("broadcaster_board_id", broadcasterBoardId);
      map.put("user_id", String.valueOf(userId));
      map.put("ip", ip);
      map.put("type", type);
					
      try {
        resultMsg = communityService.updateBoardWriteCommentRecommend(map); // 댓글 추천

        if(resultMsg.equals("Success")) {
          request.setAttribute("type", "boardComment");
          request.setAttribute("board_comment_id", id);
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
@Transactional(isolation=Isolation.READ_COMMITTED)
public String updateBoardWriteCommentRecommend(Map<String, String> map) throws Exception { // 방송인 커뮤니티 게시판 글 댓글 추천 증가
		
  String result = "Fail";
		
  Integer recommendHistoryType = dao.selectBoardWriteCommentRecommendHistoryTypeByMap(map);
			
  if(recommendHistoryType == null) {
    int successCount = dao.updateBoardWriteCommentRecommend(map);
	
    if(successCount == 1) {
      successCount = dao.insertBoardWriteCommentRecommendHistory(map);
	
      if(successCount == 1) {
        result = "Success";
      }
    }
  } else {
    if(recommendHistoryType == 1) {
      result = "Already Press Up";
    } else if(recommendHistoryType == 2) {
      result = "Already Press Down";
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
  <select id="selectBoardWriteCommentRecommendHistoryTypeByMap" resultType="Integer">
    SELECT b.type FROM (SELECT * FROM broadcaster_board_comment_recommend_history WHERE broadcaster_board_comment_id = #{id}) b WHERE b.user_id = #{user_id} OR b.ip = #{ip}
  </select>
  <update id="updateBoardWriteCommentRecommend">
    <if test='type.equals("up")'>
      UPDATE broadcaster_board_comment SET up = up + 1 WHERE (broadcaster_board_id = #{broadcaster_board_id}) AND id = #{id} AND status = 1
    </if>
    <if test='type.equals("down")'>
      UPDATE broadcaster_board_comment SET down = down + 1 WHERE (broadcaster_board_id = #{broadcaster_board_id}) AND id = #{id} AND status = 1
    </if>
  </update>
  <insert id="insertBoardWriteCommentRecommendHistory">
    <if test='type.equals("up")'>
      INSERT INTO broadcaster_board_comment_recommend_history(broadcaster_board_comment_id, user_id, ip, type) VALUES(#{id}, #{user_id}, #{ip}, 1)
    </if>
    <if test='type.equals("down")'>
      INSERT INTO broadcaster_board_comment_recommend_history(broadcaster_board_comment_id, user_id, ip, type) VALUES(#{id}, #{user_id}, #{ip}, 2)
    </if>
	</insert>
</mapper>
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/mapper/CommunityDAO.xml">CommunityDAO.xml</a>
</pre>
## CommonServiceImpl
```java
@Inject
private CommonDAO dao;

private final int EXPIRE_DELETE_DAY_TYPE_RECOMMEND_HISTORY = 1;

@Override
@Transactional(isolation=Isolation.READ_COMMITTED)
@Scheduled(cron="0 0 0 * * *")
public void deleteExpireRecommendHistory() throws Exception {  // 보관 기한이 만료된 추천 기록들 영구삭제
  dao.deleteExpireBroadcasterBoardWriteRecommendHistory(EXPIRE_DELETE_DAY_TYPE_RECOMMEND_HISTORY);
  dao.deleteExpireBroadcasterBoardWriteCommentRecommendHistory(EXPIRE_DELETE_DAY_TYPE_RECOMMEND_HISTORY);
  dao.deleteExpireBroadcasterReviewRecommendHistory(EXPIRE_DELETE_DAY_TYPE_RECOMMEND_HISTORY);
  dao.deleteExpireCustomerServiceCommentRecommendHistory(EXPIRE_DELETE_DAY_TYPE_RECOMMEND_HISTORY);
  dao.deleteExpireCombineBoardWriteRecommendHistory(EXPIRE_DELETE_DAY_TYPE_RECOMMEND_HISTORY);
  dao.deleteExpireCombineBoardWriteCommentRecommendHistory(EXPIRE_DELETE_DAY_TYPE_RECOMMEND_HISTORY);
}
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/service/CommonServiceImpl.java">CommonServiceImpl.java</a>
</pre>
## CommonMapper
```xml
<mapper namespace="common">
  <delete id="deleteExpireBroadcasterBoardWriteRecommendHistory">
    DELETE FROM broadcaster_board_recommend_history WHERE id IN (SELECT r.id FROM (SELECT id, datediff(CURRENT_TIMESTAMP, register_date) datediff FROM broadcaster_board_recommend_history) r WHERE r.datediff >= #{param1})
  </delete>
  <delete id="deleteExpireBroadcasterBoardWriteCommentRecommendHistory">
    DELETE FROM broadcaster_board_comment_recommend_history WHERE id IN (SELECT r.id FROM (SELECT id, datediff(CURRENT_TIMESTAMP, register_date) datediff FROM broadcaster_board_comment_recommend_history) r WHERE r.datediff >= #{param1})
  </delete>
  <delete id="deleteExpireBroadcasterReviewRecommendHistory">
    DELETE FROM broadcaster_review_recommend_history WHERE id IN (SELECT r.id FROM (SELECT id, datediff(CURRENT_TIMESTAMP, register_date) datediff FROM broadcaster_review_recommend_history) r WHERE r.datediff >= #{param1})
  </delete>
  <delete id="deleteExpireCustomerServiceCommentRecommendHistory">
    DELETE FROM notice_comment_recommend_history WHERE id IN (SELECT r.id FROM (SELECT id, datediff(CURRENT_TIMESTAMP, register_date) datediff FROM notice_comment_recommend_history) r WHERE r.datediff >= #{param1})
  </delete>
  <delete id="deleteExpireCombineBoardWriteRecommendHistory">
    DELETE FROM combine_board_recommend_history WHERE id IN (SELECT r.id FROM (SELECT id, datediff(CURRENT_TIMESTAMP, register_date) datediff FROM combine_board_recommend_history) r WHERE r.datediff >= #{param1})
  </delete>
  <delete id="deleteExpireCombineBoardWriteCommentRecommendHistory">
    DELETE FROM combine_board_comment_recommend_history WHERE id IN (SELECT r.id FROM (SELECT id, datediff(CURRENT_TIMESTAMP, register_date) datediff FROM combine_board_comment_recommend_history) r WHERE r.datediff >= #{param1})
  </delete>
</mapper>
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/mapper/CommonDAO.xml">CommonDAO.xml</a>
</pre>
