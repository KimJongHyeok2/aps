package com.kjh.aps.controller;

import java.io.ByteArrayInputStream;
import java.util.HashMap;
import java.util.Iterator;
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
import com.kjh.aps.domain.CommentDTO;
import com.kjh.aps.domain.CommentReplyDTO;
import com.kjh.aps.domain.CommentReplysDTO;
import com.kjh.aps.domain.CommentsDTO;
import com.kjh.aps.domain.ImageDTO;
import com.kjh.aps.domain.PaginationDTO;
import com.kjh.aps.exception.ResponseBodyException;
import com.kjh.aps.service.CustomerService;
import com.kjh.aps.validator.BoardValidator;
import com.kjh.aps.validator.CommentReplyValidator;
import com.kjh.aps.validator.CommentValidator;

@Controller
@RequestMapping("/customerService")
public class CustomerController {
	
	private static final Logger logger = LoggerFactory.getLogger(CustomerController.class);

	@Inject
	private CustomerService customerService;
	private final int BOARD_PAGEBLOCK = 5;
	private final int COMMENT_PAGEBLOCK = 5;
	private final int COMMENT_POPULAR_ORDER = 20;
	
	@Resource(name="s3Properties")
	private Properties s3Properties;
	
	// 고객센터 페이지
	@GetMapping("/{categoryId}")
	public String customerService(@PathVariable String categoryId,
			@RequestParam(value = "page", defaultValue = "1") int page,
			@RequestParam(value = "row", defaultValue = "10") int row, Model model) {
		
		if(categoryId == null || !(categoryId.equals("notice") || categoryId.equals("update") || categoryId.equals("event"))) {
			categoryId = "notice";
		}
		
		Map<String, String> map = new HashMap<>();
		map.put("currPage", String.valueOf(page));
		map.put("page", String.valueOf((page-1)*row));
		map.put("row", String.valueOf(row));
		map.put("pageBlock", String.valueOf(BOARD_PAGEBLOCK));
		map.put("category_id", categoryId);
		
		try {
			Map<String, Object> maps = customerService.selectCustomerServiceBoardWriteListByMap(map);
			
			model.addAttribute("boardWrites", (BoardWritesDTO)maps.get("boardWrites"));
			model.addAttribute("pagination", (PaginationDTO)maps.get("pagination"));
		} catch (Exception e) {
			throw new RuntimeException(e);
		}
		
		return "customerService/customer_service";
	}
	
	@PostMapping("/{categoryId}")
	public String customerServiceView(@PathVariable String categoryId, int id, Model model) {
		
		if(categoryId == null || !(categoryId.equals("notice") || categoryId.equals("update") || categoryId.equals("event"))) {
			categoryId = "notice";
		}
		
		Map<String, String> map = new HashMap<>();
		map.put("currPage", String.valueOf(1));
		map.put("page", String.valueOf((1-1)*10));
		map.put("row", String.valueOf(10));
		map.put("pageBlock", String.valueOf(BOARD_PAGEBLOCK));
		map.put("category_id", categoryId);
		
		try {
			Map<String, Object> maps = customerService.selectCustomerServiceBoardWriteListByMap(map);
			
			model.addAttribute("boardWrites", (BoardWritesDTO)maps.get("boardWrites"));
			model.addAttribute("pagination", (PaginationDTO)maps.get("pagination"));
		} catch (Exception e) {
			throw new RuntimeException(e);
		}
		
		return "customerService/customer_service";
	}
	
	// 방송인 커뮤니티 게시판 글 검색
	@GetMapping(value = "/{categoryId}", params = {"searchValue", "searchType"})
	public String board(@PathVariable String categoryId, String searchValue,
			@RequestParam(value = "searchType", defaultValue = "1") int searchType,
			@RequestParam(value = "page", defaultValue = "1") int page,
			@RequestParam(value = "row", defaultValue = "10") int row, Model model) {
		
		String resultView = "confirm/error_500";
		
		if(categoryId == null || !(categoryId.equals("notice") || categoryId.equals("update") || categoryId.equals("event"))) {
			categoryId = "notice";
		}
		
		// 파라미터 유효성 검사
		if(!(searchValue == null || searchValue.length() == 0)) {
			try {
				Map<String, String> map = new HashMap<>();
				map.put("category_id", categoryId);
				map.put("searchValue", searchValue);
				map.put("searchType", String.valueOf(searchType));
				map.put("currPage", String.valueOf(page));
				map.put("page", String.valueOf((page-1)*row));
				map.put("row", String.valueOf(row));
				map.put("pageBlock", String.valueOf(BOARD_PAGEBLOCK));

				Map<String, Object> maps = customerService.selectCustomerServiceSearchBoardWriteListByMap(map);

				BoardWritesDTO boardWrites = (BoardWritesDTO)maps.get("boardWrites");
				PaginationDTO pagination = (PaginationDTO)maps.get("pagination");
				
				model.addAttribute("boardWrites", boardWrites);
				model.addAttribute("pagination", pagination);
				resultView = "customerService/customer_service";
			} catch (Exception e) {
				throw new RuntimeException(e);
			} 
		}
		
		return resultView;
	}
	
	// 고객센터 글 이미지 업로드
	@PostMapping("/write/imageUpload")
	public @ResponseBody ImageDTO imageUpload(MultipartHttpServletRequest multi) {
		
		Iterator<String> names = multi.getFileNames();
		String name = names.next();
		MultipartFile file = multi.getFile(name);
		
		final AmazonS3 s3 = AmazonS3ClientBuilder.standard()
				.withEndpointConfiguration(new AwsClientBuilder.EndpointConfiguration(s3Properties.getProperty("s3.endPoint"), s3Properties.getProperty("s3.region")))
				.withCredentials(new AWSStaticCredentialsProvider(new BasicAWSCredentials(s3Properties.getProperty("s3.accessKey"), s3Properties.getProperty("s3.secretKey")))).build();
		
		String bucketName = "aps";
		String folderName = "notice";
		
		ObjectMetadata objectMetadata = new ObjectMetadata();
		objectMetadata.setContentLength(0L);
		objectMetadata.setContentType("application/x-directory");
		PutObjectRequest putObjectRequest = new PutObjectRequest(bucketName, folderName + "/", new ByteArrayInputStream(new byte[0]), objectMetadata);

		// 폴더 생성
		try {
		    s3.putObject(putObjectRequest);
		} catch (AmazonS3Exception e) {
		    e.printStackTrace();
		} catch(SdkClientException e) {
		    e.printStackTrace();
		}
		
		UUID uuid = UUID.randomUUID(); // 이미지 파일 중복 방지
		String objectName = uuid.toString() + "_" + file.getOriginalFilename();
		objectMetadata.setContentLength(file.getSize());
		objectMetadata.setContentType(file.getContentType());
		
		// Object 업로드
		try {
			s3.putObject(bucketName + "/" + folderName, objectName, file.getInputStream(), objectMetadata);
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		// Object 권한 설정
		try {
			AccessControlList accessControlList = s3.getObjectAcl(bucketName + "/" + folderName, objectName);
			accessControlList.grantPermission(GroupGrantee.AllUsers, Permission.Read);
			s3.setObjectAcl(bucketName + "/" + folderName, objectName, accessControlList);			
		} catch (AmazonS3Exception e) {
			e.printStackTrace();
		}
		
		ImageDTO image = new ImageDTO();
		
		image.setUploaded(true);
		image.setUrl(s3Properties.getProperty("s3.endPoint") + "/" + bucketName + "/" + folderName + "/" + objectName);
		image.setName(objectName);
		
		logger.info("CustomerWrite : {} - {} 이미지 업로드", multi.getSession().getAttribute("id"), multi.getSession().getAttribute("nickname"));
		
		return image;
	}
	
	// 고객센터 글 작성
	@PostMapping("/writeOk")
	public String writeOk(BoardDTO dto, BindingResult result,
			HttpServletRequest request) {
		
		String resultView = "confirm/error_500";
		
		BoardValidator validation = new BoardValidator();
		validation.setRequest(request);
		
		// 파라미터 유효성 검사
		if(validation.supports(dto.getClass())) {
			validation.validate(dto, result);
			
			if(!result.hasErrors()) {
				dto.setIp(request.getRemoteAddr());
				
				try {
					resultView = customerService.insertCustomerServiceBoardWrite(dto);
				} catch (Exception e) {
					throw new RuntimeException(e);
				}
			}
		}
		
		return resultView;
	}
	
	// 조회 수 업데이트
	@PostMapping("/view")
	public @ResponseBody Map<String, String> view(@RequestParam(value = "id", defaultValue = "0") int id,
			HttpServletRequest request) {
		
		Map<String, String> map = new HashMap<>();
		map.put("result", "Fail");
		
		// 파라미터 유효성 검사
		if(id != 0) {
			/*if(request.getSession().getAttribute("n-view-" + id) == null) {*/
			try {
				int viewCount = customerService.updateCustomerServiceBoardWriteViewCount(id);
					
				if(viewCount != 0) {
					map.put("result", "Success");
					map.put("view", String.valueOf(viewCount));
				}
			} catch (Exception e) {
				throw new ResponseBodyException(e);
			}
				/*request.getSession().setAttribute("n-view-" + id, id);*/
			/*}*/
		}
		
		return map;
	}
	
	// 고객센터 글 수정 페이지
	@GetMapping("/modify/{id}")
	public String modify(@PathVariable int id, String categoryId,
			HttpServletRequest request, Model model) {

		String resultView = "confirm/error_500";
		
		try {
			Map<String, String> map = new HashMap<>();
			map.put("id", String.valueOf(id));
			map.put("category_id", categoryId);
			map.put("user_id", String.valueOf(request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id")));
			
			Map<String, Object> maps = customerService.selectCustomerServiceBoardWriteByMap(map);
			
			String resultMsg = (String)maps.get("result");
			
			if(resultMsg.equals("Success")) { // 정상적으로 불러왔다면
				model.addAttribute("categoryId", "modify");
				model.addAttribute("board", (BoardDTO)maps.get("board"));
				resultView = "customerService/customer_service";
			} else if(resultMsg.equals("not_exist")) {
				resultView = "confirm/" + resultMsg;
			} else if(resultMsg.equals("error_405")) {
				resultView = "confirm/" + resultMsg;
			}
		} catch (Exception e) {
			throw new RuntimeException(e);
		}
		
		return resultView;
	}
	
	// 고객센터 글 수정
	@PostMapping("/modifyOk")
	public String modifyOk(BoardDTO dto, BindingResult result,
			HttpServletRequest request) {
		
		String resultView = "confirm/error_500";
		
		BoardValidator validation = new BoardValidator();
		validation.setRequest(request);
		
		// 파라미터 유효성 검사
		if(validation.supports(dto.getClass())) {
			validation.validate(dto, result);
			
			// 오류가 존재하지 않는다면
			if(!result.hasErrors()) {
				dto.setIp(request.getRemoteAddr());
				
				try {
					resultView = customerService.updateCustomerServiceBoardWrite(dto);
				} catch (Exception e) {
					throw new RuntimeException(e);
				}
			}
		}
		
		return resultView;
	}
	
	// 고객센터 글 삭제
	@PostMapping("/deleteOk")
	public String deleteOk(@RequestParam(value = "id", defaultValue = "0") int id, String categoryId,
			HttpServletRequest request) {
		
		String resultView = "confirm/error_500";
		
		try {
			Map<String, String> map = new HashMap<>();
			map.put("id", String.valueOf(id));
			map.put("category_id", categoryId);
			map.put("user_id", String.valueOf(request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id")));
			
			resultView = customerService.deleteCustomerServiceBoardWrite(map);
		} catch (Exception e) {
			throw new RuntimeException(e);
		}
		
		return resultView;
	}
	
	// 고객센터 글의 댓글 작성
	@PostMapping("/comment/write")
	public @ResponseBody String commentWrite(CommentDTO dto, BindingResult result,
			HttpServletRequest request) {
		
		String resultMsg = "Fail";
		CommentValidator validation = new CommentValidator();
		validation.setRequest(request);
		
		// 파라미터 유효성 검사
		if(validation.supports(dto.getClass())) {
			validation.validate(dto, result);
			
			// 오류가 존재하지 않는다면
			if(!result.hasErrors()) {
				dto.setIp(request.getRemoteAddr());
				
				try {
					if(request.getSession().getAttribute("prevention") != null) { // 도배방지 세션 값이 존재하다면
						dto.setPrevention(true);
					}
					
					resultMsg = customerService.insertCustomerServiceBoardWriteComment(dto);
					
					if(resultMsg.equals("Success")) {
						request.setAttribute("type", 4);
						request.setAttribute("dto", dto);
					}
				} catch (Exception e) {
					throw new ResponseBodyException(e);
				}
			}
		}
		
		return resultMsg;
	}
	
	// 고객센터 글의 수정할 댓글 조회
	@GetMapping("/comment/modify/{id}")
	public String commentModify(@PathVariable int id, int noticeId, 
			HttpServletRequest request, Model model) {
		
		String resultView = "confirm/error_500";
		
		try {
			Map<String, Integer> map = new HashMap<>();
			map.put("id", id);
			map.put("notice_id", noticeId);
			map.put("user_id", request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id"));

			Object object = customerService.selectCustomerServiceBoardWriteCommentByMap(map); // 수정할 댓글
		
			if(object instanceof String) {
				String resultMsg = (String)object;	
				resultView = "confirm/" + resultMsg;
			} else if(object instanceof CommentDTO) { // 정상적으로 불러왔다면
				model.addAttribute("comment", (CommentDTO)object);
				resultView = "customerService/comment_modify";
			}
		} catch (Exception e) {
			throw new RuntimeException(e);
		}
		
		return resultView;
	}
	
	// 고객센터 글의 댓글 수정
	@PostMapping("/comment/modifyOk")
	public @ResponseBody String commentModifyOk(CommentDTO dto, BindingResult result,
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
					resultMsg = customerService.updateCustomerServiceBoardWriteComment(dto);
				} catch (Exception e) {
					throw new ResponseBodyException(e);
				}
			}
		}
		
		return resultMsg;
	}
	
	// 방송인 민심평가 삭제
	@PostMapping("/comment/deleteOk")
	public @ResponseBody String commentDeleteOk(int noticeId,
			@RequestParam(value = "id", defaultValue = "0") int id,
			HttpServletRequest request) {
		
		String result = "Fail";
		
		try {
			Map<String, Integer> map = new HashMap<>();
			map.put("notice_id", noticeId);
			map.put("id", id);
			map.put("user_id", request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id"));
			
			result = customerService.deleteCustomerServiceBoardWriteComment(map);
		} catch (Exception e) {
			throw new ResponseBodyException(e);
		}
		
		return result;
	}

	// 고객센터 글의 댓글 추천
	@PostMapping("/comment/recommend")
	public @ResponseBody String commentRecommend(@RequestParam(value = "id", defaultValue = "0") int id,
			String type, HttpServletRequest request) {
		
			String resultMsg = "Fail";
		
			// 파라미터 유효성 검사
			if(!(id == 0 || type == null || type.equals("up") && type.equals("down"))) {
				Integer userId = request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id");
				String ip = request.getRemoteAddr();
				
				if(userId == 0) { // 로그인 여부
					resultMsg = "Login Required";
				} else {
					Map<String, String> map = new HashMap<>();
					map.put("id", String.valueOf(id));
					map.put("user_id", String.valueOf(userId));
					map.put("ip", ip);
					map.put("type", type);
					
					try {
						resultMsg = customerService.updateCustomerServiceBoardWriteCommentRecommend(map);
						
						if(resultMsg.equals("Success")) {
							request.setAttribute("type", "noticeComment");
							request.setAttribute("notice_comment_id", id);
						}
					} catch (Exception e) {
						throw new ResponseBodyException(e);
					}
				}
			}
		
		return resultMsg;
	}
	
	// 고객센터 글 댓글 목록
	@PostMapping("/comment/list")
	public @ResponseBody CommentsDTO commentList(int noticeId,
			HttpServletRequest request,
			@RequestParam(value = "listType", defaultValue = "new") String listType,
			@RequestParam(value = "page", defaultValue = "1") int page,
			@RequestParam(value = "row", defaultValue = "5") int row) {
		
		CommentsDTO boardComment = new CommentsDTO();
		
		try {
			Map<String, String> map = new HashMap<>();
			map.put("notice_id", String.valueOf(noticeId));
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
			
			boardComment = customerService.selectCustomerServiceBoardWriteCommentListByMap(map);
		} catch (Exception e) {
			boardComment.setStatus("Fail");
			throw new ResponseBodyException(e);
		}
		
		return boardComment;
	}
	
	// 고객센터 글 댓글의 답글 작성
	@PostMapping("/commentReply/write")
	public @ResponseBody String commentReplywWrite(CommentReplyDTO dto, BindingResult result,
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
					
					resultMsg = customerService.insertCustomerServiceBoardWriteCommentReply(dto);
					
					if(resultMsg.equals("Success")) {
						request.setAttribute("type", 5);
						request.setAttribute("dto", dto);
					}
				} catch (Exception e) {
					throw new ResponseBodyException(e);
				}
			}
		}
		
		return resultMsg;
	}
	
	// 고객센터 글의 답글 삭제
	@PostMapping("/commentReply/deleteOk")
	public @ResponseBody String boardCommentReplyDeleteOk(int noticeCommentId, int id, HttpServletRequest request) {
		
		String resultMsg = "Fail";
		
		try {
			Map<String, Integer> map = new HashMap<>();
			map.put("notice_comment_id", noticeCommentId);
			map.put("id", id);
			map.put("user_id", request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id"));
			
			resultMsg = customerService.deleteCustomerServiceBoardWriteCommentReply(map); // 답글 삭제(상태값 변경)
		} catch (Exception e) {
			throw new ResponseBodyException(e);
		}
	
		return resultMsg;
	}
	
	// 고객센터 글 댓글의 답글 목록
	@PostMapping("/commentReply/list")
	public @ResponseBody CommentReplysDTO boardCommenReplyList(int noticeCommentId,
			@RequestParam(value = "page", defaultValue = "1") int page,
			@RequestParam(value = "row", defaultValue = "10") int row) {
		
		CommentReplysDTO boardCommentReply = new CommentReplysDTO();
		
		try {
			Map<String, Integer> map = new HashMap<>();
			map.put("notice_comment_id", noticeCommentId);
			map.put("page", page);
			map.put("row", row);
			
			boardCommentReply = customerService.selectCustomerServiceBoardWriteCommentReplyLisByMap(map);
		} catch (Exception e) {
			boardCommentReply.setStatus("Fail");
			throw new ResponseBodyException(e);
		}
		
		return boardCommentReply;
	}
	
}