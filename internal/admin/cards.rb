post('/admin/cards/new') do
  db = open_db
  name = params['name']
  power = params['power'].to_i
  db.execute('INSERT INTO cards (name, power) VALUES (?, ?)', name, power)
  redirect('/admin')
end

post('/admin/cards/:id/delete') do
  db = open_db
  id = params[:id].to_i
  db.execute('DELETE FROM cards WHERE id = ?', id)
  redirect('/admin')
end

get('/admin/cards/:id/edit') do
  db = open_db
  id = params[:id].to_i
  data = db.execute('SELECT * FROM cards WHERE id = ?', id).first
  slim(:'edit/card', locals: { card: data })
end

post('/admin/cards/:id/edit') do
  db = open_db
  id = params[:id]
  name = params['name']
  power = params['power'].to_i
  db.execute('UPDATE cards SET name = ?, power = ? WHERE id = ?', name, power, id)
  redirect('/admin')
end
