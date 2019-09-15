package com.kjh.aps.util;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

import javax.servlet.http.HttpSession;

import org.springframework.util.StringUtils;

import com.github.scribejava.core.builder.ServiceBuilder;
import com.github.scribejava.core.model.OAuth2AccessToken;
import com.github.scribejava.core.model.OAuthRequest;
import com.github.scribejava.core.model.Response;
import com.github.scribejava.core.model.Verb;
import com.github.scribejava.core.oauth.OAuth20Service;

public class NaverLoginBO {

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
}