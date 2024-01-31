def open_db
  db = SQLite3::Database.new('db/db.sqlite3')
  db.results_as_hash = true
  db
end

# ================ USERS ==================
def new_user(username, pwd_hash, permissions)
  db = open_db
  db.execute('INSERT INTO users (username, pwd_hash, permissions) VALUES (?,?,?)', username, pwd_hash, permissions)
end

def get_user(user_id)
  db = open_db
  db.execute('SELECT * FROM users WHERE id = ?', user_id).first
end

def get_user_by_name(username)
  db = open_db
  db.execute('SELECT * FROM users WHERE username = ?', username).first
end

def add_user_tokens(user_id, amount)
  db = open_db
  db.execute('UPDATE users SET tokens = tokens - ? WHERE id = ?', amount, user_id)
end

# ================ BOOSTERS ==================
def get_boosters
  db = open_db
  data = db.execute('SELECT * FROM boosters ORDER BY price')
end

def get_user_boosters(user_id)
  db = open_db
  db.execute('SELECT boosters.* FROM boosters JOIN user_booster_rel ON boosters.id = user_booster_rel.booster_id WHERE user_booster_rel.user_id = ?', user_id)
end

def get_user_booster_rel(user_id, booster_id)
  db = open_db
  db.execute('SELECT * FROM user_booster_rel WHERE user_id = ? AND booster_id = ?', user_id, booster_id)
end

def get_user_booster_join(user_id, booster_id)
  db = open_db
  db.execute('SELECT users.*, boosters.* FROM users INNER JOIN boosters ON boosters.id = ? WHERE users.id = ?', booster_id, user_id).first
end

def make_user_booster_rel(user_id, booster_id)
  db = open_db
  db.execute('INSERT INTO user_booster_rel (user_id, booster_id) VALUES (?, ?)', user_id, booster_id)
end

# ================ CARDS ==================
def get_cards
  db = open_db
  db.execute('SELECT * FROM cards ORDER BY power')
end

def get_user_cards(user_id)
  db = open_db
  db.execute('SELECT cards.* FROM cards WHERE user_id = ?', user_id)
end

# ================ EVENTS ==================
def get_events
  db = open_db
  db.execute('SELECT * FROM events ORDER BY reward')
end

def get_user_events(user_id)
  db = open_db
  db.execute('SELECT events.* FROM events JOIN user_event_rel ON events.id = user_event_rel.event_id WHERE user_event_rel.user_id = ?', user_id)
end

# ================ PRICES ==================
def get_user_prices(user_id)
  db = open_db
  db.execute('SELECT prices.* FROM prices WHERE user_id = ?', user_id)
end

