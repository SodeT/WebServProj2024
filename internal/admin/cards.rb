post('/admin/cards/new') do
  name = params['name']
  power = params['power'].to_i
  new_card(name, power)
  redirect('/admin')
end

post('/admin/cards/:id/delete') do
  id = params[:id].to_i
  delete_card(id)
  redirect('/admin')
end

get('/admin/cards/:id/edit') do
  id = params[:id].to_i
  card = get_card(id)
  slim(:'cards/edit', locals: { card: card })
end

post('/admin/cards/:id/edit') do
  id = params[:id]
  name = params['name']
  power = params['power'].to_i
  update_card(id, name, power)
  redirect('/admin')
end
