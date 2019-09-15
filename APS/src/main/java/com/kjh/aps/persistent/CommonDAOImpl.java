package com.kjh.aps.persistent;

import java.util.List;
import java.util.Map;

import javax.inject.Inject;

import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Repository;

import com.kjh.aps.domain.UserPushDTO;

@Repository("CommonDAO")
public class CommonDAOImpl implements CommonDAO {

	@Inject
	private SqlSession sqlSession;
	
	private final String COMMON_DAO_NAMESPACE = "common";
	
	@Override
	public int insertUserPush(UserPushDTO dto) throws Exception {
		return sqlSession.insert(COMMON_DAO_NAMESPACE + ".insertUserPush", dto);
	}
	
	@Override
	public int selectUserIdByUserPushDTO(UserPushDTO dto) throws Exception {
		return sqlSession.selectOne(COMMON_DAO_NAMESPACE + ".selectUserIdByUserPushDTO", dto);
	}

	@Override
	public List<UserPushDTO> selectUserPushListByUserId(int userId) throws Exception {
		return sqlSession.selectList(COMMON_DAO_NAMESPACE + ".selectUserPushListByUserId", userId);
	}

	@Override
	public int updateUserPushStatus(Map<String, Integer> map) throws Exception {
		return sqlSession.update(COMMON_DAO_NAMESPACE + ".updateUserPushStatus", map);
	}

	@Override
	public int deleteUserPush(Map<String, String> map) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteUserPush", map);
	}

	@Override
	public Map<String, Integer> selectUserRecommendCountByMap(Map<String, String> map) throws Exception {
		return sqlSession.selectOne(COMMON_DAO_NAMESPACE + ".selectUserRecommendCountByMap", map);
	}

	@Override
	public int updateUserLevel(Map<String, String> map) throws Exception {
		return sqlSession.update(COMMON_DAO_NAMESPACE + ".updateUserLevel", map);
	}

	@Override
	public int deleteExpireBoardWriteCommentReply(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireBoardWriteCommentReply", expireDay);
	}
	
	@Override
	public int deleteExpireBoardWriteCommentRecommendHistory(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireBoardWriteCommentRecommendHistory", expireDay);
	}

	@Override
	public int deleteExpireBoardWriteComment(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireBoardWriteComment", expireDay);
	}

	@Override
	public int deleteExpireBoardWriteRecommendHistory(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireBoardWriteRecommendHistory", expireDay);
	}

	@Override
	public int deleteExpireBoardWrite(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireBoardWrite", expireDay);
	}

	@Override
	public int deleteExpireUserLog(int id) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireUserLog", id);
	}

	@Override
	public int deleteExpireUserBan(int id) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireUserBan", id);
	}

	@Override
	public int deleteExpireUserPush(int id) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireUserPush", id);
	}

	@Override
	public int deleteExpireUser(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireUser", expireDay);
	}

	@Override
	public int deleteExpireUserBoardWriteCommentChildReply(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireUserBoardWriteCommentChildReply", expireDay);
	}
	
	@Override
	public int deleteExpireUserBoardWriteCommentReply(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireUserBoardWriteCommentReply", expireDay);
	}

	@Override
	public int deleteExpireUserBoardWriteCommentRecommendHistory(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireUserBoardWriteCommentRecommendHistory", expireDay);
	}

	@Override
	public int deleteExpireUserBoardWriteComment(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireUserBoardWriteComment", expireDay);
	}

	@Override
	public int deleteExpireUserBoardWriteChildRecommendHistory(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireUserBoardWriteChildRecommendHistory", expireDay);
	}
	
	@Override
	public int deleteExpireUserBoardWriteRecommendHistory(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireUserBoardWriteRecommendHistory", expireDay);
	}

	@Override
	public int deleteExpireUserBoardWrite(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireUserBoardWrite", expireDay);
	}

	@Override
	public int deleteExpireBoardWriteCommentIndivReply(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireBoardWriteCommentIndivReply", expireDay);
	}

	@Override
	public int deleteExpireBoardWriteCommentIndivRecommendHistory(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireBoardWriteCommentIndivRecommendHistory", expireDay);
	}

	@Override
	public int deleteExpireBoardWriteCommentIndiv(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireBoardWriteCommentIndiv", expireDay);
	}

	@Override
	public int deleteExpireBoardWriteCommentReplyIndiv(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireBoardWriteCommentReplyIndiv", expireDay);
	}

	@Override
	public int deleteExpireBraodcasterReviewIndivReply(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireBraodcasterReviewIndivReply", expireDay);
	}

	@Override
	public int deleteExpireBraodcasterReviewIndivRecommendHistory(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireBraodcasterReviewIndivRecommendHistory", expireDay);
	}

	@Override
	public int deleteExpireBraodcasterReviewIndiv(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireBraodcasterReviewIndiv", expireDay);
	}

	@Override
	public int deleteExpireBraodcasterReviewReplyIndiv(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireBraodcasterReviewReplyIndiv", expireDay);
	}

	@Override
	public int deleteExpireUserBroadcasterReviewChildReply(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireUserBroadcasterReviewChildReply", expireDay);
	}

	@Override
	public int deleteExpireUserBroadcasterReviewReply(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireUserBroadcasterReviewReply", expireDay);
	}

	@Override
	public int deleteExpireUserBroadcasterReviewChildRecommendHistory(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireUserBroadcasterReviewChildRecommendHistory", expireDay);
	}

	@Override
	public int deleteExpireUserBroadcasterReviewRecommendHistory(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireUserBroadcasterReviewRecommendHistory", expireDay);
	}

	@Override
	public int deleteExpireUserBroadcasterReview(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireUserBroadcasterReview", expireDay);
	}

	@Override
	public int deleteExpireCustomerServiceBoardWriteCommentReply(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireCustomerServiceBoardWriteCommentReply", expireDay);
	}

	@Override
	public int deleteExpireCustomerServiceBoardWriteCommentRecommendHistory(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireCustomerServiceBoardWriteCommentRecommendHistory", expireDay);
	}

	@Override
	public int deleteExpireCustomerServiceBoardWriteComment(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireCustomerServiceBoardWriteComment", expireDay);
	}
	
	@Override
	public int deleteExpireCustomerServiceBoardWrite(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireCustomerServiceBoardWrite", expireDay);
	}

	@Override
	public int deleteExpireCustomerServiceBoardWriteCommentIndivReply(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireCustomerServiceBoardWriteCommentIndivReply", expireDay);
	}

	@Override
	public int deleteExpireCustomerServiceBoardWriteCommentReplyIndiv(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireCustomerServiceBoardWriteCommentReplyIndiv", expireDay);
	}

	@Override
	public int deleteExpireCustomerServiceBoardWriteCommentIndivRecommendHistory(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireCustomerServiceBoardWriteCommentIndivRecommendHistory", expireDay);
	}

	@Override
	public int deleteExpireCustomerServiceBoardWriteCommentIndiv(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireCustomerServiceBoardWriteCommentIndiv", expireDay);
	}

	@Override
	public int deleteExpireUserCustomerServiceBoardWriteCommentChildReply(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireUserCustomerServiceBoardWriteCommentChildReply", expireDay);
	}

	@Override
	public int deleteExpireUserCustomerServiceBoardWriteCommentReply(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireUserCustomerServiceBoardWriteCommentReply", expireDay);
	}

	@Override
	public int deleteExpireUserCustomerServiceBoardWriteCommentChildRecommendHistory(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireUserCustomerServiceBoardWriteCommentChildRecommendHistory", expireDay);
	}

	@Override
	public int deleteExpireUserCustomerServiceBoardWriteCommentRecommendHistory(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireUserCustomerServiceBoardWriteCommentRecommendHistory", expireDay);
	}

	@Override
	public int deleteExpireUserCustomerServiceBoardWriteComment(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireUserCustomerServiceBoardWriteComment", expireDay);
	}

	@Override
	public int deleteExpireBroadcasterBoardWriteRecommendHistory(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireBroadcasterBoardWriteRecommendHistory", expireDay);
	}

	@Override
	public int deleteExpireBroadcasterBoardWriteCommentRecommendHistory(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireBroadcasterBoardWriteCommentRecommendHistory", expireDay);
	}

	@Override
	public int deleteExpireBroadcasterReviewRecommendHistory(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireBroadcasterReviewRecommendHistory", expireDay);
	}

	@Override
	public int deleteExpireCustomerServiceCommentRecommendHistory(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireCustomerServiceCommentRecommendHistory", expireDay);
	}	

	@Override
	public int deleteExpireUserPushIndiv(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireUserPushIndiv", expireDay);
	}

	@Override
	public int deleteSuspensionExpireUser() throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteSuspensionExpireUser");
	}

	@Override
	public int updateSuspensionExpireUser() throws Exception {
		return sqlSession.update(COMMON_DAO_NAMESPACE + ".updateSuspensionExpireUser");
	}

	@Override
	public int deleteExpireCombineBoardWriteRecommendHistory(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireCombineBoardWriteRecommendHistory", expireDay);
	}

	@Override
	public int deleteExpireCombineBoardWriteCommentRecommendHistory(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireCombineBoardWriteCommentRecommendHistory", expireDay);
	}

	@Override
	public int deleteExpireCombineBoardWriteCommentReply(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireCombineBoardWriteCommentReply", expireDay);
	}

	@Override
	public int deleteExpireCombineBoardWriteCommentRecommendHistoryIndiv(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireCombineBoardWriteCommentRecommendHistoryIndiv", expireDay);
	}

	@Override
	public int deleteExpireCombineBoardWriteComment(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireCombineBoardWriteComment", expireDay);
	}

	@Override
	public int deleteExpireCombineBoardWriteRecommendHistoryIndiv(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireCombineBoardWriteRecommendHistoryIndiv", expireDay);
	}

	@Override
	public int deleteExpireCombineBoardWrite(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireCombineBoardWrite", expireDay);
	}

	@Override
	public int deleteExpireUserCombineBoardWriteCommentChildReply(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireUserCombineBoardWriteCommentChildReply", expireDay);
	}

	@Override
	public int deleteExpireUserCombineBoardWriteCommentReply(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireUserCombineBoardWriteCommentReply", expireDay);
	}

	@Override
	public int deleteExpireUserCombineBoardWriteCommentRecommendHistory(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireUserCombineBoardWriteCommentRecommendHistory", expireDay);
	}

	@Override
	public int deleteExpireUserCombineBoardWriteComment(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireUserCombineBoardWriteComment", expireDay);
	}

	@Override
	public int deleteExpireUserCombineBoardWriteChildRecommendHistory(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireUserCombineBoardWriteChildRecommendHistory", expireDay);
	}

	@Override
	public int deleteExpireUserCombineBoardWriteRecommendHistory(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireUserCombineBoardWriteRecommendHistory", expireDay);
	}

	@Override
	public int deleteExpireUserCombineBoardWrite(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireUserCombineBoardWrite", expireDay);
	}

	@Override
	public int deleteExpireCombineBoardWriteCommentIndivReply(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireCombineBoardWriteCommentIndivReply", expireDay);
	}

	@Override
	public int deleteExpireCombineBoardWriteCommentReplyIndiv(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireCombineBoardWriteCommentReplyIndiv", expireDay);
	}

	@Override
	public int deleteExpireCombineBoardWriteCommentIndivRecommendHistory(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireCombineBoardWriteCommentIndivRecommendHistory", expireDay);
	}

	@Override
	public int deleteExpireCombineBoardWriteCommentIndiv(int expireDay) throws Exception {
		return sqlSession.delete(COMMON_DAO_NAMESPACE + ".deleteExpireCombineBoardWriteCommentIndiv", expireDay);
	}
	
}