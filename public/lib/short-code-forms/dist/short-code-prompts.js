function shortCodePrompt(el, options) {

  options = options || {};

  options.regex = options.regex || /\[prompt:(\w*):*([\s\w]*):*(\w*)\]/g;

  options.replacePrompt = options.replacePrompt || function replacePrompt(match, p1, p2, p3) {

    var o = '',
        placeholder = p2 || "",
        uniqueId = p3 || "short-code-form-" + parseInt(Math.random() * 10000),
        submit = "Add";
    o += '<form id="' + uniqueId + '" class="well">';
    if (p1 == 'text')      o += '<p><input class="form-control" type="text" placeholder="' + placeholder + '" /></p>';
    if (p1 == 'paragraph') o += '<p><textarea class="form-control" placeholder="' + placeholder + '" /></textarea></p>';
    o += '<p><button class="btn btn-default" type="submit">' + submit  + '</button> <span class="prompt-message"></span></p>\n</form>';

    function interceptForm(e) {
      e.preventDefault();
      var input = $('#' + uniqueId + ' .form-control').val();
      submitForm(e, match, input + '\n\n' + match);
      var message = $('#' + uniqueId + ' .prompt-message');
      message.html('<i class="fa fa-circle-o-notch fa-spin" style="color:#bbb;"></i>');
      return false;
    }

    // if passed as option, may need to bind to local scope, or forms will get crossed?
    // we had this set-able via options but then there was just a single one for all forms, which doesn't work
    //options.onComplete = options.onComplete || function onComplete(response) {
    function onComplete(response) {
      var message = $('#' + uniqueId + ' .prompt-message');
      if (response === 'true' || response === true) {
        message.html('<i class="fa fa-check" style="color:green;"></i>');
        var input = $('#' + uniqueId + ' .form-control').val();
        var form = $('#' + uniqueId).before('<p>' + input + '</p>');
        $('#' + uniqueId + ' .form-control').val('');
      } else {
        message.html('There was an error. Do you need to <a href="/login">log in</a>?');
      }
    }

    // if passed as option, may need to bind to local scope?
    // same problem as onComplete
    // options.onFail = options.onFail || function onFail(response) {
    function onFail(response) {
      var message = $('#' + uniqueId + ' .prompt-message');
      message.html('There was an error. Do you need to <a href="/login">log in</a>?');
    }

    // to be attached to on each matching form:
    // same problem as onComplete
    // options.submitForm = options.submitForm || function submitPromptForm(e, before, after) {
    function submitForm(e, before, after) {
 
      options.submitUrl = options.submitUrl || '/';
 
      $.post(options.submitUrl, {
        before: before,
        after: after
      })
       .done(onComplete)
       .fail(onFail);
 
    }

    setTimeout(function timeOut() {
      // using jQuery here: 
      $('#' + uniqueId).submit(interceptForm);
    }, 0);

    return o;

  }

  var output = el.innerHTML.replace(options.regex, options.replacePrompt);

  return output;

}
