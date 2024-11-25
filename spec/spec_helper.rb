require 'capybara/mechanize'
require 'capybara/rspec'

Capybara.app = proc do
  ['200', { 'Content-Type' => 'text/html' }, ['This is a dummy app.']]
end
Capybara.default_driver = :mechanize
Capybara.app_host = 'http://localhost:4567/'
Capybara.run_server = false
