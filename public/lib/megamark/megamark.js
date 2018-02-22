'use strict';

var insane = require('insane');
var assign = require('assignment');
var markdown = require('./markdown');
var hightokens = require('highlight.js-tokens').map(codeclass);

function codeclass (token) {
  return 'md-code-' + token;
}

function sanitize (html, o) {
  var headings = { h1: 'id', h2: 'id', h3: 'id', h4: 'id', h5: 'id', h6: 'id' };
  var options = assign({ allowedClasses: {}, allowedAttributes: headings }, o);
  var ac = options.allowedClasses;

  add('mark', ['md-mark', 'md-code-mark']);
  add('pre', ['md-code-block']);
  add('code', markdown.languages);
  add('span', hightokens);

  return insane(html, options);

  function add (type, more) {
    ac[type] = (ac[type] || []).concat(more);
  }
}

function megamark (md, options) {
  var o = options || {};
  var html = markdown(md, o);
  var sane = sanitize(html, o.sanitizer);
  return sane;
}

markdown.languages.push('md-code', 'md-code-inline'); // only sanitizing purposes
megamark.parser = markdown.parser;
module.exports = megamark;
