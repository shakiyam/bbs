require_relative 'spec_helper'
require 'net/http'
require 'uri'

feature 'CSRF Protection' do
  scenario 'POST with valid CSRF token' do
    visit '/'
    fill_in 'body', with: 'Valid CSRF test message'
    click_button
    expect(page.status_code).to eq 200
    expect(page).to have_content 'Valid CSRF test message'
  end

  scenario 'POST without session' do
    response = Net::HTTP.post_form(URI.parse("#{Capybara.app_host}/"), 'body' => 'Missing token test')
    expect(response.code).to eq '403'
    expect(response.body).to include 'Forbidden'
  end

  scenario 'POST with empty CSRF token' do
    visit '/'
    fill_in 'body', with: 'Empty token test'
    find('input[name="_csrf"]', visible: false).set('')
    expect { click_button }.to raise_error(/403/)
  end

  scenario 'POST with invalid CSRF token' do
    visit '/'
    fill_in 'body', with: 'Invalid token test'
    find('input[name="_csrf"]', visible: false).set('invalid_token_12345')
    expect { click_button }.to raise_error(/403/)
  end

  scenario 'CSRF token rotation after successful POST' do
    visit '/'
    first_token = find('input[name="_csrf"]', visible: false).value
    fill_in 'body', with: 'Token rotation test'
    click_button
    expect(page.status_code).to eq 200
    visit '/'
    second_token = find('input[name="_csrf"]', visible: false).value
    expect(first_token).not_to eq second_token
  end

  scenario 'POST with reused CSRF token' do
    visit '/'
    csrf_token = find('input[name="_csrf"]', visible: false).value
    fill_in 'body', with: 'First POST'
    click_button
    expect(page.status_code).to eq 200
    fill_in 'body', with: 'Second POST with old token'
    find('input[name="_csrf"]', visible: false).set(csrf_token)
    expect { click_button }.to raise_error(/403/)
  end
end
