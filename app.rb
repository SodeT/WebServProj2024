require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'

enable :sessions
set :session_secret, 'random-key'

def all_of(*paths)
    return /(#{paths.join("|")})/
end

def open_db(path)
    db = SQLite3::Database.new(path)
    db.results_as_hash = true
    return db
end

before(all_of("/play", "/boosters", "/cards", "/events", "/prices")) do
    db = open_db("db/db.sqlite3")
    id = session[:id]

    result = db.execute("SELECT COUNT(1) FROM users WHERE id = ?", id).first

    if result == nil
        redirect("/login")
    end
end

get('/')  do
    slim(:home)
end

get('/signup') do 
    slim(:signup)
end

post('/signuppost') do
    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_confirm]
    permissions = params[:permissions].to_i
  
    if password != password_confirm
      return "Passwords don't match..."
    end
  
    pwd_hash = BCrypt::Password.create(password)
    db = open_db("db/db.sqlite3")
    db.execute("INSERT INTO users (username, pwd_hash, permissions, tokens) VALUES (?,?,?,?)", username, pwd_hash, permissions, 0)
    user = db.execute("SELECT * FROM users WHERE username = ?", username).first
    session[:id] = user["id"]
    session[:username] = user["username"]

    redirect("/play")
end
  
get('/login') do
    slim(:login)
end
  
post('/loginpost') do
    db = open_db("db/db.sqlite3")
    username = params[:username]
    password = params[:password]
  
    user = db.execute("SELECT * FROM users WHERE username = ?", username).first
  
    pwd_hash = user["pwd_hash"]
  
    if BCrypt::Password.new(pwd_hash) == password
      session[:id] = user["id"]
      session[:username] = user["username"]
      redirect('/play')
    else
      "Fel lösenord..."
    end
end

get('/play') do
    slim(:play)
end

