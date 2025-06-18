require 'sequel'
require 'sinatra'
require 'slim'

set :bind, '0.0.0.0'
set :show_exceptions, false

user = ENV.fetch('DB_USER')
pass = ENV.fetch('DB_PASSWORD')
host = ENV.fetch('DB_HOST')
port = ENV.fetch('DB_PORT')
database = ENV.fetch('DB_DATABASE')

begin
  DB = Sequel.connect("mysql://#{user}:#{pass}@#{host}:#{port}/#{database}")

  DB.run "CREATE TABLE IF NOT EXISTS posts (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    body TEXT,
    created_at DATETIME(6) DEFAULT NOW(6)
  )"
rescue Sequel::Error => e
  p e
  sleep 1
  retry
end

get '/' do
  cache_control :no_cache
  @posts = DB['SELECT body, created_at FROM posts ORDER BY created_at DESC']
  slim :index
end

post '/' do
  body_content = params[:body]&.rstrip
  DB[:posts].insert(body: body_content) unless body_content.nil? || body_content.empty?
  redirect to('/'), 303
end

error do
  error_msg = env['sinatra.error']
  "Application error: #{error_msg.class} - #{error_msg.message}"
end
