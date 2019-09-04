App.room = App.cable.subscriptions.create('UserNotificationChannel',{
    connected: function(){
    },
    disconnected: function(){
    },
    received: function(data) {
        navigator.serviceWorker.register('/sw.js');
        // Called when there's incoming data on the websocket for this channel
        // Let's check if the browser supports notifications
        if (!("Notification" in window)) {
            console.log("This browser does not support desktop notification");
        }
        // Let's check whether notification permissions have already been granted
        else if (Notification.permission === "granted") {
            // If it's okay let's create a notification
            navigator.serviceWorker.ready.then(function(registration) {
                registration.showNotification(data.notification.title, data.notification.option);
            });
        }
    }
});