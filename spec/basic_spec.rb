require_relative 'spec_helper'

feature 'Basic application functionality' do
  scenario 'Basic posting functionality works' do
    visit '/'
    expect(page).to have_content 'Sample BBS'
    expect(page).to have_field 'body'

    ['Hello, world!', 'こんにちは、世界！'].each do |message|
      fill_in 'body', with: message
      click_button 'Post'
      expect(page).to have_content message
    end
  end
end
