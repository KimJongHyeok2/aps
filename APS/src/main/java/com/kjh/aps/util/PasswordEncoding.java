package com.kjh.aps.util;

import org.springframework.security.crypto.factory.PasswordEncoderFactories;
import org.springframework.security.crypto.password.PasswordEncoder;

public class PasswordEncoding implements PasswordEncoder {

	private PasswordEncoder passwordEncoder;
	
	public PasswordEncoding() {
		this.passwordEncoder = PasswordEncoderFactories.createDelegatingPasswordEncoder();
	}
	
	@Override
	public String encode(CharSequence arg0) {
		return passwordEncoder.encode(arg0);
	}

	@Override
	public boolean matches(CharSequence arg0, String arg1) {
		return passwordEncoder.matches(arg0, arg1);
	}

}