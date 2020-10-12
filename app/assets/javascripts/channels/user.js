App.room = App.cable.subscriptions.create('UserChannel',{
    connected: function(){

    },
    disconnected: function(){

    },
    received: function(data){

        // Called when there's incoming data on the websocket for this channel
    }
});