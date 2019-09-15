## Demo
<h5>네이버 로그인</h5>
<img src="https://user-images.githubusercontent.com/47962660/64924996-80ee4800-d825-11e9-881d-8841b0a67aaa.gif"/>
<h5>구글 로그인</h5>
<img src="https://user-images.githubusercontent.com/47962660/64925032-d0cd0f00-d825-11e9-9635-47b1b57b1b4b.gif"/>

## ServletContext
<pre>
&lt;!-- Naver Login --&gt;
&lt;beans:bean name="naverLoginBO" class="com.kjh.aps.util.NaverLoginBO"&gt;
  &lt;beans:constructor-arg index="0" value="${naver.clientId}"/&gt;
  &lt;beans:constructor-arg index="1" value="${naver.clientSecret}"/&gt;
  &lt;beans:constructor-arg index="2" value="${naver.redirectUrl}"/&gt;
  &lt;beans:constructor-arg index="3" value="${naver.sessionState}"/&gt;
  &lt;beans:constructor-arg index="4" value="${naver.profileApiUrl}"/&gt;
&lt;/beans:bean&gt;
<!-- Google Login -->
&lt;beans:bean name="googleOAuth2Template" class="org.springframework.social.google.connect.GoogleOAuth2Template"&gt;
  &lt;beans:constructor-arg value="${google.clientId}"/&gt;
  &lt;beans:constructor-arg value="${google.clientSecret}"/&gt;
&lt;/beans:bean&gt;

&lt;beans:bean name="googleOAuth2Parameters" class="org.springframework.social.oauth2.OAuth2Parameters"&gt;
  &lt;beans:property name="scope" value="${google.scope}"/&gt;
  &lt;beans:property name="redirectUri" value="${google.redirectUrl}"/&gt;
&lt;/beans:bean&gt;

&lt;beans:bean name="googleLoginBO" class="com.kjh.aps.util.GoogleLoginBO"&gt;
  &lt;beans:constructor-arg index="0" ref="googleOAuth2Template"/&gt;
  &lt;beans:constructor-arg index="1" ref="googleOAuth2Parameters"/&gt;
  &lt;beans:constructor-arg index="2" value="${google.clientId}"/&gt;
  &lt;beans:constructor-arg index="3" value="${google.clientSecret}"/&gt;
&lt;/beans:bean&gt;
</pre>
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/webapp/WEB-INF/spring/appServlet/servlet-context.xml">ServletContext.xml</a>
</pre>
## NaverLoginApi
<pre>
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
</pre>
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/util/NaverLoginApi.java">NaverLoginApi.java</a>
</pre>
## NaverLoginBO
<pre>
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
</pre>
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/util/NaverLoginBO.java">NaverLoginBO.java</a>
</pre>
## GoogleLoginBO
<pre>
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
</pre>
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/util/GoogleLoginBO.java">GoogleLoginBO.java</a>
</pre>
## LoginController
<pre>
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
</pre>
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/controller/LoginController.java">LoginController.java</a>
</pre>
## Callback(Client)
<pre>
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
</pre>
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/webapp/WEB-INF/views/login/callback.jsp">callback.jsp</a>
</pre>
## JoinController
<pre>
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
</pre>
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/controller/JoinController.java">JoinController.java</a>
</pre>
## JoinServiceImpl
<pre>
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
</pre>
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/service/JoinServiceImpl.java">joinServiceImpl.java</a>
</pre>
