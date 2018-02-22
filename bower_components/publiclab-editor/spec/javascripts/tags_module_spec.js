var editor, module;

describe("TagsModule", function() {

  beforeAll(function() {

    fixture = loadFixtures('index.html');

    editor = new PL.Editor({
      textarea: $('.ple-textarea')[0]
    });

    module = new PL.TagsModule(editor, {});

  });


  it("reports key, value, valid", function() {

    expect(module).not.toBeUndefined();
    expect(module.key).toBe('tags');

    expect(module.value()).not.toBe(false);
    expect(module.value()).toBe('');
    module.value('cool,rad');
    expect(module.value()).toBe('cool,rad');

    expect(module.options.name).toBe('tags');
    expect(module.options.required).toBe(false);

    expect(module.valid()).toBe(true);

  });


  it("adds value to 'tags' key of editor.data, instead of overwriting it", function() {

    expect(module.value()).toBe('cool,rad');
    editor.data[module.key] = 'first';
    expect(editor.data.hasOwnProperty(module.key)).toBe(true);
    expect(editor.data[module.key]).toBe('first');
    expect(module.value()).toBe('first,cool,rad');

  });

});
