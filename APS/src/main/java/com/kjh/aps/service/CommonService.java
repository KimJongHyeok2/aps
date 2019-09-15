package com.kjh.aps.service;

import java.util.Map;

import com.kjh.aps.domain.UserPushDTO;
import com.kjh.aps.domain.UserPushsDTO;

public interface CommonService {
	public int insertUserPush(UserPushDTO dto) throws Exception;
	public UserPushsDTO selectUserPushListByUserId(int userId) throws Exception;
	public int updateUserPushStatus(Map<String, Integer> map) throws Exception;
	public int deleteUserPush(Map<String, String> map) throws Exception;
	public void updateUserLevel(Map<String, String> map) throws Exception;
	public void deleteExpireBroadcasterBoardWrite() throws Exception;
	public void deleteExpireUser() throws Exception;
	public void deleteExpireBroadcasterComment() throws Exception;
	public void deleteExpireBroadcasterReview() throws Exception;
	public void deleteExpireCustomerServiceBoardWrite() throws Exception;
	public void deleteExpireCustomerServiceBoardWriteComment() throws Exception;
	public void deleteExpireRecommendHistory() throws Exception;
	public void deleteExpireUserPushIndiv() throws Exception;
	public void updateSuspensionExpireUser() throws Exception;
	public void deleteExpireCombineBoardWrite() throws Exception;
	public void deleteExpireCombineBoardWriteComment() throws Exception;
}