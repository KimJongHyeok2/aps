package com.kjh.aps.controller;

import java.io.UnsupportedEncodingException;
import java.util.HashMap;
import java.util.Map;
import java.util.Random;

import javax.inject.Inject;
import javax.mail.MessagingException;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import javax.mail.internet.MimeMessage.RecipientType;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.apache.ibatis.session.SqlSession;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import com.github.scribejava.core.model.OAuth2AccessToken;
import com.kjh.aps.exception.ResponseBodyException;
import com.kjh.aps.persistent.LoginDAO;
import com.kjh.aps.util.GoogleLoginBO;
import com.kjh.aps.util.NaverLoginBO;
import com.kjh.aps.util.PasswordEncoding;

@Controller
@RequestMapping("/login")
public class LoginController {
	
	@Inject
	private SqlSession sqlSession;
	@Inject
	private JavaMailSender mailSender;
	@Value("${email.username}")
	private String fromEmail;
	
	@Inject
	private NaverLoginBO naverLoginBO;
	@Inject
	private GoogleLoginBO googleLoginBO;
	
	// 로그인 페이지
	@RequestMapping("")
	public String login(HttpSession session, Model model) {
		
		String naverUrl = naverLoginBO.getAuthorizationUrl(session);
		String googleUrl = googleLoginBO.getAuthorizationUrl();
		
		model.addAttribute("naverUrl", naverUrl);		
		model.addAttribute("googleUrl", googleUrl);		
		return "login/login";
	}
	
	// 아이디 찾기 페이지
	@GetMapping("/find/username")
	public String findUsername() {
		return "login/find/find_username";
	}

	// 비밀번호 찾기 페이지
	@GetMapping("/find/password")
	public String findPassword() {
		return "login/find/find_password";
	}
	
	// 아이디 찾기 서비스
	@PostMapping(value = "/find/username", params = {"name", "email"})
	public @ResponseBody String findUsernameService(String name, String email) {
		
		String resultMsg = "Fail";
		
		// 파라미터 유효성 검사
		if(!(name == null || name.length() == 0 || email == null || email.length() == 0)) {
			LoginDAO dao = sqlSession.getMapper(LoginDAO.class);
			Map<String, String> map = new HashMap<>();
			map.put("name", name);
			map.put("email", email);
			
			// DB에 해당 회원정보가 존재하는지
			Map<String, String> result = dao.selectUserInfoByMap(map);
			
			if(result != null) { // 회원정보가 존재한다면
				
				int type = Integer.parseInt(result.get("type"));
				
				if(type == 1) {
					MimeMessage msg = mailSender.createMimeMessage();
					
					String html = "";
					html += "<div>";
						html += "<div style='max-width: 500px; margin: auto; border: 1px solid #EAEAEA; font-family: '나눔바른고딕';'>";
/*							html += "<div style='padding: 10px; text-align: center; font-family: '나눔스퀘어';>";
								html += "<h3>LOGO</h3>";
							html += "</div>";*/
							html += "<div style='padding: 10px; text-align: center;'>";
								html += "<div style='display: inline-block; margin-right: 5px; padding-left: 5px; font-size: 13pt;'>아이디 : </div>";
								html += "<div style='display: inline-block; font-size: 13pt; font-weight: bold; color: dimgray;'>" + result.get("username") + "</div>";
							html += "</div>";
						html += "</div>";
					html += "</div>";
					
					try {
						msg.setFrom(new InternetAddress(fromEmail, "APS", "utf-8"));
						msg.setText(html, "utf-8", "html");
						msg.setSubject("[APS] 아이디 찾기 서비스입니다.");
						msg.addRecipient(RecipientType.TO, new InternetAddress(email));
						mailSender.send(msg);
						
						resultMsg = "Success";
					} catch (UnsupportedEncodingException e) {
						throw new ResponseBodyException(e);
					} catch (MessagingException e) {
						throw new ResponseBodyException(e);
					}
				} else {
					resultMsg = "Incorrect User Type";
				}
			}
		}
		
		return resultMsg;
	}
	
	// 비밀번호 찾기 서비스
	@PostMapping(value = "/find/password", params = {"name", "username", "email"})
	public @ResponseBody String findPasswordService(String name, String username, String email) {
		
		String resultMsg = "Fail";
		// 파라미터 유효성 검사
		if(!(name == null || name.length() == 0 || username == null || username.length() == 0 || email == null || email.length() == 0)) {
			LoginDAO dao = sqlSession.getMapper(LoginDAO.class);
			Map<String, String> map = new HashMap<>();
			map.put("name", name);
			map.put("username", username);
			map.put("email", email);
			
			// DB에 해당 회원정보가 존재하는지
			Integer type = dao.selectUserTypeByMap(map);
			
			if(type != null && type == 1) { // 회원정보가 존재한다면
				// 임시 비밀번호 생성
				Random ran = new Random();
				StringBuffer sb = new StringBuffer();
				int num;
				int size = 10;
				
				do {
					num = ran.nextInt(75) + 48;
					if ((num >= 48 && num <= 57) || (num >= 65 && num <= 90) || (num >= 97 && num <= 122)) {
						sb.append((char) num);
					} else {
						continue;
					}

				} while (sb.length() < size);
				
				PasswordEncoding passwordEncoder = new PasswordEncoding();
				String tempPassword = passwordEncoder.encode(sb); // 임시 비밀번호 암호화
				
				map.put("tempPassword", tempPassword);
				
				int successCount = dao.updatePasswordByMap(map); // 해당 회원 비밀번호 변경
				
				if(successCount == 1) { // 비밀번호 변경에 성공했다면 이메일으로 변경한 임시 비밀번호 전송
					MimeMessage msg = mailSender.createMimeMessage();
					
					String html = "";
					html += "<div>";
						html += "<div style='max-width: 500px; margin: auto; border: 1px solid #EAEAEA; font-family: '나눔바른고딕';'>";
/*							html += "<div style='padding: 10px; text-align: center; font-family: '나눔스퀘어';>";
								html += "<h3>LOGO</h3>";
							html += "</div>";*/
							html += "<div style='padding: 10px; text-align: center;'>";
								html += "<div style='display: inline-block; margin-right: 5px; padding-left: 5px; font-size: 13pt;'>임시 비밀번호 : </div>";
								html += "<div style='display: inline-block; font-size: 13pt; font-weight: bold; color: dimgray;'>" + sb + "</div>";
							html += "</div>";
						html += "</div>";
					html += "</div>";
					
					try {
						msg.setFrom(new InternetAddress(fromEmail, "APS", "utf-8"));
						msg.setText(html, "utf-8", "html");
						msg.setSubject("[APS] 임시 비밀번호입니다.");
						msg.addRecipient(RecipientType.TO, new InternetAddress(email));
						mailSender.send(msg);
						
						resultMsg = "Success";
					} catch (UnsupportedEncodingException e) {
						throw new ResponseBodyException("findPasswordService");
					} catch (MessagingException e) {
						throw new ResponseBodyException("findPasswordService");
					}
				}
			} else {
				resultMsg = "Incorrect User Type";
			}
		}
		
		return resultMsg;
	}
	
	@GetMapping("/naverLogin")
	public String naverLogin(String code, String state, HttpSession session, Model model) {
		
		try {
			OAuth2AccessToken oauthToken;
			oauthToken = naverLoginBO.getAccessToken(session, code, state);
			
			String result = naverLoginBO.getUserProfile(oauthToken);
			
			JSONParser parser = new JSONParser();
			Object object = parser.parse(result);
			JSONObject jsonObject = (JSONObject)object;
				
			JSONObject responseObject = (JSONObject)jsonObject.get("response");	
			if(responseObject.get("name") == null || responseObject.get("id") == null || responseObject.get("email") == null) { // 동의하지 않은 항목이 존재한다면
				return "redirect:" + naverLoginBO.getRepromptAuthorizationUrl(session);
			}
			model.addAttribute("name", responseObject.get("name"));
			model.addAttribute("username", responseObject.get("id"));
			model.addAttribute("email", responseObject.get("email"));
			model.addAttribute("loginType", "naver");
			model.addAttribute("status", "Success");
		} catch (Exception e) {
			throw new RuntimeException(e);
		}
		
		return "login/callback";
	}
	
	@GetMapping("/googleLogin")
	public String googleLogin(HttpServletRequest request, Model model) {
		
		try {
			Map<String, String> result = googleLoginBO.getUserProfile(request.getParameter("code"));
			
			model.addAttribute("name", result.get("name"));
			model.addAttribute("username", result.get("sub"));
			model.addAttribute("email", result.get("email"));
			model.addAttribute("loginType", "google");
			model.addAttribute("status", "Success");
		} catch (Exception e) {
			throw new RuntimeException(e);
		}
		
		return "login/callback";
	}
	
}