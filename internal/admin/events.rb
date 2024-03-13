post('/admin/events/new') do
  name = params['name']
  reward = params['reward'].to_i
  condition = params['condition'].to_i
  price = params['price'].to_i
  new_event(name, reward, condition, price)
  redirect('/admin')
end

post('/admin/events/:id/delete') do
  id = params[:id].to_i
  delete_event(id)
  redirect('/admin')
end

get('/admin/events/:id/edit') do
  id = params[:id].to_i
  data = get_event(id)
  slim(:'events/edit', locals: { event: data })
end

post('/admin/events/:id/edit') do
  id = params[:id]
  name = params['name']
  reward = params['reward'].to_i
  condition = params['condition'].to_i
  price = params['price'].to_i
  update_event(id, name, reward, condition, price)
  redirect('/admin')
end
