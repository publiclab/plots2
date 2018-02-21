'use strict';

var MarkdownIt = require('markdown-it');
var hljs = require('highlight.js');
var sluggish = require('sluggish');
var tokenizeLinks = require('./tokenizeLinks');
var md = new MarkdownIt({
  html: true,
  xhtmlOut: true,
  linkify: true,
  typographer: true,
  langPrefix: 'md-lang-alias-',
  highlight: highlight.bind(null, false)
});
var ralias = / class="md-lang-alias-([^"]+)"/;
var aliases = {
  js: 'javascript',
  md: 'markdown',
  html: 'xml', // next best thing
  jade: 'css', // next best thing
  zsh: 'bash', // next best thing
  shell: 'bash', // next best thing
  sh: 'bash' // next best thing
};

md.core.ruler.after('linkify', 'pos_counter', function posCounter (state) {
  var partial = state.src;
  var cursor = 0;
  state.tokens.forEach(function crawl (token, i) {
    token.cursorStart = cursor;
    if (token.markup) {
      moveCursor(token.markup);
    }
    if (token.type === 'link_open') {
      moveCursor('[');
    }
    if (token.type === 'link_close') {
      moveCursorAfterLinkClose();
    }
    if (token.type === 'image') {
      moveCursor('![');
    }
    if (token.children) {
      token.children.forEach(crawl);
    } else if (token.content) {
      token.src = token.content;
      moveCursor(token.src);
    }
    if (token.type === 'code_inline') { // closing mark
      moveCursor(token.markup);
    }
    if (token.type === 'heading_open') {
      moveCursor('');
    }
    if (token.map) {
      moveCursor('');
    }
    token.cursorEnd = cursor;
  });

  function moveCursor (needle) {
    var regex = needle instanceof RegExp;
    var re = regex ? needle : new RegExp('^\\s*' + escapeForRegExp(needle), 'ig');
    var match = re.exec(partial);
    if (!match) {
      return false;
    }
    var diff = re.lastIndex;
    cursor += diff;
    partial = partial.slice(diff);
    return true;
  }

  function moveCursorAfterLinkClose () {
    moveCursor(']');
    if (!moveCursor(/^\s*\[[^\]]+\]/g)) {
      moveCursor('(');
      moveCursorAfterParenthesis();
    }
  }

  function moveCursorAfterParenthesis () {
    var prev;
    var char;
    var i;
    var inQuotes = false;
    for (i = 0; i < partial.length; i++) {
      prev = partial[i - 1] || '';
      if (prev === '\\') { continue; }
      char = partial[i];
      if (!inQuotes && char === ')') { break; }
      if (char === '"' || char === '\'') { inQuotes = !inQuotes; }
    }
    cursor += i + 1;
    partial = partial.slice(i + 1);
  }
});

function repeat (text, times) {
  var result = '', n;
  while (n) {
    if (n % 2 === 1) {
      result += text;
    }
    if (n > 1) {
      text += text;
    }
    n >>= 1;
  }
  return result;
}

function escapeForRegExp (text) { return text.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, '\\$&'); }

var baseblock = md.renderer.rules.code_block;
var baseinline = md.renderer.rules.code_inline;
var basefence = md.renderer.rules.fence;
var basetext = md.renderer.rules.text;
var baserenderInline = md.renderer.renderInline;
var languages = [];

md.core.ruler.before('linkify', 'linkify-tokenizer', linkifyTokenizer, {});
md.renderer.rules.heading_open = heading;
md.renderer.rules.code_block = block;
md.renderer.rules.code_inline = inline;
md.renderer.rules.fence = fence;
md.renderer.renderInline = renderInline;

hljs.configure({ tabReplace: 2, classPrefix: 'md-code-' });

function highlight (encoded, code, detected) {
  var lower = String(detected).toLowerCase();
  var lang = aliases[detected] || detected;
  var escaped = encodeHtmlMarks(code, encoded);
  try {
    var result = hljs.highlight(lang, escaped);
    var unescaped = decodeHtmlMarks(result.value, true, encoded);
    return unescaped;
  } catch (e) {
    return decodeHtmlMarks(encodeHtmlMarks(code, encoded), true, encoded);
  }
}

function encode (tag) {
  return tag.replace('<', '&lt;').replace('>', '&gt;');
}

function encodeHtmlMarks (code, encoded) {
  var opentag = '<mark>';
  var closetag = '</mark>';
  if (encoded) {
    opentag = encode(opentag);
    closetag = encode(closetag);
  }
  var ropen = new RegExp(opentag, 'g');
  var rclose = new RegExp(closetag, 'g');
  var open = 'highlightmarkisveryliteral';
  var close = 'highlightmarkwasveryliteral';
  return code.replace(ropen, open).replace(rclose, close);
}

function decodeHtmlMarks (value, inCode) {
  var ropen = /highlightmarkisveryliteral/g;
  var rclose = /highlightmarkwasveryliteral/g;
  var classes = 'md-mark' + (inCode ? ' md-code-mark' : '');
  var open = '<mark class="' + classes + '">';
  var close = '</mark>';
  return value.replace(ropen, open).replace(rclose, close);
}

function heading (tokens, i, options, env, renderer) {
  var token = tokens[i];
  var open = '<' + token.tag;
  var close = '>';
  var contents = read();
  var slug = sluggish(contents);
  if (slug.length) {
    return open + ' id="' + slug + '"' + close;
  }
  return open + close;

  function read () {
    var index = i++;
    var next = tokens[index];
    var contents = '';
    while (next && next.type !== 'heading_close') {
      contents += next.content;
      next = tokens[index++ + 1];
    }
    return contents;
  }
}

function block (tokens, idx, options, env) {
  var base = baseblock.apply(this, arguments).substr(11); // starts with '<pre><code>'
  var untagged = base.substr(0, base.length - 14);
  var upmarked = upmark(tokens[idx], untagged, 0, env);
  var marked = highlight(true, upmarked);
  var classed = '<pre class="md-code-block"><code class="md-code">' + marked + '</code></pre>\n';
  return classed;
}

function inline (tokens, idx, options, env) {
  var base = baseinline.apply(this, arguments).substr(6); // starts with '<code>'
  var untagged = base.substr(0, base.length - 7); // ends with '</code>'
  var upmarked = upmark(tokens[idx], untagged, 1, env);
  var marked = highlight(true, upmarked);
  var classed = '<code class="md-code md-code-inline">' + marked + '</code>';
  return classed;
}

function renderInline (tokens, options, env) {
  var result = baserenderInline.apply(this, arguments);
  if (!tokens.length) {
    return result;
  }
  env.flush = true;
  result += upmark(tokens[tokens.length - 1], '', 0, env);
  env.flush = false;
  return result;
}

function upmark (token, content, offset, env) {
  return env.markers
    .filter(pastOrPresent)
    .reverse()
    .reduce(considerUpmarking, content);

  function considerUpmarking (content, marker) {
    var startOffset = env.flush ? 0 : marker[0] - token.cursorStart;
    var start = Math.max(0, startOffset - offset);
    var markerCode = consumeMarker(marker, env);
    return (
      content.slice(0, start) +
        markerCode +
      content.slice(start)
    );
  }

  function pastOrPresent (marker) {
    return marker[0] <= token.cursorEnd;
  }
}

function consumeMarker (marker, env) {
  var code = randomCode() + randomCode() + randomCode();
  env.markers.splice(env.markers.indexOf(marker), 1);
  env.markerCodes.push([code, marker[1]]);
  return code;
}

function randomCode () {
  return Math.random().toString(18).substr(2).replace(/\d+/g, '');
}

function fence (tokens, idx, options, env) {
  var base = basefence.apply(this, arguments).substr(5); // starts with '<pre>'
  var lang = base.substr(0, 6) !== '<code>'; // when the fence has a language class
  var untaggedStart = lang ? base.indexOf('>') + 1 : 6;
  var untagged = base.substr(untaggedStart);
  var upmarked = upmark(tokens[idx], untagged, 0, env);
  var codeTag = lang ? base.substr(0, untaggedStart) : '<code class="md-code">';
  var classed = '<pre class="md-code-block">' + codeTag + upmarked;
  var aliased = classed.replace(ralias, aliasing);
  return aliased;
}

function aliasing (all, language) {
  var name = aliases[language] || language || 'unknown';
  var lang = 'md-lang-' + name;
  if (languages.indexOf(lang) === -1) {
    languages.push(lang);
  }
  return ' class="md-code ' + lang + '"';
}

function textParser (tokens, idx, options, env) {
  var token = tokens[idx];
  token.content = upmark(token, token.content, 0, env);
  var base = basetext.apply(this, arguments);
  var tokenized = tokenize(base, env.tokenizers);
  return tokenized;
}

function linkifyTokenizer (state) {
  tokenizeLinks(state, state.env);
}

function tokenize (text, tokenizers) {
  return tokenizers.reduce(use, text);
  function use (result, tok) {
    return result.replace(tok.token, tok.transform);
  }
}

function decodeMarkers (html, env) {
  return env.markerCodes.reduce(reducer, html);
  function reducer (html, mcp) {
    return html.replace(mcp[0], mcp[1]);
  }
}

function markdown (input, options) {
  var tok = options.tokenizers || [];
  var lin = options.linkifiers || [];
  var valid = input === null || input === void 0 ? '' : String(input);
  var env = {
    tokenizers: tok,
    linkifiers: lin,
    markers: options.markers ? options.markers.sort(asc) : [],
    markerCodes: []
  };
  md.renderer.rules.text = textParser;
  var leftMark = upmark({ cursorStart: 0, cursorEnd: 0 }, '', 0, env);
  var htmlMd = md.render(valid, env);
  env.flush = true;
  var rightMark = upmark({ cursorStart: 0, cursorEnd: Infinity }, '', 0, env);
  var html = leftMark + htmlMd + rightMark;
  return decodeMarkers(decodeHtmlMarks(encodeHtmlMarks(html)), env);
}

function asc (a, b) { return a[0] - b[0]; }

markdown.parser = md;
markdown.languages = languages;
module.exports = markdown;
