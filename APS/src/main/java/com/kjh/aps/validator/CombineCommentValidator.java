package com.kjh.aps.validator;

import java.util.regex.Pattern;

import javax.servlet.http.HttpServletRequest;

import org.springframework.validation.Errors;
import org.springframework.validation.ValidationUtils;
import org.springframework.validation.Validator;

import com.kjh.aps.domain.CommentDTO;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CombineCommentValidator implements Validator {

	private HttpServletRequest request;
	
	@Override
	public boolean supports(Class<?> clazz) {
		return CommentDTO.class.isAssignableFrom(clazz);
	}

	@Override
	public void validate(Object target, Errors errors) {
		CommentDTO dto = (CommentDTO)target;
		
		String patternSpc = "^[0-9|a-z|A-Z|ㄱ-ㅎ|ㅏ-ㅣ|가-힝]{2,6}$"; // 닉네임 정규표현식1
		String patternCon = "^.*[ㄱ-ㅎㅏ-ㅣ]+.*$"; // 닉네임 정규표현식2
		
		if(!(dto.getComment_type().equals("non") || dto.getComment_type().equals("user"))) {
			errors.reject("content", "invalidCommentType");
		}
		if(!(request.getRequestURI().indexOf("/combine/comment/modifyOk") >= 0)) {			
			ValidationUtils.rejectIfEmpty(errors, "boardSubject", "emptyBoardSubject");
		}
		ValidationUtils.rejectIfEmpty(errors, "content", "emptyContent");
		
		// 비회원 댓글 비밀번호 유효성 검사
		if(dto.getComment_type().equals("non")) {
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
		
		if(dto.getContent() != null) {
			if(dto.getContent().length() == 0 || dto.getContent().length() > 5000) {
				errors.reject("content", "invalidContent");
			}
		}
		
	}

}