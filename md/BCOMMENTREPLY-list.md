## Demo
<img src="https://user-images.githubusercontent.com/47962660/64961871-5d80d700-d8d1-11e9-8567-db6fd57d18b0.gif"/>

## BoardView(Client)
```javascript
function selectCommentReply(id, row) {
  var replyCount = parseInt($("#reply-count-" + id).html().trim());
		
  if(replyCount != 0) {
    $.ajax({
      url: "${pageContext.request.contextPath}/community/board/commentReply/list",
      type: "POST",
      cache: false,
      data: {
        "broadcasterBoardCommentId" : id,
        "row" : row
      },
      beforeSend: function(xhr) {
        xhr.setRequestHeader(header, token);
      },
      success: function(data, status) {
        if(status == "success") {
          if(data.status == "Success") {
            $("#reply-list-box-" + id).html("");
            var tempHTML = "";
            tempHTML += "<ul class='reply-list'>";
            for(var i=0; i<data.count; i++) {
              tempHTML += "<li class='rl-default'>";
                tempHTML += "<div class='comment-box'>";
                  tempHTML += "<div class='comment-title'>";
                    tempHTML += "<div class='comment-info'>";
                      if(data.commentReplys[i].profile != null) {
                        tempHTML += "<div class='info-image'><img class='img-fluid' src='https://kr.object.ncloudstorage.com/aps/profile/" + data.commentReplys[i].profile + "'/></div>";
                      } else {														
                        tempHTML += "<div class='info-image'><i class='far fa-user fa-2x'></i></div>";
                      }
                      if(data.commentReplys[i].userType == 10) {
                        tempHTML += "<div class='info-name'><span class='nickname'>" + data.commentReplys[i].nickname + "</span><span class='master'>M</span></div>";
                      } else {
                        tempHTML += "<div class='info-name'><span class='nickname'>" + data.commentReplys[i].nickname + "</span><span class='level'>lv." + data.commentReplys[i].level + "</span></div>";														
                      }
                      tempHTML += "<div class='info-regdate'>" + commentDateFormat(data.commentReplys[i].register_date) + "</div>";
                      tempHTML += "<div class='info-ip'>" + data.commentReplys[i].ip + "</div>";
                    tempHTML += "</div>";
                    tempHTML += "<s:authorize access='isAuthenticated()'>";
                      if(data.commentReplys[i].user_id == parseInt("${empty sessionScope.id? 0:sessionScope.id}")) {
                        tempHTML += "<div class='ellipsis' onclick=$('#comment-reply-dropdown-" + data.commentReplys[i].id + "').toggle();>";
                          tempHTML += "<i class='fas fa-ellipsis-v'>";
                            tempHTML += "<ul id='comment-reply-dropdown-" + data.commentReplys[i].id + "' class='dropdown'>";
                              tempHTML += "<li class='dd-default' onclick='deleteCommentReply(" + data.commentReplys[i].broadcaster_board_comment_id + ", " + data.commentReplys[i].id + ");'><i class='fas fa-trash'></i></li>";
                            tempHTML += "</ul>";
                          tempHTML += "</i>";
                        tempHTML += "</div>";
                      }
                    tempHTML += "</s:authorize>";
                  tempHTML += "</div>";
                  tempHTML += "<div class='comment-content'>";
                    tempHTML += "<span class='reply-id'></span><span class='content'>" + data.commentReplys[i].content.replace(/\n/g, "<br>") + "</span>";
                  tempHTML += "</div>";
                  tempHTML += "<div class='mobile-comment-info'>";
                    tempHTML += "<div class='mobile-info-regdate'>" + commentDateFormat(data.commentReplys[i].register_date) + "</div>";
                    tempHTML += "<div class='mobile-info-ip'>" + data.commentReplys[i].ip + "</div>";
                  tempHTML += "</div>";
                tempHTML += "</div>";
              tempHTML += "</li>";
            }
            if(data.replyCount > data.count) {
              tempHTML += "<li class='rl-default add-list' onclick='addCommentReply(" + id + ")'>더 보기 <i class='fas fa-caret-down'></i></li>";	
            }
            var commentStatus = $("#comment-status-" + id).val();
            if(commentStatus == 1) {
              tempHTML += "<s:authorize access='isAuthenticated()'>";
                tempHTML += "<li class='rl-default'>";
                  tempHTML += "<div class='input-box'>";
                    tempHTML += "<textarea id='comment-reply-content-" + id + "' placeholder='내용을 입력해주세요.'></textarea><button class='reply-button' onclick='writeCommentReply(" + id + ");'>등록</button>";
                    tempHTML += "<input type='hidden' id='comment-reply-row-" + id + "' value='" + row + "'/>";
                  tempHTML += "</div>";
                tempHTML += "</li>";
              tempHTML += "</s:authorize>";
              tempHTML += "<s:authorize access='!isAuthenticated()'>";
                tempHTML += "<li class='rl-default'>";
                  tempHTML += "<div class='input-box'>";
                    tempHTML += "<div class='not-authenticated'>";
                      tempHTML += "<div class='info-circle'><i class='fas fa-info fa-2x'></i></div>";
                      tempHTML += "<div class='text'>답글을 등록하려면 로그인이 필요합니다.</div>";
                      tempHTML += "<input type='hidden' id='comment-reply-row-" + id + "' value='" + row + "'/>";
                    tempHTML += "</div>";
                  tempHTML += "</div>";
                tempHTML += "</li>";
              tempHTML += "</s:authorize>";
            }
            tempHTML += "</ul>";
            $("#reply-list-box-" + id).html(tempHTML);
            $("#reply-count-" + id).html(data.replyCount);
          } else {
            modalToggle("#modal-type-4", "오류", "알 수 없는 오류입니다.");
          }
        }
      },
      error: function() {
        modalToggle("#modal-type-4", "오류", "알 수 없는 오류입니다.");
      }
    });
  }
}
function addCommentReply(id) {
  $("#comment-reply-row-" + id).val(parseInt($("#comment-reply-row-" + id).val()) + 10);
  var row = $("#comment-reply-row-" + id).val();
  selectCommentReply(id, row);
}
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/webapp/WEB-INF/views/community/board/board_view.jsp">board_view.jsp</a>
</pre>
## CommunityController
```java
@Inject
private CommunityService communityService;
  
// 방송인 커뮤니티 게시판 글 댓글의 답글 목록
@PostMapping("/board/commentReply/list")
public @ResponseBody CommentReplysDTO boardCommenReplyList(int broadcasterBoardCommentId,
  @RequestParam(value = "page", defaultValue = "1") int page,
  @RequestParam(value = "row", defaultValue = "10") int row) {
		
  CommentReplysDTO boardCommentReply = new CommentReplysDTO();
		
  try {
    Map<String, Integer> map = new HashMap<>();
    map.put("broadcaster_board_comment_id", broadcasterBoardCommentId);
    map.put("page", page);
    map.put("row", row);
			
    boardCommentReply = communityService.selectBoardWriteCommentReplyListByMap(map);
  } catch (Exception e) {
    boardCommentReply.setStatus("Fail");
    throw new ResponseBodyException(e);
  }
		
  return boardCommentReply;
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
public CommentReplysDTO selectBoardWriteCommentReplyListByMap(Map<String, Integer> map) throws Exception { // 방송인 커뮤니티 게시판 글의 답글 목록

  CommentReplysDTO boardCommentReply = new CommentReplysDTO();
		
  boardCommentReply.setCommentReplys(dao.selectBoardWriteCommentReplyListByMap(map));
		
  if(boardCommentReply.getCommentReplys() != null && boardCommentReply.getCommentReplys().size() != 0) {
    boardCommentReply.setCount(boardCommentReply.getCommentReplys().size());

    boardCommentReply.setReplyCount(dao.selectBoardWriteCommentReplyCountByBoardCommentId(map.get("broadcaster_board_comment_id")));
			
    int charCount = 0;
    for(int i=0; i<boardCommentReply.getCount(); i++) { // 회원 IP 치환
      for(int j=0; j<boardCommentReply.getCommentReplys().get(i).getIp().length(); j++) {
        if(boardCommentReply.getCommentReplys().get(i).getIp().charAt(j) == '.') {
          charCount += 1;
        }
					
        if(charCount == 2) {
          charCount = 0;
          boardCommentReply.getCommentReplys().get(i).setIp(boardCommentReply.getCommentReplys().get(i).getIp().substring(0, j));
          break;
        }
      }
    }
  }
		
  boardCommentReply.setStatus("Success");
		
  return boardCommentReply;
}
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/service/CommunityServiceImpl.java">CommunityServiceImpl.java</a>
</pre>
## CommunityMapper
```xml
<mapper namespace="community">
  <select id="selectBoardWriteCommentReplyListByMap" resultType="com.kjh.aps.domain.CommentReplyDTO">
    SELECT brc_b_cr_list.* FROM
      (SELECT
        @rownum:=@rownum+1 as no, brc_b_cr.*
      FROM
        (SELECT
          cr.*, u.nickname as nickname, u.level as level, u.profile as profile, u.type as userType
        FROM
          broadcaster_board_comment_reply cr INNER JOIN user u ON cr.user_id = u.id
        WHERE
          cr.broadcaster_board_comment_id = #{broadcaster_board_comment_id} AND cr.status = 1 ORDER BY cr.id ASC) brc_b_cr, (SELECT @rownum:=0) rownum) brc_b_cr_list
    WHERE brc_b_cr_list.no BETWEEN #{page} AND #{row}
  </select>
  <select id="selectBoardWriteCommentReplyCountByBoardCommentId" resultType="Integer">
    SELECT count(id) FROM broadcaster_board_comment_reply WHERE broadcaster_board_comment_id = #{param1} AND status = 1
  </select>
</mapper>
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/mapper/CommunityDAO.xml">CommunityDAO.xml</a>
</pre>
