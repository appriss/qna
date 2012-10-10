var QnaSocket = {
  initialize: function() {
    WEB_SOCKET_SWF_LOCATION = "/javascripts/web-socket-js/WebSocketMain.swf";

    var config = $("#websocket");
    this.error_count = 0;
    this.ws = new WebSocket("ws://"+config.attr("data-host")+":34567/");
    this.socket_key = null;


    this.ws.onmessage = function(evt) {
      QnaSocket.parse(evt.data);
    };

    window.webSocketError = function(message) {
      console.error(decodeURIComponent(message));
      QnaSocket.error_count += 1;
    }

    this.ws.onclose = function() {
      if(QnaSocket.error_count < 3)
        setTimeout(QnaSocket.initialize, 5000)
    };

    this.ws.onopen = function() {
      QnaSocket.send({id: 'start', key: config.attr("data-key"), channel_id: config.attr("data-group")});
    };
  },
  add_chat_message: function(from, message) {
    $("#chat_div").chatbox("option", "boxManager").addMsg(from, message);
  },
  parse: function(data) {
    var data = JSON.parse(data);

    window.console && console.log("received: ");
    window.console && console.log(data);

    switch(data.id) {
      case 'chatmessage': {
        QnaSocket.add_chat_message(data.from, data.message);
      }
      break;
      case 'newquestion': {
        QnaUI.new_question(data);
      }
      break;
      case 'updatequestion': {
        QnaUI.update_question(data);
      }
      break;
      case 'destroyquestion': {
        QnaUI.delete_question(data);
      }
      break;
      case 'newanswer': {
        QnaUI.new_answer(data);
      }
      break;
      case 'updateanswer': {
        QnaUI.update_answer(data);
      }
      break;
      case 'vote': {
        QnaUI.vote(data);
      }
      break;
      case 'newcomment': {
        QnaUI.new_comment(data);
      }
      break;
      case 'updatedcomment': {
        QnaUI.update_comment(data);
      }
      break;
      case 'newactivity': {
        QnaUI.new_activity(data);
      }
      break;
    }
  },
  send: function(data) {
    this.ws.send(JSON.stringify(data))
  }
};
