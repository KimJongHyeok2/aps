## Demo
<img src="https://user-images.githubusercontent.com/47962660/64926988-8062ab00-d83f-11e9-8660-9328352e6f4b.gif"/>

## ServletContext
<pre>
&lt;util:properties id="s3Properties" location="classpath:s3.properties"/&gt;

&lt;beans:bean name="multipartResolver" class="org.springframework.web.multipart.commons.CommonsMultipartResolver"&gt;
  &lt;beans:property name="maxUploadSize" value="3145728"/&gt;
  &lt;beans:property name="maxInMemorySize" value="10000000"/&gt;
&lt;/beans:bean&gt;
</pre>
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/webapp/WEB-INF/spring/appServlet/servlet-context.xml">ServletContext.xml</a>
</pre>
## BoardWrite(Client)
<pre>
function validWrite(obj) {
  var subject = obj["subject"].value;
  var content = myEditor.getData();
  
  if(subject == null || subject.length == 0) {
    modalToggle("#modal-type-1", "안내", "제목을 입력해주세요.");
    return false;
  }
  if(subject.length &lt; 40) {
    modalToggle("#modal-type-1", "안내", "제목은 40자 이하로 입력해주세요.");
    return false;
  }
  if(content.length == 0) {
    modalToggle("#modal-type-1", "안내", "내용을 입력해주세요.");
    return false;		
  } else {
    if(content.length &lt; 30000) {
      modalToggle("#modal-type-1", "안내", "내용은 30,000자 이하로 입력해주세요.");
      return false;
    } else {
      if(content.indexOf('&lt;figure class="image"&gt;') != -1) {
        $("#image_flag").val(1);
      } else {
        $("#image_flag").val(0);
      }
      if(content.indexOf('&lt;figure class="media"&gt;') != -1) {
        $("#media_flag").val(1);
      } else {
        $("#media_flag").val(0);
      }	
    }
  }
}

&lt;form action="writeOk" method="post" onsubmit="return validWrite(this);"&gt;
  &lt;div class="write-content"&gt;
    &lt;div class="input-box"&gt;
      &lt;input type="text" id="subject" name="subject" maxlength="40" value="${dto.subject}" placeholder="제목을 입력해주세요."/&gt;
    &lt;/div&gt;
    &lt;div class="input-box"&gt;
      &lt;textarea id="content" name="content">${dto.content}&lt;/textarea&gt;
    &lt;/div&gt;
    &lt;input type="hidden" id="image_flag" name="image_flag" value="0"/&gt;
    &lt;input type="hidden" id="media_flag" name="media_flag" value="0"/&gt;
    &lt;input type="hidden" id="user_id" name="user_id" value="${empty sessionScope.id? 0:sessionScope.id}"/&gt;
    &lt;input type="hidden" id="broadcaster_id" name="broadcaster_id" value="${broadcaster.id}"/&gt;
    &lt;input type="hidden" id="page" name="page" value="${param.page}"/&gt;
    &lt;s:csrfInput/&gt;
  &lt;/div&gt;
  &lt;div class="input-info"&gt;
    &lt;ul&gt;
      &lt;li>5MB 이하의(PNG, JPG, JPEG, GIT) 이미지 파일만  업로드 가능합니다.&lt;/li&gt;
    &lt;/ul&gt;
  &lt;/div&gt;
  &lt;div class="function"&gt;
    &lt;button type="button" class="aps-button" onclick="history.back();"&gt;이전&lt;/button&gt;
    &lt;button type="submit" class="aps-button"&gt;완료&lt;/button&gt;
  &lt;/div&gt;
&lt;/form&gt;
</pre>
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/webapp/WEB-INF/views/community/board/board_write.jsp">board_write.jsp</a>
</pre>
## CommunityController
<pre>
@Inject
private CommunityService communityService;
private final int BOARD_PAGEBLOCK = 5;
private final int BOARD_POPULAR_ORDER = 20;
private final int COMMENT_PAGEBLOCK = 5;
private final int COMMENT_POPULAR_ORDER = 20;

@Resource(name="s3Properties")
private Properties s3Properties;

// 방송인 커뮤니티 게시판 글 작성
@PostMapping("/board/writeOk")
public String boardWriteOk(BoardDTO dto, BindingResult result,
    @RequestParam(value = "page", defaultValue = "1") int page,
  HttpServletRequest request, Model model) {
		
  BoardValidator validation = new BoardValidator();
  validation.setRequest(request);
  String error = "insertFail";
		
  Map<String, Object> map = null;
		
  // 파라미터 유효성 검사
  if(validation.supports(dto.getClass())) {
    validation.validate(dto, result);

    if(request.getSession().getAttribute("prevention") != null) { // 도배방지 세션 값이 존재하다면
      dto.setPrevention(true);
      error = "prevention";
    }

    // 오류가 존재하지 않다면
    if(!result.hasErrors()) {
      dto.setIp(request.getRemoteAddr());

      try {
        map = communityService.insertBoardWrite(dto); // 글 추가

        String resultMsg = (String)map.get("result");

        if(resultMsg.equals("Success")) { // 정상적으로 추가되었다면
          for(WebSocketSession session : BoardWritePushHandler.sessionList) { // 새 글 알림
            if(!session.getRemoteAddress().getHostName().equals(request.getRemoteAddr())) { // 작성자 본인 제외
              session.sendMessage(new TextMessage(dto.getBroadcaster_id() + "," + dto.getId() + "," + dto.getSubject()));
            }
          }
            model.addAttribute("resultMsg", resultMsg);
            return "redirect:/community/board/view/" + dto.getId() + "?broadcasterId=" + dto.getBroadcaster_id() + "&page=" + page + "";
          }
        } catch (Exception e) {
          throw new RuntimeException(e);
        }
    }
  }
		
  BroadcasterDTO broadcaster = (BroadcasterDTO)map.get("broadcaster");
		
  if(broadcaster == null) { // 잘못된 방송인 아이디 값이 넘어왔다면
    return "confirm/not_exist";
  } else {
    model.addAttribute("broadcaster", broadcaster);
  }

  model.addAttribute("error", error);
		
  return "community/board/board_write";
}

// 방송인 커뮤니티 게시판 글 이미지 업로드
@PostMapping("/board/write/imageUpload")
public @ResponseBody ImageDTO boardWriteImageUpload(MultipartHttpServletRequest multi) {
		
  Iterator<String> names = multi.getFileNames();
  String name = names.next();
  MultipartFile file = multi.getFile(name);
		
  final AmazonS3 s3 = AmazonS3ClientBuilder.standard()
    .withEndpointConfiguration(new AwsClientBuilder.EndpointConfiguration(s3Properties.getProperty("s3.endPoint"), s3Properties.getProperty("s3.region")))
    .withCredentials(new AWSStaticCredentialsProvider(new BasicAWSCredentials(s3Properties.getProperty("s3.accessKey"), s3Properties.getProperty("s3.secretKey")))).build();
		
    String bucketName = "aps";
    String folderName = "board";
		
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
		
    ImageDTO image = new ImageDTO();
		
    image.setUploaded(true);
    image.setUrl(s3Properties.getProperty("s3.endPoint") + "/" + bucketName + "/" + folderName + "/" + objectName);
    image.setName(objectName);
		
    logger.info("BoardWrite : {} - {} 이미지 업로드", multi.getSession().getAttribute("id"), multi.getSession().getAttribute("nickname"));
		
    return image;
}
</pre>
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/controller/CommunityController.java">CommunityController.java</a>
</pre>
## CommunityServiceImpl
<pre>
@Inject
private CommunityDAO dao;

@Override
public Map<String, Object> insertBoardWrite(BoardDTO dto) throws Exception { // 방송인 커뮤니티 게시판 글 작성
  Map<String, Object> map = new HashMap<>();
  String result = "Fail";
		
  int successCount = 0;
		
  if(!dto.isPrevention()) { // 도배 제한에 걸려있지 않아야 DB에 글 등록
    successCount = dao.insertBoardWrite(dto);
  }
	
  if(successCount == 1) {
    result = "Success";
  } else {
    map.put("broadcaster", dao.selectBroadcasterById(dto.getBroadcaster_id()));
  }
		
  map.put("result", result);
		
  return map;
}
</pre>
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/service/CommunityServiceImpl.java">CommunityServiceImpl.java</a>
</pre>
## CommunityMapper
<pre>
&lt;mapper namespace="community"&gt;
  &lt;insert id="insertBoardWrite" parameterType="com.kjh.aps.domain.BoardDTO" useGeneratedKeys="true" keyProperty="id" keyColumn="id"&gt;
    &lt;choose&gt;
      &lt;when test="board_type != null"&gt;
        &lt;choose&gt;
          &lt;when test='board_type.equals("non")'&gt;
            INSERT INTO combine_board(nickname, password, ip, subject, content, image_flag, media_flag, type)
            VALUE(#{nickname}, #{password}, #{ip}, #{subject}, #{content}, #{image_flag}, #{media_flag}, #{board_type})
          &lt;/when&gt;
          &lt;when test='board_type.equals("user") and user_id != 0'&gt;
            INSERT INTO combine_board(user_id, nickname, profile, level, ip, subject, content, image_flag, media_flag, user_type, type)
            VALUE(#{user_id}, #{nickname}, #{profile}, #{level}, #{ip}, #{subject}, #{content}, #{image_flag}, #{media_flag}, #{userType}, #{board_type})
          &lt;/when&gt;
        &lt;/choose&gt;
      &lt;/when&gt;
      &lt;otherwise&gt;
        INSERT INTO broadcaster_board(broadcaster_id, user_id, ip, subject, content, image_flag, media_flag)
        VALUE(#{broadcaster_id}, #{user_id}, #{ip}, #{subject}, #{content}, #{image_flag}, #{media_flag})
      &lt;/otherwise&gt;
    &lt;/choose&gt;
  &lt;/insert&gt;
  &lt;select id="selectBroadcasterById" resultType="com.kjh.aps.domain.BroadcasterDTO"&gt;
    SELECT * FROM broadcaster WHERE id = #{param1}
  &lt;/select&gt;
&lt;/mapper&gt;
</pre>
<pre>
<a href="https://github.com/KimJongHyeok2/aps/blob/master/APS/src/main/java/com/kjh/aps/mapper/CommunityDAO.xml">CommunityDAO.xml</a>
</pre>
