# Handles the new card form in the admin dashboard
post('/admin/cards/new') do
  name = params['name']
  price = params['price'].to_i
  new_card(name, price)
  redirect('/admin')
end

# Handles the delete card in the admin dashboard
post('/admin/cards/:id/delete') do
  id = params[:id].to_i
  delete_card(id)
  redirect('/admin')
end

# Displays the edit card form in the admin dashboard
get('/admin/cards/:id/edit') do
  id = params[:id].to_i
  card = get_card(id)
  slim(:'cards/edit', locals: { card: card })
end

# Handles the edit card form in the admin dashboard
post('/admin/cards/:id/edit') do
  id = params[:id]
  name = params['name']
  price = params['price'].to_i
  update_card(id, name, price)
  redirect('/admin')
end
