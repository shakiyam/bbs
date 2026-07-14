require_relative 'spec_helper'
require 'net/http'
require 'uri'

feature 'Not Found handling' do
  scenario 'GET to unknown path returns generic 404' do
    response = Net::HTTP.get_response(URI.parse("#{Capybara.app_host}/nonexistent"))
    expect(response.code).to eq '404'
    expect(response.body).to eq 'Not Found'
    expect(response.body).not_to include 'Sinatra'
    expect(response['X-Cascade']).to be_nil
  end
end
