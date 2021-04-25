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

#post("/") do
#    db = SQLite3::Database.new("blog_database.db")
#end

get("/login") do
    slim(:login)
end

post('/login') do
    username = params[:username]
    password = params[:password]
    db = SQLite3::Database.new("blog_database.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM users WHERE username = ?",username).first
    pwd = result["pwd"]
    id = result["id"]

    if BCrypt::Password.new(pwd) == password
    
        session[:id] = id
        redirect('/')
    else
        "Fel lösen breh"
    end
end    

get("/register") do
    slim(:register)
end

post("/register") do
    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_confirm]

    if username != "" and password != "" and password_confirm != ""
        if password == password_confirm
            password_digest = BCrypt::Password.create(password)
            db = SQLite3::Database.new('blog_database.db')
            db.execute("INSERT INTO users (username,pwd) VALUES (?,?)",username,password_digest)
            redirect('/')
        else
            "Lösenorden matchade ej!"
        end
    else
        "Var snäll fyll i alla fält!"
    end
end

get('/logout') do 
    if session[:id]
        session.destroy()
    end
    redirect("/")
end

post("/my_blogs") do
    id = session[:id].to_i
    title = params[:title]
    content = params[:content]
    db = SQLite3::Database.new("blog_database.db")
    db.execute("INSERT INTO blogs (title,content,user_id) VALUES (?,?,?)",title,content,id)
    redirect("/my_blogs")
  end

get("/my_blogs") do
    id = session[:id].to_i
    db = SQLite3::Database.new("blog_database.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM blogs WHERE user_id = ?",id)
    slim(:"my_blogs/index",locals:{my_blogs:result}) 
  end
  
post("/my_blogs/:id/delete") do
    id = params[:id].to_i
    db = SQLite3::Database.new("blog_database.db")
    db.execute("DELETE FROM blogs WHERE id = ?",id)
    redirect("/my_blogs")
end
  
get("/my_blogs/:id/edit") do
    id = params[:id].to_i
    db = SQLite3::Database.new("blog_database.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM blogs WHERE id = ?",id).first
    slim(:"my_blogs/edit",locals:{result:result})
end
  
post("/my_blogs/:id/update") do
    id = params[:id].to_i
    title = params[:title]
    content = params[:content]
    user_id = params[:user_id]
    db = SQLite3::Database.new("blog_database.db")
    db.execute("UPDATE blogs SET title=?,content=?,user_id=? WHERE id = ?",title,content,user_id,id)
    redirect("/my_blogs")
end