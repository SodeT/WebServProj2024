# Handles the new price form in the admin dashboard
post('/admin/prices/new') do
  name = params['name']
  price = params['price'].to_i
  description = params['description']
  new_price(name, price, description)
  redirect('/admin')
end

# Handles the delete price in the admin dashboard
post('/admin/prices/:id/delete') do
  id = params[:id].to_i
  delete_price(id)
  redirect('/admin')
end

# Displays the edit price form in the admin dashboard
get('/admin/prices/:id/edit') do
  id = params[:id].to_i
  data = get_price(id)
  slim(:'prices/edit', locals: { price: data })
end

# Handles the edit price form in the admin dashboard
post('/admin/prices/:id/edit') do
  id = params[:id]
  name = params['name']
  price = params['price'].to_i
  description = params['description']
  update_price(id, name, price, description)
  redirect('/admin')
end
