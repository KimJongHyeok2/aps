package com.kjh.aps.util;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

public class BoardWritePushHandler extends TextWebSocketHandler {
	
	private static Logger logger = LoggerFactory.getLogger(BoardWritePushHandler.class);
	
	public static List<WebSocketSession> sessionList = new ArrayList<WebSocketSession>();
	public static Map<String, Map<String, String>> sessionCount = new HashMap<>();
	
	@Override
	public void afterConnectionEstablished(WebSocketSession session) throws Exception {
		sessionList.add(session);
		logger.info("BoardWritePush : {} - {} 연결됨", session.getId(), session.getRemoteAddress());
		super.afterConnectionEstablished(session);
	}

	@Override
	protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
		/*logger.info("BoardWritePush : {}로 부터 {} 받음", session.getId(), message.getPayload());*/
		Map<String, String> userMap = new HashMap<>();
		userMap.put(session.getId(), session.getId());
		if(sessionCount.get(message.getPayload()) == null) {
			sessionCount.put(message.getPayload(), userMap);
		} else {
			Map<String, String> sessionUserMap = sessionCount.get(message.getPayload());
			sessionUserMap.put(session.getId(), session.getId());
			sessionCount.put(message.getPayload(), sessionUserMap);
		}
		for(WebSocketSession sess : sessionList) {
			sess.sendMessage(new TextMessage(message.getPayload() + "," + sessionCount.get(message.getPayload()).size()));
		}
		super.handleTextMessage(session, message);
	}
	
	@Override
	public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
		sessionList.remove(session);
		Set<String> keys = sessionCount.keySet();
		for(String key : keys) {
			Map<String, String> userMap = sessionCount.get(key);
			userMap.remove(session.getId());
		}
		super.afterConnectionClosed(session, status);
	}
	
}