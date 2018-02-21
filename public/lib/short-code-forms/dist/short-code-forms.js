function replaceFormTag(match, p1, p2, p3) {

  var o = '',
      contents = p3 || p2;
      uniqueId = p3 ? p2 : false;
  uniqueId = uniqueId || "short-code-form-" + parseInt(Math.random() * 10000);
  o += '<form id="' + uniqueId + '" class="well">';

  var innerTag = contents.replace(/\[(\w+):*([\s\w]+)*\]/, function replaceInnerTag(m, pp1, pp2) {

    var placeholder = pp2 || "";
    var input = '';
    input += '<p><input class="form-control" type="text" placeholder="' + placeholder + '" /></p>';
    return input;

  });

  o += innerTag;
  var submit = p1 || "Add";
  o += '<p><button class="btn btn-default" type="submit">' + submit  + '</button></p>\n</form>';

  return o;

}


function shortCodeForm(el) {
  var regex = /\[form:*(\w+)*:*(\w+)*\](\s*\[[^\/].*\]\s*)*\[\/form\]/g;
  var output = el.innerHTML.replace(regex, replaceFormTag)
  return output;
}
