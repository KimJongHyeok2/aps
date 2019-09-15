package com.kjh.aps.domain;

import java.util.List;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class BoardWritesDTO {

	private List<BoardDTO> boards;
	private int count; // 불러온 댓글 수
	private String status; // 상태
	
	public BoardWritesDTO() { }

}