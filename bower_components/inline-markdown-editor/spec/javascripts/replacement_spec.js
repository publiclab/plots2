describe("Replacement functions", function() {

  it("won't generate an editor for an ambiguous (duplicated) section, where replacement server side could apply to the wrong section", function() {
    fixture = loadFixtures('index.html');
    var html = "Unique text.\n\nDuplicated text.\n\nDuplicated text.";
    $('.markdown').html(html);
    var editor = inlineMarkdownEditor({
      replaceUrl: '/wiki/replace/',
      selector: '.markdown'
    });
    expect($('.inline-edit-form textarea').length).toBe(1);
  });

  it("sends exactly matching original text and 'before' parameters", function(done) {
    fixture = loadFixtures('index.html');
    var html     = "## Headings [with](/links)";
    var new_html = "## Headings [with](/links) and other things";
    $('.markdown').html(html);

    var editor = inlineMarkdownEditor({
      replaceUrl: '/wiki/replace/',
      selector: '.markdown',
      submitSectionForm: submitSectionForm
    });

    function submitSectionForm(e, before, after, o) {
      expect(before).toBe(html);
      expect(after).toBe(new_html);
      expect(before).not.toBe(after);
      done();
    }

    // generate an editor by clicking the pencil button
    $('.inline-edit-btn').click();

    $('.inline-edit-form textarea').html(new_html);

    // trigger a section save:
    $('.inline-edit-form:last button.submit').click();
    expect(editor.options.submitSectionForm).toBe(submitSectionForm);
    expect(editor.options.originalMarkdown).toBe(html);
  });

});
