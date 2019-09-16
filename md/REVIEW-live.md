## Demo
<img src="https://user-images.githubusercontent.com/47962660/64978837-61245600-d8f1-11e9-8990-3febd999a89a.gif"/>

## ServletContext
```xml
<beans:bean name="gradePointAverageHandler" class="com.kjh.aps.util.GradePointAverageHandler"/>

<!-- Web Socket -->
<websocket:handlers allowed-origins="*">
  <websocket:mapping handler="gradePointAverageHandler" path="/GradePointAverage"/>
  <websocket:sockjs/>
</websocket:handlers>
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/webapp/WEB-INF/spring/appServlet/servlet-context.xml">ServletContext.xml</a>
</pre>
## Review(Client)
```javascript
var reviewSocket;
reviewSocket = new SockJS('<c:url value="/GradePointAverage"/>');
reviewSocket.onopen = reviewOnOpen;
reviewSocket.onmessage = reviewOnMessage;
reviewSocket.onclose = reviewOnClose;

function reviewOnOpen() {
  reviewSocket.send("open,${broadcaster.id}");
}
function reviewOnMessage(msg) {
  var message = msg.data.split(",");
  var prevTodayGpAvg = parseFloat($("#gp-avg-today").html().trim());
  var prevWeekGpAvg = parseFloat($("#gp-avg-week").html().trim());
  var prevMonthGpAvg = parseFloat($("#gp-avg-month").html().trim());
	
  var newTodayGpAvg = parseFloat(message[0]);
  var newWeekGpAvg = parseFloat(message[1]);
  var newMonthGpAvg = parseFloat(message[2]);
	
  var broadcasterId = message[3];
	
  if("${broadcaster.id}" == broadcasterId) {
    $("#gp-avg-today").html(newTodayGpAvg);
    $("#gp-avg-week").html(newWeekGpAvg);
    $("#gp-avg-month").html(newMonthGpAvg);
		
    $(".stat-content .stat-avg i").removeClass("on");
		
    if(!reviewSocketSendFlag) {
      $(".stat-content .stat-avg .fa-minus").addClass("on");
      reviewSocketSendFlag = true;
    } else {
      gpAvgCompare("today", prevTodayGpAvg, newTodayGpAvg);
      gpAvgCompare("week", prevWeekGpAvg, newWeekGpAvg);
      gpAvgCompare("month", prevMonthGpAvg, newMonthGpAvg);
    }		
  }
}
function gpAvgCompare(type, prevGpAvg, newGpAvg) {
  if(prevGpAvg > newGpAvg) {
    $("#stat-avg-" +  type + " .fa-caret-square-down").addClass("on");
  } else if(prevGpAvg < newGpAvg) {
    $("#stat-avg-" +  type + " .fa-caret-square-up").addClass("on");		
  } else {
    $("#stat-avg-" +  type + " .fa-minus").addClass("on");				
  }
}
function reviewOnClose(evt) {
  var tempHTML = "";
  tempHTML += "<div id='session-message-error' class='session-message animated tdFadeInLeft'>";
    tempHTML += "<div class='icon'><i class='fas fa-exclamation-triangle fa-3x'></i></div>";
    tempHTML += "<div class='content'>";
      tempHTML += "<div class='title'>연결이 종료되었습니다.</div>";
      tempHTML += "<div class='subject'>새로고침을 진행해주세요.</div>";
    tempHTML += "</div>";
  tempHTML += "</div>";
  $(".session-message-box").html(tempHTML);
  setTimeout(function() { $("#session-message-error").addClass("animated tdFadeOutRight"); }, 5000);
  setTimeout(function() { $("#session-message-error").remove(); }, 5500)
}

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
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/webapp/WEB-INF/views/community/review.jsp">review.jsp</a>
</pre>
## GradePointAverageHandler
```java
public class GradePointAverageHandler extends TextWebSocketHandler {

  @Inject
  private CommunityService communityService;  
	public static List<WebSocketSession> sessionList = new ArrayList<WebSocketSession>();

  @Override
  public void afterConnectionEstablished(WebSocketSession session) throws Exception {
    sessionList.add(session);
    super.afterConnectionEstablished(session);
  }
	
  @Override
  protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
		
    String[] values = message.getPayload().split(",");
    String type = values[0];
    String broadcasterId = values[1];
		
    ReviewGradePointDTO reviewGradePoint = communityService.selectBroadcasterReviewGradePointAverageByMap(broadcasterId);
		
    if(type.equals("open")) {
      if(reviewGradePoint == null) {
        session.sendMessage(new TextMessage("0,0,0," + broadcasterId));
      } else {				
        session.sendMessage(new TextMessage(reviewGradePoint.getGp_avg_today() + "," + reviewGradePoint.getGp_avg_week() + "," + reviewGradePoint.getGp_avg_month() + "," + broadcasterId));
      }
    } else if(type.equals("write")) {
      for(WebSocketSession sessions : sessionList) {
        if(reviewGradePoint == null) {
          sessions.sendMessage(new TextMessage("0,0,0," + broadcasterId));
        } else {					
          sessions.sendMessage(new TextMessage(reviewGradePoint.getGp_avg_today() + "," + reviewGradePoint.getGp_avg_week() + "," + reviewGradePoint.getGp_avg_month() + "," + broadcasterId));
        }
      }
    }
    
    super.handleTextMessage(session, message);
  }
	
  @Override
  public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
    sessionList.remove(session);
    super.afterConnectionClosed(session, status);
  }
	
}
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/util/GradePointAverageHandler.java">GradePoinAverageHandler.java</a>
</pre>
## CommunityServiceImpl
```java
@Inject
private CommunityDAO dao;

@Override
@Transactional(readOnly = true)
public ReviewGradePointDTO selectBroadcasterReviewGradePointAverageByMap(String broadcasterId) throws Exception { // 일일, 주간, 월간 평점 평균
		
  Map<String, String> map = new HashMap<>();
  map.put("broadcaster_id", broadcasterId);
		
  Calendar today = Calendar.getInstance(timezone);
  Calendar startDay = Calendar.getInstance(timezone);
  Calendar endDay = Calendar.getInstance(timezone);
		
  startDay.add(Calendar.DATE, -startDay.get(Calendar.DAY_OF_WEEK) + 1); // 이번 주의 시작
  endDay.set(Calendar.DAY_OF_WEEK, Calendar.SUNDAY); // 이번 주의 끝
  endDay.add(Calendar.DATE, 7);
		
  map.put("today", sdf.format(today.getTime()));
  map.put("startDay", sdf.format(startDay.getTime()));
  map.put("endDay", sdf.format(endDay.getTime()));
		
  return dao.selectBroadcasterReviewGradePointAverageByMap(map);
}
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/service/CommunityServiceImpl.java">CommunityServiceImpl.java</a>
</pre>
## CommunityMapper
```xml
<mapper namespace="community">
  <select id="selectBroadcasterReviewGradePointAverageByMap" resultType="com.kjh.aps.domain.ReviewGradePointDTO">
    SELECT 
      round(avg((SELECT gp FROM broadcaster_review WHERE id = b.id AND DATE_FORMAT(register_date, '%Y-%m-%d') = DATE_FORMAT(#{today}, '%Y-%m-%d'))), 1) gp_avg_today,
      round(avg((SELECT gp FROM broadcaster_review WHERE id = b.id AND DATE_FORMAT(register_date, '%Y-%m-%d') BETWEEN DATE_FORMAT(#{startDay}, '%Y-%m-%d') AND DATE_FORMAT(#{endDay}, '%Y-%m-%d'))), 1) gp_avg_week,
      round(avg((SELECT gp FROM broadcaster_review WHERE id = b.id AND DATE_FORMAT(register_date, '%Y-%m') = DATE_FORMAT(#{today}, '%Y-%m'))), 1) gp_avg_month
    FROM
      broadcaster_review b WHERE b.broadcaster_id = #{broadcaster_id} AND b.status = 1
  </select>
</mapper>
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/mapper/CommunityDAO.xml">CommunityDAO.xml</a>
</pre>
