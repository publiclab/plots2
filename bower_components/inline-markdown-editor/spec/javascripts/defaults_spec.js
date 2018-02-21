describe("Editor defaults", function() {

  var editor, defaultMarkdown;

  beforeEach(function() {
    fixture = loadFixtures('index.html');
    editor = inlineMarkdownEditor({
      replaceUrl: '/wiki/replace/',
      selector: '.markdown'
    });
    defaultMarkdown = editor.options.defaultMarkdown
  });

  it("has a default markdown parser that catches @mentions and #hashtags in PublicLab.org style", function() {
    var html = "@hagit";
    expect(defaultMarkdown(html)).toBe('<p><a href="/profile/hagit">@hagit</a></p>\n');
    html = "@warren and @liz";
    expect(defaultMarkdown(html)).toEqual('<p><a href="/profile/warren">@warren</a> and <a href="/profile/liz">@liz</a></p>\n');
  });

  it("adds hashtag links", function() {
    var html = "#timelapse and #balloon-mapping";
    expect(defaultMarkdown(html)).toEqual('<p><a href="/tag/timelapse">#timelapse</a> and <a href="/tag/balloon-mapping">#balloon-mapping</a></p>\n');
  });

});
