# typeahead.js-browserify

Make using [typeahead.js](http://twitter.github.io/typeahead.js/) with browserify a little easier. 

The standard `typeahead.js` npm package doesn't expose Bloodhound, and loads it's jQuery plugin as soon as it's required. 

This package is just a small wrapper that allows you to access Bloodhound and load the jQuery plugin explicitly. 

# Usage

Bloodhound: 
```javascript
var Bloodhound = require("typeahead.js-browserify").Bloodhound 
var engine = new Bloodhound({
  local: ['dog', 'pig', 'moose'],
  queryTokenizer: Bloodhound.tokenizers.whitespace,
  datumTokenizer: Bloodhound.tokenizers.whitespace
});
```

For jQuery just `require` jquery, and then call `loadjQueryPlugin()`. typeahead.js will attach itself to the previously required jQuery.

```javascript
var jQuery = require("jquery");
var typeahead = require("typeahead.js-browserify");
typeahead.loadjQueryPlugin();
```
