describe("Editor", function() {

  var editor;

  beforeEach(function() {
    fixture = loadFixtures('index.html');
    editor = inlineMarkdownEditor({
      replaceUrl: '/wiki/replace/',
      selector: '.markdown'
    });
  });

  it("exists & initializes", function() {
    expect(editor).not.toBeUndefined();
    expect(editor.options).not.toBeUndefined();
    expect(editor.element).not.toBeUndefined();
    expect(editor.sections).not.toBeUndefined();
  });

  it("correctly assesses isEditable (default)", function() {
    var isEditable = editor.options.isEditable
    expect(isEditable('<p></p>')).toBe(false);
    expect(isEditable('****')).toBe(false);
    expect(isEditable('----')).toBe(false);
    expect(isEditable('Just a simple string.')).toBe(true);
  });

  it("correctly assesses isEditable when comparing to original full text; no duplicates", function() {
    var isEditable = editor.options.isEditable
    expect(isEditable('phrase', 'One phrase, two phrase.')).toBe(false);
    expect(isEditable('One', 'One phrase, two phrase.')).toBe(true);
  });

  it("generates the right number of sections", function() {
    expect(editor.sections.length).toBe(8);
    expect($('.inline-section').length).toBe(8);
    expect(editor.sections[0]).toBe('');
    expect(editor.editableSections.length).toBe(5);
    expect($('.inline-edit-form').length).toBe(5);
    expect($('.inline-edit-form textarea').length).toBe(5);
  });

  it("correctly splits up sections", function() {
    expect(editor.sections[0]).toBe("");
    expect(editor.sections[1]).toBe("### Hello, World");
    expect(editor.sections[2]).toBe("This is a paragraph.");
    expect(editor.sections[3]).toBe("* this\n* is\n* a\n* list");
    expect(editor.sections[4]).toBe("****");
    expect(editor.sections[5]).toBe("### Hello again, World");
    expect(editor.sections[6]).toBe("### Hello finally");
    expect(editor.sections[7]).toBe("");
  });

});
