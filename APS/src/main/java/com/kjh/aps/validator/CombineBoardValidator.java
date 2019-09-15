package com.kjh.aps.validator;

import java.util.regex.Pattern;

import org.springframework.validation.Errors;
import org.springframework.validation.ValidationUtils;
import org.springframework.validation.Validator;

import com.kjh.aps.domain.BoardDTO;

public class CombineBoardValidator implements Validator {

	@Override
	public boolean supports(Class<?> clazz) {
		return BoardDTO.class.isAssignableFrom(clazz);
	}

	@Override
	public void validate(Object target, Errors errors) {
		BoardDTO dto = (BoardDTO)target;

		String patternSpc = "^[0-9|a-z|A-Z|ㄱ-ㅎ|ㅏ-ㅣ|가-힝]{2,6}$"; // 닉네임 정규표현식1
		String patternCon = "^.*[ㄱ-ㅎㅏ-ㅣ]+.*$"; // 닉네임 정규표현식2
		
		// 글 제목 유효성 검사
		ValidationUtils.rejectIfEmpty(errors, "subject", "emptySubject");
		// 글 내용 유효성 검사
		ValidationUtils.rejectIfEmpty(errors, "content", "emptyContent");
		// 게시글 타입 유효성 검사
		ValidationUtils.rejectIfEmpty(errors, "board_type", "emptyBoardType");
		
		// 게시글 타입 유효성 검사2
		if(!(dto.getBoard_type().equals("non") || dto.getBoard_type().equals("user"))) {
			errors.reject("board_type", "invalidBoardType");
		}
		// 비회원 이라면
		if(dto.getBoard_type().equals("non")) {
			ValidationUtils.rejectIfEmpty(errors, "nickname", "emptyNickname");
			ValidationUtils.rejectIfEmpty(errors, "password", "emptyPassword");
			
			if(!(Pattern.matches(patternSpc, dto.getNickname())) && (!Pattern.matches(patternCon, dto.getNickname()))) {
				errors.reject("nickname", "invalidNickname");
			}
			if(dto.getPassword().length() < 4 || dto.getPassword().length() > 20) {
				errors.reject("password", "invalidPassword");
			}
		} else {
			if(dto.getUser_id() == 0) {
				errors.reject("user_id", "invalidUserId");				
			}
		}
		// 글 제목 유효성 검사2
		if(dto.getSubject() != null) {
			if(dto.getSubject().length() == 0 || dto.getSubject().length() > 40) {
				errors.reject("subject", "invalidSubject");
			}
		}
		// 글 내용 유효성 검사
		if(dto.getContent() != null) {
			if(dto.getContent().length() == 0 || dto.getContent().length() > 30000) {
				errors.reject("subject", "invalidContent");
			}
		}
	}

}
