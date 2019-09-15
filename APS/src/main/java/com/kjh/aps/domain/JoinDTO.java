package com.kjh.aps.domain;

import com.kjh.aps.util.PasswordEncoding;

public class JoinDTO {

	private String name; // 이름
	private String username; // 아이디
	private String password; // 비밀번호
	private String email; // 이메일
	
	public JoinDTO() { }

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getUsername() {
		return username;
	}

	public void setUsername(String username) {
		this.username = username;
	}

	public String getPassword() {
		return password;
	}

	public void setPassword(String password) {
		PasswordEncoding passwordEncoder = new PasswordEncoding();
		this.password = passwordEncoder.encode(password);
	}

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}
	
}