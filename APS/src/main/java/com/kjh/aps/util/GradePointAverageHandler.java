package com.kjh.aps.util;

import java.util.ArrayList;
import java.util.List;

import javax.inject.Inject;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import com.kjh.aps.domain.ReviewGradePointDTO;
import com.kjh.aps.service.CommunityService;

public class GradePointAverageHandler extends TextWebSocketHandler {
	
	@Inject
	private CommunityService communityService;
	
	private static Logger logger = LoggerFactory.getLogger(GradePointAverageHandler.class);
	
	public static List<WebSocketSession> sessionList = new ArrayList<WebSocketSession>();
	
	@Override
	public void afterConnectionEstablished(WebSocketSession session) throws Exception {
		sessionList.add(session);
		logger.info("GradePointAverage : {} - {} 연결됨", session.getId(), session.getRemoteAddress());
		super.afterConnectionEstablished(session);
	}
	
	@Override
	protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
		
		String[] values = message.getPayload().split(",");
		String type = values[0];
		String broadcasterId = values[1];
		
		ReviewGradePointDTO reviewGradePoint = communityService.selectBroadcasterReviewGradePointAverageByMap(broadcasterId);
		
		if(type.equals("open")) {
			if(reviewGradePoint == null) {
				session.sendMessage(new TextMessage("0,0,0," + broadcasterId));
			} else {				
				session.sendMessage(new TextMessage(reviewGradePoint.getGp_avg_today() + "," + reviewGradePoint.getGp_avg_week() + "," + reviewGradePoint.getGp_avg_month() + "," + broadcasterId));
			}
		} else if(type.equals("write")) {
			for(WebSocketSession sessions : sessionList) {
				if(reviewGradePoint == null) {
					sessions.sendMessage(new TextMessage("0,0,0," + broadcasterId));
				} else {					
					sessions.sendMessage(new TextMessage(reviewGradePoint.getGp_avg_today() + "," + reviewGradePoint.getGp_avg_week() + "," + reviewGradePoint.getGp_avg_month() + "," + broadcasterId));
				}
			}
		}
		
		/*logger.info("GradePointAverage : {}로 부터 {} 받음", session.getId(), message.getPayload());*/
		
		super.handleTextMessage(session, message);
	}
	
	@Override
	public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
		sessionList.remove(session);
		super.afterConnectionClosed(session, status);
	}
	
}