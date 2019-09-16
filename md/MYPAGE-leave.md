## Demo
<img src="https://user-images.githubusercontent.com/47962660/64986389-e0218a80-d901-11e9-9674-43fa46daebb8.gif"/>

## MyPageController
```java
@Inject
private MyPageService mypageService;

// 회원탈퇴
@PostMapping("/leaveOk")
public String leaveOk(String policy, HttpServletRequest request) {

  String resultView = "confirm/error_400";
		
  if(policy != null && policy.equals("on")) {
    int id = request.getSession().getAttribute("id")==null? 0:(int)request.getSession().getAttribute("id");
    Map<String, String> map = new HashMap<>();
    map.put("id", String.valueOf(id));
    map.put("type", "leave");
			
    try {
      String result = mypageService.updateUserStatus(map);
				
      if(result.equals("Success")) {
        resultView = "confirm/leave_success";
      }
    } catch (Exception e) {
      throw new RuntimeException(e);
    }
  }
		
  return resultView;
}
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/controller/MyPageController.java">MyPageController.java</a>
</pre>
## MyPageServiceImpl
```java
@Inject
private MyPageDAO dao;

@Override
public String updateUserStatus(Map<String, String> map) throws Exception { // 회원 상태값 수정
		
  String result = "Fail";
		
  int successCount = dao.updateUserStatus(map);
		
  if(successCount == 1) {
    result = "Success";
  }
		
  return result;
}
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/service/MyPageServiceImpl.java">MyPageServiceImpl.java</a>
</pre>
## MyPageMapper
```xml
<mapper namespace="mypage">
  <update id="updateUserStatus">
    <choose>
      <when test='type != null and type.equals("leave")'>
        UPDATE user SET status = 3, delete_date = CURRENT_TIMESTAMP WHERE id = #{id}
      </when>
    </choose>
  </update>
</mapper>
```
## CommonServiceImpl
```java
@Inject
private CommonDAO dao;

private final int EXPIRE_DELETE_DAY = 30;
 
@Override
@Transactional(isolation=Isolation.READ_COMMITTED)
@Scheduled(cron="0 0 0 * * *")
public void deleteExpireUser() throws Exception { // 탈퇴 요청한 회원 중 보관 기한이 만료된 회원정보, 서비스 기록 등 영구삭제
  dao.deleteExpireUserBoardWriteCommentChildReply(EXPIRE_DELETE_DAY);
  dao.deleteExpireUserBoardWriteCommentReply(EXPIRE_DELETE_DAY);
  dao.deleteExpireUserBoardWriteCommentRecommendHistory(EXPIRE_DELETE_DAY);
  dao.deleteExpireUserBoardWriteComment(EXPIRE_DELETE_DAY);
  dao.deleteExpireUserBoardWriteChildRecommendHistory(EXPIRE_DELETE_DAY);
  dao.deleteExpireUserBoardWriteRecommendHistory(EXPIRE_DELETE_DAY);
  dao.deleteExpireUserBoardWrite(EXPIRE_DELETE_DAY);
		
  dao.deleteExpireUserBroadcasterReviewChildReply(EXPIRE_DELETE_DAY);
  dao.deleteExpireUserBroadcasterReviewReply(EXPIRE_DELETE_DAY);
  dao.deleteExpireUserBroadcasterReviewChildRecommendHistory(EXPIRE_DELETE_DAY);
  dao.deleteExpireUserBroadcasterReviewRecommendHistory(EXPIRE_DELETE_DAY);
  dao.deleteExpireUserBroadcasterReview(EXPIRE_DELETE_DAY);
		
  dao.deleteExpireUserCustomerServiceBoardWriteCommentChildReply(EXPIRE_DELETE_DAY);
  dao.deleteExpireUserCustomerServiceBoardWriteCommentReply(EXPIRE_DELETE_DAY);
  dao.deleteExpireUserCustomerServiceBoardWriteCommentChildRecommendHistory(EXPIRE_DELETE_DAY);
  dao.deleteExpireUserCustomerServiceBoardWriteCommentRecommendHistory(EXPIRE_DELETE_DAY);
  dao.deleteExpireUserCustomerServiceBoardWriteComment(EXPIRE_DELETE_DAY);
		
  dao.deleteExpireUserCombineBoardWriteCommentChildReply(EXPIRE_DELETE_DAY);
  dao.deleteExpireUserCombineBoardWriteCommentReply(EXPIRE_DELETE_DAY);
  dao.deleteExpireUserCombineBoardWriteCommentRecommendHistory(EXPIRE_DELETE_DAY);
  dao.deleteExpireUserCombineBoardWriteComment(EXPIRE_DELETE_DAY);
  dao.deleteExpireUserCombineBoardWriteChildRecommendHistory(EXPIRE_DELETE_DAY);
  dao.deleteExpireUserCombineBoardWriteRecommendHistory(EXPIRE_DELETE_DAY);
  dao.deleteExpireUserBoardWrite(EXPIRE_DELETE_DAY);
		
  dao.deleteExpireUserLog(EXPIRE_DELETE_DAY);
  dao.deleteExpireUserBan(EXPIRE_DELETE_DAY);
  dao.deleteExpireUserPush(EXPIRE_DELETE_DAY);
  dao.deleteExpireUser(EXPIRE_DELETE_DAY);
}
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/service/CommonServiceImpl.java">CommonServiceImpl.java</a>
</pre>
## CommonMapper
```xml
<mapper namespace="common">
  <delete id="deleteExpireUserBoardWriteCommentChildReply">
    DELETE FROM broadcaster_board_comment_reply WHERE broadcaster_board_comment_id IN (SELECT id FROM broadcaster_board_comment WHERE user_id IN (SELECT u.id FROM (SELECT id, datediff(delete_date, CURRENT_TIMESTAMP) datediff FROM user WHERE status = 3) u WHERE u.datediff >= #{param1}))
  </delete>
  <delete id="deleteExpireUserBoardWriteCommentReply">
    DELETE FROM broadcaster_board_comment_reply WHERE user_id IN (SELECT u.id FROM (SELECT id, datediff(delete_date, CURRENT_TIMESTAMP) datediff FROM user WHERE status = 3) u WHERE u.datediff >= #{param1})
  </delete>
  <delete id="deleteExpireUserBoardWriteCommentRecommendHistory">
    DELETE FROM broadcaster_board_comment_recommend_history WHERE user_id IN (SELECT u.id FROM (SELECT id, datediff(delete_date, CURRENT_TIMESTAMP) datediff FROM user WHERE status = 3) u WHERE u.datediff >= #{param1})
  </delete>
  <delete id="deleteExpireUserBoardWriteComment">
    DELETE FROM broadcaster_board_comment WHERE user_id IN (SELECT u.id FROM (SELECT id, datediff(delete_date, CURRENT_TIMESTAMP) datediff FROM user WHERE status = 3) u WHERE u.datediff >= #{param1})
  </delete>
  <delete id="deleteExpireUserBoardWriteChildRecommendHistory">
    DELETE FROM broadcaster_board_recommend_history WHERE broadcaster_board_id IN (SELECT id FROM broadcaster_board WHERE user_id IN (SELECT u.id FROM (SELECT id, datediff(delete_date, CURRENT_TIMESTAMP) datediff FROM user WHERE status = 3) u WHERE u.datediff >= #{param1}))
  </delete>
  <delete id="deleteExpireUserBoardWriteRecommendHistory">
    DELETE FROM broadcaster_board_recommend_history WHERE user_id IN (SELECT u.id FROM (SELECT id, datediff(delete_date, CURRENT_TIMESTAMP) datediff FROM user WHERE status = 3) u WHERE u.datediff >= #{param1})
  </delete>
  <delete id="deleteExpireUserBoardWrite">
    DELETE FROM broadcaster_board WHERE user_id IN (SELECT u.id FROM (SELECT id, datediff(delete_date, CURRENT_TIMESTAMP) datediff FROM user WHERE status = 3) u WHERE u.datediff >= #{param1})
  </delete>
  <delete id="deleteExpireUserBroadcasterReviewChildReply">
    DELETE FROM broadcaster_review_reply WHERE broadcaster_review_id IN (SELECT id FROM broadcaster_review WHERE user_id IN (SELECT u.id FROM (SELECT id, datediff(CURRENT_TIMESTAMP, delete_Date) datediff FROM user WHERE status = 3) u WHERE u.datediff >= #{param1}))
  </delete>
  <delete id="deleteExpireUserBroadcasterReviewReply">
    DELETE FROM broadcaster_review_reply WHERE user_id IN (SELECT u.id FROM (SELECT id, datediff(CURRENT_TIMESTAMP, delete_Date) datediff FROM user WHERE status = 3) u WHERE u.datediff >= #{param1})		
  </delete>
  <delete id="deleteExpireUserBroadcasterReviewChildRecommendHistory">
    DELETE FROM broadcaster_review_recommend_history WHERE broadcaster_review_id IN (SELECT id FROM broadcaster_review WHERE user_id IN (SELECT u.id FROM (SELECT id, datediff(CURRENT_TIMESTAMP, delete_Date) datediff FROM user WHERE status = 3) u WHERE u.datediff >= #{param1}))
  </delete>
  <delete id="deleteExpireUserBroadcasterReviewRecommendHistory">
    DELETE FROM broadcaster_review_recommend_history WHERE user_id IN (SELECT u.id FROM (SELECT id, datediff(CURRENT_TIMESTAMP, delete_Date) datediff FROM user WHERE status = 3) u WHERE u.datediff >= #{param1})
  </delete>
  <delete id="deleteExpireUserBroadcasterReview">
    DELETE FROM broadcaster_review WHERE user_id IN (SELECT u.id FROM (SELECT id, datediff(CURRENT_TIMESTAMP, delete_Date) datediff FROM user WHERE status = 3) u WHERE u.datediff >= #{param1})
  </delete>
  <delete id="deleteExpireUserCombineBoardWriteCommentChildReply">
    DELETE FROM combine_board_comment_reply WHERE combine_board_comment_id IN (SELECT id FROM combine_board_comment WHERE user_id IN (SELECT u.id FROM (SELECT id, datediff(delete_date, CURRENT_TIMESTAMP) datediff FROM user WHERE status = 3) u WHERE u.datediff >= #{param1}))
  </delete>
  <delete id="deleteExpireUserCombineBoardWriteCommentReply">
    DELETE FROM combine_board_comment_reply WHERE user_id IN (SELECT u.id FROM (SELECT id, datediff(delete_date, CURRENT_TIMESTAMP) datediff FROM user WHERE status = 3) u WHERE u.datediff >= #{param1})
  </delete>
  <delete id="deleteExpireUserCombineBoardWriteCommentRecommendHistory">
    DELETE FROM combine_board_comment_recommend_history WHERE user_id IN (SELECT u.id FROM (SELECT id, datediff(delete_date, CURRENT_TIMESTAMP) datediff FROM user WHERE status = 3) u WHERE u.datediff >= #{param1})
  </delete>
  <delete id="deleteExpireUserCombineBoardWriteComment">
    DELETE FROM combine_board_comment WHERE user_id IN (SELECT u.id FROM (SELECT id, datediff(delete_date, CURRENT_TIMESTAMP) datediff FROM user WHERE status = 3) u WHERE u.datediff >= #{param1})
  </delete>
  <delete id="deleteExpireUserCombineBoardWriteChildRecommendHistory">
    DELETE FROM combine_board_recommend_history WHERE combine_board_id IN (SELECT id FROM combine_board WHERE user_id IN (SELECT u.id FROM (SELECT id, datediff(delete_date, CURRENT_TIMESTAMP) datediff FROM user WHERE status = 3) u WHERE u.datediff >= #{param1}))
  </delete>
  <delete id="deleteExpireUserCombineBoardWriteRecommendHistory">
    DELETE FROM combine_board_recommend_history WHERE user_id IN (SELECT u.id FROM (SELECT id, datediff(delete_date, CURRENT_TIMESTAMP) datediff FROM user WHERE status = 3) u WHERE u.datediff >= #{param1})
  </delete>
  <delete id="deleteExpireUserCombineBoardWrite">
    DELETE FROM combine_board WHERE user_id IN (SELECT u.id FROM (SELECT id, datediff(delete_date, CURRENT_TIMESTAMP) datediff FROM user WHERE status = 3) u WHERE u.datediff >= #{param1})
  </delete>
  <delete id="deleteExpireUserBoardWrite">
    DELETE FROM broadcaster_board WHERE user_id IN (SELECT u.id FROM (SELECT id, datediff(delete_date, CURRENT_TIMESTAMP) datediff FROM user WHERE status = 3) u WHERE u.datediff >= #{param1})
  </delete>
  <delete id="deleteExpireUserLog">
    DELETE FROM user_log WHERE user_id IN (SELECT u.id FROM (SELECT id, datediff(delete_date, CURRENT_TIMESTAMP) datediff FROM user WHERE status = 3) u WHERE u.datediff >= #{param1})
  </delete>
  <delete id="deleteExpireUserBan">
    DELETE FROM user_ban WHERE user_id IN (SELECT u.id FROM (SELECT id, datediff(delete_date, CURRENT_TIMESTAMP) datediff FROM user WHERE status = 3) u WHERE u.datediff >= #{param1})
  </delete>
  <delete id="deleteExpireUserPush">
    DELETE FROM user_push WHERE user_id IN (SELECT u.id FROM (SELECT id, datediff(delete_date, CURRENT_TIMESTAMP) datediff FROM user WHERE status = 3) u WHERE u.datediff >= #{param1})
  </delete>
  <delete id="deleteExpireUser">
    DELETE FROM user WHERE id IN (SELECT u.id FROM (SELECT id, datediff(delete_date, CURRENT_TIMESTAMP) datediff FROM user WHERE status = 3) u WHERE u.datediff >= #{param1})
	</delete>
</mapper>
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/mapper/CommonDAO.xml">CommonDAO.xml</a>
</pre>
## CustomAuthenticationProvider
```java
public class CustomAuthenticationProvider implements AuthenticationProvider {

  @Inject
  private CustomUserDetailsService userDetailsService;
	
  @Override
  public Authentication authenticate(Authentication auth) throws AuthenticationException {

    String username = (String)auth.getPrincipal();
    String password = (String)auth.getCredentials();
		
    CustomUserDetails userDetails = (CustomUserDetails)userDetailsService.loadUserByUsername(username);
		
    PasswordEncoding passowrdEncoder = new PasswordEncoding();
		
    if(userDetails.getType() == 1 || userDetails.getType() == 10) { // APS 회원인 경우
      if(!passowrdEncoder.matches(password, userDetails.getPassword())) {
        throw new BadCredentialsException(username);
      }
    } else if(userDetails.getType() >= 2) { // 소셜 회원인 경우
      if(!password.equals(userDetails.getPassword())) {
        throw new BadCredentialsException(username);
      } else {
        userDetailsService.updateSocialUserPassword(userDetails.getId());
      }
    }
		
    if(userDetails.getStatus() == 3) { // 회원탈퇴 신청 회원이 30일 이내에 로그인 했다면
      LoginDAO dao = userDetailsService.getSqlSession().getMapper(LoginDAO.class);
      Map<String, String> map = new HashMap<>();
      map.put("id", String.valueOf(userDetails.getId()));
      map.put("type", "unlock");
      dao.updateUserStatus(map);
      throw new LockedException(username);
		}
		
    if(!userDetails.isEnabled()) { // 서비스 이용 정지된 회원
      throw new DisabledException(username);
    }
		
    UsernamePasswordAuthenticationToken token = new UsernamePasswordAuthenticationToken(username, password, userDetails.getAuthorities());
    token.setDetails(userDetails);
		
    return token;
  }

  @Override
  public boolean supports(Class<?> arg0) {
    return true;
  }

}
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/security/CustomAuthenticationProvider.java">CustomAuthenticationProvider.java</a>
</pre>
## LoginMapper
```xml
<mapper namespace="com.kjh.aps.persistent.LoginDAO">
  <update id="updateUserStatus">
    <choose>
      <when test='type != null and type.equals("unlock")'>
        UPDATE user SET enabled = 1, status = 1 WHERE id = #{id}
      </when>
    </choose>
  </update>
</mapper>
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/mapper/LoginDAO.xml">LoginDAO.xml</a>
</pre>
