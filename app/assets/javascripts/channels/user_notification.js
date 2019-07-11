App.room = App.cable.subscriptions.create('UserNotificationChannel',{
    connected: function(){
    },
    disconnected: function(){
    },
    received: function(data) {
        console.log("in here 1");
        // Called when there's incoming data on the websocket for this channel
        // Let's check if the browser supports notifications
        if (!("Notification" in window)) {
            console.log("in here 2");
            console.log("This browser does not support desktop notification");
        }
        // Let's check whether notification permissions have already been granted
        else if (Notification.permission === "granted") {
            console.log("in here 3");
            // If it's okay let's create a notification
           var notification = new Notification(data.notification.title, data.notification.option);
           notification.onclick = function(event) {
               console.log("in here 4");
                event.preventDefault(); // prevent the browser from focusing the Notification's tab
                window.open(data.notification.path, '_blank');
            }
        }
    }
});