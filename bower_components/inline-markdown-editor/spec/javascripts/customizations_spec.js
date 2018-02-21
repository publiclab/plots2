describe("Customization functions", function() {

  var editor;

  it("adds new buttons and runs their setup functions", function() {
    var fixture = loadFixtures('index.html');
    var buttonSetupRunCount = 0;
    editor = inlineMarkdownEditor({
      replaceUrl: '/wiki/replace/',
      selector: '.markdown',
      extraButtons: {
        // here we specify a button icon and a function to be run on it
        'fa-book': function exampleBookFunction(element, uniqueId) {
          expect(element).not.toBeUndefined();
          expect(element.length).toBe(1);
          expect($('.inline-edit-btn-' + uniqueId).length).toBe(2); // two because there are two buttons per section
          expect($('.inline-edit-btn-' + uniqueId + '-fa-book').length).toBe(1);
          buttonSetupRunCount += 1;
        }
      }
    });
    expect(buttonSetupRunCount).toBe(editor.editableSections.length);
    expect($('.inline-edit-btns a i.fa-book').length).toBe(editor.editableSections.length);
    expect($('.inline-edit-btn-fa-book').length).toBe(editor.editableSections.length);
  });

});
