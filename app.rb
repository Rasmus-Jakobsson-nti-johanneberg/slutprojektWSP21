require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'

enable :sessions

get('/') do
    slim(:home)
end

post("/") do
    db = SQLite3::Database.new("blog_database.db")
    db.results_as_hash = true
    result = db.execute("SELECT title, content FROM blogs")
    p result
end