package com.kjh.aps.domain;

import java.util.Random;

public class EmailAccessDTO {
	
	private int id; // 고유번호
	private String accesskey; // 인증키
	private int size = 15; // 인증키 사이즈
	private boolean lowerCheck = false; // 대문자 사용여부
	
	public EmailAccessDTO() { initKey(); }

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public String getAccesskey() {
		return accesskey;
	}

	public void setAccesskey(String accesskey) {
		this.accesskey = accesskey;
	}
	
	// 이메일 인증키 생성
	private void initKey() {
		Random ran = new Random();
		StringBuffer sb = new StringBuffer();
		int num = 0;

		do {
			num = ran.nextInt(75) + 48;
			if ((num >= 48 && num <= 57) || (num >= 65 && num <= 90) || (num >= 97 && num <= 122)) {
				sb.append((char) num);
			} else {
				continue;
			}

		} while (sb.length() < size);
		if(lowerCheck) {
			this.accesskey = sb.toString().toLowerCase();
		}
		this.accesskey = sb.toString(); 
	}
	
}
