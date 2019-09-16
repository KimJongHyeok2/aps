## Demo
<img src="https://user-images.githubusercontent.com/47962660/64987792-ecf3ad80-d904-11e9-9ba7-f2c53c267e65.gif"/>

## ServletContext
```xml
<!-- Interceptor -->
<beans:bean name="pushInterceptor" class="com.kjh.aps.intercepter.PushInterceptor"/>
<interceptors>
  <interceptor>
      <mapping path="/community/board/comment/write"/>
      <mapping path="/community/board/commentReply/write"/>
      <mapping path="/community/reviewReply/write"/>
      <mapping path="/community/combine/comment/write"/>
      <mapping path="/community/combine/commentReply/write"/>
      <mapping path="/customerService/comment/write"/>
      <mapping path="/customerService/commentReply/write"/>
    <beans:ref bean="pushInterceptor"/>
  </interceptor>
</interceptors>
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/webapp/WEB-INF/spring/appServlet/servlet-context.xml">ServletContext.xml</a>
</pre>
## PushInterceptor
```java
public class PushInterceptor extends HandlerInterceptorAdapter {

  @Inject
  private CommonService commonService;
	
  @Override
  public void postHandle(HttpServletRequest request, HttpServletResponse response, Object handler,
    ModelAndView modelAndView) throws Exception {
		
    Integer type = (Integer)request.getAttribute("type"); // Push Type
    Integer from_user_id = request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id"); // Push를 보낸 회원 고유번호
    UserPushDTO dto = null;
		
    if(type != null && from_user_id != 0) {
      if(type == 1) { // 방송인 커뮤니티 게시판 댓글 Push
        CommentDTO comment = (CommentDTO)request.getAttribute("dto");
        Integer user_id = comment.getBoardUserId(); // Push를 수신할 회원 고유번호
				
        dto = new UserPushDTO(comment.getBroadcaster_id(), user_id, from_user_id, comment.getBroadcaster_board_id(), comment.getBoardSubject(), type);
      } else if(type == 2) { // 방송인 커뮤니티 게시판 댓글의 답글 Push
        CommentReplyDTO commentReply = (CommentReplyDTO)request.getAttribute("dto");
        Integer user_id = commentReply.getBroadcaster_board_comment_id(); // Push를 수신할 회원의 해당 댓글의 고유번호 
				
        dto = new UserPushDTO(commentReply.getBroadcaster_id(), user_id, from_user_id, commentReply.getBroadcaster_board_id(), commentReply.getBoardSubject(), type);
      } else if(type == 3) { // 방송인 민심평가 답글 Push
        CommentReplyDTO commentReply = (CommentReplyDTO)request.getAttribute("dto");
        Integer user_id = 0;
				
        dto = new UserPushDTO(commentReply.getBroadcaster_id(), user_id, from_user_id, commentReply.getBroadcaster_review_id(), "NONE", type);
			} else if(type == 4) { // 고객센터 댓글 Push
				CommentDTO comment = (CommentDTO)request.getAttribute("dto");
				Integer user_id = comment.getBoardUserId(); // Push를 수신할 회원 고유번호
				
				dto = new UserPushDTO(comment.getCategory_id(), user_id, from_user_id, comment.getNotice_id(), comment.getBoardSubject(), type);
      } else if(type == 5) { // 고객센터 댓글의 답글 Push
        CommentReplyDTO commentReply = (CommentReplyDTO)request.getAttribute("dto");
        Integer user_id = commentReply.getNotice_comment_id(); // Push를 수신할 회원의 해당 댓글의 고유번호
				
        dto = new UserPushDTO(commentReply.getCategory_id(), user_id, from_user_id, commentReply.getNotice_id(), commentReply.getBoardSubject(), type);
      }
    } else if(type != null && from_user_id == 0 && request.getAttribute("dto") != null) {
      if(type == 6) { // 통합 게시판 댓글 Push					
        CommentDTO comment = (CommentDTO)request.getAttribute("dto");
        Integer user_id = comment.getBoardUserId(); // Push를 수신할 회원 고유번호
					
        dto = new UserPushDTO("combine", user_id, from_user_id, comment.getNickname(), comment.getCombine_board_id(), comment.getBoardSubject(), type);
      } else if(type == 7) { // 통합 게시판 댓글의 답글 Push
        CommentReplyDTO commentReply = (CommentReplyDTO)request.getAttribute("dto");
        Integer user_id = commentReply.getCombine_board_comment_id(); // Push를 수신할 회원 고유번호
						
        dto = new UserPushDTO("combine", user_id, from_user_id, commentReply.getNickname(), commentReply.getCombine_board_id(), commentReply.getBoardSubject(), type);
      }
    }
		
    if(dto != null) { commonService.insertUserPush(dto); }
		
    super.postHandle(request, response, handler, modelAndView);
  }
	
}
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/intercepter/PushInterceptor.java">PushInterceptor.java</a>
</pre>
## CommonServiceImpl
```java
@Inject
private CommonDAO dao;

@Override
public int insertUserPush(UserPushDTO dto) throws Exception { // 알림 추가
  Integer user_id = dao.selectUserIdByUserPushDTO(dto);

  if(user_id != dto.getFrom_user_id() && user_id != null) {		
    return dao.insertUserPush(dto);
  } else {
    return 0;
  }
}
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/service/CommonServiceImpl.java">CommonServiceImpl.java</a>
</pre>
## CommonMapper
```xml
<mapper namespace="common">
  <select id="selectUserIdByUserPushDTO" resultType="Integer">
    <choose>
      <when test="type == 1">
        SELECT user_id FROM broadcaster_board WHERE id = #{content_id}
      </when>
      <when test="type == 2">
        SELECT u.user_id FROM (SELECT * FROM broadcaster_board_comment WHERE broadcaster_board_id = #{content_id}) u WHERE u.id = #{user_id}
      </when>
      <when test="type == 3">
        SELECT u.user_id FROM (SELECT id, user_id FROM broadcaster_review WHERE broadcaster_id = #{broadcaster_id}) u WHERE u.id = #{content_id}
      </when>
      <when test="type == 4">
        SELECT user_id FROM notice WHERE id = #{content_id}
      </when>
      <when test="type == 5">
        SELECT u.user_id FROM (SELECT * FROM notice_comment WHERE notice_id = #{content_id}) u WHERE u.id = #{user_id}
      </when>
      <when test="type == 6">
        SELECT user_id FROM combine_board WHERE id = #{content_id}
      </when>
      <when test="type == 7">
        SELECT user_id FROM combine_board_comment WHERE id = #{user_id}
      </when>
    </choose>
  </select>
  <insert id="insertUserPush" parameterType="com.kjh.aps.domain.UserPushDTO">
    <choose>
      <when test="type == 1">
        INSERT INTO user_push(broadcaster_id, user_id, from_user_id, content_id, subject, type) VALUES(#{broadcaster_id}, #{user_id}, #{from_user_id}, #{content_id}, #{subject}, #{type})
      </when>
      <when test="type == 2">
        INSERT INTO user_push(broadcaster_id, user_id, from_user_id, content_id, subject, type) VALUES(#{broadcaster_id}, (SELECT u.user_id FROM (SELECT * FROM broadcaster_board_comment WHERE broadcaster_board_id = #{content_id}) u WHERE u.id = #{user_id}), #{from_user_id}, #{content_id}, #{subject}, #{type})
      </when>
      <when test="type == 3">
        INSERT INTO user_push(broadcaster_id, user_id, from_user_id, content_id, subject, type) VALUES(#{broadcaster_id}, (SELECT u.user_id FROM (SELECT id, user_id FROM broadcaster_review WHERE broadcaster_id = #{broadcaster_id}) u WHERE u.id = #{content_id}), #{from_user_id}, #{content_id}, #{subject}, #{type})
      </when>
      <when test="type == 4">
        INSERT INTO user_push(broadcaster_id, user_id, from_user_id, content_id, subject, type) VALUES(#{broadcaster_id}, #{user_id}, #{from_user_id}, #{content_id}, #{subject}, #{type})
      </when>
      <when test="type == 5">
        INSERT INTO user_push(broadcaster_id, user_id, from_user_id, content_id, subject, type) VALUES(#{broadcaster_id}, (SELECT u.user_id FROM (SELECT * FROM notice_comment WHERE notice_id = #{content_id}) u WHERE u.id = #{user_id}), #{from_user_id}, #{content_id}, #{subject}, #{type})
      </when>
      <when test="type == 6">
        INSERT INTO user_push(broadcaster_id, user_id, from_user_id, nonuser_nickname, content_id, subject, type) VALUES(#{broadcaster_id}, #{user_id}, #{from_user_id}, #{nonuser_nickname}, #{content_id}, #{subject}, #{type})
      </when>
      <when test="type == 7">
        INSERT INTO user_push(broadcaster_id, user_id, from_user_id, nonuser_nickname, content_id, subject, type) VALUES(#{broadcaster_id}, (SELECT user_id FROM combine_board_comment WHERE id = #{user_id}), #{from_user_id}, #{nonuser_nickname}, #{content_id}, #{subject}, #{type})
      </when>
    </choose>
  </insert>
</mapper>
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/mapper/CommonDAO.xml">CommonDAO.xml</a>
</pre>
