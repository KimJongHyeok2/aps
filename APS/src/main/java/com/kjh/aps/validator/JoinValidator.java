package com.kjh.aps.validator;

import java.util.regex.Pattern;

import org.springframework.validation.Errors;
import org.springframework.validation.ValidationUtils;
import org.springframework.validation.Validator;

import com.kjh.aps.domain.JoinDTO;

public class JoinValidator implements Validator {

	@Override
	public boolean supports(Class<?> clazz) {
		return JoinDTO.class.isAssignableFrom(clazz);
	}

	@Override
	public void validate(Object target, Errors errors) {
		JoinDTO dto = (JoinDTO)target;
		
		String usernamePattern = "^([a-zA-Z\\d]{5,10})$"; // 아이디 정규표현식
		String namePattern = "^[가-힣]{2,4}$"; // 이름 정규표현식
		String emailPattern = "^(([a-zA-Z\\d][-_]?){3,15})@([a-zA-z\\d]{5,15})\\.([a-z]{2,3})$"; // 이메일 정규표현식 
		
		// 이름 유효성 검사
		ValidationUtils.rejectIfEmptyOrWhitespace(errors, "name", "emptyName");
		// 아이디 유효성 검사
		ValidationUtils.rejectIfEmptyOrWhitespace(errors, "username", "emptyUsername");
		// 비밀번호 유효성 검사
		ValidationUtils.rejectIfEmptyOrWhitespace(errors, "password", "emptyPassword");
		// 이메일 유효성 검사
		ValidationUtils.rejectIfEmptyOrWhitespace(errors, "email", "emptyEmail");
		
		if(dto.getUsername() != null && dto.getPassword() != null && dto.getName() != null && dto.getEmail() != null) {
			// 이름 정규표현식 검사
			if(!Pattern.matches(namePattern, dto.getName())) {
				errors.reject("name", "invalidName");
			}
			// 아이디 정규표현식 검사
			if(!Pattern.matches(usernamePattern, dto.getUsername())) {
				errors.reject("username", "invalidUsername");
			}
			// 이메일 정규표현식 검사
			if(!Pattern.matches(emailPattern, dto.getEmail())) {
				errors.reject("email", "invalidEmail");
			}
		}
	}

}
