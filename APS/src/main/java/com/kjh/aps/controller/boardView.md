## Demo
<img src="https://user-images.githubusercontent.com/47962660/64928044-95463b00-d84d-11e9-9e6f-4cfecb3d6986.gif"/>

## CommunityController
<pre>
@Inject
private CommunityService communityService;
private final int BOARD_PAGEBLOCK = 5;
private final int BOARD_POPULAR_ORDER = 20;
private final int COMMENT_PAGEBLOCK = 5;
private final int COMMENT_POPULAR_ORDER = 20;
  
// 방송인 커뮤니티 게시판 글 상세보기
@GetMapping("/board/view/{id}")
public String boardView(@PathVariable int id, String broadcasterId,
  @RequestParam(value = "listType", defaultValue = "new") String listType,
  @RequestParam(value = "page", defaultValue = "1") int page,
  @RequestParam(value = "row", defaultValue = "20") int row,
  HttpServletRequest request, Model model) {

  try {
    Map<String, String> map = new HashMap<>();
    map.put("id", String.valueOf(id));
    map.put("broadcaster_id", broadcasterId);
    map.put("currPage", String.valueOf(page));
    map.put("page", String.valueOf((page-1)*row));
    map.put("row", String.valueOf(row));
    Integer userId = request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id");
    String ip =  request.getSession().getAttribute("id")==null? "0":request.getRemoteAddr();
    map.put("user_id", String.valueOf(userId));
    map.put("ip", ip);
    map.put("listType", listType);
    map.put("order", String.valueOf(BOARD_POPULAR_ORDER));
    map.put("view", "false");
    map.put("pageBlock", String.valueOf(COMMENT_PAGEBLOCK));
			
    Map<String, Object> maps = communityService.selectBoardWriteViewByMap(map);
			
    String resultMsg = (String)maps.get("result");
			
    if(resultMsg.equals("Success")) { // 정상적으로 불러왔다면
      BoardWritesDTO boards = (BoardWritesDTO) maps.get("boards");

      model.addAttribute("broadcaster", (BroadcasterDTO)maps.get("broadcaster"));
      model.addAttribute("board", (BoardDTO)maps.get("board"));
      model.addAttribute("boardList", boards.getBoards());
      model.addAttribute("pagination", (PaginationDTO)maps.get("pagination"));
      model.addAttribute("listType", listType);
    } else if(resultMsg.equals("not_exist")) {
      return "confirm/" + resultMsg;
    } else {
      return "confirm/error_404";
    }
  } catch (Exception e) {
    throw new RuntimeException(e);
  }
		
  return "community/board/board_view";
}
</pre>
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/controller/CommunityController.java">CommunityController.java</a>
</pre>
## CommunityServiceImpl
<pre>
@Inject
private CommunityDAO dao;
	
private TimeZone timezone = TimeZone.getTimeZone("Asia/Seoul");
private SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
  
@Override
public Map<String, Object> selectBoardWriteViewByMap(Map<String, String> map) throws Exception { // 방송인 커뮤니티 게시판 글 상세보기
		
  Map<String, Object> maps = new HashMap<>();
  String result = "Fail";
  String listType = map.get("listType");
  String view = map.get("view");
		
  if(listType.equals("today")) { // 게시글 정렬 타입
    Calendar today = Calendar.getInstance(timezone);
    map.put("today", sdf.format(today.getTime()));
  } else if(listType.equals("week")) {
    Calendar startDay = Calendar.getInstance(timezone); // 이번 주의 시작
    Calendar endDay = Calendar.getInstance(timezone); // 이번 주의 끝
			
    startDay.add(Calendar.DATE, -startDay.get(Calendar.DAY_OF_WEEK) + 1);
    endDay.set(Calendar.DAY_OF_WEEK, Calendar.SUNDAY);
    endDay.add(Calendar.DATE, 7);
	
    map.put("startDay", sdf.format(startDay.getTime()));
    map.put("endDay", sdf.format(endDay.getTime()));
  } else if(listType.equals("month")) {
    Calendar today = Calendar.getInstance(timezone);
    map.put("month", sdf.format(today.getTime()));
  }
		
  if(view.equals("true")) {
    dao.updateBoardWriteView(map);
  }
		
  BoardDTO board = dao.selectBoardWriteByMap(map);
  BroadcasterDTO broadcaster = dao.selectBroadcasterById(map.get("broadcaster_id"));
		
  int charCount = 0;
  for(int i=0; i&lt;board.getIp().length(); i++) {
    if(board.getIp().charAt(i) == '.') {
      charCount += 1;
    }
			
    if(charCount == 2) {
      board.setIp(board.getIp().substring(0, i));
    }
  }
		
	if(board == null || broadcaster == null) {
    result = "not_exist";
  } else {
    map.put("id", board.getBroadcaster_id());
			
    BoardWritesDTO boards = new BoardWritesDTO();
    boards.setBoards(dao.selectBoardWriteListByMap(map));
			
    if(boards.getBoards() != null && boards.getBoards().size() != 0) {
      boards.setCount(boards.getBoards().size());
      boards.setStatus("Success");
    }
			
    int listCount = dao.selectBoardWriteCountByMap(map);
			
    PaginationDTO pagination = new PaginationDTO(Integer.parseInt(map.get("pageBlock")), listCount, Integer.parseInt(map.get("currPage")), Integer.parseInt(map.get("row")));
    maps.put("broadcaster", broadcaster); 
    maps.put("board", board);
    maps.put("boards", boards);
    maps.put("pagination", pagination);
    result = "Success";
  }
		
  maps.put("result", result);
		
  return maps;
}
</pre>
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/service/CommunityServiceImpl.java">CommunityServiceImpl.java</a>
</pre>
## CommunityMapper
<pre>
&lt;mapper namespace="community"&gt;
  &lt;select id="selectBoardWriteByMap" resultType="com.kjh.aps.domain.BoardDTO"&gt;
    &lt;![CDATA[
      SELECT
        brc_b.*, u.nickname as nickname, u.level as level, u.profile as profile, u.type as userType,
        (SELECT min(n.id) FROM (SELECT * FROM broadcaster_board WHERE broadcaster_id = #{broadcaster_id} AND status = 1) n WHERE n.id &gt; #{id}) as next_id,
        (SELECT max(p.id) FROM (SELECT * FROM broadcaster_board WHERE broadcaster_id = #{broadcaster_id} AND status = 1) p WHERE p.id &lt; #{id}) as prev_id,
				(SELECT ns.subject FROM (SELECT * FROM broadcaster_board WHERE broadcaster_id = #{broadcaster_id} AND status = 1) ns WHERE ns.id = (SELECT min(n.id) FROM (SELECT * FROM broadcaster_board WHERE broadcaster_id = #{broadcaster_id} AND status = 1) n WHERE n.id &gt; #{id})) as next_subject,
        (SELECT ps.subject FROM (SELECT * FROM broadcaster_board WHERE broadcaster_id = #{broadcaster_id} AND status = 1) ps WHERE ps.id = (SELECT max(p.id) FROM (SELECT * FROM broadcaster_board WHERE broadcaster_id = #{broadcaster_id} AND status = 1) p WHERE p.id &lt; #{id})) as prev_subject,
        (SELECT b.type FROM (SELECT * FROM broadcaster_board_recommend_history WHERE broadcaster_id = #{broadcaster_id}) b WHERE b.broadcaster_board_id = #{id} AND (b.user_id = #{user_id} OR b.ip = #{ip})) type,
        ((SELECT count(id) FROM broadcaster_board_comment WHERE broadcaster_board_id = #{id} AND status = 1) + (SELECT count(id) FROM broadcaster_board_comment_reply WHERE broadcaster_board_comment_id IN (SELECT id FROM broadcaster_board_comment WHERE broadcaster_board_id = #{id}) AND status = 1)) commentCount
      FROM
        (SELECT * FROM broadcaster_board WHERE broadcaster_id = #{broadcaster_id} AND status = 1) brc_b INNER JOIN user u ON brc_b.user_id = u.id
      WHERE brc_b.id = #{id} AND brc_b.status = 1
    ]]&gt;
  &lt;/select&gt;
  &lt;select id="selectBoardWriteListByMap" resultType="com.kjh.aps.domain.BoardDTO"&gt;
    &lt;choose&gt;
      &lt;when test='listType != null and listType.equals("today")'&gt;
        SELECT brc_b_list.* FROM
          (SELECT
            @rownum:=@rownum+1 as no, brc_b.*
          FROM
            (SELECT
              b.*, u.nickname as nickname, u.level as level, u.profile as profile, u.type as userType,
              ((SELECT count(id) FROM broadcaster_board_comment WHERE broadcaster_board_id = b.id AND status = 1) + (SELECT count(id) FROM broadcaster_board_comment_reply WHERE broadcaster_board_comment_id IN (SELECT id FROM broadcaster_board_comment WHERE broadcaster_board_id = b.id) AND status = 1)) commentCount
            FROM
              broadcaster_board b INNER JOIN user u ON b.user_id = u.id
            WHERE
              (b.broadcaster_id = #{id} AND b.status = 1) AND (DATE_FORMAT(b.register_date, '%Y-%m-%d') = DATE_FORMAT(#{today}, '%Y-%m-%d')) AND ((b.up - b.down) &gt;= #{order}) ORDER BY (b.up - b.down) DESC) brc_b, (SELECT @rownum:=0) rownum) brc_b_list
        WHERE brc_b_list.no BETWEEN #{page} + 1 AND #{page} + #{row}
      &lt;/when&gt;
      &lt;when test='listType != null and listType.equals("week")'&gt;
        SELECT brc_b_list.* FROM
          (SELECT
            @rownum:=@rownum+1 as no, brc_b.*
          FROM
            (SELECT
              b.*, u.nickname as nickname, u.level as level, u.profile as profile, u.type as userType,
              ((SELECT count(id) FROM broadcaster_board_comment WHERE broadcaster_board_id = b.id AND status = 1) + (SELECT count(id) FROM broadcaster_board_comment_reply WHERE broadcaster_board_comment_id IN (SELECT id FROM broadcaster_board_comment WHERE broadcaster_board_id = b.id) AND status = 1)) commentCount
            FROM
              broadcaster_board b INNER JOIN user u ON b.user_id = u.id
            WHERE
              (b.broadcaster_id = #{id} AND b.status = 1) AND ((DATE_FORMAT(b.register_date, '%Y-%m-%d')) BETWEEN (DATE_FORMAT(#{startDay}, '%Y-%m-%d')) AND (DATE_FORMAT(#{endDay}, '%Y-%m-%d'))) AND ((b.up - b.down) &gt;= #{order}) ORDER BY (b.up - b.down) DESC) brc_b, (SELECT @rownum:=0) rownum) brc_b_list
        WHERE brc_b_list.no BETWEEN #{page} + 1 AND #{page} + #{row}
      &lt;/when&gt;
      &lt;when test='listType != null and listType.equals("month")'&gt;
        SELECT brc_b_list.* FROM
          (SELECT
            @rownum:=@rownum+1 as no, brc_b.*
          FROM
          (SELECT
            b.*, u.nickname as nickname, u.level as level, u.profile as profile, u.type as userType,
            ((SELECT count(id) FROM broadcaster_board_comment WHERE broadcaster_board_id = b.id AND status = 1) + (SELECT count(id) FROM broadcaster_board_comment_reply WHERE broadcaster_board_comment_id IN (SELECT id FROM broadcaster_board_comment WHERE broadcaster_board_id = b.id) AND status = 1)) commentCount
          FROM
            broadcaster_board b INNER JOIN user u ON b.user_id = u.id
          WHERE
            (b.broadcaster_id = #{id} AND b.status = 1) AND (DATE_FORMAT(b.register_date, '%Y-%m') = DATE_FORMAT(#{month}, '%Y-%m')) AND ((b.up - b.down) &gt;= #{order}) ORDER BY (b.up - b.down) DESC) brc_b, (SELECT @rownum:=0) rownum) brc_b_list
        WHERE brc_b_list.no BETWEEN #{page} + 1 AND #{page} + #{row}
      &lt;/when&gt;
      &lt;otherwise&gt;
        SELECT brc_b_list.* FROM
          (SELECT
            @rownum:=@rownum+1 as no, brc_b.*
          FROM
            (SELECT
              b.*, u.nickname as nickname, u.level as level, u.profile as profile, u.type as userType,
              ((SELECT count(id) FROM broadcaster_board_comment WHERE broadcaster_board_id = b.id AND status = 1) + (SELECT count(id) FROM broadcaster_board_comment_reply WHERE broadcaster_board_comment_id IN (SELECT id FROM broadcaster_board_comment WHERE broadcaster_board_id = b.id) AND status = 1)) commentCount
            FROM
              broadcaster_board b INNER JOIN user u ON b.user_id = u.id
            WHERE
              b.broadcaster_id = #{id} AND b.status = 1 ORDER BY b.id DESC) brc_b, (SELECT @rownum:=0) rownum) brc_b_list
        WHERE brc_b_list.no BETWEEN #{page} + 1 AND #{page} + #{row}
      &lt;/otherwise&gt;
    &lt;/choose&gt;
  &lt;/select&gt;
  &lt;select id="selectBoardWriteCountByMap" resultType="Integer"&gt;
    &lt;choose&gt;
      &lt;when test='listType != null and listType.equals("today")'&gt;
        SELECT count(b.id) FROM (SELECT * FROM broadcaster_board WHERE broadcaster_id = #{id} AND status = 1) b WHERE (DATE_FORMAT(b.register_date, '%Y-%m-%d') = DATE_FORMAT(#{today}, '%Y-%m-%d')) AND ((b.up - b.down) &gt;= #{order})
      &lt;/when&gt;
      &lt;when test='listType != null and listType.equals("week")'&gt;
        SELECT count(b.id) FROM (SELECT * FROM broadcaster_board WHERE broadcaster_id = #{id} AND status = 1) b WHERE ((DATE_FORMAT(b.register_date, '%Y-%m-%d')) BETWEEN (DATE_FORMAT(#{startDay}, '%Y-%m-%d')) AND (DATE_FORMAT(#{endDay}, '%Y-%m-%d'))) AND ((b.up - b.down) &gt;= #{order})
      &lt;/when&gt;
      &lt;when test='listType != null and listType.equals("month")'&gt;
        SELECT count(b.id) FROM (SELECT * FROM broadcaster_board WHERE broadcaster_id = #{id} AND status = 1) b WHERE (DATE_FORMAT(b.register_date, '%Y-%m') = DATE_FORMAT(#{month}, '%Y-%m')) AND ((b.up - b.down) &gt;= #{order})
      &lt;/when&gt;
      &lt;otherwise&gt;
        SELECT count(id) FROM broadcaster_board WHERE (broadcaster_id = #{id} AND status = 1) 
      &lt;/otherwise&gt;
    &lt;/choose&gt;
  &lt;/select&gt;
&lt;/mapper&gt;
</pre>
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/mapper/CommunityDAO.xml">CommunityDAO.xml</a>
</pre>
