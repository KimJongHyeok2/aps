package com.kjh.aps.domain;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ReviewGradePointDTO {

	private double gp_avg; // 평점 평균
	private String gp_date; // 평점 등록일 그룹
	
	private double gp_avg_today; // 일일 평점 평균
	private double gp_avg_week; // 주간 평점 평균
	private double gp_avg_month; // 월간 평점 평균
	
	public ReviewGradePointDTO() { }
	
}