package com.kjh.aps.util;

import java.util.Map;

import org.apache.commons.codec.binary.Base64;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.social.google.connect.GoogleOAuth2Template;
import org.springframework.social.oauth2.GrantType;
import org.springframework.social.oauth2.OAuth2Parameters;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;

import com.fasterxml.jackson.databind.ObjectMapper;

public class GoogleLoginBO {

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
	
}