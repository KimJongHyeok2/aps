## Demo
<img src="https://user-images.githubusercontent.com/47962660/64945677-0ae0f400-d8ac-11e9-975d-a4f9f8bd6468.gif"/>

## BoardView(Client)
```javascript
// 게시글 추천/비추천
function recommend(type) {
  var id = "${board.id}";
  var broadcasterId = "${broadcaster.id}";
  var userId = "${empty sessionScope.id? 0:sessionScope.id}";
	
  if(userId == 0) {
    modalToggle("#modal-type-2", "확인", "로그인이 필요한 기능입니다.");
    $("#modal-type-2 #2-identify-button").html("로그인");
    $("#modal-type-2 #2-identify-button").attr("onclick", "pageMove('login')");
    return false;
  } else {
    $.ajax({
      url: "${pageContext.request.contextPath}/community/board/recommend",
      type: "POST",
      cache: false,
      data: {
        "id" : id,
        "broadcasterId" : broadcasterId,
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
              $("#up").html(parseInt($("#up").html()) + 1);
              $("#up").parent("button").addClass("active");
            } else if(type == "down") {
              modalToggle("#modal-type-1", "안내", "비추천을 누르셨습니다.");
              $("#down").html(parseInt($("#down").html()) + 1);
              $("#down").parent("button").addClass("active");
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

// 방송인 커뮤니티 게시판 글 추천
@PostMapping("/board/recommend")
public @ResponseBody String boardRecommend(@RequestParam(value = "id", defaultValue = "0") int id,
  String broadcasterId, String type, HttpServletRequest request) {
		
  String resultMsg = "Fail";
		
  // 파라미터 유효성 검사
  if(!(id == 0 || broadcasterId == null || broadcasterId.length() == 0 || type == null || type.equals("up") && type.equals("down"))) {
    Integer userId = request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id");
    String ip = request.getRemoteAddr();
				
    if(userId == 0) { // 로그인 여부
      resultMsg = "Login Required";
    } else {
      Map<String, String> map = new HashMap<>();
      map.put("id", String.valueOf(id));
      map.put("broadcaster_id", broadcasterId);
      map.put("user_id", String.valueOf(userId));
      map.put("ip", ip);
      map.put("type", type);
					
      try {
        resultMsg = communityService.updateBoardWriteRecommend(map); // 글 추천

        if(resultMsg.equals("Success")) {
          request.setAttribute("type", "board");
          request.setAttribute("board_id", id);
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
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/controller/CommunityController.java">CommunityControler.java</a>
</pre>
## CommunityServiceImpl
```java
@Inject
private CommunityDAO dao;
  
@Override
@Transactional(isolation=Isolation.READ_COMMITTED)
public String updateBoardWriteRecommend(Map<String, String> map) throws Exception { // 방송인 커뮤니티 게시판 글 댓글 추천 증가
		
  String result = "Fail";
		
  Integer recommendHistoryType = dao.selectBoardWriteRecommendHistoryTypeByMap(map);

  if(recommendHistoryType == null) {
    int successCount = dao.updateBoardWriteRecommend(map);

    if(successCount == 1) {
      successCount = dao.insertBoardWriteRecommendHistory(map);
	
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
  <select id="selectBoardWriteRecommendHistoryTypeByMap" resultType="Integer">
    SELECT b.type FROM (SELECT * FROM broadcaster_board_recommend_history WHERE broadcaster_id = #{broadcaster_id}) b WHERE b.broadcaster_board_id = #{id} AND (b.user_id = #{user_id} OR b.ip = #{ip})
  </select>
  <update id="updateBoardWriteRecommend">
    <if test='type.equals("up")'>
      UPDATE broadcaster_board SET up = up + 1 WHERE (broadcaster_id = #{broadcaster_id}) AND id = #{id} AND status = 1
    </if>
    <if test='type.equals("down")'>
      UPDATE broadcaster_board SET down = down + 1 WHERE (broadcaster_id = #{broadcaster_id}) AND id = #{id} AND status = 1
    </if>
  </update>
  <insert id="insertBoardWriteRecommendHistory">
    <if test='type.equals("up")'>
      INSERT INTO broadcaster_board_recommend_history(broadcaster_id, broadcaster_board_id, user_id, ip, type) VALUES(#{broadcaster_id}, #{id}, #{user_id}, #{ip}, 1)
    </if>
    <if test='type.equals("down")'>
      INSERT INTO broadcaster_board_recommend_history(broadcaster_id, broadcaster_board_id, user_id, ip, type) VALUES(#{broadcaster_id}, #{id}, #{user_id}, #{ip}, 2)
    </if>
  </insert>
</mapper>
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/mapper/CommunityDAO.xml">CommunityDAO.xml</a>
</pre>
