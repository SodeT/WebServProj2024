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

  return "Passwords don't match..." if password != password_confirm

  pwd_hash = BCrypt::Password.create(password)
  db = open_db('db/db.sqlite3')
  db.execute('INSERT INTO users (username, pwd_hash, permissions, tokens) VALUES (?,?,?,?)', username, pwd_hash, permissions, 0)
  user = db.execute('SELECT * FROM users WHERE username = ?', username).first
  session[:id] = user['id']
  session[:username] = user['username']

  redirect('/play')
end

get('/login') do
  slim(:'account/login')
end

post('/login') do
  db = open_db('db/db.sqlite3')
  username = params[:username]
  password = params[:password]

  user = db.execute('SELECT * FROM users WHERE username = ?', username).first

  pwd_hash = user['pwd_hash']

  if BCrypt::Password.new(pwd_hash) == password
    session[:id] = user['id']
    session[:username] = user['username']
    redirect('/play')
  else
    'Fel lösenord...'
  end
end

