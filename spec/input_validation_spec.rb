require_relative 'spec_helper'

MAX_POST_LENGTH = 1000

feature 'Input validation' do
  scenario 'Post with exactly maximum characters' do
    visit '/'
    message = 'a' * MAX_POST_LENGTH
    fill_in 'body', with: message
    click_button
    expect(page.status_code).to eq 200
    expect(page).to have_content message
  end

  scenario 'Post exceeding maximum characters is truncated' do
    visit '/'
    long_message = 'b' * (MAX_POST_LENGTH + 500)
    expected_message = 'b' * MAX_POST_LENGTH
    fill_in 'body', with: long_message
    click_button
    expect(page.status_code).to eq 200
    expect(page).to have_content expected_message
    expect(page).not_to have_content long_message
  end

  scenario 'Boundary test - one character under limit' do
    visit '/'
    message = 'c' * (MAX_POST_LENGTH - 1)
    fill_in 'body', with: message
    click_button
    expect(page.status_code).to eq 200
    expect(page).to have_content message
  end

  scenario 'Empty post is not processed' do
    visit '/'
    posts_before = page.all('.list-group-item').count
    fill_in 'body', with: ''
    click_button
    expect(page.status_code).to eq 200
    posts_after = page.all('.list-group-item').count
    expect(posts_after).to eq(posts_before)
  end

  scenario 'Whitespace-only post is not processed' do
    visit '/'
    posts_before = page.all('.list-group-item').count
    fill_in 'body', with: '   '
    click_button
    expect(page.status_code).to eq 200
    posts_after = page.all('.list-group-item').count
    expect(posts_after).to eq(posts_before)
  end

  scenario 'HTML and special characters are properly escaped' do
    visit '/'
    malicious_content = '<script>alert("XSS")</script> & "test" \'quotes\''
    fill_in 'body', with: malicious_content
    click_button
    expect(page.status_code).to eq 200
    expect(page.html).to include '&lt;script&gt;'
    expect(page.html).not_to include '<script>'
    expect(page.html).to include '&amp;'
    expect(page.html).to include '&quot;'
    expect(page.html).to include '&#39;'
    expect(page).to have_content 'test'
  end

  scenario 'Newlines are preserved in post' do
    visit '/'
    multiline_content = "Line 1\nLine 2\nLine 3"
    fill_in 'body', with: multiline_content
    click_button
    expect(page.status_code).to eq 200
    post_text = page.first('.list-group-item p').text
    expect(post_text).to match(/Line 1[\r\n] *Line 2[\r\n] *Line 3/)
  end
end
