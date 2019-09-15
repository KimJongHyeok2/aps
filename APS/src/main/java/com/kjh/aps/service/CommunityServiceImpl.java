package com.kjh.aps.service;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.TimeZone;

import javax.inject.Inject;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Isolation;
import org.springframework.transaction.annotation.Transactional;

import com.kjh.aps.domain.CommentReplysDTO;
import com.kjh.aps.domain.CommentsDTO;
import com.kjh.aps.domain.BoardDTO;
import com.kjh.aps.domain.BoardWritesDTO;
import com.kjh.aps.domain.BroadcasterDTO;
import com.kjh.aps.domain.CommentDTO;
import com.kjh.aps.domain.CommentReplyDTO;
import com.kjh.aps.domain.PaginationDTO;
import com.kjh.aps.domain.ReviewGradePointDTO;
import com.kjh.aps.domain.ReviewGradePointsDTO;
import com.kjh.aps.persistent.CommunityDAO;

@Transactional
@Service("CommunityService")
public class CommunityServiceImpl implements CommunityService {

	@Inject
	private CommunityDAO dao;
	
	private TimeZone timezone = TimeZone.getTimeZone("Asia/Seoul");
	private SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
	
	@Override
	@Transactional(readOnly = true)
	public List<BroadcasterDTO> selectBroadcasterList(String type) throws Exception { // 방송인 커뮤니티 목록
		return dao.selectBroadcasterList(type);
	}

	@Override
	@Transactional(readOnly = true)
	public List<BroadcasterDTO> selectBroadcasterByMap(Map<String, String> map) throws Exception { // 방송인 커뮤니티 검색
		return dao.selectBroadcasterByMap(map);
	}

	@Override
	@Transactional(readOnly = true)
	public Map<String, Object> selectBoardWriteListByMap(Map<String, String> map) throws Exception { // 방송인 커뮤니티 게시판 글 목록
	
		Map<String, Object> maps = new HashMap<>();
		String result = "Fail";
		String listType = map.get("listType");
		
		if(listType.equals("today")) { // 게시글 정렬 타입
			Calendar today = Calendar.getInstance(timezone);
			map.put("today", sdf.format(today.getTime()));
		} else if(listType.equals("week")) {
			Calendar startDay = Calendar.getInstance(timezone); // 이번 주의 시작
			Calendar endDay = Calendar.getInstance(timezone); // 이번 주의 끝
			
			startDay.add(Calendar.DATE, -startDay.get(Calendar.DAY_OF_WEEK) + 1);
			endDay.set(Calendar.DAY_OF_WEEK, Calendar.SUNDAY);
			endDay.add(Calendar.DATE, 7);
			
			map.put("startDay", sdf.format(startDay.getTime()));
			map.put("endDay", sdf.format(endDay.getTime()));
		} else if(listType.equals("month")) {
			Calendar month = Calendar.getInstance(timezone);
			map.put("month", sdf.format(month.getTime()));
		}
		
		BroadcasterDTO broadcaster = dao.selectBroadcasterById(map.get("id"));
		
		if(broadcaster == null) {
			result = "not_exist";
		} else {
			BoardWritesDTO boards = new BoardWritesDTO();
			boards.setBoards(dao.selectBoardWriteListByMap(map));
			
			if(boards.getBoards() != null && boards.getBoards().size() != 0) {
				boards.setCount(boards.getBoards().size());
				boards.setStatus("Success");
			}
			
			int listCount = dao.selectBoardWriteCountByMap(map);
			
			PaginationDTO pagination = new PaginationDTO(Integer.parseInt(map.get("pageBlock")), listCount, Integer.parseInt(map.get("currPage")), Integer.parseInt(map.get("row")));
			
			maps.put("broadcaster", broadcaster);
			maps.put("boards", boards);
			maps.put("pagination", pagination);
			result = "Success";
		}
		
		maps.put("result", result);
		
		return maps;
	}
	
	@Override
	@Transactional(readOnly = true)
	public BroadcasterDTO selectBroadcasterById(String id) throws Exception { // 방송인 정보
		return dao.selectBroadcasterById(id);
	}

	@Override
	public Map<String, Object> insertBoardWrite(BoardDTO dto) throws Exception { // 방송인 커뮤니티 게시판 글 작성
		
		Map<String, Object> map = new HashMap<>();
		String result = "Fail";
		
		int successCount = 0;
		
		if(!dto.isPrevention()) { // 도배 제한에 걸려있지 않아야 DB에 글 등록
			successCount = dao.insertBoardWrite(dto);
		}
	
		if(successCount == 1) {
			result = "Success";
		} else {
			map.put("broadcaster", dao.selectBroadcasterById(dto.getBroadcaster_id()));
		}
		
		map.put("result", result);
		
		return map;
	}
	
	@Override
	public Map<String, Object> selectBoardWriteViewByMap(Map<String, String> map) throws Exception { // 방송인 커뮤니티 게시판 글 상세보기
		
		Map<String, Object> maps = new HashMap<>();
		String result = "Fail";
		String listType = map.get("listType");
		String view = map.get("view");
		
		if(listType.equals("today")) { // 게시글 정렬 타입
			Calendar today = Calendar.getInstance(timezone);
			map.put("today", sdf.format(today.getTime()));
		} else if(listType.equals("week")) {
			Calendar startDay = Calendar.getInstance(timezone); // 이번 주의 시작
			Calendar endDay = Calendar.getInstance(timezone); // 이번 주의 끝
			
			startDay.add(Calendar.DATE, -startDay.get(Calendar.DAY_OF_WEEK) + 1);
			endDay.set(Calendar.DAY_OF_WEEK, Calendar.SUNDAY);
			endDay.add(Calendar.DATE, 7);
			
			map.put("startDay", sdf.format(startDay.getTime()));
			map.put("endDay", sdf.format(endDay.getTime()));
		} else if(listType.equals("month")) {
			Calendar today = Calendar.getInstance(timezone);
			map.put("month", sdf.format(today.getTime()));
		}
		
		if(view.equals("true")) {
			dao.updateBoardWriteView(map);
		}
		
		BoardDTO board = dao.selectBoardWriteByMap(map);
		BroadcasterDTO broadcaster = dao.selectBroadcasterById(map.get("broadcaster_id"));
		
		int charCount = 0;
		for(int i=0; i<board.getIp().length(); i++) {
			if(board.getIp().charAt(i) == '.') {
				charCount += 1;
			}
			
			if(charCount == 2) {
				board.setIp(board.getIp().substring(0, i));
			}
		}
		
		if(board == null || broadcaster == null) {
			result = "not_exist";
		} else {
			map.put("id", board.getBroadcaster_id());
			
			BoardWritesDTO boards = new BoardWritesDTO();
			boards.setBoards(dao.selectBoardWriteListByMap(map));
			
			if(boards.getBoards() != null && boards.getBoards().size() != 0) {
				boards.setCount(boards.getBoards().size());
				boards.setStatus("Success");
			}
			
			int listCount = dao.selectBoardWriteCountByMap(map);
			
			PaginationDTO pagination = new PaginationDTO(Integer.parseInt(map.get("pageBlock")), listCount, Integer.parseInt(map.get("currPage")), Integer.parseInt(map.get("row")));
			maps.put("broadcaster", broadcaster); 
			maps.put("board", board);
			maps.put("boards", boards);
			maps.put("pagination", pagination);
			result = "Success";
		}
		
		maps.put("result", result);
		
		return maps;
	}

	@Override
	@Transactional(readOnly = true)
	public Map<String, Object> selectBoardWriteByMap(Map<String, String> map) throws Exception { // 방송인 커뮤니티 게시판 글 정보조회
				
		Map<String, Object> maps = new HashMap<>();
		String result = "Fail";
		
		BoardDTO board = dao.selectBoardWriteByMap(map);
		
		if(board == null) {
			result = "not_exist";
		} else {
			Integer userId = Integer.parseInt(map.get("userId"));
			
			if(board.getUser_id() == userId) {
				result = "Success";
			} else {
				result = "error_405";
			}
		}
		
		if(result.equals("Success")) {
			maps.put("board", board);
		}
		
		maps.put("result", result);
		maps.put("broadcaster", dao.selectBroadcasterById(board.getBroadcaster_id()));

		return maps;
	}

	@Override
	@Transactional(readOnly = true)
	public Map<String, Object> selectSearchBoardListByMap(Map<String, String> map) throws Exception { // 방송인 커뮤니티 게시판 글 검색
		
		Map<String, Object> maps = new HashMap<>();
		String result = "Fail";
		String listType = map.get("listType");
		
		if(listType.equals("today")) { // 게시글 정렬 타입
			Calendar today = Calendar.getInstance(timezone);
			map.put("today", sdf.format(today.getTime()));
		} else if(listType.equals("week")) {
			Calendar startDay = Calendar.getInstance(timezone); // 이번 주의 시작
			Calendar endDay = Calendar.getInstance(timezone); // 이번 주의 끝
			
			startDay.add(Calendar.DATE, -startDay.get(Calendar.DAY_OF_WEEK) + 1);
			endDay.set(Calendar.DAY_OF_WEEK, Calendar.SUNDAY);
			endDay.add(Calendar.DATE, 7);
			
			map.put("startDay", sdf.format(startDay.getTime()));
			map.put("endDay", sdf.format(endDay.getTime()));
		} else if(listType.equals("month")) {
			Calendar month = Calendar.getInstance(timezone);
			map.put("month", sdf.format(month.getTime()));
		}
		
		BroadcasterDTO broadcaster = dao.selectBroadcasterById(map.get("id"));
		
		if(broadcaster == null) {
			result = "not_exist";
		} else {
			BoardWritesDTO boards = new BoardWritesDTO();
			boards.setBoards(dao.selectSearchBoardListByMap(map));
			
			if(boards.getBoards() != null && boards.getBoards().size() != 0) {
				boards.setCount(boards.getBoards().size());
				boards.setStatus("Success");
			}
			
			int listCount = dao.selectSearchBoardCountByMap(map);
			
			PaginationDTO pagination = new PaginationDTO(Integer.parseInt(map.get("pageBlock")), listCount, Integer.parseInt(map.get("currPage")), Integer.parseInt(map.get("row")));
			
			maps.put("broadcaster", broadcaster);
			maps.put("boards", boards);
			maps.put("pagination", pagination);
			result = "Success";
		}
		
		maps.put("result", result);
		
		return maps;
	}

	@Override
	@Transactional(readOnly = true)
	public int selectSearchBoardCountByMap(Map<String, String> map) throws Exception { // 방송인 커뮤니티 게시판 검색된 글 수
		return dao.selectSearchBoardCountByMap(map);
	}

	@Override
	public Map<String, Object> updateBoardWrite(BoardDTO dto) throws Exception { // 방송인 커뮤니티 게시판 글 수정
		
		Map<String, Object> map = new HashMap<>();
		String result = "Fail";
		
		int successCount = dao.updateBoardWrite(dto);
		
		if(successCount == 1) {
			result = "Success";
		} else {
			map.put("broadcaster", dao.selectBroadcasterById(dto.getBroadcaster_id()));
		}
		
		map.put("result", result);
		
		return map;
	}

	@Override
	public String deleteBoardWrite(Map<String, String> map) throws Exception { // 방송인 커뮤니티 게시판 글 삭제
		
		String result = "Fail";
		
		Integer boardUserId = dao.selectBoardWriteUserIdByMap(map);
		
		if(!(boardUserId == null)) {
			Integer userId = Integer.parseInt(map.get("userId"));
			
			if(boardUserId == userId) {
				map.put("user_id", String.valueOf(userId));
				int successCount = dao.deleteBoardWrite(map);
				
				if(successCount == 1) {
					result = "Success";
				}
			}
		}
		
		return result; 
	}

	@Override
	public int updateBoardWriteView(Map<String, String> map) throws Exception { // 방송인 커뮤니티 게시판 글 조회수 증가
		return dao.updateBoardWriteView(map);
	}

	@Override
	@Transactional(isolation=Isolation.READ_COMMITTED)
	public String updateBoardWriteRecommend(Map<String, String> map) throws Exception { // 방송인 커뮤니티 게시판 글 댓글 추천 증가
		
		String result = "Fail";
		
		Integer recommendHistoryType = dao.selectBoardWriteRecommendHistoryTypeByMap(map);

		if(recommendHistoryType == null) {
			int successCount = dao.updateBoardWriteRecommend(map);

			if(successCount == 1) {
				successCount = dao.insertBoardWriteRecommendHistory(map);
	
				if(successCount == 1) {
					result = "Success";
				}
			}
		} else {
			if(recommendHistoryType == 1) {
				result = "Already Press Up";
			} else if(recommendHistoryType == 2) {
				result = "Already Press Down";
			}
		}
		
		return result;
	}

	@Override
	public int insertBoardWriteRecommendHistory(Map<String, String> map) throws Exception { // 방송인 커뮤니티 게시판 글 추천 기록 추가
		return dao.insertBoardWriteRecommendHistory(map);
	}

	@Override
	public String insertBoardWriteComment(CommentDTO dto) throws Exception { // 방송인 커뮤니티 게시판 글 댓글 작성
		
		 String result = "Fail";
		 
		 int successCount = 0;
		 
		 if(!dto.isPrevention()) { 
			 successCount = dao.insertBoardWriteComment(dto);
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
	public CommentsDTO selectBoardWriteCommentListByMap(Map<String, String> map) throws Exception { // 방송인 커뮤니티 게시판 글 댓글 목록

		CommentsDTO boardComment = new CommentsDTO();
		
		// 댓글 목록
		boardComment.setComments(dao.selectBoardWriteCommentListByMap(map));
		
		// 댓글이 존재한다면
		if(boardComment.getComments() != null && boardComment.getComments().size() != 0) {
			int listCount = dao.selectBoardWriteCommentCountByMap(map);
			
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
	public String insertBoardWriteCommentReply(CommentReplyDTO dto) throws Exception { // 방송인 커뮤니티 게시판 글의 답글 추가
		
		String result = "Fail";
		
		int successCount = 0;
		
		 if(!dto.isPrevention()) { 
			 successCount = dao.insertBoardWriteCommentReply(dto);
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
	public CommentReplysDTO selectBoardWriteCommentReplyListByMap(Map<String, Integer> map) throws Exception { // 방송인 커뮤니티 게시판 글의 답글 목록

		CommentReplysDTO boardCommentReply = new CommentReplysDTO();
		
		boardCommentReply.setCommentReplys(dao.selectBoardWriteCommentReplyListByMap(map));
		
		if(boardCommentReply.getCommentReplys() != null && boardCommentReply.getCommentReplys().size() != 0) {
			boardCommentReply.setCount(boardCommentReply.getCommentReplys().size());

			boardCommentReply.setReplyCount(dao.selectBoardWriteCommentReplyCountByBoardCommentId(map.get("broadcaster_board_comment_id")));
			
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
	@Transactional(readOnly = true)
	public Object selectBoardWriteCommentByMap(Map<String, Integer> map) throws Exception { // 방송인 커뮤니티 게시판 글 댓글 조회
		
		Object result = "Fail";
		
		CommentDTO comment = dao.selectBoardWriteCommentByMap(map);
		
		if(comment == null) {
			result = "not_exist";
		} else {
			if(comment.getUser_id() == map.get("userId")) {
				result = comment;
			} else {
				result = "error_405";
			}
		}
		
		return result; 
	}

	@Override
	public String updateBoardWriteComment(CommentDTO dto) throws Exception { // 방송인 커뮤니티 게시판 글 댓글 수정
		
		String result = "Fail";
		
		int successCount = dao.updateBoardWriteComment(dto);
		
		if(successCount == 1) {
			result = "Success";
		}
		
		return result;
	}

	@Override
	public String deleteBoardWriteComment(Map<String, Integer> map) throws Exception { // 방송인 커뮤니티 게시판 글 댓글 삭제
		
		String result = "Fail";
		
		Integer commentUserId = dao.selectBoardWriteCommentUserIdByMap(map);
		
		if(commentUserId != null) { // 정상적으로 불러왔다면
			Integer userId = map.get("userId");
			
			if(commentUserId == userId) { // 삭제를 요청한 회원의 고유번호와 일치한다면
				map.put("user_id", userId);
				
				int successCount = dao.deleteBoardWriteComment(map);
				
				if(successCount == 1) { // 정상적으로 삭제처리 되었다면
					result = "Success";
				}
			}
		}
		
		return result;
	}

	@Override
	public String deleteBoardWriteCommentReply(Map<String, Integer> map) throws Exception { // 방송인 커뮤니티 게시판 글의 답글 삭제

		String result = "Fail";
		
		Integer commentReplyUserId = dao.selectBoardWriteCommentReplyUserIdByMap(map);
		
		if(commentReplyUserId != null) {
			Integer userId = map.get("userId");
			
			if(commentReplyUserId == userId) {
				map.put("user_id", userId);
				int successCount = dao.deleteBoardWriteCommentReply(map);
				
				if(successCount == 1) {
					result = "Success";
				}
			}
		}
		
		return result;
	}
	
	@Override
	@Transactional(isolation=Isolation.READ_COMMITTED)
	public String updateBoardWriteCommentRecommend(Map<String, String> map) throws Exception { // 방송인 커뮤니티 게시판 글 댓글 추천 증가
		
		String result = "Fail";
		
		Integer recommendHistoryType = dao.selectBoardWriteCommentRecommendHistoryTypeByMap(map);
			
		if(recommendHistoryType == null) {
			int successCount = dao.updateBoardWriteCommentRecommend(map);
	
			if(successCount == 1) {
				successCount = dao.insertBoardWriteCommentRecommendHistory(map);
	
				if(successCount == 1) {
					result = "Success";
				}
			}
		} else {
			if(recommendHistoryType == 1) {
				result = "Already Press Up";
			} else if(recommendHistoryType == 2) {
				result = "Already Press Down";
			}
		}
		
		return result;
	}

	@Override
	public String insertBroadcasterReview(CommentDTO dto) throws Exception { // 방송인 평가 등록
		
		String result = "Fail";
		
		Map<String, String> map = new HashMap<>();
		Calendar today = Calendar.getInstance(timezone);
		map.put("today", sdf.format(today.getTime()));
		map.put("broadcaster_id", dto.getBroadcaster_id());
		map.put("user_id", String.valueOf(dto.getUser_id()));
		map.put("ip", dto.getIp());
		
		int todayReviewCount = dao.selectBroadcasterReviewCountByMap(map);
		int successCount = 0;
		
		if(todayReviewCount == 0) {
			successCount = dao.insertBroadcasterReview(dto);
		} else {
			result = "Already Review Write";
		}
		
		if(successCount == 1) {
			result = "Success";
		}
		
		return result;
	}

	@Override
	@Transactional(readOnly = true)
	public CommentsDTO selectBroadcasterReviewListByMap(Map<String, String> map) throws Exception { // 방송인 평가 목록
		
		CommentsDTO reviews = new CommentsDTO();
		String listType1 = map.get("listType1");
		
		if(listType1.equals("today")) {
			Calendar today = Calendar.getInstance(timezone);
			map.put("today", sdf.format(today.getTime()));
		} else if(listType1.equals("week")) {
			Calendar startDay = Calendar.getInstance(timezone); // 이번 주의 시작
			Calendar endDay = Calendar.getInstance(timezone); // 이번 주의 끝
			
			startDay.add(Calendar.DATE, -startDay.get(Calendar.DAY_OF_WEEK) + 1);
			endDay.set(Calendar.DAY_OF_WEEK, Calendar.SUNDAY);
			endDay.add(Calendar.DATE, 7);

			map.put("startDay", sdf.format(startDay.getTime()));
			map.put("endDay", sdf.format(endDay.getTime()));
		} else if(listType1.equals("month")) {
			Calendar month = Calendar.getInstance(timezone);
			map.put("month", sdf.format(month.getTime()));
		}
		
		reviews.setComments(dao.selectBroadcasterReviewListByMap(map));
		
		if(reviews.getComments() != null && reviews.getComments().size() != 0) {
			reviews.setCount(reviews.getComments().size());
			reviews.setReviewCount(dao.selectBroadcasterReviewCount(map));
			
			int listCount = dao.selectBroadcasterReviewListCountByMap(map);

			PaginationDTO pagination = new PaginationDTO(Integer.parseInt(map.get("pageBlock")), listCount, Integer.parseInt(map.get("currPage")), Integer.parseInt(map.get("row")));
			reviews.setPagination(pagination);
			
			int charCount = 0;
			for(int i=0; i<reviews.getCount(); i++) { // 회원 IP 치환
				for(int j=0; j<reviews.getComments().get(i).getIp().length(); j++) {
					if(reviews.getComments().get(i).getIp().charAt(j) == '.') {
						charCount += 1;
					}
					
					if(charCount == 2) {
						charCount = 0;
						reviews.getComments().get(i).setIp(reviews.getComments().get(i).getIp().substring(0, j));
						break;
					}
				}
			}
		}

		reviews.setStatus("Success");
		
		return reviews;
	}

	@Override
	@Transactional(readOnly = true)
	public int selectBroadcasterReviewListCountByMap(Map<String, String> map) throws Exception { // 방송인 평가 수
		return dao.selectBroadcasterReviewListCountByMap(map);
	}

	@Override
	public String insertBroadcasterReviewReply(CommentReplyDTO dto) throws Exception { // 방송인 평가 답글 등록
		
		String result = "Fail";
		
		int successCount = 0;
		
		if(!dto.isPrevention()) {
			successCount = dao.insertBroadcasterReviewReply(dto);			
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
	public CommentReplysDTO selectBroadcasterReviewReplyListByMap(Map<String, Integer> map) throws Exception { // 방송인 평가 답글 목록
		
		CommentReplysDTO reviewReplys = new CommentReplysDTO();
		
		reviewReplys.setCommentReplys(dao.selectBroadcasterReviewReplyListByMap(map));
		
		if(reviewReplys.getCommentReplys() != null && reviewReplys.getCommentReplys().size() != 0) {
			reviewReplys.setCount(reviewReplys.getCommentReplys().size());
			
			reviewReplys.setReplyCount(dao.selectBroadcasterReviewReplyCountByBroadcasterReviewId(map.get("broadcaster_review_id"))); // 해당 리뷰 답글 수
			
			int charCount = 0;
			for(int i=0; i<reviewReplys.getCount(); i++) { // 회원 IP 치환
				for(int j=0; j<reviewReplys.getCommentReplys().get(i).getIp().length(); j++) {
					if(reviewReplys.getCommentReplys().get(i).getIp().charAt(j) == '.') {
						charCount += 1;
					}
					
					if(charCount == 2) {
						charCount = 0;
						reviewReplys.getCommentReplys().get(i).setIp(reviewReplys.getCommentReplys().get(i).getIp().substring(0, j));
						break;
					}
				}
			}
		}
		
		reviewReplys.setStatus("Success");
		
		return reviewReplys;
	}

	@Override
	@Transactional(readOnly = true)
	public Object selectBroadcasterReviewByMap(Map<String, String> map) throws Exception { // 평가 불러오기
		
		Object result = "Fail";
		
		CommentDTO comment = dao.selectBroadcasterReviewByMap(map);
		
		if(comment == null) {
			result = "error_404";
		} else {
			if(comment.getUser_id() == Integer.parseInt(map.get("user_id"))) {
				result = comment;
			} else {
				result = "error_405";
			}
		}
		
		return result;
	}

	@Override
	public String updateBroadcasterReview(CommentDTO dto) throws Exception { // 평가 수정
		
		String result = "Fail";
		
		int successCount = dao.updateBroadcasterReview(dto);
		
		if(successCount == 1) {
			result = "Success";
		}
		
		return result;
	}

	@Override
	public String deleteBroadcasterReview(Map<String, String> map) throws Exception { // 평가 삭제
		
		String result = "Fail";
		
		int successCount = dao.deleteBroadcasterReview(map);
		
		if(successCount == 1) {
			result = "Success";
		}
		
		return result;
	}

	@Override
	public String deleteBroadcasterReviewReply(Map<String, Integer> map) throws Exception { // 평가의 답글 삭제
		
		String result = "Fail";
		
		int successCount = dao.deleteBroadcasterReviewReply(map);
		
		if(successCount == 1) {
			result = "Success";
		}
		
		return result;
	}

	@Override
	@Transactional(isolation=Isolation.READ_COMMITTED)
	public String updateBroadcasterReviewRecommend(Map<String, String> map) throws Exception { // 평가 글 추천

		String result = "Fail";
		
		Integer recommendHistory = dao.selectBroadcasterReviewRecommendHistoryTypeByMap(map);
		
		if(recommendHistory == null) {
			int successCount = dao.updateBroadcasterReviewRecommend(map);
			
			if(successCount == 1) {
				successCount = dao.insertBroadcasterReviewRecommendHistory(map);
				
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
	@Transactional(readOnly = true)
	public ReviewGradePointsDTO selectBroadcasterReviewGradePointAverageListByMap(Map<String, String> map) throws Exception { // 기간별 평점 평균 목록
		
		ReviewGradePointsDTO reviewGradePoints = new ReviewGradePointsDTO();
		String dataType = map.get("dataType");
		
		if(dataType.equals("week")) {
			Calendar startDay = Calendar.getInstance(timezone); // 이번 주의 시작
			Calendar endDay = Calendar.getInstance(timezone); // 이번 주의 끝
			
			startDay.add(Calendar.DATE, -startDay.get(Calendar.DAY_OF_WEEK) + 1);
			endDay.set(Calendar.DAY_OF_WEEK, Calendar.SUNDAY);
			endDay.add(Calendar.DATE, 7);
			
			map.put("startDay", sdf.format(startDay.getTime()));
			map.put("endDay", sdf.format(endDay.getTime()));
		} else if(dataType.equals("month")) {
			Calendar year = Calendar.getInstance(timezone);
			
			map.put("year", sdf.format(year.getTime()));
		}
		
		reviewGradePoints.setGradePointAverages(dao.selectBroadcasterReviewGradePointAverageListByMap(map));
		
		if(reviewGradePoints.getGradePointAverages() != null && reviewGradePoints.getGradePointAverages().size() != 0) {
			reviewGradePoints.setCount(reviewGradePoints.getGradePointAverages().size());
		}
		
		reviewGradePoints.setStatus("Success");
		
		return reviewGradePoints;
	}

	@Override
	@Transactional(readOnly = true)
	public ReviewGradePointDTO selectBroadcasterReviewGradePointAverageByMap(String broadcasterId) throws Exception { // 일일, 주간, 월간 평점 평균
		
		Map<String, String> map = new HashMap<>();
		map.put("broadcaster_id", broadcasterId);
		
		Calendar today = Calendar.getInstance(timezone);
		Calendar startDay = Calendar.getInstance(timezone);
		Calendar endDay = Calendar.getInstance(timezone);
		
		startDay.add(Calendar.DATE, -startDay.get(Calendar.DAY_OF_WEEK) + 1); // 이번 주의 시작
		endDay.set(Calendar.DAY_OF_WEEK, Calendar.SUNDAY); // 이번 주의 끝
		endDay.add(Calendar.DATE, 7);
		
		map.put("today", sdf.format(today.getTime()));
		map.put("startDay", sdf.format(startDay.getTime()));
		map.put("endDay", sdf.format(endDay.getTime()));
		
		return dao.selectBroadcasterReviewGradePointAverageByMap(map);
	}

	@Override
	@Transactional(readOnly = true)
	public List<BoardDTO> selectLastNotice() throws Exception { // 최근 공지사항 목록
		return dao.selectLastNotice();
	}

	@Override
	@Transactional(readOnly = true)
	public Map<String, Object> selectCombineBoardWriteListByMap(Map<String, String> map) throws Exception { // 통합 게시판 게시글 목록
		
		Map<String, Object> maps = new HashMap<>();
		String result = "Fail";
		String listType = map.get("listType");
		
		if(listType.equals("today")) { // 게시글 정렬 타입
			Calendar today = Calendar.getInstance(timezone);
			map.put("today", sdf.format(today.getTime()));
		} else if(listType.equals("week")) {
			Calendar startDay = Calendar.getInstance(timezone); // 이번 주의 시작
			Calendar endDay = Calendar.getInstance(timezone); // 이번 주의 끝
			
			startDay.add(Calendar.DATE, -startDay.get(Calendar.DAY_OF_WEEK) + 1);
			endDay.set(Calendar.DAY_OF_WEEK, Calendar.SUNDAY);
			endDay.add(Calendar.DATE, 7);
			
			map.put("startDay", sdf.format(startDay.getTime()));
			map.put("endDay", sdf.format(endDay.getTime()));
		} else if(listType.equals("month")) {
			Calendar month = Calendar.getInstance(timezone);
			map.put("month", sdf.format(month.getTime()));
		}

		BoardWritesDTO boards = new BoardWritesDTO();
		boards.setBoards(dao.selectCombineBoardWriteListByMap(map));
			
		if(boards.getBoards() != null && boards.getBoards().size() != 0) {
			boards.setCount(boards.getBoards().size());
			boards.setStatus("Success");
		}

		int listCount = dao.selectCombineBoardWriteCountByMap(map);
			
		PaginationDTO pagination = new PaginationDTO(Integer.parseInt(map.get("pageBlock")), listCount, Integer.parseInt(map.get("currPage")), Integer.parseInt(map.get("row")));
			
		maps.put("boards", boards);
		maps.put("pagination", pagination);
		result = "Success";
		
		maps.put("result", result);
		
		return maps;
	}

	@Override
	public Map<String, Object> selectCombineBoardWriteViewByMap(Map<String, String> map) throws Exception { // 통합 게시판 게시글 상세보기
		
		Map<String, Object> maps = new HashMap<>();
		String result = "Fail";
		String listType = map.get("listType");
		String view = map.get("view");
		
		if(listType.equals("today")) { // 게시글 정렬 타입
			Calendar today = Calendar.getInstance(timezone);
			map.put("today", sdf.format(today.getTime()));
		} else if(listType.equals("week")) {
			Calendar startDay = Calendar.getInstance(timezone); // 이번 주의 시작
			Calendar endDay = Calendar.getInstance(timezone); // 이번 주의 끝
			
			startDay.add(Calendar.DATE, -startDay.get(Calendar.DAY_OF_WEEK) + 1);
			endDay.set(Calendar.DAY_OF_WEEK, Calendar.SUNDAY);
			endDay.add(Calendar.DATE, 7);
			
			map.put("startDay", sdf.format(startDay.getTime()));
			map.put("endDay", sdf.format(endDay.getTime()));
		} else if(listType.equals("month")) {
			Calendar today = Calendar.getInstance(timezone);
			map.put("month", sdf.format(today.getTime()));
		}
		
		if(view.equals("true")) {
			dao.updateCombineBoardWriteView(map);
		}
		
		BoardDTO board = dao.selectCombineBoardWriteByMap(map);
		
		int charCount = 0;
		
		if(board == null) {
			result = "not_exist";
		} else {
			for(int i=0; i<board.getIp().length(); i++) { // 작성자 IP 치환
				if(board.getIp().charAt(i) == '.') {
					charCount += 1;
				}
				
				if(charCount == 2) {
					board.setIp(board.getIp().substring(0, i));
				}
			}
			
			BoardWritesDTO boards = new BoardWritesDTO();
			boards.setBoards(dao.selectCombineBoardWriteListByMap(map));
			
			if(boards.getBoards() != null && boards.getBoards().size() != 0) {
				boards.setCount(boards.getBoards().size());
				boards.setStatus("Success");
			}
			
			int listCount = dao.selectCombineBoardWriteCountByMap(map);
			
			PaginationDTO pagination = new PaginationDTO(Integer.parseInt(map.get("pageBlock")), listCount, Integer.parseInt(map.get("currPage")), Integer.parseInt(map.get("row")));
			maps.put("board", board);
			maps.put("boards", boards);
			maps.put("pagination", pagination);
			result = "Success";
		}
		
		maps.put("result", result);
		
		return maps;
	}

	@Override
	@Transactional(readOnly = true)
	public String selectCombineBoardWriteTypeById(int id) throws Exception { // 통합 게시판 글 타입
		return dao.selectCombineBoardWriteTypeById(id);
	}

	@Override
	@Transactional(readOnly = true)
	public Map<String, Object> selectCombineBoardWriteByMap(Map<String, String> map) throws Exception { // 통합 게시판 수정할 글 불러오기
		
		Map<String, Object> maps = new HashMap<>();
		String result = "Fail";
		
		String boardType = dao.selectCombineBoardWriteTypeById(Integer.parseInt(map.get("id")));
		
		if(boardType != null) {
			map.put("type", boardType);
			BoardDTO board = dao.selectModifyCombineBoardWriteByMap(map);
			
			if(board == null) {
				if(boardType.equals("non")) {
					result = "Password Wrong";
				}
			} else {
				result = "Success";
				maps.put("board", board);
			}
		}
		
		maps.put("result", result);
		
		return maps;
	}

	@Override
	public String updateCombineBoardWrite(BoardDTO dto) throws Exception { // 통합 게시판 글 수정
		
		String result = "Fail";
		
		int successCount = dao.updateCombineBoardWrite(dto);
		
		if(successCount == 1) {
			result = "Success";
		}
		
		return result;
	}

	@Override
	@Transactional(isolation=Isolation.READ_COMMITTED)
	public String updateCombineBoardWriteRecommend(Map<String, String> map) throws Exception { // 통합 게시판 글 추천/비추천
		
		String result = "Fail";
		
		Integer recommendHistoryType = dao.selectCombineBoardWriteRecommendHistoryTypeByMap(map);

		if(recommendHistoryType == null) {
			int successCount = dao.updateCombineBoardWriteRecommend(map);

			if(successCount == 1) {
				successCount = dao.insertCombineBoardWriteRecommendHistory(map);
	
				if(successCount == 1) {
					result = "Success";
				}
			}
		} else {
			if(recommendHistoryType == 1) {
				result = "Already Press Up";
			} else if(recommendHistoryType == 2) {
				result = "Already Press Down";
			}
		}
		
		return result;
	}

	@Override
	public String deleteCombineBoardWrite(Map<String, String> map) throws Exception { // 통합게시판 글 삭제
		
		String result = "Fail";
		
		String boardType = dao.selectCombineBoardWriteTypeById(Integer.parseInt(map.get("id")));
		
		if(boardType != null) {
			map.put("board_type", boardType);
			int successCount = dao.deleteCombineBoardWrite(map);
			
			if(successCount == 0) {
				if(boardType.equals("non")) {
					result = "Password Wrong";
				}
			} else {
				result = "Success";
			}
		}
		
		return result;
	}

	@Override
	public String insertCombineBoardWriteComment(CommentDTO dto) throws Exception { // 통합 게시판 글의 댓글 등록

		 String result = "Fail";
		 
		 int successCount = 0;
		 
		 if(!dto.isPrevention()) { 
			 successCount = dao.insertCombineBoardWriteComment(dto);
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
	public CommentsDTO selectCombineBoardWriteCommentListByMap(Map<String, String> map) throws Exception { // 통합 게시판 글의 댓글 목록
		
		CommentsDTO combineComment = new CommentsDTO();
		
		// 댓글 목록
		combineComment.setComments(dao.selectCombineBoardWriteCommentListByMap(map));
		
		// 댓글이 존재한다면
		if(combineComment.getComments() != null && combineComment.getComments().size() != 0) {
			int listCount = dao.selectCombineBoardWriteCommentCountByMap(map);
			
			PaginationDTO pagination = new PaginationDTO(Integer.parseInt(map.get("pageBlock")), listCount, Integer.parseInt(map.get("currPage")), Integer.parseInt(map.get("row")));
			combineComment.setPagination(pagination);
		
			combineComment.setCount(combineComment.getComments().size());
			
			int charCount = 0;
			for(int i=0; i<combineComment.getCount(); i++) { // 회원 IP 치환
				for(int j=0; j<combineComment.getComments().get(i).getIp().length(); j++) {
					if(combineComment.getComments().get(i).getIp().charAt(j) == '.') {
						charCount += 1;
					}
					
					if(charCount == 2) {
						charCount = 0;
						combineComment.getComments().get(i).setIp(combineComment.getComments().get(i).getIp().substring(0, j));
						break;
					}
				}
			}
		}
		
		combineComment.setStatus("Success");
		
		return combineComment;
	}

	@Override
	@Transactional(readOnly = true)
	public String selectCombineBoardWriteCommentTypeById(int id) throws Exception { // 통합 게시판 글의 댓글 타입
		return dao.selectCombineBoardWriteCommentTypeById(id);
	}

	@Override
	public Map<String, Object> selectCombineBoardWriteCommentByMap(Map<String, String> map) throws Exception { // 통합 게시판 글의 댓글 조회

		Map<String, Object> maps = new HashMap<>();
		String result = "Fail";
		
		String commentType = dao.selectCombineBoardWriteCommentTypeById(Integer.parseInt(map.get("id")));
		
		if(commentType != null) {
			map.put("type", commentType);
			CommentDTO comment = dao.selectCombineBoardWriteCommentByMap(map);
			
			if(comment == null) {
				if(commentType.equals("non")) {
					result = "Password Wrong";
				}
			} else {
				result = "Success";
				maps.put("comment", comment);
			}
		}
		
		maps.put("result", result);
		
		return maps;
	}

	@Override
	public String updateCombineBoardWriteComment(CommentDTO dto) throws Exception { // 통합 게시판 글의 댓글 수정
		
		String result = "Fail";
		
		int successCount = dao.updateCombineBoardWriteComment(dto);
		
		if(successCount == 1) {
			result = "Success";
		}
		
		return result;
	}

	@Override
	public String deleteCombineBoardWriteComment(Map<String, String> map) throws Exception { // 통합 게시판 글의 댓글 삭제(상태값 변경)

		String result = "Fail";
		
		String commentType = dao.selectCombineBoardWriteCommentTypeById(Integer.parseInt(map.get("id")));
		
		if(commentType != null) {
			map.put("comment_type", commentType);
			int successCount = dao.deleteCombineBoardWriteComment(map);
			
			if(successCount == 0) {
				if(commentType.equals("non")) {
					result = "Password Wrong";
				}
			} else {
				result = "Success";
			}
		}
		
		return result;
	}

	@Override
	@Transactional(isolation = Isolation.READ_COMMITTED)
	public String updateCombineBoardWriteCommentRecommend(Map<String, String> map) throws Exception { // 통합 게시판 글의 댓글 추천

		String result = "Fail";
		
		Integer recommendHistoryType = dao.selectCombineBoardWriteCommentRecommendHistoryTypeByMap(map);

		if(recommendHistoryType == null) {
			int successCount = dao.updateCombineBoardWriteCommentRecommend(map);

			if(successCount == 1) {
				successCount = dao.insertCombineBoardWriteCommentRecommendHistory(map);
	
				if(successCount == 1) {
					result = "Success";
				}
			}
		} else {
			if(recommendHistoryType == 1) {
				result = "Already Press Up";
			} else if(recommendHistoryType == 2) {
				result = "Already Press Down";
			}
		}
		
		return result;
	}

	@Override
	public String insertCombineBoardWriteCommentReply(CommentReplyDTO dto) throws Exception { // 통합 게시판 글의 답글 등록

		String result = "Fail";
		int successCount = 0;
		
		if(!dto.isPrevention()) { 
			successCount = dao.insertCombineBoardWriteCommentReply(dto);
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
	public CommentReplysDTO selectCombineBoardWriteCommentReplyListByMap(Map<String, Integer> map) throws Exception { // 통합 게시판 글의 답글 목록

		CommentReplysDTO commentReplys = new CommentReplysDTO();
		
		commentReplys.setCommentReplys(dao.selectCombineBoardWriteCommentReplyListByMap(map));
		
		if(commentReplys.getCommentReplys() != null && commentReplys.getCommentReplys().size() != 0) {
			commentReplys.setCount(commentReplys.getCommentReplys().size());
			
			commentReplys.setReplyCount(dao.selectCombineBoardWriteCommentReplyCountByCombineBoardCommentId(map.get("combine_board_comment_id"))); // 해당 리뷰 답글 수
			
			int charCount = 0;
			for(int i=0; i<commentReplys.getCount(); i++) { // 회원 IP 치환
				for(int j=0; j<commentReplys.getCommentReplys().get(i).getIp().length(); j++) {
					if(commentReplys.getCommentReplys().get(i).getIp().charAt(j) == '.') {
						charCount += 1;
					}
					
					if(charCount == 2) {
						charCount = 0;
						commentReplys.getCommentReplys().get(i).setIp(commentReplys.getCommentReplys().get(i).getIp().substring(0, j));
						break;
					}
				}
			}
		}
		
		commentReplys.setStatus("Success");
		
		return commentReplys;
	}

	@Override
	@Transactional(readOnly = true)
	public String selectCombineBoardWriteCommentReplyTypeById(int id) throws Exception { // 통합 게시판 글의 답글 타입 조회
		return dao.selectCombineBoardWriteCommentReplyTypeById(id);
	}

	@Override
	public String deleteCombineBoardWriteCommentReply(Map<String, String> map) throws Exception { // 통합 게시판 글의 답글 삭제

		String result = "Fail";
		
		String commentReplyType = dao.selectCombineBoardWriteCommentReplyTypeById(Integer.parseInt(map.get("id")));
		
		if(commentReplyType != null) {
			map.put("commentReply_type", commentReplyType);
			int successCount = dao.deleteCombineBoardWriteCommentReply(map);
			
			if(successCount == 0) {
				if(commentReplyType.equals("non")) {
					result = "Password Wrong";
				}
			} else {
				result = "Success";
			}
		}
		
		return result;
	}

	@Override
	@Transactional(readOnly = true)
	public Map<String, Object> selectSearchCombineBoardWriteListByMap(Map<String, String> map) throws Exception { // 통합 게시판 게시글 검색
		
		Map<String, Object> maps = new HashMap<>();
		String listType = map.get("listType");
		
		if(listType.equals("today")) { // 게시글 정렬 타입
			Calendar today = Calendar.getInstance(timezone);
			map.put("today", sdf.format(today.getTime()));
		} else if(listType.equals("week")) {
			Calendar startDay = Calendar.getInstance(timezone); // 이번 주의 시작
			Calendar endDay = Calendar.getInstance(timezone); // 이번 주의 끝
			
			startDay.add(Calendar.DATE, -startDay.get(Calendar.DAY_OF_WEEK) + 1);
			endDay.set(Calendar.DAY_OF_WEEK, Calendar.SUNDAY);
			endDay.add(Calendar.DATE, 7);
			
			map.put("startDay", sdf.format(startDay.getTime()));
			map.put("endDay", sdf.format(endDay.getTime()));
		} else if(listType.equals("month")) {
			Calendar month = Calendar.getInstance(timezone);
			map.put("month", sdf.format(month.getTime()));
		}

		BoardWritesDTO boards = new BoardWritesDTO();
		boards.setBoards(dao.selectSearchCombineBoardWriteListByMap(map));
			
		if(boards.getBoards() != null && boards.getBoards().size() != 0) {
			boards.setCount(boards.getBoards().size());
				boards.setStatus("Success");
		}
			
		int listCount = dao.selectSearchCombineBoardWriteCountByMap(map);

		PaginationDTO pagination = new PaginationDTO(Integer.parseInt(map.get("pageBlock")), listCount, Integer.parseInt(map.get("currPage")), Integer.parseInt(map.get("row")));
			
		maps.put("boards", boards);
		maps.put("pagination", pagination);	
		maps.put("result", "Success");
		
		return maps;
	}

}