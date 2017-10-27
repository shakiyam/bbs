require_relative 'spec_helper'

feature 'Post message' do
  messages = {
    'English message' => 'Hello, world!',
    'Japanese message' => 'こんにちは、世界！'
  }

  messages.each do |scenario_name, message|
    scenario scenario_name.to_s do
      visit '/'
      fill_in 'body', with: message
      click_button
      expect(page.status_code).to eq 200
      expect(page).to have_content message
    end
  end
end
