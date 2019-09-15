package com.kjh.aps.validator;

import javax.servlet.http.HttpServletRequest;

import org.springframework.validation.Errors;
import org.springframework.validation.ValidationUtils;
import org.springframework.validation.Validator;

import com.kjh.aps.domain.BoardDTO;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class BoardValidator implements Validator {
	
	private HttpServletRequest request;
	
	@Override
	public boolean supports(Class<?> clazz) {
		return BoardDTO.class.isAssignableFrom(clazz);
	}

	@Override
	public void validate(Object target, Errors errors) {
		BoardDTO dto = (BoardDTO)target;
		
		// 방송인 식별 아이디 유효성 검사
		if(dto.getCategory_id() == null) {
			ValidationUtils.rejectIfEmpty(errors, "broadcaster_id", "emptyBroadcasterId");
		}
		// 회원 고유번호 유효성 검사
		ValidationUtils.rejectIfEmpty(errors, "user_id", "emptyUserId");
		// 글 제목 유효성 검사
		ValidationUtils.rejectIfEmpty(errors, "subject", "emptySubject");
		// 글 내용 유효성 검사
		ValidationUtils.rejectIfEmpty(errors, "content", "emptyContent");
		
		// 회원 고유번호 유효성 검사2
		if(dto.getUser_id() != 0) {
			Integer userId = request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id");
			if(userId == 0) {
				errors.reject("user_id", "invalidUserId");
			} else {
				if(dto.getUser_id() != userId) {
					errors.reject("user_id", "invalidUserId");
				}	
			}
		} else {
			errors.reject("user_id", "invalidUserId");
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
