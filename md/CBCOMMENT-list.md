## Demo
<h5>등록된 댓글을 최신/인기순으로 정렬할 수 있습니다.</h5>
<img src="https://user-images.githubusercontent.com/47962660/65045372-9c7a5f80-d999-11e9-92a2-c8f8dbfba943.gif"/>

## CombineView(Client)
```javascript
function selectComment(page) {
  var combineBoardId = "${board.id}";
  var listType = $("#comment-list-type").val();
	
  if(page == null) {
    page = 1;
  }
	
  $("#comment-spinner").addClass("on");
  $("#comment-list-box").html("");
	
  $.ajax({
    url: "${pageContext.request.contextPath}/community/combine/comment/list",
    type: "POST",
    cache: false,
    data: {
      "combineBoardId" : combineBoardId,
      "page" : page,
      "listType" : listType
    },
    beforeSend: function(xhr) {
      xhr.setRequestHeader(header, token);
    },
    success: function(data, status) {
      if(status == "success") {
        if(data.status == "Success" && data.count != 0) {
          var tempHTML = "";
          var countFlag = false;
          $("#list-type-box").css("display", "none");
          $("#comment-pagination-inner-box").css("display", "none");
          for(var i=0; i<data.count; i++) {
            if(data.comments[i].status == 1) {
              countFlag = true;
              tempHTML += "<ul class='comment-list animated tdFadeIn'>";
                tempHTML += "<li id='cl-default-" + data.comments[i].id + "' class='cl-default'>";
                    tempHTML += "<div class='comment-box'>";
                      tempHTML += "<div class='comment-title'>";
                        if(listType == "popular" && data.comments[i].no <= 3) {
                          tempHTML += "<div class='popular-top'>BEST</div>";
                        }
                        tempHTML += "<div class='comment-info'>";
                          if(data.comments[i].profile != null) {												
                            tempHTML += "<div class='info-image'><img class='img-fluid' src='https://kr.object.ncloudstorage.com/aps/profile/" + data.comments[i].profile + "'/></div>";
                          } else {														
                            tempHTML += "<div class='info-image'><i class='far fa-user fa-2x'></i></div>";
                          }
                          if(data.comments[i].userType == 10) {
                            tempHTML += "<div class='info-name'><span class='nickname'>" + data.comments[i].nickname + "</span><span class='master'>M</span></div>";
                          } else {
                            /* tempHTML += "<div class='info-name'><span class='nickname'>" + data.comments[i].nickname + "</span><span class='level'>lv." + data.comments[i].level + "</span></div>"; */
                            tempHTML += "<div class='info-name'><span class='nickname'>" + data.comments[i].nickname + "</span>";
                            if(data.comments[i].userType != 0) {															
                              tempHTML += "<span class='level'>lv." + data.comments[i].level + "</span>";
                            }
                            tempHTML += "</div>";
                          }
                          tempHTML += "<div class='info-regdate'>" + commentDateFormat(data.comments[i].register_date) + "</div>";
                          tempHTML += "<div class='info-ip'>" + data.comments[i].ip + "</div>";
                        tempHTML += "</div>";
                      if(data.comments[i].comment_type == "non") {
                        tempHTML += "<div class='ellipsis' onclick=$('#comment-dropdown-" + data.comments[i].id + "').toggle();>";
                          tempHTML += "<i class='fas fa-ellipsis-v'>";
                            tempHTML += "<ul class='dropdown' id='comment-dropdown-" + data.comments[i].id + "'>";
                              tempHTML += "<li class='dd-default' onclick=modifyComment('" + data.comments[i].id + "','" + data.comments[i].comment_type + "');><i class='fas fa-pen'></i></li>";
                              tempHTML += "<li class='dd-default' onclick=deleteComment('" + data.comments[i].id + "','" + data.comments[i].comment_type + "');><i class='fas fa-trash'></i></li>";
                            tempHTML += "</ul>";
                          tempHTML += "</i>";
                        tempHTML += "</div>";
                      } else if(data.comments[i].comment_type == "user") {
                        tempHTML += "<s:authorize access='isAuthenticated()'>";
                          if(data.comments[i].user_id == parseInt("${empty sessionScope.id? 0:sessionScope.id}")) {
                            tempHTML += "<div class='ellipsis' onclick=$('#comment-dropdown-" + data.comments[i].id + "').toggle();>";
                              tempHTML += "<i class='fas fa-ellipsis-v'>";
                                tempHTML += "<ul class='dropdown' id='comment-dropdown-" + data.comments[i].id + "'>";
                                  tempHTML += "<li class='dd-default' onclick=modifyComment('" + data.comments[i].id + "','" + data.comments[i].comment_type + "');><i class='fas fa-pen'></i></li>";
                                  tempHTML += "<li class='dd-default' onclick=deleteComment('" + data.comments[i].id + "','" + data.comments[i].comment_type + "');><i class='fas fa-trash'></i></li>";
                                tempHTML += "</ul>";
                              tempHTML += "</i>";
                            tempHTML += "</div>";
                          }
                        tempHTML += "</s:authorize>";
                      }
                      tempHTML += "</div>"
                      tempHTML += "<div class='comment-content'>";
                        tempHTML += "<span class='content'>" + data.comments[i].content + "</span>";
                      tempHTML += "</div>";
                      tempHTML += "<div class='mobile-comment-info'>";
                        tempHTML += "<div class='mobile-info-regdate'>" + commentDateFormat(data.comments[i].register_date) + "</div>";
                        tempHTML += "<div class='mobile-info-ip'>" + data.comments[i].ip + "</div>";
                      tempHTML += "</div>";
                      tempHTML += "<div class='comment-function'>";
                        tempHTML += "<div class='reply-box'>";
                          tempHTML += "<button class='reply-button' onclick='replyOn(" + data.comments[i].id + ")'>답글(<span id='reply-count-" + data.comments[i].id + "'>" + countFormat(data.comments[i].replyCount) + "</span>)</button>";
                        tempHTML += "</div>";
                        tempHTML += "<div class='recommend-box'>";
                          tempHTML += "<div class='up " + (data.comments[i].recommendType==1? "active":"") + "' onclick=recommendComment('" + data.comments[i].id + "','up');><i class='far fa-thumbs-up'></i> <span id='comment-up-" + data.comments[i].id + "'>" + countFormat(data.comments[i].up) + "</span></div>";
                          tempHTML += "<div class='down " + (data.comments[i].recommendType==2? "active":"") + "' onclick=recommendComment('" + data.comments[i].id + "','down');><i class='far fa-thumbs-down'></i> <span id='comment-down-" + data.comments[i].id + "'>" + countFormat(data.comments[i].down) + "</span></div>";
                        tempHTML += "</div>";
                      tempHTML += "</div>";
                    tempHTML += "</div>";
                  tempHTML += "</li>";
                  tempHTML += "<li id='reply-list-box-" + data.comments[i].id + "' class='reply-list-box'>";
                  tempHTML += "<s:authorize access='isAuthenticated()'>";
                    tempHTML += "<ul class='reply-list'>";
                      tempHTML += "<li class='rl-default'>";
                        tempHTML += "<div class='input-box'>";
                          tempHTML += "<textarea id='comment-reply-content-" + data.comments[i].id + "' placeholder='내용을 입력해주세요.'></textarea><button class='reply-button' onclick=writeCommentReply('" + data.comments[i].id + "','user');>등록</button>";
                          tempHTML += "<input type='hidden' id='comment-reply-row-" + data.comments[i].id + "' value='10'/>";
                        tempHTML += "</div>";
                      tempHTML += "</li>";
                    tempHTML += "</ul>";
                  tempHTML += "</s:authorize>";
                  tempHTML += "<s:authorize access='!isAuthenticated()'>";
                    tempHTML += "<ul class='reply-list'>";
                      tempHTML += "<li class='rl-default'>";
                        tempHTML += "<div class='input-box non'>";
                          tempHTML += "<div class='input'>";
                            tempHTML += "<input type='text' id='comment-reply-nickname-" + data.comments[i].id + "' placeholder='닉네임을 입력해주세요.'/>";
                          tempHTML += "</div>";
                          tempHTML += "<div class='input'>";
                            tempHTML += "<input type='password' id='comment-reply-password-" + data.comments[i].id + "' placeholder='비밀번호를 입력해주세요.'/>";
                          tempHTML += "</div>";
                        tempHTML += "</div>";
                        tempHTML += "<div class='input-box'>";
                          tempHTML += "<textarea id='comment-reply-content-" + data.comments[i].id + "' placeholder='내용을 입력해주세요.'></textarea><button class='reply-button' onclick=writeCommentReply('" + data.comments[i].id + "','non');>등록</button>";
                          tempHTML += "<input type='hidden' id='comment-reply-row-" + data.comments[i].id + "' value='10'/>";
                        tempHTML += "</div>";
                      tempHTML += "</li>";
                    tempHTML += "</ul>";
                  tempHTML += "</s:authorize>";
                  tempHTML += "</li>";
                  tempHTML += "<input type='hidden' id='comment-status-" + data.comments[i].id + "' value='" + data.comments[i].status + "'/>";
                tempHTML += "</ul>";
              } else {
                if(data.comments[i].replyCount != 0) {
                  tempHTML += "<ul class='comment-list animated tdFadeIn'>";
                    tempHTML += "<li id='cl-default-" + data.comments[i].id + "' class='cl-default'>";
                      tempHTML += "<div class='comment-box'>";
                        tempHTML += "<div class='comment-delete'>사용자의 요청에 의해 삭제된 댓글입니다.</div>";
                        tempHTML += "<div class='comment-function'>";
                          tempHTML += "<div class='reply-box'>";
                            tempHTML += "<div class='reply-button' onclick='replyOn(" + data.comments[i].id + ")'>답글(<span id='reply-count-" + data.comments[i].id + "'>" + countFormat(data.comments[i].replyCount) + "</span>)</div>";
                            tempHTML += "<input type='hidden' id='comment-reply-row-" + data.comments[i].id + "' value='10'/>";
                            tempHTML += "<input type='hidden' id='comment-status-" + data.comments[i].id + "' value='" + data.comments[i].status + "'/>";
                          tempHTML += "</div>";
                          tempHTML += "<div class='recommend-box'>";
                            tempHTML += "<div class='up'><i class='far fa-thumbs-up'></i> <span>" + countFormat(data.comments[i].up) + "</span></div>";
                            tempHTML += "<div class='down'><i class='far fa-thumbs-down'></i> <span>" + countFormat(data.comments[i].down) + "</span></div>";
                          tempHTML += "</div>";
                        tempHTML += "</div>";
                      tempHTML += "</div>";
                    tempHTML += "</li>";
                    tempHTML += "<li id='reply-list-box-" + data.comments[i].id + "' class='reply-list-box'>";
                    tempHTML += "</li>";
                  tempHTML += "</ul>";
                }
              }
          }
          if(countFlag) {
            $("#list-type-box").css("display", "flex");
            $("#comment-pagination-inner-box").css("display", "block");
          }
          $("#comment-list-box").html(tempHTML);
          $(".comment-content .image img").addClass("img-fluid");
          tempHTML = "";
          tempHTML += "<ul class='pagination-list'>";
          if(data.pagination.startPage > data.pagination.pageBlock) {
            tempHTML += "<li class='pt-default' onclick='selectComment(" + (data.pagination.startPage - data.pagination.pageBlock) + ");'><i class='fas fa-chevron-left'></i></li>"; 
          }
          for(var i=data.pagination.startPage; i<=data.pagination.endPage; i++) {
            if(i == data.pagination.page) {
              tempHTML += "<li class='pt-default active'>" + i + "</li>";
              $("#comment-page").val(i);
            } else {
              tempHTML += "<li class='pt-default' onclick='selectComment(" + i + ");'>" + i + "</li>";
            }
          }
          if(data.pagination.endPage < data.pagination.pageCount) {
            tempHTML += "<li class='pt-default' onclick='selectComment(" + (data.pagination.startPage + data.pagination.pageBlock) + ");'><i class='fas fa-chevron-right'></i></li>"; 
          }
          tempHTML += "</ul>";
          $("#comment-pagination-inner-box").html(tempHTML);
        } else if(listType == "popular" && data.count == 0) {
          var tempHTML = "";
          tempHTML += "<ul class='comment-list animated tdFadeIn'>";
            tempHTML += "<li class='cl-default empty-comment'>";
              tempHTML += "<div class='comment-box'>";
                tempHTML += "<div class='info-circle'>";
                  tempHTML += "<i class='fas fa-comment-alt fa-2x'></i>";
                tempHTML += "</div>";
                tempHTML += "<div class='text'>";
                  tempHTML += "인기 댓글이 없습니다.";
                tempHTML += "</div>";
              tempHTML += "</div>";
            tempHTML += "</li>";
          tempHTML += "</ul>";
          $("#comment-list-box").html(tempHTML);
          /* $("#list-type-box").css("display", "none"); */
          $("#comment-pagination-inner-box").css("display", "none");
        } else {
          var tempHTML = "";
          if(data.status == "Fail") {
            modalToggle("#modal-type-4", "오류", "알 수 없는 오류입니다.");
          }
          $("#comment-list-box").html(tempHTML);
          $("#list-type-box").css("display", "none");
          $("#comment-pagination-inner-box").css("display", "none");
        }
      }
    },
    error: function() {
      modalToggle("#modal-type-4", "오류", "알 수 없는 오류입니다.");
    },
    complete: function() {
      $("#comment-spinner").removeClass("on");
    }
  });
}
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/webapp/WEB-INF/views/community/combine/combine_view.jsp">combine_view.jsp</a>
</pre>
## CommunityController
```java
@Inject
private CommunityService communityService;
  
private final int COMMENT_PAGEBLOCK = 5;
private final int COMMENT_POPULAR_ORDER = 20;

// 통합 게시판 글 댓글 목록
@PostMapping("/combine/comment/list")
public @ResponseBody CommentsDTO combineBoardWriteCommentList(int combineBoardId,
  HttpServletRequest request,
  @RequestParam(value = "listType", defaultValue = "new") String listType,
  @RequestParam(value = "page", defaultValue = "1") int page,
  @RequestParam(value = "row", defaultValue = "15") int row) {
		
  CommentsDTO boardComment = new CommentsDTO();
		
  try {
    Map<String, String> map = new HashMap<>();
    map.put("combine_board_id", String.valueOf(combineBoardId));
    map.put("currPage", String.valueOf(page));
    map.put("page", String.valueOf((page-1)*row));
    map.put("row", String.valueOf(row));
    map.put("pageBlock", String.valueOf(COMMENT_PAGEBLOCK));
    map.put("listType", listType);
    map.put("order", String.valueOf(COMMENT_POPULAR_ORDER));
			
    Integer userId = request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id");
    String ip = request.getRemoteAddr();
			
    map.put("user_id", String.valueOf(userId));
    map.put("ip", ip);
			
    boardComment = communityService.selectCombineBoardWriteCommentListByMap(map); // 댓글 목록
  } catch (Exception e) {
    boardComment.setStatus("Fail");
    throw new ResponseBodyException(e);
  }
		
  return boardComment;
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
public CommentsDTO selectCombineBoardWriteCommentListByMap(Map<String, String> map) throws Exception { // 통합 게시판 글의 댓글 목록
		
  CommentsDTO combineComment = new CommentsDTO();
		
  // 댓글 목록
  combineComment.setComments(dao.selectCombineBoardWriteCommentListByMap(map));
		
  // 댓글이 존재한다면
  if(combineComment.getComments() != null && combineComment.getComments().size() != 0) {
    int listCount = dao.selectCombineBoardWriteCommentCountByMap(map);
			
    PaginationDTO pagination = new PaginationDTO(Integer.parseInt(map.get("pageBlock")), listCount, Integer.parseInt(map.get("currPage")), Integer.parseInt(map.get("row")));
    combineComment.setPagination(pagination);
		
    combineComment.setCount(combineComment.getComments().size());
			
    int charCount = 0;
      for(int i=0; i<combineComment.getCount(); i++) { // 회원 IP 치환
        for(int j=0; j<combineComment.getComments().get(i).getIp().length(); j++) {
          if(combineComment.getComments().get(i).getIp().charAt(j) == '.') {
            charCount += 1;
          }
					
          if(charCount == 2) {
            charCount = 0;
            combineComment.getComments().get(i).setIp(combineComment.getComments().get(i).getIp().substring(0, j));
            break;
          }
        }
      }
    }
		
  combineComment.setStatus("Success");
		
  return combineComment;
}
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/service/CommunityServiceImpl">CommunityServiceImpl.java</a>
</pre>
## CommunityMapper
```xml
<mapper namespace="community">
  <select id="selectCombineBoardWriteCommentListByMap" resultType="com.kjh.aps.domain.CommentDTO">
    <choose>
      <when test='listType != null and listType.equals("popular")'>
        SELECT brc_b_c_j_list.* FROM
          (SELECT
            @rownum:=@rownum+1 as no, brc_b_c_j.*
          FROM
            (SELECT
              brc_b_c.*
            FROM
              (SELECT
                c.id, c.combine_board_id, c.user_id, c.ip, c.nickname, c.profile, c.level, c.user_type userType, c.type comment_type, c.content, c.up, c.down, c.status, c.register_date,
                (SELECT count(id) FROM combine_board_comment_reply WHERE combine_board_comment_id = c.id AND status = 1) replyCount,
                (SELECT type FROM combine_board_comment_recommend_history WHERE combine_board_comment_id = c.id AND (user_id = #{user_id} OR ip = #{ip})) recommendType
              FROM
                combine_board_comment c) brc_b_c
            WHERE
              ((brc_b_c.combine_board_id = #{combine_board_id} AND brc_b_c.status = 1) AND ((brc_b_c.up - brc_b_c.down) >= #{order})) OR ((brc_b_c.combine_board_id = #{combine_board_id} AND brc_b_c.status = 0 AND brc_b_c.replyCount != 0) AND ((brc_b_c.up - brc_b_c.down) >= #{order})) ORDER BY (brc_b_c.up - brc_b_c.down) DESC) brc_b_c_j, (SELECT @rownum:=0) rownum) brc_b_c_j_list
        WHERE brc_b_c_j_list.no BETWEEN #{page} + 1 AND #{page} + #{row}
      </when>
      <otherwise>
        SELECT brc_b_c_j_list.* FROM
          (SELECT
            @rownum:=@rownum+1 as no, brc_b_c_j.*
          FROM
            (SELECT
              brc_b_c.*
            FROM
              (SELECT
                c.id, c.combine_board_id, c.user_id, c.ip, c.nickname, c.profile, c.level, c.user_type userType, c.type comment_type, c.content, c.up, c.down, c.status, c.register_date,
                (SELECT count(id) FROM combine_board_comment_reply WHERE combine_board_comment_id = c.id AND status = 1) replyCount,
                (SELECT type FROM combine_board_comment_recommend_history WHERE combine_board_comment_id = c.id AND (user_id = #{user_id} OR ip = #{ip})) recommendType
              FROM
                combine_board_comment c) brc_b_c
            WHERE
              (brc_b_c.combine_board_id = #{combine_board_id} AND brc_b_c.status = 1) OR (brc_b_c.combine_board_id = #{combine_board_id} AND brc_b_c.status = 0 AND brc_b_c.replyCount != 0) ORDER BY brc_b_c.id DESC) brc_b_c_j, (SELECT @rownum:=0) rownum) brc_b_c_j_list
        WHERE brc_b_c_j_list.no BETWEEN #{page} + 1 AND #{page} + #{row}
      </otherwise>
    </choose>
  </select>
  <select id="selectCombineBoardWriteCommentCountByMap" resultType="Integer">
    <choose>
      <when test='listType != null and listType.equals("popular")'>
        SELECT count(brc_cr.id) FROM
          (SELECT cr.*,
            (SELECT count(id) FROM combine_board_comment_reply WHERE combine_board_comment_id = cr.id AND status = 1) replyCount
          FROM
            combine_board_comment cr WHERE cr.combine_board_id = #{combine_board_id}) brc_cr
        WHERE ((brc_cr.status = 1) OR (brc_cr.status = 0 AND brc_cr.replyCount != 0)) AND (brc_cr.up - brc_cr.down) >= #{order}
      </when>
      <otherwise>
        SELECT count(brc_cr.id) FROM
          (SELECT cr.*,
            (SELECT count(id) FROM combine_board_comment_reply WHERE combine_board_comment_id = cr.id AND status = 1) replyCount
          FROM
            combine_board_comment cr WHERE cr.combine_board_id = #{combine_board_id}) brc_cr
        WHERE (brc_cr.status = 1) OR (brc_cr.status = 0 AND brc_cr.replyCount != 0)
      </otherwise>
    </choose>
  </select>
</mapper>
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/mapper/CommunityDAO.xml">CommunityDAO.xml</a>
</pre>
