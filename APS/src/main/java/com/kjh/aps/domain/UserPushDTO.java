package com.kjh.aps.domain;

import java.sql.Timestamp;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class UserPushDTO {
	
	private int id; // Push 고유번호
	private String broadcaster_id; // 방송인 식별 아이디
	private int user_id; // Push를 받을 회원 고유번호
	private int from_user_id; // Push를 보낸 회원 고유번호
	private int content_id; // Push Content 고유번호
	private String subject;	// Push 제목
	private int status; // 읽음 상태
	private int type; // Push Type
	private Timestamp register_date; // Push 등록일시
	
	// Push를 보낸 회원 닉네임
	private String nickname;
	// Push를 보낸 비회원 닉네임
	private String nonuser_nickname;
	// Push가 오고가는 민심평가 또는 게시판의 방송인 닉네임
	private String broadcaster_nickname;
	
	public UserPushDTO() { }

	public UserPushDTO(String broadcaster_id, int user_id, int from_user_id, int content_id, String subject, int type) {
		this.broadcaster_id = broadcaster_id;
		this.user_id = user_id;
		this.from_user_id = from_user_id;
		this.content_id = content_id;
		this.subject = subject;
		this.type = type;
	}
	
	public UserPushDTO(String broadcaster_id, int user_id, int from_user_id, String nonuser_nickname, int content_id, String subject, int type) {
		this.broadcaster_id = broadcaster_id;
		this.user_id = user_id;
		this.from_user_id = from_user_id;
		this.nonuser_nickname = nonuser_nickname;
		this.content_id = content_id;
		this.subject = subject;
		this.type = type;
	}
	
}