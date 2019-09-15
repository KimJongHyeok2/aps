package com.kjh.aps.domain;

import java.sql.Timestamp;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class BroadcasterDTO {
	
	private String id; // 방송인 식별 아이디
	private String nickname; // 방송인 닉네임
	private boolean best_flag; // 베스트 BJ 여부
	private boolean partner_flag; // 파트너 BJ 여부
	private String afreeca; // 방송국 주소
	private String youtube; // Youtube 주소
	private String profile; // 프로필 이미지
	private Timestamp register_date; // 등록일시
	
	public BroadcasterDTO() { }
	
}