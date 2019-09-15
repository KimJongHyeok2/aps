package com.kjh.aps.persistent;

import java.util.List;
import java.util.Map;

import javax.inject.Inject;

import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Repository;

import com.kjh.aps.domain.BoardDTO;
import com.kjh.aps.domain.BroadcasterDTO;
import com.kjh.aps.domain.CommentDTO;
import com.kjh.aps.domain.CommentReplyDTO;
import com.kjh.aps.domain.ReviewGradePointDTO;

@Repository("CommunityDAO")
public class CommunityDAOImpl implements CommunityDAO {

	@Inject
	private SqlSession sqlSession;
	
	private final String COMMUNITY_DAO_NAMESPACE = "community";
	
	@Override
	public List<BroadcasterDTO> selectBroadcasterList(String type) throws Exception {
		return sqlSession.selectList(COMMUNITY_DAO_NAMESPACE + ".selectBroadcasterList", type);
	}

	@Override
	public List<BroadcasterDTO> selectBroadcasterByMap(Map<String, String> map) throws Exception {
		return sqlSession.selectList(COMMUNITY_DAO_NAMESPACE + ".selectBroadcasterByMap", map);
	}

	@Override
	public List<BoardDTO> selectBoardWriteListByMap(Map<String, String> map) throws Exception {
		return sqlSession.selectList(COMMUNITY_DAO_NAMESPACE + ".selectBoardWriteListByMap", map);
	}

	@Override
	public BroadcasterDTO selectBroadcasterById(String id) throws Exception {
		return sqlSession.selectOne(COMMUNITY_DAO_NAMESPACE + ".selectBroadcasterById", id);
	}

	@Override
	public int insertBoardWrite(BoardDTO dto) throws Exception {
		return sqlSession.insert(COMMUNITY_DAO_NAMESPACE + ".insertBoardWrite", dto);
	}

	@Override
	public BoardDTO selectBoardWriteByMap(Map<String, String> map) throws Exception {
		return sqlSession.selectOne(COMMUNITY_DAO_NAMESPACE + ".selectBoardWriteByMap", map);
	}

	@Override
	public int selectBoardWriteCountByMap(Map<String, String> map) throws Exception {
		return sqlSession.selectOne(COMMUNITY_DAO_NAMESPACE + ".selectBoardWriteCountByMap", map);
	}

	@Override
	public List<BoardDTO> selectSearchBoardListByMap(Map<String, String> map) throws Exception {
		return sqlSession.selectList(COMMUNITY_DAO_NAMESPACE + ".selectSearchBoardListByMap", map);
	}

	@Override
	public int selectSearchBoardCountByMap(Map<String, String> map) throws Exception {
		return sqlSession.selectOne(COMMUNITY_DAO_NAMESPACE + ".selectSearchBoardCountByMap", map);
	}

	@Override
	public int updateBoardWrite(BoardDTO dto) throws Exception {
		return sqlSession.update(COMMUNITY_DAO_NAMESPACE + ".updateBoardWrite", dto);
	}

	@Override
	public int selectBoardWriteUserIdByMap(Map<String, String> map) throws Exception {
		return sqlSession.selectOne(COMMUNITY_DAO_NAMESPACE + ".selectBoardWriteUserIdByMap", map);
	}

	@Override
	public int deleteBoardWrite(Map<String, String> map) throws Exception {
		return sqlSession.update(COMMUNITY_DAO_NAMESPACE + ".deleteBoardWrite", map);
	}

	@Override
	public int updateBoardWriteView(Map<String, String> map) throws Exception {
		return sqlSession.update(COMMUNITY_DAO_NAMESPACE + ".updateBoardWriteView", map);
	}

	@Override
	public Integer selectBoardWriteRecommendHistoryTypeByMap(Map<String, String> map) throws Exception {
		return sqlSession.selectOne(COMMUNITY_DAO_NAMESPACE + ".selectBoardWriteRecommendHistoryTypeByMap", map);
	}

	@Override
	public int updateBoardWriteRecommend(Map<String, String> map) throws Exception {
		return sqlSession.update(COMMUNITY_DAO_NAMESPACE + ".updateBoardWriteRecommend", map);
	}

	@Override
	public int insertBoardWriteRecommendHistory(Map<String, String> map) throws Exception {
		return sqlSession.insert(COMMUNITY_DAO_NAMESPACE + ".insertBoardWriteRecommendHistory", map);
	}

	@Override
	public int insertBoardWriteComment(CommentDTO dto) throws Exception {
		return sqlSession.insert(COMMUNITY_DAO_NAMESPACE + ".insertBoardWriteComment", dto);
	}

	@Override
	public List<CommentDTO> selectBoardWriteCommentListByMap(Map<String, String> map) throws Exception {
		return sqlSession.selectList(COMMUNITY_DAO_NAMESPACE + ".selectBoardWriteCommentListByMap", map);
	}

	@Override
	public int selectBoardWriteCommentCountByMap(Map<String, String> map) throws Exception {
		return sqlSession.selectOne(COMMUNITY_DAO_NAMESPACE + ".selectBoardWriteCommentCountByMap", map);
	}

	@Override
	public int insertBoardWriteCommentReply(CommentReplyDTO dto) throws Exception {
		return sqlSession.insert(COMMUNITY_DAO_NAMESPACE + ".insertBoardWriteCommentReply", dto);
	}

	@Override
	public List<CommentReplyDTO> selectBoardWriteCommentReplyListByMap(Map<String, Integer> map) throws Exception {
		return sqlSession.selectList(COMMUNITY_DAO_NAMESPACE + ".selectBoardWriteCommentReplyListByMap", map);
	}

	@Override
	public int selectBoardWriteCommentReplyCountByBoardCommentId(int id) throws Exception {
		return sqlSession.selectOne(COMMUNITY_DAO_NAMESPACE + ".selectBoardWriteCommentReplyCountByBoardCommentId", id);
	}

	@Override
	public CommentDTO selectBoardWriteCommentByMap(Map<String, Integer> map) throws Exception {
		return sqlSession.selectOne(COMMUNITY_DAO_NAMESPACE + ".selectBoardWriteCommentByMap", map);
	}

	@Override
	public int updateBoardWriteComment(CommentDTO dto) throws Exception {
		return sqlSession.update(COMMUNITY_DAO_NAMESPACE + ".updateBoardWriteComment", dto);
	}

	@Override
	public int deleteBoardWriteComment(Map<String, Integer> map) throws Exception {
		return sqlSession.update(COMMUNITY_DAO_NAMESPACE + ".deleteBoardWriteComment", map);
	}

	@Override
	public Integer selectBoardWriteCommentUserIdByMap(Map<String, Integer> map) throws Exception {
		return sqlSession.selectOne(COMMUNITY_DAO_NAMESPACE + ".selectBoardWriteCommentUserIdByMap", map);
	}

	@Override
	public Integer selectBoardWriteCommentReplyUserIdByMap(Map<String, Integer> map) throws Exception {
		return sqlSession.selectOne(COMMUNITY_DAO_NAMESPACE + ".selectBoardWriteCommentReplyUserIdByMap", map);
	}

	@Override
	public int deleteBoardWriteCommentReply(Map<String, Integer> map) throws Exception {
		return sqlSession.update(COMMUNITY_DAO_NAMESPACE + ".deleteBoardWriteCommentReply", map);
	}

	@Override
	public Integer selectBoardWriteCommentRecommendHistoryTypeByMap(Map<String, String> map) throws Exception {
		return sqlSession.selectOne(COMMUNITY_DAO_NAMESPACE + ".selectBoardWriteCommentRecommendHistoryTypeByMap", map);
	}

	@Override
	public int updateBoardWriteCommentRecommend(Map<String, String> map) throws Exception {
		return sqlSession.update(COMMUNITY_DAO_NAMESPACE + ".updateBoardWriteCommentRecommend", map);
	}

	@Override
	public int insertBoardWriteCommentRecommendHistory(Map<String, String> map) throws Exception {
		return sqlSession.insert(COMMUNITY_DAO_NAMESPACE + ".insertBoardWriteCommentRecommendHistory", map);
	}

	@Override
	public int insertBroadcasterReview(CommentDTO dto) throws Exception {
		return sqlSession.insert(COMMUNITY_DAO_NAMESPACE + ".insertBroadcasterReview", dto);
	}

	@Override
	public List<CommentDTO> selectBroadcasterReviewListByMap(Map<String, String> map) throws Exception {
		return sqlSession.selectList(COMMUNITY_DAO_NAMESPACE + ".selectBroadcasterReviewListByMap", map);
	}

	@Override
	public int selectBroadcasterReviewListCountByMap(Map<String, String> map) throws Exception {
		return sqlSession.selectOne(COMMUNITY_DAO_NAMESPACE + ".selectBroadcasterReviewListCountByMap", map);
	}

	@Override
	public int insertBroadcasterReviewReply(CommentReplyDTO dto) throws Exception {
		return sqlSession.insert(COMMUNITY_DAO_NAMESPACE + ".insertBroadcasterReviewReply", dto);
	}

	@Override
	public List<CommentReplyDTO> selectBroadcasterReviewReplyListByMap(Map<String, Integer> map) throws Exception {
		return sqlSession.selectList(COMMUNITY_DAO_NAMESPACE + ".selectBroadcasterReviewReplyListByMap", map);
	}

	@Override
	public int selectBroadcasterReviewReplyCountByBroadcasterReviewId(int id) throws Exception {
		return sqlSession.selectOne(COMMUNITY_DAO_NAMESPACE + ".selectBroadcasterReviewReplyCountByBroadcasterReviewId", id);
	}

	@Override
	public CommentDTO selectBroadcasterReviewByMap(Map<String, String> map) throws Exception {
		return sqlSession.selectOne(COMMUNITY_DAO_NAMESPACE + ".selectBroadcasterReviewByMap", map);
	}

	@Override
	public int updateBroadcasterReview(CommentDTO dto) throws Exception {
		return sqlSession.update(COMMUNITY_DAO_NAMESPACE + ".updateBroadcasterReview", dto);
	}

	@Override
	public int deleteBroadcasterReview(Map<String, String> map) throws Exception {
		return sqlSession.update(COMMUNITY_DAO_NAMESPACE + ".deleteBroadcasterReview", map);
	}

	@Override
	public int deleteBroadcasterReviewReply(Map<String, Integer> map) throws Exception {
		return sqlSession.update(COMMUNITY_DAO_NAMESPACE + ".deleteBroadcasterReviewReply", map);
	}

	@Override
	public Integer selectBroadcasterReviewRecommendHistoryTypeByMap(Map<String, String> map) throws Exception {
		return sqlSession.selectOne(COMMUNITY_DAO_NAMESPACE + ".selectBroadcasterReviewRecommendHistoryTypeByMap", map);
	}

	@Override
	public int insertBroadcasterReviewRecommendHistory(Map<String, String> map) throws Exception {
		return sqlSession.insert(COMMUNITY_DAO_NAMESPACE + ".insertBroadcasterReviewRecommendHistory", map);
	}

	@Override
	public int updateBroadcasterReviewRecommend(Map<String, String> map) throws Exception {
		return sqlSession.update(COMMUNITY_DAO_NAMESPACE + ".updateBroadcasterReviewRecommend", map);
	}

	@Override
	public int selectBroadcasterReviewCount(Map<String, String> map) throws Exception {
		return sqlSession.selectOne(COMMUNITY_DAO_NAMESPACE + ".selectBroadcasterReviewCount", map);
	}

	@Override
	public List<ReviewGradePointDTO> selectBroadcasterReviewGradePointAverageListByMap(Map<String, String> map) throws Exception {
		return sqlSession.selectList(COMMUNITY_DAO_NAMESPACE + ".selectBroadcasterReviewGradePointAverageListByMap", map);
	}

	@Override
	public ReviewGradePointDTO selectBroadcasterReviewGradePointAverageByMap(Map<String, String> map) throws Exception {
		return sqlSession.selectOne(COMMUNITY_DAO_NAMESPACE + ".selectBroadcasterReviewGradePointAverageByMap", map);
	}

	@Override
	public int selectBroadcasterReviewCountByMap(Map<String, String> map) throws Exception {
		return sqlSession.selectOne(COMMUNITY_DAO_NAMESPACE + ".selectBroadcasterReviewCountByMap", map);
	}

	@Override
	public List<BoardDTO> selectLastNotice() throws Exception {
		return sqlSession.selectList(COMMUNITY_DAO_NAMESPACE + ".selectLastNotice");
	}

	@Override
	public List<BoardDTO> selectCombineBoardWriteListByMap(Map<String, String> map) throws Exception {
		return sqlSession.selectList(COMMUNITY_DAO_NAMESPACE + ".selectCombineBoardWriteListByMap", map);
	}

	@Override
	public int selectCombineBoardWriteCountByMap(Map<String, String> map) throws Exception {
		return sqlSession.selectOne(COMMUNITY_DAO_NAMESPACE + ".selectCombineBoardWriteCountByMap", map);
	}

	@Override
	public BoardDTO selectCombineBoardWriteByMap(Map<String, String> map) throws Exception {
		return sqlSession.selectOne(COMMUNITY_DAO_NAMESPACE + ".selectCombineBoardWriteByMap", map);
	}

	@Override
	public String selectCombineBoardWriteTypeById(int id) throws Exception {
		return sqlSession.selectOne(COMMUNITY_DAO_NAMESPACE + ".selectCombineBoardWriteTypeById", id);
	}

	@Override
	public int updateCombineBoardWriteView(Map<String, String> map) throws Exception {
		return sqlSession.update(COMMUNITY_DAO_NAMESPACE + ".updateCombineBoardWriteView", map);
	}

	@Override
	public BoardDTO selectModifyCombineBoardWriteByMap(Map<String, String> map) throws Exception {
		return sqlSession.selectOne(COMMUNITY_DAO_NAMESPACE + ".selectModifyCombineBoardWriteByMap", map);
	}

	@Override
	public int updateCombineBoardWrite(BoardDTO dto) throws Exception {
		return sqlSession.update(COMMUNITY_DAO_NAMESPACE + ".updateCombineBoardWrite", dto);
	}

	@Override
	public int updateCombineBoardWriteRecommend(Map<String, String> map) throws Exception {
		return sqlSession.update(COMMUNITY_DAO_NAMESPACE + ".updateCombineBoardWriteRecommend", map);
	}

	@Override
	public Integer selectCombineBoardWriteRecommendHistoryTypeByMap(Map<String, String> map) throws Exception {
		return sqlSession.selectOne(COMMUNITY_DAO_NAMESPACE + ".selectCombineBoardWriteRecommendHistoryTypeByMap", map);
	}

	@Override
	public int insertCombineBoardWriteRecommendHistory(Map<String, String> map) throws Exception {
		return sqlSession.insert(COMMUNITY_DAO_NAMESPACE + ".insertCombineBoardWriteRecommendHistory", map);
	}

	@Override
	public int deleteCombineBoardWrite(Map<String, String> map) throws Exception {
		return sqlSession.update(COMMUNITY_DAO_NAMESPACE + ".deleteCombineBoardWrite", map);
	}

	@Override
	public int insertCombineBoardWriteComment(CommentDTO dto) throws Exception {
		return sqlSession.insert(COMMUNITY_DAO_NAMESPACE + ".insertCombineBoardWriteComment", dto);
	}

	@Override
	public List<CommentDTO> selectCombineBoardWriteCommentListByMap(Map<String, String> map) throws Exception {
		return sqlSession.selectList(COMMUNITY_DAO_NAMESPACE + ".selectCombineBoardWriteCommentListByMap", map);
	}

	@Override
	public int selectCombineBoardWriteCommentCountByMap(Map<String, String> map) throws Exception {
		return sqlSession.selectOne(COMMUNITY_DAO_NAMESPACE + ".selectCombineBoardWriteCommentCountByMap", map);
	}

	@Override
	public String selectCombineBoardWriteCommentTypeById(int id) throws Exception {
		return sqlSession.selectOne(COMMUNITY_DAO_NAMESPACE + ".selectCombineBoardWriteCommentTypeById", id);
	}

	@Override
	public CommentDTO selectCombineBoardWriteCommentByMap(Map<String, String> map) throws Exception {
		return sqlSession.selectOne(COMMUNITY_DAO_NAMESPACE + ".selectCombineBoardWriteCommentByMap", map);
	}

	@Override
	public int updateCombineBoardWriteComment(CommentDTO dto) throws Exception {
		return sqlSession.update(COMMUNITY_DAO_NAMESPACE + ".updateCombineBoardWriteComment", dto);
	}

	@Override
	public int deleteCombineBoardWriteComment(Map<String, String> map) throws Exception {
		return sqlSession.update(COMMUNITY_DAO_NAMESPACE + ".deleteCombineBoardWriteComment", map);
	}

	@Override
	public int updateCombineBoardWriteCommentRecommend(Map<String, String> map) throws Exception {
		return sqlSession.update(COMMUNITY_DAO_NAMESPACE + ".updateCombineBoardWriteCommentRecommend", map);
	}

	@Override
	public Integer selectCombineBoardWriteCommentRecommendHistoryTypeByMap(Map<String, String> map) throws Exception {
		return sqlSession.selectOne(COMMUNITY_DAO_NAMESPACE + ".selectCombineBoardWriteCommentRecommendHistoryTypeByMap", map);
	}

	@Override
	public int insertCombineBoardWriteCommentRecommendHistory(Map<String, String> map) throws Exception {
		return sqlSession.insert(COMMUNITY_DAO_NAMESPACE + ".insertCombineBoardWriteCommentRecommendHistory", map);
	}

	@Override
	public int insertCombineBoardWriteCommentReply(CommentReplyDTO dto) throws Exception {
		return sqlSession.insert(COMMUNITY_DAO_NAMESPACE + ".insertCombineBoardWriteCommentReply", dto);
	}

	@Override
	public List<CommentReplyDTO> selectCombineBoardWriteCommentReplyListByMap(Map<String, Integer> map)
			throws Exception {
		return sqlSession.selectList(COMMUNITY_DAO_NAMESPACE + ".selectCombineBoardWriteCommentReplyListByMap", map);
	}

	@Override
	public int selectCombineBoardWriteCommentReplyCountByCombineBoardCommentId(int id) throws Exception {
		return sqlSession.selectOne(COMMUNITY_DAO_NAMESPACE + ".selectCombineBoardWriteCommentReplyCountByCombineBoardCommentId", id);
	}

	@Override
	public String selectCombineBoardWriteCommentReplyTypeById(int id) throws Exception {
		return sqlSession.selectOne(COMMUNITY_DAO_NAMESPACE + ".selectCombineBoardWriteCommentReplyTypeById", id);
	}

	@Override
	public int deleteCombineBoardWriteCommentReply(Map<String, String> map) throws Exception {
		return sqlSession.update(COMMUNITY_DAO_NAMESPACE + ".deleteCombineBoardWriteCommentReply", map);
	}

	@Override
	public List<BoardDTO> selectSearchCombineBoardWriteListByMap(Map<String, String> map) throws Exception {
		return sqlSession.selectList(COMMUNITY_DAO_NAMESPACE + ".selectSearchCombineBoardWriteListByMap", map);
	}

	@Override
	public int selectSearchCombineBoardWriteCountByMap(Map<String, String> map) throws Exception {
		return sqlSession.selectOne(COMMUNITY_DAO_NAMESPACE + ".selectSearchCombineBoardWriteCountByMap", map);
	}

}