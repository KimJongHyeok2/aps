package com.kjh.aps.domain;

import java.util.List;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CommentReplysDTO {

	private List<CommentReplyDTO> commentReplys; // 답글 목록
	private int count; // 불러온 답글 수
	private String status; // 상태
	
	private int replyCount; // 답글 수
	
	public CommentReplysDTO() { }
	
}