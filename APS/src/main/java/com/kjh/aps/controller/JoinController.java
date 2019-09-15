package com.kjh.aps.controller;

import javax.inject.Inject;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import javax.mail.internet.MimeMessage.RecipientType;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Controller;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import com.kjh.aps.domain.EmailAccessDTO;
import com.kjh.aps.domain.JoinDTO;
import com.kjh.aps.domain.SocialLoginDTO;
import com.kjh.aps.exception.ResponseBodyException;
import com.kjh.aps.service.JoinService;
import com.kjh.aps.validator.JoinValidator;
import com.kjh.aps.validator.SocialLoginValidator;

@Controller
@RequestMapping("/join")
public class JoinController {
	
	@Inject
	private JoinService joingService;
	@Inject
	private JavaMailSender mailSender;
	@Value("${email.username}")
	private String fromEmail;
	
	// 회원가입 약관동의 페이지
	@GetMapping("/policy")
	public String policy() {
		return "join/policy";
	}
	
	// 회원가입 정보입력 페이지
	@PostMapping("/input")
	public String input(String policy1, String policy2) {
		
		// 약관에 동의하지 않은 항목이 있다면 리다이렉트
		if(policy1 == null || policy2 == null) {
			return "redirect:/join/policy";
		} else {
			// 약관에 동의하였으나 올바르지 않은 값을 임의로 설정 했을 시
			if(!(policy1.equals("policy1-agree") && policy2.equals("policy2-agree"))) {
				return "redirect:/join/policy";
			}
		}
		
		return "join/input";
	}
	
	// 이메일 인증키 요청
	@PostMapping("/input/emailAccess")
	public @ResponseBody String emailAccess(String email) {
		
		// 파라미터 유효성 검사
		if(!(email == null || email.length() == 0)) {
			EmailAccessDTO dto = new EmailAccessDTO(); // 인증키 난수 생성
			
			try {
				int successCount = joingService.insertEmailAccessKey(dto); // DB에 인증키 추가
				
				if(successCount == 1) { // 인증키가 DB에 정상적으로 추가되었으면 인증키 이메일 전송
					MimeMessage msg = mailSender.createMimeMessage();
					
					String html = "";
					html += "<div>";
						html += "<div style='max-width: 500px; margin: auto; border: 1px solid #EAEAEA; font-family: '나눔바른고딕';'>";
/*							html += "<div style='padding: 10px; text-align: center; font-family: '나눔스퀘어';>";
								html += "<h3>LOGO</h3>";
							html += "</div>";*/
							html += "<div style='padding: 10px; text-align: center;'>";
								html += "<div style='display: inline-block; margin-right: 5px; padding-left: 5px; font-size: 13pt;'>인증번호 : </div>";
								html += "<div style='display: inline-block; font-size: 13pt; font-weight: bold; color: dimgray;'>" + dto.getAccesskey() + "</div>";
							html += "</div>";
						html += "</div>";
					html += "</div>";
					
					msg.setFrom(new InternetAddress(fromEmail, "APS", "utf-8"));
					msg.setText(html, "utf-8", "html");
					msg.setSubject("[APS] 이메일 인증키 입니다.");
					msg.addRecipient(RecipientType.TO, new InternetAddress(email));		
					mailSender.send(msg);
					
					return String.valueOf(dto.getId());
				}
			} catch (Exception e) {
				throw new ResponseBodyException(e);
			}
		}
		
		return "Fail";
	}
	
	// 이메일 인증키 확인
	@PostMapping("/input/emailAccessOk")
	public @ResponseBody String emailAccessOk(EmailAccessDTO dto) {
		
		// 파라미터 유효성 검사
		if(!(dto.getId() == 0 || dto.getAccesskey() == null || dto.getAccesskey().length() == 0)) {
			try {
				String dbAccessKey = joingService.selectEmailAccessKeyById(dto.getId()); // DB에 인증키 불러오기
				
				if(dbAccessKey != null) {
					if(dto.getAccesskey().equals(dbAccessKey)) { // 인증키가 일치한다면
						return "Success";
					}
				}
			} catch (Exception e) {
				throw new ResponseBodyException(e);
			}
		}
		
		return "Fail";
	}
	
	// 아이디 및 이메일 중복확인
	@PostMapping("/input/overlap")
	public @ResponseBody String overlap(String value, String type) {
		
		// 파라미터 유효성 검사
		if(!(value == null || value.length() == 0 || type == null || type.length() == 0)) {
			try {
				int count = 0;
				if(type.equals("username")) { // 아이디 중복확인
					count = joingService.selectUsernameCountByUsername(value);
				} else if(type.equals("email")) { // 이메일 중복확인
					count = joingService.selectEmailCountByEmail(value);
				}
				
				if(count == 0) { // 중복된 값이 없을 시
					return "Success";
				}
			} catch (Exception e) {
				throw new ResponseBodyException(e);
			}
		}
		
		return "Fail";
	}
	
	// 회원가입
	@PostMapping("/input/user")
	public @ResponseBody String joinUser(JoinDTO dto, BindingResult result) {

		JoinValidator validation = new JoinValidator();
		
		// 파라미터 유효성 검사
		if(validation.supports(dto.getClass())) {
			validation.validate(dto, result);
			
			// 오류가 존재하지 않다면
			if(!result.hasErrors()) {
				try {
					int successCount = joingService.insertUser(dto); // DB에 회원정보 추가
					
					if(successCount == 1) { // DB에 정상적으로 추가되었다면
						return "Success";
					}
				} catch (Exception e) {
					throw new ResponseBodyException(e);
				}
			}
		}
		
		return "Fail";
	}
	
	// 소셜 회원가입
	@PostMapping("/input/socialUser")
	public @ResponseBody SocialLoginDTO joinSocialUser(SocialLoginDTO dto, BindingResult result) {
		
		SocialLoginValidator validation = new SocialLoginValidator();
		
		if(validation.supports(dto.getClass())) {
			validation.validate(dto, result);
			
			if(!result.hasErrors()) {
				try {
					dto = joingService.selectUserBySocialLoginDTO(dto);
				} catch (Exception e) {
					throw new ResponseBodyException(e);
				}
			}
		}
		
		return dto;
	}
}