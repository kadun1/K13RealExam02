<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
</head>
<body>
<script type="text/javascript">
var messageWindow;
var inputMessage;
var chat_id;
var webSocket;
var logWindow;
window.onload = function(){
	
	messageWindow = document.getElementById("messageWindow");
	//대화영역의 스크롤바를 항상 아래로 내려준다
	messageWindow.scrollTop = messageWindow.scrollHeight;
	//메세지 입력부분
	inputMessage = document.getElementById('inputMessage');
	//채팅아이디
	chat_id = document.getElementById('chat_id').value;
	logWindow = document.getElementById('logWindow');
	
	webSocket = new WebSocket('ws://localhost:8080/realexam02/EchoServer.do');
	webSocket.onopen = function(event){
		wsOpen(event);
	};
	webSocket.onmessage = function(event){
		wsMessage(event);
	};
	webSocket.onclose = function(event){
		wsClose(event);
	};
	webSocket.onerror = function(event){
		wsError(event);
	};
}
function wsOpen(event){
	writeResponse("연결성공");
}

function wsMessage(event){
	var message = event.data.split("|");
	var sender = message[0];
	var content = message[1];
	var msg;
	
	writeResponse(event.data);
	
	if (content ==""){
		//내용없으므로 아무것도 하지않는다.
	}
	else {
		//내용에 /가 있다면 귓속말이므로...
		if(content.match("/")){
			//해당 아이디(닉네임)에게만 디스플레이 한다.
			if(content.match("/"+chat_id)){
				var temp = content.replace(("/"+chat_id),"[귓속말]:");
				msg = makeBalloon(sender, temp);
				messageWindow.innerHTML += msg;
				//대화영역의 스크롤바를 항상 아래로 내려준다.
				messageWindow.scrollTop = messageWindow.scrollHeight;					
			}
		}
		else{
			//귓속말이 아니면 모두에게 디스플레이
			msg = makeBalloon(sender, content);
			messageWindow.innerHTML += msg;
			//대화영역의 스크롤바를 항상 아래로 내려준다.
			messageWindow.scrollTop = messageWindow.scrollHeight;					
		}
	}
}

function wsClose(event){
	writeResponse("대화 종료");
}
function wsError(event){
	writeResponse("에러 발생");
	writeResponse(event.data);
}
function makeBalloon(id, cont){
	var msg = '';
	msg += '<div>'+id+':'+cont+'</div>';
	return msg;
}


function sendMessage(){
	//웹소켓 서버로 대화내용을 전송한다
	webSocket.send(chat_id+'|'+inputMessage.value);
	
	//내가 보낸 내용에 UI를 적용한다.
	var msg = '';
	msg += '<div style="text-align:right;">'+inputMessage.value+'</div>';
	
	messageWindow.innerHTML += msg;
	inputMessage.value = "";
	//대화영역의 스크롤바를 항상 아래로 내려준다.
	messageWindow.scrollTop = messageWindow.scrollHeight;						
}

function enterkey(){
	/*
	키보드를 눌렀다가 뗐을때 호출되며, 눌러진 키보드의
	키코드가 13일때, 즉 엔터키일때 아래 함수를 즉시 호출한다.
	*/
	if(window.event.keyCode==13){
		sendMessage();
	}
}
function writeResponse(text){
	logWindow.innerHTML += "<br/>"+text;
}
</script>	


<div class="container">
    <input type="hid den" id="chat_id" value="${param.chat_id }" />
    <input type="hid den" id="chat_room" value="${param.chat_room }" />
    <table class="table table-bordered">
   	 <tr>
   		 <td>방명:</td>
   		 <td>${param.chat_room }</td>
   	 </tr>
   	 <tr>
   		 <td>닉네임:</td>
   		 <td>${param.chat_id }</td>
   	 </tr>
   	 <tr>
   		 <td>메시지:</td>
   		 <td>
   			 <input type="text" id="inputMessage" class="form-control float-left mr-1" style="width:75%"
   			 onkeyup="enterkey();" />
   			 <input type="button" id="sendBtn" onclick="sendMessage();" value="전송" class="btn btn-info float-left" />
   		 </td>
   	 </tr>
    </table>
    <div id="messageWindow" class="border border-primary" style="height:300px; overflow:auto;">
   	 <div style="text-align:right;">내가쓴거</div>
   	 <div>상대가보낸거</div>
    </div>   
	<div id="logWindow" class="border border-danger" style="height:130px; overflow:auto;"></div>   

</div>



</body>
</html>