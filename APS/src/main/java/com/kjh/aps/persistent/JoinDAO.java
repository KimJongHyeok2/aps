package com.kjh.aps.persistent;

import com.kjh.aps.domain.EmailAccessDTO;
import com.kjh.aps.domain.JoinDTO;
import com.kjh.aps.domain.SocialLoginDTO;

public interface JoinDAO {
	public int insertEmailAccessKey(EmailAccessDTO dto) throws Exception;
	public String selectEmailAccessKeyById(int id) throws Exception;
	public int selectUsernameCountByUsername(String username) throws Exception;
	public int selectEmailCountByEmail(String email) throws Exception;
	public int insertUser(JoinDTO dto) throws Exception;
	public SocialLoginDTO selectUserBySocialLoginDTO(String email) throws Exception;
	public int insertSocialUser(SocialLoginDTO dto) throws Exception;
}