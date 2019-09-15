## Demo
<img src="https://user-images.githubusercontent.com/47962660/64924783-34097200-d823-11e9-8ffe-6c06e37c42f1.gif"/>

## Login(Client)
<pre>
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

&lt;form id="loginForm" action="&lt;c:url value='/loginOk'/&gt;" method="post" onsubmit="return validLogin(this);"&gt;
  &lt;div class="input-box"&gt;
    &lt;input type="text" id="username" name="username" placeholder="아이디" autocomplete="off"/&gt;
  &lt;/div&gt;
  &lt;div class="input-box"&gt;
    &lt;input type="password" id="password" name="password" placeholder="비밀번호" autocomplete="off"/&gt;
  &lt;/div&gt;
  &lt;div class="input-box"&gt;
    &lt;button class="aps-button"&gt;로그인&lt:/button&gt;
  &lt;/div&gt;
  &lt;s:csrfInput/&gt;
&lt;/form&gt;
</pre>
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/webapp/WEB-INF/views/login/login.jsp">login.jsp</a>
</pre>

## SecurityContext
<pre>
&lt;security:http use-expressions="true">
	&lt;security:form-login login-page="/login"
	username-parameter="username"
	password-parameter="password"
	login-processing-url="/loginOk"
	authentication-failure-handler-ref="customAuthenticationFailureHandler"
	authentication-success-handler-ref="customAuthenticationSuccessHandler"
	default-target-url="/"
	/&gt;
	&lt;security:intercept-url pattern="/" requires-channel="https" access="permitAll"/&gt;
	&lt;security:intercept-url pattern="/mypage/**" access="hasAnyRole('ROLE_USER', 'ROLE_ADMIN')"/&gt;
	&lt;security:intercept-url pattern="/community/board/write" access="hasAnyRole('ROLE_USER', 'ROLE_ADMIN')"/&gt;
	&lt;security:intercept-url pattern="/community/board/writeOk" access="hasAnyRole('ROLE_USER', 'ROLE_ADMIN')"/&gt;
	&lt;security:intercept-url pattern="/community/board/modify/**" access="hasAnyRole('ROLE_USER', 'ROLE_ADMIN')"/&gt;
	&lt;security:intercept-url pattern="/community/board/modifyOk" access="hasAnyRole('ROLE_USER', 'ROLE_ADMIN')"/&gt;
	&lt;security:intercept-url pattern="/community/board/deleteOk" access="hasAnyRole('ROLE_USER', 'ROLE_ADMIN')"/&gt;
	&lt;security:intercept-url pattern="/customerService/write" access="hasRole('ROLE_ADMIN')"/&gt;
	&lt;security:intercept-url pattern="/customerService/writeOk" access="hasRole('ROLE_ADMIN')"/&gt;
	&lt;security:intercept-url pattern="/customerService/modify" access="hasRole('ROLE_ADMIN')"/&gt;
	&lt;security:intercept-url pattern="/customerService/modifyOk" access="hasRole('ROLE_ADMIN')"/&gt;
	&lt;security:intercept-url pattern="/customerService/deleteOk" access="hasRole('ROLE_ADMIN')"/&gt;
  &lt;security:logout logout-url="/logout" logout-success-url="/login" invalidate-session="true"/&gt;
  &lt;security:access-denied-handler error-page="/access_denied"/&gt;
  &lt;security:session-management&gt;
    &lt;security:concurrency-control max-sessions="1" expired-url="/expired_login"/&gt;
  &lt;/security:session-management&gt;
&lt;/security:http&gt;

&lt;security:authentication-manager&gt;
  &lt;security:authentication-provider ref="customAuthenticationProvider"/&gt;
  &lt;security:authentication-provider user-service-ref="customUserDetailService"/&gt;
&lt;/security:authentication-manager&gt;
	
&lt;security:http-firewall ref="customLoggingHttpFirewall"/&gt;
	
&lt;bean name="customAuthenticationProvider" class="com.kjh.aps.security.CustomAuthenticationProvider"/&gt;
&lt;bean name="customUserDetailService" class="com.kjh.aps.security.CustomUserDetailsService"/&gt;
&lt;bean name="customAuthenticationFailureHandler" class="com.kjh.aps.security.CustomAuthenticationFailureHandler"/&gt;
&lt;bean name="customAuthenticationSuccessHandler" class="com.kjh.aps.security.CustomAuthenticationSuccessHandler"/&gt;
&lt;bean name="customLoggingHttpFirewall" class="com.kjh.aps.security.CustomLoggingHttpFirewall"/&gt;

&lt;!-- DataSource --&gt;
&lt;bean name="dataSource" class="org.apache.commons.dbcp2.BasicDataSource" destroy-method="close"&gt;
  &lt;property name="driverClassName" value="${db.driver}"/&gt;
  &lt;property name="url" value="${db.url}"/&gt;
  &lt;property name="username" value="${db.username}"/&gt;
  &lt;property name="password" value="${db.password}"/&gt;
		
  &lt;property name="initialSize" value="20"/&gt;
  &lt;property name="maxTotal" value="20"/&gt;
  &lt;property name="maxIdle" value="20"/&gt;
  &lt;property name="minIdle" value="20"/&gt;
		
  &lt;property name="testOnBorrow" value="false"/&gt;
  &lt;property name="testOnReturn" value="false"/&gt;
&lt;/bean>

&lt;!-- SqlSession --&gt;
&lt;bean name="sqlSessionFactory" class="org.mybatis.spring.SqlSessionFactoryBean"&gt;
  &lt;property name="dataSource" ref="dataSource"/&gt;
  &lt;property name="mapperLocations" value="classpath:com/kjh/aps/mapper/*.xml"/&gt;
&lt;/bean&gt;
	
&lt;bean name="sqlSession" class="org.mybatis.spring.SqlSessionTemplate"&gt;
  &lt;constructor-arg index="0" ref="sqlSessionFactory"/&gt;
 &lt;/bean&gt;

&lt;context:component-scan base-package="com.kjh.aps.security"/&gt;
</pre>
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/webapp/WEB-INF/spring/appServlet/security-context.xml">SecurityContext.xml</a>
</pre>
## LoginController
<pre>
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
</pre>
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/controller/LoginController.java">LoginController.java</a>
</pre>
## CustomUserDetailService
<pre>
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
</pre>
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/security/CustomUserDetailsService.java">CustomUserDetailsService.java</a>
</pre>
## CustomAuthenticationProvider
<pre>
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
</pre>
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/security/CustomAuthenticationProvider.java">CustomAuthenticationProvider.java</a>
</pre>
## CustomAuthenticationSuccessHandler
<pre>
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
</pre>
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/security/CustomAuthenticationSuccessHandler.java">CustomAuthenticationSuccessHandler.java</a>
</pre>
## CustomAuthenticationFailureHandler
<pre>
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
</pre>
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/security/CustomAuthenticationFailureHandler.java">CustomAuthenticationFailureHandler.java</a>
</pre>
## LoginMapper
<pre>
&lt;mapper namespace="com.kjh.aps.persistent.LoginDAO"&gt;
  &lt;select id="selectUserByUsername" resultType="com.kjh.aps.security.CustomUserDetails"&gt;
    SELECT id, username, password, nickname, profile, level, type, auth, enabled, status FROM user WHERE username = #{param1}
  &lt;/select&gt;
  &lt;select id="selectUserInfoByMap" resultType="Map"&gt;
    SELECT username, cast(type as char(1)) type FROM user WHERE name = #{name} AND email = #{email}
  &lt;/select&gt;
  &lt;select id="selectUserTypeByMap" resultType="Integer"&gt;
    SELECT type FROM user WHERE name = #{name} AND username = #{username} AND email = #{email}
  &lt;/select&gt;
  &lt;update id="updateUserStatus"&gt;
    &lt;choose&gt;
      &lt;when test='type != null and type.equals("unlock")'&gt;
        UPDATE user SET enabled = 1, status = 1 WHERE id = #{id}
      &lt;/when&gt;
    &lt;/choose&gt;
  &lt;/update&gt;
  &lt;insert id="insertUserLog"&gt;
    INSERT INTO user_log(user_id, ip, login_date) VALUES(#{user_id}, #{ip}, CURRENT_TIMESTAMP)
  &lt;/insert&gt;
  &lt;select id="selectUserBanInfoByUsername" resultType="Map"&gt;
    SELECT
      reason, DATE_FORMAT(period_date, '%Y-%m-%d') period_date,
      DATE_FORMAT(register_date, '%Y-%m-%d') register_date
    FROM
      user_ban
    WHERE
      user_id = (SELECT id FROM user WHERE username = #{param1})
  &lt;/select&gt;
&lt;/mapper&gt;
</pre>
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/mapper/LoginDAO.xml">LoginDAO.xml</a>
</pre>
