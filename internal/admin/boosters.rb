# Handles the create new booster form in the admin dashboard
post('/admin/boosters/new') do
  name = params['name']
  multiplier = params['multiplier'].to_i
  price = params['price'].to_i
  new_booster(name, multiplier, price)
  redirect('/admin')
end

# Handles the delete booster in the admin dashboard
post('/admin/boosters/:id/delete') do
  id = params[:id].to_i
  delete_booster(id)
  redirect('/admin')
end

# Displays the edit booster in the admin dashboard
get('/admin/boosters/:id/edit') do
  id = params[:id].to_i
  booster = get_booster(id)
  slim(:'boosters/edit', locals: { booster: booster })
end

# Handles the edit booster form in the admin dashboard
post('/admin/boosters/:id/edit') do
  id = params[:id]
  name = params['name']
  multiplier = params['multiplier'].to_i
  price = params['price'].to_i
  update_booster(id, name, multiplier, price)
  redirect('/admin')
end
