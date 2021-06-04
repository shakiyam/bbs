require 'sequel'
require 'sinatra'
require 'sinatra/reloader'
require 'slim'

set :bind, '0.0.0.0'

user = ENV['DB_USER']
pass = ENV['DB_PASSWORD']
host = ENV['DB_HOST']
port = ENV['DB_PORT']
database = ENV['DB_DATABASE']

begin
  DB = Sequel.connect("mysql://#{user}:#{pass}@#{host}:#{port}/#{database}")

  DB.run "CREATE TABLE IF NOT EXISTS posts (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    body TEXT,
    created_at DATETIME(6) DEFAULT NOW(6)
  )"
rescue Sequel::Error
  sleep 1
  retry
end

get '/' do
  cache_control :no_cache
  @posts = DB['SELECT body, created_at FROM posts ORDER BY created_at DESC']
  slim :index
end

post '/' do
  DB[:posts].insert(body: params[:body])
  redirect to('/'), 303
end

error do
  "Sorry there was a nasty error - #{env['sinatra.error'].name}"
end

__END__

@@ index
doctype html
html
  head
    meta charset="utf-8"
    meta name="viewport" content="width=device-width, initial-scale=1"
    link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.1/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-+0n0xVW2eSR5OomGNYDnhzAbDsOXxcvSN1TPprVMTNDbiYZCxYbOOl7+AMvyTG2x" crossorigin="anonymous"
    title Sample BBS
  body.d-flex.flex-column.min-vh-100
    nav.navbar.navbar-expand-lg.navbar-light.bg-light
      .container
        h1.navbar-brand Sample BBS
        a href="https://github.com/shakiyam/bbs" GitHub
    main.container.mb-auto
      br
      form method="post"
        textarea.form-control name="body"
        .d-flex.justify-content-end
          button.btn.btn-primary type="submit" Post
      br
      .list-group
        - @posts.all.each do |post|
          .list-group-item
            p
              = post[:body]
            footer.text-end.text-muted
              = post[:created_at]
    footer.container
      | &copy; 2016 Shinichi Akiyama
    script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.1/dist/js/bootstrap.bundle.min.js" integrity="sha384-gtEjrD/SeCtmISkJkNUaaKMoLD0//ElJ19smozuHV6z3Iehds+3Ulb9Bn9Plx0x4" crossorigin="anonymous"
