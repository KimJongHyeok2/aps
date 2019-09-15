package com.kjh.aps.persistent;

import java.util.Map;

import com.kjh.aps.domain.UserDTO;

public interface MyPageDAO {
	public UserDTO selectUserInfoById(int id) throws Exception;
	public int updateUserNickname(Map<String, String> map) throws Exception;
	public int updateUserProfileImage(Map<String, String> map) throws Exception;
	public String selectUserPasswordByMap(Map<String, String> map) throws Exception;
	public int updateUserPassword(Map<String, String> map) throws Exception;
	public int updateUserStatus(Map<String, String> map) throws Exception;
}