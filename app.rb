require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'

enable :sessions

get('/') do
    db = SQLite3::Database.new("blog_database.db")
    db.results_as_hash = true
    result = db.execute("SELECT users.username, users.id, blogs.title, blogs.content, blogs.user_id FROM blogs INNER JOIN users")
    p result
    slim(:home,locals:{blogs:result})
end

post("/") do
    db = SQLite3::Database.new("blog_database.db")
end