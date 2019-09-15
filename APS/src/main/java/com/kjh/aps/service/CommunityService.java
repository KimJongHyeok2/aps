package com.kjh.aps.service;

import java.util.List;
import java.util.Map;

import com.kjh.aps.domain.CommentReplysDTO;
import com.kjh.aps.domain.CommentsDTO;
import com.kjh.aps.domain.ReviewGradePointDTO;
import com.kjh.aps.domain.ReviewGradePointsDTO;
import com.kjh.aps.domain.BoardDTO;
import com.kjh.aps.domain.BroadcasterDTO;
import com.kjh.aps.domain.CommentDTO;
import com.kjh.aps.domain.CommentReplyDTO;

public interface CommunityService {
	public List<BroadcasterDTO> selectBroadcasterList(String type) throws Exception;
	public List<BroadcasterDTO> selectBroadcasterByMap(Map<String, String> map) throws Exception;
	public Map<String, Object> selectBoardWriteListByMap(Map<String, String> map) throws Exception;
	public BroadcasterDTO selectBroadcasterById(String id) throws Exception;
	/*public int selectBoardWriteCountByMap(Map<String, String> map) throws Exception;*/
	public Map<String, Object> insertBoardWrite(BoardDTO dto) throws Exception;
	public Map<String, Object> selectBoardWriteViewByMap(Map<String, String> map) throws Exception;
	public Map<String, Object> selectBoardWriteByMap(Map<String, String> map) throws Exception;
	public Map<String, Object> selectSearchBoardListByMap(Map<String, String> map) throws Exception;
	public int selectSearchBoardCountByMap(Map<String, String> map) throws Exception;
	public Map<String, Object> updateBoardWrite(BoardDTO dto) throws Exception;
	public String deleteBoardWrite(Map<String, String> map) throws Exception;
	public int updateBoardWriteView(Map<String, String> map) throws Exception;
	/*public Integer selectBoardWriteRecommendHistoryTypeByMap(Map<String, String> map) throws Exception;*/
	public String updateBoardWriteRecommend(Map<String, String> map) throws Exception;
	public int insertBoardWriteRecommendHistory(Map<String, String> map) throws Exception;
	public String insertBoardWriteComment(CommentDTO dto) throws Exception;
	public CommentsDTO selectBoardWriteCommentListByMap(Map<String, String> map) throws Exception;
	public String insertBoardWriteCommentReply(CommentReplyDTO dto) throws Exception;
	public CommentReplysDTO selectBoardWriteCommentReplyListByMap(Map<String, Integer> map) throws Exception;
	public Object selectBoardWriteCommentByMap(Map<String, Integer> map) throws Exception;
	public String updateBoardWriteComment(CommentDTO dto) throws Exception;
	public String deleteBoardWriteComment(Map<String, Integer> map) throws Exception;
	public String deleteBoardWriteCommentReply(Map<String, Integer> map) throws Exception;
	public String updateBoardWriteCommentRecommend(Map<String, String> map) throws Exception;
	public String insertBroadcasterReview(CommentDTO dto) throws Exception;
	public CommentsDTO selectBroadcasterReviewListByMap(Map<String, String> map) throws Exception;
	public int selectBroadcasterReviewListCountByMap(Map<String, String> map) throws Exception;
	public String insertBroadcasterReviewReply(CommentReplyDTO dto) throws Exception;
	public CommentReplysDTO selectBroadcasterReviewReplyListByMap(Map<String, Integer> map) throws Exception;
	public Object selectBroadcasterReviewByMap(Map<String, String> map) throws Exception;
	public String updateBroadcasterReview(CommentDTO dto) throws Exception;
	public String deleteBroadcasterReview(Map<String, String> map) throws Exception;
	public String deleteBroadcasterReviewReply(Map<String, Integer> map) throws Exception;
	public String updateBroadcasterReviewRecommend(Map<String, String> map) throws Exception;
	public ReviewGradePointsDTO selectBroadcasterReviewGradePointAverageListByMap(Map<String, String> map) throws Exception;
	public ReviewGradePointDTO selectBroadcasterReviewGradePointAverageByMap(String broadcasterId) throws Exception;
	public List<BoardDTO> selectLastNotice() throws Exception;
	public Map<String, Object> selectCombineBoardWriteListByMap(Map<String, String> map) throws Exception;
	public Map<String, Object> selectCombineBoardWriteViewByMap(Map<String, String> map) throws Exception;
	public String selectCombineBoardWriteTypeById(int id) throws Exception;
	public Map<String, Object> selectCombineBoardWriteByMap(Map<String, String> map) throws Exception;
	public String updateCombineBoardWrite(BoardDTO dto) throws Exception;
	public String updateCombineBoardWriteRecommend(Map<String, String> map) throws Exception;
	public String deleteCombineBoardWrite(Map<String, String> map) throws Exception;
	public String insertCombineBoardWriteComment(CommentDTO dto) throws Exception;
	public CommentsDTO selectCombineBoardWriteCommentListByMap(Map<String, String> map) throws Exception;
	public String selectCombineBoardWriteCommentTypeById(int id) throws Exception;
	public Map<String, Object> selectCombineBoardWriteCommentByMap(Map<String, String> map) throws Exception;
	public String updateCombineBoardWriteComment(CommentDTO dto) throws Exception;
	public String deleteCombineBoardWriteComment(Map<String, String> map) throws Exception;
	public String updateCombineBoardWriteCommentRecommend(Map<String, String> map) throws Exception;
	public String insertCombineBoardWriteCommentReply(CommentReplyDTO dto) throws Exception;
	public CommentReplysDTO selectCombineBoardWriteCommentReplyListByMap(Map<String, Integer> map) throws Exception;
	public String selectCombineBoardWriteCommentReplyTypeById(int id) throws Exception;
	public String deleteCombineBoardWriteCommentReply(Map<String, String> map) throws Exception;
	public Map<String, Object> selectSearchCombineBoardWriteListByMap(Map<String, String> map) throws Exception;
}