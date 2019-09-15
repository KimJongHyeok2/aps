package com.kjh.aps.controller;

import java.util.HashMap;
import java.util.Map;

import javax.inject.Inject;
import javax.servlet.http.HttpServletRequest;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.kjh.aps.domain.UserPushsDTO;
import com.kjh.aps.exception.ResponseBodyException;
import com.kjh.aps.service.CommonService;

@Controller
@RequestMapping("/common")
public class CommonController {
	
	@Inject
	private CommonService commonService;
	
	// 알림 목록
	@PostMapping("/push")
	public @ResponseBody UserPushsDTO push(HttpServletRequest request) {
		
		UserPushsDTO userPushs = new UserPushsDTO();
		Integer userId = request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id");
		
		if(userId != 0) {
			try {
				userPushs = commonService.selectUserPushListByUserId(userId);
			} catch (Exception e) {
				e.printStackTrace();
				userPushs.setStatus("Fail");
				throw new ResponseBodyException(e);
			}
		}
		
		return userPushs;
	}
	
	// 알림 읽음 처리
	@PostMapping("/push/read")
	public @ResponseBody String pushRead(@RequestParam(value = "id", defaultValue = "0") int id, HttpServletRequest request) {
		
		String result = "Success";
		Integer userId = request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id");
		
		if(userId != 0 && id != 0) {
			Map<String, Integer> map = new HashMap<>();
			map.put("id", id);
			map.put("user_id", userId);
			try {
				commonService.updateUserPushStatus(map);
			} catch (Exception e) {
				result = "Fail";
				throw new ResponseBodyException(e);
			}
		}
		
		return result;
	}
	
	// 알림 삭제
	@PostMapping("/push/delete")
	public @ResponseBody String pushDelete(@RequestParam(value = "id", defaultValue = "0") int id,
			String deleteType, HttpServletRequest request) {
		
		String result = "Fail";
		Integer userId = request.getSession().getAttribute("id")==null? 0:(Integer)request.getSession().getAttribute("id");
		
		if(userId != 0 && deleteType != null) {
			Map<String, String> map = new HashMap<>();
			map.put("id", String.valueOf(id));
			map.put("user_id", String.valueOf(userId));
			map.put("deleteType", deleteType);
			
			try {
				int successCount = 0;
				successCount = commonService.deleteUserPush(map);
				if(successCount >= 1) {
					result = "Success";
				}
			} catch (Exception e) {
				throw new ResponseBodyException("pushDelete");
			}
		}
		
		return result;
	}
	
}