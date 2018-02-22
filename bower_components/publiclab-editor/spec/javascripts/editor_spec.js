var editor;

describe("Editor", function() {

  beforeAll(function() {

    fixture = loadFixtures('index.html');

    editor = new PL.Editor({
      textarea: $('.ple-textarea')[0]
    });

  });


  it("exists, and has a textarea", function() {

    expect($('.ple-textarea')[0]).not.toBeUndefined();
    expect(editor).not.toBeUndefined();
    expect(editor.options.textarea).not.toBeUndefined();
    expect(editor.options.textarea).toBe($('.ple-textarea')[0]);

  });


  it("counts valid modules and enables publish button", function() {

    expect(editor.titleModule.el.find('input').val()).toBe("");
    expect(editor.titleModule.valid()).toBe(false);

    expect(editor.validate()).toBe(false);

    editor.richTextModule.wysiwyg.setMode('markdown');
    editor.richTextModule.value(""); // empty it
    expect(editor.richTextModule.value()).toBe("");
    expect(editor.richTextModule.valid()).toBe(false);

    editor.titleModule.value("My title");
    editor.richTextModule.value("My content");
    expect(editor.validate()).toBe(true);

  });


  it("sends AJAX request on editor.publish()", function(done) {

    jasmine.Ajax.install();

    editor.options.destination = '/post';

    var ajaxSpy = spyOn($, "ajax").and.callFake(function(options) {

      if (options === editor.options.destination) {

        // http://stackoverflow.com/questions/13148356/how-to-properly-unit-test-jquerys-ajax-promises-using-jasmine-and-or-sinon
        var d = $.Deferred();
        d.resolve(options);
        d.reject(options);
        return d.promise();

      }

    });

    function onPublish(response) {

      expect(response).not.toBeUndefined();
 
      jasmine.Ajax.uninstall();
      done();
 
    }

    editor.publish(onPublish);

  });


});
