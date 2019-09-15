package com.kjh.aps.intercepter;

import java.util.HashMap;
import java.util.Map;

import javax.inject.Inject;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.handler.HandlerInterceptorAdapter;

import com.kjh.aps.service.CommonService;

public class RecommendInterceptor extends HandlerInterceptorAdapter {
	
	@Inject
	private CommonService commonService;
	
	@Override
	public void postHandle(HttpServletRequest request, HttpServletResponse response, Object handler,
			ModelAndView modelAndView) throws Exception {
		String type = (String)request.getAttribute("type");
		int id = 0;
		
		Map<String, String> map = new HashMap<>();
		
		if(type != null) {
			if(type.equals("board")) {
				id = request.getAttribute("board_id")==null? 0:(Integer)request.getAttribute("board_id");
			} else if(type.equals("boardComment")) {
				id = request.getAttribute("board_comment_id")==null? 0:(Integer)request.getAttribute("board_comment_id");
			} else if(type.equals("reviewComment")) {
				id = request.getAttribute("review_id")==null? 0:(Integer)request.getAttribute("review_id");						
			} else if(type.equals("noticeComment")) {
				id = request.getAttribute("notice_comment_id")==null? 0:(Integer)request.getAttribute("notice_comment_id");
			} else if(type.equals("combineBoard")) {
				id = request.getAttribute("combine_board_id")==null? 0:(Integer)request.getAttribute("combine_board_id");
			} else if(type.equals("combineBoardComment")) {
				id = request.getAttribute("combine_board_comment_id")==null? 0:(Integer)request.getAttribute("combine_board_comment_id");
			}

			map.put("type", type);
			map.put("id", String.valueOf(id));
			
			commonService.updateUserLevel(map); // 받은 추천 수 종합에 따른 레벨 수정
		}
		
		super.postHandle(request, response, handler, modelAndView);
	}

}