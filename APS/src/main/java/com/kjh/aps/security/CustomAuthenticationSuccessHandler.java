package com.kjh.aps.security;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import javax.inject.Inject;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.ibatis.session.SqlSession;
import org.springframework.security.core.Authentication;
import org.springframework.security.web.DefaultRedirectStrategy;
import org.springframework.security.web.RedirectStrategy;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.security.web.savedrequest.HttpSessionRequestCache;
import org.springframework.security.web.savedrequest.RequestCache;
import org.springframework.security.web.savedrequest.SavedRequest;

import com.kjh.aps.persistent.LoginDAO;

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