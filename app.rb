require_relative 'model/model.rb'
require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'

enable :sessions
include Model

t = Time.now
i = 0

def get_user_id()
    return session[:id]
end

get('/') do
    slim(:register)
end

post('/users/new') do

    if validate_username_length(params) == false
        session[:em] = "Ditt användarnamn är för kort. Vänligen försök igen!"
        session[:re] = "/"
        redirect('/error')
    end

    if validate_password(params) == true
        register = create_user(params)
        redirect('/showlogin')
    else
        session[:em] = "Lösenordet är för kort eller matchar ej. Vänligen försök igen!"
        session[:re] = "/"
        redirect('/error')
    end
end

get('/showlogin') do
    slim(:login)
end

post('/login') do
    password = params[:password]
    db = get_database(params)
    if get_user(params) == nil
        session[:em] = "Kontot existerar inte. Vänligen registrera ett konto"
        session[:re] = "/"
        redirect("/error")
    end

    if login(params, i, t) == true
        session[:id] = get_user(params)["id"]
        i = 0 
        redirect('my_blogs')
    elsif login(params, i, t) == false
        session[:em] = "För många fel, dags för en timeout"
        session[:re] = "/showlogin"
        session[:time] = Time.now + (10)
        t = session[:time]
        i +=1 
        redirect("/error")

    else
        session[:em] = "Fel lösenord, försök igen"
        session[:re] = "/showlogin"
        i += 1
        redirect("/error")
    end
end

get('/error') do
    slim(:error)
end

get("/my_blogs") do
    user_id = get_user_id()
        if user_id == 0
            session[:em] = "Du är inte nuvarande inloggad"
            session[:re] = "/"
            redirect("/error")
        else
            result = get_user_blogs(params, user_id)
        end
    slim(:"my_blogs/index", locals:{my_blogs:result})
end

get("/all_blogs") do
    blogs = get_blogs(params)
    genres = get_genres(params)
    slim(:"my_blogs/all_blogs", locals:{blogs:blogs, genres:genres})
end

get("/logout") do
    session.destroy()
    redirect("/")
end

get("/my_blogs/create") do
    result = get_genres(params)
    slim(:"my_blogs/create", locals:{genres:result})
end

post("/my_blogs/create") do
    create_blog = create_blog(params)
    redirect("/my_blogs")
end

get("/my_blogs/:id/edit") do
    if validate_blogs_user(params) == true
        result = get_blog(params)
        result2 = get_genres(params)
        slim(:"my_blogs/edit", locals:{my_blogs:result, genres:result2})
    else
        session[:em] = "Detta är inte din blogg att ändra på!"
        session[:re] = "/showlogin"
        redirect("/error")
    end
end

post("/my_blogs/:id/update") do
    if validate_blogs_user(params) == true
        updated_blog = update_blog(params)
        redirect("/my_blogs")
    else
        session[:em] = "Detta är inte din blogg att ändra på!"
        session[:re] = "/showlogin"
        redirect("/error")
    end
end

post("/my_blogs/:id/delete") do
    if validate_blogs_user(params) == true
        delete = delete_blog(params)
        redirect("/my_blogs")
    else
        session[:em] = "Detta är inte din blogg att ändra på!"
        session[:re] = "/showlogin"
        redirect("/error")
    end
end

get("/genre/:id") do
    blogs = get_blogs_with_genre(params)
    genre = get_genre(params)
    slim(:"my_blogs/all_blogs_genre", locals:{blogs:blogs, genre:genre})
end

get("/blog/:id") do
    result = get_blog(params)
    author = get_blog_author(params)
    genre = get_blog_genre(params)
    slim(:"my_blogs/blog_view", locals:{result:result, author:author, genre:genre})
end
