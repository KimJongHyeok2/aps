package com.kjh.aps.persistent;

import java.util.List;
import java.util.Map;

import javax.inject.Inject;

import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Repository;

import com.kjh.aps.domain.BoardDTO;
import com.kjh.aps.domain.CommentDTO;
import com.kjh.aps.domain.CommentReplyDTO;

@Repository("CustomerDAO")
public class CustomerDAOImpl implements CustomerDAO {

	@Inject
	private SqlSession sqlSession;
	
	private final String CS_DAO_NAMESPACE = "cs";
	
	@Override
	public int insertCustomerServiceBoardWrite(BoardDTO dto) throws Exception {
		return sqlSession.insert(CS_DAO_NAMESPACE + ".insertCustomerServiceBoardWrite", dto);
	}

	@Override
	public List<BoardDTO> selectCustomerServiceBoardWriteListByMap(Map<String, String> map) throws Exception {
		return sqlSession.selectList(CS_DAO_NAMESPACE + ".selectCustomerServiceBoardWriteListByCategoryId", map);
	}

	@Override
	public int selectCustomerServiceBoardWriteListCountByMap(Map<String, String> map) throws Exception {
		return sqlSession.selectOne(CS_DAO_NAMESPACE + ".selectCustomerServiceBoardWriteListCountByMap", map);
	}

	@Override
	public int insertCustomerServiceBoardWriteComment(CommentDTO dto) throws Exception {
		return sqlSession.insert(CS_DAO_NAMESPACE + ".insertCustomerServiceBoardWriteComment", dto);
	}

	@Override
	public List<CommentDTO> selectCustomerServiceBoardWriteCommentListByMap(Map<String, String> map) throws Exception {
		return sqlSession.selectList(CS_DAO_NAMESPACE + ".selectCustomerServiceBoardWriteCommentListByMap", map);
	}

	@Override
	public int selectCustomerServiceBoardWriteCommentListCountByMap(Map<String, String> map) throws Exception {
		return sqlSession.selectOne(CS_DAO_NAMESPACE + ".selectCustomerServiceBoardWriteCommentListCountByMap", map);
	}

	@Override
	public int selectCustomerServiceBoardWriteViewCountById(int id) throws Exception {
		return sqlSession.selectOne(CS_DAO_NAMESPACE + ".selectCustomerServiceBoardWriteViewCountById", id);
	}

	@Override
	public int updateCustomerServiceBoardWriteViewCount(int id) throws Exception {
		return sqlSession.update(CS_DAO_NAMESPACE + ".updateCustomerServiceBoardWriteViewCount",  id);
	}

	@Override
	public BoardDTO selectCustomerServiceBoardWriteByMap(Map<String, String> map) throws Exception {
		return sqlSession.selectOne(CS_DAO_NAMESPACE + ".selectCustomerServiceBoardWriteByMap", map);
	}

	@Override
	public int updateCustomerServiceBoardWrite(BoardDTO dto) throws Exception {
		return sqlSession.update(CS_DAO_NAMESPACE + ".updateCustomerServiceBoardWrite", dto);
	}

	@Override
	public int deleteCustomerServiceBoardWrite(Map<String, String> map) throws Exception {
		return sqlSession.update(CS_DAO_NAMESPACE + ".deleteCustomerServiceBoardWrite", map);
	}

	@Override
	public CommentDTO selectCustomerServiceBoardWriteCommentByMap(Map<String, Integer> map) throws Exception {
		return sqlSession.selectOne(CS_DAO_NAMESPACE + ".selectCustomerServiceBoardWriteCommentByMap", map);
	}

	@Override
	public int updateCustomerServiceBoardWriteComment(CommentDTO dto) throws Exception {
		return sqlSession.update(CS_DAO_NAMESPACE + ".updateCustomerServiceBoardWriteComment", dto);
	}

	@Override
	public Integer selectCustomerServiceBoardWriteCommentRecommendHistoryByMap(Map<String, String> map) throws Exception {
		return sqlSession.selectOne(CS_DAO_NAMESPACE + ".selectCustomerServiceBoardWriteCommentRecommendHistoryByMap", map);
	}

	@Override
	public int updateCustomerServiceBoardWriteCommentRecommend(Map<String, String> map) throws Exception {
		return sqlSession.update(CS_DAO_NAMESPACE + ".updateCustomerServiceBoardWriteCommentRecommend", map);
	}

	@Override
	public int insertCustomerServiceBoardWriteCommentRecommendHistory(Map<String, String> map) throws Exception {
		return sqlSession.insert(CS_DAO_NAMESPACE + ".insertCustomerServiceBoardWriteCommentRecommendHistory", map);
	}

	@Override
	public int deleteCustomerServiceBoardWriteComment(Map<String, Integer> map) throws Exception {
		return sqlSession.delete(CS_DAO_NAMESPACE + ".deleteCustomerServiceBoardWriteComment", map);
	}

	@Override
	public int insertCustomerServiceBoardWriteCommentReply(CommentReplyDTO dto) throws Exception {
		return sqlSession.insert(CS_DAO_NAMESPACE + ".insertCustomerServiceBoardWriteCommentReply", dto);
	}

	@Override
	public List<CommentReplyDTO> selectCustomerServiceBoardWriteCommentReplyLisByMap(Map<String, Integer> map)
			throws Exception {
		return sqlSession.selectList(CS_DAO_NAMESPACE + ".selectCustomerServiceBoardWriteCommentReplyLisByMap", map);
	}

	@Override
	public int selectCustomerServiceBoardWriteCommentReplyCountByNoticeCommentId(int noticeCommentId) throws Exception {
		return sqlSession.selectOne(CS_DAO_NAMESPACE + ".selectCustomerServiceBoardWriteCommentReplyCountByNoticeCommentId", noticeCommentId);
	}

	@Override
	public int deleteCustomerServiceBoardWriteCommentReply(Map<String, Integer> map) throws Exception {
		return sqlSession.update(CS_DAO_NAMESPACE + ".deleteCustomerServiceBoardWriteCommentReply", map);
	}

	@Override
	public List<BoardDTO> selectCustomerServiceSearchBoardWriteListByMap(Map<String, String> map) throws Exception {
		return sqlSession.selectList(CS_DAO_NAMESPACE + ".selectCustomerServiceSearchBoardWriteListByMap", map);
	}

	@Override
	public int selectCustomerServiceSearchBoardWriteCount(Map<String, String> map) throws Exception {
		return sqlSession.selectOne(CS_DAO_NAMESPACE + ".selectCustomerServiceSearchBoardWriteCount", map);
	}

}