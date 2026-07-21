require_relative 'spec_helper'

feature 'Pagination' do
  posts_per_page = 20

  def tagged_message(number)
    format('pagination-test-%02d', number)
  end

  scenario 'First page shows only the newest posts in newest-first order' do
    visit '/'
    (1..(posts_per_page + 1)).each do |i|
      fill_in 'body', with: tagged_message(i)
      click_button 'Post'
    end
    expect(page.all('.list-group-item').count).to eq posts_per_page
    expected = (2..(posts_per_page + 1)).map { |i| tagged_message(i) }.reverse
    expect(page.all('.post-body').map(&:text)).to eq expected
  end

  scenario 'Second page shows the remaining posts' do
    visit '/?page=2'
    expect(page.status_code).to eq 200
    expect(page).to have_content tagged_message(1)
    expect(page).not_to have_content tagged_message(2)
  end

  scenario 'Pagination navigation links to other pages' do
    visit '/'
    expect(page).to have_css 'ul.pagination'
    expect(page).to have_link '2', href: '/?page=2'
    visit '/?page=2'
    expect(page).to have_link '1', href: '/?page=1'
  end

  scenario 'Disabled and current page items are not focusable links' do
    visit '/'
    expect(page).not_to have_link 'Previous'
    expect(page).to have_css 'li.page-item.disabled span.page-link', text: 'Previous'
    expect(page).to have_css 'li.page-item.active span.page-link', text: '1'
    expect(page).to have_link 'Next'
    visit '/?page=999'
    expect(page).not_to have_link 'Next'
    expect(page).to have_css 'li.page-item.disabled span.page-link', text: 'Next'
    expect(page).to have_link 'Previous'
  end

  scenario 'Invalid page parameters fall back to the first page' do
    ['/?page=abc', '/?page=0', '/?page=-1'].each do |path|
      visit path
      expect(page.status_code).to eq 200
      expect(page).to have_content tagged_message(posts_per_page + 1)
    end
  end

  scenario 'Page beyond the last shows an empty list' do
    ['/?page=999', '/?page=99999999999999999999'].each do |path|
      visit path
      expect(page.status_code).to eq 200
      expect(page.all('.list-group-item').count).to eq 0
    end
  end

  scenario 'Long page lists are windowed with ellipses' do
    visit '/'
    (1..165).each do |i|
      fill_in 'body', with: format('window-test-%03d', i)
      click_button 'Post'
    end
    page_numbers = -> { page.all('ul.pagination .page-link').map(&:text) - %w[Previous Next] }
    last_page = Integer(page_numbers.call.last)
    expect(last_page).to be >= 9
    expect(page_numbers.call).to eq ['1', '2', '3', '…', last_page.to_s]
    visit '/?page=4'
    expect(page_numbers.call).to eq ['1', '2', '3', '4', '5', '6', '…', last_page.to_s]
    expect(page).to have_css 'li.page-item.active span.page-link', text: '4'
    expect(page).to have_link '5', href: '/?page=5'
  end
end
