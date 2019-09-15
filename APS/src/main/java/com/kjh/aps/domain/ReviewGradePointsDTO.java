package com.kjh.aps.domain;

import java.util.List;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ReviewGradePointsDTO {

	private List<ReviewGradePointDTO> gradePointAverages; // 평점 목록
	private int count; // 불러온 알림 수
	private String status; // 상태
	
	public ReviewGradePointsDTO() { }

}