get('/play') do
  id = session['id']
  db = open_db('db/db.sqlite3')
  data = db.execute('SELECT username, tokens FROM users WHERE id = ?', id).first
  slim(:play, locals: { user: data })
end

get('/boosters') do
  db = open_db('db/db.sqlite3')
  data = db.execute('SELECT * FROM boosters ORDER BY price')
  slim(:boosters, locals: { boosters: data })
end

# FIXME: Does not find this rout :(
post('/boosters/:id/buy') do
  puts('HERE ======================================================')
  db = open_db('db/db.sqlite3')
  booster_id = params[:id].to_i
  user_id = session[:id]

  result = db.execute('SELECT * FROM user_booster_rel WHERE user_id = ? AND booster_id = ?', user_id, booster_id)

  return 'You already own this booster...' unless result.empty?

  data = db.execute('SELECT users.tokens, boosters.price FROM boosters INNER JOIN users ON user_booster_rel.user_id = users.id WHERE boosters.id = ?', booster_id)
  p data

  return 'You do not have enough tokens to buy this booster...' if data['tokens'] < data['price']

  db.execute('INSERT INTO user_booster_rel (user_id, booster_id) VALUES (?, ?)', user_id, booster_id)
  db.execute('UPDATE users SET tokens = tokens - ? WHERE id = ?', data['price'], user_id)
  redirect('/boosters')
end

get('/cards') do
  db = open_db('db/db.sqlite3')
  data = db.execute('SELECT * FROM cards ORDER BY power')
  slim(:cards, locals: { cards: data })
end

get('/events') do
  db = open_db('db/db.sqlite3')
  data = db.execute('SELECT * FROM events ORDER BY reward')
  slim(:events, locals: { events: data })
end

get('/prices') do
  db = open_db('db/db.sqlite3')
  data = db.execute('SELECT * FROM prices ORDER BY value')
  slim(:prices, locals: { prices: data })
end
