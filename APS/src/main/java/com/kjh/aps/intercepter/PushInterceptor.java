package com.kjh.aps.intercepter;

import javax.inject.Inject;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.handler.HandlerInterceptorAdapter;

import com.kjh.aps.domain.CommentDTO;
import com.kjh.aps.domain.CommentReplyDTO;
import com.kjh.aps.domain.UserPushDTO;
import com.kjh.aps.service.CommonService;

public class PushInterceptor extends HandlerInterceptorAdapter {

	@Inject
	private CommonService commonService;
	
	@Override
	public void postHandle(HttpServletRequest request, HttpServletResponse response, Object handler,
			ModelAndView modelAndView) throws Exception {
		
		Integer type = (Integer)request.getAttribute("type"); // Push Type
		Integer from_user_id = request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id"); // Push를 보낸 회원 고유번호
		UserPushDTO dto = null;
		
		if(type != null && from_user_id != 0) {
			if(type == 1) { // 방송인 커뮤니티 게시판 댓글 Push
				CommentDTO comment = (CommentDTO)request.getAttribute("dto");
				Integer user_id = comment.getBoardUserId(); // Push를 수신할 회원 고유번호
				
				dto = new UserPushDTO(comment.getBroadcaster_id(), user_id, from_user_id, comment.getBroadcaster_board_id(), comment.getBoardSubject(), type);
			} else if(type == 2) { // 방송인 커뮤니티 게시판 댓글의 답글 Push
				CommentReplyDTO commentReply = (CommentReplyDTO)request.getAttribute("dto");
				Integer user_id = commentReply.getBroadcaster_board_comment_id(); // Push를 수신할 회원의 해당 댓글의 고유번호 
				
				dto = new UserPushDTO(commentReply.getBroadcaster_id(), user_id, from_user_id, commentReply.getBroadcaster_board_id(), commentReply.getBoardSubject(), type);
			} else if(type == 3) { // 방송인 민심평가 답글 Push
				CommentReplyDTO commentReply = (CommentReplyDTO)request.getAttribute("dto");
				Integer user_id = 0;
				
				dto = new UserPushDTO(commentReply.getBroadcaster_id(), user_id, from_user_id, commentReply.getBroadcaster_review_id(), "NONE", type);
			} else if(type == 4) { // 고객센터 댓글 Push
				CommentDTO comment = (CommentDTO)request.getAttribute("dto");
				Integer user_id = comment.getBoardUserId(); // Push를 수신할 회원 고유번호
				
				dto = new UserPushDTO(comment.getCategory_id(), user_id, from_user_id, comment.getNotice_id(), comment.getBoardSubject(), type);
			} else if(type == 5) { // 고객센터 댓글의 답글 Push
				CommentReplyDTO commentReply = (CommentReplyDTO)request.getAttribute("dto");
				Integer user_id = commentReply.getNotice_comment_id(); // Push를 수신할 회원의 해당 댓글의 고유번호
				
				dto = new UserPushDTO(commentReply.getCategory_id(), user_id, from_user_id, commentReply.getNotice_id(), commentReply.getBoardSubject(), type);
			}
		} else if(type != null && from_user_id == 0 && request.getAttribute("dto") != null) {
			if(type == 6) { // 통합 게시판 댓글 Push					
				CommentDTO comment = (CommentDTO)request.getAttribute("dto");
				Integer user_id = comment.getBoardUserId(); // Push를 수신할 회원 고유번호
					
				dto = new UserPushDTO("combine", user_id, from_user_id, comment.getNickname(), comment.getCombine_board_id(), comment.getBoardSubject(), type);
			} else if(type == 7) { // 통합 게시판 댓글의 답글 Push
				CommentReplyDTO commentReply = (CommentReplyDTO)request.getAttribute("dto");
				Integer user_id = commentReply.getCombine_board_comment_id(); // Push를 수신할 회원 고유번호
						
				dto = new UserPushDTO("combine", user_id, from_user_id, commentReply.getNickname(), commentReply.getCombine_board_id(), commentReply.getBoardSubject(), type);
			}
		}
		
		if(dto != null) { commonService.insertUserPush(dto); }
		
		super.postHandle(request, response, handler, modelAndView);
	}
	
}