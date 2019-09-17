## Demo
<img src="https://user-images.githubusercontent.com/47962660/65029893-7e046c00-d979-11e9-9e17-e9f2ab2e4488.gif"/>

## CommunityController
```java
@Inject
private CommunityService communityService;

// 통합 게시판 글 수정 또는 삭제 전 Confirm 페이지
@GetMapping("/combine/confirm")
public String combineConfirm(@RequestParam(value = "id", defaultValue = "0") int id, String type,
  @RequestParam(value = "page", defaultValue = "1") int page, Model model) {
  String resultView = "confirm/not_exist";
  if(id != 0 && type != null && (type.equals("modify") || type.equals("delete"))) {
    try {
      String boardType = communityService.selectCombineBoardWriteTypeById(id);
				
      if(boardType.equals("non")) {
        resultView = "community/combine/combine_confirm";
        model.addAttribute("type", type);
      }
				
      model.addAttribute("page", page);
      model.addAttribute("id", id);
    } catch (Exception e) {
      throw new RuntimeException(e);
    }
  }
		
  return resultView;
}

// 통합 게시판 글 삭제
@PostMapping("/combine/deleteOk")
public String combineBoardWriteDeleteOk(@RequestParam(value = "id", defaultValue = "0") int id,
  String password, @RequestParam(value = "page", defaultValue = "1") int page,
  HttpServletRequest request, Model model) {

  try {
    Map<String, String> map = new HashMap<>();
    map.put("id", String.valueOf(id));
    map.put("user_id", String.valueOf(request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id")));
    map.put("password", password);
			
    String resultMsg = communityService.deleteCombineBoardWrite(map); // 글 삭제(상태값 변경)
			
    if(resultMsg.equals("Success")) { // 정상적으로 글 상태값이 변경되었다면
      return "redirect:/community/combine";
    } else if(resultMsg.equals("Password Wrong")) {
      model.addAttribute("id", id);
      model.addAttribute("type", "delete");
      model.addAttribute("error", resultMsg);
      return "community/combine/combine_confirm";
    }
  } catch (Exception e) {
    throw new RuntimeException(e);
  }

  model.addAttribute("error", "deleteFail");

  return "redirect:/community/combine/view/" + id + "?page=" + page;
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
public String deleteCombineBoardWrite(Map<String, String> map) throws Exception { // 통합게시판 글 삭제
		
  String result = "Fail";
		
  String boardType = dao.selectCombineBoardWriteTypeById(Integer.parseInt(map.get("id")));
		
  if(boardType != null) {
    map.put("board_type", boardType);
    int successCount = dao.deleteCombineBoardWrite(map);
			
    if(successCount == 0) {
      if(boardType.equals("non")) {
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
  <select id="selectCombineBoardWriteTypeById" resultType="String">
    SELECT type FROM combine_board WHERE id = #{param1} AND status = 1
  </select>
  <update id="deleteCombineBoardWrite">
    <choose>
      <when test='board_type.equals("non")'>
        UPDATE combine_board SET status = 0, delete_date = CURRENT_TIMESTAMP WHERE id = #{id} AND password = #{password} AND type = #{board_type}
      </when>
      <when test='board_type.equals("user")'>
        UPDATE combine_board SET status = 0, delete_date = CURRENT_TIMESTAMP WHERE id = #{id} AND user_id = #{user_id} AND type = #{board_type}
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
public void deleteExpireCombineBoardWrite() throws Exception { // 통합 게시판의 삭제 요청 게시글 30일 보관 기한 만료 시 영구삭제
  dao.deleteExpireCombineBoardWriteCommentReply(EXPIRE_DELETE_DAY);
  dao.deleteExpireCombineBoardWriteCommentRecommendHistoryIndiv(EXPIRE_DELETE_DAY);
  dao.deleteExpireCombineBoardWriteComment(EXPIRE_DELETE_DAY);
  dao.deleteExpireCombineBoardWriteRecommendHistoryIndiv(EXPIRE_DELETE_DAY);
  dao.deleteExpireCombineBoardWrite(EXPIRE_DELETE_DAY);
}
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/service/CommonServiceImpl.java">CommonServiceImpl.java</a>
</pre>
## CommonMapper
```xml
<mapper namespace="common">
  <delete id="deleteExpireCombineBoardWriteCommentReply">
    DELETE FROM combine_board_comment_reply WHERE combine_board_comment_id IN (SELECT id FROM combine_board_comment WHERE combine_board_id IN (SELECT b.id FROM (SELECT id, delete_date, DATEDIFF(CURRENT_TIMESTAMP, delete_date) datediff FROM combine_board WHERE status = 0) b WHERE b.datediff >= #{param1}))
  </delete>
  <delete id="deleteExpireCombineBoardWriteCommentRecommendHistoryIndiv">
    DELETE FROM combine_board_comment_recommend_history WHERE combine_board_comment_id IN (SELECT id FROM combine_board_comment WHERE combine_board_id IN (SELECT b.id FROM (SELECT id, delete_date, DATEDIFF(CURRENT_TIMESTAMP, delete_date) datediff FROM combine_board WHERE status = 0) b WHERE b.datediff >= #{param1}))
  </delete>
  <delete id="deleteExpireCombineBoardWriteComment">
    DELETE FROM combine_board_comment WHERE combine_board_id IN (SELECT b.id FROM (SELECT id, delete_date, DATEDIFF(CURRENT_TIMESTAMP, delete_date) datediff FROM combine_board WHERE status = 0) b WHERE b.datediff >= #{param1})
  </delete>
  <delete id="deleteExpireCombineBoardWriteRecommendHistoryIndiv">
    DELETE FROM combine_board_recommend_history WHERE combine_board_id IN (SELECT b.id FROM (SELECT id, delete_date, DATEDIFF(CURRENT_TIMESTAMP, delete_date) datediff FROM combine_board WHERE status = 0) b WHERE b.datediff >= #{param1})
  </delete>
  <delete id="deleteExpireCombineBoardWrite">
    DELETE FROM combine_board WHERE id IN (SELECT b.id FROM (SELECT id, delete_date, DATEDIFF(CURRENT_TIMESTAMP, delete_date) datediff FROM combine_board WHERE status = 0) b WHERE b.datediff >= #{param1})
  </delete>
</mapper>
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/mapper/CommonDAO.xml">CommonDAO.xml</a>
</pre>
