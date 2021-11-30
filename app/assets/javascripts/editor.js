class Editor {
  // default parameters:
  //   defaultForm - when the Editor is initialized, there needs to be a default editor form:
  //     1. the main comment form in multi-comment wikis, questions, & research notes.
  //     2. the only editor form on /wiki/new and /wiki/edit
  //   isSingleFormPage - to distinguish between a) pages with multiple comments b) pages like /wiki/new, and /features/new with only one comment form
  //     elements have different ID naming conventions on the two kinds of pages:
  //     1. multi-form pages with multiple comments: #comment-preview-123
  //     2. /wiki/new and /wiki/edit: #preview-main
  constructor(defaultForm = "main", isSingleFormPage = false) {
    this.commentFormID = defaultForm;
    this.isSingleFormPage = isSingleFormPage;
    // this will get deleted in the next few PRs, so collapsing into one line to pass codeclimate
      
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
    // eg. on /wiki/new & /wiki/edit, the preview element is called #preview-main
    const previewIDPrefix = this.isSingleFormPage ? "#preview-" : "#comment-preview-"
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
  
  h2() {
    this.wrap('##', '');
  }

  //debounce function addition
  debounce(func, wait, immediate) {
    let timeout;
    return function () {
      let context = this,
        args = arguments;
      let later = function () {
        timeout = null;
        if (!immediate) func.apply(context, args);
      };
      let callNow = immediate && !timeout;
      clearTimeout(timeout);
      timeout = setTimeout(later, wait);
      if (callNow) func.apply(context, args);
    };
  }

  // this function is dedicated to Don Blair https://github.com/donblair
  attachSaveListener() {
    // remove any other existing eventHandler
    $("textarea").off("input.save"); // input.save is a custom jQuery eventHandler
    const thisEditor = this; // save a reference to this editor, because inside the eventListener, "this" points to e.target
    //implementing a debounce function on save method
    this.textAreaElement.on(
    "input.save",
    debounce(function () {
      //changing styles and text
      //explicitly handling main comment form
      if ($('#text-input-main').is(':focus')) {
       
       $("#comment-form-main .btn-toolbar #save-button-main").find("i").removeClass("fa fa-save").addClass("fas fa-sync fa-spin");
     
       let saving_text = $('<p id="saving-text" style="padding-bottom: 8px"> Saving... </p>');
       $("#comment-form-main .imagebar").prepend(saving_text);
       $("#comment-form-main .imagebar p").not("#saving-text").hide();
        
       //adding delay and revering the styles
        setTimeout(() => {
          $("#comment-form-main .btn-toolbar #save-button-main").find("i").removeClass("fas fa-sync fa-spin").addClass("fa fa-save");
          
          $("#comment-form-main .imagebar").find("#saving-text").remove();
          $("#comment-form-main .imagebar p").not("#saving-text").show();
        }, 400);
    }
    else { 
        //handling other comment forms
        let comment_temp_id = (document.activeElement.parentElement.parentElement.id);
        let imager_bar = (document.activeElement.nextElementSibling.className);

        $('#'+comment_temp_id).find('.btn-toolbar').find(".save-button").find("i").removeClass("fa fa-save").addClass("fas fa-sync fa-spin");

        let saving_text = $('<p id="saving-text" style="padding-bottom: 8px"> Saving... </p>');
        $('#'+comment_temp_id).find('.'+imager_bar).prepend(saving_text);
        $('#'+comment_temp_id).find('.'+imager_bar).find("p").not("#saving-text").hide();

        setTimeout(() => {
          $('#'+comment_temp_id).find('.btn-toolbar').find(".save-button").find("i").removeClass("fas fa-sync fa-spin").addClass("fa fa-save");
          
          $('#'+comment_temp_id).find('.'+imager_bar).find("#saving-text").remove();
          $('#'+comment_temp_id).find('.'+imager_bar).find("p").not("#saving-text").show();
        }, 400);
    }
      thisEditor.save(thisEditor);
      }, 700)
    );
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
    const formIdPrefix = this.isSingleFormPage ? "#form-body-" : "#comment-form-body-";
    const commentFormBody = $(formIdPrefix + this.commentFormID);

    this.previewElement[0].innerHTML = marked.parse(this.textAreaValue);
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
