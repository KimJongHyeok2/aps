## Demo
<img src="https://user-images.githubusercontent.com/47962660/64966353-958c1800-d8d9-11e9-8ab6-49da44f2a299.gif"/>

## Review(Client)
```javascript
function modifyReview(id) {
  var pop = window.open("${pageContext.request.contextPath}/community/review/modify/" + id + "?broadcasterId=${broadcaster.id}", "pop", "width=500, height=712, scrollbars=yes, resizable=yes");
}
function modifyReviewOk(data) {
  if(data == "Success") {
    var commentPage = $("#comment-page").val();
    selectReview(commentPage);
  }
}
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/webapp/WEB-INF/views/community/review.jsp">reviwe.jsp</a>
</pre>
## ReviewModify(Client)
```javascript
function modifyReviewOk() {
  var content = $("#comment").val();
  var broadcasterId = "${review.broadcaster_id}";
  var broadcasterReviewId = "${review.id}";
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
          url: "${pageContext.request.contextPath}/community/review/modifyOk",
          type: "POST",
          cache: false,
          data: {
            "broadcaster_id" : broadcasterId,
            "id" : broadcasterReviewId,
            "user_id" : userId,
            "content" : content
          },
          beforeSend: function(xhr) {
            xhr.setRequestHeader(header, token);
          },
          success: function(data, status) {
            if(status == "success") {
              if(data == "Success") {
                opener.modifyReviewOk(data);
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
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/webapp/WEB-INF/views/community/review_modify.jsp">review_modify.jsp</a>
</pre>
## CommunityController
```java
@Inject
private CommunityService communityService;
  
// 방송인 민심평가 수정 페이지
@GetMapping("/review/modify/{id}")
public String reviewModify(@PathVariable int id, String broadcasterId, 
  HttpServletRequest request, Model model) {
		
  try {
    Map<String, String> map = new HashMap<>();
    map.put("id", String.valueOf(id));
    map.put("broadcaster_id", broadcasterId);
    map.put("user_id", String.valueOf(request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id")));

    Object object = communityService.selectBroadcasterReviewByMap(map); // 수정할 평가
			
    if(object instanceof String) {
      String resultMsg = (String)object;
				
      if(resultMsg.equals("not_exist")) {
        return "confirm/" + resultMsg;
      } else if(resultMsg.equals("error_405")) {
        return "confirm/" + resultMsg;
      }
    } else if(object instanceof CommentDTO) { // 정상적으로 불러왔다면
      model.addAttribute("review", (CommentDTO)object);
    }
  } catch (Exception e) {
    throw new RuntimeException(e);
  }
		
  return "community/review_modify";
}
	
// 방송인 민심평가 수정
@PostMapping("/review/modifyOk")
public @ResponseBody String reviewModifyOk(CommentDTO dto, BindingResult result,
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
        resultMsg = communityService.updateBroadcasterReview(dto); // 평가 수정
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
public Object selectBroadcasterReviewByMap(Map<String, String> map) throws Exception { // 평가 불러오기
		
  Object result = "Fail";
		
  CommentDTO comment = dao.selectBroadcasterReviewByMap(map);
		
  if(comment == null) {
    result = "error_404";
  } else {
    if(comment.getUser_id() == Integer.parseInt(map.get("user_id"))) {
      result = comment;
    } else {
      result = "error_405";
    }
  }
		
  return result;
}

@Override
public String updateBroadcasterReview(CommentDTO dto) throws Exception { // 평가 수정
		
  String result = "Fail";
		
  int successCount = dao.updateBroadcasterReview(dto);
		
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
  <select id="selectBroadcasterReviewByMap" resultType="com.kjh.aps.domain.CommentDTO">
    SELECT b.* FROM (SELECT * FROM broadcaster_review WHERE broadcaster_id = #{broadcaster_id}) b WHERE b.id = #{id} AND status = 1
  </select>
  <update id="updateBroadcasterReview">
    UPDATE broadcaster_review SET ip = #{ip}, content = #{content} WHERE (broadcaster_id = #{broadcaster_id}) AND (id = #{id} AND user_id = #{user_id}) AND status = 1
  </update>
</mapper>
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/mapper/CommunityDAO.xml">CommunityDAO.xml</a>
</pre>
