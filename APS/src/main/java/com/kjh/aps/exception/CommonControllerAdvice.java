package com.kjh.aps.exception;

import java.text.SimpleDateFormat;
import java.util.Date;

import javax.servlet.http.HttpServletRequest;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.servlet.ModelAndView;

import com.kjh.aps.controller.CommunityController;

@ControllerAdvice
public class CommonControllerAdvice {
	
	private static final Logger logger = LoggerFactory.getLogger(CommunityController.class);

	@ExceptionHandler(Exception.class)
	@ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
	public ModelAndView exception(HttpServletRequest request, Exception e) {
		logger.warn("------------------------------------------------------------------------------------");
		logger.warn("Internal Server Error : 500");
		logger.warn("Request : " + request.getRequestURL() + "?" + request.getQueryString());
		logger.warn("Message : " + e.getMessage());
		logger.warn("Cause : " + e.getCause());
		logger.warn("Agent : " + request.getHeader("User-Agent"));
		logger.warn("IP : " + request.getRemoteAddr());
		logger.warn("Date : " + new SimpleDateFormat("yyyy-MM-dd hh:mm:ss").format(new Date(System.currentTimeMillis())));
		logger.warn("------------------------------------------------------------------------------------");
		
		ModelAndView modelAndView = new ModelAndView();
		modelAndView.addObject("exception", e);
		modelAndView.setViewName("confirm/error_500");
		
		return modelAndView;
	}
	
	@ExceptionHandler(ResponseBodyException.class)
	public void responseBodyException(HttpServletRequest request, ResponseBodyException e) {
		logger.warn("------------------------------------------------------------------------------------");
		logger.warn("Internal Server Error : 500(ResponseBody)");
		logger.warn("Request : " + request.getRequestURL() + "?" + request.getQueryString());
		logger.warn("Method : " + e.getMessage());
		logger.warn("Cause : " + e.getCause());
		logger.warn("AgentT : " + request.getHeader("User-Agent"));
		logger.warn("IP : " + request.getRemoteAddr());
		logger.warn("Date : " + new SimpleDateFormat("yyyy-MM-dd hh:mm:ss").format(new Date(System.currentTimeMillis())));
		logger.warn("------------------------------------------------------------------------------------");
	}
	
}