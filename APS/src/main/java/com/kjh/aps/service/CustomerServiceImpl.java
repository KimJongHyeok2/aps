package com.kjh.aps.service;

import java.util.HashMap;
import java.util.Map;

import javax.inject.Inject;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Isolation;
import org.springframework.transaction.annotation.Transactional;

import com.kjh.aps.domain.BoardDTO;
import com.kjh.aps.domain.BoardWritesDTO;
import com.kjh.aps.domain.CommentDTO;
import com.kjh.aps.domain.CommentReplyDTO;
import com.kjh.aps.domain.CommentReplysDTO;
import com.kjh.aps.domain.CommentsDTO;
import com.kjh.aps.domain.PaginationDTO;
import com.kjh.aps.persistent.CustomerDAO;

@Transactional
@Service("CustomerService")
public class CustomerServiceImpl implements CustomerService {

	@Inject
	private CustomerDAO dao;
	
	@Override
	public String insertCustomerServiceBoardWrite(BoardDTO dto) throws Exception { // 고객센터 글 작성
		
		String resultView = "confirm/error_500";
		
		int successCount = dao.insertCustomerServiceBoardWrite(dto);
		
		if(successCount == 1) {
			resultView = "redirect:/customerService/" + dto.getCategory_id();
		}
		
		return resultView;
	}

	@Override
	@Transactional(readOnly = true)
	public Map<String, Object> selectCustomerServiceBoardWriteListByMap(Map<String, String> map) throws Exception { // 고객센터 카테고리에 따른 글 목록
		
		Map<String, Object> maps = new HashMap<>();
		BoardWritesDTO boardWrites = new BoardWritesDTO();
		boardWrites.setBoards(dao.selectCustomerServiceBoardWriteListByMap(map));
		
		if(boardWrites.getBoards() != null && boardWrites.getBoards().size() != 0) {
			boardWrites.setCount(boardWrites.getBoards().size());
		}
		
		boardWrites.setStatus("Success");
		
		int listCount = dao.selectCustomerServiceBoardWriteListCountByMap(map);
		int pageBlock = Integer.parseInt(map.get("pageBlock"));
		int currPage = Integer.parseInt(map.get("currPage"));
		int row = Integer.parseInt(map.get("row"));
		
		PaginationDTO pagination = new PaginationDTO(pageBlock, listCount, currPage, row);
		
		maps.put("boardWrites", boardWrites);
		maps.put("pagination", pagination);
		
		return maps;
	}

	@Override
	public String insertCustomerServiceBoardWriteComment(CommentDTO dto) throws Exception { // 고객센터 글의 댓글 작성
		
		String result = "Fail";
		
		int successCount = 0;
		
		if(!dto.isPrevention()) {			
			successCount = dao.insertCustomerServiceBoardWriteComment(dto);
		} else {
			result = "prevention";
		}
		
		if(successCount == 1) {
			result = "Success";
		}
		
		return result;
	}

	@Override
	@Transactional(readOnly = true)
	public CommentsDTO selectCustomerServiceBoardWriteCommentListByMap(Map<String, String> map) throws Exception { // 고객센터 글의 댓글 목록
		
		CommentsDTO boardComment = new CommentsDTO();
		
		// 댓글 목록
		boardComment.setComments(dao.selectCustomerServiceBoardWriteCommentListByMap(map));
		
		// 댓글이 존재한다면
		if(boardComment.getComments() != null && boardComment.getComments().size() != 0) {
			int listCount = dao.selectCustomerServiceBoardWriteCommentListCountByMap(map);

			PaginationDTO pagination = new PaginationDTO(Integer.parseInt(map.get("pageBlock")), listCount, Integer.parseInt(map.get("currPage")), Integer.parseInt(map.get("row")));
			boardComment.setPagination(pagination);
		
			boardComment.setCount(boardComment.getComments().size());
			
			int charCount = 0;
			for(int i=0; i<boardComment.getCount(); i++) { // 회원 IP 치환
				for(int j=0; j<boardComment.getComments().get(i).getIp().length(); j++) {
					if(boardComment.getComments().get(i).getIp().charAt(j) == '.') {
						charCount += 1;
					}
					
					if(charCount == 2) {
						charCount = 0;
						boardComment.getComments().get(i).setIp(boardComment.getComments().get(i).getIp().substring(0, j));
						break;
					}
				}
			}
		}
		
		boardComment.setStatus("Success");
		
		return boardComment;
	}

	@Override
	@Transactional(isolation=Isolation.READ_COMMITTED)
	public int updateCustomerServiceBoardWriteViewCount(int id) throws Exception { // 고객센터 글의 조회 수 업데이트
		
		int successCount = dao.updateCustomerServiceBoardWriteViewCount(id);
		
		if(successCount == 1) {
			return dao.selectCustomerServiceBoardWriteViewCountById(id);
		}
		
		return 0;
	}

	@Override
	@Transactional(readOnly = true)
	public Map<String, Object> selectCustomerServiceBoardWriteByMap(Map<String, String> map) throws Exception { // 고객센터 글 조회
		
		Map<String, Object> maps = new HashMap<>();
		String result = "Fail";
		
		BoardDTO board = dao.selectCustomerServiceBoardWriteByMap(map);
		
		if(board == null) {
			result = "not_exist";
		} else {
			Integer userId = Integer.parseInt(map.get("user_id"));
			
			if(userId == board.getUser_id()) {
				result = "Success";
			} else {
				result = "error_405";
			}
		}
		
		if(result.equals("Success")) {
			maps.put("board", board);
			maps.put("result", result);
		}
		
		return maps;
	}

	@Override
	public String updateCustomerServiceBoardWrite(BoardDTO dto) throws Exception { // 고객센터 글 수정
		
		String result = "confirm/error_500";
		
		int successCount = dao.updateCustomerServiceBoardWrite(dto);
		
		if(successCount == 1) {
			result = "redirect:/customerService/" + dto.getCategory_id();
		}
		
		return result;
	}

	@Override
	public String deleteCustomerServiceBoardWrite(Map<String, String> map) throws Exception { // 고객센터 글 삭제
		
		String result = "confirm/error_500";
		
		int successCount = dao.deleteCustomerServiceBoardWrite(map);
		
		if(successCount == 1) {
			result = "redirect:/customerService/" + map.get("category_id");
		}
		
		return result;
	}

	@Override
	@Transactional(readOnly = true)
	public Object selectCustomerServiceBoardWriteCommentByMap(Map<String, Integer> map) throws Exception { // 고객센터 글의 댓글 조회
		
		Object result = "error_500";
		
		CommentDTO comment = dao.selectCustomerServiceBoardWriteCommentByMap(map);
		
		if(comment == null) {
			result = "not_exist";
		} else {
			if(comment.getUser_id() == map.get("user_id")) {
				result = comment;
			} else {
				result = "error_405";
			}
		}
		
		return result;
	}

	@Override
	public String updateCustomerServiceBoardWriteComment(CommentDTO dto) throws Exception { // 고객센터 글의 댓글 수정

		String result = "Fail";
		
		int successCount = dao.updateCustomerServiceBoardWriteComment(dto);
		
		if(successCount == 1) {
			result = "Success";
		}
		
		return result;
	}

	@Override
	@Transactional(isolation=Isolation.READ_COMMITTED)
	public String updateCustomerServiceBoardWriteCommentRecommend(Map<String, String> map) throws Exception { // 고객센터 글의 댓글 추천/비추천
		
		String result = "Fail";
		
		Integer recommendHistory = dao.selectCustomerServiceBoardWriteCommentRecommendHistoryByMap(map);
		
		if(recommendHistory == null) {
			int successCount = dao.insertCustomerServiceBoardWriteCommentRecommendHistory(map);
			
			if(successCount == 1) {
				successCount = dao.updateCustomerServiceBoardWriteCommentRecommend(map);
				
				if(successCount == 1) {
					result = "Success";
				}
			}
		} else {
			if(recommendHistory == 1) {
				result = "Already Press Up";
			} else if(recommendHistory == 2) {
				result = "Already Press Down";
			}
		}
		
		return result;
	}

	@Override
	public String deleteCustomerServiceBoardWriteComment(Map<String, Integer> map) throws Exception { // 고객센터 글의 댓글 삭제
		
		String result = "Fail";
		
		int successCount = dao.deleteCustomerServiceBoardWriteComment(map);
		
		if(successCount == 1) {
			result = "Success";
		}
		
		return result;
	}

	@Override
	public String insertCustomerServiceBoardWriteCommentReply(CommentReplyDTO dto) throws Exception { // 고객센터 글 댓글의 답글 작성
		
		String result = "Fail";
		
		int successCount = 0;
		
		if(!dto.isPrevention()) {
			successCount = dao.insertCustomerServiceBoardWriteCommentReply(dto);			
		} else {
			result = "prevention";
		}
		
		if(successCount == 1) {
			result = "Success";
		}
		
		return result;
	}

	@Override
	@Transactional(readOnly = true)
	public CommentReplysDTO selectCustomerServiceBoardWriteCommentReplyLisByMap(Map<String, Integer> map)
			throws Exception { // 고객센터 글 댓글의 답글 목록
		
		CommentReplysDTO boardCommentReply = new CommentReplysDTO();
		
		boardCommentReply.setCommentReplys(dao.selectCustomerServiceBoardWriteCommentReplyLisByMap(map));
		
		if(boardCommentReply.getCommentReplys() != null && boardCommentReply.getCommentReplys().size() != 0) {
			boardCommentReply.setCount(boardCommentReply.getCommentReplys().size());

			boardCommentReply.setReplyCount(dao.selectCustomerServiceBoardWriteCommentReplyCountByNoticeCommentId(map.get("notice_comment_id")));
			
			int charCount = 0;
			for(int i=0; i<boardCommentReply.getCount(); i++) { // 회원 IP 치환
				for(int j=0; j<boardCommentReply.getCommentReplys().get(i).getIp().length(); j++) {
					if(boardCommentReply.getCommentReplys().get(i).getIp().charAt(j) == '.') {
						charCount += 1;
					}
					
					if(charCount == 2) {
						charCount = 0;
						boardCommentReply.getCommentReplys().get(i).setIp(boardCommentReply.getCommentReplys().get(i).getIp().substring(0, j));
						break;
					}
				}
			}
		}
		
		boardCommentReply.setStatus("Success");
		
		return boardCommentReply;
	}

	@Override
	public String deleteCustomerServiceBoardWriteCommentReply(Map<String, Integer> map) throws Exception { // 고객센터 글 댓글의 답글 삭제
		
		String result = "Fail";
		
		int successCount = dao.deleteCustomerServiceBoardWriteCommentReply(map);
		
		if(successCount == 1) {
			result = "Success";
		}
		
		return result;
	}

	@Override
	@Transactional(readOnly = true)
	public Map<String, Object> selectCustomerServiceSearchBoardWriteListByMap(Map<String, String> map)
			throws Exception { // 고객센터 글 검색
		
		Map<String, Object> maps = new HashMap<>();
		
		BoardWritesDTO boardWrites = new BoardWritesDTO();
		
		boardWrites.setBoards(dao.selectCustomerServiceSearchBoardWriteListByMap(map));
		
		if(boardWrites.getBoards() != null && boardWrites.getBoards().size() != 0) {
			boardWrites.setCount(boardWrites.getBoards().size());
			boardWrites.setStatus("Success");
		}
		
		int listCount = dao.selectCustomerServiceSearchBoardWriteCount(map);
		
		int pageBlock = Integer.parseInt(map.get("pageBlock"));
		int currPage = Integer.parseInt(map.get("currPage"));
		int row = Integer.parseInt(map.get("row"));
		
		PaginationDTO pagination = new PaginationDTO(pageBlock, listCount, currPage, row);
		
		maps.put("boardWrites", boardWrites);
		maps.put("pagination", pagination);

		return maps;
	}
	
}