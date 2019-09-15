package com.kjh.aps.security;

import java.util.HashMap;
import java.util.Map;
import java.util.Random;

import javax.inject.Inject;

import org.apache.ibatis.session.SqlSession;
import org.springframework.security.authentication.InternalAuthenticationServiceException;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;

import com.kjh.aps.persistent.LoginDAO;

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