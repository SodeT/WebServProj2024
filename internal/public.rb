get('/') do
  user_id = session[:id]
  redirect('/play') unless user_id.nil? 
  slim(:home)
end

get('/signup') do
  slim(:'account/signup')
end

post('/signup') do
  session.clear
  username = params[:username]
  password = params[:password]
  password_confirm = params[:password_confirm]
  permissions = params[:permissions].to_i

  show_error("Passwords don't match...", '/signup') if password != password_confirm

  pwd_hash = BCrypt::Password.create(password)
  new_user(username, pwd_hash, permissions)
  user = get_user_by_name(username)
  session[:id] = user['id']
  session[:username] = user['username']

  redirect('/play')
end

get('/login') do
  slim(:'account/login')
end

post('/login') do
  session.clear
  username = params[:username]
  password = params[:password]

  user = get_user_by_name(username)

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
