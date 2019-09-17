## Demo
<img src="https://user-images.githubusercontent.com/47962660/65052676-c2a5fc80-d9a5-11e9-969d-14f91e1bc8fc.gif"/>

## CombineView(Client)
```javascript
function selectCommentReply(id, row) {
  var replyCount = parseInt($("#reply-count-" + id).html().trim());
  if(replyCount != 0) {
    $.ajax({
      url: "${pageContext.request.contextPath}/community/combine/commentReply/list",
      type: "POST",
      cache: false,
      data: {
        "combineBoardCommentId" : id,
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
                        tempHTML += "<div class='info-name'><span class='nickname'>" + data.commentReplys[i].nickname + "</span>";
                        if(data.commentReplys[i].userType != 0) {															
                          tempHTML += "<span class='level'>lv." + data.commentReplys[i].level + "</span>";
                        }
                        tempHTML += "</div>";
                      }
                      tempHTML += "<div class='info-regdate'>" + commentDateFormat(data.commentReplys[i].register_date) + "</div>";
                      tempHTML += "<div class='info-ip'>" + data.commentReplys[i].ip + "</div>";
                    tempHTML += "</div>";
                    if(data.commentReplys[i].commentReply_type == "non") {
                      tempHTML += "<div class='ellipsis' onclick=$('#comment-reply-dropdown-" + data.commentReplys[i].id + "').toggle();>";
                        tempHTML += "<i class='fas fa-ellipsis-v'>";
                          tempHTML += "<ul class='dropdown' id='comment-reply-dropdown-" + data.commentReplys[i].id + "'>";
                            tempHTML += "<li class='dd-default' onclick=deleteCommentReply('" + data.commentReplys[i].id + "','" + data.commentReplys[i].combine_board_comment_id + "','" + data.commentReplys[i].commentReply_type + "');><i class='fas fa-trash'></i></li>";
                          tempHTML += "</ul>";
                        tempHTML += "</i>";
                      tempHTML += "</div>";
                    } else if(data.commentReplys[i].commentReply_type == "user") {
                      tempHTML += "<s:authorize access='isAuthenticated()'>";
                        if(data.commentReplys[i].user_id == parseInt("${empty sessionScope.id? 0:sessionScope.id}")) {
                          tempHTML += "<div class='ellipsis' onclick=$('#comment-reply-dropdown-" + data.commentReplys[i].id + "').toggle();>";
                            tempHTML += "<i class='fas fa-ellipsis-v'>";
                              tempHTML += "<ul class='dropdown' id='comment-reply-dropdown-" + data.commentReplys[i].id + "'>";
                                tempHTML += "<li class='dd-default' onclick=deleteCommentReply('" + data.commentReplys[i].id + "','" + data.commentReplys[i].combine_board_comment_id + "','" + data.commentReplys[i].commentReply_type + "');><i class='fas fa-trash'></i></li>";
                              tempHTML += "</ul>";
                            tempHTML += "</i>";
                          tempHTML += "</div>";
                        }
                      tempHTML += "</s:authorize>";
                    }
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
                    tempHTML += "<textarea id='comment-reply-content-" + id + "' placeholder='내용을 입력해주세요.'></textarea><button class='reply-button' onclick=writeCommentReply('" + id + "','user');>등록</button>";
                    tempHTML += "<input type='hidden' id='comment-reply-row-" + id + "' value='" + row + "'/>";
                  tempHTML += "</div>";
                tempHTML += "</li>";
              tempHTML += "</s:authorize>";
              tempHTML += "<s:authorize access='!isAuthenticated()'>";
                tempHTML += "<li class='rl-default'>";
                  tempHTML += "<div class='input-box non'>";
                    tempHTML += "<div class='input'>";
                      tempHTML += "<input type='text' id='comment-reply-nickname-" + id + "' placeholder='닉네임을 입력해주세요.'/>";
                    tempHTML += "</div>";
                    tempHTML += "<div class='input'>";
                      tempHTML += "<input type='password' id='comment-reply-password-" + id + "' placeholder='비밀번호를 입력해주세요.'/>";
                    tempHTML += "</div>";
                  tempHTML += "</div>";
                  tempHTML += "<div class='input-box'>";
                      tempHTML += "<textarea id='comment-reply-content-" + id + "' placeholder='내용을 입력해주세요.'></textarea><button class='reply-button' onclick=writeCommentReply('" + id + "','non');>등록</button>";
                      tempHTML += "<input type='hidden' id='comment-reply-row-" + id + "' value='10'/>";
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
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/webapp/WEB-INF/views/community/combine/combine_view.jsp">combine_view.jsp</a>
</pre>
## CommunityController
```java
@Inject
private CommunityService communityService;

// 통합 게시판 글 댓글의 답글 목록
@PostMapping("/combine/commentReply/list")
public @ResponseBody CommentReplysDTO combineCommentReplyList(int combineBoardCommentId,
  @RequestParam(value = "page", defaultValue = "1") int page,
  @RequestParam(value = "row", defaultValue = "15") int row) {
		
  CommentReplysDTO commentReplys = new CommentReplysDTO();
		
  if(combineBoardCommentId != 0) {
    try {
      Map<String, Integer> map = new HashMap<>();
      map.put("combine_board_comment_id", combineBoardCommentId);
      map.put("page", page);
      map.put("row", row);
				
      commentReplys = communityService.selectCombineBoardWriteCommentReplyListByMap(map);
    } catch (Exception e) {
      commentReplys.setStatus("Fail");
      throw new ResponseBodyException(e);
    }
  }
		
  return commentReplys;
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
public CommentReplysDTO selectCombineBoardWriteCommentReplyListByMap(Map<String, Integer> map) throws Exception { // 통합 게시판 글의 답글 목록

  CommentReplysDTO commentReplys = new CommentReplysDTO();
		
  commentReplys.setCommentReplys(dao.selectCombineBoardWriteCommentReplyListByMap(map));
		
  if(commentReplys.getCommentReplys() != null && commentReplys.getCommentReplys().size() != 0) {
    commentReplys.setCount(commentReplys.getCommentReplys().size());
			
    commentReplys.setReplyCount(dao.selectCombineBoardWriteCommentReplyCountByCombineBoardCommentId(map.get("combine_board_comment_id"))); // 해당 리뷰 답글 수
			
    int charCount = 0;
    for(int i=0; i<commentReplys.getCount(); i++) { // 회원 IP 치환
      for(int j=0; j<commentReplys.getCommentReplys().get(i).getIp().length(); j++) {
        if(commentReplys.getCommentReplys().get(i).getIp().charAt(j) == '.') {
          charCount += 1;
        }
					
        if(charCount == 2) {
          charCount = 0;
          commentReplys.getCommentReplys().get(i).setIp(commentReplys.getCommentReplys().get(i).getIp().substring(0, j));
          break;
        }
      }
    }
  }
		
  commentReplys.setStatus("Success");
		
  return commentReplys;
}
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/service/CommunityServiceImpl.java">CommunityServiceImpl.java</a>
</pre>
## CommunityMapper
```xml
<mapper namespace="community">
  <select id="selectCombineBoardWriteCommentReplyListByMap" resultType="com.kjh.aps.domain.CommentReplyDTO">
    SELECT brc_b_cr_list.* FROM
      (SELECT
        @rownum:=@rownum+1 as no, brc_b_cr.*
      FROM
        (SELECT
          cr.id, cr.combine_board_comment_id, cr.user_id, cr.ip, cr.nickname, cr.profile, cr.level, cr.user_type userType, cr.type commentReply_type, cr.content, cr.status, cr.register_date
        FROM
          combine_board_comment_reply cr
        WHERE
          cr.combine_board_comment_id = #{combine_board_comment_id} AND cr.status = 1 ORDER BY cr.id ASC) brc_b_cr, (SELECT @rownum:=0) rownum) brc_b_cr_list
    WHERE brc_b_cr_list.no BETWEEN #{page} AND #{row}
	</select>
  <select id="selectCombineBoardWriteCommentReplyCountByCombineBoardCommentId" resultType="Integer">
    SELECT count(id) FROM combine_board_comment_reply WHERE combine_board_comment_id = #{param1} AND status = 1
  </select>
</mapper>
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/mapper/CommunityDAO.xml">CommunityDAO.xml</a>
</pre>
