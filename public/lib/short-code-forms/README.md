# Short Code Forms

A form generator following conventions in [WordPress short codes](https://github.com/MWDelaney/bootstrap-3-shortcodes)

## Goals

* for each match:
  * make it return the original markup
  * make it return before/after change
  * make a submit() method to send it somewhere
  * make an "onComplete" feedback - green/red checkmark/x

## Currently

* short-code-prompts.js is working; takes a single input or textarea
* short-code-forms.js is not yet -- need to decide how it converts each type of input (textarea, input, select, etc) into Markdown or HTML


