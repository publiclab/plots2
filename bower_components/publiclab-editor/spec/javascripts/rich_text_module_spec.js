var editor, module;

describe("RichTextModule", function() {

  beforeAll(function() {

    var fixture = loadFixtures('index.html');

    editor = new PL.Editor({
      textarea: $('.ple-textarea')[0]
    });

    module = new PL.RichTextModule( editor, { textarea: editor.options.textarea });

  });


  it("reports key, value, valid", function() {

    expect(module).not.toBeUndefined();
    expect(module.value()).not.toBe(false);
    expect(module.value()).not.toBeUndefined();
    expect(module.key).toBe('body');

    expect(module.options.name).toBe('body');
    expect(module.options.required).toBe(true);

    expect(module.valid()).toBe(true);
    //_module.height = function() {

  });

  it("sets and reports value regardless of whether it's in markdown or wysiwyg mode", function() {

    module.setMode('markdown');
    module.value('Test text');
    expect(module.value()).toBe('Test text');

    module.setMode('wysiwyg');
    expect($(module.editable).html()).toBe('<p>Test text</p>');
    expect(module.value()).toBe('Test text');

    module.value('Test text 2');
    expect(module.value()).toBe('Test text 2');

    module.setMode('markdown');
    module.value('## Test title');
    expect(module.value()).toBe('## Test title');

    module.setMode('html');
    expect($(module.textarea).val()).toBe('<h2 id="test-title">Test title</h2>');

    module.setMode('markdown');
    expect($(module.textarea).val()).toBe('## Test title');

  });


  it("recognizes @callouts and #hashtags and #hash-tags", function() {

    module.setMode('markdown');
    module.value('Hello, @jeff!');
    // shouldn't actually add markdown link around a callout:
    expect(module.value()).not.toContain('[@jeff](/profile/jeff)');

    module.setMode('wysiwyg');
    expect(module.html()).toContain('<a href="/profile/jeff">@jeff</a>');

    module.value('Hi, #robots are cool!');
    expect(module.html()).toContain('<a href="/tag/robots">#robots</a>');

    module.value('#balloon-mapping');
    expect(module.html()).toContain('<a href="/tag/balloon-mapping">#balloon-mapping</a>');

  });


  it("accepts customized authors method as constructor option for @callouts", function() {

    module = new PL.RichTextModule( editor, { 
      textarea: editor.options.textarea,
      authors: function(value, done) {
        done([
          { value: '@kirk',    text: '@kirk; 1 note'    },
          { value: '@spock',   text: '@spock; 2 notes'  },
          { value: '@uhura',   text: '@uhura; 4 notes'  },
          { value: '@bones',   text: '@bones; 1 note'   },
          { value: '@sulu',    text: '@sulu; 5 notes'   },
          { value: '@checkov', text: '@checkov; 1 note' }
        ]);
      }
    });

    module.options.authors('', function(list) {
      expect(list[0].value).toBe('@kirk');
    })

  });


});
