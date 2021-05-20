require_relative 'model/model.rb'
require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'

enable :sessions
include Model

t = Time.now
i = 0

#Gets the session of the user_id
def get_user_id()
    return session[:id]
end

# Displays Register Page
get('/') do
    slim(:register)
end

#Creates a new user if the length of the username and password is larger than 3 while password_confirm is equal to password.
#Redirects to '/error' if not met with the conditions. Otherwise redirects to '/showlogin'
#
# @param [String] username, The username that the user input
# @param [String] password, The password that the user input
# @param [String] password_confirm, The confirmation that the password the user input before is correct
#
# @see Model#create_user
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

#Attempts to login and updates the session. Stops user from logging in with a cooldown-timer if wrong password is written more than 5 times. 
#
# @param [String] username, The username
# @param [String] password, The password
# @see Model#get_user
# @see Model#login
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

#Displays the error page
get('/error') do
    slim(:error)
end

#Displays created blogs and options to update and delete created blogs. 
#The page can only be accessed if logged in.
#
# @param [Integer] :id, The users ID that has been saved in a session when logged in
# @see Model#get_user_blogs
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

#Displays all blogs that are in the database
#
# see Model#get_blogs
# see Model#get_genres
get("/all_blogs") do
    blogs = get_blogs(params)
    genres = get_genres(params)
    slim(:"my_blogs/all_blogs", locals:{blogs:blogs, genres:genres})
end

#Logs out the user and redirects to '/'
get("/logout") do
    session.destroy()
    redirect("/")
end

#Displays a create form for blogs
#
# @see Model#get_genres
get("/my_blogs/create") do
    result = get_genres(params)
    slim(:"my_blogs/create", locals:{genres:result})
end

#Creates a new blog and redirects to '/my_blogs'
#
# @param [Integer] genre_id, The ID of the genre
# @param [String] title, The title of the new blog
# @param [String] recipe_id, The ID of the new blog
# @param [Integer] :id, The users ID that has been saved in a session when logged in
# @param [String] content, The text in the blog 
# @see Model#create_blog
post("/my_blogs/create") do
    create_blog = create_blog(params)
    redirect("/my_blogs")
end

#Displays an edit form for the recipe, validates the blog the user is editing is owned by the user
#
# @param [Integer] :id, The ID of the blog
# @param [String] username The username
# @see Model#validate_blogs_user
# @see Model#get_blog
# @see Model#get_genres
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

#Updates an existing blog and redirects to '/my_blogs', validates the blog the user is editing is owned by the user
#
# @param [Integer] :id, The ID of the blog
# @param [Integer] genre_id, The ID of the genre
# @param [String] username The username
# @param [String] title, The new title of the blog
# @param [String] content, The new text in the blog
# @see Model#validate_blogs_user
# @see Model#update_recipe
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

#Deletes an existing blog and redirects to '/my_blogs', validates the blog the user is editing is owned by the user
#
# @param [Integer] :id, The ID of the blog
# @param [String] username The username
# @see Model#blog
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

#Displays all blogs that belong to the genre ID
#
# @param [Integer] :id, The ID of the genre
# see Model#get_blogs_with_genre
# see Model#get_genre
get("/genre/:id") do
    blogs = get_blogs_with_genre(params)
    genre = get_genre(params)
    slim(:"my_blogs/all_blogs_genre", locals:{blogs:blogs, genre:genre})
end

#Displays a blog in more detail
#
# @param [Integer] :id, The ID of the blog
# see Model#get_blog
# see Model#get_blog_author
# see Model#get_genre
get("/blog/:id") do
    result = get_blog(params)
    author = get_blog_author(params)
    genre = get_blog_genre(params)
    slim(:"my_blogs/blog_view", locals:{result:result, author:author, genre:genre})
end
