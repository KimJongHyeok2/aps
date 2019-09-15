package com.kjh.aps.exception;

public class CustomLoginException extends RuntimeException {

	private static final long serialVersionUID = 1L;
	
	public CustomLoginException() {
		super("CustomLoginException Occurs");
	}
	
	public CustomLoginException(String Msg) {
		super(Msg);
	}
	
	public CustomLoginException(Exception e) {
		super(e);
	}
	
}