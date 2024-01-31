get('/play') do
  id = session['id']
  db = open_db
  user = get_user(id)

  boosters = get_user_boosters(id)
  cards = get_cards(id)
  events = get_events(id)
  prices = get_prices(id)

  slim(:play, locals: { user: user, boosters: boosters, cards: cards, events: events, prices: prices })
end

post('/spin') do
  user_id = session['id']
  db = open_db

  user = get_user(user_id)

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
  boosters = get_boosters
  slim(:boosters, locals: { boosters: boosters })
end

post('/boosters/:id/buy') do
  db = open_db
  booster_id = params[:id].to_i
  user_id = session[:id]

  user_boosters = get_user_booster_rel(user_id, booster_id)

  show_error('You already own this booster...', '/boosters') unless user_boosters.empty?

  data = get_user_booster_join(user_id, booster_id)

  show_error("You don't have enough tokens to buy this booster...", '/boosters') if data['tokens'] < data['price']

  make_user_booster_rel(user_id, booster_id)
  add_user_tokens(user_id, -data['price'])
  redirect('/boosters')
end

get('/cards') do
  cards = get_cards
  slim(:cards, locals: { cards: cards })
end

get('/events') do
  events = get_events
  slim(:events, locals: { events: events })
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

  price = db.execute('SELECT * FROM prices WHERE id = ?', price_id).first
  user = db.execute('SELECT * FROM users WHERE id = ?', user_id).first

  show_error('You have already redeemed this price...', '/events') if price['user_id'] == user_id
  show_error("You don't have enough tokens to redeem this price...", '/events') if user['tokens'] < price['value']

  db.execute('UPDATE prices SET user_id = ? WHERE id = ?', user_id, price_id)
  db.execute('UPDATE users SET tokens = tokens - ? WHERE id = ?', price['value'], user_id)

  redirect('/prices')
end
