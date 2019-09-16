## Demo
<h5>등록된 평가를 일일/주간/월간, 최신/인기순으로 정렬할 수 있습니다.</h5>
<img src="https://user-images.githubusercontent.com/47962660/64969363-ba36be80-d8de-11e9-9eab-b28023f9ce0a.gif"/>

## Review(Client)
```javascript
function selectReview(page) {
  var listType1 = $("#list-type1").val();
  var listType2 = $("#list-type2").val();
  var broadcasterId = "${broadcaster.id}";
	
  $("#list-type-box").css("display", "none");
  $("#comment-pagination-inner-box").css("display", "none");
	
  if(page == null) {
    page = 1;
  }
	
  $("#comment-spinner").addClass("on");
  $("#comment-list-box").html("");
  setTimeout(function() {
  $.ajax({
    url: "${pageContext.request.contextPath}/community/review/list",
    type: "POST",
    cache: false,
    data: {
      "broadcasterId" : broadcasterId,
      "listType1" : listType1,
      "listType2" : listType2,
      "page" : page
    },
    beforeSend: function(xhr) {
      xhr.setRequestHeader(header, token);
    },
    success: function(data, status) {
      if(status == "success") {
        if(data.status == "Success" && data.count != 0) {
          var tempHTML = "";
          var countFlag = false;
          for(var i=0; i<data.count; i++) {
            if(data.comments[i].status == 1) {
              countFlag = true;
              tempHTML += "<ul class='comment-list animated tdFadeIn'>";
                tempHTML += "<li id='cl-default-" + data.comments[i].id + "' class='cl-default'>";
                  tempHTML += "<div class='comment-box'>";
                    tempHTML += "<div class='comment-title'>";
                      if(listType2 == "popular" && data.comments[i].no <= 3) {
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
                        tempHTML += "<div class='info-name'><span class='nickname'>" + data.comments[i].nickname + "</span><span class='level'>lv." + data.comments[i].level + "</span></div>";														
                      }
                        tempHTML += "<div class='info-regdate'>" + reviewDateFormat(data.comments[i].register_date) + "</div>";
                        tempHTML += "<div class='info-ip'>" + data.comments[i].ip + "</div>";
                      tempHTML += "</div>";
                      tempHTML += "<s:authorize access='isAuthenticated()'>";
                        if(data.comments[i].user_id == parseInt("${empty sessionScope.id? 0:sessionScope.id}")) {
                          tempHTML += "<div class='ellipsis' onclick=$('#comment-dropdown-" + data.comments[i].id + "').toggle();>";
                            tempHTML += "<i class='fas fa-ellipsis-v'>";
                              tempHTML += "<ul class='dropdown' id='comment-dropdown-" + data.comments[i].id + "'>";
                                  tempHTML += "<li class='dd-default' onclick=modifyReview('" + data.comments[i].id + "');><i class='fas fa-pen'></i></li>";
                                  tempHTML += "<li class='dd-default' onclick=deleteReview('" + data.comments[i].id + "');><i class='fas fa-trash'></i></li>";
                              tempHTML += "</ul>";
                            tempHTML += "</i>";
                          tempHTML += "</div>";
                        }
                      tempHTML += "</s:authorize>";
                    tempHTML += "</div>"
                    tempHTML += "<div class='comment-content'>";
                      tempHTML += "<span class='content'>" + data.comments[i].content.replace(/\n/g, "<br>") + "</span>";
                    tempHTML += "</div>";
                    tempHTML += "<div class='mobile-comment-info'>";
                      tempHTML += "<div class='mobile-info-regdate'>" + reviewDateFormat(data.comments[i].register_date) + "</div>";
                      tempHTML += "<div class='mobile-info-ip'>" + data.comments[i].ip + "</div>";
                    tempHTML += "</div>";
                    tempHTML += "<div class='comment-function'>";
                      tempHTML += "<div class='reply-box'>";
                        tempHTML += "<button class='reply-button' onclick='replyOn(" + data.comments[i].id + ")'>답글(<span id='reply-count-" + data.comments[i].id + "'>" + countFormat(data.comments[i].replyCount) + "</span>)</button>";
                        tempHTML += "<div class='gp'><i class='fas fa-star'></i> " + data.comments[i].gp + "</div>";
                      tempHTML += "</div>";
                      tempHTML += "<div class='recommend-box'>";
                        tempHTML += "<div class='up " + (data.comments[i].type==1? "active":"") + "' onclick=recommendReview('" + data.comments[i].id + "','up');><i class='far fa-thumbs-up'></i> <span id='comment-up-" + data.comments[i].id + "'>" + countFormat(data.comments[i].up) + "</span></div>";
                        tempHTML += "<div class='down " + (data.comments[i].type==2? "active":"") + "' onclick=recommendReview('" + data.comments[i].id + "','down');><i class='far fa-thumbs-down'></i> <span id='comment-down-" + data.comments[i].id + "'>" + countFormat(data.comments[i].down) + "</span></div>";
                      tempHTML += "</div>";
                    tempHTML += "</div>";
                  tempHTML += "</div>";
                tempHTML += "</li>";
                tempHTML += "<li id='reply-list-box-" + data.comments[i].id + "' class='reply-list-box'>";
                  tempHTML += "<s:authorize access='isAuthenticated()'>";
                    tempHTML += "<ul class='reply-list'>";
                      tempHTML += "<li class='rl-default'>";
                        tempHTML += "<div class='input-box'>";
                          tempHTML += "<textarea id='comment-reply-content-" + data.comments[i].id + "' placeholder='내용을 입력해주세요.'></textarea><button class='reply-button' onclick='writeReviewReply(" + data.comments[i].id + ");'>등록</button>";
                          tempHTML += "<input type='hidden' id='comment-reply-row-" + data.comments[i].id + "' value='10'/>";
                        tempHTML += "</div>";
                      tempHTML += "</li>";
                    tempHTML += "</ul>";
                  tempHTML += "</s:authorize>";
                  tempHTML += "<s:authorize access='!isAuthenticated()'>";
                    tempHTML += "<ul class='reply-list'>";
                      tempHTML += "<li class='rl-default'>";
                        tempHTML += "<div class='input-box'>";
                          tempHTML += "<div class='not-authenticated'>";
                            tempHTML += "<div class='info-circle'><i class='fas fa-info fa-2x'></i></div>";
                            tempHTML += "<div class='text'>답글을 등록하려면 로그인이 필요합니다.</div>";
                            tempHTML += "<input type='hidden' id='comment-reply-row-" + data.comments[i].id + "' value='10'/>";
                          tempHTML += "</div>";
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
                              tempHTML += "<div class='gp'><i class='fas fa-star'></i> " + data.comments[i].gp + "</div>";
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
            tempHTML = "";
            tempHTML += "<ul class='pagination-list'>";
            if(data.pagination.startPage > data.pagination.pageBlock) {
              tempHTML += "<li class='pt-default' onclick='selectReview(" + (data.pagination.startPage - data.pagination.pageBlock) + ");'><i class='fas fa-chevron-left'></i></li>"; 
            }
            for(var i=data.pagination.startPage; i<=data.pagination.endPage; i++) {
              if(i == data.pagination.page) {
                tempHTML += "<li class='pt-default active'>" + i + "</li>";
                $("#comment-page").val(i);
              } else {
                tempHTML += "<li class='pt-default' onclick='selectReview(" + i + ");'>" + i + "</li>";
              }
            }
            if(data.pagination.endPage < data.pagination.pageCount) {
              tempHTML += "<li class='pt-default' onclick='selectReview(" + (data.pagination.startPage + data.pagination.pageBlock) + ");'><i class='fas fa-chevron-right'></i></li>"; 
            }
            tempHTML += "</ul>";
            $("#comment-pagination-inner-box").html(tempHTML);
          } else {
            var tempHTML = "";
            tempHTML += "<ul class='comment-list animated tdFadeIn'>";
              tempHTML += "<li class='cl-default empty-comment'>";
                tempHTML += "<div class='comment-box'>";
                  tempHTML += "<div class='info-circle'>";
                    tempHTML += "<i class='fas fa-comment-alt fa-2x'></i>";
                  tempHTML += "</div>";
                  tempHTML += "<div class='text'>";
                    tempHTML += "등록된 평가가 없습니다.";
                  tempHTML += "</div>";
                tempHTML += "</div>";
              tempHTML += "</li>";
            tempHTML += "</ul>";
            $("#comment-list-box").html(tempHTML);
					  $("#comment-pagination-inner-box").css("display", "none");
          }
          $("#review-count").html(countFormat(data.reviewCount));
        }
      },
      error: function() {
        modalToggle("#modal-type-4", "오류", "알 수 없는 오류입니다.");
      },
      complete: function() {
        $("#comment-spinner").removeClass("on");
      }
    });
  }, 2000);
}
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/webapp/WEB-INF/views/community/review.jsp">review.jsp</a>
</pre>
## CommunityController
```java
@Inject
private CommunityService communityService;
  
// 방송인 민심평가 목록
@PostMapping("/review/list")
public @ResponseBody CommentsDTO reviewList(String broadcasterId,
  @RequestParam(value = "listType1", defaultValue = "today") String listType1,
  @RequestParam(value = "listType2", defaultValue = "new") String listType2,
  @RequestParam(value = "page", defaultValue = "1") int page,
  @RequestParam(value = "row", defaultValue = "15") int row,
  HttpServletRequest request) {
		
  CommentsDTO reviews = new CommentsDTO();
		
  if(broadcasterId != null && broadcasterId.length() != 0) {
    try {
      Map<String, String> map = new HashMap<>();
      map.put("broadcaster_id", broadcasterId);
      map.put("currPage", String.valueOf(page));
      map.put("page", String.valueOf((page-1)*row));
      map.put("row", String.valueOf(row));
      map.put("pageBlock", String.valueOf(COMMENT_PAGEBLOCK));
      map.put("listType1", listType1);
      map.put("listType2", listType2);
      map.put("order", String.valueOf(COMMENT_POPULAR_ORDER));
				
      Integer userId = request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id");
      String ip =  request.getSession().getAttribute("id")==null? "0":request.getRemoteAddr();
				
      map.put("user_id", String.valueOf(userId));
      map.put("ip", ip);
				
      reviews = communityService.selectBroadcasterReviewListByMap(map);
    } catch (Exception e) {
      reviews.setStatus("Fail");
      throw new ResponseBodyException(e);
    }
  }
		
  return reviews;
}
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/controller/CommunityController.java">CommunityControlle.java</a>
</pre>
## CommunityServiceImpl
```java
@Inject
private CommunityDAO dao;

@Override
@Transactional(readOnly = true)
public CommentsDTO selectBroadcasterReviewListByMap(Map<String, String> map) throws Exception { // 방송인 평가 목록
		
  CommentsDTO reviews = new CommentsDTO();
  String listType1 = map.get("listType1");

  if(listType1.equals("today")) {
    Calendar today = Calendar.getInstance(timezone);
    map.put("today", sdf.format(today.getTime()));
  } else if(listType1.equals("week")) {
    Calendar startDay = Calendar.getInstance(timezone); // 이번 주의 시작
    Calendar endDay = Calendar.getInstance(timezone); // 이번 주의 끝

    startDay.add(Calendar.DATE, -startDay.get(Calendar.DAY_OF_WEEK) + 1);
    endDay.set(Calendar.DAY_OF_WEEK, Calendar.SUNDAY);
    endDay.add(Calendar.DATE, 7);

    map.put("startDay", sdf.format(startDay.getTime()));
    map.put("endDay", sdf.format(endDay.getTime()));
  } else if(listType1.equals("month")) {
    Calendar month = Calendar.getInstance(timezone);
    map.put("month", sdf.format(month.getTime()));
  }
		
  reviews.setComments(dao.selectBroadcasterReviewListByMap(map));
		
  if(reviews.getComments() != null && reviews.getComments().size() != 0) {
    reviews.setCount(reviews.getComments().size());
    reviews.setReviewCount(dao.selectBroadcasterReviewCount(map));
			
    int listCount = dao.selectBroadcasterReviewListCountByMap(map);

    PaginationDTO pagination = new PaginationDTO(Integer.parseInt(map.get("pageBlock")), listCount, Integer.parseInt(map.get("currPage")), Integer.parseInt(map.get("row")));
    reviews.setPagination(pagination);
			
    int charCount = 0;
    for(int i=0; i<reviews.getCount(); i++) { // 회원 IP 치환
      for(int j=0; j<reviews.getComments().get(i).getIp().length(); j++) {
        if(reviews.getComments().get(i).getIp().charAt(j) == '.') {
          charCount += 1;
        }
					
        if(charCount == 2) {
          charCount = 0;
          reviews.getComments().get(i).setIp(reviews.getComments().get(i).getIp().substring(0, j));
          break;
        }
      }
    }
  }

  reviews.setStatus("Success");
		
  return reviews;
}
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/service/CommunityServiceImpl.java">CommunityServiceImpl.java</a>
</pre>
## CommunityMapper
```xml
<mapper namespace="community">
  <select id="selectBroadcasterReviewListByMap" resultType="com.kjh.aps.domain.CommentDTO">
    <choose>
      <when test='listType1 != null and listType2 != null and listType1.equals("today") and listType2.equals("new")'>
        SELECT brc_b_c_j_list.* FROM
          (SELECT
            @rownum:=@rownum+1 as no, brc_b_c_j.*
          FROM
            (SELECT
              brc_b_c.*
            FROM
              (SELECT
                c.*, u.nickname as nickname, u.level as level, u.profile as profile, u.type as userType,
                (SELECT count(id) FROM broadcaster_review_reply WHERE broadcaster_review_id = c.id AND status = 1) replyCount,
                (SELECT b.type FROM (SELECT * FROM broadcaster_review_recommend_history WHERE broadcaster_id = #{broadcaster_id}) b WHERE b.broadcaster_review_id = c.id AND (b.user_id = #{user_id} OR b.ip = #{ip})) type
              FROM
                broadcaster_review c INNER JOIN user u ON c.user_id = u.id) brc_b_c
            WHERE
              (brc_b_c.broadcaster_id = #{broadcaster_id} AND brc_b_c.status = 1 AND DATE_FORMAT(brc_b_c.register_date, '%Y-%m-%d') = DATE_FORMAT(#{today}, '%Y-%m-%d')) OR (brc_b_c.broadcaster_id = #{broadcaster_id} AND brc_b_c.status = 0 AND brc_b_c.replyCount != 0 AND DATE_FORMAT(brc_b_c.register_date, '%Y-%m-%d') = DATE_FORMAT(#{today}, '%Y-%m-%d')) ORDER BY brc_b_c.id DESC) brc_b_c_j, (SELECT @rownum:=0) rownum) brc_b_c_j_list
        WHERE brc_b_c_j_list.no BETWEEN #{page} + 1 AND #{page} + #{row}
      </when>
      <when test='listType1 != null and listType2 != null and listType1.equals("today") and listType2.equals("popular")'>
        SELECT brc_b_c_j_list.* FROM
          (SELECT
            @rownum:=@rownum+1 as no, brc_b_c_j.*
          FROM
            (SELECT
              brc_b_c.*
            FROM
              (SELECT
                c.*, u.nickname as nickname, u.level as level, u.profile as profile, u.type as userType,
                (SELECT count(id) FROM broadcaster_review_reply WHERE broadcaster_review_id = c.id AND status = 1) replyCount,
                (SELECT b.type FROM (SELECT * FROM broadcaster_review_recommend_history WHERE broadcaster_id = #{broadcaster_id}) b WHERE b.broadcaster_review_id = c.id AND (b.user_id = #{user_id} OR b.ip = #{ip})) type
              FROM
                broadcaster_review c INNER JOIN user u ON c.user_id = u.id) brc_b_c
            WHERE
                (brc_b_c.broadcaster_id = #{broadcaster_id} AND brc_b_c.status = 1 AND DATE_FORMAT(brc_b_c.register_date, '%Y-%m-%d') = DATE_FORMAT(#{today}, '%Y-%m-%d') AND (brc_b_c.up - brc_b_c.down) >= #{order}) OR (brc_b_c.broadcaster_id = #{broadcaster_id} AND brc_b_c.status = 0 AND brc_b_c.replyCount != 0 AND DATE_FORMAT(brc_b_c.register_date, '%Y-%m-%d') = DATE_FORMAT(#{today}, '%Y-%m-%d')) ORDER BY (brc_b_c.up - brc_b_c.down) >= #{order} DESC) brc_b_c_j, (SELECT @rownum:=0) rownum) brc_b_c_j_list
        WHERE brc_b_c_j_list.no BETWEEN #{page} + 1 AND #{page} + #{row}
      </when>
      <when test='listType1 != null and listType2 != null and listType1.equals("week") and listType2.equals("new")'>
        SELECT brc_b_c_j_list.* FROM
          (SELECT
            @rownum:=@rownum+1 as no, brc_b_c_j.*
          FROM
            (SELECT
              brc_b_c.*
            FROM
              (SELECT
                c.*, u.nickname as nickname, u.level as level, u.profile as profile, u.type as userType,
                (SELECT count(id) FROM broadcaster_review_reply WHERE broadcaster_review_id = c.id AND status = 1) replyCount,
                (SELECT b.type FROM (SELECT * FROM broadcaster_review_recommend_history WHERE broadcaster_id = #{broadcaster_id}) b WHERE b.broadcaster_review_id = c.id AND (b.user_id = #{user_id} OR b.ip = #{ip})) type
              FROM
                broadcaster_review c INNER JOIN user u ON c.user_id = u.id) brc_b_c
            WHERE
              (brc_b_c.broadcaster_id = #{broadcaster_id} AND brc_b_c.status = 1 AND DATE_FORMAT(brc_b_c.register_date, '%Y-%m-%d') BETWEEN DATE_FORMAT(#{startDay}, '%Y-%m-%d') AND DATE_FORMAT(#{endDay}, '%Y-%m-%d')) OR (brc_b_c.broadcaster_id = #{broadcaster_id} AND brc_b_c.status = 0 AND brc_b_c.replyCount != 0 AND DATE_FORMAT(brc_b_c.register_date, '%Y-%m-%d') BETWEEN DATE_FORMAT(#{startDay}, '%Y-%m-%d') AND DATE_FORMAT(#{endDay}, '%Y-%m-%d')) ORDER BY brc_b_c.id DESC) brc_b_c_j, (SELECT @rownum:=0) rownum) brc_b_c_j_list
        WHERE brc_b_c_j_list.no BETWEEN #{page} + 1 AND #{page} + #{row}
      </when>
      <when test='listType1 != null and listType2 != null and listType1.equals("week") and listType2.equals("popular")'>
        SELECT brc_b_c_j_list.* FROM
          (SELECT
            @rownum:=@rownum+1 as no, brc_b_c_j.*
          FROM
            (SELECT
              brc_b_c.*
            FROM
              (SELECT
                c.*, u.nickname as nickname, u.level as level, u.profile as profile, u.type as userType,
                (SELECT count(id) FROM broadcaster_review_reply WHERE broadcaster_review_id = c.id AND status = 1) replyCount,
                (SELECT b.type FROM (SELECT * FROM broadcaster_review_recommend_history WHERE broadcaster_id = #{broadcaster_id}) b WHERE b.broadcaster_review_id = c.id AND (b.user_id = #{user_id} OR b.ip = #{ip})) type
              FROM
                broadcaster_review c INNER JOIN user u ON c.user_id = u.id) brc_b_c
            WHERE
              (brc_b_c.broadcaster_id = #{broadcaster_id} AND brc_b_c.status = 1 AND DATE_FORMAT(brc_b_c.register_date, '%Y-%m-%d') BETWEEN DATE_FORMAT(#{startDay}, '%Y-%m-%d') AND DATE_FORMAT(#{endDay}, '%Y-%m-%d') AND (brc_b_c.up - brc_b_c.down) >= #{order}) OR (brc_b_c.broadcaster_id = #{broadcaster_id} AND brc_b_c.status = 0 AND brc_b_c.replyCount != 0 AND DATE_FORMAT(brc_b_c.register_date, '%Y-%m-%d') BETWEEN DATE_FORMAT(#{startDay}, '%Y-%m-%d') AND DATE_FORMAT(#{endDay}, '%Y-%m-%d')) ORDER BY (brc_b_c.up - brc_b_c.down) >= #{order} DESC) brc_b_c_j, (SELECT @rownum:=0) rownum) brc_b_c_j_list
        WHERE brc_b_c_j_list.no BETWEEN #{page} + 1 AND #{page} + #{row}
      </when>
      <when test='listType1 != null and listType2 != null and listType1.equals("month") and listType2.equals("new")'>
        SELECT brc_b_c_j_list.* FROM
          (SELECT
            @rownum:=@rownum+1 as no, brc_b_c_j.*
          FROM
            (SELECT
              brc_b_c.*
            FROM
              (SELECT
                c.*, u.nickname as nickname, u.level as level, u.profile as profile, u.type as userType,
                (SELECT count(id) FROM broadcaster_review_reply WHERE broadcaster_review_id = c.id AND status = 1) replyCount,
                (SELECT b.type FROM (SELECT * FROM broadcaster_review_recommend_history WHERE broadcaster_id = #{broadcaster_id}) b WHERE b.broadcaster_review_id = c.id AND (b.user_id = #{user_id} OR b.ip = #{ip})) type
              FROM
                broadcaster_review c INNER JOIN user u ON c.user_id = u.id) brc_b_c
            WHERE
              (brc_b_c.broadcaster_id = #{broadcaster_id} AND brc_b_c.status = 1 AND DATE_FORMAT(brc_b_c.register_date, '%Y-%m') = DATE_FORMAT(#{month}, '%Y-%m')) OR (brc_b_c.broadcaster_id = #{broadcaster_id} AND brc_b_c.status = 0 AND brc_b_c.replyCount != 0 AND DATE_FORMAT(brc_b_c.register_date, '%Y-%m') = DATE_FORMAT(#{month}, '%Y-%m')) ORDER BY brc_b_c.id DESC) brc_b_c_j, (SELECT @rownum:=0) rownum) brc_b_c_j_list
        WHERE brc_b_c_j_list.no BETWEEN #{page} + 1 AND #{page} + #{row}
      </when>
      <when test='listType1 != null and listType2 != null and listType1.equals("month") and listType2.equals("popular")'>
        SELECT brc_b_c_j_list.* FROM
          (SELECT
            @rownum:=@rownum+1 as no, brc_b_c_j.*
          FROM
            (SELECT
              brc_b_c.*
            FROM
              (SELECT
                c.*, u.nickname as nickname, u.level as level, u.profile as profile, u.type as userType,
                (SELECT count(id) FROM broadcaster_review_reply WHERE broadcaster_review_id = c.id AND status = 1) replyCount,
                (SELECT b.type FROM (SELECT * FROM broadcaster_review_recommend_history WHERE broadcaster_id = #{broadcaster_id}) b WHERE b.broadcaster_review_id = c.id AND (b.user_id = #{user_id} OR b.ip = #{ip})) type
              FROM
                broadcaster_review c INNER JOIN user u ON c.user_id = u.id) brc_b_c
            WHERE
              (brc_b_c.broadcaster_id = #{broadcaster_id} AND brc_b_c.status = 1 AND DATE_FORMAT(brc_b_c.register_date, '%Y-%m') = DATE_FORMAT(#{month}, '%Y-%m') AND (brc_b_c.up - brc_b_c.down) >= #{order}) OR (brc_b_c.broadcaster_id = #{broadcaster_id} AND brc_b_c.status = 0 AND brc_b_c.replyCount != 0 AND DATE_FORMAT(brc_b_c.register_date, '%Y-%m') = DATE_FORMAT(#{month}, '%Y-%m')) ORDER BY (brc_b_c.up - brc_b_c.down) >= #{order} DESC) brc_b_c_j, (SELECT @rownum:=0) rownum) brc_b_c_j_list
        WHERE brc_b_c_j_list.no BETWEEN #{page} + 1 AND #{page} + #{row}
      </when>
    </choose>
  </select>
</mapper>
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/mapper/CommunityDAO.xml">CommunityDAO.xml</a>
</pre>
