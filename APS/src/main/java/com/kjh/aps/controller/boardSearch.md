## Demo
<img src="https://user-images.githubusercontent.com/47962660/64928394-b3fb0080-d852-11e9-8d29-b9bc678ac872.gif"/>

## CommunityController
<pre>
@Inject
private CommunityService communityService;
private final int BOARD_PAGEBLOCK = 5;
private final int BOARD_POPULAR_ORDER = 20;
 
// 방송인 커뮤니티 게시판 글 검색
@GetMapping(value = "/board", params = {"searchValue", "searchType"})
public String board(String id, String searchValue,
  @RequestParam(value = "searchType", defaultValue = "1") int searchType,
  @RequestParam(value = "listType", defaultValue = "new") String listType,
  @RequestParam(value = "page", defaultValue = "1") int page,
  @RequestParam(value = "row", defaultValue = "20") int row, Model model) {
		
  // 파라미터 유효성 검사
  if(id == null || id.length() == 0 || searchValue == null || searchValue.length() == 0) {
    return "confirm/not_exist";
  } else {
    try {
      Map<String, String> map = new HashMap<>();
      map.put("id", id);
      map.put("searchValue", searchValue);
      map.put("searchType", String.valueOf(searchType));
      map.put("currPage", String.valueOf(page));
      map.put("page", String.valueOf((page-1)*row));
      map.put("row", String.valueOf(row));
      map.put("listType", listType);
      map.put("order", String.valueOf(BOARD_POPULAR_ORDER));
      map.put("pageBlock", String.valueOf(BOARD_PAGEBLOCK));

      Map<String, Object> maps = communityService.selectSearchBoardListByMap(map);
				
      String resultMsg = (String)maps.get("result");
				
      if(resultMsg.equals("Success")) {
        BoardWritesDTO boards = (BoardWritesDTO)maps.get("boards");
					
        model.addAttribute("broadcaster", (BroadcasterDTO)maps.get("broadcaster"));
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
  }
		
  return "community/board/board_list";
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
@Transactional(readOnly = true)
  public Map<String, Object> selectSearchBoardListByMap(Map<String, String> map) throws Exception { // 방송인 커뮤니티 게시판 글 검색
		
  Map<String, Object> maps = new HashMap<>();
  String result = "Fail";
  String listType = map.get("listType");
		
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
    Calendar month = Calendar.getInstance(timezone);
    map.put("month", sdf.format(month.getTime()));
  }
		
  BroadcasterDTO broadcaster = dao.selectBroadcasterById(map.get("id"));
		
  if(broadcaster == null) {
    result = "not_exist";
  } else {
    BoardWritesDTO boards = new BoardWritesDTO();
    boards.setBoards(dao.selectSearchBoardListByMap(map));
 	
    if(boards.getBoards() != null && boards.getBoards().size() != 0) {
      boards.setCount(boards.getBoards().size());
      boards.setStatus("Success");
    }

    int listCount = dao.selectSearchBoardCountByMap(map);

    PaginationDTO pagination = new PaginationDTO(Integer.parseInt(map.get("pageBlock")), listCount, Integer.parseInt(map.get("currPage")), Integer.parseInt(map.get("row")));

    maps.put("broadcaster", broadcaster);
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
  &lt;select id="selectBroadcasterById" resultType="com.kjh.aps.domain.BroadcasterDTO"&gt;
		SELECT * FROM broadcaster WHERE id = #{param1}
  &lt;/select&gt;
  &lt;select id="selectSearchBoardListByMap" resultType="com.kjh.aps.domain.BoardDTO"&gt;
    &lt;choose&gt;
      &lt;when test="searchType == 1"&gt;
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
                  (b.broadcaster_id = #{id} AND b.status = 1) AND (b.subject like UPPER(CONCAT('%', #{searchValue}, '%')) OR b.subject like LOWER(CONCAT('%', #{searchValue}, '%')))
                  AND ((DATE_FORMAT(b.register_date, '%Y-%m-%d') = DATE_FORMAT(#{today}, '%Y-%m-%d')) AND ((b.up - b.down) >= #{order}))
                ORDER BY b.id DESC) brc_b, (SELECT @rownum:=0) rownum) brc_b_list
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
                  (b.broadcaster_id = #{id} AND b.status = 1) AND (b.subject like UPPER(CONCAT('%', #{searchValue}, '%')) OR b.subject like LOWER(CONCAT('%', #{searchValue}, '%')))
                  AND ((DATE_FORMAT(b.register_date, '%Y-%m-%d') BETWEEN DATE_FORMAT(#{startDay}, '%Y-%m-%d') AND DATE_FORMAT(#{endDay}, '%Y-%m-%d')) AND ((b.up - b.down) &lt;= #{order}))
                ORDER BY b.id DESC) brc_b, (SELECT @rownum:=0) rownum) brc_b_list
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
                  (b.broadcaster_id = #{id} AND b.status = 1) AND (b.subject like UPPER(CONCAT('%', #{searchValue}, '%')) OR b.subject like LOWER(CONCAT('%', #{searchValue}, '%')))
                  AND ((DATE_FORMAT(b.register_date, '%Y-%m') = DATE_FORMAT(#{month}, '%Y-%m')) AND ((b.up - b.down) &lt;= #{order}))
                ORDER BY b.id DESC) brc_b, (SELECT @rownum:=0) rownum) brc_b_list
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
                  (b.broadcaster_id = #{id} AND b.status = 1) AND (b.subject like UPPER(CONCAT('%', #{searchValue}, '%')) OR b.subject like LOWER(CONCAT('%', #{searchValue}, '%')))
                ORDER BY b.id DESC) brc_b, (SELECT @rownum:=0) rownum) brc_b_list
          	WHERE brc_b_list.no BETWEEN #{page} + 1 AND #{page} + #{row}
          &lt;/otherwise&gt;
        &lt;/choose&gt;
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
              (b.broadcaster_id = #{id} AND b.status = 1) AND (b.subject like UPPER(CONCAT('%', #{searchValue}, '%')) OR b.subject like LOWER(CONCAT('%', #{searchValue}, '%')))
            ORDER BY b.id DESC) brc_b, (SELECT @rownum:=0) rownum) brc_b_list
        WHERE brc_b_list.no BETWEEN #{page} + 1 AND #{page} + #{row}
      &lt;/otherwise&gt;
    &lt;/choose&gt;
  &lt;/select&gt;
  &lt;select id="selectSearchBoardCountByMap" resultType="Integer"&gt;
    &lt;choose&gt;
      &lt;when test="searchType == 1"&gt;
        &lt;choose&gt;
          &lt;when test='listType != null and listType.equals("today")'&gt;
            SELECT count(id) FROM broadcaster_board WHERE (broadcaster_id = #{id}) AND (subject like UPPER(CONCAT('%', #{searchValue}, '%')) OR subject like LOWER(CONCAT('%', #{searchValue}, '%'))) AND status = 1
            AND ((DATE_FORMAT(register_date, '%Y-%m-%d') = DATE_FORMAT(#{today}, '%Y-%m-%d')) AND ((up - down) &lt;= #{order}))
          &lt;/when&gt;
          &lt;when test='listType != null and listType.equals("week")'&gt;
            SELECT count(id) FROM broadcaster_board WHERE (broadcaster_id = #{id}) AND (subject like UPPER(CONCAT('%', #{searchValue}, '%')) OR subject like LOWER(CONCAT('%', #{searchValue}, '%'))) AND status = 1
            AND ((DATE_FORMAT(register_date, '%Y-%m-%d') BETWEEN DATE_FORMAT(#{startDay}, '%Y-%m-%d') AND DATE_FORMAT(#{endDay}, '%Y-%m-%d')) AND ((up - down) &lt;= #{order}))
          &lt;/when&gt;
          &lt;when test='listType != null and listType.equals("month")'&gt;
            SELECT count(id) FROM broadcaster_board WHERE (broadcaster_id = #{id}) AND (subject like UPPER(CONCAT('%', #{searchValue}, '%')) OR subject like LOWER(CONCAT('%', #{searchValue}, '%'))) AND status = 1
            AND ((DATE_FORMAT(register_date, '%Y-%m') = DATE_FORMAT(#{month}, '%Y-%m')) AND ((up - down) &lt;= #{order}))
          &lt;/when&gt;
          &lt;otherwise&gt;
            SELECT count(id) FROM broadcaster_board WHERE (broadcaster_id = #{id}) AND (subject like UPPER(CONCAT('%', #{searchValue}, '%')) OR subject like LOWER(CONCAT('%', #{searchValue}, '%'))) AND status = 1
          &lt;/otherwise&gt;
        &lt;/choose&gt;
      &lt;/when&gt;
      &lt;otherwise&gt;
        SELECT count(id) FROM broadcaster_board WHERE (broadcaster_id = #{id}) AND (subject like UPPER(CONCAT('%', #{searchValue}, '%')) OR subject like LOWER(CONCAT('%', #{searchValue}, '%'))) AND status = 1
      &lt;/otherwise&gt;
    &lt;/choose&gt;
  &lt;/select&gt;
&lt;/mapper&gt;
</pre>
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/mapper/CommunityDAO.xml">CommunityDAO.xml</a>
</pre>
