post('/admin/prices/new') do
  db = open_db
  name = params['name']
  value = params['value'].to_i
  description = params['description']
  db.execute('INSERT INTO prices (name, value, description) VALUES (?, ?, ?)', name, value, description)
  redirect('/admin')
end

post('/admin/prices/:id/delete') do
  db = open_db
  id = params[:id].to_i
  db.execute('DELETE FROM prices WHERE id = ?', id)
  redirect('/admin')
end

get('/admin/prices/:id/edit') do
  db = open_db
  id = params[:id].to_i
  data = db.execute('SELECT * FROM prices WHERE id = ?', id).first
  slim(:'edit/price', locals: { price: data })
end

post('/admin/prices/:id/edit') do
  db = open_db
  id = params[:id]
  name = params['name']
  value = params['value'].to_i
  description = params['description']
  db.execute('UPDATE prices SET name = ?, value = ?, description = ? WHERE id = ?', name, value, description, id)
  redirect('/admin')
end
