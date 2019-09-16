## Demo
<img src="https://user-images.githubusercontent.com/47962660/64972906-10a6fb80-d8e5-11e9-96de-a95c27dc9498.gif"/>

## Review(Client)
```javascript
// 답글 불러오기
function selectReviewReply(id, row) {
  var replyCount = parseInt($("#reply-count-" + id).html().trim());
	
  if(replyCount != 0) {
    $.ajax({
      url: "${pageContext.request.contextPath}/community/reviewReply/list",
      type: "POST",
      cache: false,
      data: {
        "broadcasterReviewId" : id,
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
                      tempHTML += "<div class='info-regdate'>" + reviewDateFormat(data.commentReplys[i].register_date) + "</div>";
                      tempHTML += "<div class='info-ip'>" + data.commentReplys[i].ip + "</div>";
                    tempHTML += "</div>";
                    tempHTML += "<s:authorize access='isAuthenticated()'>";
                      if(data.commentReplys[i].user_id == parseInt("${empty sessionScope.id? 0:sessionScope.id}")) {
                        tempHTML += "<div class='ellipsis' onclick=$('#comment-reply-dropdown-" + data.commentReplys[i].id + "').toggle();>";
                          tempHTML += "<i class='fas fa-ellipsis-v'>";
                            tempHTML += "<ul id='comment-reply-dropdown-" + data.commentReplys[i].id + "' class='dropdown'>";
                              tempHTML += "<li class='dd-default' onclick='deleteReviewReply(" + data.commentReplys[i].broadcaster_review_id + ", " + data.commentReplys[i].id + ");'><i class='fas fa-trash'></i></li>";
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
                    tempHTML += "<div class='mobile-info-regdate'>" + reviewDateFormat(data.commentReplys[i].register_date) + "</div>";
                    tempHTML += "<div class='mobile-info-ip'>" + data.commentReplys[i].ip + "</div>";
                  tempHTML += "</div>";
                tempHTML += "</div>";
              tempHTML += "</li>";
            }
            if(data.replyCount > data.count) {
              tempHTML += "<li class='rl-default add-list' onclick='addReviewReply(" + id + ")'>더 보기 <i class='fas fa-caret-down'></i></li>";	
            }
            var commentStatus = $("#comment-status-" + id).val();
            if(commentStatus == 1) {
              tempHTML += "<s:authorize access='isAuthenticated()'>";
                tempHTML += "<li class='rl-default'>";
                  tempHTML += "<div class='input-box'>";
                    tempHTML += "<textarea id='comment-reply-content-" + id + "' placeholder='내용을 입력해주세요.'></textarea><button class='reply-button' onclick='writeReviewReply(" + id + ");'>등록</button>";
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
// 답글 더 보기
function addReviewReply(id) {
  $("#comment-reply-row-" + id).val(parseInt($("#comment-reply-row-" + id).val()) + 10);
  var row = $("#comment-reply-row-" + id).val();
  selectReviewReply(id, row);
}
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/webapp/WEB-INF/views/community/review.jsp">review.jsp</a>
</pre>
## CommunityController
```java
@Inject
private CommunityService communityService;

// 방송인 민심평가 답글 목록
@PostMapping("/reviewReply/list")
public @ResponseBody CommentReplysDTO reviewReplyList(int broadcasterReviewId,
  @RequestParam(value = "page", defaultValue = "1") int page,
  @RequestParam(value = "row", defaultValue = "15") int row) {
		
  CommentReplysDTO reviewReplys = new CommentReplysDTO();
		
  if(broadcasterReviewId != 0) {
    try {
      Map<String, Integer> map = new HashMap<>();
      map.put("broadcaster_review_id", broadcasterReviewId);
      map.put("page", page);
      map.put("row", row);
				
      reviewReplys = communityService.selectBroadcasterReviewReplyListByMap(map);
    } catch (Exception e) {
      reviewReplys.setStatus("Fail");
      throw new ResponseBodyException(e);
    }
  }
		
  return reviewReplys;
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
public CommentReplysDTO selectBroadcasterReviewReplyListByMap(Map<String, Integer> map) throws Exception { // 방송인 평가 답글 목록
		
  CommentReplysDTO reviewReplys = new CommentReplysDTO();
		
  reviewReplys.setCommentReplys(dao.selectBroadcasterReviewReplyListByMap(map));
		
  if(reviewReplys.getCommentReplys() != null && reviewReplys.getCommentReplys().size() != 0) {
    reviewReplys.setCount(reviewReplys.getCommentReplys().size());
			
    reviewReplys.setReplyCount(dao.selectBroadcasterReviewReplyCountByBroadcasterReviewId(map.get("broadcaster_review_id"))); // 해당 리뷰 답글 수
			
    int charCount = 0;
    for(int i=0; i<reviewReplys.getCount(); i++) { // 회원 IP 치환
      for(int j=0; j<reviewReplys.getCommentReplys().get(i).getIp().length(); j++) {
        if(reviewReplys.getCommentReplys().get(i).getIp().charAt(j) == '.') {
          charCount += 1;
        }
					
        if(charCount == 2) {
          charCount = 0;
          reviewReplys.getCommentReplys().get(i).setIp(reviewReplys.getCommentReplys().get(i).getIp().substring(0, j));
          break;
        }
      }
    }
  }
		
  reviewReplys.setStatus("Success");
		
  return reviewReplys;
}
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/service/CommunityServiceImpl.java">CommunityServiceImpl.java</a>
</pre>
## CommunityMapper
```xml
<mapper namespace="community">
  <select id="selectBroadcasterReviewReplyListByMap" resultType="com.kjh.aps.domain.CommentReplyDTO">
    SELECT brc_b_cr_list.* FROM
      (SELECT
        @rownum:=@rownum+1 as no, brc_b_cr.*
      FROM
        (SELECT
          cr.*, u.nickname as nickname, u.level as level, u.profile as profile, u.type as userType
        FROM
          broadcaster_review_reply cr INNER JOIN user u ON cr.user_id = u.id
        WHERE
          cr.broadcaster_review_id = #{broadcaster_review_id} AND cr.status = 1 ORDER BY cr.id ASC) brc_b_cr, (SELECT @rownum:=0) rownum) brc_b_cr_list
    WHERE brc_b_cr_list.no BETWEEN #{page} AND #{row}
  </select>
  <select id="selectBroadcasterReviewReplyCountByBroadcasterReviewId" resultType="Integer">
    SELECT count(id) FROM broadcaster_review_reply WHERE broadcaster_review_id = #{param1} AND status = 1
  </select>
</mapper>
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/mapper/CommunityDAO.xml">CommunityDAO.xml</a>
</pre>
