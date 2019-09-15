package com.kjh.aps.domain;

import java.sql.Timestamp;

import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@ToString
public class BoardDTO {
	
	private int id; // 글 고유번호
	private String broadcaster_id; // 방송인 식별 아이디
	private int user_id; // 회원 고유번호
	private String ip; // 글 작성 IP
	private String subject; // 글 제목
	private String content; // 글 내용
	private boolean image_flag; // 이미지 존재 여부
	private boolean media_flag; // 동영상 존재 여부
	private int up; // 추천 수
	private int down; // 비추천 수
	private int view; // 조회수
	private int status; // 글 상태
	private Timestamp register_date; // 글 작성 일시
	private Timestamp delete_date; // 글 삭제 일시
	
	// 작성자 닉네임
	private String nickname; // 회원 닉네임
	// 작성자 레벨
	private int level;
	// 작성자 프로필 사진
	private String profile;
	// 작성자 타입
	private int userType;
	
	// 다음글, 이전글 정보
	private int next_id;
	private int prev_id;
	private String next_subject;
	private String prev_subject;
	
	// 해당 글을 추천한 기록이 있다면
	private Integer type;
	
	// 해당 글의 댓글 수
	private int commentCount;
	
	// 고객센터 글 카테고리
	private String category_id;
	
	// 도배방지 제한
	private boolean prevention;
	
	// 게시글  타입
	private String board_type;
	// 비회원 글 비밀번호
	private String password;
	
	public BoardDTO() { }
	
}