package com.kjh.aps.service;

import java.util.Map;

import com.kjh.aps.domain.UserDTO;

public interface MyPageService {
	public UserDTO selectUserInfoById(int id) throws Exception;
	public String updateUserNickname(Map<String, String> map) throws Exception;
	public String updateUserProfileImage(Map<String, String> map) throws Exception;
	public String updateUserPassword(Map<String, String> map) throws Exception;
	public String updateUserStatus(Map<String, String> map) throws Exception;
}
