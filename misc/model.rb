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

# FIXME: This function is probubually used incorrectly
def add_user_tokens(user_id, amount)
  db = open_db
  db.execute('UPDATE users SET tokens = tokens - ? WHERE id = ?', amount, user_id)
end

# ================ BOOSTERS ==================
def get_boosters
  db = open_db
  db.execute('SELECT * FROM boosters ORDER BY price')
end

def get_booster(booster_id)
  db = open_db
  db.execute('SELECT * FROM boosters WHERE id = ?', booster_id).first
end

def get_user_boosters(user_id)
  db = open_db
  db.execute(
    'SELECT boosters.* FROM boosters JOIN user_booster_rel ON boosters.id = user_booster_rel.booster_id WHERE user_booster_rel.user_id = ?', user_id
  )
end

def get_user_booster_rel(user_id, booster_id)
  db = open_db
  db.execute('SELECT * FROM user_booster_rel WHERE user_id = ? AND booster_id = ?', user_id, booster_id)
end

def get_user_booster_join(user_id, booster_id)
  db = open_db
  db.execute('SELECT users.*, boosters.* FROM users INNER JOIN boosters ON boosters.id = ? WHERE users.id = ?',
             booster_id, user_id).first
end

def make_user_booster_rel(user_id, booster_id)
  db = open_db
  db.execute('INSERT INTO user_booster_rel (user_id, booster_id) VALUES (?, ?)', user_id, booster_id)
end

def new_booster(name, multiplier, price)
  db = open_db
  db.execute('INSERT INTO boosters (name, multiplier, price) VALUES (?, ?, ?)', name, multiplier, price)
end

def delete_booster(booster_id)
  db = open_db
  db.execute('DELETE FROM boosters WHERE id = ?', booster_id)
  db.execute('DELETE FROM user_booster_rel WHERE booster_id = ?', booster_id)
end

def update_booster(booster_id, name, multiplier, price)
  db = open_db
  db.execute('UPDATE boosters SET name = ?, multiplier = ?, price = ? WHERE id = ?', name, multiplier, price,
             booster_id)
end

# ================ CARDS ==================
def get_cards
  db = open_db
  db.execute('SELECT * FROM cards ORDER BY power')
end

def get_card(card_id)
  db = open_db
  db.execute('SELECT * FROM cards WHERE id = ?', card_id).first
end

def get_user_cards(user_id)
  db = open_db
  db.execute('SELECT cards.* FROM cards WHERE user_id = ?', user_id)
end

def new_card(name, power)
  db = open_db
  db.execute('INSERT INTO cards (name, power) VALUES (?, ?)', name, power)
end

def delete_card(card_id)
  db = open_db
  db.execute('DELETE FROM cards WHERE id = ?', card_id)
end

def update_card(card_id, name, power)
  db = open_db
  db.execute('UPDATE cards SET name = ?, power = ? WHERE id = ?', name, power, card_id)
end

# ================ EVENTS ==================
def get_events
  db = open_db
  db.execute('SELECT * FROM events ORDER BY reward')
end

def get_event(event_id)
  db = open_db
  db.execute('SELECT * FROM events WHERE id = ?', event_id).first
end

def get_user_events(user_id)
  db = open_db
  db.execute(
    'SELECT events.* FROM events JOIN user_event_rel ON events.id = user_event_rel.event_id WHERE user_event_rel.user_id = ?', user_id
  )
end

def get_user_events_rel(user_id, event_id)
  db = open_db
  db.execute('SELECT * FROM user_event_rel WHERE user_id = ? AND event_id = ?', user_id, event_id)
end

def get_event_price(user_id, event_id)
  db = open_db
  db.execute('SELECT users.tokens, events.fee FROM users INNER JOIN events ON events.id = ? WHERE users.id = ?',
             event_id, user_id).first
end

def make_user_event_rel(user_id, event_id)
  db = open_db
  db.execute('INSERT INTO user_event_rel (user_id, event_id) VALUES (?, ?)', user_id, event_id)
end

def new_event(name, reward, condition, fee)
  db = open_db
  db.execute('INSERT INTO events (name, reward, condition, fee) VALUES (?, ?, ?, ?)', name, reward, condition, fee)
end

def delete_event(event_id)
  db = open_db
  db.execute('DELETE FROM events WHERE id = ?', event_id)
  db.execute('DELETE FROM user_event_rel WHERE event_id = ?', event_id)
end

def update_event(event_id, name, reward, condition, fee)
  db = open_db
  db.execute('UPDATE events SET name = ?, reward = ?, condition = ?, fee = ? WHERE id = ?', name, reward, condition,
             fee, event_id)
end

# ================ PRICES ==================
def get_prices
  db = open_db
  db.execute('SELECT * FROM prices ORDER BY value')
end

def get_price(price_id)
  db = open_db
  db.execute('SELECT * FROM prices WHERE id = ?', price_id).first
end

def get_user_prices(user_id)
  db = open_db
  db.execute('SELECT prices.* FROM prices WHERE user_id = ?', user_id)
end

def set_user_price(user_id, price_id)
  db = open_db
  db.execute('UPDATE prices SET user_id = ? WHERE id = ?', user_id, price_id)
end

def new_price(name, value, description)
  db = open_db
  db.execute('INSERT INTO prices (name, value, description) VALUES (?, ?, ?)', name, value, description)
end

def delete_price(price_id)
  db = open_db
  db.execute('DELETE FROM prices WHERE id = ?', price_id)
end

def update_price(price_id, name, value, description)
  db = open_db
  db.execute('UPDATE prices SET name = ?, value = ?, description = ? WHERE id = ?', name, value, description, price_id)
end
