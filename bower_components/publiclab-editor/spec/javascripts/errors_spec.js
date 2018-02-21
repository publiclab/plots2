var editor;

describe("Errors", function() {


  it("displays given errors", function() {

    fixture = loadFixtures('index.html');

    editor = new PL.Editor({
      textarea: $('.ple-textarea')[0],
      errors: {
        "title": ["can't be blank"]
      }
    });

    expect($('.ple-errors').length).not.toBe(0);
    expect($('.ple-errors .alert').length).toBe(1);
    expect($('.ple-errors p').length).toBe(1);
    expect($('.ple-errors p').text()).toBe("Error: title can't be blank.");

  });

  it("does not display error alert if there are no errors", function() {

    fixture = loadFixtures('index.html');

    $('.ple-errors').html('');

    editor = new PL.Editor({
      textarea: $('.ple-textarea')[0]
    });

    expect($('.ple-errors .alert').length).toBe(0);

  });


});

