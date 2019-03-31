require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  chromeOptions = %w(--headless  --disable-gpu --no-sandbox --remote-debugging-port=9222)
  caps = Selenium::WebDriver::Remote::Capabilities.chrome("chromeOptions" => {"args" => chromeOptions})
  driven_by :selenium, using: :chrome, screen_size: [1400, 1400], options: { desired_capabilities: caps }
end
