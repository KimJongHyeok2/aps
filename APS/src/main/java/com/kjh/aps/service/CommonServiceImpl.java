package com.kjh.aps.service;

import java.util.Map;

import javax.inject.Inject;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Isolation;
import org.springframework.transaction.annotation.Transactional;

import com.kjh.aps.domain.UserPushDTO;
import com.kjh.aps.domain.UserPushsDTO;
import com.kjh.aps.persistent.CommonDAO;

@Transactional
@Service("CommonService")
public class CommonServiceImpl implements CommonService {

	private static final Logger logger = LoggerFactory.getLogger(CommonServiceImpl.class);
	
	@Inject
	private CommonDAO dao;
	
	private final int LEVEL_UPDATE_STANDARD = 20;
	private final int EXPIRE_DELETE_DAY = 30;
	private final int EXPIRE_DELETE_DAY_TYPE_PUSH = 7;
	private final int EXPIRE_DELETE_DAY_TYPE_RECOMMEND_HISTORY = 1;
	
	@Override
	public int insertUserPush(UserPushDTO dto) throws Exception { // 알림 추가
		Integer user_id = dao.selectUserIdByUserPushDTO(dto);

		if(user_id != dto.getFrom_user_id() && user_id != null) {		
			return dao.insertUserPush(dto);
		} else {
			return 0;
		}
	}

	@Override
	@Transactional(readOnly = true)
	public UserPushsDTO selectUserPushListByUserId(int userId) throws Exception { // 회원 알림 불러오기
		
		UserPushsDTO userPushs = new UserPushsDTO();
		
		userPushs.setUserPushs(dao.selectUserPushListByUserId(userId));
		
		if(userPushs.getUserPushs() != null && userPushs.getUserPushs().size() != 0) {
			userPushs.setCount(userPushs.getUserPushs().size());
		}
		
		userPushs.setStatus("Success");
		
		return userPushs;
	}

	@Override
	public int updateUserPushStatus(Map<String, Integer> map) throws Exception { // 알림 읽음 상태 수정
		return dao.updateUserPushStatus(map);
	}

	@Override
	public int deleteUserPush(Map<String, String> map) throws Exception { // 알림 삭제
		return dao.deleteUserPush(map);
	}
	
	@Override
	@Transactional(isolation=Isolation.READ_COMMITTED)
	public void updateUserLevel(Map<String, String> map) throws Exception { // 회원 레벨 수정

		Map<String, Integer> maps = dao.selectUserRecommendCountByMap(map);
		
		if(maps != null) {
			Integer level = maps.get("level");
			Integer exp = Integer.parseInt(String.valueOf(maps.get("exp")));
	
			if(level != null && exp != null) {
				boolean levelUpdateFlag = false;
				
				if(((level * level) * LEVEL_UPDATE_STANDARD) <= exp) {
					map.put("updateType", "up");
					levelUpdateFlag = true;
				} else {
					if(level == 1) {
						if(level > exp) {
							map.put("updateType", "down");
							levelUpdateFlag = true;
						}
					} else {
						if(level != 0) {
							if((((level-1) * (level-1)) * LEVEL_UPDATE_STANDARD) > exp) {
								map.put("updateType", "down");
								levelUpdateFlag = true;
							}
						}
					}
				}
				
				if(levelUpdateFlag) {
					dao.updateUserLevel(map);
				}
			}
		}
	}

	@Override
	@Transactional(isolation=Isolation.READ_COMMITTED)
	@Scheduled(cron="0 0 0 * * *")
	public void deleteExpireBroadcasterBoardWrite() throws Exception { // 방송인 커뮤니티 게시판의 삭제 요청 게시글 30일 보관 기한 만료 시 영구삭제
		dao.deleteExpireBoardWriteCommentReply(EXPIRE_DELETE_DAY);
		dao.deleteExpireBoardWriteCommentRecommendHistory(EXPIRE_DELETE_DAY);
		dao.deleteExpireBoardWriteComment(EXPIRE_DELETE_DAY);
		dao.deleteExpireBoardWriteRecommendHistory(EXPIRE_DELETE_DAY);
		dao.deleteExpireBoardWrite(EXPIRE_DELETE_DAY);
		logger.info("보관 기한이 만료된 방송인 커뮤니티 게시판의 게시글들을 삭제하였습니다.");
	}

	@Override
	@Transactional(isolation=Isolation.READ_COMMITTED)
	@Scheduled(cron="0 0 0 * * *")
	public void deleteExpireUser() throws Exception { // 탈퇴 요청한 회원 중 보관 기한이 만료된 회원정보, 서비스 기록 등 영구삭제
		dao.deleteExpireUserBoardWriteCommentChildReply(EXPIRE_DELETE_DAY);
		dao.deleteExpireUserBoardWriteCommentReply(EXPIRE_DELETE_DAY);
		dao.deleteExpireUserBoardWriteCommentRecommendHistory(EXPIRE_DELETE_DAY);
		dao.deleteExpireUserBoardWriteComment(EXPIRE_DELETE_DAY);
		dao.deleteExpireUserBoardWriteChildRecommendHistory(EXPIRE_DELETE_DAY);
		dao.deleteExpireUserBoardWriteRecommendHistory(EXPIRE_DELETE_DAY);
		dao.deleteExpireUserBoardWrite(EXPIRE_DELETE_DAY);
		
		dao.deleteExpireUserBroadcasterReviewChildReply(EXPIRE_DELETE_DAY);
		dao.deleteExpireUserBroadcasterReviewReply(EXPIRE_DELETE_DAY);
		dao.deleteExpireUserBroadcasterReviewChildRecommendHistory(EXPIRE_DELETE_DAY);
		dao.deleteExpireUserBroadcasterReviewRecommendHistory(EXPIRE_DELETE_DAY);
		dao.deleteExpireUserBroadcasterReview(EXPIRE_DELETE_DAY);
		
		dao.deleteExpireUserCustomerServiceBoardWriteCommentChildReply(EXPIRE_DELETE_DAY);
		dao.deleteExpireUserCustomerServiceBoardWriteCommentReply(EXPIRE_DELETE_DAY);
		dao.deleteExpireUserCustomerServiceBoardWriteCommentChildRecommendHistory(EXPIRE_DELETE_DAY);
		dao.deleteExpireUserCustomerServiceBoardWriteCommentRecommendHistory(EXPIRE_DELETE_DAY);
		dao.deleteExpireUserCustomerServiceBoardWriteComment(EXPIRE_DELETE_DAY);
		
		dao.deleteExpireUserCombineBoardWriteCommentChildReply(EXPIRE_DELETE_DAY);
		dao.deleteExpireUserCombineBoardWriteCommentReply(EXPIRE_DELETE_DAY);
		dao.deleteExpireUserCombineBoardWriteCommentRecommendHistory(EXPIRE_DELETE_DAY);
		dao.deleteExpireUserCombineBoardWriteComment(EXPIRE_DELETE_DAY);
		dao.deleteExpireUserCombineBoardWriteChildRecommendHistory(EXPIRE_DELETE_DAY);
		dao.deleteExpireUserCombineBoardWriteRecommendHistory(EXPIRE_DELETE_DAY);
		dao.deleteExpireUserBoardWrite(EXPIRE_DELETE_DAY);
		
		dao.deleteExpireUserLog(EXPIRE_DELETE_DAY);
		dao.deleteExpireUserBan(EXPIRE_DELETE_DAY);
		dao.deleteExpireUserPush(EXPIRE_DELETE_DAY);
		dao.deleteExpireUser(EXPIRE_DELETE_DAY);
		logger.info("보관 기한이 만료된 회원정보 및 서비스 기록들을 삭제하였습니다.");
	}

	@Override
	@Transactional(isolation=Isolation.READ_COMMITTED)
	@Scheduled(cron="0 0 0 * * *")
	public void deleteExpireBroadcasterComment() throws Exception { // 방송인 커뮤니티 게시판 글의 삭제 요청 댓글 및 답글 30일 보관 기한 만료 시 영구삭제
		dao.deleteExpireBoardWriteCommentIndivReply(EXPIRE_DELETE_DAY);
		dao.deleteExpireBoardWriteCommentReplyIndiv(EXPIRE_DELETE_DAY);
		dao.deleteExpireBoardWriteCommentIndivRecommendHistory(EXPIRE_DELETE_DAY);
		dao.deleteExpireBoardWriteCommentIndiv(EXPIRE_DELETE_DAY);
		logger.info("보관 기한이 만료된 방송인 커뮤니티 게시판의 댓글 및 답글들을 삭제하였습니다.");
	}

	@Override
	@Transactional(isolation=Isolation.READ_COMMITTED)
	@Scheduled(cron="0 0 0 * * *")
	public void deleteExpireBroadcasterReview() throws Exception { // 삭제 요청 민심평가 및 답글 30일 보관 기한 만료 시 영구삭제
		dao.deleteExpireBraodcasterReviewIndivReply(EXPIRE_DELETE_DAY);
		dao.deleteExpireBraodcasterReviewReplyIndiv(EXPIRE_DELETE_DAY);
		dao.deleteExpireBraodcasterReviewIndivRecommendHistory(EXPIRE_DELETE_DAY);
		dao.deleteExpireBraodcasterReviewIndiv(EXPIRE_DELETE_DAY);
		logger.info("보관 기한이 만료된 민싱폄가 및 답글들을 삭제하였습니다.");
	}

	@Override
	@Transactional(isolation=Isolation.READ_COMMITTED)
	@Scheduled(cron="0 0 0 * * *")
	public void deleteExpireCustomerServiceBoardWrite() throws Exception { // 고객센터의 삭제 요청 게시글 30일 보관 기한 만료 시 영구삭제
		dao.deleteExpireCustomerServiceBoardWriteCommentReply(EXPIRE_DELETE_DAY);
		dao.deleteExpireCustomerServiceBoardWriteCommentRecommendHistory(EXPIRE_DELETE_DAY);
		dao.deleteExpireCustomerServiceBoardWriteComment(EXPIRE_DELETE_DAY);
		dao.deleteExpireCustomerServiceBoardWrite(EXPIRE_DELETE_DAY);
		logger.info("보관 기한이 만료된 고객센터의 게시글들을 삭제하였습니다.");
	}

	@Override
	@Transactional(isolation=Isolation.READ_COMMITTED)
	@Scheduled(cron="0 0 0 * * *")
	public void deleteExpireCustomerServiceBoardWriteComment() throws Exception { // 고객센터의 게시글의 삭제요청 댓글 및 답글 30일 보관 기한 만료 시 영구삭제
		dao.deleteExpireCustomerServiceBoardWriteCommentIndivReply(EXPIRE_DELETE_DAY);
		dao.deleteExpireCustomerServiceBoardWriteCommentReplyIndiv(EXPIRE_DELETE_DAY);
		dao.deleteExpireCustomerServiceBoardWriteCommentIndivRecommendHistory(EXPIRE_DELETE_DAY);
		dao.deleteExpireCustomerServiceBoardWriteCommentIndiv(EXPIRE_DELETE_DAY);
		logger.info("보관 기한이 만료된 고객센터의 댓글 및 답글들을 삭제하였습니다.");
	}

	@Override
	@Transactional(isolation=Isolation.READ_COMMITTED)
	@Scheduled(cron="0 0 0 * * *")
	public void deleteExpireRecommendHistory() throws Exception {  // 보관 기한이 만료된 추천 기록들 영구삭제
		dao.deleteExpireBroadcasterBoardWriteRecommendHistory(EXPIRE_DELETE_DAY_TYPE_RECOMMEND_HISTORY);
		dao.deleteExpireBroadcasterBoardWriteCommentRecommendHistory(EXPIRE_DELETE_DAY_TYPE_RECOMMEND_HISTORY);
		dao.deleteExpireBroadcasterReviewRecommendHistory(EXPIRE_DELETE_DAY_TYPE_RECOMMEND_HISTORY);
		dao.deleteExpireCustomerServiceCommentRecommendHistory(EXPIRE_DELETE_DAY_TYPE_RECOMMEND_HISTORY);
		dao.deleteExpireCombineBoardWriteRecommendHistory(EXPIRE_DELETE_DAY_TYPE_RECOMMEND_HISTORY);
		dao.deleteExpireCombineBoardWriteCommentRecommendHistory(EXPIRE_DELETE_DAY_TYPE_RECOMMEND_HISTORY);
		logger.info("보관 기한이 만료된 추천 기록들을 삭제하였습니다.");
	}

	@Override
	@Transactional(isolation=Isolation.READ_COMMITTED)
	@Scheduled(cron="0 0 0 * * *")
	public void deleteExpireUserPushIndiv() throws Exception { // 보관 기한이 만료된 회원 알림들 영구삭제
		dao.deleteExpireUserPushIndiv(EXPIRE_DELETE_DAY_TYPE_PUSH);
		logger.info("보관 기한이 만료된 회원 알림들을 삭제하였습니다.");
	}

	@Override
	@Transactional(isolation=Isolation.READ_COMMITTED)
	@Scheduled(cron="0 0 0 * * *")
	public void updateSuspensionExpireUser() throws Exception { // 정지 기한이 만료된 회원 정지 해제
		dao.updateSuspensionExpireUser();
		dao.deleteSuspensionExpireUser();
		logger.info("정지 기한이 만료된 회원의 정지가 해제되었습니다.");
	}

	@Override
	@Transactional(isolation=Isolation.READ_COMMITTED)
	@Scheduled(cron="0 0 0 * * *")
	public void deleteExpireCombineBoardWrite() throws Exception { // 통합 게시판의 삭제 요청 게시글 30일 보관 기한 만료 시 영구삭제
		dao.deleteExpireCombineBoardWriteCommentReply(EXPIRE_DELETE_DAY);
		dao.deleteExpireCombineBoardWriteCommentRecommendHistoryIndiv(EXPIRE_DELETE_DAY);
		dao.deleteExpireCombineBoardWriteComment(EXPIRE_DELETE_DAY);
		dao.deleteExpireCombineBoardWriteRecommendHistoryIndiv(EXPIRE_DELETE_DAY);
		dao.deleteExpireCombineBoardWrite(EXPIRE_DELETE_DAY);
		logger.info("보관 기한이 만료된 통합 게시판의 게시글들을 삭제하였습니다.");
	}

	@Override
	@Transactional(isolation=Isolation.READ_COMMITTED)
	@Scheduled(cron="0 0 0 * * *")
	public void deleteExpireCombineBoardWriteComment() throws Exception { // 통합 게시판의 삭제 요청 댓글 및 답글 30일 보관 기한 만료 시 영구삭제
		dao.deleteExpireCombineBoardWriteCommentIndivReply(EXPIRE_DELETE_DAY);
		dao.deleteExpireCombineBoardWriteCommentReplyIndiv(EXPIRE_DELETE_DAY);
		dao.deleteExpireCombineBoardWriteCommentIndivRecommendHistory(EXPIRE_DELETE_DAY);
		dao.deleteExpireCombineBoardWriteCommentIndiv(EXPIRE_DELETE_DAY);
		logger.info("보관 기한이 만료된 통합 게시판의 댓글 및 답글들을 삭제하였습니다.");
	}
	
}