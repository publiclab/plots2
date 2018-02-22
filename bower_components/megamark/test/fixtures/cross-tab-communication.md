# Cross-tab Communication

The upcoming [SharedWorker][1] API allows to transmit data across iframes and even browser tabs or windows. It landed in Chrome years ago, and not so long ago in Firefox, but it's [nowhere to be seen][2] in IE or Safari. A wildly supported alternative exists that can be used today, but it's largely unknown. Let's explore it!

I wanted an elegant solution to the following scenario: suppose a human walks into your website, logs in, **opens a second tab**, and logs out in that tab. He's still _"logged in"_ on the first tab, except anything he touches will either redirect them to the login page or straight blow up in their face. A more inviting alternative would be to figure out that they're logged out and do something about it, such as display a dialog asking them to re-authenticate, or maybe the login view itself.

You could use the WebSocket API for this, but that'd be overkill. I wanted a lower-level technology flyswatter, so I started looking for cross-tab communication options. The first option that popped up was using cookies or `localStorage`, and then periodically checking whether they were logged in or not via `setInterval`. I wasn't satisfied with that answer because it would waste too many CPU cycles checking for something that might not ever come up. At that point I would've rather used a _["comet"][3] (also known as long-polling)_, Server-Sent Events, or WebSockets.

I was surprised to see that the answer was lying in front of my nose, it was `localStorage` all along!

Did you know that `localStorage` fires an event? More specifically, it fires an event whenever an item is added, modified, or removed _in another browsing context_. Effectively, this means that whenever you touch `localStorage` in any given tab, all other tabs can learn about it by listening for the `storage` event on the `window` object, like so:

```
window.addEventListener('storage', function (event) {
  console.log(event.key, event.newValue);
});
```

The `event` object contains a few relevant properties.

Property   | Description
-----------|---------------------
`key`      | The affected key in `localStorage`
`newValue` | The value that is currently assigned to that key
`oldValue` | The value before modification
`url`      | The URL of the page where the change occurred

Whenever a tab modifies something in `localStorage`, an event fires in every other tab. This means we're able to _communicate across browser tabs_ simply by setting values on `localStorage`. Consider the following pseudo_ish_-code example:

```js
var loggedOn;

// TODO: call when logged-in user changes or logs out
logonChanged();

window.addEventListener('storage', updateLogon);
window.addEventListener('focus', checkLogon);

function getUsernameOrNull () {
  // TODO: return whether the user is logged on
}

function logonChanged () {
  var uname = getUsernameOrNull();
  loggedOn = uname;
  localStorage.setItem('logged-on', uname);
}

function updateLogon (event) {
  if (event.key === 'logged-on') {
    loggedOn = event.newValue;
  }
}

function checkLogon () {
  var uname = getUsernameOrNull();
  if (uname !== loggedOn) {
    location.reload();
  }
}
```

The basic idea is that when a user has two open tabs, logs out from one of them, and goes back to the other tab, the page is reloaded and _(hopefully)_ the server-side logic redirects them to somewhere else. The check is being done only when the tab is focused as a nod to the fact that maybe they log out and they log back in immediately, and in those cases we wouldn't want to log them out of every other tab.

We could certainly improve that piece of code, but it serves its purpose pretty well.  A better implementation would probably ask them to log in on the spot, but note that this also works the other way around: when they log in and go to another tab that was also logged out, the snippet detects that change reloading the page, and then the server would redirect them to the logged-in fountain-of-youth blessing of an experience you call your website _(again, hopefully)_.

# A simpler API

The `localStorage` API is arguably one of the easiest to use APIs there are, when it comes to web browsers, and it also enjoys quite thorough cross-browser support. There are, however, some quirks such as incognito Safari throwing on sets with a `QuotaExceededError`, no support for JSON out the box, or older browsers bumming you out.

For those reasons, I put together [local-storage][4] which is a module that provides a simplified API to `localStorage`, gets rid of those quirks, falls back to an in-memory store when the `localStorage` API is missing, and also makes it easier to consume `storage` events, by letting you register and unregister listeners for specific keys.

API endpoints in `local-storage@1.3.1` _(**latest**, at the time of this writing)_ are listed below.

- `ls(key, value?)` gets or sets `key`
- `ls.get(key)` gets the value in `key`
- `ls.set(key, value)` sets `key` to `value`
- `ls.remove(key)` removes `key`
- `ls.on(key, fn(value, old, url))` listens for changes to `key` in other tabs, triggers `fn`
- `ls.off(key, fn)` unregisters listener previously added with `ls.on`

It's also worth mentioning that [local-storage][4] registers a single `storage` event handler and keeps track of every key you want to observe, rather than register multiple `storage` events.

I'd be interested to learn about other use cases for low-tech communication across tabs! Certainly sounds useful for _offline-first_ development, particularly if we keep in mind that `SharedWorker` might take a while to become widely supported, and WebSockets are unreliable in offline-first scenarios.

[1]: https://developer.mozilla.org/en-US/docs/Web/API/SharedWorker "SharedWorker Web API on MDN"
[2]: http://caniuse.com/#feat=sharedworkers "Can I Use SharedWorkers?"
[3]: http://stackoverflow.com/a/12855533/389745 "What are Long-Polling, Websockets, Server-Sent Events (SSE) and Comet?"
[4]: https://github.com/bevacqua/local-storage "bevacqua/local-storage on GitHub"
