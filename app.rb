# encoding: utf-8

require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require 'sequel'

set :bind, '0.0.0.0'

user = ENV['DB_ENV_MYSQL_USER']
pass = ENV['DB_ENV_MYSQL_PASSWORD']
host = ENV['DB_PORT_3306_TCP_ADDR']
port = ENV['DB_PORT_3306_TCP_PORT']
database = ENV['DB_ENV_MYSQL_DATABASE']

DB = Sequel.connect("mysql://#{user}:#{pass}@#{host}:#{port}/#{database}")

unless DB.tables.include?(:posts)
  DB.create_table :posts do
    primary_key :id
    String :body, text: true
    DateTime :created_at
  end
end

get '/' do
  cache_control :no_cache
  @posts = DB['SELECT body, created_at FROM posts ORDER BY created_at DESC']
  slim :index
end

post '/' do
  DB[:posts].insert(
    body: params[:body],
    created_at: Time.now.strftime('%Y-%m-%d %H:%M:%S'))
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
    script src="//code.jquery.com/jquery-3.1.1.min.js"
    script src="//maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"
