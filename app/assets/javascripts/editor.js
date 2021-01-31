class Editor {
  // default parameters reference the IDs of:
  //   1. main comment form in multi-comment wikis, questions, & research notes.
  //   2. the only editor form on /wiki/new and /wiki/edit
  constructor(textarea = "text-input", preview = "comment-preview-main", title = "title") {
    this.textarea = textarea;
    this.preview = preview;
    this.title = title;
    this.previewing = false;
    this.previewed = false;
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
      highligh(code, lang) {
        if (lang === 'js') {
          return highlighter.javascript(code);
        }
        return code;
      }
    });
  }
  setState(textarea = 'text-input', preview = 'comment-preview-main', title = 'title') {
    $E.title = $('#' + title + 'title'); // not sure why this exists? seems like $E.title is always #title
    $E.textarea = $('#' + textarea);
    $E.textarea.bind('input propertychange', $E.save);
    $E.preview = $('#' + preview);
  }
  // code seems unused, commenting out for now.
  // is_editing() {
  //   return ($E.textarea[0].selectionStart == 0 && $E.textarea[0].selectionEnd == 0)
  // };
  refresh() {
    // textarea
    $E.textarea = ($D.selected).find('textarea').eq(0);
    $E.textarea.bind('input propertychange',$E.save);
    // preview
    $E.preview = ($D.selected).find('.comment-preview').eq(0);
  }
  isMultiFormPage(url) {
    // this RegEx matches three different pages where only one editor form is present (instead of multiple comment forms):
    //   1. /wiki/new
    //   2. /wiki/{wiki name}/edit
    //   3. /features/new
    const singleFormPath = RegExp(/\/(wiki|features)(\/[^\/]+\/edit|\/new)/);
    return !singleFormPath.test(url);
  }
  // wraps currently selected text in textarea with strings a and b
  wrap(a, b, args) {
    // we only refresh $E's values if we are on a page with multiple comments
    if (this.isMultiFormPage(window.location.pathname)) { this.refresh(); }

    const selectionStart = $E.textarea[0].selectionStart;
    const selectionEnd = $E.textarea[0].selectionEnd;
    const fallBackParameterExists = args && args['fallback'];
    const selection = fallBackParameterExists ? args['fallback'] : $E.textarea.val().substring(selectionStart, selectionEnd); // fallback if nothing has been selected, and we're simply dealing with an insertion point

    const newlineParameterExists = args && args['newline'];
    const newText = a + selection + b; // ie. ** + selection + ** (wrapping selection in bold)
    if (newlineParameterExists) { newText = newText + "\n\n"; }
    const selectionStartsMidText = $E.textarea[0].selectionStart > 0;
    if (newlineParameterExists && selectionStartsMidText) { newText = "\n" + newText; }

    const textLength = $E.textarea.val().length;
    const textBeforeSelection = $E.textarea.val().substring(0,selectionStart);
    const textAfterSelection = $E.textarea.val().substring(selectionEnd, textLength);
    $E.textarea.val(textBeforeSelection + newText + textAfterSelection);
  }
  bold() {
    $E.wrap('**','**')
  }
  italic() {
    $E.wrap('_','_')
  }
  link(uri) {
    uri = prompt('Enter a URL');
    if (uri === null) { uri = ""; }
    $E.wrap('[', '](' + uri + ')');
  }
  image(src) {
    $E.wrap('\n![',']('+src+')\n')
  }
  // these header formatting functions are not used anywhere, so commenting them out for now to pass codeclimate:

  // h1() {
  //   $E.wrap('#','')
  // }
  h2() {
    $E.wrap('##','')
  }
  // h3() {
  //   $E.wrap('###','')
  // }
  // h4() {
  //   $E.wrap('####','')
  // }
  // h5() {
  //   $E.wrap('#####','')
  // }
  // h6() {
  //   $E.wrap('######','')
  // }
  // h7() {
  //   $E.wrap('#######','')
  // }
  // this function is dedicated to Don Blair https://github.com/donblair
  save() {
    localStorage.setItem('plots:lastpost',$E.textarea.val())
    localStorage.setItem('plots:lasttitle',$E.title.val())
  }
  recover() {
    $E.textarea.val(localStorage.getItem('plots:lastpost'))
    $E.title.val(localStorage.getItem('plots:lasttitle'))
  }
  apply_template(template) {
    if($E.textarea.val() == ""){
      $E.textarea.val($E.templates[template])
    }else if(($E.textarea.val() == $E.templates['event']) || ($E.textarea.val() == $E.templates['default']) || ($E.textarea.val() == $E.templates['support'])){
        $E.textarea.val($E.templates[template])
    }else{
      $E.textarea.val($E.textarea.val()+'\n\n'+$E.templates[template])
    }
  }
  generate_preview(id,text) {
    $('#'+id)[0].innerHTML = marked(text)
  }
  toggle_preview() {
    let previewBtn;
    let dropzone;
    // if the element is part of a multi-comment page,
    // ensure to grab the current element and not the other comment element.
    previewBtn = $(this.textarea.context).find('.preview-btn');
    dropzone = $(this.textarea.context).find('.dropzone');

    $E.preview[0].innerHTML = marked($E.textarea.val());
    $E.preview.toggle();
    dropzone.toggle();

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