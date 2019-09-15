package com.kjh.aps.persistent;

import java.util.List;
import java.util.Map;

import com.kjh.aps.domain.BoardDTO;
import com.kjh.aps.domain.CommentDTO;
import com.kjh.aps.domain.CommentReplyDTO;

public interface CustomerDAO {
	public int insertCustomerServiceBoardWrite(BoardDTO dto) throws Exception;
	public List<BoardDTO> selectCustomerServiceBoardWriteListByMap(Map<String, String> map) throws Exception;
	public int selectCustomerServiceBoardWriteListCountByMap(Map<String, String> map) throws Exception;
	public int insertCustomerServiceBoardWriteComment(CommentDTO dto) throws Exception;
	public List<CommentDTO> selectCustomerServiceBoardWriteCommentListByMap(Map<String, String> map) throws Exception;
	public int selectCustomerServiceBoardWriteCommentListCountByMap(Map<String, String> map) throws Exception;
	public int selectCustomerServiceBoardWriteViewCountById(int id) throws Exception;
	public int updateCustomerServiceBoardWriteViewCount(int id) throws Exception;
	public BoardDTO selectCustomerServiceBoardWriteByMap(Map<String, String> map) throws Exception;
	public int updateCustomerServiceBoardWrite(BoardDTO dto) throws Exception;
	public int deleteCustomerServiceBoardWrite(Map<String, String> map) throws Exception;
	public CommentDTO selectCustomerServiceBoardWriteCommentByMap(Map<String, Integer> map) throws Exception;
	public int updateCustomerServiceBoardWriteComment(CommentDTO dto) throws Exception;
	public Integer selectCustomerServiceBoardWriteCommentRecommendHistoryByMap(Map<String, String> map) throws Exception;
	public int updateCustomerServiceBoardWriteCommentRecommend(Map<String, String> map) throws Exception;
	public int insertCustomerServiceBoardWriteCommentRecommendHistory(Map<String, String> map) throws Exception;
	public int deleteCustomerServiceBoardWriteComment(Map<String, Integer> map) throws Exception;
	public int insertCustomerServiceBoardWriteCommentReply(CommentReplyDTO dto) throws Exception;
	public List<CommentReplyDTO> selectCustomerServiceBoardWriteCommentReplyLisByMap(Map<String, Integer> map) throws Exception;
	public int selectCustomerServiceBoardWriteCommentReplyCountByNoticeCommentId(int noticeCommentId) throws Exception;
	public int deleteCustomerServiceBoardWriteCommentReply(Map<String, Integer> map) throws Exception;
	public List<BoardDTO> selectCustomerServiceSearchBoardWriteListByMap(Map<String, String> map) throws Exception;
	public int selectCustomerServiceSearchBoardWriteCount(Map<String, String> map) throws Exception;
}