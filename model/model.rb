module Model

    # Gets all database
    def get_database(params)
        db = SQLite3::Database.new("db/blog_database.db")
        return db
    end
    
    # Gets all database as a hash
    def get_database_as_hash(params)
        db = SQLite3::Database.new("db/blog_database.db")
        db.results_as_hash = true
        return db
    end
    
    # Validates the blogs user, checks if its the current user
    #
    # @param [Hash] params form data
    # @option params[Integer] id The ID of the blog
    # @option params[Integer] id The ID of the user
    #
    # @return [Boolean] whether an error has occurred
    def validate_blogs_user(params)
        id = params[:id].to_i
        user_id = get_user_id()
        db = get_database(params)
        blogs_user = db.execute("SELECT user_id FROM blogs WHERE id = ?", id)[0][0]
        if user_id == blogs_user
            return true
        else
            return false
        end
    end
    
    # Validates the username length
    #
    # @param [Hash] params form data
    # @option params [String] username The username
    #
    # @return [Boolean] whether an error has occurred
    def validate_username_length(params)
        username = params[:username]
        if username.length <= 3
            return false
        else
            return true
        end
    end

    # Validates the password length and password_confirm length. Checks if password is matching password_confirm
    #
    # @param [Hash] params form data
    # @option params [String] password The password
    # @option params [String] password_confirm The repeat password
    #
    # @return [Boolean] whether an error has occurred
    def validate_password(params)
        password = params[:password]
        password_confirm = params[:password_confirm]
        if password_confirm.length <= 3 or password != password_confirm
            return false
        else
            return true
        end
    end

    # Attempts to create a new user
    #
    # @param [Hash] params form data
    # @option params [String] username The username
    # @option params [String] password The password
    # @option params [String] password_confirm The repeated password
    def create_user(params)
        username = params[:username]
        password = params[:password]
        password_confirm = params[:password_confirm]
        db = get_database(params)
        pwd = BCrypt::Password.create(password)
        db.execute("INSERT INTO users (username,pwd) VALUES (?,?)",username,pwd)
    end
    
    #Attempts to login the user if correct password and username is inserted
    # 
    # @param [Hash] params form data
    # @option params [String] password The users password
    #
    # @return [Integer]
    def login(params, i ,t)
        password = params[:password]
        pwd = get_user(params)["pwd"]
        if BCrypt::Password.new(pwd) == password and Time.now >= t
            return true
        elsif i >= 4
            return false
        end
    end
    
    #Retrieves all row of data from the username
    #
    # @param [String] params form data
    # @option params[String] username The users username
    #
    # @return [Hash]
    # * :id [Integer] The ID of the user
    # * :username [String] The users username
    # * :pw_digest [String] The encrypted password
    def get_user(params)
        username = params[:username]
        db = get_database_as_hash(params)
        result = db.execute("SELECT * FROM users WHERE username = ?",username).first
        return result
    end
    
    #Attempts to retrieve all blogs created by the user
    #
    # @param [Hash] params form data
    # @option params[Integer] id The ID of the user
    # 
    # @return [Hash]
    # * :id [Integer] The id of the blog
    # * :content [String] The text in the blog
    # * :title [String] The title of the blog
    # * :user_id [Integer] The ID of the blogs author
    def get_user_blogs(params, user_id)
        db = get_database_as_hash(params)
        result = db.execute("SELECT * FROM blogs WHERE user_id = ?", user_id)
        return result
    end
    
    #Attempts to get one single blog from the database
    #
    # @param [Hash] params form data
    # @option params [Integer] :id The ID of the blog
    #
    # @return [Hash]
    # * :recipe_id [Integer] The ID of the blog
    # * :content [String] The text of the blog
    # * :title [String] The title of the blog
    # * :user_id [Integer] The ID of the user
    def get_blog(params)
        id = params[:id].to_i
        db = get_database_as_hash(params)
        result = db.execute("SELECT * FROM blogs WHERE id = ?", id).first
        return result
    end
    
    #Attempts to get all blogs from the blogs table
    #
    # @return [Hash]
    # * :id [Integer] The id of the blog
    # * :content [String] The text in the blog
    # * :title [String] The title of the blog
    # * :user_id [Integer] The ID of the blogs author
    def get_blogs(params)
        db = get_database_as_hash(params)
        result = db.execute("SELECT * FROM blogs")
        return result
    end

    #Attempts to get the genre from a blog
    #
    # @param [Hash] params form data
    # @option params [Integer] :id The ID of the blog
    # 
    # @return [Hash]
    # * :name [String] The name of the genre
    # * :id [Integer] The ID of the genre
    def get_genre(params)
        id = params[:id].to_i
        db = get_database_as_hash(params)
        result = db.execute("SELECT * FROM genres WHERE id = ?", id).first
        return result
    end
    
    # Attempts to get all genres from the genres table
    #
    # @return [Hash]
    # * :id [Integer] The ID of the genre
    # * :name [String] The name of the genre
    def get_genres(params)
        db = get_database_as_hash(params)
        result = db.execute("SELECT * FROM genres")
        return result
    end

    #Attempts to get the creators row of data by using the blog's ID
    #
    # @param [Hash] params form data
    # @option params [Integer] :id The ID of the blog
    #
    # @return [Hash]
    # * :id [Integer] The ID of the user
    # * :username [String] The name of the user
    # * :pw_digest [String] The encrypted password
    def get_blog_author(params)
        id = params[:id].to_i
        db = get_database_as_hash(params)
        result = get_blog(params)
        author_id = result["user_id"]
        author = db.execute("SELECT * FROM users WHERE id = ?", author_id).first
        return author
    end
   
    # Attempts to select a blogs genre
   #
   # @param [Hash] params form data
   # @option params [Integer] :id The ID of the blog
   # 
   # @return [Hash]
   # * :name [String] The name of the genre
   # * :id [Integer] The ID of the genre
    def get_blog_genre(params)
        id = params[:id].to_i
        db = get_database_as_hash(params)
        genre_variable = db.execute("SELECT * FROM blogs_genres_relation WHERE blog_id = ?", id)
        genre_id = genre_variable[0]["genre_id"]
        genre = db.execute("SELECT * FROM genres WHERE id = ?", genre_id).first
        return genre
    end
    
    #Attempts to select all blogs that belong to a specific genre
    #
    # @param [Hash] params form data
    # @option params [Integer] :id The ID of the genre
    #
    # @return [Hash]
    # * :recipe_id [Integer] The ID of the blog
    # * :category_id [Integer] The ID of the genre
    # * :content [String] The text in the blog
    # * :title [String] The title of the blog
    # * :user_id [Integer] The users ID    
    def get_blogs_with_genre(params)
        genre_id = params[:id].to_i
        db = get_database_as_hash(params)
        blogs = db.execute("SELECT * FROM blogs_genres_relation INNER JOIN blogs ON blogs_genres_relation.blog_id = blogs.id WHERE blogs_genres_relation.genre_id = ?", genre_id)
        return blogs
    end

    #Attempts to create a new blog by inserting a new row in the blogs table, and a new row in the blogs_genres_relation table
    #
    # @param [Hash] params form data
    # @option params [Integer] genre_id The ID of the genre
    # @option params [String] title, The title of the new blog
    # @option params [Integer] blog_id The ID of the new blog
    # @option params [Integer] user_id, The ID of the user
    # @option params [String] content, The text in the new blog    
    def create_blog(params)
        genre = params[:genre]
        title = params[:title]
        user_id = get_user_id()
        content = params[:content]
        db = get_database_as_hash(params)
        db.execute("INSERT INTO blogs (title, content, user_id) VALUES (?,?,?)", title, content, user_id)
        result = db.execute("SELECT * FROM blogs WHERE content = ?",content).first
        id = result["id"]
        db.execute("INSERT INTO blogs_genres_relation (blog_id, genre_id) VALUES (?,?)", id, genre)
    end
    
    #Attempts to update a row in the blog table
    #
    # @param [Hash] params form data
    # @option params [Integer] :id The ID of the blog
    # @option params [Integer] genre_id, The new ID of the genre
    # @option params [String] content, The new text in the new blog
    # @option params [String] title, The new title of the blog
    def update_blog(params)
        id = params[:id].to_i
        genre = params[:genre]
        title = params[:title]
        content = params[:content]
        db = get_database(params)
        db.execute("UPDATE blogs SET title=?, content=? WHERE id = ?", title, content, id)
        db.execute("DELETE FROM blogs_genres_relation WHERE blog_id = ?", id)
        db.execute("INSERT INTO blogs_genres_relation (blog_id, genre_id) VALUES (?,?)", id, genre)
    end
   
    #Attempts to delete a row from the blogs table
    #
    # @param [Hash] params form data
    # @option params [Integer] :id The ID of the blog
    def delete_blog(params)
        id = params[:id].to_i
        db = get_database(params)
        db.execute("DELETE FROM blogs WHERE id = ?", id)
        db.execute("DELETE FROM blogs_genres_relation WHERE blog_id = ?", id)
    end
end

