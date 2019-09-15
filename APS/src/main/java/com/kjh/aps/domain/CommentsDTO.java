package com.kjh.aps.domain;

import java.util.List;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CommentsDTO {

	private List<CommentDTO> comments; // 댓글 목록
	private int count; // 불러온 댓글 수
	private String status; // 상태
	
	private PaginationDTO pagination; // 댓글 페이징
	
	private int reviewCount; // 민심평가 수
	
	public CommentsDTO() { }
	
}