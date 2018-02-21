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
html lang="ja"
  head
    meta charset="utf-8"
    title Sample BBS
    link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"
  body
    .container style="width: 730px;"
      h1.page-header Sample BBS
      form method="post"
         textarea.form-control name="body"
         button.btn.btn-primary type="submit" Post
      br
      .list-group
        - @posts.all.each do |post|
          .list-group-item
            p.list-group-item-text
              = post[:body]
            footer.list-group-item-text.text-right.text-muted
              = post[:created_at]
    script src="//code.jquery.com/jquery-3.2.1.min.js"
    script src="//maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"
