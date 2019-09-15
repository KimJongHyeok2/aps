<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/include/modals.css"/>
<!-- Normal Modal -->
<div id="modal-type-1" class="aps-modal-panel">
    <div class="aps-modal-wrapper">
        <div class="aps-modal-inner">
            <div class="aps-modal-inner-box animated tdExpandIn">
                <div class="aps-modal-header">
                    <div class="title"><i class="fas fa-info-circle"></i> <span></span></div>
                    <div class="close-button" onclick="modalToggle('#modal-type-1');"><i class="fas fa-times"></i></div>
                </div>
                <div class="aps-modal-body">
                    <div class="body-text"></div>
                </div>
                <div class="aps-modal-footer">
                    <button class="aps-modal-button" onclick="modalToggle('#modal-type-1');">닫기</button>
                </div>
            </div>
        </div>
    </div>
</div>
<!-- Confirm Modal -->
<div id="modal-type-2" class="aps-modal-panel">
    <div class="aps-modal-wrapper">
        <div class="aps-modal-inner">
            <div class="aps-modal-inner-box animated tdExpandIn">
                <div class="aps-modal-header">
                    <div class="title"><i class="fas fa-question-circle"></i> <span></span></div>
                    <div class="close-button" onclick="modalToggle('#modal-type-2');"><i class="fas fa-times"></i></div>
                </div>
                <div class="aps-modal-body">
                    <div class="body-text"></div>
                </div>
                <div class="aps-modal-footer">
                    <button id="2-identify-button" class="aps-modal-button">확인</button>
                    <button id="2-cancle-button" class="aps-modal-button" onclick="modalToggle('#modal-type-2');">취소</button>
                </div>
            </div>
        </div>
    </div>
</div>
<!-- Email Access Confirm Modal -->
<div id="modal-type-3" class="aps-modal-panel">
    <div class="aps-modal-wrapper">
        <div class="aps-modal-inner">
            <div class="aps-modal-inner-box animated tdExpandIn">
                <div class="aps-modal-header">
                    <div class="title"><i class="fas fa-info-circle"></i> <span>인증</span></div>
                </div>
                <div class="aps-modal-body">
                    <div class="body-text">
	                	<div class="input-box">
		                    <input type="text" id="email_accesskey" placeholder="이메일 인증키 입력"/><button class="re-access-button" onclick="retryEmailAccess();"><i class="fas fa-undo"></i></button>
	                    </div>
	                    <label class="confirmMsg">인증키가 올바르지 않습니다.</label>
                    </div>
                </div>
                <div class="aps-modal-footer">
                    <button class="aps-modal-button">완료</button>
                </div>
            </div>
        </div>
    </div>
</div>
<!-- Error Modal -->
<div id="modal-type-4" class="aps-modal-panel">
    <div class="aps-modal-wrapper">
        <div class="aps-modal-inner">
            <div class="aps-modal-inner-box animated tdExpandIn">
                <div class="aps-modal-header">
                    <div class="title"><i class="fas fa-times-circle"></i> <span></span></div>
                    <div class="close-button" onclick="modalToggle('#modal-type-4');"><i class="fas fa-times"></i></div>
                </div>
                <div class="aps-modal-body">
                    <div class="body-text"></div>
                </div>
                <div class="aps-modal-footer">
                    <button class="aps-modal-button" onclick="modalToggle('#modal-type-4');">확인</button>
                </div>
            </div>
        </div>
    </div>
</div>