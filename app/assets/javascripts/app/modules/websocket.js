var AceSocket = {
  initialize: function() {
    WEB_SOCKET_SWF_LOCATION = "/javascripts/web-socket-js/WebSocketMain.swf";

    var config = $("#websocket");
    this.error_count = 0;
    this.ws = new WebSocket("ws://"+config.attr("data-host")+":34567/");
    this.socket_key = null;


    this.ws.onmessage = function(evt) {
      AceSocket.parse(evt.data);
    };

    window.webSocketError = function(message) {
      console.error(decodeURIComponent(message));
      AceSocket.error_count += 1;
    }

    this.ws.onclose = function() {
      if(AceSocket.error_count < 3)
        setTimeout(AceSocket.initialize, 5000)
    };

    this.ws.onopen = function() {
      AceSocket.send({id: 'start', key: config.attr("data-key"), channel_id: config.attr("data-group")});
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
        AceSocket.add_chat_message(data.from, data.message);
      }
      break;
      case 'newquestion': {
        AceUI.new_question(data);
      }
      break;
      case 'updatequestion': {
        AceUI.update_question(data);
      }
      break;
      case 'destroyquestion': {
        AceUI.delete_question(data);
      }
      break;
      case 'newanswer': {
        AceUI.new_answer(data);
      }
      break;
      case 'updateanswer': {
        AceUI.update_answer(data);
      }
      break;
      case 'vote': {
        AceUI.vote(data);
      }
      break;
      case 'newcomment': {
        AceUI.new_comment(data);
      }
      break;
      case 'updatedcomment': {
        AceUI.update_comment(data);
      }
      break;
      case 'newactivity': {
        AceUI.new_activity(data);
      }
      break;
    }
  },
  send: function(data) {
    this.ws.send(JSON.stringify(data))
  }
};
