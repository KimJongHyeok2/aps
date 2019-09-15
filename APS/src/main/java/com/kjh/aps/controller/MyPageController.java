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

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
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
import com.kjh.aps.domain.UserDTO;
import com.kjh.aps.exception.ResponseBodyException;
import com.kjh.aps.service.MyPageService;
@Controller
@RequestMapping("/mypage")
public class MyPageController {

	@Inject
	private MyPageService mypageService;
	
	@Resource(name="s3Properties")
	private Properties s3Properties;
	
	// 마이페이지
	@GetMapping("")
	public String mypage_main(HttpServletRequest request, Model model) {
		
		int id = request.getSession().getAttribute("id")==null? 0:(int)request.getSession().getAttribute("id");
		
		try {
			UserDTO user = mypageService.selectUserInfoById(id);
			request.getSession().setAttribute("level", user.getLevel());
			model.addAttribute("user", user);
		} catch (Exception e) {
			throw new RuntimeException(e);
		}
		
		return "mypage/mypage";
	}

	// 회원 닉네임 수정
	@PostMapping("/modify/nickname")
	public @ResponseBody String modifyNickname(String nickname, HttpServletRequest request) {
		
		String result = "Fail";
		int id = request.getSession().getAttribute("id")==null? 0:(int)request.getSession().getAttribute("id");
		
		// 파라미터 유효성 검사
		if(nickname != null && nickname.length() != 0 && nickname.length() <= 6) {
			Map<String, String> map = new HashMap<String, String>();
			map.put("id", String.valueOf(id));
			map.put("nickname", nickname);

			try {
				result = mypageService.updateUserNickname(map);
				
				if(result.equals("Success")) {
					request.getSession().setAttribute("nickname", nickname);
				}
			} catch (Exception e) {
				throw new ResponseBodyException(e);
			}
		}
		
		return result;
	}
	
	// 회원 프로필 사진 수정 및 업로드
	@PostMapping("/modify/profileImage")
	public @ResponseBody String modifyProfileImage(MultipartHttpServletRequest multi) {
		
		Iterator<String> names = multi.getFileNames();
		String name = names.next();
		MultipartFile file = multi.getFile(name);
		String result = "Fail";

		final AmazonS3 s3 = AmazonS3ClientBuilder.standard()
				.withEndpointConfiguration(new AwsClientBuilder.EndpointConfiguration(s3Properties.getProperty("s3.endPoint"), s3Properties.getProperty("s3.region")))
				.withCredentials(new AWSStaticCredentialsProvider(new BasicAWSCredentials(s3Properties.getProperty("s3.accessKey"), s3Properties.getProperty("s3.secretKey")))).build();
		
		String bucketName = "aps";
		String folderName = "profile";
		
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
			
		Map<String, String> map = new HashMap<>();
		int id = multi.getSession().getAttribute("id")==null? 0:(int)multi.getSession().getAttribute("id");
		map.put("id", String.valueOf(id));
		map.put("profile", objectName);
		
		try {
			result = mypageService.updateUserProfileImage(map);
		} catch (Exception e) {
			throw new ResponseBodyException(e);
		}
		
/*		String prevProfileImageName = (String)multi.getSession().getAttribute("profile");
		
		if(prevProfileImageName != null) {
			file = new File(saveDirectory + "/" + prevProfileImageName);
			if(file.isFile()) {							
				file.delete();
			}
		}*/
		
		// 기존의 Object 버킷에서 삭제
		String prevProfile = (String)multi.getSession().getAttribute("profile");
		if(prevProfile != null && prevProfile.length() != 0) {
			try {
				s3.deleteObject(bucketName + "/" + folderName, prevProfile);
			} catch (AmazonS3Exception e) {
				throw new ResponseBodyException(e);
			}
		}
		
		multi.getSession().setAttribute("profile", map.get("profile"));
		
		return result;
	}
	
/*	// 회원 프로필 사진 수정 및 업로드
	@PostMapping("/modify/profileImage")
	public @ResponseBody String modifyProfileImage(HttpServletRequest request) {
		
		String saveDirectory = request.getSession().getServletContext().getRealPath("/resources/upload/profile");
		File file = new File(saveDirectory);
		if(!file.isDirectory()) {
			file.mkdirs();
		}
		
		int maxPostSize = 3 * 1024 * 1024;
		String encoding = "UTF-8";
		FileRenamePolicy policy = new DefaultFileRenamePolicy();
		
		String result = "Fail";
		
		try {
			MultipartRequest multi = new MultipartRequest(request, saveDirectory, maxPostSize, encoding, policy);
			
			@SuppressWarnings("unchecked")
			Enumeration<String> enums = multi.getFileNames();
			
			if(enums.hasMoreElements()) {
				String name = enums.nextElement();
				String value = multi.getFilesystemName(name);
				
				Map<String, String> map = new HashMap<>();
				int id = request.getSession().getAttribute("id")==null? 0:(int)request.getSession().getAttribute("id");
				map.put("id", String.valueOf(id));
				map.put("profile", value);
				
				result = mypageService.updateUserProfileImage(map);
				
				if(result.equals("Success")) {
					String prevProfileImageName = (String)request.getSession().getAttribute("profile");
					
					if(prevProfileImageName != null) {
						file = new File(saveDirectory + "/" + prevProfileImageName);
						if(file.isFile()) {							
							file.delete();
						}
					}
					request.getSession().setAttribute("profile", map.get("profile"));
				}
			}
		} catch (Exception e) {
			throw new ResponseBodyException(e);
		}
		
		return result;
	}
*/	
	// 회원 비밀번호 수정
	@PostMapping("/modify/password")
	public String modifyPassword(String currentPassword, String newPasswordCheck,
			HttpServletRequest request, Model model) {
		
		String result = "Fail";
		
		// 파라미터 유효성 검사
		if(currentPassword != null && currentPassword.length() != 0 && newPasswordCheck != null && newPasswordCheck.length() != 0) {
			int id = request.getSession().getAttribute("id")==null? 0:(int)request.getSession().getAttribute("id");
			
			Map<String, String> map = new HashMap<>();
			map.put("id", String.valueOf(id));
			map.put("currentPassword", currentPassword);
			map.put("newPassword", newPasswordCheck);
			
			try {
				result = mypageService.updateUserPassword(map);
			} catch (Exception e) {
				throw new RuntimeException(e);
			}
		}
		
		model.addAttribute("result", result);
		
		return "mypage/mypage";
	}
	
	// 회원탈퇴 페이지
	@GetMapping("/leave")
	public String leave() {
		return "mypage/leave";
	}
	
	// 회원탈퇴
	@PostMapping("/leaveOk")
	public String leaveOk(String policy, HttpServletRequest request) {

		String resultView = "confirm/error_400";
		
		if(policy != null && policy.equals("on")) {
			int id = request.getSession().getAttribute("id")==null? 0:(int)request.getSession().getAttribute("id");
			Map<String, String> map = new HashMap<>();
			map.put("id", String.valueOf(id));
			map.put("type", "leave");
			
			try {
				String result = mypageService.updateUserStatus(map);
				
				if(result.equals("Success")) {
					resultView = "confirm/leave_success";
				}
			} catch (Exception e) {
				throw new RuntimeException(e);
			}
		}
		
		return resultView;
	}
	
}