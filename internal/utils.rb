enable :sessions
set :session_secret, 'fa5BBHS41ZAdUTQ4R4zk48fZxxz66XkfxutJ4hA3Irn3QiBURqsdJ0110hIIQ5Gt'
# TODO: Don't use hardcoded encryption key in production

permissions = {
  'user' => 0,
  'creator' => 1,
  'admin' => 2
}

def all_of(*paths)
  /(#{paths.join('|')})/
end

def open_db(path)
  db = SQLite3::Database.new(path)
  db.results_as_hash = true
  db
end

# Middleware to check permissions
before do
  path = request.path_info
  admin_pattern = '\/admin'
  login_pattern = '\/(login|signup)'

  return if path.match(login_pattern) || path == '/'

  db = open_db('db/db.sqlite3')
  id = session[:id]
  user = db.execute('SELECT * FROM users WHERE id = ?', id).first

  redirect('/login') if user.nil?

  if path.match(admin_pattern)
    return if user['permissions'] == permissions['admin']

    redirect('/login')
  end
end
