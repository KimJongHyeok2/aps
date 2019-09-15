package com.kjh.aps.persistent;

import java.util.Map;

import javax.inject.Inject;

import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Repository;

import com.kjh.aps.domain.UserDTO;

@Repository("MyPageDAO")
public class MyPageDAOImpl implements MyPageDAO {

	@Inject
	private SqlSession sqlSession;
	
	private final String MYPAGE_DAO_NAMESPACE = "mypage";
	
	@Override
	public UserDTO selectUserInfoById(int id) throws Exception {
		return sqlSession.selectOne(MYPAGE_DAO_NAMESPACE + ".selectUserInfoById", id);
	}

	@Override
	public int updateUserNickname(Map<String, String> map) throws Exception {
		return sqlSession.update(MYPAGE_DAO_NAMESPACE + ".updateUserNickname", map);
	}

	@Override
	public int updateUserProfileImage(Map<String, String> map) throws Exception {
		return sqlSession.update(MYPAGE_DAO_NAMESPACE + ".updateUserProfileImage", map);
	}

	@Override
	public String selectUserPasswordByMap(Map<String, String> map) throws Exception {
		return sqlSession.selectOne(MYPAGE_DAO_NAMESPACE + ".selectUserPasswordByMap", map);
	}

	@Override
	public int updateUserPassword(Map<String, String> map) throws Exception {
		return sqlSession.update(MYPAGE_DAO_NAMESPACE + ".updateUserPassword", map);
	}

	@Override
	public int updateUserStatus(Map<String, String> map) throws Exception {
		return sqlSession.update(MYPAGE_DAO_NAMESPACE + ".updateUserStatus", map);
	}

}
