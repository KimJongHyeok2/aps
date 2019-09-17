## Demo
<img src="https://user-images.githubusercontent.com/47962660/65040710-faa24500-d98f-11e9-9a88-d191d38aa2f0.gif"/>

## CommunityController
```java
@Inject
private CommunityService communityService;

private final int BOARD_PAGEBLOCK = 5;
private final int BOARD_POPULAR_ORDER = 20;

// 통합 게시판 글 검색
@GetMapping(value = "/combine", params = {"searchValue", "searchType"})
public String combine(String searchValue,
  @RequestParam(value = "listType", defaultValue = "new") String listType,
  @RequestParam(value = "searchType", defaultValue = "1") int searchType,
  @RequestParam(value = "page", defaultValue = "1") int page,
  @RequestParam(value = "row", defaultValue = "10") int row, Model model) {
		
  String resultView = "confirm/error_500";
		
  // 파라미터 유효성 검사
  if(!(searchValue == null || searchValue.length() == 0)) {
    try {
      Map<String, String> map = new HashMap<>();
      map.put("searchValue", searchValue);
      map.put("searchType", String.valueOf(searchType));
      map.put("currPage", String.valueOf(page));
      map.put("page", String.valueOf((page-1)*row));
      map.put("row", String.valueOf(row));
      map.put("pageBlock", String.valueOf(BOARD_PAGEBLOCK));
      map.put("listType", listType);
      map.put("order", String.valueOf(BOARD_POPULAR_ORDER));

      Map<String, Object> maps = communityService.selectSearchCombineBoardWriteListByMap(map);

      BoardWritesDTO boards = (BoardWritesDTO)maps.get("boards");
      PaginationDTO pagination = (PaginationDTO)maps.get("pagination");
				
      model.addAttribute("boardList", boards.getBoards());
      model.addAttribute("pagination", pagination);
      model.addAttribute("listType", listType);
      resultView = "community/combine/combine_list";
    } catch (Exception e) {
      throw new RuntimeException(e);
    } 
  }
		
  return resultView;
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
public Map<String, Object> selectSearchCombineBoardWriteListByMap(Map<String, String> map) throws Exception { // 통합 게시판 게시글 검색
		
  Map<String, Object> maps = new HashMap<>();
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
  boards.setBoards(dao.selectSearchCombineBoardWriteListByMap(map));
			
  if(boards.getBoards() != null && boards.getBoards().size() != 0) {
    boards.setCount(boards.getBoards().size());
    boards.setStatus("Success");
  }
			
  int listCount = dao.selectSearchCombineBoardWriteCountByMap(map);

  PaginationDTO pagination = new PaginationDTO(Integer.parseInt(map.get("pageBlock")), listCount, Integer.parseInt(map.get("currPage")), Integer.parseInt(map.get("row")));
			
  maps.put("boards", boards);
  maps.put("pagination", pagination);	
  maps.put("result", "Success");
		
  return maps;
}
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/service/CommunityServiceImpl.java">CommunityServiceImpl.java</a>
</pre>
## CommunityMapper
```xml
<mapper namespace="community">
  <select id="selectSearchCombineBoardWriteListByMap" resultType="com.kjh.aps.domain.BoardDTO">
    <choose>
      <when test="searchType == 1">
        <choose>
          <when test='listType != null and listType.equals("today")'>
            SELECT brc_b_list.* FROM
              (SELECT
                @rownum:=@rownum+1 as no, brc_b.*
              FROM
                  (SELECT
                    b.id, b.ip, b.user_id, b.nickname, b.profile, b.level, b.user_type userType, b.type board_type, b.subject, b.content, b.image_flag, b.media_flag, b.up, b.down, b.view, b.status, b.register_date,
                    ((SELECT count(id) FROM combine_board_comment WHERE combine_board_id = b.id AND status = 1) + (SELECT count(id) FROM combine_board_comment_reply WHERE combine_board_comment_id IN (SELECT id FROM combine_board_comment WHERE combine_board_id = b.id) AND status = 1)) commentCount
                  FROM
                    combine_board b
                  WHERE
                    (b.status = 1) AND (b.subject like UPPER(CONCAT('%', #{searchValue}, '%')) OR b.subject like LOWER(CONCAT('%', #{searchValue}, '%')))
                    AND ((DATE_FORMAT(b.register_date, '%Y-%m-%d') = DATE_FORMAT(#{today}, '%Y-%m-%d')) AND ((b.up - b.down) >= #{order}))
                  ORDER BY b.id DESC) brc_b, (SELECT @rownum:=0) rownum) brc_b_list
            WHERE brc_b_list.no BETWEEN #{page} + 1 AND #{page} + #{row}
          </when>
          <when test='listType != null and listType.equals("week")'>
            SELECT brc_b_list.* FROM
              (SELECT
                @rownum:=@rownum+1 as no, brc_b.*
              FROM
                (SELECT
                  b.id, b.ip, b.user_id, b.nickname, b.profile, b.level, b.user_type userType, b.type board_type, b.subject, b.content, b.image_flag, b.media_flag, b.up, b.down, b.view, b.status, b.register_date,
                  ((SELECT count(id) FROM combine_board_comment WHERE combine_board_id = b.id AND status = 1) + (SELECT count(id) FROM combine_board_comment_reply WHERE combine_board_comment_id IN (SELECT id FROM combine_board_comment WHERE combine_board_id = b.id) AND status = 1)) commentCount
                FROM
                  combine_board b
                WHERE
                  (b.status = 1) AND (b.subject like UPPER(CONCAT('%', #{searchValue}, '%')) OR b.subject like LOWER(CONCAT('%', #{searchValue}, '%')))
                  AND ((DATE_FORMAT(b.register_date, '%Y-%m-%d') BETWEEN DATE_FORMAT(#{startDay}, '%Y-%m-%d') AND DATE_FORMAT(#{endDay}, '%Y-%m-%d')) AND ((b.up - b.down) >= #{order}))
                ORDER BY b.id DESC) brc_b, (SELECT @rownum:=0) rownum) brc_b_list
            WHERE brc_b_list.no BETWEEN #{page} + 1 AND #{page} + #{row}
          </when>
          <when test='listType != null and listType.equals("month")'>
            SELECT brc_b_list.* FROM
              (SELECT
                @rownum:=@rownum+1 as no, brc_b.*
              FROM
                (SELECT
                  b.id, b.ip, b.user_id, b.nickname, b.profile, b.level, b.user_type userType, b.type board_type, b.subject, b.content, b.image_flag, b.media_flag, b.up, b.down, b.view, b.status, b.register_date,
                  ((SELECT count(id) FROM combine_board_comment WHERE combine_board_id = b.id AND status = 1) + (SELECT count(id) FROM combine_board_comment_reply WHERE combine_board_comment_id IN (SELECT id FROM combine_board_comment WHERE combine_board_id = b.id) AND status = 1)) commentCount
                FROM
                  combine_board b
                WHERE
                  (b.status = 1) AND (b.subject like UPPER(CONCAT('%', #{searchValue}, '%')) OR b.subject like LOWER(CONCAT('%', #{searchValue}, '%')))
                  AND ((DATE_FORMAT(b.register_date, '%Y-%m') = DATE_FORMAT(#{month}, '%Y-%m')) AND ((b.up - b.down) >= #{order}))
                ORDER BY b.id DESC) brc_b, (SELECT @rownum:=0) rownum) brc_b_list
            WHERE brc_b_list.no BETWEEN #{page} + 1 AND #{page} + #{row}
          </when>
          <otherwise>
            SELECT brc_b_list.* FROM
              (SELECT
                @rownum:=@rownum+1 as no, brc_b.*
              FROM
                (SELECT
                  b.id, b.ip, b.user_id, b.nickname, b.profile, b.level, b.user_type userType, b.type board_type, b.subject, b.content, b.image_flag, b.media_flag, b.up, b.down, b.view, b.status, b.register_date,
                  ((SELECT count(id) FROM combine_board_comment WHERE combine_board_id = b.id AND status = 1) + (SELECT count(id) FROM combine_board_comment_reply WHERE combine_board_comment_id IN (SELECT id FROM combine_board_comment WHERE combine_board_id = b.id) AND status = 1)) commentCount
                FROM
                  combine_board b
                WHERE
                  (b.status = 1) AND (b.subject like UPPER(CONCAT('%', #{searchValue}, '%')) OR b.subject like LOWER(CONCAT('%', #{searchValue}, '%')))
                ORDER BY b.id DESC) brc_b, (SELECT @rownum:=0) rownum) brc_b_list
            WHERE brc_b_list.no BETWEEN #{page} + 1 AND #{page} + #{row}
          </otherwise>
        </choose>
      </when>
      <otherwise>
        SELECT brc_b_list.* FROM
          (SELECT
            @rownum:=@rownum+1 as no, brc_b.*
          FROM
            (SELECT
              b.id, b.ip, b.user_id, b.nickname, b.profile, b.level, b.user_type userType, b.type board_type, b.subject, b.content, b.image_flag, b.media_flag, b.up, b.down, b.view, b.status, b.register_date,
              ((SELECT count(id) FROM combine_board_comment WHERE combine_board_id = b.id AND status = 1) + (SELECT count(id) FROM combine_board_comment_reply WHERE combine_board_comment_id IN (SELECT id FROM combine_board_comment WHERE combine_board_id = b.id) AND status = 1)) commentCount
            FROM
              combine_board b
            WHERE
              (b.status = 1) AND (b.subject like UPPER(CONCAT('%', #{searchValue}, '%')) OR b.subject like LOWER(CONCAT('%', #{searchValue}, '%')))
            ORDER BY b.id DESC) brc_b, (SELECT @rownum:=0) rownum) brc_b_list
        WHERE brc_b_list.no BETWEEN #{page} + 1 AND #{page} + #{row}
      </otherwise>
    </choose>
  </select>
  <select id="selectSearchCombineBoardWriteCountByMap" resultType="Integer">
    <choose>
      <when test="searchType == 1">
        <choose>
          <when test='listType != null and listType.equals("today")'>
            SELECT count(id) FROM combine_board WHERE (subject like UPPER(CONCAT('%', #{searchValue}, '%')) OR subject like LOWER(CONCAT('%', #{searchValue}, '%'))) AND status = 1
            AND ((DATE_FORMAT(register_date, '%Y-%m-%d') = DATE_FORMAT(#{today}, '%Y-%m-%d')) AND ((up - down) >= #{order}))
          </when>
          <when test='listType != null and listType.equals("week")'>
            SELECT count(id) FROM combine_board WHERE (subject like UPPER(CONCAT('%', #{searchValue}, '%')) OR subject like LOWER(CONCAT('%', #{searchValue}, '%'))) AND status = 1
            AND ((DATE_FORMAT(register_date, '%Y-%m-%d') BETWEEN DATE_FORMAT(#{startDay}, '%Y-%m-%d') AND DATE_FORMAT(#{endDay}, '%Y-%m-%d')) AND ((up - down) >= #{order}))
          </when>
          <when test='listType != null and listType.equals("month")'>
            SELECT count(id) FROM combine_board WHERE (subject like UPPER(CONCAT('%', #{searchValue}, '%')) OR subject like LOWER(CONCAT('%', #{searchValue}, '%'))) AND status = 1
            AND ((DATE_FORMAT(register_date, '%Y-%m') = DATE_FORMAT(#{month}, '%Y-%m')) AND ((up - down) >= #{order}))
          </when>
          <otherwise>
            SELECT count(id) FROM combine_board WHERE (subject like UPPER(CONCAT('%', #{searchValue}, '%')) OR subject like LOWER(CONCAT('%', #{searchValue}, '%'))) AND status = 1
          </otherwise>
        </choose>
      </when>
      <otherwise>
        SELECT count(id) FROM combine_board WHERE (subject like UPPER(CONCAT('%', #{searchValue}, '%')) OR subject like LOWER(CONCAT('%', #{searchValue}, '%'))) AND status = 1
      </otherwise>
    </choose>
  </select>
</mapper>
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/mapper/CommunityDAO.xml">CommunityDAO.xml</a>
</pre>
