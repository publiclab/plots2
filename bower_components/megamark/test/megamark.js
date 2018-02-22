'use strict';

var fs = require('fs');
var test = require('tape');
var megamark = require('..');

function read (name) {
  return fs.readFileSync('./test/fixtures/' + name, 'utf8');
}

function write (name, data) {
  return fs.writeFileSync('./test/fixtures/' + name, data);
}

test('empty doesn\'t blow up', function (t) {
  t.equal(megamark(), '');
  t.end();
});

test('code snippets work as expected', function (t) {
  t.equal(megamark(read('code-snippets.md')), read('code-snippets.html'));
  t.end();
});

test('email link works as expected', function (t) {
  t.equal(megamark(read('email-example.md')), read('email-example.html'));
  t.end();
});

test('emphasis works as expected', function (t) {
  t.equal(megamark(read('barkup.md')), read('barkup.html'));
  t.end();
});

test('parsing of ponyfoo articles works as expected', function (t) {
  t.equal(megamark(read('stop-breaking-the-web.md')), read('stop-breaking-the-web.html'));
  t.equal(megamark(read('cross-tab-communication.md')), read('cross-tab-communication.html'));
  t.end();
});

test('tokenizing works as expected', function (t) {
  t.equal(megamark('_@bevacqua_', { tokenizers: [{ token: /(?:^|\s)@([A-z]+)\b/, transform: transform }] }), '<p><em>BEVACQUA</em></p>\n');
  t.end();
  function transform (text, username) {
    return username.toUpperCase();
  }
});

test('tokenizer ignores encoding by default', function (t) {
  t.equal(megamark('_@bevacqua_', { tokenizers: [{ token: /(?:^|\s)@([A-z]+)\b/, transform: transform }] }), '<p><em><a href="/users/bevacqua">BEVACQUA</a></em></p>\n');
  t.end();
  function transform (text, username) {
    return '<a href="/users/' + username + '">' + username.toUpperCase() + '</a>';
  }
});

test('markdown defaults to ignoring hazardous elements, but that can be overridden', function (t) {
  t.equal(megamark('<iframe>foo</iframe>'), '');
  t.equal(megamark('<script>foo</script>'), '');
  t.equal(megamark('<style>foo</style>'), '');
  t.equal(megamark('<iframe>foo</iframe>', { sanitizer: { allowedTags: ['p', 'iframe'] } }), '<iframe>foo</iframe>');
  t.end();
  function transform (text, username) {
    return username.toUpperCase();
  }
});

test('tokenizing links allows me to return no content', function (t) {
  t.equal(megamark('ponyfoo.com', { linkifiers: [linkify] }), '<p></p>\n');
  t.end();
  function linkify (href, text) {
    return '';
  }
});

test('tokenizing links allows me to return plain text content', function (t) {
  t.equal(megamark('ponyfoo.com', { linkifiers: [linkify] }), '<p>@ponyfoo</p>\n');
  t.end();
  function linkify (href, text) {
    return '@' + text.split('.').shift();
  }
});

test('tokenizing links allows me to return any tags I want', function (t) {
  t.equal(megamark('ponyfoo.com', { linkifiers: [linkify] }), '<p><em>http://ponyfoo.com</em></p>\n');
  t.end();
  function linkify (href, text) {
    return '<em>' + href + '</em>';
  }
});

test('tokenizing links allows me to ignore _some_ things', function (t) {
  t.equal(megamark('ponyfoo.com google.com', { linkifiers: [linkify] }), '<p><em>http://ponyfoo.com</em> </p>\n');
  t.end();
  function linkify (href, text) {
    if (/\/\/google\.com/.test(href)) {
      return '';
    }
    return '<em>' + href + '</em>';
  }
});

test('tokenizing links allows me to return any tags I want', function (t) {
  t.equal(megamark('http://localhost:9000/bevacqua/stompflow/issues/28', { linkifiers: [linkify] }), '<p><a href="http://localhost:9000/bevacqua/stompflow/issues/28">#28</a></p>\n');
  t.end();
  function linkify (href, text) {
    return '<a href=' + href + '>#' + href.split('/').pop() + '</a>';
  }
});

test('tokenizing links doesn\'t break protocol', function (t) {
  t.equal(megamark('//localhost:9000/bevacqua/stompflow/issues/28', { linkifiers: [linkify] }), '<p><a href="//localhost:9000/bevacqua/stompflow/issues/28">#28</a></p>\n');
  t.end();
  function linkify (href, text) {
    return '<a href=' + href + '>#' + href.split('/').pop() + '</a>';
  }
});

test('tokenizing links doesn\'t break protocol', function (t) {
  t.equal(megamark('www.stompflow.com/bevacqua/stompflow/issues/28', { linkifiers: [linkify] }), '<p><a href="http://www.stompflow.com/bevacqua/stompflow/issues/28">#28</a></p>\n');
  t.end();
  function linkify (href, text) {
    return '<a href=' + href + '>#' + href.split('/').pop() + '</a>';
  }
});

test('tokenizing links doesn\'t break protocol', function (t) {
  t.equal(megamark('https://localhost:9000/bevacqua/stompflow/issues/28', { linkifiers: [linkify] }), '<p><a href="https://localhost:9000/bevacqua/stompflow/issues/28">#28</a></p>\n');
  t.end();
  function linkify (href, text) {
    return '<a href=' + href + '>#' + href.split('/').pop() + '</a>';
  }
});

test('links work as expected', function (t) {
  t.equal(
    megamark('ponyfoo.com and them something else'),
    '<p><a href="http://ponyfoo.com">ponyfoo.com</a> and them something else</p>\n'
  );
  t.equal(
    megamark('[asd](http://localhost:3000/author/compose)'),
    '<p><a href="http://localhost:3000/author/compose">asd</a></p>\n'
  );
  t.equal(
    megamark('[asd](/author/compose)'),
    '<p><a href="/author/compose">asd</a></p>\n'
  );
  t.equal(
    megamark('[asd][1]\n\n[1]: /author/compose'),
    '<p><a href="/author/compose">asd</a></p>\n'
  );
  t.equal(
    megamark('Get half off my **JavaScript Application Design** book today! Enter code **dotd072115au** at [bevacqua.io/bf/book](http://localhost:3000/author/compose) when checking out. If you run into any issues, let me know.'),
    '<p>Get half off my <strong>JavaScript Application Design</strong> book today! Enter code <strong>dotd072115au</strong> at <a href="http://localhost:3000/author/compose">bevacqua.io/bf/book</a> when checking out. If you run into any issues, let me know.</p>\n'
  );
  t.end();
});

test('italics work as expected', function (t) {
  t.equal(megamark('_some_'), '<p><em>some</em></p>\n');
  t.equal(megamark('_(some)_'), '<p><em>(some)</em></p>\n');
  t.equal(megamark('_(#)_'), '<p><em>(#)</em></p>\n');
  t.equal(megamark('_(#)_.'), '<p><em>(#)</em>.</p>\n');
  t.equal(megamark('_(#)_.', {}), '<p><em>(#)</em>.</p>\n');
  t.end();
});

test('headings work as expected', function (t) {
  t.equal(megamark('# foo'), '<h1 id="foo">foo</h1>\n');
  t.equal(megamark('## foo'), '<h2 id="foo">foo</h2>\n');
  t.equal(megamark('## **foo**'), '<h2 id="foo"><strong>foo</strong></h2>\n');
  t.equal(megamark('## **f _o_ o**'), '<h2 id="f-o-o"><strong>f <em>o</em> o</strong></h2>\n');
  t.equal(megamark('<h1></h1>'), '<h1></h1>');
  t.equal(megamark('<h1>a</h1>'), '<h1>a</h1>');
  t.equal(megamark('<h1 id="foo">bar</h1>'), '<h1 id="foo">bar</h1>');
  t.end();
});

test('mark highlights nodes, even within code', function (t) {
  t.equal(
    megamark('foo is <mark>marked..</mark>\n\n```html\n<mark><span>foo</span></mark>;\n```'),
    '<p>foo is <mark class="md-mark">marked…</mark></p>\n<pre class="md-code-block"><code class="md-code md-lang-xml"><mark class="md-mark md-code-mark"><span class="md-code-tag">&lt;<span class="md-code-title">span</span>&gt;</span>foo<span class="md-code-tag">&lt;/<span class="md-code-title">span</span>&gt;</span></mark>;\n</code></pre>\n'
  );
  t.equal(
    megamark('foo is <mark>marked..</mark>\n\n```js\n<mark><span>foo</span></mark>;\n```'),
    '<p>foo is <mark class="md-mark">marked…</mark></p>\n<pre class="md-code-block"><code class="md-code md-lang-javascript"><mark class="md-mark md-code-mark">&lt;span&gt;foo&lt;/span&gt;</mark>;\n</code></pre>\n'
  );
  t.equal(
    megamark('foo is <mark>marked..</mark>\n\n```\n<mark><span>foo</span></mark>;\n```'),
    '<p>foo is <mark class="md-mark">marked…</mark></p>\n<pre class="md-code-block"><code class="md-code"><mark class="md-mark md-code-mark"><span>foo</span></mark>;\n</code></pre>\n'
  );
  t.equal(
    megamark('asd\n\n`var foo = 1; <mark>foo = -10</mark>;`\n'),
    '<p>asd</p>\n<p><code class="md-code md-code-inline">var foo = 1; <mark class="md-mark md-code-mark">foo = -10</mark>;</code></p>\n'
  );
  t.equal(
    megamark('asd\n\n    <mark><span>foo</span></mark>'),
    '<p>asd</p>\n<pre class="md-code-block"><code class="md-code"><mark class="md-mark md-code-mark">&lt;span&gt;foo&lt;/span&gt;</mark></code></pre>\n'
  );
  t.end();
});

test('megamark understands markers', function (t) {
  t.equal(megamark('_foo_', { markers: [[0, '[START]'], [0, '[END]']] }), '[START][END]<p><em>foo</em></p>\n');
  t.equal(megamark('_foo_', { markers: [[5, '[START]'], [5, '[END]']] }), '<p><em>foo</em>[START][END]</p>\n');
  t.equal(megamark('_foo_', { markers: [[1, '[START]'], [5, '[END]']] }), '<p><em>[START]foo</em>[END]</p>\n');
  t.equal(megamark('foo', { markers: [[1, '[START]'], [2, '[END]']] }), '<p>f[START]o[END]o</p>\n');
  t.equal(megamark('**foo**', { markers: [[1, '[START]'], [5, '[END]']] }), '<p><strong>[START]foo[END]</strong></p>\n');
  t.equal(megamark('**foo**', { markers: [[2, '[START]'], [4, '[END]']] }), '<p><strong>[START]fo[END]o</strong></p>\n');
  t.equal(megamark('`foo`\n\n> *bar*\n\n**baz**', { markers: [[2, '[START]'], [5, '[END]']] }), '<p><code class="md-code md-code-inline">f[START]oo[END]</code></p>\n<blockquote>\n<p><em>bar</em></p>\n</blockquote>\n<p><strong>baz</strong></p>\n');
  t.equal(megamark('# markdown', { markers: [[3, '[START]'], [6, '[END]']] }), '<h1 id="markdown">m[START]ark[END]down</h1>\n');
  t.equal(megamark('### markdown', { markers: [[5, '[START]'], [8, '[END]']] }), '<h3 id="markdown">m[START]ark[END]down</h3>\n');
  t.equal(megamark('### markdown\n\n\n\n\n\n\n\n\nfoo bar baz', { markers: [[20, '[START]'], [23, '[END]']] }), '<h3 id="markdown">markdown</h3>\n<p>[START]fo[END]o bar baz</p>\n');
  t.equal(megamark('<a href="/foo">bar</a>', { markers: [[16, '[START]'], [18, '[END]']] }), '<p><a href="/foo">b[START]ar[END]</a></p>\n');
  t.equal(megamark('[bar](/foo)', { markers: [[2, '[START]'], [4, '[END]']] }), '<p><a href="/foo">b[START]ar[END]</a></p>\n');
  t.equal(megamark('[bar][a]\n\n[a]: /foo', { markers: [[2, '[START]'], [4, '[END]']] }), '<p><a href="/foo">b[START]ar[END]</a></p>\n');
  t.equal(megamark('![alt](/foo)', { markers: [[2, '[START]'], [4, '[END]']] }), '<p><img src="/foo" alt="[START]al[END]t"/></p>\n');
  t.equal(megamark('![alt][a]\n\n[a]: /foo', { markers: [[2, '[START]'], [4, '[END]']] }), '<p><img src="/foo" alt="[START]al[END]t"/></p>\n');
  t.equal(megamark('<img src="/foo" />', { markers: [[2, '[START]'], [4, '[END]']] }), '<img src="/foo"/>[START][END]');
  t.end();
});

test('megamark understands markers in complex markdown', function (t) {
  t.equal(megamark(read('woofmark-sample.md'), { markers: [[103, '[START]'], [172, '[END]']] }), read('woofmark-sample.html'));
  t.end();
});

test('megamark ignores html in code', function (t) {
  t.equal(megamark('`<strong>bar</strong>`'),
    '<p><code class="md-code md-code-inline">&lt;strong&gt;bar&lt;/strong&gt;</code></p>\n');

  t.equal(megamark('`<mark>foo</mark> asd asd  <strong>bar</strong>`'),
    '<p><code class="md-code md-code-inline"><mark class="md-mark md-code-mark">foo</mark> asd asd &lt;strong&gt;bar&lt;/strong&gt;</code></p>\n');
  t.equal(megamark('    <mark>foo</mark> asd asd  <strong>bar</strong>'),
    '<pre class="md-code-block"><code class="md-code"><mark class="md-mark md-code-mark">foo</mark> asd asd  &lt;strong&gt;bar&lt;/strong&gt;</code></pre>\n');

  t.equal(megamark('    <!doctype html>\n    <html><div>foo</div></html>'),
    '<pre class="md-code-block"><code class="md-code">&lt;!doctype html&gt;\n&lt;html&gt;&lt;div&gt;foo&lt;/div&gt;&lt;/html&gt;</code></pre>\n');
  t.end();
});
