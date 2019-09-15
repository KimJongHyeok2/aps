package com.kjh.aps.security;

import java.util.HashMap;
import java.util.Map;

import javax.inject.Inject;

import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.DisabledException;
import org.springframework.security.authentication.LockedException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;

import com.kjh.aps.persistent.LoginDAO;
import com.kjh.aps.util.PasswordEncoding;

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