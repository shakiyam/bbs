require_relative '../app.rb'
require 'rspec'
require 'capybara/rspec'

Capybara.app = Sinatra::Application.new
