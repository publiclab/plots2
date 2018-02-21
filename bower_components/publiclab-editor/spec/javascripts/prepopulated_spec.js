var editor;

describe("Prepopulated editor", function() {

  beforeEach(function() {

    fixture = loadFixtures('index.html');

  });


  it("loads existing title, body, & tags", function() {

    var title = 'My original title',
        body  = 'My **boring** original post.',
        tags  = 'my,old, tags',
        mainImage = 0; // just a unique identifier

    $('.ple-module-title input').val(title);
    $('.ple-module-body textarea').val(body);
    $('.ple-module-tags input').val(tags);

    editor = new PL.Editor({
      textarea: $('.ple-textarea')[0]
    });

    expect(editor.titleModule.value()).toBe(title);
    expect(editor.richTextModule.value()).toBe(body);
    expect(editor.tagsModule.value()).toBe(tags);

  });


  it("accepts prepopulated values via constructor options, by key", function() {

    var title        = 'My original title',
        body         = 'My **boring** original post.',
        tags         = 'my,old, tags',
        mainImageUrl = 'http://example.com/image.jpg';

    editor = new PL.Editor({
      textarea:     $('.ple-textarea')[0],
      title:        title,
      body:         body,
      tags:         tags,
      mainImageUrl: mainImageUrl
    });

    expect(editor.titleModule.value()        ).toBe(title);
    expect(editor.richTextModule.value()     ).toBe(body);
    expect(editor.tagsModule.value()         ).toBe(tags);
    expect(editor.mainImageModule.options.url).toBe(mainImageUrl);

    var url = editor.mainImageModule.el.find('.ple-drag-drop').css('background-image').replace(/"/g, ''); // phantomjs removes quotation marks
    expect(url).toBe('url(' + mainImageUrl + ')');

    editor.collectData();
    expect(editor.data.title         ).toBe(title);
    expect(editor.data.body          ).toBe(body);
    expect(editor.data.tags          ).toBe(tags);
    expect(editor.data.main_image_url).toBe(mainImageUrl);

  });


});
