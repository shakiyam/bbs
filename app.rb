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
    link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm" crossorigin="anonymous"
  body
    nav.navbar.navbar-expand-lg.navbar-light.bg-light
      .container
        h1.navbar-brand Sample BBS
        a href="https://github.com/shakiyam/bbs" GitHub
    .container
      br
      form method="post"
        textarea.form-control name="body"
        .d-flex.justify-content-end
          button.btn.btn-primary type="submit" Post
      br
      .list-group
        - @posts.all.each do |post|
          .list-group-item
            p.list-group-item-text
              = post[:body]
            footer.list-group-item-text.text-right.text-muted
              = post[:created_at]
      hr
      | &copy; 2016 Shinichi Akiyama
    script src="https://code.jquery.com/jquery-3.2.1.slim.min.js" integrity="sha384-KJ3o2DKtIkvYIK3UENzmM7KCkRr/rE9/Qpg6aAZGJwFDMVNA/GpGFF93hXpG5KkN" crossorigin="anonymous"
    script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.9/umd/popper.min.js" integrity="sha384-ApNbgh9B+Y1QKtv3Rn7W3mgPxhU9K/ScQsAP7hUibX39j7fakFPskvXusvfa0b4Q" crossorigin="anonymous"
    script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js" integrity="sha384-JZR6Spejh4U02d8jOt6vLEHfe/JQGiRRSQQxSfFWpi1MquVdAyjUar5+76PVCmYl" crossorigin="anonymous"
