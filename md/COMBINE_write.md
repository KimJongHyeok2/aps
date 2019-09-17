## Demo
<h5>회원/비회원 모두 게시글을 작성할 수 있습니다.</h5>
<img src="https://user-images.githubusercontent.com/47962660/65025685-20205600-d972-11e9-8a5f-e0ed82f12574.gif"/>

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
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/controller/CommunityController.java">CommunityController.java</a>
</pre>
## CommunityServiceImpl
```java
@Inject
private CommunityDAO dao;

@Override
public Map<String, Object> insertBoardWrite(BoardDTO dto) throws Exception { // 방송인 커뮤니티 게시판 글 작성
		
  Map<String, Object> map = new HashMap<>();
  String result = "Fail";
		
  int successCount = 0;
		
  if(!dto.isPrevention()) { // 도배 제한에 걸려있지 않아야 DB에 글 등록
    successCount = dao.insertBoardWrite(dto);
  }
	
  if(successCount == 1) {
    result = "Success";
  } else {
    map.put("broadcaster", dao.selectBroadcasterById(dto.getBroadcaster_id()));
  }
		
  map.put("result", result);
		
  return map;
}
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/service/CommunityServiceImpl.java">CommunityServiceImpl.java</a>
</pre>
## CommunityMapper
```xml
<mapper namespace="community">
  <insert id="insertBoardWrite" parameterType="com.kjh.aps.domain.BoardDTO" useGeneratedKeys="true" keyProperty="id" keyColumn="id">
    <choose>
      <when test="board_type != null">
        <choose>
          <when test='board_type.equals("non")'>
            INSERT INTO combine_board(nickname, password, ip, subject, content, image_flag, media_flag, type)
            VALUE(#{nickname}, #{password}, #{ip}, #{subject}, #{content}, #{image_flag}, #{media_flag}, #{board_type})
          </when>
          <when test='board_type.equals("user") and user_id != 0'>
            INSERT INTO combine_board(user_id, nickname, profile, level, ip, subject, content, image_flag, media_flag, user_type, type)
            VALUE(#{user_id}, #{nickname}, #{profile}, #{level}, #{ip}, #{subject}, #{content}, #{image_flag}, #{media_flag}, #{userType}, #{board_type})
          </when>
        </choose>
      </when>
      <otherwise>
        INSERT INTO broadcaster_board(broadcaster_id, user_id, ip, subject, content, image_flag, media_flag)
        VALUE(#{broadcaster_id}, #{user_id}, #{ip}, #{subject}, #{content}, #{image_flag}, #{media_flag})
      </otherwise>
    </choose>
  </insert>
</mapper>
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/mapper/CommunityDAO.xml">CommunityDAO.xml</a>
</pre>
