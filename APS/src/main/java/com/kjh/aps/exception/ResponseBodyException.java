package com.kjh.aps.exception;

public class ResponseBodyException extends RuntimeException {
	
	private static final long serialVersionUID = 1L;
	
	public ResponseBodyException() {
		super("ResponseBodyException Occurs");
	}
	
	public ResponseBodyException(String Msg) {
		super(Msg);
	}
	
	public ResponseBodyException(Exception e) {
		super(e);
	}

}