require 'logger'
require 'securerandom'
require 'sequel'
require 'sinatra'
require 'slim'

set :bind, '0.0.0.0'
set :show_exceptions, false

MAX_POST_LENGTH = 1000

def generate_csrf_token
  SecureRandom.urlsafe_base64(24)
end

def secure_compare(a, b)
  return false if a.nil? || b.nil?
  Rack::Utils.secure_compare(a, b)
end

def log_and_halt_csrf(request, reason)
  user_agent = request.user_agent&.[](0..199) || 'unknown'
  referer = request.referer&.[](0..199) || 'none'
  settings.logger.warn "CSRF attack blocked (#{reason}): IP=#{request.ip}, " \
                       "User-Agent=#{user_agent}, Referer=#{referer}"
  halt 403, 'Forbidden'
end

configure do
  enable :sessions
  default_secret = 'default-secret-key-that-is-long-enough-for-production-use-minimum-64-chars'
  set :session_secret, ENV.fetch('SESSION_SECRET', default_secret)

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
  @csrf_token = session[:csrf_token] ||= generate_csrf_token
  @posts = DB['SELECT body, created_at FROM posts ORDER BY created_at DESC']
  slim :index
end

post '/' do
  submitted_token = params[:_csrf]
  session_token = session[:csrf_token]
  log_and_halt_csrf(request, 'no session') if session_token.nil?
  log_and_halt_csrf(request, 'missing token') if submitted_token.nil? || submitted_token.empty?
  log_and_halt_csrf(request, 'invalid token') unless secure_compare(submitted_token, session_token)
  session[:csrf_token] = generate_csrf_token

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
