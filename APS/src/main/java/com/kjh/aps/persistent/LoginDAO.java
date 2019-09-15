package com.kjh.aps.persistent;

import java.util.Map;

import com.kjh.aps.security.CustomUserDetails;

public interface LoginDAO {
	public CustomUserDetails selectUserByUsername(String username);
	public Map<String, String> selectUserInfoByMap(Map<String, String> map);
	public Integer selectUserTypeByMap(Map<String, String> map);
	public int updatePasswordByMap(Map<String, String> map);
	public int updateUserStatus(Map<String, String> map);
	public int insertUserLog(Map<String, String> map);
	public Map<String, String> selectUserBanInfoByUsername(String username);
	public int updateSocialUserPassword(Map<String, String> map);
}