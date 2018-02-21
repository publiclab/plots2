var editor;

describe("Formatter", function() {


  it("converts basic post data into a given format", function() {

    var formatted = new PL.Formatter().convert({
      title: 'My title',
      body: 'My body'
    }, 'publiclab');

    expect(formatted).not.toBeUndefined();
    expect(formatted.title).not.toBeUndefined();
    expect(formatted.body).not.toBeUndefined();

  });


});
