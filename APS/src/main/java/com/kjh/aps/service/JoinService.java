package com.kjh.aps.service;

import com.kjh.aps.domain.EmailAccessDTO;
import com.kjh.aps.domain.JoinDTO;
import com.kjh.aps.domain.SocialLoginDTO;

public interface JoinService {
	public int insertEmailAccessKey(EmailAccessDTO dto) throws Exception;
	public String selectEmailAccessKeyById(int id) throws Exception;
	public int selectUsernameCountByUsername(String username) throws Exception;
	public int selectEmailCountByEmail(String email) throws Exception;
	public int insertUser(JoinDTO dto) throws Exception;
	public SocialLoginDTO selectUserBySocialLoginDTO(SocialLoginDTO dto) throws Exception;
}