## Demo
<img src="https://user-images.githubusercontent.com/47962660/64924783-34097200-d823-11e9-8ffe-6c06e37c42f1.gif"/>

## Login(Client)
```javascript
// 로그인 유효성 검사
function validLogin(obj) {
  var username = obj["username"].value;
  var password = obj["password"].value;
	
  if(username == null || username.length == 0) {
    modalToggle("#modal-type-1", "안내", "아이디를 입력해주세요.");
    return false;
  }
  if(password == null || password.length == 0) {
    modalToggle("#modal-type-1", "안내", "비밀번호를 입력해주세요.");
    return false;
  }
}
```
```html
<form id="loginForm" action="<c:url value='/loginOk'/>" method="post" onsubmit="return validLogin(this);">
  <div class="input-box">
    <input type="text" id="username" name="username" placeholder="아이디" autocomplete="off"/>
  </div>
  <div class="input-box">
    <input type="password" id="password" name="password" placeholder="비밀번호" autocomplete="off"/>
  </div>
  <div class="input-box">
    <button class="aps-button">로그인</button>
	</div>
  <s:csrfInput/>
</form>
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/webapp/WEB-INF/views/login/login.jsp">login.jsp</a>
</pre>
## SecurityContext
```xml
  <context:property-placeholder
  location="classpath:db.properties"/>

  <security:http use-expressions="true">
    <security:form-login login-page="/login"
    username-parameter="username"
    password-parameter="password"
    login-processing-url="/loginOk"
    authentication-failure-handler-ref="customAuthenticationFailureHandler"
    authentication-success-handler-ref="customAuthenticationSuccessHandler"
    default-target-url="/"
    />
    <security:intercept-url pattern="/" requires-channel="https" access="permitAll"/>
    <security:intercept-url pattern="/mypage/**" access="hasAnyRole('ROLE_USER', 'ROLE_ADMIN')"/>
    <security:intercept-url pattern="/community/board/write" access="hasAnyRole('ROLE_USER', 'ROLE_ADMIN')"/>
    <security:intercept-url pattern="/community/board/writeOk" access="hasAnyRole('ROLE_USER', 'ROLE_ADMIN')"/>
    <security:intercept-url pattern="/community/board/modify/**" access="hasAnyRole('ROLE_USER', 'ROLE_ADMIN')"/>
    <security:intercept-url pattern="/community/board/modifyOk" access="hasAnyRole('ROLE_USER', 'ROLE_ADMIN')"/>
    <security:intercept-url pattern="/community/board/deleteOk" access="hasAnyRole('ROLE_USER', 'ROLE_ADMIN')"/>
    <security:intercept-url pattern="/customerService/write" access="hasRole('ROLE_ADMIN')"/>
    <security:intercept-url pattern="/customerService/writeOk" access="hasRole('ROLE_ADMIN')"/>
    <security:intercept-url pattern="/customerService/modify" access="hasRole('ROLE_ADMIN')"/>
    <security:intercept-url pattern="/customerService/modifyOk" access="hasRole('ROLE_ADMIN')"/>
    <security:intercept-url pattern="/customerService/deleteOk" access="hasRole('ROLE_ADMIN')"/>
    <security:logout logout-url="/logout" logout-success-url="/login" invalidate-session="true"/>
    <security:access-denied-handler error-page="/access_denied"/>
    <security:session-management>
      <security:concurrency-control max-sessions="1" expired-url="/expired_login"/>
    </security:session-management>
  </security:http>

  <security:authentication-manager>
    <security:authentication-provider ref="customAuthenticationProvider"/>
    <security:authentication-provider user-service-ref="customUserDetailService"/>
  </security:authentication-manager>
	
  <security:http-firewall ref="customLoggingHttpFirewall"/>
	
  <bean name="customAuthenticationProvider" class="com.kjh.aps.security.CustomAuthenticationProvider"/>
  <bean name="customUserDetailService" class="com.kjh.aps.security.CustomUserDetailsService"/>
  <bean name="customAuthenticationFailureHandler" class="com.kjh.aps.security.CustomAuthenticationFailureHandler"/>
  <bean name="customAuthenticationSuccessHandler" class="com.kjh.aps.security.CustomAuthenticationSuccessHandler"/>
  <bean name="customLoggingHttpFirewall" class="com.kjh.aps.security.CustomLoggingHttpFirewall"/>
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/webapp/WEB-INF/spring/appServlet/security-context.xml">SecurityContext.xml</a>
</pre>
## LoginController
```java
@Inject
private NaverLoginBO naverLoginBO;
@Inject
private GoogleLoginBO googleLoginBO;

// 로그인 페이지
@RequestMapping("")
public String login(HttpSession session, Model model) {

  String naverUrl = naverLoginBO.getAuthorizationUrl(session);
  String googleUrl = googleLoginBO.getAuthorizationUrl();
		
  model.addAttribute("naverUrl", naverUrl);		
  model.addAttribute("googleUrl", googleUrl);		
  return "login/login";
}
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/controller/LoginController.java">LoginController.java</a>
</pre>
## CustomUserDetailService
```java
public class CustomUserDetailsService implements UserDetailsService {

  @Inject
  private SqlSession sqlSession;

  public SqlSession getSqlSession() {
    return sqlSession;
  }

  @Override
  public UserDetails loadUserByUsername(String arg0) throws UsernameNotFoundException {

    LoginDAO dao = sqlSession.getMapper(LoginDAO.class);

    CustomUserDetails userDetails = dao.selectUserByUsername(arg0);

    if(userDetails == null) {
      throw new InternalAuthenticationServiceException(arg0);
    } else {
      return userDetails;
    }

  }

  public void updateSocialUserPassword(int id) throws RuntimeException {
    Random ran = new Random();
    StringBuffer sb = new StringBuffer();
    int num = 0;

    do {
      num = ran.nextInt(75) + 48;

      if ((num >= 48 && num <= 57) || (num >= 65 && num <= 90) || (num >= 97 && num <= 122)) {
        sb.append((char) num);
      } else {
        continue;
      }
    } while (sb.length() < 20);
      Map<String, String> map = new HashMap<>();
      map.put("id", String.valueOf(id));
      map.put("password", "{noop}" + sb.toString());

      LoginDAO dao = sqlSession.getMapper(LoginDAO.class);
      dao.updateSocialUserPassword(map);
  }
}
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/security/CustomUserDetailsService.java">CustomUserDetailsService.java</a>
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
}
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/security/CustomAuthenticationProvider.java">CustomAuthenticationProvider.java</a>
</pre>
## CustomAuthenticationSuccessHandler
```java
public class CustomAuthenticationSuccessHandler implements AuthenticationSuccessHandler {

  @Inject
  private SqlSession sqlSession;

  private RequestCache requestCache = new HttpSessionRequestCache();
  private RedirectStrategy redirectStrategy = new DefaultRedirectStrategy();

  @Override
  public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response, Authentication auth)
    throws IOException, ServletException {

    CustomUserDetails userDetails = (CustomUserDetails)auth.getDetails();

    LoginDAO dao = sqlSession.getMapper(LoginDAO.class);
    Map<String, String> map = new HashMap<>();
    map.put("user_id", String.valueOf(userDetails.getId()));
    map.put("ip", request.getRemoteAddr());
    dao.insertUserLog(map); // 마지막 로그인 일시 기록

    request.getSession().setAttribute("id", userDetails.getId());
    request.getSession().setAttribute("nickname", userDetails.getNickname());
    request.getSession().setAttribute("level", userDetails.getLevel());
    request.getSession().setAttribute("profile", userDetails.getProfile());
    request.getSession().setAttribute("userType", userDetails.getType());

    SavedRequest saveRequest = requestCache.getRequest(request, response);

    if(saveRequest != null) {
      redirectStrategy.sendRedirect(request, response, saveRequest.getRedirectUrl());
    } else {
      redirectStrategy.sendRedirect(request, response, "/");
    }

  }
}
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/security/CustomAuthenticationSuccessHandler.java">CustomAuthenticationSuccessHandler.java</a>
</pre>
## CustomAuthenticationFailureHandler
```java
public class CustomAuthenticationFailureHandler implements AuthenticationFailureHandler {

  @Inject
  private SqlSession sqlSession;

  @Override
   public void onAuthenticationFailure(HttpServletRequest request, HttpServletResponse response, AuthenticationException exception)
    throws IOException, ServletException {

    String errorMsg = "";

    if(exception instanceof InternalAuthenticationServiceException || exception instanceof BadCredentialsException) {
      errorMsg = "아이디 또는 비밀번호를 확인해주세요.";
    } else if(exception instanceof LockedException) {
      errorMsg = "진행 중인 탈퇴가 취소되었습니다.<br>다시 로그인해주세요.";
    } else if(exception instanceof DisabledException) {
      LoginDAO dao = sqlSession.getMapper(LoginDAO.class);
      String username = request.getParameter("username");
      Map<String, String> resultMap = dao.selectUserBanInfoByUsername(username);
      errorMsg = "정지된 계정입니다.<br><br>"
          + "사유 : " + resultMap.get("reason") + "<br>"
          + "정지일 : " + resultMap.get("register_date") + " 00:00" + "<br>"
          + "해제일 : " + resultMap.get("period_date") + " 00:00";
    }

    request.setAttribute("errorMsg", errorMsg);
    request.getRequestDispatcher("/login").forward(request, response);

  }
}
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/security/CustomAuthenticationFailureHandler.java">CustomAuthenticationFailureHandler.java</a>
</pre>
## LoginMapper
```xml
<mapper namespace="com.kjh.aps.persistent.LoginDAO">
  <select id="selectUserByUsername" resultType="com.kjh.aps.security.CustomUserDetails">
    SELECT id, username, password, nickname, profile, level, type, auth, enabled, status FROM user WHERE username = #{param1}
  </select>
  <select id="selectUserTypeByMap" resultType="Integer">
    SELECT type FROM user WHERE name = #{name} AND username = #{username} AND email = #{email}
  </select>
  <update id="updateUserStatus">
    <choose>
      <when test='type != null and type.equals("unlock")'>
        UPDATE user SET enabled = 1, status = 1 WHERE id = #{id}
      </when>
    </choose>
  </update>
  <insert id="insertUserLog">
    INSERT INTO user_log(user_id, ip, login_date) VALUES(#{user_id}, #{ip}, CURRENT_TIMESTAMP)
  </insert>
  <select id="selectUserBanInfoByUsername" resultType="Map">
    SELECT
      reason, DATE_FORMAT(period_date, '%Y-%m-%d') period_date,
      DATE_FORMAT(register_date, '%Y-%m-%d') register_date
    FROM
      user_ban
    WHERE
      user_id = (SELECT id FROM user WHERE username = #{param1})
  </select>
  <update id="updateSocialUserPassword">
    UPDATE user SET password = #{password} WHERE id = #{id}
  </update>
</mapper>
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/mapper/LoginDAO.xml">LoginDAO.xml</a>
</pre>
