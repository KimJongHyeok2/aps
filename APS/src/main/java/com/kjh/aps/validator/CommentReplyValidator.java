package com.kjh.aps.validator;

import javax.servlet.http.HttpServletRequest;

import org.springframework.validation.Errors;
import org.springframework.validation.ValidationUtils;
import org.springframework.validation.Validator;

import com.kjh.aps.domain.CommentReplyDTO;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CommentReplyValidator implements Validator {

	private HttpServletRequest request;
	
	@Override
	public boolean supports(Class<?> clazz) {
		return CommentReplyDTO.class.isAssignableFrom(clazz);
	}

	@Override
	public void validate(Object target, Errors errors) {
		CommentReplyDTO dto = (CommentReplyDTO)target;
		
		// 답글을 작성한 댓글의 고유번호 유효성 검사
		if(request.getRequestURI().indexOf("/board/commentReply/write") >= 0) {
			ValidationUtils.rejectIfEmpty(errors, "broadcaster_board_comment_id", "emptyBoardCommentId");
		}
		// 리뷰를 작성한 글의 고유번호 유효성 검사
		if(request.getRequestURI().indexOf("/reviewReply/write") >= 0) {
			ValidationUtils.rejectIfEmpty(errors, "broadcaster_review_id", "emptyBroadcasterReviewId");
		}
		// 답글을 작성한 댓글과 해당 글의 고유번호 유효성 검사(고객센터)
		if(request.getRequestURI().indexOf("/customerService/commentReply/write") >= 0) {
			ValidationUtils.rejectIfEmpty(errors, "notice_comment_id", "emptyNoticeCommentId");
		}
		// 회원 고유번호 유효성 검사
		ValidationUtils.rejectIfEmpty(errors, "user_id", "emptyUserId");
		// 답글 내용 유효성 검사
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
			if(dto.getContent().length() == 0 || dto.getContent().length() > 2500) {
				errors.reject("content", "invalidContent");
			}
		}
		
	}

}