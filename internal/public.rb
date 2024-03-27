get('/') do
  user_id = session[:id]
  user = get_user(user_id)
  redirect('/play') unless user.nil? 
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

  if username.length > 64 || password.length > 64 || password_confirm.length > 64
    show_error('Input is to long...', '/signup')
  end

  show_error('Username and password cannot be empty...', '/signup') if password.empty? || username.empty?
  show_error("Passwords don't match...", '/signup') if password != password_confirm
  show_error('Username is already taken...', '/signup') unless get_user_by_name(username).nil?

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

  if username.length > 64 || password.length > 64 
    show_error('Input is to long...', '/signup')
  end

  user = get_user_by_name(username)
  show_error('Incorrect credentials...', '/login') if user.nil?

  pwd_hash = user['pwd_hash']

  if BCrypt::Password.new(pwd_hash) == password
    session[:id] = user['id']
    session[:username] = user['username']
    redirect('/play')
  end
  show_error('Incorrect credentials...', '/login')
end

get('/error') do
  err = session[:error]
  url = session[:url]
  slim(:error, locals: { error: err, url: url })
end
