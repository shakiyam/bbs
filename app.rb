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

DB = Sequel.connect("mysql://#{user}:#{pass}@#{host}:#{port}/#{database}")

DB.run "CREATE TABLE IF NOT EXISTS posts (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  body TEXT,
  created_at DATETIME(6) DEFAULT NOW(6)
)"

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
    link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous"
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
    script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"
    script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js" integrity="sha384-UO2eT0CpHqdSJQ6hJty5KVphtPhzWj9WO1clHTMGa3JDZwrnQq4sF86dIHNDz0W1" crossorigin="anonymous"
    script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js" integrity="sha384-JjSmVgyd0p3pXB1rRibZUAYoIIy6OrQ6VrjIEaFf/nJGzIxFDsf4x0xIM+B07jRM" crossorigin="anonymous"
