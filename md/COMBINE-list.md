## Demo
<h5>최신 또는 일일/주간/월간 인기순으로 게시글 정렬이 가능합니다.</h5>
<img src="https://user-images.githubusercontent.com/47962660/65027692-c457cc00-d975-11e9-816e-94407c9a7be1.gif"/>

## CommunityController
```java
@Inject
private CommunityService communityService;
  
private final int BOARD_PAGEBLOCK = 5;
private final int BOARD_POPULAR_ORDER = 20;

// 통합 게시판 페이지
@GetMapping("/combine")
public String combine(@RequestParam(value = "listType", defaultValue = "new") String listType,
  @RequestParam(value = "page", defaultValue = "1") int page,
  @RequestParam(value = "row", defaultValue = "20") int row, Model model) {

  try {
    Map<String, String> map = new HashMap<>();
    map.put("currPage", String.valueOf(page));
    map.put("page", String.valueOf((page-1)*row));
    map.put("row", String.valueOf(row));
    map.put("listType", listType);
    map.put("order", String.valueOf(BOARD_POPULAR_ORDER));
    map.put("pageBlock", String.valueOf(BOARD_PAGEBLOCK));

    Map<String, Object> maps = communityService.selectCombineBoardWriteListByMap(map);

    String resultMsg = (String)maps.get("result");
				
    if(resultMsg.equals("Success")) {
      BoardWritesDTO boards = (BoardWritesDTO)maps.get("boards");
					
      model.addAttribute("boardList", boards.getBoards()); // 해당 방송인 커뮤니티 글 목록
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
		
  return "community/combine/combine_list";
}
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/controller/CommunityController.java">CommunityController.java</a>
</pre>
## CommunityServiceImpl
```java
@Inject
private CommunityDAO dao;

private TimeZone timezone = TimeZone.getTimeZone("Asia/Seoul");
private SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");

@Override
@Transactional(readOnly = true)
public Map<String, Object> selectCombineBoardWriteListByMap(Map<String, String> map) throws Exception { // 통합 게시판 게시글 목록
		
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

  BoardWritesDTO boards = new BoardWritesDTO();
  boards.setBoards(dao.selectCombineBoardWriteListByMap(map));
			
  if(boards.getBoards() != null && boards.getBoards().size() != 0) {
    boards.setCount(boards.getBoards().size());
    boards.setStatus("Success");
  }

  int listCount = dao.selectCombineBoardWriteCountByMap(map);
			
  PaginationDTO pagination = new PaginationDTO(Integer.parseInt(map.get("pageBlock")), listCount, Integer.parseInt(map.get("currPage")), Integer.parseInt(map.get("row")));
			
  maps.put("boards", boards);
  maps.put("pagination", pagination);
  result = "Success";
		
  maps.put("result", result);
		
  return maps;
}
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/service/CommunityServiceImpl.java">CommunityServiceImpl.java</a>
</pre>
## CommunityMapper
```xml
<mapper namespace="community">
  <select id="selectCombineBoardWriteListByMap" resultType="com.kjh.aps.domain.BoardDTO">
    <choose>
      <when test='listType != null and listType.equals("today")'>
        SELECT brc_b_list.* FROM
          (SELECT
            @rownum:=@rownum+1 as no, brc_b.*
          FROM
            (SELECT
              b.id, b.user_id, b.ip, b.nickname, b.profile, b.level, b.user_type userType, b.type board_type, b.subject, b.content, b.image_flag, b.media_flag, b.up, b.down, b.view, b.status, b.register_date,
              ((SELECT count(id) FROM combine_board_comment WHERE combine_board_id = b.id AND status = 1) + (SELECT count(id) FROM combine_board_comment_reply WHERE combine_board_comment_id IN (SELECT id FROM combine_board_comment WHERE combine_board_id = b.id) AND status = 1)) commentCount
            FROM
              combine_board b
            WHERE
              (b.status = 1) AND (DATE_FORMAT(b.register_date, '%Y-%m-%d') = DATE_FORMAT(#{today}, '%Y-%m-%d')) AND ((b.up - b.down) >= #{order}) ORDER BY (b.up - b.down) DESC) brc_b, (SELECT @rownum:=0) rownum) brc_b_list
        WHERE brc_b_list.no BETWEEN #{page} + 1 AND #{page} + #{row}
      </when>
      <when test='listType != null and listType.equals("week")'>
        SELECT brc_b_list.* FROM
          (SELECT
            @rownum:=@rownum+1 as no, brc_b.*
          FROM
            (SELECT
              b.id, b.user_id, b.ip, b.nickname, b.profile, b.level, b.user_type userType, b.type board_type, b.subject, b.content, b.image_flag, b.media_flag, b.up, b.down, b.view, b.status, b.register_date,
              ((SELECT count(id) FROM combine_board_comment WHERE combine_board_id = b.id AND status = 1) + (SELECT count(id) FROM combine_board_comment_reply WHERE combine_board_comment_id IN (SELECT id FROM combine_board_comment WHERE combine_board_id = b.id) AND status = 1)) commentCount
            FROM
              combine_board b
            WHERE
              b.status = 1 AND ((DATE_FORMAT(b.register_date, '%Y-%m-%d')) BETWEEN (DATE_FORMAT(#{startDay}, '%Y-%m-%d')) AND (DATE_FORMAT(#{endDay}, '%Y-%m-%d'))) AND ((b.up - b.down) >= #{order}) ORDER BY (b.up - b.down) DESC) brc_b, (SELECT @rownum:=0) rownum) brc_b_list
        WHERE brc_b_list.no BETWEEN #{page} + 1 AND #{page} + #{row}
      </when>
      <when test='listType != null and listType.equals("month")'>				
        SELECT brc_b_list.* FROM
          (SELECT
            @rownum:=@rownum+1 as no, brc_b.*
          FROM
            (SELECT
              b.id, b.user_id, b.ip, b.nickname, b.profile, b.level, b.user_type userType, b.type board_type, b.subject, b.content, b.image_flag, b.media_flag, b.up, b.down, b.view, b.status, b.register_date,
              ((SELECT count(id) FROM combine_board_comment WHERE combine_board_id = b.id AND status = 1) + (SELECT count(id) FROM combine_board_comment_reply WHERE combine_board_comment_id IN (SELECT id FROM combine_board_comment WHERE combine_board_id = b.id) AND status = 1)) commentCount
            FROM
              combine_board b
            WHERE
              b.status = 1 AND (DATE_FORMAT(b.register_date, '%Y-%m') = DATE_FORMAT(#{month}, '%Y-%m')) AND ((b.up - b.down) >= #{order}) ORDER BY (b.up - b.down) DESC) brc_b, (SELECT @rownum:=0) rownum) brc_b_list
        WHERE brc_b_list.no BETWEEN #{page} + 1 AND #{page} + #{row}
      </when>
      <otherwise>
        SELECT brc_b_list.* FROM
          (SELECT
            @rownum:=@rownum+1 as no, brc_b.*
          FROM
            (SELECT
              b.id, b.user_id, b.ip, b.nickname, b.profile, b.level, b.user_type userType, b.type board_type, b.subject, b.content, b.image_flag, b.media_flag, b.up, b.down, b.view, b.status, b.register_date,
              ((SELECT count(id) FROM combine_board_comment WHERE combine_board_id = b.id AND status = 1) + (SELECT count(id) FROM combine_board_comment_reply WHERE combine_board_comment_id IN (SELECT id FROM combine_board_comment WHERE combine_board_id = b.id) AND status = 1)) commentCount
            FROM
              combine_board b
            WHERE
              b.status = 1 ORDER BY b.id DESC) brc_b, (SELECT @rownum:=0) rownum) brc_b_list
        WHERE brc_b_list.no BETWEEN #{page} + 1 AND #{page} + #{row}
      </otherwise>
    </choose>
  </select>
  <select id="selectCombineBoardWriteCountByMap" resultType="Integer">
    <choose>
      <when test='listType != null and listType.equals("today")'>
        SELECT count(b.id) FROM (SELECT * FROM combine_board WHERE status = 1) b WHERE (DATE_FORMAT(b.register_date, '%Y-%m-%d') = DATE_FORMAT(#{today}, '%Y-%m-%d')) AND ((b.up - b.down) >= #{order})
      </when>
      <when test='listType != null and listType.equals("week")'>
        SELECT count(b.id) FROM (SELECT * FROM combine_board WHERE status = 1) b WHERE ((DATE_FORMAT(b.register_date, '%Y-%m-%d')) BETWEEN (DATE_FORMAT(#{startDay}, '%Y-%m-%d')) AND (DATE_FORMAT(#{endDay}, '%Y-%m-%d'))) AND ((b.up - b.down) >= #{order})
      </when>
      <when test='listType != null and listType.equals("month")'>
        SELECT count(b.id) FROM (SELECT * FROM combine_board WHERE status = 1) b WHERE (DATE_FORMAT(b.register_date, '%Y-%m') = DATE_FORMAT(#{month}, '%Y-%m')) AND ((b.up - b.down) >= #{order})
      </when> 
      <otherwise>
        SELECT count(id) FROM combine_board WHERE status = 1
      </otherwise>
    </choose>
  </select>
</mapper>
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/mapper/CommunityDAO.xml">CommunityDAO.xml</a>
</pre>
