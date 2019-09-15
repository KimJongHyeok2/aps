package com.kjh.aps.security;

import java.io.IOException;
import java.util.Map;

import javax.inject.Inject;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.ibatis.session.SqlSession;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.DisabledException;
import org.springframework.security.authentication.InternalAuthenticationServiceException;
import org.springframework.security.authentication.LockedException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.authentication.AuthenticationFailureHandler;

import com.kjh.aps.persistent.LoginDAO;

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