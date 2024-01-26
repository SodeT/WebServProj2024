post('/admin/boosters/new') do
  db = open_db('db/db.sqlite3')
  name = params['name']
  multiplier = params['multiplier'].to_i
  price = params['price'].to_i
  db.execute('INSERT INTO boosters (name, multiplier, price) VALUES (?, ?, ?)', name, multiplier, price)
  redirect('/admin')
end

post('/admin/boosters/:id/delete') do
  db = open_db('db/db.sqlite3')
  id = params[:id].to_i
  db.execute('DELETE FROM boosters WHERE id = ?', id)
  db.execute('DELETE FROM user_boosters_rel WHERE booster_id = ?', id)
  redirect('/admin')
end

get('/admin/boosters/:id/edit') do
  db = open_db('db/db.sqlite3')
  id = params[:id].to_i
  data = db.execute('SELECT * FROM boosters WHERE id = ?', id).first
  slim(:'edit/booster', locals: { booster: data })
end

post('/admin/boosters/:id/edit') do
  db = open_db('db/db.sqlite3')
  id = params[:id]
  name = params['name']
  multiplier = params['multiplier'].to_i
  price = params['price'].to_i
  db.execute('UPDATE boosters SET name = ?, multiplier = ?, price = ? WHERE id = ?', name, multiplier, price, id)
  redirect('/admin')
end
