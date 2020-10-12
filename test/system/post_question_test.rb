require "application_system_test_case"

class QuestionTest < ApplicationSystemTestCase
  Capybara.default_max_wait_time = 60

  def setup
    visit '/'

    find(".nav-link.loginToggle").click()
    fill_in("username-login", with: "jeff")
    fill_in("password-signup", with: "secretive")

    find(".login-modal-form #login-button").click()
  end

  test 'viewing question post' do
    visit '/questions/new'

    take_screenshot
  end

  # Test for https://github.com/publiclab/PublicLab.Editor/issues/113
  test 'posting a question' do
    visit '/questions/new'

    find('[placeholder="What\'s your question? Be specific."]').set("Let's test this, shall we?");

    page.execute_script <<-JS
      // Create button element
      var btn = document.createElement('button');
      btn.id = 'copy-to-clipboard';
      btn.textContent = "Click me to copy the text!";

      // Copying to the clipboard requires user's interaction
      btn.addEventListener('click', copyToClipboard);
      document.body.appendChild(btn);

      function copyToClipboard() {
        // Create temporary textarea element
        var tempEl = document.createElement('textarea');
        // Set the value to the textarea
        tempEl.value = `
          1. Post your suggested activity as an Answer below (not a comment).
          2. Other people can Comment on that idea.
          3. Other people can Like (star) that idea.
        `;
        document.body.appendChild(tempEl);
        // Copy the content from the textarea
        tempEl.select();
        document.execCommand('copy');
        document.body.removeChild(tempEl);
      };
    JS

    # Copy text to clipboard
    find('#copy-to-clipboard').click()

    # Paste it in the question's body
    find('.wk-wysiwyg').native.send_keys [:control, 'v']

    find('.ple-publish').click();

    # Wait for note to be published
    wait_for_ajax

    message = find('.alert-success').text
    note_title = find('.note-show h1', match: :first).text

    assert_equal( "Let's test this, shall we?", note_title )
    assert_equal( "×\nResearch note published. Get the word out on the discussion lists!", message )
  end

  test 'post question button is disabled on invalid data' do
    visit '/questions/new'

    find('[placeholder="What\'s your question? Be specific."]').set(' ');
    find('.wk-wysiwyg').set('Question with an empty title!')
    find('.ple-publish').click();

    askQuestionButton = find('.ple-publish.disabled', text: 'Ask')

    assert_equal askQuestionButton.disabled?, true
  end

end
