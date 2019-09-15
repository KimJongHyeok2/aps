package com.kjh.aps.domain;

import java.sql.Timestamp;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CommentReplyDTO {

	private int id; // 답글 고유번호
	private int broadcaster_board_comment_id; // 답글을 작성한 댓글 고유번호
	private int user_id; // 회원 고유번호
	private String ip; // 답글 작성 IP
	private String content; // 답글 내용
	private int status; // 답글 상태
	private Timestamp register_date; // 답글 등록일시
	private Timestamp delete_date; // 답글 삭제일시
	
	// 작성자 닉네임
	private String nickname;
	// 작성자 레벨
	private int level;
	// 작성자 프로필 사진
	private String profile;
	// 작성자 타입
	private int userType;

	// 방송인 식별 아이디
	private String broadcaster_id;
	// 답글을 작성한 댓글의 글 고유번호
	private int broadcaster_board_id;
	// 답글을 작성한 댓글의 글 작성자의 고유번호
	private int boardUserId;
	// 답글을 작성한 댓글의 글 제목
	private String boardSubject;
	
	// 답글을 작성한 리뷰 고유번호
	private int broadcaster_review_id;
	
	// 고객센터 글 카테고리
	private String category_id;
	// 답글을 작성한 댓글 고유번호(고객센터)
	private int notice_comment_id;
	// 답글을 작성한 댓글의 글 고유번호
	private int notice_id;

	// 도배방지 제한
	private boolean prevention;
	
	// 답글 타입
	private String commentReply_type;
	// 답글을 작성한 댓글의 글 고유번호
	private int combine_board_id;
	// 답글을 작성한 글 고유번호
	private int combine_board_comment_id;
	// 비회원 댓글 비밀번호
	private String password;
	
	public CommentReplyDTO() { }

}