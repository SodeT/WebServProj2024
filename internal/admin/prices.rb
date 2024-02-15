post('/admin/prices/new') do
  name = params['name']
  value = params['value'].to_i
  description = params['description']
  new_price(name, value, description)
  redirect('/admin')
end

post('/admin/prices/:id/delete') do
  id = params[:id].to_i
  delete_price(id)
  redirect('/admin')
end

get('/admin/prices/:id/edit') do
  id = params[:id].to_i
  data = get_price(id)
  slim(:'prices/edit', locals: { price: data })
end

post('/admin/prices/:id/edit') do
  id = params[:id]
  name = params['name']
  value = params['value'].to_i
  description = params['description']
  update_price(id, name, value, description)
  redirect('/admin')
end
