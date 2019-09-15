package com.kjh.aps.validator;

import java.util.regex.Pattern;

import javax.servlet.http.HttpServletRequest;

import org.springframework.validation.Errors;
import org.springframework.validation.ValidationUtils;
import org.springframework.validation.Validator;

import com.kjh.aps.domain.CommentReplyDTO;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CombineCommentReplyValidator implements Validator {

	private HttpServletRequest request;
	
	@Override
	public boolean supports(Class<?> clazz) {
		return CommentReplyDTO.class.isAssignableFrom(clazz);
	}

	@Override
	public void validate(Object target, Errors errors) {
		CommentReplyDTO dto = (CommentReplyDTO)target;
		
		String patternSpc = "^[0-9|a-z|A-Z|ㄱ-ㅎ|ㅏ-ㅣ|가-힝]{2,6}$"; // 닉네임 정규표현식1
		String patternCon = "^.*[ㄱ-ㅎㅏ-ㅣ]+.*$"; // 닉네임 정규표현식2
		
		// 답글을 작성한 댓글의 고유번호 유효성 검사
		ValidationUtils.rejectIfEmpty(errors, "combine_board_comment_id", "emptyCombineBoardCommentId");
		// 답글 내용 유효성 검사
		ValidationUtils.rejectIfEmpty(errors, "content", "emptyContent");
		ValidationUtils.rejectIfEmpty(errors, "boardSubject", "emptyBoardSubject");

		// 비회원 댓글 비밀번호 유효성 검사
		if(dto.getCommentReply_type().equals("non")) {
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
			if(dto.getContent().length() == 0 || dto.getContent().length() > 2500) {
				errors.reject("content", "invalidContent");
			}
		}
		
	}

}