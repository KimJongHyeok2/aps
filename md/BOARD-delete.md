## Demo
<img src="https://user-images.githubusercontent.com/47962660/64927760-3b904180-d84a-11e9-8e55-5e90cb5d1917.gif"/>

## CommunityController
```java
@Inject
private CommunityService communityService;

// 방송인 커뮤니티 게시판 글 삭제
@PostMapping("/board/deleteOk")
public String boardDeleteOk(int id, String broadcasterId,
  @RequestParam(value = "page", defaultValue = "1") int page,
  HttpServletRequest request, Model model) {

  try {
    Map<String, String> map = new HashMap<>();
    map.put("id", String.valueOf(id));
    map.put("broadcaster_id", broadcasterId);
    map.put("userId", String.valueOf(request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id")));
			
    String resultMsg = communityService.deleteBoardWrite(map); // 글 삭제(상태값 변경)
			
    if(resultMsg.equals("Success")) { // 정상적으로 글 상태값이 변경되었다면
      return "redirect:/community/board?id=" + broadcasterId;
    }
  } catch (Exception e) {
    throw new RuntimeException(e);
  }

  model.addAttribute("error", "deleteFail");

  return "redirect:/community/board/view/" + id + "?broadcasterId=" + broadcasterId + "&page=" + page + "";
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
public String deleteBoardWrite(Map<String, String> map) throws Exception { // 방송인 커뮤니티 게시판 글 삭제
		
  String result = "Fail";
		
  Integer boardUserId = dao.selectBoardWriteUserIdByMap(map);
		
  if(!(boardUserId == null)) {
    Integer userId = Integer.parseInt(map.get("userId"));
			
    if(boardUserId == userId) {
      map.put("user_id", String.valueOf(userId));
      int successCount = dao.deleteBoardWrite(map);
				
      if(successCount == 1) {
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
  <select id="selectBoardWriteUserIdByMap" resultType="Integer">
    SELECT b.user_id FROM (SELECT * FROM broadcaster_board WHERE broadcaster_id = #{broadcaster_id}) b WHERE b.id = #{id} AND status = 1
  </select>
  <update id="deleteBoardWrite">
    UPDATE broadcaster_board SET status = 0, delete_date = CURRENT_TIMESTAMP WHERE (broadcaster_id = #{broadcaster_id}) AND id = #{id} AND user_id = #{user_id}
  </update>
</mapper>
```
## CommonServiceImpl
```java
@Inject
private CommonDAO dao;

private final int EXPIRE_DELETE_DAY = 30;

@Override
@Transactional(isolation=Isolation.READ_COMMITTED)
@Scheduled(cron="0 0 0 * * *")
public void deleteExpireBroadcasterBoardWrite() throws Exception { // 방송인 커뮤니티 게시판의 삭제 요청 게시글 30일 보관 기한 만료 시 영구삭제
  dao.deleteExpireBoardWriteCommentReply(EXPIRE_DELETE_DAY);
  dao.deleteExpireBoardWriteCommentRecommendHistory(EXPIRE_DELETE_DAY);
  dao.deleteExpireBoardWriteComment(EXPIRE_DELETE_DAY);
  dao.deleteExpireBoardWriteRecommendHistory(EXPIRE_DELETE_DAY);
  dao.deleteExpireBoardWrite(EXPIRE_DELETE_DAY);
}
</pre>
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/service/CommonServiceImpl.java">CommonServiceImpl.java</a>
```
## CommonMapper
```xml
<mapper namespace="common">
  <delete id="deleteExpireBoardWriteCommentReply">
    DELETE FROM broadcaster_board_comment_reply WHERE broadcaster_board_comment_id IN (SELECT id FROM broadcaster_board_comment WHERE broadcaster_board_id IN (SELECT b.id FROM (SELECT id, delete_date, DATEDIFF(CURRENT_TIMESTAMP, delete_date) datediff FROM broadcaster_board WHERE status = 0) b WHERE b.datediff >= #{param1}))
  </delete>
  <delete id="deleteExpireBoardWriteCommentRecommendHistory">
    DELETE FROM broadcaster_board_comment_recommend_history WHERE broadcaster_board_comment_id IN (SELECT id FROM broadcaster_board_comment WHERE broadcaster_board_id IN (SELECT b.id FROM (SELECT id, delete_date, DATEDIFF(CURRENT_TIMESTAMP, delete_date) datediff FROM broadcaster_board WHERE status = 0) b WHERE b.datediff >= #{param1}))
  </delete>
  <delete id="deleteExpireBoardWriteComment">
    DELETE FROM broadcaster_board_comment WHERE broadcaster_board_id IN (SELECT b.id FROM (SELECT id, delete_date, DATEDIFF(CURRENT_TIMESTAMP, delete_date) datediff FROM broadcaster_board WHERE status = 0) b WHERE b.datediff >= #{param1})
  </delete>
  <delete id="deleteExpireBoardWriteRecommendHistory">
    DELETE FROM broadcaster_board_recommend_history WHERE broadcaster_board_id IN (SELECT b.id FROM (SELECT id, delete_date, DATEDIFF(CURRENT_TIMESTAMP, delete_date) datediff FROM broadcaster_board WHERE status = 0) b WHERE b.datediff >= #{param1})
  </delete>
  <delete id="deleteExpireBoardWrite">
    DELETE FROM broadcaster_board WHERE id IN (SELECT b.id FROM (SELECT id, delete_date, DATEDIFF(CURRENT_TIMESTAMP, delete_date) datediff FROM broadcaster_board WHERE status = 0) b WHERE b.datediff >= #{param1})
  </delete>
</mapper>
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/mapper/CommonDAO.xml">CommonDAO.xml</a>
</pre>
