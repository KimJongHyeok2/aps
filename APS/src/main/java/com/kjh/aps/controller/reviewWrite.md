## Demo
<h5>오늘 방송에 대한 의견 또는 총평을 등록할 수 있습니다.</h5>
<img src="https://user-images.githubusercontent.com/47962660/64944499-6eb5ed80-d8a9-11e9-96ea-e111b48ecd43.gif"/>

## Review(Client)
<pre>
function writeReview() {
  var rating = $("#rate").rateYo("option", "rating");
  var content = $("#comment").val();
  var broadcasterId = "${broadcaster.id}";
  var userId = "${empty sessionScope.id? 0:sessionScope.id}";
	
  if(userId == 0) {
    modalToggle("#modal-type-2", "확인", "로그인이 필요한 기능입니다.");
    $("#modal-type-2 #2-identify-button").html("로그인");
    $("#modal-type-2 #2-identify-button").attr("onclick", "pageMove('login')");
    return false;
  } else {
    if(rating == 0) {
      modalToggle("#modal-type-1", "안내", "0점 이상을 입력해주세요.");
      return false;
    }
    if(content == null || content.length == 0) {
      modalToggle("#modal-type-1", "안내", "의견을 입력해주세요.");
      return false;
    } else {
      if(content.length > 5000) {
        modalToggle("#modal-type-1", "안내", "의견은 5000자 이하로 입력해주세요.");
        return false;
      } else {
        $.ajax({
          url: "${pageContext.request.contextPath}/community/review/write",
          type: "POST",
          cache: false,
          data: {
            "broadcaster_id" : broadcasterId,
            "user_id" : userId,
            "gp" : rating,
            "content" : content
          },
          beforeSend: function(xhr) {
            xhr.setRequestHeader(header, token);
          },
          success: function(data, status) {
            if(status == "success") {
              if(data == "Success") {
                $("#comment").val("");
                $("#rate").rateYo("option", "rating", 0);
                $("#counter").html("0");
                selectReview();
                setTimeout(function() { selectReviewGradePointAverage() }, 1000);
                reviewSocket.send("write,${broadcaster.id}");
              } else if(data == "Already Review Write") {
                modalToggle("#modal-type-1", "안내", "오늘은 이미 해당 BJ의 민심평가를 진행하셨습니다.");
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
  }
}
</s:authorize>
</pre>
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/webapp/WEB-INF/views/community/review.jsp">review.jsp</a>
</pre>
## CommunityController
<pre>
@Inject
private CommunityService communityService;
  
// 방송인 민심평가 등록
@PostMapping("/review/write")
public @ResponseBody String reviewWrite(CommentDTO dto, BindingResult result,
  HttpServletRequest request) {
  String resultMsg = "Fail";
		
  CommentValidator validation = new CommentValidator();
  validation.setRequest(request);
		
  // 파라미터 유효성 검사
  if(validation.supports(dto.getClass())) {
    validation.validate(dto, result);
    dto.setIp(request.getRemoteAddr());
			
    // 오류가 존재하지 않다면
    if(!result.hasErrors()) {
      try {
        resultMsg = communityService.insertBroadcasterReview(dto);
      } catch (Exception e) {
        throw new ResponseBodyException(e);
      }
    }
  }
		
  return resultMsg;
}
</pre>
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/controller/CommunityController.java">CommunityController.java</a>
</pre>
## CommunityServiceImpl
<pre>
@Inject
private CommunityDAO dao;
  
@Override
public String insertBroadcasterReview(CommentDTO dto) throws Exception { // 방송인 평가 등록
		
  String result = "Fail";
		
  Map<String, String> map = new HashMap<>();
  Calendar today = Calendar.getInstance(timezone);
  map.put("today", sdf.format(today.getTime()));
  map.put("broadcaster_id", dto.getBroadcaster_id());
  map.put("user_id", String.valueOf(dto.getUser_id()));
  map.put("ip", dto.getIp());
		
  int todayReviewCount = dao.selectBroadcasterReviewCountByMap(map);
  int successCount = 0;
		
  if(todayReviewCount == 0) {
    successCount = dao.insertBroadcasterReview(dto);
  } else {
    result = "Already Review Write";
  }
		
  if(successCount == 1) {
    result = "Success";
  }
		
  return result;
}
</pre>
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/service/CommunityServiceImpl.java">CommunityServiceImpl.java</a>
</pre>
## CommunityMapper
<pre>
&lt;mapper namespace="community"&gt;
  &lt;select id="selectBroadcasterReviewCountByMap" resultType="Integer"&gt;
    SELECT count(br.id) FROM (SELECT * FROM broadcaster_review WHERE broadcaster_id = #{broadcaster_id}) br WHERE DATE_FORMAT(br.register_date, '%Y-%m-%d') = DATE_FORMAT(#{today}, '%Y-%m-%d') AND (br.user_id = #{user_id} OR br.ip = #{ip}) 
  &lt;/select&gt;
  &lt;insert id="insertBroadcasterReview" parameterType="com.kjh.aps.domain.CommentDTO"&gt;
    INSERT INTO broadcaster_review(broadcaster_id, user_id, ip, gp, content) VALUES(#{broadcaster_id}, #{user_id}, #{ip}, #{gp}, #{content})
  &lt;/insert&gt;
&lt;/mapper&gt;
</pre>
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/mapper/CommunityDAO.xml">CommunityDAO.xml</a>
</pre>
