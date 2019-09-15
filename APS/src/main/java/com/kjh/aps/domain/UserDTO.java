package com.kjh.aps.domain;

import java.sql.Timestamp;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class UserDTO {
	
	private int id;
	private String username;
	private String password;
	private String name;
	private String nickname;
	private String profile;
	private String email;
	private int level;
	private int type;
	private String auth;
	private boolean enabled;
	private Timestamp register_date;
	private Timestamp modify_date;
	private Timestamp delete_date;
	
	// 해당 회원의 모든 게시글 및 댓글 (추천+비추천) 수
	private int exp;
	
	public UserDTO() { }
	
}