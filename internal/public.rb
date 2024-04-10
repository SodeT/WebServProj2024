# Displays the home page but redirects to the /play page if the user is logged in
# it also has a fake casino wheel to lure new users to signup
get('/') do
  user_id = session[:id]
  user = get_user(user_id)
  redirect('/play') unless user.nil?
  fakespin = session['fakespin']
  slim(:home, locals: { fakespin: fakespin })
end

# Displays the signup page
get('/signup') do
  slim(:'account/signup')
end

# Handles the signup page
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

# Displays the login page
get('/login') do
  slim(:'account/login')
end

# Handles the login page
post('/login') do
  session.clear
  username = params[:username]
  password = params[:password]

  show_error('Input is to long...', '/signup') if username.length > 64 || password.length > 64

  user = get_user_by_name(username)
  show_error('Incorrect credentials...', '/login') if user.nil?

  sleep(user['failed_login'].to_i * 30) if user['failed_login'] >= 3

  pwd_hash = user['pwd_hash']

  if BCrypt::Password.new(pwd_hash) == password
    session[:id] = user['id']
    session[:username] = user['username']
    set_user_login_attempts(user['id'], 0)
    redirect('/play')
  end
  set_user_login_attempts(user['id'], user['failed_login'].to_i + 1)
  show_error('Incorrect credentials...', '/login')
end

# Displays an error and has a hyperlink refering the user back to where they came
get('/error') do
  err = session[:error]
  url = session[:url]
  slim(:error, locals: { error: err, url: url })
end

# Handles the fake casino wheel on the home page
post('/fakespin') do
  session['fakespin'] = rand(1_000_000..999_999_999)
  redirect('/')
end
