post('/admin/events/new') do
  db = open_db
  name = params['name']
  reward = params['reward'].to_i
  condition = params['condition'].to_i
  fee = params['fee'].to_i
  db.execute('INSERT INTO events (name, reward, condition, fee) VALUES (?, ?, ?, ?)', name, reward, condition, fee)
  redirect('/admin')
end

post('/admin/events/:id/delete') do
  db = open_db
  id = params[:id].to_i
  db.execute('DELETE FROM events WHERE id = ?', id)
  db.execute('DELETE FROM user_event_rel WHERE event_id = ?', id)
  redirect('/admin')
end

get('/admin/events/:id/edit') do
  db = open_db
  id = params[:id].to_i
  data = db.execute('SELECT * FROM events WHERE id = ?', id).first
  slim(:'edit/event', locals: { event: data })
end

post('/admin/events/:id/edit') do
  db = open_db
  id = params[:id]
  name = params['name']
  reward = params['reward'].to_i
  condition = params['condition'].to_i
  fee = params['fee'].to_i
  db.execute('UPDATE events SET name = ?, reward = ?, condition = ?, fee = ? WHERE id = ?', name, reward, condition, fee, id)
  redirect('/admin')
end
