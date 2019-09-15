package com.kjh.aps.validator;

import org.springframework.validation.Errors;
import org.springframework.validation.ValidationUtils;
import org.springframework.validation.Validator;

import com.kjh.aps.domain.SocialLoginDTO;

public class SocialLoginValidator implements Validator {

	@Override
	public boolean supports(Class<?> clazz) {
		return SocialLoginDTO.class.isAssignableFrom(clazz);
	}

	@Override
	public void validate(Object target, Errors errors) {
		ValidationUtils.rejectIfEmptyOrWhitespace(errors, "name", "emptySocialUserName");
		ValidationUtils.rejectIfEmptyOrWhitespace(errors, "username", "emptySocialUserId");
		ValidationUtils.rejectIfEmptyOrWhitespace(errors, "email", "emptySocialUserEmail");
		ValidationUtils.rejectIfEmptyOrWhitespace(errors, "loginType", "emptySocialLoginType");
	}

}