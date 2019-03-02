require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :chrome, screen_size: [1400, 1400]
  argument = { arg: ["headless", "disable-gpu", "no-sandbox", "disable-dev-shm-usage"] }

  Selenium::WebDriver::Chrome::Options.new.add_argument(argument)
end
