package com.kjh.aps.intercepter;

import java.text.SimpleDateFormat;
import java.util.Date;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.handler.HandlerInterceptorAdapter;

public class WriteInterceptor extends HandlerInterceptorAdapter {

	private SimpleDateFormat sdf = new SimpleDateFormat("YYYYMMddHHmm");
	
	@Override
	public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler)
			throws Exception {
		
		if(request.getSession().getAttribute("prevention") != null) { // 도배방지 세션 값이 존재한다면
			long preventionDateTime = (long)request.getSession().getAttribute("prevention");
			Date currDate = new Date();
			currDate = sdf.parse(sdf.format(currDate));
			long currDateTime = currDate.getTime(); // 현재 시간
			
			int minute = (int)((currDateTime - preventionDateTime) / 60000);
			
			if(minute >= 15) { // 15분 제한시간이 만료되었다면 세션 값 제거
				request.getSession().removeAttribute("prevention");
				request.getSession().removeAttribute("writeCount");
				request.getSession().removeAttribute("writeLastDate");
			}
		}
		
		return super.preHandle(request, response, handler);
	}
	
	@Override
	public void postHandle(HttpServletRequest request, HttpServletResponse response, Object handler,
			ModelAndView modelAndView) throws Exception {
		
		if(request.getSession().getAttribute("prevention") == null) { // 이미 도배방지 세션 값이 존재하는지
			if(request.getSession().getAttribute("writeCount") == null && request.getSession().getAttribute("writeLastDate") == null) { // 게시글을 등록한 적이 없거나 제한시간이 만료되었다면
				Date writeLastDate = new Date();
				writeLastDate = sdf.parse(sdf.format(writeLastDate));
				long writeLastDateTime = writeLastDate.getTime();
				request.getSession().setAttribute("writeCount", 1); // 카운트
				request.getSession().setAttribute("writeLastDate", writeLastDateTime); // 게시글 등록일시
			} else { // 게시글을 등록했었다면
				long writeLastDateTime = (long)request.getSession().getAttribute("writeLastDate"); // 가장 최근 등록한 게시글 등록일시 
				Date currDate = new Date();
				currDate = sdf.parse(sdf.format(currDate));
				long currDateTime = currDate.getTime(); // 현재 시간
				
				int minute = (int)((currDateTime - writeLastDateTime) / 60000); // 현재시간과 마지막 게시글 등록일시 시간(분)
				
				if(minute <= 5) { // 5분 이내에 등록했다면
					int writeCount = (int)request.getSession().getAttribute("writeCount"); // 5분 이내에 등록한 게시글 카운트
					if(writeCount >= 5) { // 5분 이내에 등록한 게시글이 5개 이상이라면 도배방지 세션 값 생성
						request.getSession().setAttribute("prevention", currDateTime);
						request.getSession().removeAttribute("writeCount");
						request.getSession().removeAttribute("writeDate");
					} else { // 카운트 증가
						writeCount += 1;
						request.getSession().setAttribute("writeCount", writeCount);
						request.getSession().setAttribute("writeLastDate", currDateTime);
					}
				} else { // 5분이 지나서 등록했다면 이전에 카운트 및 등록일시 세션 값 제거
					request.getSession().removeAttribute("writeCount");
					request.getSession().removeAttribute("writeLastDate");
				}
			}
		}
		
		super.postHandle(request, response, handler, modelAndView);
	}
	
}
