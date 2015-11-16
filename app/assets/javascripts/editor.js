$E = {
  initialize: function(args) {
    args = args || {}
    args['textarea'] = args['textarea'] || 'text-input'
    $E.textarea = $('#'+args['textarea'])
    $E.title = $('#title')
    args['preview'] = args['preview'] || 'preview'
    $E.preview = $('#'+args['preview'])
    $E.textarea.bind('input propertychange',$E.save)

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

  },
  is_editing: function() {
    return ($E.textarea[0].selectionStart == 0 && $E.textarea[0].selectionEnd == 0)
  },
  // wraps currently selected text in textarea with strings a and b
  wrap: function(a,b,args) {
    var len = $E.textarea.val().length;
    var start = $E.textarea[0].selectionStart;
    var end = $E.textarea[0].selectionEnd;
    var sel = $E.textarea.val().substring(start, end);
    if (args && args['fallback']) { // an alternative if nothing has been selected, but we're simply dealing with an insertion point
      sel = args['fallback']
    }
    var replace = a + sel + b;
    if (args && args['newline']) {
      if ($E.textarea[0].selectionStart > 0) replace = "\n"+replace
      replace = replace+"\n\n"
    }
    $E.textarea.val($E.textarea.val().substring(0,start) + replace + $E.textarea.val().substring(end,len));
  },
  bold: function() {
    $E.wrap('**','**')
  },
  italic: function() {
    $E.wrap('_','_')
  },
  link: function(uri) {
    uri = uri || prompt('Enter a URL')
    $E.wrap('[',']('+uri+')')
  },
  image: function(src) {
    src = src || prompt('Enter an image URL')
    $E.wrap('\n![',']('+src+')\n')
  },

  h1: function() {
    $E.wrap('#','')
  },
  h2: function() {
    $E.wrap('##','')
  },
  h3: function() {
    $E.wrap('###','')
  },
  h4: function() {
    $E.wrap('####','')
  },
  h5: function() {
    $E.wrap('#####','')
  },
  h6: function() {
    $E.wrap('######','')
  },
  h7: function() {
    $E.wrap('#######','')
  },
  // this function is dedicated to Don Blair https://github.com/donblair
  save: function() {
    localStorage.setItem('plots:lastpost',$E.textarea.val())
    localStorage.setItem('plots:lasttitle',$E.title.val())
  },
  recover: function() {
    $E.textarea.val(localStorage.getItem('plots:lastpost'))
    $E.title.val(localStorage.getItem('plots:lasttitle'))
  },
  apply_template: function(template) {
    if ($E.textarea.val() != "") $E.textarea.val($E.textarea.val()+'\n\n'+$E.templates[template])
    else $E.textarea.val($E.templates[template])
  },
  templates: {
    'default': "###What I want to do\n\n###My attempt and results\n\n###Questions and next steps\n\n###Why I'm interested",
    'support': "###Details about the problem\n\n###A photo or screenshot of the setup",
    'event': "###Event details\n\nWhen, where, what\n\n###Background\n\nWho, why",
    'oiltestkit': "##Reflections on the Alpha Oil Testing Kit\n\n###What was tested\n\nWhen, where, what\n\n###Things that went well\n\n###Challenges encountered\n\n###Suggestions to improve the tool\n\n\n",
    'question': "###What I want to do or know\n\n###Background story"
  },
  previewing: false,
  generate_preview: function(id,text) {
    $('#'+id)[0].innerHTML = marked(text)
  },
  toggle_preview: function() {
    $E.preview[0].innerHTML = marked($E.textarea.val());
    $('.preview-btn').button('toggle');
    $E.previewing = !$E.previewing
    if ($E.previewing) $('.preview-btn').button('previewing');
    else $('.preview-btn').button('reset');
    $('#dropzone').toggle()
    $E.preview.toggle();
  }
}
