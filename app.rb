require 'logger'
require 'sequel'
require 'sinatra'
require 'slim'

set :bind, '0.0.0.0'
set :show_exceptions, false

MAX_POST_LENGTH = 1000

configure do
  set :logger, Logger.new($stderr)
  settings.logger.level = Logger.const_get(ENV.fetch('LOG_LEVEL', 'INFO'))
  settings.logger.formatter = proc do |severity, datetime, _progname, msg|
    "[#{datetime.strftime('%Y-%m-%d %H:%M:%S')}] #{severity}: #{msg}\n"
  end
end

user = ENV.fetch('DB_USER')
pass = ENV.fetch('DB_PASSWORD')
host = ENV.fetch('DB_HOST')
port = ENV.fetch('DB_PORT')
database = ENV.fetch('DB_DATABASE')

begin
  DB = Sequel.connect("mysql://#{user}:#{pass}@#{host}:#{port}/#{database}")
  settings.logger.info "Database connected: mysql://#{user}@#{host}:#{port}/#{database}"

  DB.run "CREATE TABLE IF NOT EXISTS posts (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    body TEXT,
    created_at DATETIME(6) DEFAULT NOW(6)
  )"
rescue Sequel::Error => e
  settings.logger.error "Database error: #{e.message}"
  sleep 1
  retry
end

get '/' do
  cache_control :no_cache
  settings.logger.info "GET / from #{request.ip}"
  @posts = DB['SELECT body, created_at FROM posts ORDER BY created_at DESC']
  slim :index
end

post '/' do
  body_content = params[:body]&.rstrip

  if body_content.nil? || body_content.empty?
    settings.logger.warn "Empty post attempt from #{request.ip}"
  else
    original_length = body_content.length
    if original_length > MAX_POST_LENGTH
      body_content = body_content[0, MAX_POST_LENGTH]
      settings.logger.info "New post: #{body_content.length}/#{original_length} chars from #{request.ip}"
    else
      settings.logger.info "New post: #{body_content.length} chars from #{request.ip}"
    end
    DB[:posts].insert(body: body_content)
    settings.logger.info 'Post created successfully'
  end
  redirect to('/'), 303
end

error do
  error_msg = env['sinatra.error']
  settings.logger.error "Application error: #{error_msg.class} - #{error_msg.message}"
  'Application error occurred. Please try again later.'
end
