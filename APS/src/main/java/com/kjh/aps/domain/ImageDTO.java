package com.kjh.aps.domain;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ImageDTO {

	private boolean uploaded = false;
	private String url;
	private String name;
	
	public ImageDTO() { }
	
}