## Demo
<h5>등록한 게시글, 댓글의 추천/비추천 수에 따라 레벨이 조정됩니다.</h5>
<img src="https://user-images.githubusercontent.com/47962660/64985328-95067800-d8ff-11e9-9683-b32aa165abca.gif"/>

## ServletContext
```xml
<!-- Interceptor -->
<beans:bean name="recommendInterceptor" class="com.kjh.aps.intercepter.RecommendInterceptor"/>
<interceptors>
  <interceptor>
    <mapping path="/community/board/recommend"/>
    <mapping path="/community/board/comment/recommend"/>
    <mapping path="/community/review/recommend"/>
    <mapping path="/community/combine/recommend"/>
    <mapping path="/community/combine/comment/recommend"/>
    <mapping path="/customerService/comment/recommend"/>
    <beans:ref bean="recommendInterceptor"/>
  </interceptor>
</interceptors>
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/webapp/WEB-INF/spring/appServlet/servlet-context.xml">ServletContext.xml</a>
</pre>
## RecommendInterceptor
```java
public class RecommendInterceptor extends HandlerInterceptorAdapter {

  @Inject
  private CommonService commonService;
	
  @Override
  public void postHandle(HttpServletRequest request, HttpServletResponse response, Object handler,
    ModelAndView modelAndView) throws Exception {
    String type = (String)request.getAttribute("type");
    int id = 0;
		
    Map<String, String> map = new HashMap<>();
		
    if(type != null) {
      if(type.equals("board")) {
        id = request.getAttribute("board_id")==null? 0:(Integer)request.getAttribute("board_id");
      } else if(type.equals("boardComment")) {
        id = request.getAttribute("board_comment_id")==null? 0:(Integer)request.getAttribute("board_comment_id");
      } else if(type.equals("reviewComment")) {
        id = request.getAttribute("review_id")==null? 0:(Integer)request.getAttribute("review_id");						
      } else if(type.equals("noticeComment")) {
        id = request.getAttribute("notice_comment_id")==null? 0:(Integer)request.getAttribute("notice_comment_id");
      } else if(type.equals("combineBoard")) {
        id = request.getAttribute("combine_board_id")==null? 0:(Integer)request.getAttribute("combine_board_id");
      } else if(type.equals("combineBoardComment")) {
        id = request.getAttribute("combine_board_comment_id")==null? 0:(Integer)request.getAttribute("combine_board_comment_id");
      }

      map.put("type", type);
      map.put("id", String.valueOf(id));
			
      commonService.updateUserLevel(map); // 받은 추천 수 종합에 따른 레벨 수정
    }
		
		super.postHandle(request, response, handler, modelAndView);
	}

}
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/intercepter/RecommendInterceptor.java">RecommendInterceptor.java</a>
</pre>
## CommonServiceImpl
```java
@Inject
private CommonDAO dao;
  
@Override
@Transactional(isolation=Isolation.READ_COMMITTED)
public void updateUserLevel(Map<String, String> map) throws Exception { // 회원 레벨 수정

  Map<String, Integer> maps = dao.selectUserRecommendCountByMap(map);
		
  if(maps != null) {
    Integer level = maps.get("level");
    Integer exp = Integer.parseInt(String.valueOf(maps.get("exp")));
	
    if(level != null && exp != null) {
      boolean levelUpdateFlag = false;
				
      if(((level * level) * LEVEL_UPDATE_STANDARD) <= exp) {
        map.put("updateType", "up");
        levelUpdateFlag = true;
      } else {
        if(level == 1) {
          if(level > exp) {
            map.put("updateType", "down");
            levelUpdateFlag = true;
          }
        } else {
          if(level != 0) {
            if((((level-1) * (level-1)) * LEVEL_UPDATE_STANDARD) > exp) {
              map.put("updateType", "down");
              levelUpdateFlag = true;
            }
          }
        }
      }
				
      if(levelUpdateFlag) {
        dao.updateUserLevel(map);
      }
    }
  }
}
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/service/CommonServiceImpl.java">CommonServiceImpl.java</a>
</pre>
## CommonMapper
```xml
<mapper namespace="common">
  <select id="selectUserRecommendCountByMap" resultType="HashMap">
    <choose>
      <when test='type != null and type.equals("board")'>
        SELECT
          sum(b.exp1 + b.exp2 + b.exp3 + b.exp4 + b.exp5 + b.exp6) exp, (SELECT level FROM user WHERE id = (SELECT user_id FROM broadcaster_board WHERE id = #{id})) level
        FROM
          (SELECT
            ifnull(sum(up-down), 0) exp1,
            (SELECT ifnull(sum(up-down), 0) FROM broadcaster_review WHERE user_id = (SELECT user_id FROM broadcaster_board WHERE id = #{id})) exp2,
            (SELECT ifnull(sum(up-down), 0) FROM broadcaster_board_comment WHERE user_id = (SELECT user_id FROM broadcaster_board WHERE id = #{id})) exp3,
            (SELECT ifnull(sum(up-down), 0) FROM notice_comment WHERE user_id = (SELECT user_id FROM broadcaster_board WHERE id = #{id})) exp4,
            (SELECT ifnull(sum(up-down), 0) FROM combine_board WHERE user_id = (SELECT user_id FROM broadcaster_board_comment WHERE id = #{id})) exp5,
            (SELECT ifnull(sum(up-down), 0) FROM combine_board_comment WHERE user_id = (SELECT user_id FROM broadcaster_board_comment WHERE id = #{id})) exp6
          FROM
            broadcaster_board
          WHERE user_id = (SELECT user_id FROM broadcaster_board WHERE id = #{id})) b
      </when>
      <when test='type != null and type.equals("boardComment")'>
        SELECT
          sum(b.exp1 + b.exp2 + b.exp3 + b.exp4 + b.exp5 + exp6) exp, (SELECT level FROM user WHERE id = (SELECT user_id FROM broadcaster_board_comment WHERE id = #{id})) level
        FROM
          (SELECT
            ifnull(sum(up-down), 0) exp1,
            (SELECT ifnull(sum(up-down), 0) FROM broadcaster_review WHERE user_id = (SELECT user_id FROM broadcaster_board_comment WHERE id = #{id})) exp2,
            (SELECT ifnull(sum(up-down), 0) FROM broadcaster_board_comment WHERE user_id = (SELECT user_id FROM broadcaster_board_comment WHERE id = #{id})) exp3,
            (SELECT ifnull(sum(up-down), 0) FROM notice_comment WHERE user_id = (SELECT user_id FROM broadcaster_board_comment WHERE id = #{id})) exp4,
            (SELECT ifnull(sum(up-down), 0) FROM combine_board WHERE user_id = (SELECT user_id FROM broadcaster_board_comment WHERE id = #{id})) exp5,
            (SELECT ifnull(sum(up-down), 0) FROM combine_board_comment WHERE user_id = (SELECT user_id FROM broadcaster_board_comment WHERE id = #{id})) exp6
          FROM
            broadcaster_board
          WHERE user_id = (SELECT user_id FROM broadcaster_board_comment WHERE id = #{id})) b
      </when>
      <when test='type != null and type.equals("reviewComment")'>
        SELECT
          sum(b.exp1 + b.exp2 + b.exp3 + b.exp4 + b.exp5 + b.exp6) exp, (SELECT level FROM user WHERE id = (SELECT user_id FROM broadcaster_review WHERE id = #{id})) level
        FROM
          (SELECT
            ifnull(sum(up-down), 0) exp1,
            (SELECT ifnull(sum(up-down), 0) FROM broadcaster_review WHERE user_id = (SELECT user_id FROM broadcaster_review WHERE id = #{id})) exp2,
            (SELECT ifnull(sum(up-down), 0) FROM broadcaster_board_comment WHERE user_id = (SELECT user_id FROM broadcaster_review WHERE id = #{id})) exp3,
            (SELECT ifnull(sum(up-down), 0) FROM notice_comment WHERE user_id = (SELECT user_id FROM broadcaster_review WHERE id = #{id})) exp4,
            (SELECT ifnull(sum(up-down), 0) FROM combine_board WHERE user_id = (SELECT user_id FROM broadcaster_review WHERE id = #{id})) exp5,
            (SELECT ifnull(sum(up-down), 0) FROM combine_board_comment WHERE user_id = (SELECT user_id FROM broadcaster_review WHERE id = #{id})) exp6
          FROM
            broadcaster_board
          WHERE user_id = (SELECT user_id FROM broadcaster_review WHERE id = #{id})) b
      </when>
      <when test='type != null and type.equals("noticeComment")'>
        SELECT
          sum(b.exp1 + b.exp2 + b.exp3 + b.exp4 + b.exp5 + b.exp6) exp, (SELECT level FROM user WHERE id = (SELECT user_id FROM notice_comment WHERE id = #{id})) level
        FROM
          (SELECT
            ifnull(sum(up-down), 0) exp1,
            (SELECT ifnull(sum(up-down), 0) FROM broadcaster_review WHERE user_id = (SELECT user_id FROM notice_comment WHERE id = #{id})) exp2,
            (SELECT ifnull(sum(up-down), 0) FROM broadcaster_board_comment WHERE user_id = (SELECT user_id FROM notice_comment WHERE id = #{id})) exp3,
            (SELECT ifnull(sum(up-down), 0) FROM notice_comment WHERE user_id = (SELECT user_id FROM notice_comment WHERE id = #{id})) exp4,
            (SELECT ifnull(sum(up-down), 0) FROM combine_board WHERE user_id = (SELECT user_id FROM notice_comment WHERE id = #{id})) exp5,
            (SELECT ifnull(sum(up-down), 0) FROM combine_board_comment WHERE user_id = (SELECT user_id FROM notice_comment WHERE id = #{id})) exp6
          FROM
            broadcaster_board
          WHERE user_id = (SELECT user_id FROM notice_comment WHERE id = #{id})) b
      </when>
      <when test='type != null and type.equals("combineBoard")'>
        SELECT
          sum(b.exp1 + b.exp2 + b.exp3 + b.exp4 + b.exp5 + b.exp6) exp, (SELECT level FROM user WHERE id = (SELECT user_id FROM combine_board WHERE id = #{id})) level
        FROM
          (SELECT
            ifnull(sum(up-down), 0) exp1,
            (SELECT ifnull(sum(up-down), 0) FROM broadcaster_review WHERE user_id = (SELECT ifnull(user_id, 0) FROM combine_board WHERE id = #{id})) exp2,
            (SELECT ifnull(sum(up-down), 0) FROM broadcaster_board_comment WHERE user_id = (SELECT ifnull(user_id, 0) FROM combine_board WHERE id = #{id})) exp3,
            (SELECT ifnull(sum(up-down), 0) FROM notice_comment WHERE user_id = (SELECT ifnull(user_id, 0) FROM combine_board WHERE id = #{id})) exp4,
            (SELECT ifnull(sum(up-down), 0) FROM combine_board WHERE user_id = (SELECT ifnull(user_id, 0) FROM combine_board WHERE id = #{id})) exp5,
            (SELECT ifnull(sum(up-down), 0) FROM combine_board_comment WHERE user_id = (SELECT ifnull(user_id, 0) FROM combine_board WHERE id = #{id})) exp6
          FROM
            broadcaster_board
          WHERE user_id = (SELECT user_id FROM combine_board WHERE id = #{id})) b
      </when>
      <when test='type != null and type.equals("combineBoardComment")'>
        SELECT
          sum(b.exp1 + b.exp2 + b.exp3 + b.exp4 + b.exp5 + b.exp6) exp, (SELECT level FROM user WHERE id = (SELECT user_id FROM combine_board_comment WHERE id = #{id})) level
        FROM
          (SELECT
            ifnull(sum(up-down), 0) exp1,
            (SELECT ifnull(sum(up-down), 0) FROM broadcaster_review WHERE user_id = (SELECT ifnull(user_id, 0) FROM combine_board_comment WHERE id = #{id})) exp2,
            (SELECT ifnull(sum(up-down), 0) FROM broadcaster_board_comment WHERE user_id = (SELECT ifnull(user_id, 0) FROM combine_board_comment WHERE id = #{id})) exp3,
            (SELECT ifnull(sum(up-down), 0) FROM notice_comment WHERE user_id = (SELECT ifnull(user_id, 0) FROM combine_board_comment WHERE id = #{id})) exp4,
            (SELECT ifnull(sum(up-down), 0) FROM combine_board WHERE user_id = (SELECT ifnull(user_id, 0) FROM combine_board_comment WHERE id = #{id})) exp5,
            (SELECT ifnull(sum(up-down), 0) FROM combine_board_comment WHERE user_id = (SELECT ifnull(user_id, 0) FROM combine_board_comment WHERE id = #{id})) exp6
          FROM
            broadcaster_board
          WHERE user_id = (SELECT ifnull(user_id, 0) FROM combine_board_comment WHERE id = #{id})) b
      </when>
    </choose>
  </select>
  <update id="updateUserLevel">
    <choose>
      <when test='updateType != null and updateType.equals("up")'>
        <choose>
          <when test='type != null and type.equals("board")'>
            UPDATE user SET level = level + 1 WHERE id = (SELECT user_id FROM broadcaster_board WHERE id = #{id})
          </when>
          <when test='type != null and type.equals("boardComment")'>
            UPDATE user SET level = level + 1 WHERE id = (SELECT user_id FROM broadcaster_board_comment WHERE id = #{id})
          </when>
          <when test='type != null and type.equals("reviewComment")'>
            UPDATE user SET level = level + 1 WHERE id = (SELECT user_id FROM broadcaster_review WHERE id = #{id})
          </when>
          <when test='type != null and type.equals("noticeComment")'>
            UPDATE user SET level = level + 1 WHERE id = (SELECT user_id FROM notice_comment WHERE id = #{id})
          </when>
          <when test='type != null and type.equals("combineBoard")'>
            UPDATE user SET level = level + 1 WHERE id = (SELECT user_id FROM combine_board WHERE id = #{id})
          </when>
          <when test='type != null and type.equals("combineBoardComment")'>
            UPDATE user SET level = level + 1 WHERE id = (SELECT user_id FROM combine_board_comment WHERE id = #{id})
          </when>
        </choose>
      </when>
      <when test='updateType != null and updateType.equals("down")'>
        <choose>
          <when test='type != null and type.equals("board")'>
            UPDATE user SET level = level - 1 WHERE id = (SELECT user_id FROM broadcaster_board WHERE id = #{id})
          </when>
          <when test='type != null and type.equals("boardComment")'>
            UPDATE user SET level = level - 1 WHERE id = (SELECT user_id FROM broadcaster_board_comment WHERE id = #{id})
          </when>
          <when test='type != null and type.equals("reviewComment")'>
            UPDATE user SET level = level - 1 WHERE id = (SELECT user_id FROM broadcaster_review WHERE id = #{id})
          </when>
          <when test='type != null and type.equals("noticeComment")'>
            UPDATE user SET level = level - 1 WHERE id = (SELECT user_id FROM notice_comment WHERE id = #{id})
          </when>
          <when test='type != null and type.equals("combineBoard")'>
            UPDATE user SET level = level + 1 WHERE id = (SELECT user_id FROM combine_board WHERE id = #{id})
          </when>
          <when test='type != null and type.equals("combineBoardComment")'>
            UPDATE user SET level = level + 1 WHERE id = (SELECT user_id FROM combine_board_comment WHERE id = #{id})
          </when>
        </choose>
      </when>
    </choose>
  </update>
</mapper>
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/mapper/CommonDAO.xml">CommonDAO.xml</a>
</pre>
