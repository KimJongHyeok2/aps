package com.kjh.aps.controller;

import java.io.ByteArrayInputStream;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.UUID;

import javax.annotation.Resource;
import javax.inject.Inject;
import javax.servlet.http.HttpServletRequest;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;

import com.kjh.aps.domain.CommentReplysDTO;
import com.kjh.aps.domain.CommentsDTO;
import com.amazonaws.SdkClientException;
import com.amazonaws.auth.AWSStaticCredentialsProvider;
import com.amazonaws.auth.BasicAWSCredentials;
import com.amazonaws.client.builder.AwsClientBuilder;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;
import com.amazonaws.services.s3.model.AccessControlList;
import com.amazonaws.services.s3.model.AmazonS3Exception;
import com.amazonaws.services.s3.model.GroupGrantee;
import com.amazonaws.services.s3.model.ObjectMetadata;
import com.amazonaws.services.s3.model.Permission;
import com.amazonaws.services.s3.model.PutObjectRequest;
import com.kjh.aps.domain.BoardDTO;
import com.kjh.aps.domain.BoardWritesDTO;
import com.kjh.aps.domain.BroadcasterDTO;
import com.kjh.aps.domain.CommentDTO;
import com.kjh.aps.domain.CommentReplyDTO;
import com.kjh.aps.domain.ImageDTO;
import com.kjh.aps.domain.PaginationDTO;
import com.kjh.aps.domain.ReviewGradePointsDTO;
import com.kjh.aps.exception.ResponseBodyException;
import com.kjh.aps.service.CommunityService;
import com.kjh.aps.util.BoardWritePushHandler;
import com.kjh.aps.validator.BoardValidator;
import com.kjh.aps.validator.CombineBoardValidator;
import com.kjh.aps.validator.CombineCommentReplyValidator;
import com.kjh.aps.validator.CombineCommentValidator;
import com.kjh.aps.validator.CommentReplyValidator;
import com.kjh.aps.validator.CommentValidator;

@Controller
@RequestMapping("/community")
public class CommunityController {
	
	private static final Logger logger = LoggerFactory.getLogger(CommunityController.class);
	
	@Inject
	private CommunityService communityService;
	private final int BOARD_PAGEBLOCK = 5;
	private final int BOARD_POPULAR_ORDER = 20;
	private final int COMMENT_PAGEBLOCK = 5;
	private final int COMMENT_POPULAR_ORDER = 20;
	
	@Resource(name="s3Properties")
	private Properties s3Properties;
	
	// 방송인 커뮤니티 목록 페이지
	@GetMapping(value = "")
	public String list(@RequestParam(value = "type", defaultValue = "bj") String type, Model model) {
		
		try {
			List<BoardDTO> noticeList = communityService.selectLastNotice(); // 공지사항
			List<BroadcasterDTO> broadcasterList = communityService.selectBroadcasterList(type); // 방송인 커뮤니티 리스트
			model.addAttribute("noticeList", noticeList);
			model.addAttribute("broadcasterList", broadcasterList);
		} catch (Exception e) {
			throw new RuntimeException(e);
		}
		
		return "community/list";
	}
	
	// 방송인 커뮤니티 목록 검색
	@PostMapping(value = "", params = "nickname")
	public String listSearch(String nickname, String type, Model model) {

		// 파라미터 유효성 검사
		if(!(nickname == null || nickname.length() == 0)) {
			try {
				if(type == null || type.length() == 0) {
					type = "bj";
				}
				Map<String, String> map = new HashMap<>();
				map.put("nickname", nickname);
				map.put("type", type);
				List<BoardDTO> noticeList = communityService.selectLastNotice(); // 공지사항
				List<BroadcasterDTO> broadcasterList = communityService.selectBroadcasterByMap(map); // 검색된 방송인 커뮤니티
				model.addAttribute("noticeList", noticeList);
				model.addAttribute("broadcasterList", broadcasterList);
			} catch (Exception e) {
				throw new RuntimeException(e);
			}
		}
		
		return "community/list";
	}
	
	// 통합 게시판 페이지
	@GetMapping("/combine")
	public String combine(@RequestParam(value = "listType", defaultValue = "new") String listType,
			@RequestParam(value = "page", defaultValue = "1") int page,
			@RequestParam(value = "row", defaultValue = "20") int row, Model model) {

		try {
			Map<String, String> map = new HashMap<>();
			map.put("currPage", String.valueOf(page));
			map.put("page", String.valueOf((page-1)*row));
			map.put("row", String.valueOf(row));
			map.put("listType", listType);
			map.put("order", String.valueOf(BOARD_POPULAR_ORDER));
			map.put("pageBlock", String.valueOf(BOARD_PAGEBLOCK));

			Map<String, Object> maps = communityService.selectCombineBoardWriteListByMap(map);

			String resultMsg = (String)maps.get("result");
				
			if(resultMsg.equals("Success")) {
				BoardWritesDTO boards = (BoardWritesDTO)maps.get("boards");
					
				model.addAttribute("boardList", boards.getBoards()); // 해당 방송인 커뮤니티 글 목록
				model.addAttribute("pagination", (PaginationDTO)maps.get("pagination"));
				model.addAttribute("listType", listType);
			} else if(resultMsg.equals("not_exist")) {
				return "confirm/" + resultMsg;
			} else {
				return "confirm/error_404";
			}
		} catch (Exception e) {
			throw new RuntimeException(e);
		}
		
		return "community/combine/combine_list";
	}
	
	// 방송인 커뮤니티 게시판 글 검색
	@GetMapping(value = "/combine", params = {"searchValue", "searchType"})
	public String combine(String searchValue,
			@RequestParam(value = "listType", defaultValue = "new") String listType,
			@RequestParam(value = "searchType", defaultValue = "1") int searchType,
			@RequestParam(value = "page", defaultValue = "1") int page,
			@RequestParam(value = "row", defaultValue = "10") int row, Model model) {
		
		String resultView = "confirm/error_500";
		
		// 파라미터 유효성 검사
		if(!(searchValue == null || searchValue.length() == 0)) {
			try {
				Map<String, String> map = new HashMap<>();
				map.put("searchValue", searchValue);
				map.put("searchType", String.valueOf(searchType));
				map.put("currPage", String.valueOf(page));
				map.put("page", String.valueOf((page-1)*row));
				map.put("row", String.valueOf(row));
				map.put("pageBlock", String.valueOf(BOARD_PAGEBLOCK));
				map.put("listType", listType);
				map.put("order", String.valueOf(BOARD_POPULAR_ORDER));
				map.put("pageBlock", String.valueOf(BOARD_PAGEBLOCK));

				Map<String, Object> maps = communityService.selectSearchCombineBoardWriteListByMap(map);

				BoardWritesDTO boards = (BoardWritesDTO)maps.get("boards");
				PaginationDTO pagination = (PaginationDTO)maps.get("pagination");
				
				model.addAttribute("boardList", boards.getBoards());
				model.addAttribute("pagination", pagination);
				model.addAttribute("listType", listType);
				resultView = "community/combine/combine_list";
			} catch (Exception e) {
				throw new RuntimeException(e);
			} 
		}
		
		return resultView;
	}
	
	// 통합 게시판 글 작성 페이지
	@GetMapping("/combine/write")
	public String combineBoardWrite() {
		return "community/combine/combine_write";
	}
	
	// 통합 게시판 글 작성
	@PostMapping("/combine/writeOk")
	public String combineBoardWriteOk(BoardDTO dto, BindingResult result,
			@RequestParam(value = "page", defaultValue = "1") int page,
			HttpServletRequest request, Model model) {
		
		CombineBoardValidator validation = new CombineBoardValidator();
		String error = "insertFail";
		
		Map<String, Object> map = null;
		
		// 파라미터 유효성 검사
		if(validation.supports(dto.getClass())) {
			dto.setIp(request.getRemoteAddr());
			Integer userId = request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id");
			
			if(dto.getBoard_type().equals("user") && userId != 0) { // 회원이 작성한 글이라면
				dto.setUser_id(userId);
				dto.setNickname((String)request.getSession().getAttribute("nickname"));
				dto.setProfile((String)request.getSession().getAttribute("profile"));
				dto.setLevel((Integer)request.getSession().getAttribute("level"));
				dto.setUserType((Integer)request.getSession().getAttribute("userType"));
			}
			validation.validate(dto, result);
			
			if(request.getSession().getAttribute("prevention") != null) { // 도배방지 세션 값이 존재하다면
				dto.setPrevention(true);
				error = "prevention";
			}
			
			// 오류가 존재하지 않다면
			if(!result.hasErrors()) {
				try {
					map = communityService.insertBoardWrite(dto); // 글 추가
					
					String resultMsg = (String)map.get("result");
					
					if(resultMsg.equals("Success")) { // 정상적으로 추가되었다면
						for(WebSocketSession session : BoardWritePushHandler.sessionList) { // 새 글 알림
							if(!session.getRemoteAddress().getHostName().equals(request.getRemoteAddr())) { // 작성자 본인 제외
								session.sendMessage(new TextMessage("combine" + "," + dto.getId() + "," + dto.getSubject()));
							}
						}
						model.addAttribute("resultMsg", resultMsg);
						return "redirect:/community/combine/view/" + dto.getId() + "?page=" + page + "";
					}
				} catch (Exception e) {
					throw new RuntimeException(e);
				}
			}
		}

		model.addAttribute("error", error);
		
		return "community/combine/combine_write";
	}
	
	// 통합 게시판 글 수정 또는 삭제 전 Confirm 페이지
	@GetMapping("/combine/confirm")
	public String combineConfirm(@RequestParam(value = "id", defaultValue = "0") int id, String type,
			@RequestParam(value = "page", defaultValue = "1") int page, Model model) {
		String resultView = "confirm/not_exist";
		if(id != 0 && type != null && (type.equals("modify") || type.equals("delete"))) {
			try {
				String boardType = communityService.selectCombineBoardWriteTypeById(id);
				
				if(boardType.equals("non")) {
					resultView = "community/combine/combine_confirm";
					model.addAttribute("type", type);
				}
				
				model.addAttribute("page", page);
				model.addAttribute("id", id);
			} catch (Exception e) {
				throw new RuntimeException(e);
			}
		}
		
		return resultView;
	}
	
	// 통합 게시판 글 수정 페이지
	@PostMapping("/combine/modify/{id}")
	public String combineBoardWriteModify(@PathVariable int id, String password,
			HttpServletRequest request, Model model) {
		String resultView = "confirm/not_exist";
		
		if(id != 0 || (password != null && password.length() > 3 && password.length() < 21)) {
			try {
				Map<String, String> map = new HashMap<>();
				map.put("id", String.valueOf(id));
				map.put("user_id", String.valueOf(request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id")));
				map.put("password", password);
				
				Map<String, Object> maps = communityService.selectCombineBoardWriteByMap(map);
				String result = (String)maps.get("result");
				
				if(result.equals("Success")) {
					resultView = "community/combine/combine_modify";
					model.addAttribute("board", (BoardDTO)maps.get("board"));
				} else if(result.equals("Password Wrong")) {
					resultView = "community/combine/combine_confirm";
					model.addAttribute("error", result);
					model.addAttribute("type", "modify");
				}
			} catch (Exception e) {
				throw new RuntimeException(e);
			}
		}
		
		model.addAttribute("id", id);
		
		return resultView;
	}
	
	// 통합 게시판 글 수정
	@PostMapping("/combine/modifyOk")
	public String combineBoardWriteModifyOk(BoardDTO dto, BindingResult result,
			@RequestParam(value = "page", defaultValue = "1") int page,
			HttpServletRequest request, Model model) {

		CombineBoardValidator validation = new CombineBoardValidator();
		String resultMsg = "Fail";
		
		// 파라미터 유효성 검사
		if(validation.supports(dto.getClass())) {
			dto.setIp(request.getRemoteAddr());
			Integer userId = request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id");
			dto.setUser_id(userId);
			
			if(dto.getBoard_type().equals("user") && userId != 0) { // 회원이 작성한 글이라면
				dto.setUser_id(userId);
				dto.setNickname((String)request.getSession().getAttribute("nickname"));
				dto.setProfile((String)request.getSession().getAttribute("profile"));
				dto.setLevel((Integer)request.getSession().getAttribute("level"));
				dto.setUserType((Integer)request.getSession().getAttribute("userType"));
			}
			validation.validate(dto, result);
			
			// 오류가 존재하지 않다면
			if(!result.hasErrors()) {
				try {
					resultMsg = communityService.updateCombineBoardWrite(dto); // 글 수정
					
					if(resultMsg.equals("Success")) { // 정상적으로 수정되었다면
						return "redirect:/community/combine/view/" + dto.getId() + "?&page=" + page + "";
					}
				} catch (Exception e) {
					throw new RuntimeException(e);
				}
			}
		}

		if(!resultMsg.equals("Success")) {
			model.addAttribute("board", dto);
			model.addAttribute("error", "updateFail");
		}
		
		return "community/combine/combine_modify";
	}
	
	// 통합 게시판 글 삭제
	@PostMapping("/combine/deleteOk")
	public String combineBoardWriteDeleteOk(@RequestParam(value = "id", defaultValue = "0") int id,
			String password, @RequestParam(value = "page", defaultValue = "1") int page,
			HttpServletRequest request, Model model) {

		try {
			Map<String, String> map = new HashMap<>();
			map.put("id", String.valueOf(id));
			map.put("user_id", String.valueOf(request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id")));
			map.put("password", password);
			
			String resultMsg = communityService.deleteCombineBoardWrite(map); // 글 삭제(상태값 변경)
			
			if(resultMsg.equals("Success")) { // 정상적으로 글 상태값이 변경되었다면
				return "redirect:/community/combine";
			} else if(resultMsg.equals("Password Wrong")) {
				model.addAttribute("id", id);
				model.addAttribute("type", "delete");
				model.addAttribute("error", resultMsg);
				return "community/combine/combine_confirm";
			}
		} catch (Exception e) {
			throw new RuntimeException(e);
		}

		model.addAttribute("error", "deleteFail");

		return "redirect:/community/combine/view/" + id + "?page=" + page;
	}
	
	// 통합 게시판 글 상세보기
	@GetMapping("/combine/view/{id}")
	public String combineBoardWriteView(@PathVariable int id,
			@RequestParam(value = "listType", defaultValue = "new") String listType,
			@RequestParam(value = "page", defaultValue = "1") int page,
			@RequestParam(value = "row", defaultValue = "20") int row,
			HttpServletRequest request, Model model) {

		try {
			Map<String, String> map = new HashMap<>();
			map.put("id", String.valueOf(id));
			map.put("currPage", String.valueOf(page));
			map.put("page", String.valueOf((page-1)*row));
			map.put("row", String.valueOf(row));
			Integer userId = request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id");
			map.put("user_id", String.valueOf(userId));
			map.put("ip", request.getRemoteAddr());
			map.put("listType", listType);
			map.put("order", String.valueOf(BOARD_POPULAR_ORDER));
			map.put("view", "false");
			map.put("pageBlock", String.valueOf(COMMENT_PAGEBLOCK));
			
			map.put("view", "true");
			
			Map<String, Object> maps = communityService.selectCombineBoardWriteViewByMap(map);
			
			String resultMsg = (String)maps.get("result");
			
			if(resultMsg.equals("Success")) { // 정상적으로 불러왔다면
				BoardWritesDTO boards = (BoardWritesDTO) maps.get("boards");

				model.addAttribute("board", (BoardDTO)maps.get("board"));
				model.addAttribute("boardList", boards.getBoards());
				model.addAttribute("pagination", (PaginationDTO)maps.get("pagination"));
				model.addAttribute("listType", listType);
			} else if(resultMsg.equals("not_exist")) {
				return "confirm/" + resultMsg;
			} else {
				return "confirm/error_404";
			}
		} catch (Exception e) {
			throw new RuntimeException(e);
		}
		
		return "community/combine/combine_view";
	}
	
	// 통합 게시판 글 댓글 추천
	@PostMapping("/combine/recommend")
	public @ResponseBody String combineBoardWriteRecommend(@RequestParam(value = "id", defaultValue = "0") int id,
			 String type, HttpServletRequest request) {
		
			String resultMsg = "Fail";
		
			// 파라미터 유효성 검사
			if(!(id == 0 || type == null || type.equals("up") && type.equals("down"))) {
				Integer userId = request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id");
				String ip = request.getRemoteAddr();
				
					Map<String, String> map = new HashMap<>();
					map.put("id", String.valueOf(id));
					map.put("user_id", String.valueOf(userId));
					map.put("ip", ip);
					map.put("type", type);
					
				try {
					resultMsg = communityService.updateCombineBoardWriteRecommend(map); // 글 추천
					
					if(resultMsg.equals("Success")) {
						request.setAttribute("type", "combineBoard");
						request.setAttribute("combine_board_id", id);
					}
				} catch (Exception e) {
					throw new ResponseBodyException(e);
				}
			}
		
		return resultMsg;
	}
	
	// 통합 게시판 글의 댓글 작성
	@PostMapping("/combine/comment/write")
	public @ResponseBody String combineBoardWriteCommentWrite(CommentDTO dto, BindingResult result,
			HttpServletRequest request) {
		
		CombineCommentValidator validation = new CombineCommentValidator();
		validation.setRequest(request);

		String resultMsg = "Fail";
		
		// 파라미터 유효성 검사
		if(validation.supports(dto.getClass())) {
			dto.setIp(request.getRemoteAddr());
			Integer userId = request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id");
			
			if(dto.getComment_type().equals("user") && userId != 0) { // 회원이 작성한 글이라면
				dto.setUser_id(userId);
				dto.setNickname((String)request.getSession().getAttribute("nickname"));
				dto.setProfile((String)request.getSession().getAttribute("profile"));
				dto.setLevel((Integer)request.getSession().getAttribute("level"));
				dto.setUserType((Integer)request.getSession().getAttribute("userType"));
			}
			validation.validate(dto, result);
			
			// 오류가 존재하지 않다면
			if(!result.hasErrors()) {
				dto.setIp(request.getRemoteAddr());

				try {
					if(request.getSession().getAttribute("prevention") != null) { // 도배방지 세션 값이 존재하다면
						dto.setPrevention(true);
					}
					
					resultMsg = communityService.insertCombineBoardWriteComment(dto); // 댓글 작성
					
					if(resultMsg.equals("Success")) { // 댓글 Push
						if(dto.getBoardUserId() != 0 && dto.getBoardSubject() != null) {							
							request.setAttribute("type", 6);
							request.setAttribute("dto", dto);
						}
					}
				} catch (Exception e) {
					throw new ResponseBodyException(e);
				}
			}
		}
		
		return resultMsg;
	}
	
	// 통합 게시판 글의 댓글 수정 또는 삭제 전 Confirm 페이지
	@GetMapping("/combine/comment/confirm")
	public String combineCommentConfirm(@RequestParam(value = "id", defaultValue = "0") int id,
			Integer combineCommentId, String type, Model model) {
		String resultView = "confirm/not_exist";
		
		if(id != 0 && type != null && (type.equals("modify") || type.equals("delete") || type.equals("deleteReply"))) {
			try {					
				String commentType = null;
				
				if(type.equals("modify") || type.equals("delete")) {					
					commentType = communityService.selectCombineBoardWriteCommentTypeById(id);
				} else if(type.equals("deleteReply")) {
					commentType = communityService.selectCombineBoardWriteCommentReplyTypeById(id);
					if(combineCommentId != null) { model.addAttribute("combineCommentId", combineCommentId); }
				}
				
				if(commentType.equals("non")) {
					resultView = "community/combine/comment_confirm";
					model.addAttribute("type", type);
				}
				model.addAttribute("id", id);
			} catch (Exception e) {
				throw new RuntimeException(e);
			}
		}
		
		return resultView;
	}
	
	// 통합 게시판 글의 댓글 수정 페이지
	@PostMapping("/combine/comment/modify/{id}")
	public String combineBoardWriteCommentModify(@PathVariable int id, String password,
			HttpServletRequest request, Model model) {
		String resultView = "confirm/not_exist";
		
		if(id != 0 || (password != null && password.length() > 3 && password.length() < 21)) {
			try {
				Map<String, String> map = new HashMap<>();
				map.put("id", String.valueOf(id));
				map.put("user_id", String.valueOf(request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id")));
				map.put("password", password);
				
				Map<String, Object> maps = communityService.selectCombineBoardWriteCommentByMap(map);
				String result = (String)maps.get("result");
				
				if(result.equals("Success")) {
					resultView = "community/combine/comment_modify";
					model.addAttribute("comment", (CommentDTO)maps.get("comment"));
				} else if(result.equals("Password Wrong")) {
					resultView = "community/combine/comment_confirm";
					model.addAttribute("error", result);
					model.addAttribute("type", "modify");
				}
			} catch (Exception e) {
				throw new RuntimeException(e);
			}
		}
		
		model.addAttribute("id", id);
		
		return resultView;
	}
	
	// 통합 게시판 글의 댓글 삭제
	@PostMapping("/combine/comment/modifyOk")
	public @ResponseBody String combineBoardWriteCommentModifyOk(CommentDTO dto, BindingResult result,
			@RequestParam(value = "page", defaultValue = "1") int page,
			HttpServletRequest request, Model model) {

		CombineCommentValidator validation = new CombineCommentValidator();
		validation.setRequest(request);
		String resultMsg = "Fail";
		
		// 파라미터 유효성 검사
		if(validation.supports(dto.getClass())) {
			dto.setIp(request.getRemoteAddr());
			Integer userId = request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id");
			dto.setUser_id(userId);
			
			if(dto.getComment_type().equals("user") && userId != 0) { // 회원이 작성한 글이라면
				dto.setUser_id(userId);
				dto.setNickname((String)request.getSession().getAttribute("nickname"));
				dto.setProfile((String)request.getSession().getAttribute("profile"));
				dto.setLevel((Integer)request.getSession().getAttribute("level"));
				dto.setUserType((Integer)request.getSession().getAttribute("userType"));
			}
			validation.validate(dto, result);
			
			// 오류가 존재하지 않다면
			if(!result.hasErrors()) {
				try {
					resultMsg = communityService.updateCombineBoardWriteComment(dto); // 글 수정
				} catch (Exception e) {
					throw new RuntimeException(e);
				}
			}
		}
		
		return resultMsg;
	}
	
	// 통합 게시판 글의 댓글 삭제
	@PostMapping("/combine/comment/deleteOk")
	public @ResponseBody String combineBoardWriteCommentDeleteOk(@RequestParam(value = "id", defaultValue = "0") int id,
			String password, HttpServletRequest request, Model model) {

		String resultMsg = "Fail";
		
		try {
			Map<String, String> map = new HashMap<>();
			map.put("id", String.valueOf(id));
			map.put("user_id", String.valueOf(request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id")));
			map.put("password", password);
			
			resultMsg = communityService.deleteCombineBoardWriteComment(map); // 글 삭제(상태값 변경)
		} catch (Exception e) {
			throw new RuntimeException(e);
		}
		
		return resultMsg;
	}
	
	// 통합 게시판 글 댓글 추천
	@PostMapping("/combine/comment/recommend")
	public @ResponseBody String combineBoardWriteCommentRecommend(@RequestParam(value = "id", defaultValue = "0") int id,
			String type, HttpServletRequest request) {
		
			String resultMsg = "Fail";
		
			// 파라미터 유효성 검사
			if(!(id == 0 ||  type == null || type.equals("up") && type.equals("down"))) {
				Integer userId = request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id");
				String ip = request.getRemoteAddr();
				
				Map<String, String> map = new HashMap<>();
				map.put("id", String.valueOf(id));
				map.put("user_id", String.valueOf(userId));
				map.put("ip", ip);
				map.put("type", type);
				
				try {
					resultMsg = communityService.updateCombineBoardWriteCommentRecommend(map);
					
					if(resultMsg.equals("Success")) {
						request.setAttribute("type", "combineBoardComment");
						request.setAttribute("combine_board_comment_id", id);
					}
				} catch (Exception e) {
					throw new ResponseBodyException(e);
				}
			}
		
		return resultMsg;
	}
	
	// 통합 게시판 글 댓글 목록
	@PostMapping("/combine/comment/list")
	public @ResponseBody CommentsDTO combineBoardWriteCommentList(int combineBoardId,
			HttpServletRequest request,
			@RequestParam(value = "listType", defaultValue = "new") String listType,
			@RequestParam(value = "page", defaultValue = "1") int page,
			@RequestParam(value = "row", defaultValue = "15") int row) {
		
		CommentsDTO boardComment = new CommentsDTO();
		
		try {
			Map<String, String> map = new HashMap<>();
			map.put("combine_board_id", String.valueOf(combineBoardId));
			map.put("currPage", String.valueOf(page));
			map.put("page", String.valueOf((page-1)*row));
			map.put("row", String.valueOf(row));
			map.put("pageBlock", String.valueOf(COMMENT_PAGEBLOCK));
			map.put("listType", listType);
			map.put("order", String.valueOf(COMMENT_POPULAR_ORDER));
			
			Integer userId = request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id");
			String ip = request.getRemoteAddr();
			
			map.put("user_id", String.valueOf(userId));
			map.put("ip", ip);
			
			boardComment = communityService.selectCombineBoardWriteCommentListByMap(map); // 댓글 목록
		} catch (Exception e) {
			boardComment.setStatus("Fail");
			throw new ResponseBodyException(e);
		}
		
		return boardComment;
	}

	
	// 통합 게시판 글 댓글 작성
	@PostMapping("/combine/commentReply/write")
	public @ResponseBody String combineBoardWriteCommentReplyWrite(CommentReplyDTO dto, BindingResult result,
			HttpServletRequest request) {
		
		CombineCommentReplyValidator validation = new CombineCommentReplyValidator();
		validation.setRequest(request);

		String resultMsg = "Fail";
		
		// 파라미터 유효성 검사
		if(validation.supports(dto.getClass())) {
			dto.setIp(request.getRemoteAddr());
			Integer userId = request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id");
			
			if(dto.getCommentReply_type().equals("user") && userId != 0) { // 회원이 작성한 글이라면
				dto.setUser_id(userId);
				dto.setNickname((String)request.getSession().getAttribute("nickname"));
				dto.setProfile((String)request.getSession().getAttribute("profile"));
				dto.setLevel((Integer)request.getSession().getAttribute("level"));
				dto.setUserType((Integer)request.getSession().getAttribute("userType"));
			}
			validation.validate(dto, result);
			
			// 오류가 존재하지 않다면
			if(!result.hasErrors()) {
				dto.setIp(request.getRemoteAddr());

				try {
					if(request.getSession().getAttribute("prevention") != null) { // 도배방지 세션 값이 존재하다면
						dto.setPrevention(true);
					}
					
					resultMsg = communityService.insertCombineBoardWriteCommentReply(dto); // 댓글 작성
					
					if(resultMsg.equals("Success")) { // 답글 Push
						if(dto.getCommentReply_type().equals("user")) {							
							request.setAttribute("dto", dto);
							request.setAttribute("type", 7);
						}
					}
				} catch (Exception e) {
					throw new ResponseBodyException(e);
				}
			}
		}
		
		return resultMsg;
	}
	
	// 통합 게시판 글 댓글의 답글 삭제
	@PostMapping("/combine/commentReply/deleteOk")
	public @ResponseBody String combineBoardWriteCommentReplyDeleteOk(@RequestParam(value = "id", defaultValue = "0") int id,
			String password, HttpServletRequest request, Model model) {

		String resultMsg = "Fail";
		
		try {
			Map<String, String> map = new HashMap<>();
			map.put("id", String.valueOf(id));
			map.put("user_id", String.valueOf(request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id")));
			map.put("password", password);
			
			resultMsg = communityService.deleteCombineBoardWriteCommentReply(map); // 글 삭제(상태값 변경)
		} catch (Exception e) {
			throw new RuntimeException(e);
		}
		
		return resultMsg;
	}
	
	// 통합 게시판 글 댓글의 답글 목록
	@PostMapping("/combine/commentReply/list")
	public @ResponseBody CommentReplysDTO combineCommentReplyList(int combineBoardCommentId,
			@RequestParam(value = "page", defaultValue = "1") int page,
			@RequestParam(value = "row", defaultValue = "15") int row) {
		
		CommentReplysDTO commentReplys = new CommentReplysDTO();
		
		if(combineBoardCommentId != 0) {
			try {
				Map<String, Integer> map = new HashMap<>();
				map.put("combine_board_comment_id", combineBoardCommentId);
				map.put("page", page);
				map.put("row", row);
				
				commentReplys = communityService.selectCombineBoardWriteCommentReplyListByMap(map);
			} catch (Exception e) {
				commentReplys.setStatus("Fail");
				throw new ResponseBodyException(e);
			}
		}
		
		return commentReplys;
	}
	
	// 방송인 민심평가 페이지
	@GetMapping("/review/{id}")
	public String review(@PathVariable String id, Model model) {
		
		try {
			BroadcasterDTO broadcaster = communityService.selectBroadcasterById(id);
			
			if(broadcaster != null) {
				model.addAttribute("broadcaster", broadcaster);
			} else {
				return "confirm/error_404";
			}
		} catch (Exception e) {
			throw new RuntimeException(e);
		}
		
		return "community/review";
	}

	// 방송인 민심평가 평균
	@PostMapping("/review/gpa")
	public @ResponseBody ReviewGradePointsDTO reviewGPA(String broadcasterId,
			@RequestParam(value = "dataType", defaultValue = "week") String dataType) {
		
		ReviewGradePointsDTO reviewGradePoints = new ReviewGradePointsDTO();
		
		Map<String, String> map = new HashMap<>();
		
		// 파라미터 유효성 검사
		if(broadcasterId != null && broadcasterId.length() != 0) {		
			try {
				map.put("broadcaster_id", broadcasterId);
				map.put("dataType", dataType);
			
				reviewGradePoints = communityService.selectBroadcasterReviewGradePointAverageListByMap(map);
			} catch (Exception e) {
				reviewGradePoints.setStatus("Fail");
				throw new ResponseBodyException(e);
			}
		} else {
			reviewGradePoints.setStatus("Fail");
		}
		
		return reviewGradePoints;
	}
	
	// 방송인 민심평가 등록
	@PostMapping("/review/write")
	public @ResponseBody String reviewWrite(CommentDTO dto, BindingResult result,
			HttpServletRequest request) {
		String resultMsg = "Fail";
		
		CommentValidator validation = new CommentValidator();
		validation.setRequest(request);
		
		// 파라미터 유효성 검사
		if(validation.supports(dto.getClass())) {
			validation.validate(dto, result);
			dto.setIp(request.getRemoteAddr());
			
			// 오류가 존재하지 않다면
			if(!result.hasErrors()) {
				try {
					resultMsg = communityService.insertBroadcasterReview(dto);
				} catch (Exception e) {
					throw new ResponseBodyException(e);
				}
			}
		}
		
		return resultMsg;
	}
	
	// 방송인 민심평가 수정 페이지
	@GetMapping("/review/modify/{id}")
	public String reviewModify(@PathVariable int id, String broadcasterId, 
			HttpServletRequest request, Model model) {
		
		try {
			Map<String, String> map = new HashMap<>();
			map.put("id", String.valueOf(id));
			map.put("broadcaster_id", broadcasterId);
			map.put("user_id", String.valueOf(request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id")));

			Object object = communityService.selectBroadcasterReviewByMap(map); // 수정할 평가
			
			if(object instanceof String) {
				String resultMsg = (String)object;
				
				if(resultMsg.equals("not_exist")) {
					return "confirm/" + resultMsg;
				} else if(resultMsg.equals("error_405")) {
					return "confirm/" + resultMsg;
				}
			} else if(object instanceof CommentDTO) { // 정상적으로 불러왔다면
				model.addAttribute("review", (CommentDTO)object);
			}
		} catch (Exception e) {
			throw new RuntimeException(e);
		}
		
		return "community/review_modify";
	}
	
	// 방송인 민심평가 수정
	@PostMapping("/review/modifyOk")
	public @ResponseBody String reviewModifyOk(CommentDTO dto, BindingResult result,
			HttpServletRequest request) {
		
		CommentValidator validation = new CommentValidator();
		validation.setRequest(request);
		
		String resultMsg = "Fail";
		
		// 파라미터 유효성 검사
		if(validation.supports(dto.getClass())) {
			validation.validate(dto, result);
			
			// 오류가 존재하지 않다면
			if(!result.hasErrors()) {
				dto.setIp(request.getRemoteAddr());
				Integer userId = request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id");
				dto.setUser_id(userId);
				
				try {
					resultMsg = communityService.updateBroadcasterReview(dto); // 평가 수정
				} catch (Exception e) {
					throw new ResponseBodyException(e);
				}
			}
		}
		
		return resultMsg;
	}
	
	// 방송인 민심평가 삭제
	@PostMapping("/review/deleteOk")
	public @ResponseBody String reviewDeleteOk(String broadcasterId,
			@RequestParam(value = "id", defaultValue = "0") int id,
			HttpServletRequest request) {
		
		String result = "Fail";
		
		try {
			Map<String, String> map = new HashMap<>();
			map.put("broadcaster_id", broadcasterId);
			map.put("id", String.valueOf(id));
			map.put("user_id", String.valueOf(request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id")));
			
			result = communityService.deleteBroadcasterReview(map);
		} catch (Exception e) {
			throw new ResponseBodyException(e);
		}
		
		return result;
	}
	
	// 방송인 민심평가 목록
	@PostMapping("/review/list")
	public @ResponseBody CommentsDTO reviewList(String broadcasterId,
			@RequestParam(value = "listType1", defaultValue = "today") String listType1,
			@RequestParam(value = "listType2", defaultValue = "new") String listType2,
			@RequestParam(value = "page", defaultValue = "1") int page,
			@RequestParam(value = "row", defaultValue = "15") int row,
			HttpServletRequest request) {
		
		CommentsDTO reviews = new CommentsDTO();
		
		if(broadcasterId != null && broadcasterId.length() != 0) {
			try {
				Map<String, String> map = new HashMap<>();
				map.put("broadcaster_id", broadcasterId);
				map.put("currPage", String.valueOf(page));
				map.put("page", String.valueOf((page-1)*row));
				map.put("row", String.valueOf(row));
				map.put("pageBlock", String.valueOf(COMMENT_PAGEBLOCK));
				map.put("listType1", listType1);
				map.put("listType2", listType2);
				map.put("order", String.valueOf(COMMENT_POPULAR_ORDER));
				
				Integer userId = request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id");
				String ip =  request.getSession().getAttribute("id")==null? "0":request.getRemoteAddr();
				
				map.put("user_id", String.valueOf(userId));
				map.put("ip", ip);
				
				reviews = communityService.selectBroadcasterReviewListByMap(map);
			} catch (Exception e) {
				reviews.setStatus("Fail");
				throw new ResponseBodyException(e);
			}
		}
		
		return reviews;
	}
	
	// 방송인 커뮤니티 게시판 글 댓글 추천
	@PostMapping("/review/recommend")
	public @ResponseBody String reviewRecommend(@RequestParam(value = "id", defaultValue = "0") int id,
			String broadcasterId, String type, HttpServletRequest request) {
		
			String resultMsg = "Fail";
		
			// 파라미터 유효성 검사
			if(!(id == 0 || broadcasterId == null || broadcasterId.length() == 0 || type == null || type.equals("up") && type.equals("down"))) {
				Integer userId = request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id");
				String ip = request.getRemoteAddr();
				
				if(userId == 0) { // 로그인 여부
					resultMsg = "Login Required";
				} else {
					Map<String, String> map = new HashMap<>();
					map.put("id", String.valueOf(id));
					map.put("broadcaster_id", broadcasterId);
					map.put("user_id", String.valueOf(userId));
					map.put("ip", ip);
					map.put("type", type);
					
					try {
						resultMsg = communityService.updateBroadcasterReviewRecommend(map);
						
						if(resultMsg.equals("Success")) {
							request.setAttribute("type", "reviewComment");
							request.setAttribute("review_id", id);
						}
					} catch (Exception e) {
						throw new ResponseBodyException(e);
					}
				}
			}
		
		return resultMsg;
	}
	
	// 방송인 민심평가 답글 등록
	@PostMapping("/reviewReply/write")
	public @ResponseBody String reviewReplywWrite(CommentReplyDTO dto, BindingResult result,
			HttpServletRequest request) {
		String resultMsg = "Fail";
		
		CommentReplyValidator validation = new CommentReplyValidator();
		validation.setRequest(request);
		
		// 파라미터 유효성 검사
		if(validation.supports(dto.getClass())) {
			validation.validate(dto, result);
			dto.setIp(request.getRemoteAddr());
			
			// 오류가 존재하지 않다면
			if(!result.hasErrors()) {
				try {
					if(request.getSession().getAttribute("prevention") != null) { // 도배방지 세션 값이 존재하다면
						dto.setPrevention(true);
					}
					
					resultMsg = communityService.insertBroadcasterReviewReply(dto);
					
					if(resultMsg.equals("Success")) {
						request.setAttribute("type", 3);
						request.setAttribute("dto", dto);
					}
				} catch (Exception e) {
					throw new ResponseBodyException(e);
				}
			}
		}
		
		return resultMsg;
	}
	
	// 방송인 민심평가 답글 삭제
	@PostMapping("/reviewReply/deleteOk")
	public @ResponseBody String reviewReplyDeleteOk(@RequestParam(value = "broadcasterReviewId", defaultValue = "0") int broadcasterReviewId,
			@RequestParam(value = "id", defaultValue = "0") int id,
			HttpServletRequest request) {
		
		String result = "Fail";
		
		try {
			Map<String, Integer> map = new HashMap<>();
			map.put("broadcaster_review_id", broadcasterReviewId);
			map.put("id", id);
			map.put("user_id", request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id"));
			
			result = communityService.deleteBroadcasterReviewReply(map);
		} catch (Exception e) {
			throw new ResponseBodyException(e);
		}
		
		return result;
	}
	
	// 방송인 민심평가 답글 목록
	@PostMapping("/reviewReply/list")
	public @ResponseBody CommentReplysDTO reviewReplyList(int broadcasterReviewId,
			@RequestParam(value = "page", defaultValue = "1") int page,
			@RequestParam(value = "row", defaultValue = "15") int row) {
		
		CommentReplysDTO reviewReplys = new CommentReplysDTO();
		
		if(broadcasterReviewId != 0) {
			try {
				Map<String, Integer> map = new HashMap<>();
				map.put("broadcaster_review_id", broadcasterReviewId);
				map.put("page", page);
				map.put("row", row);
				
				reviewReplys = communityService.selectBroadcasterReviewReplyListByMap(map);
			} catch (Exception e) {
				reviewReplys.setStatus("Fail");
				throw new ResponseBodyException(e);
			}
		}
		
		return reviewReplys;
	}
	
	// 방송인 커뮤니티 게시판 페이지
	@GetMapping(value = "/board", params = "id")
	public String board(String id, @RequestParam(value = "listType", defaultValue = "new") String listType,
			@RequestParam(value = "page", defaultValue = "1") int page,
			@RequestParam(value = "row", defaultValue = "20") int row, Model model) {
		
		// 파라미터 유효성 검사
		if(id == null || id.length() == 0) {
			return "confirm/not_exist";
		} else {
			try {
				Map<String, String> map = new HashMap<>();
				map.put("id", id);
				map.put("currPage", String.valueOf(page));
				map.put("page", String.valueOf((page-1)*row));
				map.put("row", String.valueOf(row));
				map.put("listType", listType);
				map.put("order", String.valueOf(BOARD_POPULAR_ORDER));
				map.put("pageBlock", String.valueOf(BOARD_PAGEBLOCK));
				
				Map<String, Object> maps = communityService.selectBoardWriteListByMap(map);
				
				String resultMsg = (String)maps.get("result");
				
				if(resultMsg.equals("Success")) {
					BoardWritesDTO boards = (BoardWritesDTO)maps.get("boards");
					
					model.addAttribute("broadcaster", (BroadcasterDTO)maps.get("broadcaster"));
					model.addAttribute("boardList", boards.getBoards()); // 해당 방송인 커뮤니티 글 목록
					model.addAttribute("pagination", (PaginationDTO)maps.get("pagination"));
					model.addAttribute("listType", listType);					
				} else if(resultMsg.equals("not_exist")) {
					return "confirm/" + resultMsg;
				} else {
					return "confirm/error_404";
				}
			} catch (Exception e) {
				throw new RuntimeException(e);
			}
		}
		
		return "community/board/board_list";
	}
	
	// 방송인 커뮤니티 게시판 글 검색
	@GetMapping(value = "/board", params = {"searchValue", "searchType"})
	public String board(String id, String searchValue,
			@RequestParam(value = "searchType", defaultValue = "1") int searchType,
			@RequestParam(value = "listType", defaultValue = "new") String listType,
			@RequestParam(value = "page", defaultValue = "1") int page,
			@RequestParam(value = "row", defaultValue = "20") int row, Model model) {
		
		// 파라미터 유효성 검사
		if(id == null || id.length() == 0 || searchValue == null || searchValue.length() == 0) {
			return "confirm/not_exist";
		} else {
			try {
				Map<String, String> map = new HashMap<>();
				map.put("id", id);
				map.put("searchValue", searchValue);
				map.put("searchType", String.valueOf(searchType));
				map.put("currPage", String.valueOf(page));
				map.put("page", String.valueOf((page-1)*row));
				map.put("row", String.valueOf(row));
				map.put("listType", listType);
				map.put("order", String.valueOf(BOARD_POPULAR_ORDER));
				map.put("pageBlock", String.valueOf(BOARD_PAGEBLOCK));

				Map<String, Object> maps = communityService.selectSearchBoardListByMap(map);
				
				String resultMsg = (String)maps.get("result");
				
				if(resultMsg.equals("Success")) {
					BoardWritesDTO boards = (BoardWritesDTO)maps.get("boards");
					
					model.addAttribute("broadcaster", (BroadcasterDTO)maps.get("broadcaster"));
					model.addAttribute("boardList", boards.getBoards());
					model.addAttribute("pagination", (PaginationDTO)maps.get("pagination"));
					model.addAttribute("listType", listType);
				} else if(resultMsg.equals("not_exist")) {
					return "confirm/" + resultMsg;
				} else {
					return "confirm/error_404";
				}
			} catch (Exception e) {
				throw new RuntimeException(e);
			}
		}
		
		return "community/board/board_list";
	}

	// 방송인 커뮤니티 게시판 글 작성 페이지
	@GetMapping("/board/write")
	public String boardWrite(String id, @RequestParam(value = "page", defaultValue = "1") int page, Model model) {
		
		// 파라미터 유효성 검사
		if(id == null || id.length() == 0) {
			return "confirm/not_exist";
		} else {
			try {
				BroadcasterDTO broadcaster = communityService.selectBroadcasterById(id); // 해당 커뮤니티 방송인 정보
				
				if(broadcaster == null) { // 잘못된 방송인 아이디 값이 넘어왔다면
					return "confirm/not_exist";
				}
				
				model.addAttribute("broadcaster", broadcaster);
			} catch (Exception e) {
				throw new RuntimeException(e);
			}
		}
		
		return "community/board/board_write";
	}
	
	// 방송인 커뮤니티 게시판 글 이미지 업로드
	@PostMapping("/board/write/imageUpload")
	public @ResponseBody ImageDTO boardWriteImageUpload(MultipartHttpServletRequest multi) {
		
		Iterator<String> names = multi.getFileNames();
		String name = names.next();
		MultipartFile file = multi.getFile(name);
		
		final AmazonS3 s3 = AmazonS3ClientBuilder.standard()
				.withEndpointConfiguration(new AwsClientBuilder.EndpointConfiguration(s3Properties.getProperty("s3.endPoint"), s3Properties.getProperty("s3.region")))
				.withCredentials(new AWSStaticCredentialsProvider(new BasicAWSCredentials(s3Properties.getProperty("s3.accessKey"), s3Properties.getProperty("s3.secretKey")))).build();
		
		String bucketName = "aps";
		String folderName = "board";
		
		ObjectMetadata objectMetadata = new ObjectMetadata();
		objectMetadata.setContentLength(0L);
		objectMetadata.setContentType("application/x-directory");
		PutObjectRequest putObjectRequest = new PutObjectRequest(bucketName, folderName + "/", new ByteArrayInputStream(new byte[0]), objectMetadata);

		// 폴더 생성
		try {
		    s3.putObject(putObjectRequest);
		} catch (AmazonS3Exception e) {
			throw new ResponseBodyException(e);
		} catch(SdkClientException e) {
			throw new ResponseBodyException(e);
		}
		
		UUID uuid = UUID.randomUUID(); // 이미지 파일 중복 방지
		String objectName = uuid.toString() + "_" + file.getOriginalFilename();
		objectMetadata.setContentLength(file.getSize());
		objectMetadata.setContentType(file.getContentType());
		
		// Object 업로드
		try {
			s3.putObject(bucketName + "/" + folderName, objectName, file.getInputStream(), objectMetadata);
		} catch (Exception e) {
			throw new ResponseBodyException(e);
		}
		
		// Object 권한 설정
		try {
			AccessControlList accessControlList = s3.getObjectAcl(bucketName + "/" + folderName, objectName);
			accessControlList.grantPermission(GroupGrantee.AllUsers, Permission.Read);
			s3.setObjectAcl(bucketName + "/" + folderName, objectName, accessControlList);			
		} catch (AmazonS3Exception e) {
			throw new ResponseBodyException(e);
		}
		
		ImageDTO image = new ImageDTO();
		
		image.setUploaded(true);
		image.setUrl(s3Properties.getProperty("s3.endPoint") + "/" + bucketName + "/" + folderName + "/" + objectName);
		image.setName(objectName);
		
		logger.info("BoardWrite : {} - {} 이미지 업로드", multi.getSession().getAttribute("id"), multi.getSession().getAttribute("nickname"));
		
		return image;
	}
	
	// 방송인 커뮤니티 게시판 글 작성
	@PostMapping("/board/writeOk")
	public String boardWriteOk(BoardDTO dto, BindingResult result,
			@RequestParam(value = "page", defaultValue = "1") int page,
			HttpServletRequest request, Model model) {
		
		BoardValidator validation = new BoardValidator();
		validation.setRequest(request);
		String error = "insertFail";
		
		Map<String, Object> map = null;
		
		// 파라미터 유효성 검사
		if(validation.supports(dto.getClass())) {
			validation.validate(dto, result);
			
			if(request.getSession().getAttribute("prevention") != null) { // 도배방지 세션 값이 존재하다면
				dto.setPrevention(true);
				error = "prevention";
			}
			
			// 오류가 존재하지 않다면
			if(!result.hasErrors()) {
				dto.setIp(request.getRemoteAddr());
				
				try {
					map = communityService.insertBoardWrite(dto); // 글 추가
					
					String resultMsg = (String)map.get("result");
					
					if(resultMsg.equals("Success")) { // 정상적으로 추가되었다면
						for(WebSocketSession session : BoardWritePushHandler.sessionList) { // 새 글 알림
							if(!session.getRemoteAddress().getHostName().equals(request.getRemoteAddr())) { // 작성자 본인 제외
								session.sendMessage(new TextMessage(dto.getBroadcaster_id() + "," + dto.getId() + "," + dto.getSubject()));
							}
						}
						model.addAttribute("resultMsg", resultMsg);
						return "redirect:/community/board/view/" + dto.getId() + "?broadcasterId=" + dto.getBroadcaster_id() + "&page=" + page + "";
					}
				} catch (Exception e) {
					throw new RuntimeException(e);
				}
			}
		}
		
		BroadcasterDTO broadcaster = (BroadcasterDTO)map.get("broadcaster");
		
		if(broadcaster == null) { // 잘못된 방송인 아이디 값이 넘어왔다면
			return "confirm/not_exist";
		} else {
			model.addAttribute("broadcaster", broadcaster);
		}

		model.addAttribute("error", error);
		
		return "community/board/board_write";
	}
	
	// 방송인 커뮤니티 게시판 글 상세보기
	@GetMapping("/board/view/{id}")
	public String boardView(@PathVariable int id, String broadcasterId,
			@RequestParam(value = "listType", defaultValue = "new") String listType,
			@RequestParam(value = "page", defaultValue = "1") int page,
			@RequestParam(value = "row", defaultValue = "20") int row,
			HttpServletRequest request, Model model) {

		try {
			Map<String, String> map = new HashMap<>();
			map.put("id", String.valueOf(id));
			map.put("broadcaster_id", broadcasterId);
			map.put("currPage", String.valueOf(page));
			map.put("page", String.valueOf((page-1)*row));
			map.put("row", String.valueOf(row));
			Integer userId = request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id");
			String ip =  request.getSession().getAttribute("id")==null? "0":request.getRemoteAddr();
			map.put("user_id", String.valueOf(userId));
			map.put("ip", ip);
			map.put("listType", listType);
			map.put("order", String.valueOf(BOARD_POPULAR_ORDER));
			map.put("view", "false");
			map.put("pageBlock", String.valueOf(COMMENT_PAGEBLOCK));
			
			/*if(request.getSession().getAttribute("view-" + id) == null) {*/
				/*request.getSession().setAttribute("view-" + id, id);*/
			map.put("view", "true");
			/*}*/
			
			Map<String, Object> maps = communityService.selectBoardWriteViewByMap(map);
			
			String resultMsg = (String)maps.get("result");
			
			if(resultMsg.equals("Success")) { // 정상적으로 불러왔다면
				BoardWritesDTO boards = (BoardWritesDTO) maps.get("boards");

				model.addAttribute("broadcaster", (BroadcasterDTO)maps.get("broadcaster"));
				model.addAttribute("board", (BoardDTO)maps.get("board"));
				model.addAttribute("boardList", boards.getBoards());
				model.addAttribute("pagination", (PaginationDTO)maps.get("pagination"));
				model.addAttribute("listType", listType);
			} else if(resultMsg.equals("not_exist")) {
				return "confirm/" + resultMsg;
			} else {
				return "confirm/error_404";
			}
		} catch (Exception e) {
			throw new RuntimeException(e);
		}
		
		return "community/board/board_view";
	}
	
	// 방송인 커뮤니티 게시판 글 댓글 추천
	@PostMapping("/board/recommend")
	public @ResponseBody String boardRecommend(@RequestParam(value = "id", defaultValue = "0") int id,
			String broadcasterId, String type, HttpServletRequest request) {
		
			String resultMsg = "Fail";
		
			// 파라미터 유효성 검사
			if(!(id == 0 || broadcasterId == null || broadcasterId.length() == 0 || type == null || type.equals("up") && type.equals("down"))) {
				Integer userId = request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id");
				String ip = request.getRemoteAddr();
				
				if(userId == 0) { // 로그인 여부
					resultMsg = "Login Required";
				} else {
					Map<String, String> map = new HashMap<>();
					map.put("id", String.valueOf(id));
					map.put("broadcaster_id", broadcasterId);
					map.put("user_id", String.valueOf(userId));
					map.put("ip", ip);
					map.put("type", type);
					
					try {
						resultMsg = communityService.updateBoardWriteRecommend(map); // 글 추천
						
						if(resultMsg.equals("Success")) {
							request.setAttribute("type", "board");
							request.setAttribute("board_id", id);
						}
					} catch (Exception e) {
						throw new ResponseBodyException(e);
					}
				}
			}
		
		return resultMsg;
	}

	// 방송인 커뮤니티 게시판 글 수정 페이지
	@GetMapping("/board/modify/{id}")
	public String boardModify(@PathVariable int id, String broadcasterId,
			@RequestParam(value = "page", defaultValue = "1") int page,
			HttpServletRequest request, Model model) {
		
		try {
			Map<String, String> map = new HashMap<>();
			map.put("id", String.valueOf(id));
			map.put("broadcaster_id", broadcasterId);
			map.put("userId", String.valueOf(request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id")));
			
			Map<String, Object> maps = communityService.selectBoardWriteByMap(map);
			
			String resultMsg = (String)maps.get("result");
			
			if(resultMsg.equals("Success")) { // 정상적으로 불러왔다면
				model.addAttribute("board", (BoardDTO)maps.get("board"));
			} else if(resultMsg.equals("not_exist")) {
				return "confirm/" + resultMsg;
			} else if(resultMsg.equals("error_405")) {
				return "confirm/" + resultMsg;
			} else {
				return "confirm/error_404";
			}
			
			BroadcasterDTO broadcaster = (BroadcasterDTO)maps.get("broadcaster");
			
			if(broadcaster == null) { // 잘못된 방송인 아이디 값이 넘어왔다면
				return "confirm/not_exist";
			} else {
				model.addAttribute("broadcaster", broadcaster);
			}
		} catch (Exception e) {
			throw new RuntimeException(e);
		}
		
		return "community/board/board_modify";
	}
	
	// 방송인 커뮤니티 게시판 글 수정
	@PostMapping("/board/modifyOk")
	public String boardModifyOk(BoardDTO dto, BindingResult result,
			@RequestParam(value = "page", defaultValue = "1") int page,
			HttpServletRequest request, Model model) {

		BoardValidator validation = new BoardValidator();
		validation.setRequest(request);

		Map<String, Object> map = null;
		
		// 파라미터 유효성 검사
		if(validation.supports(dto.getClass())) {
			validation.validate(dto, result);
			
			// 오류가 존재하지 않다면
			if(!result.hasErrors()) {
				dto.setIp(request.getRemoteAddr());
				Integer userId = request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id");
				dto.setUser_id(userId);
				
				try {
					map = communityService.updateBoardWrite(dto); // 글 수정
					String resultMsg = (String)map.get("result");
					
					if(resultMsg.equals("Success")) { // 정상적으로 수정되었다면
						return "redirect:/community/board/view/" + dto.getId() + "?broadcasterId=" + dto.getBroadcaster_id() + "&page=" + page + "";
					}
				} catch (Exception e) {
					throw new RuntimeException(e);
				}
			}
		}

		BroadcasterDTO broadcaster = (BroadcasterDTO)map.get("broadcaster");
		
		if(broadcaster == null) { // 잘못된 방송인 아이디 값이 넘어왔다면
			return "confirm/not_exist";
		} else {
			model.addAttribute("broadcaster", broadcaster);
		}

		model.addAttribute("error", "updateFail");
		
		return "community/board/board_modify";
	}
	
	// 방송인 커뮤니티 게시판 글 삭제
	@PostMapping("/board/deleteOk")
	public String boardDeleteOk(int id, String broadcasterId,
			@RequestParam(value = "page", defaultValue = "1") int page,
			HttpServletRequest request, Model model) {

		try {
			Map<String, String> map = new HashMap<>();
			map.put("id", String.valueOf(id));
			map.put("broadcaster_id", broadcasterId);
			map.put("userId", String.valueOf(request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id")));
			
			String resultMsg = communityService.deleteBoardWrite(map); // 글 삭제(상태값 변경)
			
			if(resultMsg.equals("Success")) { // 정상적으로 글 상태값이 변경되었다면
				return "redirect:/community/board?id=" + broadcasterId;
			}
		} catch (Exception e) {
			throw new RuntimeException(e);
		}

		model.addAttribute("error", "deleteFail");

		return "redirect:/community/board/view/" + id + "?broadcasterId=" + broadcasterId + "&page=" + page + "";
	}
	
	// 방송인 커뮤니티 게시판 글 댓글 작성
	@PostMapping("/board/comment/write")
	public @ResponseBody String boardCommentWrite(CommentDTO dto, BindingResult result,
			String broacasterId, HttpServletRequest request) {
		
		CommentValidator validation = new CommentValidator();
		validation.setRequest(request);

		String resultMsg = "Fail";
		
		// 파라미터 유효성 검사
		if(validation.supports(dto.getClass())) {
			validation.validate(dto, result);
			
			// 오류가 존재하지 않다면
			if(!result.hasErrors()) {
				dto.setIp(request.getRemoteAddr());

				try {
					if(request.getSession().getAttribute("prevention") != null) { // 도배방지 세션 값이 존재하다면
						dto.setPrevention(true);
					}
					
					resultMsg = communityService.insertBoardWriteComment(dto); // 댓글 작성
					
					if(resultMsg.equals("Success")) { // 댓글 Push
						request.setAttribute("type", 1);
						request.setAttribute("dto", dto);
					}
				} catch (Exception e) {
					throw new ResponseBodyException(e);
				}
			}
		}
		
		return resultMsg;
	}

	// 방송인 커뮤니티 게시판 글 댓글 이미지 업로드
	@PostMapping("/board/comment/write/imageUpload")
	public @ResponseBody ImageDTO boardWriteCommentImageUpload(MultipartHttpServletRequest multi) {
		
		Iterator<String> names = multi.getFileNames();
		String name = names.next();
		MultipartFile file = multi.getFile(name);
		
		final AmazonS3 s3 = AmazonS3ClientBuilder.standard()
				.withEndpointConfiguration(new AwsClientBuilder.EndpointConfiguration(s3Properties.getProperty("s3.endPoint"), s3Properties.getProperty("s3.region")))
				.withCredentials(new AWSStaticCredentialsProvider(new BasicAWSCredentials(s3Properties.getProperty("s3.accessKey"), s3Properties.getProperty("s3.secretKey")))).build();
		
		String bucketName = "aps";
		String folderName = "boardComment";
		
		ObjectMetadata objectMetadata = new ObjectMetadata();
		objectMetadata.setContentLength(0L);
		objectMetadata.setContentType("application/x-directory");
		PutObjectRequest putObjectRequest = new PutObjectRequest(bucketName, folderName + "/", new ByteArrayInputStream(new byte[0]), objectMetadata);

		// 폴더 생성
		try {
		    s3.putObject(putObjectRequest);
		} catch (AmazonS3Exception e) {
			throw new ResponseBodyException(e);
		} catch(SdkClientException e) {
			throw new ResponseBodyException(e);
		}
		
		UUID uuid = UUID.randomUUID(); // 이미지 파일 중복 방지
		String objectName = uuid.toString() + "_" + file.getOriginalFilename();
		objectMetadata.setContentLength(file.getSize());
		objectMetadata.setContentType(file.getContentType());
		
		// Object 업로드
		try {
			s3.putObject(bucketName + "/" + folderName, objectName, file.getInputStream(), objectMetadata);
		} catch (Exception e) {
			throw new ResponseBodyException(e);
		}
		
		// Object 권한 설정
		try {
			AccessControlList accessControlList = s3.getObjectAcl(bucketName + "/" + folderName, objectName);
			accessControlList.grantPermission(GroupGrantee.AllUsers, Permission.Read);
			s3.setObjectAcl(bucketName + "/" + folderName, objectName, accessControlList);			
		} catch (AmazonS3Exception e) {
			throw new ResponseBodyException(e);
		}
		
		ImageDTO image = new ImageDTO();
		
		image.setUploaded(true);
		image.setUrl(s3Properties.getProperty("s3.endPoint") + "/" + bucketName + "/" + folderName + "/" + objectName);
		image.setName(objectName);
		
		logger.info("BoardWriteComment : {} - {} 이미지 업로드", multi.getSession().getAttribute("id"), multi.getSession().getAttribute("nickname"));
		
		return image;
	}
	
	// 방송인 커뮤니티 게시판 글 댓글 수정 페이지
	@GetMapping("/board/comment/modify/{id}")
	public String boardCommentModify(@PathVariable int id, int broadcasterBoardId, 
			HttpServletRequest request, Model model) {
		
		try {
			Map<String, Integer> map = new HashMap<>();
			map.put("id", id);
			map.put("broadcaster_board_id", broadcasterBoardId);
			map.put("userId", request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id"));

			Object object = communityService.selectBoardWriteCommentByMap(map); // 수정할 댓글
			
			if(object instanceof String) {
				String resultMsg = (String)object;
				
				if(resultMsg.equals("not_exist")) {
					return "confirm/" + resultMsg;
				} else if(resultMsg.equals("error_405")) {
					return "confirm/" + resultMsg;
				}
			} else if(object instanceof CommentDTO) { // 정상적으로 불러왔다면
				model.addAttribute("comment", (CommentDTO)object);
			}
		} catch (Exception e) {
			throw new RuntimeException(e);
		}
		
		return "community/board/comment_modify";
	}
	
	// 방송인 커뮤니티 게시판 글 댓글 수정
	@PostMapping("/board/comment/modifyOk")
	public @ResponseBody String boardCommentModifyOk(CommentDTO dto, BindingResult result,
			HttpServletRequest request) {
		
		CommentValidator validation = new CommentValidator();
		validation.setRequest(request);
		
		String resultMsg = "Fail";
		
		// 파라미터 유효성 검사
		if(validation.supports(dto.getClass())) {
			validation.validate(dto, result);
			
			// 오류가 존재하지 않다면
			if(!result.hasErrors()) {
				dto.setIp(request.getRemoteAddr());
				Integer userId = request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id");
				dto.setUser_id(userId);
				
				try {
					resultMsg = communityService.updateBoardWriteComment(dto); // 글 수정
				} catch (Exception e) {
					throw new ResponseBodyException(e);
				}
			}
		}
		
		return resultMsg;
	}
	
	// 방송인 커뮤니티 게시판 글 댓글 삭제
	@PostMapping("/board/comment/deleteOk")
	public @ResponseBody String boardCommentDeleteOk(int broadcasterBoardId, int id, HttpServletRequest request) {
		
		String resultMsg = "Fail";
		
		try {
			Map<String, Integer> map = new HashMap<>();
			map.put("broadcaster_board_id", broadcasterBoardId);
			map.put("id", id);
			map.put("userId", request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id"));
			
			resultMsg = communityService.deleteBoardWriteComment(map);
		} catch (Exception e) {
			throw new ResponseBodyException(e);
		}
	
		return resultMsg;
	}

	// 방송인 커뮤니티 게시판 글 댓글 목록
	@PostMapping("/board/comment/list")
	public @ResponseBody CommentsDTO boardCommentList(int broadcasterBoardId,
			HttpServletRequest request,
			@RequestParam(value = "listType", defaultValue = "new") String listType,
			@RequestParam(value = "page", defaultValue = "1") int page,
			@RequestParam(value = "row", defaultValue = "15") int row) {
		
		CommentsDTO boardComment = new CommentsDTO();
		
		try {
			Map<String, String> map = new HashMap<>();
			map.put("broadcaster_board_id", String.valueOf(broadcasterBoardId));
			map.put("currPage", String.valueOf(page));
			map.put("page", String.valueOf((page-1)*row));
			map.put("row", String.valueOf(row));
			map.put("pageBlock", String.valueOf(COMMENT_PAGEBLOCK));
			map.put("listType", listType);
			map.put("order", String.valueOf(COMMENT_POPULAR_ORDER));
			
			Integer userId = request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id");
			String ip =  request.getSession().getAttribute("id")==null? "0":request.getRemoteAddr();
			
			map.put("user_id", String.valueOf(userId));
			map.put("ip", ip);
			
			boardComment = communityService.selectBoardWriteCommentListByMap(map); // 댓글 목록
		} catch (Exception e) {
			boardComment.setStatus("Fail");
			throw new ResponseBodyException(e);
		}
		
		return boardComment;
	}

	// 방송인 커뮤니티 게시판 글 댓글 추천
	@PostMapping("/board/comment/recommend")
	public @ResponseBody String boardCommentRecommend(@RequestParam(value = "id", defaultValue = "0") int id,
			String broadcasterBoardId, String type, HttpServletRequest request) {
		
			String resultMsg = "Fail";
		
			// 파라미터 유효성 검사
			if(!(id == 0 || broadcasterBoardId == null || broadcasterBoardId.length() == 0 || type == null || type.equals("up") && type.equals("down"))) {
				Integer userId = (Integer)request.getSession().getAttribute("id");
				String ip = request.getRemoteAddr();
				
				if(userId == null) { // 로그인 여부
					resultMsg = "Login Required";
				} else {
					Map<String, String> map = new HashMap<>();
					map.put("id", String.valueOf(id));
					map.put("broadcaster_board_id", broadcasterBoardId);
					map.put("user_id", String.valueOf(userId));
					map.put("ip", ip);
					map.put("type", type);
					
					try {
						resultMsg = communityService.updateBoardWriteCommentRecommend(map); // 댓글 추천
						
						if(resultMsg.equals("Success")) {
							request.setAttribute("type", "boardComment");
							request.setAttribute("board_comment_id", id);
						}
					} catch (Exception e) {
						throw new ResponseBodyException(e);
					}
				}
			}
		
		return resultMsg;
	}
	
	// 방송인 커뮤니티 게시판 글 댓글의 답글 작성
	@PostMapping("/board/commentReply/write")
	public @ResponseBody String boardCommentReplyWrite(CommentReplyDTO dto, BindingResult result,
			String broacasterId, HttpServletRequest request) {
		
		CommentReplyValidator validation = new CommentReplyValidator();
		validation.setRequest(request);
		
		String resultMsg = "Fail";
		
		// 파라미터 유효성 검사
		if(validation.supports(dto.getClass())) {
			validation.validate(dto, result);
			
			// 오류가 존재하지 않다면
			if(!result.hasErrors()) {
				dto.setIp(request.getRemoteAddr());
				
				try {
					if(request.getSession().getAttribute("prevention") != null) { // 도배방지 세션 값이 존재하다면
						dto.setPrevention(true);
					}
					
					resultMsg = communityService.insertBoardWriteCommentReply(dto); // 답글 추가
					if(resultMsg.equals("Success")) { // 답글 Push
						request.setAttribute("type", 2);
						request.setAttribute("dto", dto);
					}
				} catch (Exception e) {
					throw new ResponseBodyException(e);
				}
			}
		}
		
		return resultMsg;
	}
	
	// 방송인 커뮤니티 게시판 글 댓글에 답글 삭제
	@PostMapping("/board/commentReply/deleteOk")
	public @ResponseBody String boardCommentReplyDeleteOk(int broadcasterBoardCommentId, int id, HttpServletRequest request) {
		
		String resultMsg = "Fail";
		
		try {
			Map<String, Integer> map = new HashMap<>();
			map.put("broadcaster_board_comment_id", broadcasterBoardCommentId);
			map.put("id", id);
			map.put("userId", request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id"));
			
			resultMsg = communityService.deleteBoardWriteCommentReply(map); // 답글 삭제(상태값 변경)
		} catch (Exception e) {
			throw new ResponseBodyException(e);
		}
	
		return resultMsg;
	}
	
	// 방송인 커뮤니티 게시판 글 댓글의 답글 목록
	@PostMapping("/board/commentReply/list")
	public @ResponseBody CommentReplysDTO boardCommenReplyList(int broadcasterBoardCommentId,
			@RequestParam(value = "page", defaultValue = "1") int page,
			@RequestParam(value = "row", defaultValue = "10") int row) {
		
		CommentReplysDTO boardCommentReply = new CommentReplysDTO();
		
		try {
			Map<String, Integer> map = new HashMap<>();
			map.put("broadcaster_board_comment_id", broadcasterBoardCommentId);
			map.put("page", page);
			map.put("row", row);
			
			boardCommentReply = communityService.selectBoardWriteCommentReplyListByMap(map);
		} catch (Exception e) {
			boardCommentReply.setStatus("Fail");
			throw new ResponseBodyException(e);
		}
		
		return boardCommentReply;
	}
	
}