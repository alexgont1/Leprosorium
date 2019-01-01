require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
  @db = SQLite3::Database.new 'testforum.db'
  @db.results_as_hash = true
end

before do
  init_db
end

configure do
  init_db
  @db.execute 'CREATE TABLE IF NOT EXISTS Posts 
  (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_date DATE,
    content TEXT
  )'

  @db.execute 'CREATE TABLE IF NOT EXISTS Comments 
  (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_date DATE,
    content TEXT,
    post_id INTEGER
  )'
end

get '/' do
  @results = @db.execute 'SELECT * FROM Posts ORDER BY id DESC'
  erb :index
end

get '/new' do
  erb :new
end

post '/new' do
  content = params[:content]

  if content.length < 1
    @error = 'Type post text'
    return erb :new
  end

  #save post in DB
  @db.execute 'INSERT INTO Posts (content, created_date) VALUES 
  (?, datetime())', [content]

  #open main page
  redirect to '/'
end

#show info about post
get '/details/:post_id' do
  post_id = params[:post_id]

  #get post info
  @results = @db.execute 'SELECT * FROM Posts WHERE id = ?', [post_id]
  #put info about post to @row
  @row = @results[0]

  erb :details
end

#get comment from server
post '/details/:post_id' do
  post_id = params[:post_id]

  content = params[:content]

  #save comment in DB
  @db.execute 'INSERT INTO Comments (content, created_date, post_id) 
  VALUES (?, datetime(), ?)', [content, post_id]

  redirect to ('/details/' + post_id)
end