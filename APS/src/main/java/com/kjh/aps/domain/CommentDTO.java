package com.kjh.aps.domain;

import java.sql.Timestamp;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CommentDTO {
	
	private int id; // 댓글 고유번호
	private int broadcaster_board_id; // 댓글을 작성한 글 고유번호
	private int user_id; // 회원 고유번호
	private String ip; // 댓글 작성 IP
	private String content; // 댓글 내용
	private int up; // 댓글 추천수
	private int down; // 댓글 비추천수
	private int status; // 댓글 상태
	private Timestamp register_date; // 댓글 등록일시
	private Timestamp delete_date; // 댓글 삭제일시
	
	// 작성자 닉네임
	private String nickname;
	// 작성자 레벨
	private int level;
	// 작성자 프로필 사진
	private String profile;
	// 작성자 타입
	private int userType;
	
	// 댓글에 달린 답글 수
	private int replyCount;
	
	// 해당 글을 추천한 기록이 있다면
	private Integer type;
	private Integer recommendType;
	
	// 댓글 순위
	private int no;
	
	// 방송인 식별 아이디
	private String broadcaster_id;
	// 댓글을 작성한 글 작성자의 고유번호
	private int boardUserId;
	// 댓글을 작성한 글의 제목
	private String boardSubject;
	
	// 민심평가 댓글일 경우
	private double gp; // 평가점수
	
	// 고객센터 글 카테고리
	private String category_id;
	// 댓글을 작성한 글의 고유번호(고객센터)
	private int notice_id;
	
	// 도배방지 제한
	private boolean prevention;
	
	// 댓글 타입
	private String comment_type;
	// 댓글을 작성한 글 고유번호
	private int combine_board_id;
	// 비회원 댓글 비밀번호
	private String password;
	
	public CommentDTO() { }

}