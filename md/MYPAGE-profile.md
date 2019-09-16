## Demo
<img src="https://user-images.githubusercontent.com/47962660/64925650-ded35d80-d82e-11e9-8add-2906a0831196.gif"/>

## ServletContext
```xml
<util:properties id="s3Properties" location="classpath:s3.properties"/>

<beans:bean name="multipartResolver" class="org.springframework.web.multipart.commons.CommonsMultipartResolver">
  <beans:property name="maxUploadSize" value="3145728"/>
  <beans:property name="maxInMemorySize" value="10000000"/>
</beans:bean>
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/webapp/WEB-INF/spring/appServlet/servlet-context.xml">ServletContext.xml</a>
</pre>
## MyPage(Client)
```javascript
function modifyNickname(nickname) {
  var nickname = nickname.val();
  var pattern_spc = /^[0-9|a-z|A-Z|ㄱ-ㅎ|ㅏ-ㅣ|가-힝]*$/;
  var pattern_con = /^.*[ㄱ-ㅎㅏ-ㅣ]+.*$/;
  
  if(nickname == null || nickname.length < 2 || nickname.length > 6) {
    modalToggle("#modal-type-1", "안내", "닉네임은 2자 이상 6자 이하로 입력해주세요.");
    return false;
  } else {
    if(!new RegExp(pattern_spc).test(nickname)) {
      modalToggle("#modal-type-1", "안내", "닉네임에 특수문자는 포함할 수 없습니다.");	
      return false;
    } else if(new RegExp(pattern_con).test(nickname)) {
      modalToggle("#modal-type-1", "안내", "닉네임을 자음 또는 모음으로 설정할 수 없습니다.");	
      return false;
    } else {
      $.ajax({
        url: "${pageContext.request.contextPath}/mypage/modify/nickname",
        type: "POST",
        cache: false,
        data: {
          "nickname" : nickname
        },
        beforeSend: function(xhr) {
          xhr.setRequestHeader(header, token);
        },
        success: function(data, status) {
          if(status == "success") {
            if(data == "Success") {
              modalToggle("#modal-type-1", "안내", "수정되었습니다.");
              $("#modal-type-1 .aps-modal-header .close-button").attr("onclick", "location.reload();");
              $("#modal-type-1 .aps-modal-footer .aps-modal-button").attr("onclick", "location.reload();");
            } else if(data == "Ban") {
              modalToggle("#modal-type-1", "안내", "금지된 단어가 포함되어있습니다.");						
            } else {
              modalToggle("#modal-type-4", "오류", "알 수 없는 오류입니다.");
            }
          }
        },
        error: function() {
          modalToggle("#modal-type-4", "오류", "알 수 없는 오류입니다.");
        }
      });
    }
  }
}
function modifyProfileImage(obj) {
  var fileName = obj.files[0].name;
  var fileSize = obj.files[0].size;
  var maxPostSize = 3 * 1024 * 1024;
  var ext = fileName.substr(fileName.lastIndexOf(".")+1 , fileName.length);
	
  if(fileSize > maxPostSize) {
    modalToggle("#modal-type-1", "안내", "3MB 이하의 이미지 파일만 등록 가능합니다.");
    return false;
  } else if(!($.inArray(ext.toLowerCase(), ["jpg", "jpeg", "jpe", "png", "gif"]) >= 0)) {
    modalToggle("#modal-type-1", "안내", "허용되지 않은 파일 확장자입니다.");
    return false;
  }
	
  var formData = new FormData();
  formData.append("file", obj.files[0]);
	
  $.ajax({
    url: "${pageContext.request.contextPath}/mypage/modify/profileImage",
    type: "POST",
    cache: false,
    processData: false,
    contentType: false,
    data: formData,
    beforeSend: function(xhr) {
      xhr.setRequestHeader(header, token);
    },
    success: function(data, status) {
      if(status == "success") {
        if(data == "Success") {
          modalToggle("#modal-type-1", "안내", "수정되었습니다.");
          $("#modal-type-1 .aps-modal-header .close-button").attr("onclick", "location.reload();");
          $("#modal-type-1 .aps-modal-footer .aps-modal-button").attr("onclick", "location.reload();");
        } else {
          modalToggle("#modal-type-4", "오류", "알 수 없는 오류입니다.");					
        }
      }
    },
    error: function() {
      modalToggle("#modal-type-4", "오류", "알 수 없는 오류입니다.");
    }
  });
}
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/webapp/WEB-INF/views/mypage/mypage.jsp">mypage.jsp</a>
</pre>
## MyPageController
```java
@Inject
private MyPageService mypageService;
	
@Resource(name="s3Properties")
private Properties s3Properties;

// 회원 닉네임 수정
@PostMapping("/modify/nickname")
public @ResponseBody String modifyNickname(String nickname, HttpServletRequest request) {
		
  String result = "Fail";
  int id = request.getSession().getAttribute("id")==null? 0:(int)request.getSession().getAttribute("id");
		
  // 파라미터 유효성 검사
  if(nickname != null && nickname.length() != 0 && nickname.length() <= 6) {
  Map<String, String> map = new HashMap<String, String>();
  map.put("id", String.valueOf(id));
  map.put("nickname", nickname);

  try {
      result = mypageService.updateUserNickname(map);
				
      if(result.equals("Success")) {
        request.getSession().setAttribute("nickname", nickname);
      }
    } catch (Exception e) {
      throw new ResponseBodyException(e);
    }
  }
		
  return result;
}
	
// 회원 프로필 사진 수정 및 업로드
@PostMapping("/modify/profileImage")
public @ResponseBody String modifyProfileImage(MultipartHttpServletRequest multi) {
		
  Iterator<String> names = multi.getFileNames();
  String name = names.next();
  MultipartFile file = multi.getFile(name);
  String result = "Fail";

  final AmazonS3 s3 = AmazonS3ClientBuilder.standard()
    .withEndpointConfiguration(new AwsClientBuilder.EndpointConfiguration(s3Properties.getProperty("s3.endPoint"), s3Properties.getProperty("s3.region")))
    .withCredentials(new AWSStaticCredentialsProvider(new BasicAWSCredentials(s3Properties.getProperty("s3.accessKey"), s3Properties.getProperty("s3.secretKey")))).build();
		
  String bucketName = "aps";
  String folderName = "profile";
		
  ObjectMetadata objectMetadata = new ObjectMetadata();
  objectMetadata.setContentLength(0L);
  objectMetadata.setContentType("application/x-directory");
  PutObjectRequest putObjectRequest = new PutObjectRequest(bucketName, folderName + "/", new ByteArrayInputStream(new byte[0]), objectMetadata);

  // 폴더 생성
  try {
    s3.putObject(putObjectRequest);
  } catch (AmazonS3Exception e) {
    throw new ResponseBodyException(e);
  } catch(SdkClientException e) {
    throw new ResponseBodyException(e);
  }
		
  UUID uuid = UUID.randomUUID(); // 이미지 파일 중복 방지
  String objectName = uuid.toString() + "_" + file.getOriginalFilename();
  objectMetadata.setContentLength(file.getSize());
  objectMetadata.setContentType(file.getContentType());
		
  // Object 업로드
  try {
    s3.putObject(bucketName + "/" + folderName, objectName, file.getInputStream(), objectMetadata);
  } catch (Exception e) {
    throw new ResponseBodyException(e);
  }
		
  // Object 권한 설정
  try {
    AccessControlList accessControlList = s3.getObjectAcl(bucketName + "/" + folderName, objectName);
    accessControlList.grantPermission(GroupGrantee.AllUsers, Permission.Read);
    s3.setObjectAcl(bucketName + "/" + folderName, objectName, accessControlList);
  } catch (AmazonS3Exception e) {
    throw new ResponseBodyException(e);
  }
			
  Map<String, String> map = new HashMap<>();
  int id = multi.getSession().getAttribute("id")==null? 0:(int)multi.getSession().getAttribute("id");
  map.put("id", String.valueOf(id));
  map.put("profile", objectName);
		
  try {
    result = mypageService.updateUserProfileImage(map);
  } catch (Exception e) {
    throw new ResponseBodyException(e);
  }
    
  // 기존의 Object 버킷에서 삭제
  String prevProfile = (String)multi.getSession().getAttribute("profile");
  if(prevProfile != null && prevProfile.length() != 0) {
    try {
      s3.deleteObject(bucketName + "/" + folderName, prevProfile);
    } catch (AmazonS3Exception e) {
      throw new ResponseBodyException(e);
    }
  }
		
  multi.getSession().setAttribute("profile", map.get("profile"));
		
  return result;
}
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/controller/MyPageController.java">MyPageController.java</a>
</pre>
## MyPageServiceImpl
```java
@Inject
private MyPageDAO dao;

@Override
public String updateUserNickname(Map<String, String> map) throws Exception { // 회원 닉네임 수정
		
  String result = "Fail";
  String patternSpc = "^[0-9|a-z|A-Z|ㄱ-ㅎ|ㅏ-ㅣ|가-힝]{2,6}$"; // 닉네임 정규표현식1
  String patternCon = "^.*[ㄱ-ㅎㅏ-ㅣ]+.*$"; // 닉네임 정규표현식2
  String[] banNicknames = {"에피스", "APS"}; 
  String nickname = map.get("nickname");

  int successCount = 0;
		
  if((Pattern.matches(patternSpc, nickname)) && (!Pattern.matches(patternCon, nickname))) { // 닉네임 정규식 검사
    boolean isBanNickname = false;
    for(int i=0; i&lt;banNicknames.length; i++) { // 금지된 닉네임인지 검사
    if(banNicknames[i].equalsIgnoreCase(nickname)) {
      isBanNickname = true;
    }
  }
    if(isBanNickname) {
      result = "Ban";
    } else {
      successCount = dao.updateUserNickname(map);
    }
  }
		
  if(successCount == 1) {
    result = "Success";
  }
		
  return result;
}

@Override
public String updateUserProfileImage(Map<String, String> map) throws Exception { // 회원 프로필 사진 수정
		
  String result = "Fail";
	
  int successCount = dao.updateUserProfileImage(map);
		
  if(successCount == 1) {
    result = "Success";
  }
		
  return result;
}
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/service/MyPageServiceImpl.java">MyPageServiceImpl.java</a>
</pre>
## MyPageMapper
```xml
<mapper namespace="mypage">
  <update id="updateUserNickname">
    UPDATE user SET nickname = #{nickname} WHERE id = #{id}
  </update>
  <update id="updateUserProfileImage">
    UPDATE user SET profile = #{profile} WHERE id = #{id}
  </update>
</mapper>
```
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/mapper/MyPageDAO.xml">MyPageDAO.xml</a>
</pre>
