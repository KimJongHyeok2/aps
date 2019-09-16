## Demo
<img src="https://user-images.githubusercontent.com/47962660/64927298-ef420300-d843-11e9-8cd7-ea623c31434b.gif"/>

## CommunityController
```java
@Inject
private CommunityService communityService;
private final int BOARD_PAGEBLOCK = 5;
private final int BOARD_POPULAR_ORDER = 20;
private final int COMMENT_PAGEBLOCK = 5;
private final int COMMENT_POPULAR_ORDER = 20;

// 방송인 커뮤니티 게시판 글 수정 페이지
@GetMapping("/board/modify/{id}")
public String boardModify(@PathVariable int id, String broadcasterId,
  @RequestParam(value = "page", defaultValue = "1") int page,
  HttpServletRequest request, Model model) {
		
  try {
    Map<String, String> map = new HashMap<>();
    map.put("id", String.valueOf(id));
    map.put("broadcaster_id", broadcasterId);
    map.put("userId", String.valueOf(request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id")));
			
    Map<String, Object> maps = communityService.selectBoardWriteByMap(map);
			
    String resultMsg = (String)maps.get("result");
			
    if(resultMsg.equals("Success")) { // 정상적으로 불러왔다면
      model.addAttribute("board", (BoardDTO)maps.get("board"));
    } else if(resultMsg.equals("not_exist")) {
      return "confirm/" + resultMsg;
    } else if(resultMsg.equals("error_405")) {
      return "confirm/" + resultMsg;
    } else {
      return "confirm/error_404";
    }
			
    BroadcasterDTO broadcaster = (BroadcasterDTO)maps.get("broadcaster");
			
    if(broadcaster == null) { // 잘못된 방송인 아이디 값이 넘어왔다면
      return "confirm/not_exist";
    } else {
      model.addAttribute("broadcaster", broadcaster);
    }
  } catch (Exception e) {
    throw new RuntimeException(e);
  }
		
  return "community/board/board_modify";
}
	
// 방송인 커뮤니티 게시판 글 수정
@PostMapping("/board/modifyOk")
public String boardModifyOk(BoardDTO dto, BindingResult result,
  @RequestParam(value = "page", defaultValue = "1") int page,
  HttpServletRequest request, Model model) {

  BoardValidator validation = new BoardValidator();
  validation.setRequest(request);

  Map<String, Object> map = null;
		
  // 파라미터 유효성 검사
  if(validation.supports(dto.getClass())) {
    validation.validate(dto, result);
			
    // 오류가 존재하지 않다면
    if(!result.hasErrors()) {
      dto.setIp(request.getRemoteAddr());
      Integer userId = request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id");
      dto.setUser_id(userId);
				
      try {
        map = communityService.updateBoardWrite(dto); // 글 수정
        String resultMsg = (String)map.get("result");
					
        if(resultMsg.equals("Success")) { // 정상적으로 수정되었다면
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

  model.addAttribute("error", "updateFail");
		
  return "community/board/board_modify";
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
public Map<String, Object> selectBoardWriteByMap(Map<String, String> map) throws Exception { // 방송인 커뮤니티 게시판 글 정보조회
				
  Map<String, Object> maps = new HashMap<>();
  String result = "Fail";
		
  BoardDTO board = dao.selectBoardWriteByMap(map);
		
  if(board == null) {
    result = "not_exist";
  } else {
    Integer userId = Integer.parseInt(map.get("userId"));
			
    if(board.getUser_id() == userId) {
      result = "Success";
    } else {
    	result = "error_405";
    }
  }
		
  if(result.equals("Success")) {
    maps.put("board", board);
  }
		
  maps.put("result", result);
  maps.put("broadcaster", dao.selectBroadcasterById(board.getBroadcaster_id()));

  return maps;
}

@Override
public Map<String, Object> updateBoardWrite(BoardDTO dto) throws Exception { // 방송인 커뮤니티 게시판 글 수정
		
  Map<String, Object> map = new HashMap<>();
  String result = "Fail";
		
  int successCount = dao.updateBoardWrite(dto);
		
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
  <select id="selectBoardWriteByMap" resultType="com.kjh.aps.domain.BoardDTO">
    <![CDATA[
      SELECT
        brc_b.*, u.nickname as nickname, u.level as level, u.profile as profile, u.type as userType,
        (SELECT min(n.id) FROM (SELECT * FROM broadcaster_board WHERE broadcaster_id = #{broadcaster_id} AND status = 1) n WHERE n.id > #{id}) as next_id,
        (SELECT max(p.id) FROM (SELECT * FROM broadcaster_board WHERE broadcaster_id = #{broadcaster_id} AND status = 1) p WHERE p.id < #{id}) as prev_id,
        (SELECT ns.subject FROM (SELECT * FROM broadcaster_board WHERE broadcaster_id = #{broadcaster_id} AND status = 1) ns WHERE ns.id = (SELECT min(n.id) FROM (SELECT * FROM broadcaster_board WHERE broadcaster_id = #{broadcaster_id} AND status = 1) n WHERE n.id > #{id})) as next_subject,
        (SELECT ps.subject FROM (SELECT * FROM broadcaster_board WHERE broadcaster_id = #{broadcaster_id} AND status = 1) ps WHERE ps.id = (SELECT max(p.id) FROM (SELECT * FROM broadcaster_board WHERE broadcaster_id = #{broadcaster_id} AND status = 1) p WHERE p.id < #{id})) as prev_subject,
        (SELECT b.type FROM (SELECT * FROM broadcaster_board_recommend_history WHERE broadcaster_id = #{broadcaster_id}) b WHERE b.broadcaster_board_id = #{id} AND (b.user_id = #{user_id} OR b.ip = #{ip})) type,
        ((SELECT count(id) FROM broadcaster_board_comment WHERE broadcaster_board_id = #{id} AND status = 1) + (SELECT count(id) FROM broadcaster_board_comment_reply WHERE broadcaster_board_comment_id IN (SELECT id FROM broadcaster_board_comment WHERE broadcaster_board_id = #{id}) AND status = 1)) commentCount
      FROM
        (SELECT * FROM broadcaster_board WHERE broadcaster_id = #{broadcaster_id} AND status = 1) brc_b INNER JOIN user u ON brc_b.user_id = u.id
      WHERE brc_b.id = #{id} AND brc_b.status = 1
    ]]>
  </select>
  <select id="selectBroadcasterById" resultType="com.kjh.aps.domain.BroadcasterDTO">
    SELECT * FROM broadcaster WHERE id = #{param1}
  </select>
  <update id="updateBoardWrite" parameterType="com.kjh.aps.domain.BoardDTO">
    UPDATE broadcaster_board SET ip = #{ip}, subject = #{subject}, content = #{content}, image_flag = #{image_flag}, media_flag = #{media_flag} WHERE (broadcaster_id = #{broadcaster_id}) AND id = #{id} AND user_id = #{user_id} AND status = 1
  </update>
</maapper>
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/mapper/CommunityDAO.xml">CommunityDAO.xml</a>
</pre>
