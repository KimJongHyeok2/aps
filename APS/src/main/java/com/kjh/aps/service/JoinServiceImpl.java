package com.kjh.aps.service;

import java.util.Random;

import javax.inject.Inject;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.kjh.aps.domain.EmailAccessDTO;
import com.kjh.aps.domain.JoinDTO;
import com.kjh.aps.domain.SocialLoginDTO;
import com.kjh.aps.persistent.JoinDAO;

@Transactional
@Service("JoinService")
public class JoinServiceImpl implements JoinService {

	@Inject
	private JoinDAO dao;
	
	@Override
	public int insertEmailAccessKey(EmailAccessDTO dto) throws Exception { // 이메일 인증키 추가
		return dao.insertEmailAccessKey(dto);
	}

	@Override
	@Transactional(readOnly = true)
	public String selectEmailAccessKeyById(int id) throws Exception { // 이메일 인증키 조회
		return dao.selectEmailAccessKeyById(id);
	}

	@Override
	@Transactional(readOnly = true)
	public int selectUsernameCountByUsername(String username) throws Exception { // 회원 아이디 유무 조회
		return dao.selectUsernameCountByUsername(username);
	}

	@Override
	@Transactional(readOnly = true)
	public int selectEmailCountByEmail(String email) throws Exception { // 회원 이메일 유무 조회
		return dao.selectEmailCountByEmail(email);
	}
	
	@Override
	public int insertUser(JoinDTO dto) throws Exception { // 회원 추가(회원가입)
		return dao.insertUser(dto);
	}

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

}
