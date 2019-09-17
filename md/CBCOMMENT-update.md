## Demo
<img src="https://user-images.githubusercontent.com/47962660/65046785-35aa7580-d99c-11e9-84a5-ef1164a84c5b.gif"/>

## CombineView(Client)
```javascript
function modifyComment(id, type) {
  if(type == "non") {		
    var pop = window.open("${pageContext.request.contextPath}/community/combine/comment/confirm?id=" + id + "&type=modify", "pop", "width=500, height=712, scrollbars=yes, resizable=yes");
  } else {
    window.open("${pageContext.request.contextPath}/community/combine/comment/modify/id=" + id, "pop", "width=500, height=712, scrollbars=yes, resizable=yes");
    var form = $("<form></form>");
    form.attr("action", "${pageContext.request.contextPath}/community/combine/comment/modify/" + id);
    form.attr("method", "post");
    form.attr("target", "pop");
    form.append('<s:csrfInput/>');
    form.appendTo("body");
    form.submit();
  }
}
function modifyCommentOk(data) {
  if(data == "Success") {
    var commentPage = $("#comment-page").val();
    selectComment(commentPage);
  }
}
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/webapp/WEB-INF/views/community/combine/combine_view.jsp">combine_view.jsp</a>
</pre>
## CommunityController
```java
@Inject
private CommunityService communityService;

// 통합 게시판 글의 댓글 수정 또는 삭제 전 Confirm 페이지
@GetMapping("/combine/comment/confirm")
public String combineCommentConfirm(@RequestParam(value = "id", defaultValue = "0") int id,
  Integer combineCommentId, String type, Model model) {
  String resultView = "confirm/not_exist";
		
  if(id != 0 && type != null && (type.equals("modify") || type.equals("delete") || type.equals("deleteReply"))) {
    try {					
      String commentType = null;
				
      if(type.equals("modify") || type.equals("delete")) {					
        commentType = communityService.selectCombineBoardWriteCommentTypeById(id);
      } else if(type.equals("deleteReply")) {
        commentType = communityService.selectCombineBoardWriteCommentReplyTypeById(id);
        if(combineCommentId != null) { model.addAttribute("combineCommentId", combineCommentId); }
      }
				
      if(commentType.equals("non")) {
          resultView = "community/combine/comment_confirm";
          model.addAttribute("type", type);
      }
      model.addAttribute("id", id);
    } catch (Exception e) {
      throw new RuntimeException(e);
    }
  }
		
  return resultView;
}
  
// 통합 게시판 글의 댓글 수정 페이지
@PostMapping("/combine/comment/modify/{id}")
public String combineBoardWriteCommentModify(@PathVariable int id, String password,
  HttpServletRequest request, Model model) {
  String resultView = "confirm/not_exist";
		
  if(id != 0 || (password != null && password.length() > 3 && password.length() < 21)) {
    try {
      Map<String, String> map = new HashMap<>();
      map.put("id", String.valueOf(id));
      map.put("user_id", String.valueOf(request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id")));
      map.put("password", password);
				
      Map<String, Object> maps = communityService.selectCombineBoardWriteCommentByMap(map);
      String result = (String)maps.get("result");
				
      if(result.equals("Success")) {
        resultView = "community/combine/comment_modify";
        model.addAttribute("comment", (CommentDTO)maps.get("comment"));
      } else if(result.equals("Password Wrong")) {
        resultView = "community/combine/comment_confirm";
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
  
// 통합 게시판 글의 댓글 삭제
@PostMapping("/combine/comment/modifyOk")
public @ResponseBody String combineBoardWriteCommentModifyOk(CommentDTO dto, BindingResult result,
  @RequestParam(value = "page", defaultValue = "1") int page,
  HttpServletRequest request, Model model) {

  CombineCommentValidator validation = new CombineCommentValidator();
  validation.setRequest(request);
  String resultMsg = "Fail";
		
  // 파라미터 유효성 검사
  if(validation.supports(dto.getClass())) {
    dto.setIp(request.getRemoteAddr());
    Integer userId = request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id");
    dto.setUser_id(userId);
			
    if(dto.getComment_type().equals("user") && userId != 0) { // 회원이 작성한 글이라면
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
        resultMsg = communityService.updateCombineBoardWriteComment(dto); // 글 수정
      } catch (Exception e) {
        throw new RuntimeException(e);
      }
    }
  }
		
  return resultMsg;
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
public String selectCombineBoardWriteCommentTypeById(int id) throws Exception { // 통합 게시판 글의 댓글 타입
  return dao.selectCombineBoardWriteCommentTypeById(id);
}

@Override
public Map<String, Object> selectCombineBoardWriteCommentByMap(Map<String, String> map) throws Exception { // 통합 게시판 글의 댓글 조회

  Map<String, Object> maps = new HashMap<>();
  String result = "Fail";
		
  String commentType = dao.selectCombineBoardWriteCommentTypeById(Integer.parseInt(map.get("id")));
		
  if(commentType != null) {
    map.put("type", commentType);
    CommentDTO comment = dao.selectCombineBoardWriteCommentByMap(map);
			
    if(comment == null) {
      if(commentType.equals("non")) {
        result = "Password Wrong";
      }
    } else {
      result = "Success";
      maps.put("comment", comment);
    }
  }
		
  maps.put("result", result);
		
  return maps;
}
  
@Override
public String updateCombineBoardWriteComment(CommentDTO dto) throws Exception { // 통합 게시판 글의 댓글 수정
		
  String result = "Fail";
		
  int successCount = dao.updateCombineBoardWriteComment(dto);
		
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
  <select id="selectCombineBoardWriteCommentTypeById" resultType="String">
    SELECT type FROM combine_board_comment WHERE id = #{param1} AND status = 1
  </select>
  <select id="selectCombineBoardWriteCommentByMap" resultType="com.kjh.aps.domain.CommentDTO">
    <choose>
      <when test='type != null and type.equals("non")'>
        <![CDATA[
          SELECT id, nickname, password, content, type comment_type FROM combine_board_comment WHERE id = #{id} AND password = #{password} AND user_type < 1 AND type = #{type} AND status = 1
        ]]>
      </when>
      <when test='type != null and type.equals("user")'>
        SELECT id, content, type comment_type FROM combine_board_comment WHERE id = #{id} AND user_id = #{user_id} AND user_type > 0 AND type = #{type} AND status = 1
      </when>
    </choose>
  </select>
  <update id="updateCombineBoardWriteComment">
    <choose>
      <when test='comment_type.equals("non")'>
        UPDATE combine_board_comment SET ip = #{ip}, content = #{content} WHERE id = #{id} AND nickname = #{nickname} AND password = #{password} AND type = #{comment_type} AND status = 1
      </when>
      <when test='comment_type.equals("user")'>
        UPDATE combine_board_comment SET ip = #{ip}, content = #{content} WHERE id = #{id} AND user_id = #{user_id} AND type = #{comment_type} AND status = 1
      </when>
    </choose>
  </update>
</mapper>
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/mapper/CommunityDAO.xml">CommunityDAO.xml</a>
</pre>
