## Demo
<img src="https://user-images.githubusercontent.com/47962660/64967847-29f77a00-d8dc-11e9-81f4-d8b45d2b1223.gif"/>

## Review(Client)
```javascript
function deleteReview(id) {
  modalToggle("#modal-type-2", "확인", "정말로 삭제하시겠습니까?");
  $("#modal-type-2 #2-identify-button").attr("onclick", "deleteReviewOk('" + id + "');");
}
function deleteReviewOk(id) {
  var broadcasterId = "${broadcaster.id}";
  var userId = "${empty sessionScope.id? 0:sessionScope.id}";
  if(userId == 0) {
    modalToggle("#modal-type-2", "확인", "로그인이 필요한 기능입니다.");
    $("#modal-type-2 #2-identify-button").html("로그인");
    $("#modal-type-2 #2-identify-button").attr("onclick", "pageMove('login')");
    return false;
  } else {
    $.ajax({
      url: "${pageContext.request.contextPath}/community/review/deleteOk",
      type: "POST",
      cache: false,
      data: {
        "broadcasterId" : broadcasterId,
        "id" : id
      },
      beforeSend: function(xhr) {
        xhr.setRequestHeader(header, token);
      },
      success: function(data, status) {
        if(status == "success") {
          if(data == "Success") {
            modalToggle('#modal-type-2');
            selectReview();
            setTimeout(function() { selectReviewGradePointAverage() }, 1000);
            reviewSocket.send("write,${broadcaster.id}");
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
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/webapp/WEB-INF/views/community/review.jsp">review.jsp</a>
</pre>
## CommunityController
```java
@Inject
private CommunityService communityService;

// 방송인 민심평가 삭제
@PostMapping("/review/deleteOk")
public @ResponseBody String reviewDeleteOk(String broadcasterId,
  @RequestParam(value = "id", defaultValue = "0") int id,
  HttpServletRequest request) {
		
  String result = "Fail";
		
  try {
    Map<String, String> map = new HashMap<>();
    map.put("broadcaster_id", broadcasterId);
    map.put("id", String.valueOf(id));
    map.put("user_id", String.valueOf(request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id")));
			
    result = communityService.deleteBroadcasterReview(map);
  } catch (Exception e) {
    throw new ResponseBodyException(e);
  }
		
  return result;
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
public String deleteBroadcasterReview(Map<String, String> map) throws Exception { // 평가 삭제
		
  String result = "Fail";
		
  int successCount = dao.deleteBroadcasterReview(map);
		
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
  <update id="deleteBroadcasterReview">
    UPDATE broadcaster_review SET status = 0, delete_date = CURRENT_TIMESTAMP WHERE (broadcaster_id = #{broadcaster_id}) AND (id = #{id} AND user_id = #{user_id}) AND status = 1
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
public void deleteExpireBroadcasterReview() throws Exception { // 삭제 요청 민심평가 및 답글 30일 보관 기한 만료 시 영구삭제
  dao.deleteExpireBraodcasterReviewIndivReply(EXPIRE_DELETE_DAY);
  dao.deleteExpireBraodcasterReviewReplyIndiv(EXPIRE_DELETE_DAY);
  dao.deleteExpireBraodcasterReviewIndivRecommendHistory(EXPIRE_DELETE_DAY);
  dao.deleteExpireBraodcasterReviewIndiv(EXPIRE_DELETE_DAY);
}
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/service/CommonServiceImpl.java">CommonServiceImpl.java</a>
</pre>
## CommonMapper
```xml
<mapper namespace="common">
  <delete id="deleteExpireBraodcasterReviewIndivReply">
    DELETE FROM broadcaster_review_reply WHERE broadcaster_review_id IN (SELECT br_r.id FROM (SELECT id, delete_date, datediff(CURRENT_TIMESTAMP, delete_Date) datediff FROM broadcaster_review WHERE status = 0) br_r WHERE br_r.datediff >= #{param1})
  </delete>
  <delete id="deleteExpireBraodcasterReviewReplyIndiv">
    DELETE FROM broadcaster_review_reply WHERE id IN (SELECT br_r.id FROM (SELECT id, delete_date, datediff(CURRENT_TIMESTAMP, delete_date) datediff FROM broadcaster_review_reply WHERE status = 0) br_r WHERE br_r.datediff >= #{param1})
  </delete>
  <delete id="deleteExpireBraodcasterReviewIndivRecommendHistory">
    DELETE FROM broadcaster_review_recommend_history WHERE broadcaster_review_id IN (SELECT br_r.id FROM (SELECT id, delete_date, datediff(CURRENT_TIMESTAMP, delete_Date) datediff FROM broadcaster_review WHERE status = 0) br_r WHERE br_r.datediff >= #{param1})
  </delete>
  <delete id="deleteExpireBraodcasterReviewIndiv">
    DELETE FROM broadcaster_review WHERE id IN (SELECT br_r.id FROM (SELECT id, delete_date, datediff(CURRENT_TIMESTAMP, delete_Date) datediff FROM broadcaster_review WHERE status = 0) br_r WHERE br_r.datediff >= #{param1})
  </delete>
</mapper>
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/mapper/CommonDAO.xml">CommonDAO.xml</a>
</pre>
