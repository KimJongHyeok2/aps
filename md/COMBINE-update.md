## Demo
<img src="https://user-images.githubusercontent.com/47962660/65028978-ee11f280-d977-11e9-8798-0eaa749c319b.gif"/>

## CommunityController
```java
@Inject
private CommunityService communityService;

// 통합 게시판 글 수정 또는 삭제 전 Confirm 페이지
@GetMapping("/combine/confirm")
public String combineConfirm(@RequestParam(value = "id", defaultValue = "0") int id, String type,
  @RequestParam(value = "page", defaultValue = "1") int page, Model model) {
  String resultView = "confirm/not_exist";
  if(id != 0 && type != null && (type.equals("modify") || type.equals("delete"))) {
    try {
      String boardType = communityService.selectCombineBoardWriteTypeById(id);
				
      if(boardType.equals("non")) {
        resultView = "community/combine/combine_confirm";
        model.addAttribute("type", type);
      }
				
      model.addAttribute("page", page);
      model.addAttribute("id", id);
    } catch (Exception e) {
      throw new RuntimeException(e);
    }
  }
		
  return resultView;
}
	
// 통합 게시판 글 수정 페이지
@PostMapping("/combine/modify/{id}")
public String combineBoardWriteModify(@PathVariable int id, String password,
  HttpServletRequest request, Model model) {
  String resultView = "confirm/not_exist";
		
  if(id != 0 || (password != null && password.length() > 3 && password.length() < 21)) {
    try {
      Map<String, String> map = new HashMap<>();
      map.put("id", String.valueOf(id));
      map.put("user_id", String.valueOf(request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id")));
      map.put("password", password);
				
      Map<String, Object> maps = communityService.selectCombineBoardWriteByMap(map);
      String result = (String)maps.get("result");
				
      if(result.equals("Success")) {
        resultView = "community/combine/combine_modify";
        model.addAttribute("board", (BoardDTO)maps.get("board"));
      } else if(result.equals("Password Wrong")) {
        resultView = "community/combine/combine_confirm";
        model.addAttribute("error", result);
        model.addAttribute("type", "modify");
      }
    } catch (Exception e) {
      throw new RuntimeException(e);
    }
  }
		
  model.addAttribute("id", id);
		
  return resultView;
}
	
// 통합 게시판 글 수정
@PostMapping("/combine/modifyOk")
public String combineBoardWriteModifyOk(BoardDTO dto, BindingResult result,
  @RequestParam(value = "page", defaultValue = "1") int page,
  HttpServletRequest request, Model model) {

  CombineBoardValidator validation = new CombineBoardValidator();
  String resultMsg = "Fail";
		
  // 파라미터 유효성 검사
  if(validation.supports(dto.getClass())) {
    dto.setIp(request.getRemoteAddr());
    Integer userId = request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id");
    dto.setUser_id(userId);
			
    if(dto.getBoard_type().equals("user") && userId != 0) { // 회원이 작성한 글이라면
      dto.setUser_id(userId);
      dto.setNickname((String)request.getSession().getAttribute("nickname"));
      dto.setProfile((String)request.getSession().getAttribute("profile"));
      dto.setLevel((Integer)request.getSession().getAttribute("level"));
      dto.setUserType((Integer)request.getSession().getAttribute("userType"));
    }
    validation.validate(dto, result);
			
    // 오류가 존재하지 않다면
    if(!result.hasErrors()) {
      try {
        resultMsg = communityService.updateCombineBoardWrite(dto); // 글 수정
					
        if(resultMsg.equals("Success")) { // 정상적으로 수정되었다면
          return "redirect:/community/combine/view/" + dto.getId() + "?&page=" + page + "";
        }
      } catch (Exception e) {
        throw new RuntimeException(e);
      }
    }
  }

  if(!resultMsg.equals("Success")) {
    model.addAttribute("board", dto);
    model.addAttribute("error", "updateFail");
  }
		
  return "community/combine/combine_modify";
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
public String selectCombineBoardWriteTypeById(int id) throws Exception { // 통합 게시판 글 타입
  return dao.selectCombineBoardWriteTypeById(id);
}
  
@Override
@Transactional(readOnly = true)
public Map<String, Object> selectCombineBoardWriteByMap(Map<String, String> map) throws Exception { // 통합 게시판 수정할 글 불러오기
		
  Map<String, Object> maps = new HashMap<>();
  String result = "Fail";
		
  String boardType = dao.selectCombineBoardWriteTypeById(Integer.parseInt(map.get("id")));
		
  if(boardType != null) {
    map.put("type", boardType);
    BoardDTO board = dao.selectModifyCombineBoardWriteByMap(map);
			
    if(board == null) {
      if(boardType.equals("non")) {
        result = "Password Wrong";
      }
    } else {
      result = "Success";
      maps.put("board", board);
    }
  }
		
  maps.put("result", result);
		
  return maps;
}
  
@Override
public String updateCombineBoardWrite(BoardDTO dto) throws Exception { // 통합 게시판 글 수정
		
  String result = "Fail";
		
  int successCount = dao.updateCombineBoardWrite(dto);
		
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
  <select id="selectCombineBoardWriteTypeById" resultType="String">
    SELECT type FROM combine_board WHERE id = #{param1} AND status = 1
  </select>
  <select id="selectModifyCombineBoardWriteByMap" resultType="com.kjh.aps.domain.BoardDTO">
    <choose>
      <when test='type != null and type.equals("non")'>
        <![CDATA[
          SELECT id, nickname, password, subject, content, type board_type FROM combine_board WHERE id = #{id} AND password = #{password} AND user_type < 1 AND type = #{type} AND status = 1
        ]]>
      </when>
      <when test='type != null and type.equals("user")'>
        SELECT id, subject, content, type board_type FROM combine_board WHERE id = #{id} AND user_id = #{user_id} AND user_type > 0 AND type = #{type} AND status = 1
      </when>
    </choose>
  </select>
  <update id="updateCombineBoardWrite">
    <choose>
      <when test='board_type.equals("non")'>
        UPDATE combine_board SET ip = #{ip}, subject = #{subject}, content = #{content}, image_flag = #{image_flag}, media_flag = #{media_flag} WHERE id = #{id} AND nickname = #{nickname} AND password = #{password} AND type = #{board_type} AND status = 1
      </when>
      <when test='board_type.equals("user")'>
        UPDATE combine_board SET ip = #{ip}, subject = #{subject}, content = #{content}, image_flag = #{image_flag}, media_flag = #{media_flag} WHERE id = #{id} AND user_id = #{user_id} AND type = #{board_type} AND status = 1
      </when>
    </choose>
  </update>
</mapper>
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/mapper/CommunityDAO.xml">CommunityDAO.xml</a>
</pre>
