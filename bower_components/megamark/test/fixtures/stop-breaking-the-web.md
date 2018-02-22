# Stop Breaking the Web

The year is 2014, a ninja rockstar band goes up against the now long-forgotten [progressive enhancement][1] technique, forsaking the origins of the web and everything they once stood for. This article is where I rant about how **we are breaking the web**, the not-immediately-obvious reasons why we should stop doing this, and how _not breaking the web would be a great thing_.

**TL;DR** _We are crushing the web. Dedicated client-side rendering sucks. Polyfills are used for all the wrong reasons. Those hideous-looking hash routers are bad and we should feel bad. We have been telling each other for years that progressive enhancement is great, and yet we're doing very little about it!_

Here's hoping the screenshot below corresponds merely to a publicity stunt, attempting to grab the tech media world by surprise. That being said, the fact that _we're not certain_ about whether this is a ruse or a permanent decision makes me cringe for the future of the web.

![tacobell.png][19]

<sub>Taco Bell _#onlyintheapp_ — is it a **clever publicity stunt to drive app downloads or a symptom of the profusely bleeding web?**</sub>

_Disclaimer: This article is **not a rant about Angular 2.0**. I started forming these thoughts a while ago, before the Angular 2.0 revelations. The roadmap for Angular merely happened to coincide with the posting of this article. If anything, those news reinforce the [points others have made against it][5], but the statement behind this article goes far beyond the myriad of breaking changes in Angular's public API._

It makes me sad to point out that **we as a community have failed the web**. Whatever happened to [progressive enhancement][1]? You know, that simple rule where you are supposed to **put content at the forefront**. Everything else is secondary to content, right? People want to see your content first. Once the content is in place, maybe they'll want to be able to interact with it. However, if content isn't there first, because [your page is too slow][2], or because you load fonts synchronously before humans can read anything, or because you decide to use client-side rendering exclusively, then **humans are pretty much screwed**. _Right?_

> Sure, humans have faster Internet connections now. Or do they? A lot of humans access the web on **mobile connections such as 2G and 3G**, and they expect your site to be _just as fast as on desktop_. That'll hardly be the case if you're blocking content on a JavaScript download.

Increasingly, this is becoming the norm. Fuck humans, we need all these awesome frameworks to make the web great. Wait, we do need humans. They have money, metadata, and stuff. Oh I know, let's give them client-side routing even if they're on IE6. That's bound to make them happy, right? Oh, stupid IE6 doesn't support the history API. Well, screw IE6. What? [IE9 doesn't support the history API][9] either? Well, I'll just support IE10. Wait, that's bad, **I'll use a hash router** and support IE all the way down to IE6! Yes, what a wonderful world, let's make our site accessible through routes like `/#/products/nintendo-game-cube` and then require JavaScript to be enabled for our view router to work, and let's also render the views in the client-side alone. Yes, _that_ will do it!

Meanwhile, we add tons of weight to our pages, levelling the field and making the experience in modern browsers worse as a result of attempting to make the experience in older browsers better. There's a problem with this fallacy, though. People using older browsers **are not expecting the newest features**. They're content with what they have. That's the whole reason why they're using an older browser in the first place. Instead of attempting to give those users a better experience (and usually failing miserably), you should enable features only if they're currently available on the target browser, instead of creating hacks around those limitations.

Humans using older browsers would be more than fine with your site if you only kept the server-side rendering part, so they don't really need your fancy-and-terribly-complex [maintainability-nightmare][3] of a hash router. But no, wait! Hash routing is [so-and-so awesome][4], right? Who needs server-side rendering!

Okay fine let's assume you agree with me. Hash routing sucks. It does nothing to help modern browsers _(except slowing down the experience, [it does do that!][6])_ and everything to complicate development and confuse humans who are using older browsers.

## Do we even care about the web as much as we say we do?

Recently, someone published an article on Medium titled ["What's wrong with Angular.js"][5]. It infuriates me that we don't seem to care _at all_ about server-side rendering, as long as we are able to develop applications using our favorite framework. While every single other point was refuted in some way or another, the point about server-side rendering went almost unnoticed. As if nobody even cared or even understood the implications.

> 6\. No server side rendering without obscure hacks. Never. You can’t fix broken design. Bye bye [isomorphic web apps][7].

The only place where I would conceive using a framework that relies solely on client-side rendering is for developing prototypes or internal backend apps _(just like how we use Bootstrap mostly for internal stuff)_. In these cases, these negligent frameworks are great because they boost productivity at virtually no cost, since no humans get harmed in the process. Besides the few use cases where neglecting server-side rendering isn't going to affect any human beings, doing so is undisputably **slow, unacceptable, backwards, and negligent**.

It is slow because the human now has to download all of your markup, your CSS, and your JavaScript before the JavaScript is able to render the view the user expected you to deliver in the first place. When did we agree to trade performance for frameworks?

It is backwards because you should be **delivering the content in human-viewable form first**, and not after every single render blocking request out there finishes loading. This means that a human-ready HTML view should be rendered in the server-side and served to the human, then you can add your fancy JavaScript magic on top of that, while the user is busy making sense of the information you've presented them with.

> Always keep humans busy, or they'll get uneasy.

It is negligent because we have been telling each other to avoid this same situation for years, but using other words. We've been telling ourselves about the importance of deferring script loading by pushing `<script>` tags to the bottom of the page, and maybe even tack on an `async` attribute, so that they load last. Using client-side rendering without backing it up with server-side rendering means that those scripts you've pushed to the bottom of your page are now harming your experience, because loading is delayed and without JavaScript you won't have any content to show for. Don't start moving your `<script>` tags to the `<head>` just yet. Just understand how far-reaching the negative implications of using client-side rendering are, when server-side rendering isn't in the picture.

But don't take my word for it, here's what Twitter had to say. Remember Twitter? Yeah, [they switched to shared-rendering back in mid 2012][6] and never looked back.

> Looking at the components that make up _[the time to first tweet]_ measurement, we discovered that the raw parsing and execution of JavaScript caused massive outliers in perceived rendering speed. In our fully client-side architecture, you don’t see anything until our JavaScript is downloaded and executed. The problem is further exacerbated if you do not have a high-specification machine or if you’re running an older browser. The bottom line is that a client-side architecture leads to slower performance because most of the code is being executed on our users’ machines rather than our own.
>
> There are a variety of options for improving the performance of our JavaScript, but we wanted to do even better. We took the execution of JavaScript completely out of our render path. By rendering our page content on the server and deferring all JavaScript execution until well after that content has been rendered, we’ve dropped the time to first Tweet to one-fifth of what it was.

We are [worrying about the wrong things][10]. Yesterday, [Henrik Joreteg][11] raised a few valid concerns about the dire future of AngularJS. These things are disputable, though. You may like the changes, you may think they're for the best, but what are you really getting out of the large refactor in the road ahead of you? Truth be told, Angular is an excellent framework in terms of developer productivity, and **it is** "sponsored by Google", as in _they maintain the thing_. On the flip side, Angular's barrier of entry is tremendously high and you have nothing to show for it when you have to jump ship.

We are doing things backwards. We are treating modern browsers as _"the status quo"_, and logically if someone doesn't conform to "_the status quo"_, we'll be super helpful and add our awesome behavioral polyfills. This way, _at least_ they get a hash router!

> **We are worrying about the wrong things.**

## Emphasize Content First

What we should be doing instead is going back to basics. Let content down the wire **as quickly as possible**, using server-side rendering. Then add any extra functionality through JavaScript _once the page has already loaded_, and the content is viewable and usable for the human. If you want to include a feature older browsers don't have access to, such as the history API, first **think if it makes sense to do it at all**. Maybe your users are better off without it. In the history API case, maybe it's best to _let older browsers stick to the request-response model_, rather than trying to cram a history API mock onto them by means of a hash router.

The same principle applies to other aspects of web development. Need people to be able to post a comment? Provide a `<form>` and use AJAX in those cases where JavaScript is enabled and `XMLHttpRequest` is well supported. Want to defer style loading as to avoid render-blocking and inline the critical CSS instead? That's awesome, but please use a `<noscript>` tag as a fallback for those who disabled JavaScript. Otherwise you'll risk breaking the styles for those humans!

Did I mention the obviously broken aspect of hash routing where you can't do server-side rendering, as you won't know the hash part of the request on the server? That's right, Twitter has to maintain dedicated client-side rendering for the foreseeable future, as long as hash-banged requests are still hitting their servers.

## Progressively Enhance All The Things!

In summary, we should stop devising immensely clever client-side rendering solutions that are simply unable to conjure up any sort of server-side rendering. Besides **vomit-inducing "strategies"** such as using PhantomJS to render the client-side view on the server-side, that is. I'm sure nobody is in love with the ["sneak peak" for Angular 2.0][8] anyways, so many breaking changes for virtually no benefit. Oh wait, there are benefits, you say? I couldn't hear you through sound of browser support being cut down.

> I guess that's what you get when you don't care about progressive enhancement.

The next time you pick up a project, don't just **blindly throw AngularJS, Bootstrap and jQuery at it**, and call it a day. Figure out ways to do shared rendering, use React or Taunus, or something else that allows you to do shared rendering without repeating yourself. Otherwise **don't do client-side rendering at all**.

**Strive for simplicity. Use progressive enhancement.** Don't do it for people who disable JavaScript. Don't do it for people who use older browsers. Don't even do it _just to be thorough_. Do it because you acknowledge the important of delivering content first. Do it because you acknowledge that **your site doesn't have to look the same in every device and browser _ever_**. Do it because it improves user experience. Do it because people on mobile networks shouldn't have to suffer the painful experience of a broken web.

Build up from the pillars of the web, instead of doing everything backwards and demanding your fancy web 2.0 JavaScript frameworks to be loaded, parsed, and executed before you can even begin to consider rendering human-digestible content.

Here's a checklist you might need.

- HTML first, get meaningful markup to the human being as soon as possible
- Deliver some CSS, [inline critical path CSS][2] _(hey, that one came from Google, too!)_
- Defer the rest of the CSS until `onload` through JavaScript, but provide a fallback using `<noscript>`
- Defer below the fold images
- Defer font loading
- Defer all the JavaScript
- **Never again rely on client-side rendering alone**
- Prioritize content delivery
- Cache static assets
- Experiment with caching dynamic assets
- Cache database queries
- **Cache all the things**

Also, use `<form>` elements first, then build some AJAX on top of that. No! It's not for the no-JavaScript crazies. If the JavaScript is still loading, your site will be useless unless you have `<form>` elements in place to guarantee the functionality will be available. Some people just have to deal with slow mobile connections, embrace that. You can [use Google Chrome to emulate mobile connections][12], for example.

Don't lock yourself into a comprehensive technology that may just die within the next few months and leave you stranded. With [progressive enhancement][1] you'll never go wrong. Progressive enhancement means your code will always work, because you'll always focus on providing a minimal experience first, and then adding features, functionality, and behavior on top of the content.

Do use a framework, but look into frameworks that are **progressive-enhancement-friendly**, such as [Taunus][14], [hyperspace][17], [React][15], or Backbone with [Rendr][16]. All of these somehow allow you to do shared rendering, although the [Rendr][16] solution is kind of awkward, [it does work][18]. Both Taunus and `hyperspace` let you do things _"the modular way"_ as they are surrounded by small modules you can take advantage of. React has its own kind of awful, but at least you can use if for server-side rendering, and at least Facebook _does_ use it.

Do look into ways of developing more modular architectures. Progressive enhancement doesn't mean you'll get a monolithic application as a result. Quite the contrary really. Progressive means that you'll get an application that builds upon the principles of the web. It means that your application will work even when JavaScript is disabled, for the most part. It may even be missing a few core aspects of its functionality, say if you forget to add a `<form>` fallback in an important part of your site's experience.

Even that would be okay, because you'd have learned the value of progressive enhancement, and you could add that `<form>`, having your site be a little more lenient with older browsers and humans using mobile phones. You'd have learned not to render your application on the client-side alone, and you'd use shared-rendering or even server-side rendering instead. You'd have learned the value of the little things, like using `<noscript>` tags or [setting up OpenSearch][13]. You'd have learned to respect the web. You'd have gotten back on the road of those who truly care about the web.

### You'd have learned to stop breaking the web.

  [1]: http://alistapart.com/article/understandingprogressiveenhancement "Understanding Progressive Enhancement"
  [2]: /articles/critical-path-performance-optimization "Critical Path Performance Optimization at Pony Foo"
  [3]: http://danwebb.net/2011/5/28/it-is-about-the-hashbangs "It is about the hashbangs"
  [4]: http://mtrpcic.net/2011/02/fragment-uris-theyre-not-as-bad-as-you-think-really/ "Hashbang URIs – They’re not as bad as you think; really."
  [5]: https://medium.com/este-js-framework/whats-wrong-with-angular-js-97b0a787f903 "What's wrong with Angular.js on Medium"
  [6]: https://blog.twitter.com/2012/improving-performance-on-twittercom "Improving performance on twitter.com"
  [7]: http://nerds.airbnb.com/isomorphic-javascript-future-web-apps/ "Isomorphic JavaScript: The Future of Web Apps"
  [8]: http://jaxenter.com/angular-2-0-112094.html "A sneak peek at the radically new Angular 2.0"
  [9]: http://caniuse.com/#feat=history "Can I Use The History API?"
  [10]: https://blog.andyet.com/2014/10/29/optimize-for-change-its-the-only-constant "Optimize for change. It’s the only constant."
  [11]: https://twitter.com/HenrikJoreteg "@HenrikJoreteg on Twitter"
  [12]: http://www.elijahmanor.com/enhanced-chrome-emulation-tools/ "Enhanced Google Chrome Emulation Tools"
  [13]: /articles/implementing-opensearch "Implementing OpenSearch"
  [14]: https://github.com/bevacqua/taunus "bevacqua/taunus on GitHub"
  [15]: https://github.com/facebook/react "facebook/react on GitHub"
  [16]: https://github.com/rendrjs/rendr "rendrjs/rendr on GitHub"
  [17]: http://substack.net/shared_rendering_in_node_and_the_browser "Shared rendering in node and the browser"
  [18]: https://github.com/buildfirst/buildfirst/tree/master/ch07/11_entourage "Entourage: Shared Rendering with Rendr"
  [19]: http://i.imgur.com/YzXGW5g.png
