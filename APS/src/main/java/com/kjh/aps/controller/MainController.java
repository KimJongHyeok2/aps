package com.kjh.aps.controller;

import java.text.SimpleDateFormat;
import java.util.Date;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class MainController {

	private static final Logger logger = LoggerFactory.getLogger(MainController.class);
	
	@GetMapping("/")
	public String main() {
		return "redirect:/community";
	}
	
	@GetMapping("/robots.txt")
	public String robots() {
		return "robots";
	}
	
	// 이용약관 페이지
	@GetMapping("/policy/policy")
	public String policy(Model model) {
		model.addAttribute("type", "policy");
		return "policy/policy";
	}
	
	// 개인정보처리방침 페이지
	@GetMapping("/policy/privacy")
	public String privacy(Model model) {
		model.addAttribute("type", "privacy");
		return "policy/policy";
	}
	
	// 민심순위
	@GetMapping("/rank")
	public String rank(Model model) {
		return "rank/rank";
	}
	
	// 400 Error
	@RequestMapping("/error_400")
	public String error_400(HttpServletRequest request) {
		logger.warn("------------------------------------------------------------------------------------");
		logger.warn("Bad Request : 400");
		logger.warn("Agent : " + request.getHeader("User-Agent"));
		logger.warn("IP : " + request.getRemoteAddr());
		logger.warn("Date : " + new SimpleDateFormat("yyyy-MM-dd hh:mm:ss").format(new Date(System.currentTimeMillis())));
		logger.warn("------------------------------------------------------------------------------------");
		return "confirm/error_400";
	}
	
	// 404 Error
	@RequestMapping("/error_404")
	public String error_404(HttpServletRequest request) {
		logger.warn("------------------------------------------------------------------------------------");
		logger.warn("Page Not Found : 404");
		logger.warn("Agent : " + request.getHeader("User-Agent"));
		logger.warn("IP : " + request.getRemoteAddr());
		logger.warn("Date : " + new SimpleDateFormat("yyyy-MM-dd hh:mm:ss").format(new Date(System.currentTimeMillis())));
		logger.warn("------------------------------------------------------------------------------------");
		return "confirm/error_404";
	}
	
	// 405 Error
	@RequestMapping("/error_405")
	public String error_405(HttpServletRequest request) {
		logger.warn("------------------------------------------------------------------------------------");
		logger.warn("Method Not allowed : 405");
		logger.warn("Agent : " + request.getHeader("User-Agent"));
		logger.warn("IP : " + request.getRemoteAddr());
		logger.warn("Date : " + new SimpleDateFormat("yyyy-MM-dd hh:mm:ss").format(new Date(System.currentTimeMillis())));
		logger.warn("------------------------------------------------------------------------------------");
		return "confirm/error_405";
	}
	
	// 500 Error
	@RequestMapping("/error_500")
	public String error_500(HttpServletRequest request, HttpServletResponse response, Exception e) {
		logger.warn("------------------------------------------------------------------------------------");
		logger.warn("Internal Server Error : 500");
		logger.warn("Message : " + e.getMessage());
		logger.warn("Cause : " + e.getCause());
		logger.warn("Agent : " + request.getHeader("User-Agent"));
		logger.warn("IP : " + request.getRemoteAddr());
		logger.warn("Date : " + new SimpleDateFormat("yyyy-MM-dd hh:mm:ss").format(new Date(System.currentTimeMillis())));
		logger.warn("------------------------------------------------------------------------------------");
		return "confirm/error_500";
	}
	
	// 권한이 없는 경우
	@RequestMapping("/access_denied")
	public String access_denied(HttpServletRequest request) {
		logger.warn("------------------------------------------------------------------------------------");
		logger.warn("Forbidden : 403");
		logger.warn("Agent : " + request.getHeader("User-Agent"));
		logger.warn("IP : " + request.getRemoteAddr());
		logger.warn("Date : " + new SimpleDateFormat("yyyy-MM-dd hh:mm:ss").format(new Date(System.currentTimeMillis())));
		logger.warn("------------------------------------------------------------------------------------");
		return "confirm/access_denied";
	}
	
	// 중복 로그인 발생 시
	@RequestMapping("/expired_login")
	public String expired_login() {
		return "confirm/expired_login";
	}
	
}