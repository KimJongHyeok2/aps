package com.kjh.aps.service;

import java.util.Map;

import com.kjh.aps.domain.BoardDTO;
import com.kjh.aps.domain.CommentDTO;
import com.kjh.aps.domain.CommentReplyDTO;
import com.kjh.aps.domain.CommentReplysDTO;
import com.kjh.aps.domain.CommentsDTO;

public interface CustomerService {
	public String insertCustomerServiceBoardWrite(BoardDTO dto) throws Exception;
	public Map<String, Object> selectCustomerServiceBoardWriteListByMap(Map<String, String> map) throws Exception;
	public String insertCustomerServiceBoardWriteComment(CommentDTO dto) throws Exception;
	public CommentsDTO selectCustomerServiceBoardWriteCommentListByMap(Map<String, String> map) throws Exception;
	public int updateCustomerServiceBoardWriteViewCount(int id) throws Exception;
	public Map<String, Object> selectCustomerServiceBoardWriteByMap(Map<String, String> map) throws Exception;
	public String updateCustomerServiceBoardWrite(BoardDTO dto) throws Exception;
	public String deleteCustomerServiceBoardWrite(Map<String, String> map) throws Exception;
	public Object selectCustomerServiceBoardWriteCommentByMap(Map<String, Integer> map) throws Exception;
	public String updateCustomerServiceBoardWriteComment(CommentDTO dto) throws Exception;
	public String updateCustomerServiceBoardWriteCommentRecommend(Map<String, String> map) throws Exception;
	public String deleteCustomerServiceBoardWriteComment(Map<String, Integer> map) throws Exception;
	public String insertCustomerServiceBoardWriteCommentReply(CommentReplyDTO dto) throws Exception;
	public CommentReplysDTO selectCustomerServiceBoardWriteCommentReplyLisByMap(Map<String, Integer> map) throws Exception;
	public String deleteCustomerServiceBoardWriteCommentReply(Map<String, Integer> map) throws Exception;
	public Map<String, Object> selectCustomerServiceSearchBoardWriteListByMap(Map<String, String> map) throws Exception;
}