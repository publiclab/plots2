class Editor {
  // default parameters:
  //   defaultForm - when the Editor is initialized, there needs to be a default editor form:
  //     1. the main comment form in multi-comment wikis, questions, & research notes.
  //     2. the only editor form on /wiki/new and /wiki/edit
  //   elementIDPrefixes - the ID naming conventions are different depending on context:
  //     1. multi-form pages with multiple comments: #comment-preview-123
  //     2. /wiki/new and /wiki/edit: #preview-main
  constructor(defaultForm = "main", elementIDPrefixes = {}) {
    this.commentFormID = defaultForm;
    this.elementIDPrefixes = elementIDPrefixes;
    // this will get deleted in the next few PRs, so collapsing into one line to pass codeclimate
    this.templates = { 'blog': "## The beginning\n\n## What we did\n\n## Why it matters\n\n## How can you help", 'default': "## What I want to do\n\n## My attempt and results\n\n## Questions and next steps\n\n## Why I'm interested", 'support': "## Details about the problem\n\n## A photo or screenshot of the setup", 'event': "## Event details\n\nWhen, where, what\n\n## Background\n\nWho, why", 'question': "## What I want to do or know\n\n## Background story" };
      
    marked.setOptions({
      gfm: true,
      tables: true,
      breaks: true,
      pedantic: false,
      sanitize: false,
      smartLists: true,
      langPrefix: 'language-',
      highlight: function(code, lang) {
        if (lang === 'js') {
          return highlighter.javascript(code);
        }
        return code;
      }
    });
  }
  setState(commentFormID) {
    this.commentFormID = commentFormID;
    this.attachSaveListener();
  }
  get textAreaElement() {
    const textAreaID = "#text-input-" + this.commentFormID;
    return $(textAreaID);
  }
  get textAreaValue() { 
    return this.textAreaElement.val(); 
  }
  get previewElement() {
    let previewIDPrefix = "#comment-preview-";
    if (this.elementIDPrefixes.hasOwnProperty("preview")) {
      // eg. on /wiki/new & /wiki/edit, the preview element is called #preview-main
      previewIDPrefix = "#" + this.elementIDPrefixes["preview"] + "-";
    }
    const previewID = previewIDPrefix + this.commentFormID;
    return $(previewID);
  }
  // wraps currently selected text in textarea with strings startString & endString
  wrap(startString, endString, newlineDesired = false, fallback) {
    const selectionStart = this.textAreaElement[0].selectionStart;
    const selectionEnd = this.textAreaElement[0].selectionEnd;
    const selection = fallback || this.textAreaValue.substring(selectionStart, selectionEnd); // fallback if nothing has been selected, and we're simply dealing with an insertion point

    let newText = newlineDesired ? startString + selection + endString + "\n\n" : startString + selection + endString; // ie. ** + selection + ** (wrapping selection in bold)
    const selectionStartsMidText = this.textAreaElement[0].selectionStart > 0;
    if (newlineDesired && selectionStartsMidText) { newText = "\n" + newText; }

    const textLength = this.textAreaValue.length;
    const textBeforeSelection = this.textAreaValue.substring(0, selectionStart);
    const textAfterSelection = this.textAreaValue.substring(selectionEnd, textLength);
    this.textAreaElement.val(textBeforeSelection + newText + textAfterSelection);
  }
  bold() {
    this.wrap('**', '**');
  }
  italic() {
    this.wrap('_', '_');
  }
  link(uri) {
    uri = prompt('Enter a URL');
    if (!uri) { uri = ""; }
    this.wrap(
      '[', 
      '](' + uri + ')'
    );
  }
  image(src) {
    this.wrap(
      '\n![', 
      '](' + src + ')\n'
    );
  }
  // these header formatting functions are not used anywhere, so commenting them out for now to pass codeclimate:

  // h1() {
  //   this.wrap('#','')
  // }
  h2() {
    this.wrap('##', '');
  }
  // h3() {
  //   this.wrap('###','')
  // }
  // h4() {
  //   this.wrap('####','')
  // }
  // h5() {
  //   this.wrap('#####','')
  // }
  // h6() {
  //   this.wrap('######','')
  // }
  // h7() {
  //   this.wrap('#######','')
  // }
  // this function is dedicated to Don Blair https://github.com/donblair
  attachSaveListener() {
    // remove any other existing eventHandler
    $("textarea").off("input.save"); // input.save is a custom jQuery eventHandler
    const thisEditor = this; // save a reference to this editor, because inside the eventListener, "this" points to e.target
    this.textAreaElement.on("input.save", function() {
      thisEditor.save(thisEditor);
    });
  }
  save(thisEditor) {
    const storageKey = "plots:" + window.location.pathname + ":" + thisEditor.commentFormID;
    localStorage.setItem(storageKey, thisEditor.textAreaValue);
  }
  recover() {
    const storageKey = "plots:" + window.location.pathname + ":" + this.commentFormID;
    this.textAreaElement.val(localStorage.getItem(storageKey));
  }
  apply_template(template) {
    if(this.textAreaValue == ""){
      this.textAreaElement.val(this.templates[template])
    }else if((this.textAreaValue == this.templates['event']) || (this.textAreaValue == this.templates['default']) || (this.textAreaValue == this.templates['support'])){
      this.textAreaElement.val(this.templates[template])
    }else{
      this.textAreaElement.val(this.textAreaValue+'\n\n'+this.templates[template])
    }
  }
  toggle_preview() {
    // if the element is part of a multi-comment page,
    // ensure to grab the current element and not the other comment element.
    const previewBtn = $("#toggle-preview-button-" + this.commentFormID);
    const commentFormBody = $("#comment-form-body-" + this.commentFormID);

    this.previewElement[0].innerHTML = marked(this.textAreaValue);
    this.previewElement.toggle();
    commentFormBody.toggle();

    this.toggleButtonPreviewMode(previewBtn);
  }
  toggleButtonPreviewMode(previewBtn) {
    let isPreviewing = previewBtn.attr('data-previewing');

    // If data-previewing attribute is not present -> we are not in "preview" mode
    if (!isPreviewing) {
      previewBtn.attr('data-previewing', 'false');
      isPreviewing = 'false';
    }

    if (isPreviewing === 'false') {
      previewBtn.attr('data-previewing', 'true');

      let previewText = previewBtn.attr('data-previewing-text');
      previewBtn.text(previewText);
    } else {
      previewBtn.attr('data-previewing', 'false');
      previewBtn.text('Preview');
    }
  }
}
