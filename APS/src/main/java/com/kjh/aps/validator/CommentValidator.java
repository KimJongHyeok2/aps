package com.kjh.aps.validator;

import javax.servlet.http.HttpServletRequest;

import org.springframework.validation.Errors;
import org.springframework.validation.ValidationUtils;
import org.springframework.validation.Validator;

import com.kjh.aps.domain.CommentDTO;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CommentValidator implements Validator {

	private HttpServletRequest request;
	
	@Override
	public boolean supports(Class<?> clazz) {
		return CommentDTO.class.isAssignableFrom(clazz);
	}

	@Override
	public void validate(Object target, Errors errors) {
		CommentDTO dto = (CommentDTO)target;
		
		// 댓글을 작성한 글의 고유번호 유효성 검사
		if(request.getRequestURI().indexOf("/board/comment/write") >= 0 || request.getRequestURI().indexOf("/board/comment/modifyOk") >= 0) {
			ValidationUtils.rejectIfEmpty(errors, "broadcaster_board_id", "emptyBoardId");
		}
		// 댓글을 작성한 글의 고유번호 유효성 검사
		if(request.getRequestURI().indexOf("/review/write") >= 0) {
			ValidationUtils.rejectIfEmpty(errors, "broadcaster_id", "emptyBroadcasterId");
			ValidationUtils.rejectIfEmpty(errors, "gp", "emptyGradePoint");
		}
		if(request.getRequestURI().indexOf("/customerService/comment/write") >= 0 || request.getRequestURI().indexOf("/customerService/comment/modifyOk") >= 0) {
			ValidationUtils.rejectIfEmpty(errors, "notice_id", "emptyNoticeId");
		}
		// 회원 고유번호 유효성 검사
		ValidationUtils.rejectIfEmpty(errors, "user_id", "emptyUserId");
		// 댓글 내용 유효성 검사
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
		
		if(dto.getContent() != null) {
			if(dto.getContent().length() == 0 || dto.getContent().length() > 5000) {
				errors.reject("content", "invalidContent");
			}
		}
		
	}

}