get('/') do
  slim(:home)
end

get('/signup') do
  slim(:'account/signup')
end

post('/signup') do
  username = params[:username]
  password = params[:password]
  password_confirm = params[:password_confirm]
  permissions = params[:permissions].to_i

  show_error("Passwords don't match...", '/signup') if password != password_confirm

  pwd_hash = BCrypt::Password.create(password)
  db = open_db
  db.execute('INSERT INTO users (username, pwd_hash, permissions, tokens) VALUES (?,?,?,?)', username, pwd_hash, permissions, 100)
  user = db.execute('SELECT * FROM users WHERE username = ?', username).first
  session[:id] = user['id']
  session[:username] = user['username']

  redirect('/play')
end

get('/login') do
  slim(:'account/login')
end

post('/login') do
  db = open_db
  username = params[:username]
  password = params[:password]

  user = db.execute('SELECT * FROM users WHERE username = ?', username).first

  pwd_hash = user['pwd_hash']

  if BCrypt::Password.new(pwd_hash) == password
    session[:id] = user['id']
    session[:username] = user['username']
    redirect('/play')
  end
  show_error('Incorrect password...', '/login')
end

get('/error') do
  err = session[:error]
  url = session[:url]
  slim(:error, locals: { error: err, url: url })
end
