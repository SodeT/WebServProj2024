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

def open_db
  db = SQLite3::Database.new('db/db.sqlite3')
  db.results_as_hash = true
  db
end

def show_error(desc, url)
  session[:error] = desc
  session[:url] = url
  redirect('/error')
end

# Middleware to check permissions
before do
  path = request.path_info
  admin_pattern = '\/admin'
  public_pattern = '\/(login|signup|error)'

  return if path.match(public_pattern) || path == '/'

  db = open_db
  id = session[:id]
  user = db.execute('SELECT * FROM users WHERE id = ?', id).first

  show_error('You have to be logged in to see this content...', '/login') if user.nil?

  if path.match(admin_pattern)
    return if user['permissions'] == permissions['admin']

    show_error('You are not allowed to view this page...', '/play')
  end
end

def get_boosters(user_id)
  db = open_db
  db.execute('SELECT boosters.* FROM boosters JOIN user_booster_rel ON boosters.id = user_booster_rel.booster_id WHERE user_booster_rel.user_id = ?', user_id)
end

def get_cards(user_id)
  db = open_db
  db.execute('SELECT cards.* FROM cards WHERE user_id = ?', user_id)
end

def get_events(user_id)
  db = open_db
  db.execute('SELECT events.* FROM events JOIN user_event_rel ON events.id = user_event_rel.event_id WHERE user_event_rel.user_id = ?', user_id)
end

def get_prices(user_id)
  db = open_db
  db.execute('SELECT prices.* FROM prices WHERE user_id = ?', user_id)
end
