require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'

enable :sessions

get('/') do
    db = SQLite3::Database.new("blog_database.db")
    db.results_as_hash = true
   # result = db.execute("SELECT * FROM blogs")
   # db.execute("SELECT username FROM users WHERE id = ?",user_id)
   # user_id = db.execute("SELECT user_id FROM blogs")
    p result
    slim(:home,locals:{blogs:result})
end

post("/") do
    db = SQLite3::Database.new("blog_database.db")
end