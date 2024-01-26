get('/play') do
  id = session['id']
  db = open_db
  user = db.execute('SELECT * FROM users WHERE id = ?', id).first

  boosters = get_boosters(id)
  cards = get_cards(id)
  events = get_events(id)
  prices = get_prices(id)

  slim(:play, locals: { user: user, boosters: boosters, cards: cards, events: events, prices: prices })
end

post('/spin') do
  user_id = session['id']
  db = open_db

  user = db.execute('SELECT * FROM users WHERE id = ?', user_id).first

  cost = 30
  show_error('Not enough tokens...', '/play') if user['tokens'] < cost

  boosters = get_boosters(user_id)

  total_multiplier = 1
  boosters.each do |booster|
    total_multiplier *= booster['multiplier']
  end

  value = rand(0..50) * total_multiplier

  value *= (user['permissions'] + 1) # Casually rigging the game in favor of admins and content creators
  value -= cost
  db.execute('UPDATE users SET tokens = tokens + ? WHERE id = ?', value, user_id)
  redirect('/play')
end

get('/boosters') do
  db = open_db
  data = db.execute('SELECT * FROM boosters ORDER BY price')
  slim(:boosters, locals: { boosters: data })
end

post('/boosters/:id/buy') do
  db = open_db
  booster_id = params[:id].to_i
  user_id = session[:id]

  result = db.execute('SELECT * FROM user_booster_rel WHERE user_id = ? AND booster_id = ?', user_id, booster_id)

  show_error('You already own this booster...', '/boosters') unless result.empty?

  data = db.execute('SELECT users.tokens, boosters.price FROM users INNER JOIN boosters ON boosters.id = ? WHERE users.id = ?', booster_id, user_id).first

  show_error("You don't have enough tokens to buy this booster...", '/boosters') if data['tokens'] < data['price']

  db.execute('INSERT INTO user_booster_rel (user_id, booster_id) VALUES (?, ?)', user_id, booster_id)
  db.execute('UPDATE users SET tokens = tokens - ? WHERE id = ?', data['price'], user_id)
  redirect('/boosters')
end

get('/cards') do
  db = open_db
  data = db.execute('SELECT * FROM cards ORDER BY power')
  slim(:cards, locals: { cards: data })
end

get('/events') do
  db = open_db
  data = db.execute('SELECT * FROM events ORDER BY reward')
  slim(:events, locals: { events: data })
end

post('/events/:id/buy') do
  db = open_db
  event_id = params[:id].to_i
  user_id = session[:id]

  result = db.execute('SELECT * FROM user_event_rel WHERE user_id = ? AND event_id = ?', user_id, event_id)

  show_error('You already own this event...', '/events') unless result.empty?

  data = db.execute('SELECT users.tokens, events.fee FROM users INNER JOIN events ON events.id = ? WHERE users.id = ?', event_id, user_id).first

  show_error("You don't have enough tokens to buy this event...", '/events') if data['tokens'] < data['fee']

  db.execute('INSERT INTO user_event_rel (user_id, event_id) VALUES (?, ?)', user_id, event_id)
  db.execute('UPDATE users SET tokens = tokens - ? WHERE id = ?', data['fee'], user_id)
  redirect('/events')
end

get('/prices') do
  db = open_db
  data = db.execute('SELECT * FROM prices ORDER BY value')
  slim(:prices, locals: { prices: data })
end

post('/prices/:id/buy') do
  db = open_db
  price_id = params[:id].to_i
  user_id = session[:id]

  price = db.execute('SELECT * FROM prices WHERE id = ?', event_id).first

  show_error('You already own this event...', '/events') if price['user_id'] == user_id
  show_error("You don't have enough tokens to redeem this price...", '/events') if price['tokens'] < data['value']

  db.execute('UPDATE prices SET user_id = ? WHERE id = ?', user_id, price_id)
  db.execute('UPDATE users SET tokens = tokens - ? WHERE id = ?', data['value'], user_id)

  redirect('/prices')
end
