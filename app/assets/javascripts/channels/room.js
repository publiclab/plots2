App.room = App.cable.subscriptions.create('RoomChannel',{
    
    connected: function(){

    },
    disconnected: function(){

    },
    received: function(data){
        console.log("Response: " + data["message"]);
        // Called when there's incoming data on the websocket for this channel
      },
    speak: function (message) {
        return this.perform('speak', {
            message: message
        });
    }
  });