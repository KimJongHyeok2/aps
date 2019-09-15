package com.kjh.aps.domain;

import java.util.List;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class UserPushsDTO {

	private List<UserPushDTO> userPushs; // 알림 목록
	private int count; // 불러온 알림 수
	private String status; // 상태
	
	public UserPushsDTO() { }

}
