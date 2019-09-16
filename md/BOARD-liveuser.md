## Demo
<h5>BJ별 게시판</h5>
<img src="https://user-images.githubusercontent.com/47962660/64983928-98e4cb00-d8fc-11e9-867a-194a732be84b.gif"/>
<h5>통힙 게시판</h5>
<img src="https://user-images.githubusercontent.com/47962660/64982757-ea3f8b00-d8f9-11e9-998e-e33d9b209c21.gif"/>

## ServletContext
```xml
<beans:bean name="boardWritePushHandler" class="com.kjh.aps.util.BoardWritePushHandler"/>

<!-- Web Socket -->
<websocket:handlers allowed-origins="*">
  <websocket:mapping handler="boardWritePushHandler" path="/BoardWritePush"/>
  <websocket:sockjs/>
</websocket:handlers>
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/webapp/WEB-INF/spring/appServlet/servlet-context.xml">ServletContext.xml</a>
</pre>
## Client
```javascript
var socket;
socket = new SockJS('<c:url value="/BoardWritePush"/>');
socket.onopen = onOpen;
socket.onmessage = onMessage;
socket.onclose = onClose;

function onOpen() {
  socket.send("${broadcaster.id}");
}
function onMessage(msg) {
  var message = msg.data.split(",");
  if(message[0] == "${broadcaster.id}") { // 접속 중인 방송인 커뮤니티 게시판의 알림일 경우만
    if(message.length == 3) {
      var tempHTML = "";
      tempHTML += "<div id='session-message-" + message[1] + "' class='session-message animated tdFadeInLeft' onclick=moveNewBoardWrite('" + message[0] + "','" + message[1] + "');>";
        tempHTML += "<div class='icon'><i class='fas fa-info-circle fa-3x'></i></div>";
        tempHTML += "<div class='content'>";
          tempHTML += "<div class='title'>새 글이 등록되었습니다.</div>";
          tempHTML += "<div class='subject'>" + message[2] + "</div>";
        tempHTML += "</div>";
      tempHTML += "</div>";
      $(".session-message-box").append(tempHTML);
      setTimeout(function() { $("#session-message-" + message[1]).addClass("animated tdFadeOutRight"); }, 5000);
      setTimeout(function() { $("#session-message-" + message[1]).remove(); }, 5500);
    } else {
      $("#conn-users").html(message[1].replace(/\B(?=(\d{3})+(?!\d))/g, ","));
    }
  } else if(message[0] == "combine") {
    if(message.length == 3) {
      var tempHTML = "";
      tempHTML += "<div id='session-message-" + message[1] + "' class='session-message animated tdFadeInLeft' onclick=moveNewBoardWrite('" + message[0] + "','" + message[1] + "');>";
        tempHTML += "<div class='icon'><i class='fas fa-info-circle fa-3x'></i></div>";
        tempHTML += "<div class='content'>";
          tempHTML += "<div class='title'>새 글이 등록되었습니다.</div>";
          tempHTML += "<div class='subject'>" + message[2] + "</div>";
        tempHTML += "</div>";
      tempHTML += "</div>";
      $(".session-message-box").append(tempHTML);
      setTimeout(function() { $("#session-message-" + message[1]).addClass("animated tdFadeOutRight"); }, 5000);
      setTimeout(function() { $("#session-message-" + message[1]).remove(); }, 5500);
    } else {
      $("#conn-users").html(message[1].replace(/\B(?=(\d{3})+(?!\d))/g, ","));
    }
  }
}
function onClose(evt) {
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
function moveNewBoardWrite(type, id) {
  if(type == "combine") {
    location.href= "${pageContext.request.contextPath}/community/combine/view/" + id;
  } else {
    location.href= "${pageContext.request.contextPath}/community/board/view/" + id + "?broadcasterId=" + broadcasterId;
  }
}
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/webapp/resources/include/board/board_socket.jsp">board_socket.jsp</a>
</pre>
## CommunityController
```java
@Inject
private CommunityService communityService;
  
// 통합 게시판 글 작성
@PostMapping("/combine/writeOk")
public String combineBoardWriteOk(BoardDTO dto, BindingResult result,
  @RequestParam(value = "page", defaultValue = "1") int page,
  HttpServletRequest request, Model model) {
		
  CombineBoardValidator validation = new CombineBoardValidator();
  String error = "insertFail";
		
  Map<String, Object> map = null;
		
  // 파라미터 유효성 검사
  if(validation.supports(dto.getClass())) {
    dto.setIp(request.getRemoteAddr());
    Integer userId = request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id");
			
    if(dto.getBoard_type().equals("user") && userId != 0) { // 회원이 작성한 글이라면
      dto.setUser_id(userId);
      dto.setNickname((String)request.getSession().getAttribute("nickname"));
      dto.setProfile((String)request.getSession().getAttribute("profile"));
      dto.setLevel((Integer)request.getSession().getAttribute("level"));
      dto.setUserType((Integer)request.getSession().getAttribute("userType"));
    }
    validation.validate(dto, result);
			
    if(request.getSession().getAttribute("prevention") != null) { // 도배방지 세션 값이 존재하다면
      dto.setPrevention(true);
      error = "prevention";
    }
			
    // 오류가 존재하지 않다면
    if(!result.hasErrors()) {
      try {
        map = communityService.insertBoardWrite(dto); // 글 추가
					
        String resultMsg = (String)map.get("result");
					
        if(resultMsg.equals("Success")) { // 정상적으로 추가되었다면
          for(WebSocketSession session : BoardWritePushHandler.sessionList) { // 새 글 알림
            if(!session.getRemoteAddress().getHostName().equals(request.getRemoteAddr())) { // 작성자 본인 제외
              session.sendMessage(new TextMessage("combine" + "," + dto.getId() + "," + dto.getSubject()));
            }
          }
          model.addAttribute("resultMsg", resultMsg);
          return "redirect:/community/combine/view/" + dto.getId() + "?page=" + page + "";
        }
      } catch (Exception e) {
        throw new RuntimeException(e);
      }
    }
  }

  model.addAttribute("error", error);
		
  return "community/combine/combine_write";
}

// 방송인 커뮤니티 게시판 글 작성
@PostMapping("/board/writeOk")
public String boardWriteOk(BoardDTO dto, BindingResult result,
  @RequestParam(value = "page", defaultValue = "1") int page,
  HttpServletRequest request, Model model) {
		
  BoardValidator validation = new BoardValidator();
  validation.setRequest(request);
  String error = "insertFail";
		
  Map<String, Object> map = null;
		
  // 파라미터 유효성 검사
  if(validation.supports(dto.getClass())) {
    validation.validate(dto, result);
			
    if(request.getSession().getAttribute("prevention") != null) { // 도배방지 세션 값이 존재하다면
      dto.setPrevention(true);
      error = "prevention";
    }
			
    // 오류가 존재하지 않다면
    if(!result.hasErrors()) {
      dto.setIp(request.getRemoteAddr());
				
      try {
        map = communityService.insertBoardWrite(dto); // 글 추가
					
        String resultMsg = (String)map.get("result");
					
        if(resultMsg.equals("Success")) { // 정상적으로 추가되었다면
          for(WebSocketSession session : BoardWritePushHandler.sessionList) { // 새 글 알림
            if(!session.getRemoteAddress().getHostName().equals(request.getRemoteAddr())) { // 작성자 본인 제외
              session.sendMessage(new TextMessage(dto.getBroadcaster_id() + "," + dto.getId() + "," + dto.getSubject()));
            }
          }
          model.addAttribute("resultMsg", resultMsg);
          return "redirect:/community/board/view/" + dto.getId() + "?broadcasterId=" + dto.getBroadcaster_id() + "&page=" + page + "";
        }
      } catch (Exception e) {
        throw new RuntimeException(e);
      }
    }
  }
		
  BroadcasterDTO broadcaster = (BroadcasterDTO)map.get("broadcaster");
		
  if(broadcaster == null) { // 잘못된 방송인 아이디 값이 넘어왔다면
    return "confirm/not_exist";
  } else {
    model.addAttribute("broadcaster", broadcaster);
  }

  model.addAttribute("error", error);
		
  return "community/board/board_write";
}
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/controller/CommunityController.java">CommunityController</a>
</pre>
## BoardWritePushHandler
```java
public class BoardWritePushHandler extends TextWebSocketHandler {
	
  private static Logger logger = LoggerFactory.getLogger(BoardWritePushHandler.class);
	
  public static List<WebSocketSession> sessionList = new ArrayList<WebSocketSession>();
  public static Map<String, Map<String, String>> sessionCount = new HashMap<>();
	
  @Override
  public void afterConnectionEstablished(WebSocketSession session) throws Exception {
    sessionList.add(session);
    super.afterConnectionEstablished(session);
  }

  @Override
  protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
    Map<String, String> userMap = new HashMap<>();
    userMap.put(session.getId(), session.getId());
    if(sessionCount.get(message.getPayload()) == null) {
      sessionCount.put(message.getPayload(), userMap);
    } else {
      Map<String, String> sessionUserMap = sessionCount.get(message.getPayload());
      sessionUserMap.put(session.getId(), session.getId());
      sessionCount.put(message.getPayload(), sessionUserMap);
    }
    for(WebSocketSession sess : sessionList) {
      sess.sendMessage(new TextMessage(message.getPayload() + "," + sessionCount.get(message.getPayload()).size()));
    }
    super.handleTextMessage(session, message);
	}
	
  @Override
  public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
    sessionList.remove(session);
    Set<String> keys = sessionCount.keySet();
    for(String key : keys) {
      Map<String, String> userMap = sessionCount.get(key);
      userMap.remove(session.getId());
    }
    super.afterConnectionClosed(session, status);
  }
  
}
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/util/BoardWritePushHandler.java">BoardWritePushHandler.java</a>
</pre>
