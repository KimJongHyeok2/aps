package com.kjh.aps.persistent;

import javax.inject.Inject;

import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Repository;

import com.kjh.aps.domain.EmailAccessDTO;
import com.kjh.aps.domain.JoinDTO;
import com.kjh.aps.domain.SocialLoginDTO;

@Repository("JoinDAO")
public class JoinDAOImpl implements JoinDAO {

	@Inject
	private SqlSession sqlSession;
	
	private final String JOIN_DAO_NAMESPACE = "join";
	
	@Override
	public int insertEmailAccessKey(EmailAccessDTO dto) throws Exception {
		return sqlSession.insert(JOIN_DAO_NAMESPACE + ".insertEmailAccessKey", dto);
	}

	@Override
	public String selectEmailAccessKeyById(int id) throws Exception {
		return sqlSession.selectOne(JOIN_DAO_NAMESPACE + ".selectEmailAccessKeyById", id);
	}

	@Override
	public int selectUsernameCountByUsername(String username) throws Exception {
		return sqlSession.selectOne(JOIN_DAO_NAMESPACE + ".selectUsernameCountByUsername", username);
	}

	@Override
	public int selectEmailCountByEmail(String email) throws Exception {
		return sqlSession.selectOne(JOIN_DAO_NAMESPACE + ".selectEmailCountByEmail", email);
	}
	
	@Override
	public int insertUser(JoinDTO dto) throws Exception {
		return sqlSession.insert(JOIN_DAO_NAMESPACE + ".insertUser", dto);
	}

	@Override
	public SocialLoginDTO selectUserBySocialLoginDTO(String email) throws Exception {
		return sqlSession.selectOne(JOIN_DAO_NAMESPACE + ".selectUserBySocialLoginDTO", email);
	}

	@Override
	public int insertSocialUser(SocialLoginDTO dto) throws Exception {
		return sqlSession.insert(JOIN_DAO_NAMESPACE + ".insertSocialUser", dto);
	}

}