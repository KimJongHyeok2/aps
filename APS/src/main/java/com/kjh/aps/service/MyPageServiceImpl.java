package com.kjh.aps.service;

import java.util.Map;
import java.util.regex.Pattern;

import javax.inject.Inject;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.kjh.aps.domain.UserDTO;
import com.kjh.aps.persistent.MyPageDAO;
import com.kjh.aps.util.PasswordEncoding;

@Transactional
@Service("MyPageService")
public class MyPageServiceImpl implements MyPageService {

	@Inject
	private MyPageDAO dao;
	
	@Override
	public UserDTO selectUserInfoById(int id) throws Exception { // 회원정보
		return dao.selectUserInfoById(id);
	}

	@Override
	public String updateUserNickname(Map<String, String> map) throws Exception { // 회원 닉네임 수정
		
		String result = "Fail";
		String patternSpc = "^[0-9|a-z|A-Z|ㄱ-ㅎ|ㅏ-ㅣ|가-힝]{2,6}$"; // 닉네임 정규표현식1
		String patternCon = "^.*[ㄱ-ㅎㅏ-ㅣ]+.*$"; // 닉네임 정규표현식2
		String[] banNicknames = {"에피스", "APS"}; 
		String nickname = map.get("nickname");

		int successCount = 0;
		
		if((Pattern.matches(patternSpc, nickname)) && (!Pattern.matches(patternCon, nickname))) { // 닉네임 정규식 검사
			boolean isBanNickname = false;
			for(int i=0; i<banNicknames.length; i++) { // 금지된 닉네임인지 검사
				if(banNicknames[i].equalsIgnoreCase(nickname)) {
					isBanNickname = true;
				}
			}
			if(isBanNickname) {
				result = "Ban";
			} else {
				successCount = dao.updateUserNickname(map);
			}
		}
		
		if(successCount == 1) {
			result = "Success";
		}
		
		return result;
	}

	@Override
	public String updateUserProfileImage(Map<String, String> map) throws Exception { // 회원 프로필 사진 수정
		
		String result = "Fail";
	
		int successCount = dao.updateUserProfileImage(map);
		
		if(successCount == 1) {
			result = "Success";
		}
		
		return result;
	}

	@Override
	public String updateUserPassword(Map<String, String> map) throws Exception { // 회원 비밀번호 수정
		
		String result = "Fail";
		
		PasswordEncoding encoder = new PasswordEncoding();
		String patternPassword = "^(?=.*\\d)(?=.*\\W)(?=.*[a-zA-Z]).{8,20}$"; // 비밀번호 정규표현식
		String dbPassword = dao.selectUserPasswordByMap(map); // 해당 회원 비밀번호 불러오기
		String newPassword = map.get("newPassword");
		String currentPassword = map.get("currentPassword");
		
		if(Pattern.matches(patternPassword, newPassword)) { // 비밀번호 정규식 검사
			if(encoder.matches(currentPassword, dbPassword)) { // 입력한 현재 비밀번호와 일치한다면
				if(encoder.matches(newPassword, dbPassword)) { // 동일한 비밀번호 변경을 시도했다면
					result = "Same";
				} else {
					map.put("newPassword", encoder.encode(newPassword));
					int successCount = dao.updateUserPassword(map);
					
					if(successCount == 1) {
						result = "Success";
					}				
				}
			} else {
				result = "Not Exist";
			}
		}
		
		return result;
	}

	@Override
	public String updateUserStatus(Map<String, String> map) throws Exception { // 회원 상태값 수정
		
		String result = "Fail";
		
		int successCount = dao.updateUserStatus(map);
		
		if(successCount == 1) {
			result = "Success";
		}
		
		return result;
	}

}
