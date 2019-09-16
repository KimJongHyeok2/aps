## Demo
<h5>네이버 로그인</h5>
<img src="https://user-images.githubusercontent.com/47962660/64924996-80ee4800-d825-11e9-881d-8841b0a67aaa.gif"/>
<h5>구글 로그인</h5>
<img src="https://user-images.githubusercontent.com/47962660/64925032-d0cd0f00-d825-11e9-9635-47b1b57b1b4b.gif"/>

## Login(Client)
```javascript
function socialLoginPopUp(url) {
  var pop = window.open(url, "pop", "width=600,height=600, scrollbars=yes, resizable=yes");
}
```
```html
<div class="social-wrapper">
  <div class="title-box margin-top">간편하게 로그인해보세요!</div>
    <div class="social-box margin-top">
      <img class="social-login naver" onclick="socialLoginPopUp('${naverUrl}');" src="${pageContext.request.contextPath}/resources/image/icon/naver.PNG">
      <img class="social-login" onclick="socialLoginPopUp('${googleUrl}');" src="${pageContext.request.contextPath}/resources/image/icon/google.png"/>
    </div>
</div>
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/webapp/WEB-INF/views/login/login.jsp">login.jsp</a>
</pre>
## ServletContext
```xml
  <!-- Naver Login -->
  <beans:bean name="naverLoginBO" class="com.kjh.aps.util.NaverLoginBO">
    <beans:constructor-arg index="0" value="${naver.clientId}"/>
    <beans:constructor-arg index="1" value="${naver.clientSecret}"/>
    <beans:constructor-arg index="2" value="${naver.redirectUrl}"/>
    <beans:constructor-arg index="3" value="${naver.sessionState}"/>
    <beans:constructor-arg index="4" value="${naver.profileApiUrl}"/>
  </beans:bean>

  <!-- Google Login -->
  <beans:bean name="googleOAuth2Template" class="org.springframework.social.google.connect.GoogleOAuth2Template">
    <beans:constructor-arg value="${google.clientId}"/>
    <beans:constructor-arg value="${google.clientSecret}"/>
  </beans:bean>
	
  <beans:bean name="googleOAuth2Parameters" class="org.springframework.social.oauth2.OAuth2Parameters">
    <beans:property name="scope" value="${google.scope}"/>
    <beans:property name="redirectUri" value="${google.redirectUrl}"/>
  </beans:bean>
	
  <beans:bean name="googleLoginBO" class="com.kjh.aps.util.GoogleLoginBO">
    <beans:constructor-arg index="0" ref="googleOAuth2Template"/>
    <beans:constructor-arg index="1" ref="googleOAuth2Parameters"/>
    <beans:constructor-arg index="2" value="${google.clientId}"/>
    <beans:constructor-arg index="3" value="${google.clientSecret}"/>
  </beans:bean>
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/webapp/WEB-INF/spring/appServlet/servlet-context.xml">ServletContext.xml</a>
</pre>
## NaverLoginApi
```java
public class NaverLoginApi extends DefaultApi20 {

  protected NaverLoginApi() { }
  
  private static class InstanceHolder {
    private static final NaverLoginApi INSTANCE = new NaverLoginApi();
  }
  
  public static NaverLoginApi instance() {
    return InstanceHolder.INSTANCE;
  }
  
  @Override
  public String getAccessTokenEndpoint() {
    return "https://nid.naver.com/oauth2.0/token?grant_type=authorization_code";
  }
  
  @Override
  protected String getAuthorizationBaseUrl() {
    return "https://nid.naver.com/oauth2.0/authorize";
  }
}
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/util/NaverLoginApi.java">NaverLoginApi.java</a>
</pre>
## NaverLoginBO
```java
private String clientId;
private String clientSecret;
private String redirectUrl;
private String sessionState;
private String profileApiUrl;	
	
public NaverLoginBO(String clientId, String clientSecret, String redirectUrl, String sessionState,
  String profileApiUrl) {
  this.clientId = clientId;
  this.clientSecret = clientSecret;
  this.redirectUrl = redirectUrl;
  this.sessionState = sessionState;
  this.profileApiUrl = profileApiUrl;
}

// 네이버 아이디로 로그인 인증 URL 생성
public String getAuthorizationUrl(HttpSession session) {
  String state = generateRandomString();
  setSession(session, state);
		
  OAuth20Service oauthService = new ServiceBuilder().apiKey(clientId).apiSecret(clientSecret).callback(redirectUrl).state(state).build(NaverLoginApi.instance());
		
  return oauthService.getAuthorizationUrl();
}
	
// 네이버 아이디로 로그인 재동의 인증 URL 생성
public String getRepromptAuthorizationUrl(HttpSession session) {
  String state = generateRandomString();
  setSession(session, state);
		
  OAuth20Service oauthService = new ServiceBuilder().apiKey(clientId).apiSecret(clientSecret).callback(redirectUrl).state(state).build(NaverLoginApi.instance());
  Map<String, String> addUrl = new HashMap<>();
  addUrl.put("auth_type", "reprompt");
		
  return oauthService.getAuthorizationUrl(addUrl);
}
	
// Callback 처리 및 AccessToken 획득
public OAuth2AccessToken getAccessToken(HttpSession session, String code, String state) throws IOException {	

  String sessionState = getSession(session);
		
  if(StringUtils.pathEquals(sessionState, state)) {
    OAuth20Service oauthService = new ServiceBuilder().apiKey(clientId).apiSecret(clientSecret).callback(redirectUrl).state(state).build(NaverLoginApi.instance());
			
    OAuth2AccessToken accessToken = oauthService.getAccessToken(code);
    return accessToken;
  }
		
  return null;
}
	
// 세션 유효성 검증을 위한 난수 생성
private String generateRandomString() {
  return UUID.randomUUID().toString();
}

// session에 데이터 저장
private void setSession(HttpSession session, String state) {
  session.setAttribute(sessionState, state);
}
	
	// session에서 데이터 불러오기
private String getSession(HttpSession session) {
  return (String)session.getAttribute(sessionState);
}
	
// AccessToken을 이용하여 네이버 사용자 프로필 API 호출
public String getUserProfile(OAuth2AccessToken oauthToken) throws IOException {
  OAuth20Service oauthService = new ServiceBuilder().apiKey(clientId).apiSecret(clientSecret).callback(redirectUrl).build(NaverLoginApi.instance());
		
  OAuthRequest request = new OAuthRequest(Verb.GET, profileApiUrl, oauthService);
  oauthService.signRequest(oauthToken, request);
  Response response = request.send();
		
  return response.getBody();
}
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/util/NaverLoginBO.java">NaverLoginBO.java</a>
</pre>
## GoogleLoginBO
```java
private GoogleOAuth2Template googleOAuth2Template;
private OAuth2Parameters googleOAuth2Parameters;
	
private String clientId;
private String clientSecret;
	
public GoogleLoginBO() { }
	
public GoogleLoginBO(GoogleOAuth2Template googleOAuth2Template, OAuth2Parameters googleOAuth2Parameters,
  String clientId, String clientSecret) {
  this.googleOAuth2Template = googleOAuth2Template;
  this.googleOAuth2Parameters = googleOAuth2Parameters;
  this.clientId = clientId;
  this.clientSecret = clientSecret;
}
	
// 구글 로그인 인증 URL 생성
public String getAuthorizationUrl() {
  return googleOAuth2Template.buildAuthenticateUrl(GrantType.AUTHORIZATION_CODE, googleOAuth2Parameters);
}

@SuppressWarnings({"unchecked", "rawtypes"})
	public Map<String, String> getUserProfile(String code) throws Exception {
		
  RestTemplate restTemplate = new RestTemplate();
  MultiValueMap<String, String> parameters = new LinkedMultiValueMap<>();
  parameters.add("code", code);
  parameters.add("client_id", clientId);
  parameters.add("client_secret", clientSecret);
  parameters.add("redirect_uri", googleOAuth2Parameters.getRedirectUri());
  parameters.add("grant_type", "authorization_code");
		
  HttpHeaders headers = new HttpHeaders();
  headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);
  HttpEntity<MultiValueMap<String, String>> requestEntity = new HttpEntity<MultiValueMap<String,String>>(parameters, headers);
  ResponseEntity<Map> responseEntity = restTemplate.exchange("https://www.googleapis.com/oauth2/v4/token", HttpMethod.POST, requestEntity, Map.class);
  Map<String, Object> responseMap = responseEntity.getBody();
		
  String[] tokens = ((String)responseMap.get("id_token")).split("\\.");
  Base64 base64 = new Base64(true);
  String body = new String(base64.decode(tokens[1]));
		
  ObjectMapper mapper = new ObjectMapper();
		
  return mapper.readValue(body, Map.class);
}
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/util/GoogleLoginBO.java">GoogleLoginBO.java</a>
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

@GetMapping("/naverLogin")
public String naverLogin(String code, String state, HttpSession session, Model model) {
		
  try {
    OAuth2AccessToken oauthToken;
    oauthToken = naverLoginBO.getAccessToken(session, code, state);
			
    String result = naverLoginBO.getUserProfile(oauthToken);
			
    JSONParser parser = new JSONParser();
    Object object = parser.parse(result);
    JSONObject jsonObject = (JSONObject)object;
				
    JSONObject responseObject = (JSONObject)jsonObject.get("response");	
  if(responseObject.get("name") == null || responseObject.get("id") == null || responseObject.get("email") == null) { // 동의하지 않은 항목이 존재한다면
    return "redirect:" + naverLoginBO.getRepromptAuthorizationUrl(session);
  }
    model.addAttribute("name", responseObject.get("name"));
    model.addAttribute("username", responseObject.get("id"));
    model.addAttribute("email", responseObject.get("email"));
    model.addAttribute("loginType", "naver");
    model.addAttribute("status", "Success");
  } catch (Exception e) {
    throw new RuntimeException(e);
  }
		
  return "login/callback";
}
	
@GetMapping("/googleLogin")
 public String googleLogin(HttpServletRequest request, Model model) {
		
  try {
    Map<String, String> result = googleLoginBO.getUserProfile(request.getParameter("code"));
			
    model.addAttribute("name", result.get("name"));
    model.addAttribute("username", result.get("sub"));
    model.addAttribute("email", result.get("email"));
    model.addAttribute("loginType", "google");
    model.addAttribute("status", "Success");
  } catch (Exception e) {
    throw new RuntimeException(e);
  }
		
  return "login/callback";
}
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/controller/LoginController.java">LoginController.java</a>
</pre>
## Callback(Client)
```javascript
var header = $("meta[name='_csrf_header']").attr("content");
var token = $("meta[name='_csrf']").attr("content");
$(document).ready(function() {
  if("${status}" == "Success") {
    $.ajax({
      url: "${pageContext.request.contextPath}/join/input/socialUser",
      type: "POST",
      cache: false,
      data: {
        "username" : "${username}",
        "name" : "${name}",
        "email" : "${email}",
        "loginType" : "${loginType}"
      },
      beforeSend: function(xhr) {
        xhr.setRequestHeader(header, token);
      },
      success: function(data, status) {
        if(status == "success") {
          if(data.status == "Already Email") {
            opener.socialLogin(data.status);
          } else if(data.status == "Success") {
            opener.socialLogin(data.status + "," + data.username + "," + data.password);
          }
        }
        window.close();
      }
    });
  } else {
    modalToggle("#modal-type-4", "오류", "인증 오류가 발생하였습니다.");
    $("#modal-type-1 .aps-modal-header .close-button").attr("onclick", "window.close();");
    $("#modal-type-1 .aps-modal-footer .aps-modal-button").attr("onclick", "window.close();");
  }
});
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/webapp/WEB-INF/views/login/callback.jsp">callback.jsp</a>
</pre>
## JoinController
```java
@Inject
private JoinService joingService;

// 소셜 회원가입
@PostMapping("/input/socialUser")
public @ResponseBody SocialLoginDTO joinSocialUser(SocialLoginDTO dto, BindingResult result) {
		
SocialLoginValidator validation = new SocialLoginValidator();
		
if(validation.supports(dto.getClass())) {
  validation.validate(dto, result);
			
  if(!result.hasErrors()) {
      try {
        dto = joingService.selectUserBySocialLoginDTO(dto);
      } catch (Exception e) {
        throw new ResponseBodyException(e);
      }
    }
  }
		
  return dto;
}
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/controller/JoinController.java">JoinController.java</a>
</pre>
## JoinServiceImpl
```java
@Inject
private JoinDAO dao;

@Override
public SocialLoginDTO selectUserBySocialLoginDTO(SocialLoginDTO dto) throws Exception { // 소셜 로그인
		
  SocialLoginDTO user = dao.selectUserBySocialLoginDTO(dto.getEmail());
		
  if(user == null) { // 가입된 회원이 아니라면
    // 비밀번호 난수 생성
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
      dto.setPassword("{noop}" + sb.toString());

      dao.insertSocialUser(dto);
      dto.setStatus("Success");
      return dto;
    } else { // 이미 가입되어 있는 회원이라면
      if(!(user.getType() >= 2)) { // 가입된 회원이 소셜 회원이 아니라면
        user.setStatus("Already Email");
      } else {
        user.setStatus("Success");
      }
    }
		
  return user;
}
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/service/JoinServiceImpl.java">joinServiceImpl.java</a>
</pre>
## Login(Client)
```javascript
function socialLogin(result) {
    var results = result.split(",");
    if(results == "Already Email") {
    modalToggle("#modal-type-1", "안내", "이미 가입된 이메일입니다.");
  } else if(results[0] == "Success") {
    var form = $("<form></form>");
    form.attr("action", "<c:url value='/loginOk'/>");
    form.attr("method", "post");
    form.append("<input type='hidden' id='username' name='username' value='" + results[1] + "' autocomplete='off'/>");
    form.append("<input type='hidden' id='password' name='password' value='" + results[2] + "' autocomplete='off'/>");
    form.append('<s:csrfInput/>');
    form.appendTo("body");
    form.submit();
  }
}
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/webapp/WEB-INF/views/login/login.jsp">login.jsp</a>
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
