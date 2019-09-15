package com.kjh.aps.domain;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class PaginationDTO {

	private int pageBlock; // 페이징 블럭 수
	private int listCount; // 리스트
	private int pageCount; // 총 페이지
	private int startPage; // 시작 페이지
	private int endPage; // 마지막 페이지
	private int page; // 현재 페이지
	private int row; // 출력할 게시글 수
	
	public PaginationDTO() { }

	public PaginationDTO(int pageBlock, int listCount, int page, int row) {
		this.pageBlock = pageBlock;
		this.listCount = listCount;
		this.pageCount = listCount/row + (listCount%row==0? 0:1);
		this.startPage = ((page-1)/pageBlock) * pageBlock + 1;
		this.endPage = this.startPage + pageBlock - 1;
		if(this.endPage > this.pageCount) { // 총 페이지 수보다 마지막 페이지가 더 크다면
			this.endPage = this.pageCount;
		}
		this.page = page;
		this.row = row;
	}
	
}