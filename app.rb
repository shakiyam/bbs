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
  'Sorry there was a nasty error - ' + env['sinatra.error'].name
end

__END__

@@ index
doctype html
html
  head
    meta charset="utf-8"
    title Sample BBS
    link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.0/css/bootstrap.min.css" integrity="sha384-9aIt2nRpC12Uk9gS9baDl411NQApFmC26EwAOH8WgZl5MYYxFfc+NcPb1dKGj7Sk" crossorigin="anonymous"
  body.d-flex.flex-column style="min-height: 100vh"
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
            footer.text-right.text-muted
              = post[:created_at]
    footer.container
      | &copy; 2016 Shinichi Akiyama
    script src="https://code.jquery.com/jquery-3.5.1.slim.min.js" integrity="sha384-DfXdz2htPH0lsSSs5nCTpuj/zy4C+OGpamoFVy38MVBnE+IbbVYUew+OrCXaRkfj" crossorigin="anonymous"
    script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.0/dist/umd/popper.min.js" integrity="sha384-Q6E9RHvbIyZFJoft+2mJbHaEWldlvI9IOYy5n3zV9zzTtmI3UksdQRVvoxMfooAo" crossorigin="anonymous"
    script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.0/js/bootstrap.min.js" integrity="sha384-OgVRvuATP1z7JjHLkuOU7Xw704+h835Lr+6QL9UvYjZE3Ipu6Tp75j7Bh/kR0JKI" crossorigin="anonymous"
