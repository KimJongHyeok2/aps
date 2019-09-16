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
## Client
```javascript
function selectPushList() {
  var header = "${_csrf.headerName}";
  var token = "${_csrf.token}";
  $("#empty-push-list").css("display", "none");
  $("#error-push-list").css("display", "none");
  $("#mobile-empty-push-list").css("display", "none");
  $("#mobile-error-push-list").css("display", "none");
  $("#pl-default").html("");
  $("#mobile-pl-default").html("");
  $("#push-list").append("<li id='progress-push-list' class='progress-push-list'><div class='spinner-border spinner-aps'></div></li>");
  $("#mobile-push-list").append("<li id='mobile-progress-push-list' class='progress-push-list'><div class='spinner-border spinner-aps'></div></li>");
  $.ajax({
    url: "${pageContext.request.contextPath}/common/push",
    type: "POST",
    cache: false,
    beforeSend: function(xhr) {
      xhr.setRequestHeader(header, token);
    },
    complete: function() {
      $("#progress-push-list").remove();
      $("#mobile-progress-push-list").remove();
    },
    success: function(data, status) {
      if(status == "success") {
        if(data.status == "Success") {
          pushCount = 0;
          pushReadCount = 0;
          if(data.count != 0) {
            var tempHTML = "";
            setTimeout(function() { $("#push-bell").removeClass("animated swing"); $("#mobile-push-bell").removeClass("animated swing"); }, 2000);
            for(var i=0; i<data.count; i++) {
              if(data.userPushs[i].status == 1) {
                pushCount += 1;
              } else {
                pushReadCount += 1;
              }
              tempHTML += "<div class='pl-default-box " + (data.userPushs[i].status==1? "":"read") + "'>";
                tempHTML += "<div class='read-circle'></div>";
                tempHTML += "<div class='content'>";
                  tempHTML += "<p class='subject' onclick=movePushPage('" + data.userPushs[i].id + "','" + data.userPushs[i].broadcaster_id + "','" + data.userPushs[i].content_id + "','" + data.userPushs[i].type + "');>" + pushSubjectFormat(data.userPushs[i].broadcaster_nickname,data.userPushs[i].subject,data.userPushs[i].type) + "</p>";
                  tempHTML += "<p class='info'>";
                    tempHTML += "<span>" + pushTypeFormat(data.userPushs[i].type) + "</span><span>" + (data.userPushs[i].nickname==null? data.userPushs[i].nonuser_nickname:data.userPushs[i].nickname) + "</span><span class='push-date'>" + pushDateFormat(data.userPushs[i].register_date) + "</span>";
                  tempHTML += "</p>"
                tempHTML += "</div>";
                tempHTML += "<div class='button'>";
                  tempHTML += "<button class='remove-button' onclick=deletePush('" + data.userPushs[i].id + "','one');>삭제</button>";
                tempHTML += "</div>";
              tempHTML += "</div>";
            }
            $("#pl-default").html(tempHTML);
            $("#mobile-pl-default").html(tempHTML);
          } else {
            $("#empty-push-list").css("display", "block");
            $("#mobile-empty-push-list").css("display", "block");
          }
          $("#push-count").html(pushCount>99? "99+":pushCount);
          $("#mobile-push-count").html(pushCount>99? "99+":pushCount);
        } else {
          $("#empty-push-list").css("display", "block");
          $("#mobile-empty-push-list").css("display", "block");
        }
        if(pushCount > 0) {
          $("#push-bell").addClass("animated swing");
          $("#push-bell").addClass("on");
          $("#mobile-push-bell").addClass("animated swing");
          $("#mobile-push-bell").addClass("on");
          $(".push-count").addClass("on");
        } else {
          $("#push-bell").removeClass("on");
          $("#mobile-push-bell").removeClass("on");
          $(".push-count").removeClass("on");
        }
      }
    },
    error: function() {
      $("#empty-push-list").css("display", "block");
      $("#mobile-empty-push-list").css("display", "block");
      location.reload();
    }
  });
}
function selectPushListPolling() {
  var header = "${_csrf.headerName}";
  var token = "${_csrf.token}";
  $("#empty-push-list").css("display", "none");
  $("#error-push-list").css("display", "none");
  $("#mobile-empty-push-list").css("display", "none");
  $("#mobile-error-push-list").css("display", "none");
  $("#pl-default").html("");
  $("#mobile-pl-default").html("");
  $("#push-list").append("<li id='progress-push-list' class='progress-push-list'><div class='spinner-border spinner-aps'></div></li>");
  $("#mobile-push-list").append("<li id='mobile-progress-push-list' class='progress-push-list'><div class='spinner-border spinner-aps'></div></li>");
  setTimeout(function() {
    $.ajax({
      url: "${pageContext.request.contextPath}/common/push",
      type: "POST",
      cache: false,
      beforeSend: function(xhr) {
        xhr.setRequestHeader(header, token);
      },
      complete: function() {
        $("#progress-push-list").remove();
        $("#mobile-progress-push-list").remove();
      },
      success: function(data, status) {
        if(status == "success") {
          if(data.status == "Success") {
            pushCount = 0;
            pushReadCount = 0;
            if(data.count != 0) {
              var tempHTML = "";
              setTimeout(function() { $("#push-bell").removeClass("animated swing"); $("#mobile-push-bell").removeClass("animated swing"); }, 2000);
              for(var i=0; i<data.count; i++) {
                if(data.userPushs[i].status == 1) {
                  pushCount += 1;
                } else {
                  pushReadCount += 1;
                }
                tempHTML += "<div class='pl-default-box " + (data.userPushs[i].status==1? "":"read") + "'>";
                  tempHTML += "<div class='read-circle'></div>";
                  tempHTML += "<div class='content'>";
                    tempHTML += "<p class='subject' onclick=movePushPage('" + data.userPushs[i].id + "','" + data.userPushs[i].broadcaster_id + "','" + data.userPushs[i].content_id + "','" + data.userPushs[i].type + "');>" + pushSubjectFormat(data.userPushs[i].broadcaster_nickname,data.userPushs[i].subject,data.userPushs[i].type) + "</p>";
                    tempHTML += "<p class='info'>";
                      tempHTML += "<span>" + pushTypeFormat(data.userPushs[i].type) + "</span><span>" + (data.userPushs[i].nickname==null? data.userPushs[i].nonuser_nickname:data.userPushs[i].nickname) + "</span><span>" + pushDateFormat(data.userPushs[i].register_date) + "</span>";
                    tempHTML += "</p>"
                  tempHTML += "</div>";
                  tempHTML += "<div class='button'>";
                    tempHTML += "<button class='remove-button' onclick=deletePush('" + data.userPushs[i].id + "','one');>삭제</button>";
                  tempHTML += "</div>";
                tempHTML += "</div>";
              }
              $("#pl-default").html(tempHTML);
              $("#mobile-pl-default").html(tempHTML);
            } else {
              $("#empty-push-list").css("display", "block");
              $("#mobile-empty-push-list").css("display", "block");
            }
            $("#push-count").html(pushCount>99? "99+":pushCount);
            $("#mobile-push-count").html(pushCount>99? "99+":pushCount);
          }
          if(pushCount > 0) {
            $("#push-bell").addClass("animated swing");
            $("#push-bell").addClass("on");
            $("#mobile-push-bell").addClass("animated swing");
            $("#mobile-push-bell").addClass("on");
            $(".push-count").addClass("on");
          } else {
            $("#push-bell").removeClass("on");
            $("#mobile-push-bell").removeClass("on");
            $(".push-count").removeClass("on")
          }
        }
      },
      error: function() {
        $("#error-push-list").css("display", "block");
        $("#mobile-error-push-list").css("display", "block");
        location.reload();
      }
    });
  }, 2000);
}
function pushSubjectFormat(nickname, subject, type) {
  if(type == 3) {
    return "민심평가(" + nickname + ")";
  } else {
    return subject;
  }
}
function pushTypeFormat(type) {
  if(type == 1 || type == 4 || type == 6) {
    return "댓글";
  } else if(type == 2 || type == 3 || type == 5 || type == 7) {
    return "답글";
  }
}
function movePushPage(id, broadcasterId, boardId, type) {
  var header = "${_csrf.headerName}";
  var token = "${_csrf.token}";
  $.ajax({
    url: "${pageContext.request.contextPath}/common/push/read",
    type: "POST",
    cache: false,
    data: {
      "id" : id
    },
    beforeSend: function(xhr) {
      xhr.setRequestHeader(header, token)
    },
    success: function(data, status) {
      if(status == "success") {
        if(data == "Success") {
          if(type == 1 || type == 2) { // 게시판 댓글, 답글
            location.href = "${pageContext.request.contextPath}/community/board/view/" + boardId + "?broadcasterId=" + broadcasterId;
          } else if(type == 3) { // 민심평가 답글
            location.href = "${pageContext.request.contextPath}/community/review/" + broadcasterId;
          } else if(type == 4 || type == 5) { // 고객센터 댓글, 답글
            location.href = "${pageContext.request.contextPath}/customerService/" + broadcasterId;
          } else if(type == 6 || type == 7) { // 통합 게시판 댓글 ,답글
            location.href = "${pageContext.request.contextPath}/community/combine/view/" + boardId;
          }
        }
      }
    }
  });
}
function deletePush(id, deleteType) {
  var header = "${_csrf.headerName}";
  var token = "${_csrf.token}";
  if(deleteType == "one") {
    $.ajax({
      url: "${pageContext.request.contextPath}/common/push/delete",
      type: "POST",
      cache: false,
      data: {
        "id" : id,
        "deleteType" : deleteType
      },
      beforeSend: function(xhr) {
        xhr.setRequestHeader(header, token);
      },
      success: function(data, status) {
        if(status == "success") {
          if(data == "Success") {
            selectPushList();
          }
        }
      }
    });
  } else if(deleteType == "readOnly") {
    if(pushReadCount != 0) {
      $.ajax({
        url: "${pageContext.request.contextPath}/common/push/delete",
        type: "POST",
        cache: false,
        data: {
          "id" : id,
          "deleteType" : deleteType
        },
        beforeSend: function(xhr) {
          xhr.setRequestHeader(header, token);
        },
        success: function(data, status) {
          if(status == "success") {
            if(data == "Success") {
              selectPushList();
            }
          }
				}
      });
    }
  } else {
    if(pushCount != 0) {
      $.ajax({
        url: "${pageContext.request.contextPath}/common/push/delete",
        type: "POST",
        cache: false,
        data: {
          "id" : id,
          "deleteType" : deleteType
        },
        beforeSend: function(xhr) {
          xhr.setRequestHeader(header, token);
        },
        success: function(data, status) {
          if(status == "success") {
            if(data == "Success") {
              selectPushList();
            }
          }
        }
      });
    }
  }
}
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/webapp/resources/include/header.jsp">header.jsp</a>
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

private final int EXPIRE_DELETE_DAY_TYPE_PUSH = 7;

@Override
public int insertUserPush(UserPushDTO dto) throws Exception { // 알림 추가
  Integer user_id = dao.selectUserIdByUserPushDTO(dto);

  if(user_id != dto.getFrom_user_id() && user_id != null) {		
    return dao.insertUserPush(dto);
  } else {
    return 0;
  }
}

@Override
@Transactional(readOnly = true)
public UserPushsDTO selectUserPushListByUserId(int userId) throws Exception { // 회원 알림 불러오기
		
  UserPushsDTO userPushs = new UserPushsDTO();
		
  userPushs.setUserPushs(dao.selectUserPushListByUserId(userId));
		
  if(userPushs.getUserPushs() != null && userPushs.getUserPushs().size() != 0) {
    userPushs.setCount(userPushs.getUserPushs().size());
  }
		
  userPushs.setStatus("Success");
		
  return userPushs;
}

@Override
public int updateUserPushStatus(Map<String, Integer> map) throws Exception { // 알림 읽음 상태 수정
  return dao.updateUserPushStatus(map);
}

@Override
public int deleteUserPush(Map<String, String> map) throws Exception { // 알림 삭제
  return dao.deleteUserPush(map);
}

@Override
@Transactional(isolation=Isolation.READ_COMMITTED)
@Scheduled(cron="0 0 0 * * *")
public void deleteExpireUserPushIndiv() throws Exception { // 보관 기한이 만료된 회원 알림들 영구삭제
  dao.deleteExpireUserPushIndiv(EXPIRE_DELETE_DAY_TYPE_PUSH);
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
  <select id="selectUserPushListByUserId" resultType="com.kjh.aps.domain.UserPushDTO">
    SELECT
      p.*,
      (SELECT nickname FROM user WHERE id = p.from_user_id) nickname,
      (SELECT nickname FROM broadcaster WHERE id = p.broadcaster_id) broadcaster_nickname
    FROM
      (SELECT * FROM user_push WHERE user_id = #{param1}) p ORDER BY id DESC
  </select>
  <update id="updateUserPushStatus">
    UPDATE user_push SET status = 0 WHERE id = #{id} AND user_id = #{user_id} AND status = 1
  </update>
  <delete id="deleteUserPush">
    <if test='deleteType != null and deleteType.equals("one")'>
      DELETE FROM user_push WHERE id = #{id} AND user_id = #{user_id}
    </if>
    <if test='deleteType != null and deleteType.equals("readOnly")'>
      DELETE FROM user_push WHERE user_id = #{user_id} AND status = 0
    </if>
    <if test='deleteType != null and deleteType.equals("all")'>
      DELETE FROM user_push WHERE user_id = #{user_id}
    </if>
  </delete>
  <delete id="deleteExpireUserPushIndiv">
    DELETE FROM user_push WHERE id IN (SELECT u.id FROM (SELECT id, datediff(CURRENT_TIMESTAMP, register_date) datediff FROM user_push) u WHERE u.datediff >= #{param1})
  </delete>
</mapper>
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/mapper/CommonDAO.xml">CommonDAO.xml</a>
</pre>
