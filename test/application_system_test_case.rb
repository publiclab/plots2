require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  chromeOptions = %w(no-sandbox disable-dev-shm-usage headless disable-gpu remote-debugging-port=9222)
  caps = Selenium::WebDriver::Remote::Capabilities.chrome("goog:chromeOptions" => {"args" => chromeOptions})
  driven_by :selenium, using: :chrome, screen_size: [1400, 1400], options: { desired_capabilities: caps }

  # https://web.archive.org/web/20170730200309/http://blog.paulrugelhiatt.com/rails/testing/capybara/dropzonejs/2014/12/29/test-dropzonejs-file-uploads-with-capybara.html
  def drop_in_dropzone(file_path, dropzoneSelector)
    existing_inputs = page.all('.fakeFileInput')
    new_input_id = 'fakeFileInput' + (existing_inputs.size + 1).to_s

    # Generate a fake input element
    fake_file_input = page.execute_script <<-JS
      const newInputId = '#{new_input_id}';
      fakeFileInput = window.$('<input/>').attr(
        {id: '#{new_input_id}', class: 'fakeFileInput', type:'file'}
      ).appendTo('body');
      return fakeFileInput;
    JS

    # Attach the file to the fake input element
    attach_file(new_input_id, file_path)

    page.execute_script(<<~JS, fake_file_input)
      ((fakeFileInput) => {
        var dataTransfer = new DataTransfer()
        dataTransfer.items.add(fakeFileInput[0].files[0])

        var fakeDropEvent = new DragEvent('drop')
        var fileToDrop = fakeFileInput[0].files[0]

        // Generate the fake "drop" event
        Object.defineProperty(fakeDropEvent, 'dataTransfer', {
          value: new FakeDataTransferObject(fileToDrop)
        });

        var dropzoneArea = document.querySelector('#{dropzoneSelector}');
        // Transfer the image to the dropzone area
        dropzoneArea.files = dataTransfer.files;
        // Emit the fake "drop" event
        dropzoneArea.dispatchEvent(fakeDropEvent);

        // Generate fake data transfer object
        function FakeDataTransferObject(file) {
          this.dropEffect = 'all';
          this.effectAllowed = 'all';
          this.items = [];
          this.types = ['Files'];
          this.getData = function() {
            return file;
          };
          this.files = [file];
        };
      })(arguments[0])
    JS
  end

  def wait_for_ajax
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop until finished_all_ajax_requests?
    end
  end

  def finished_all_ajax_requests?
      request_count = page.evaluate_script("$.active").to_i
      request_count && request_count.zero?
    rescue Timeout::Error
  end

end
