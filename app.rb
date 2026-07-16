require 'logger'
require 'securerandom'
require 'sequel'
require 'sinatra'
require 'slim'

set :bind, '0.0.0.0'
set :show_exceptions, false
set :x_cascade, false

MAX_POST_LENGTH = 1000

def generate_csrf_token
  SecureRandom.urlsafe_base64(24)
end

def secure_compare(a, b)
  return false if a.nil? || b.nil?
  Rack::Utils.secure_compare(a, b)
end

def truncate_for_log(value)
  value&.slice(0, 200)
end

def log_and_halt_csrf(request, reason)
  user_agent = truncate_for_log(request.user_agent) || 'unknown'
  referer = truncate_for_log(request.referer) || 'none'
  settings.logger.warn "CSRF attack blocked (#{reason}): IP=#{request.ip}, " \
                       "User-Agent=#{user_agent}, Referer=#{referer}"
  halt 403, 'Forbidden'
end

def validate_csrf!
  submitted_token = params[:_csrf]
  session_token = session[:csrf_token]
  log_and_halt_csrf(request, 'no session') if session_token.nil?
  log_and_halt_csrf(request, 'missing token') if submitted_token.nil? || submitted_token.empty?
  log_and_halt_csrf(request, 'invalid token') unless secure_compare(submitted_token, session_token)
  session[:csrf_token] = generate_csrf_token
end

def create_post(body)
  body_content = body&.rstrip
  if body_content.nil? || body_content.empty?
    settings.logger.warn "Empty post attempt from #{request.ip}"
    return
  end
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

configure do
  set :sessions, same_site: :strict
  set :session_secret, ENV.fetch('SESSION_SECRET') { SecureRandom.hex(64) }

  set :logger, Logger.new($stderr)
  settings.logger.level = Logger.const_get(ENV.fetch('LOG_LEVEL', 'INFO'))
  settings.logger.formatter = proc do |severity, datetime, _progname, msg|
    "[#{datetime.strftime('%Y-%m-%d %H:%M:%S')}] #{severity}: #{msg}\n"
  end
end

before do
  csp_policy = "default-src 'self'; style-src 'self' https://cdn.jsdelivr.net; " \
               "script-src 'self' https://cdn.jsdelivr.net; frame-ancestors 'none'"
  headers 'Content-Security-Policy' => csp_policy,
          'X-Content-Type-Options' => 'nosniff',
          'X-Frame-Options' => 'DENY',
          'Referrer-Policy' => 'strict-origin-when-cross-origin'
end

user = ENV.fetch('DB_USER')
pass = ENV.fetch('DB_PASSWORD')
host = ENV.fetch('DB_HOST')
port = ENV.fetch('DB_PORT')
database = ENV.fetch('DB_DATABASE')

retries = 0
begin
  DB = Sequel.connect("mysql://#{user}:#{pass}@#{host}:#{port}/#{database}")
  DB.extension(:connection_validator)
  DB.pool.connection_validation_timeout = -1

  # Sequel's mysql adapter only rescues Mysql::Error on close, but ruby-mysql
  # raises IOError when closing an already-dead connection, which would fail
  # the request that triggered the validation
  DB.define_singleton_method(:disconnect_connection) do |conn|
    super(conn)
  rescue IOError, SystemCallError
    nil
  end
  settings.logger.info "Database connected: mysql://#{user}@#{host}:#{port}/#{database}"

  DB.run "CREATE TABLE IF NOT EXISTS posts (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    body TEXT,
    created_at DATETIME(6) DEFAULT NOW(6)
  )"
rescue Sequel::Error => e
  retries += 1
  if retries < 3
    wait_seconds = 1.0 * retries
    settings.logger.error "Database error (attempt #{retries}): #{e.message}. Waiting #{wait_seconds} seconds..."
    sleep wait_seconds
    retry
  else
    settings.logger.fatal "Database connection failed after 3 attempts: #{e.message}"
    exit 1
  end
end

get '/' do
  cache_control :no_cache
  settings.logger.info "GET / from #{request.ip}"
  @csrf_token = session[:csrf_token] ||= generate_csrf_token
  @posts = DB['SELECT body, created_at FROM posts ORDER BY created_at DESC'].all
  slim :index
end

post '/' do
  validate_csrf!
  create_post(params[:body])
  redirect to('/'), 303
end

not_found do
  'Not Found'
end

error do
  error_msg = env['sinatra.error']
  backtrace = error_msg.backtrace&.join("\n")
  settings.logger.error "Application error: #{error_msg.class} - #{error_msg.message}\n#{backtrace}"
  'Application error occurred. Please try again later.'
end
