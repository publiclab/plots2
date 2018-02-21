describe("MainImageModule", function() {


  it("reports key, value, valid", function() {

    var fixture = loadFixtures('index.html');

    var editor = new PL.Editor({
      textarea: $('.ple-textarea')[0],
      mainImageUrl: 'examples/example.gif'
    });

    var module = new PL.MainImageModule(editor, {});

    expect(module).not.toBeUndefined();
    expect(module.value()).not.toBe(false);
    expect(module.value()).not.toBeUndefined();
    expect(module.key).toBe('main_image_url');

    expect(module.options.name).toBe('main_image');
    expect(module.options.required).toBe(false);

    expect(module.valid()).toBe(true);

    expect(module.value('/image/url.jpg', 34)).toBe('/image/url.jpg');
    expect(editor.data.has_main_image).toBe(true);
    expect(editor.data.image_revision).toBe('/image/url.jpg');
    expect(module.image.src).toBe('file:///image/url.jpg');
    expect(module.options.url).toBe('/image/url.jpg');

  });


  it("makes upload request", function(done) {

    var mainImageUrl = 'http://example.com/image.jpg',
        nid          = 3,
        uid          = 4;

    var fixture = loadFixtures('index.html');

    var editor = new PL.Editor({
      textarea: $('.ple-textarea')[0],
      mainImageModule: {
        nid: nid,
        uid: uid,
        uploadUrl: '/img' //overriding default '/images'
      }
    });

    var module = editor.mainImageModule;

    expect(module.el.find('.progress-bar')).toBeHidden();

    jasmine.Ajax.install();

    var ajaxSpy = spyOn($, "ajax").and.callFake(function(options) {

      if (options.url === '/img') {

        // http://stackoverflow.com/questions/13148356/how-to-properly-unit-test-jquerys-ajax-promises-using-jasmine-and-or-sinon
        var d = $.Deferred();
        d.resolve(options);
        d.reject(options);
        return d.promise();

      }

    });

    function fileuploadsend(e, data) {

      expect(data.url).toBe('/img');
      expect(data.formData.nid).toBe(nid);
      expect(data.formData.uid).toBe(uid);
      expect(module.el.find('.progress-bar')).not.toBeHidden();

    }

    module.el.find('input').bind('fileuploadsend', fileuploadsend);

    function fileuploaddone(e, data) {

      expect(data).not.toBeUndefined();
 
      jasmine.Ajax.uninstall();
      done();
 
    }

    module.el.find('input').bind('fileuploaddone', fileuploaddone);

    // https://github.com/blueimp/jQuery-File-Upload/wiki/API#programmatic-file-upload
    module.el.find('input').fileupload('add', {
      files: [
        new Blob(["fakedata"])
      ]
    });

  });


});
