get('/play') do
  id = session['id']
  db = open_db
  user = get_user(id)

  boosters = get_user_boosters(id)
  cards = get_user_cards(id)
  events = get_user_events(id)
  prices = get_user_prices(id)

  slim(:play, locals: { user: user, boosters: boosters, cards: cards, events: events, prices: prices })
end

post('/spin') do
  user_id = session['id']
  db = open_db

  user = get_user(user_id)

  cost = 30
  show_error('Not enough tokens...', '/play') if user['tokens'] < cost

  boosters = get_boosters(user_id)

  total_multiplier = 1
  boosters.each do |booster|
    total_multiplier *= booster['multiplier']
  end

  value = rand(0..50) * total_multiplier

  value *= (user['permissions'] + 1) # Casually rigging the game in favor of admins and content creators
  value -= cost
  add_user_tokens(user_id, value)
  redirect('/play')
end

get('/boosters') do
  boosters = get_boosters
  slim(:'boosters/index', locals: { boosters: boosters })
end

post('/boosters/:id/buy') do
  db = open_db
  booster_id = params[:id].to_i
  user_id = session[:id]

  user_boosters = get_user_booster_rel(user_id, booster_id)

  show_error('You already own this booster...', '/boosters') unless user_boosters.empty?

  data = get_user_booster_join(user_id, booster_id)

  show_error("You don't have enough tokens to buy this booster...", '/boosters') if data['tokens'] < data['price']

  make_user_booster_rel(user_id, booster_id)
  add_user_tokens(user_id, -data['price'])
  redirect('/boosters')
end

get('/cards') do
  cards = get_cards
  slim(:'cards/index', locals: { cards: cards })
end

get('/events') do
  events = get_events
  slim(:'events/index', locals: { events: events })
end

post('/events/:id/buy') do
  event_id = params[:id].to_i
  user_id = session[:id]

  result = get_user_booster_rel(user_id, event_id)

  show_error('You already own this event...', '/events') unless result.empty?

  data = get_event_price(user_id, event_id)

  show_error("You don't have enough tokens to buy this event...", '/events') if data['tokens'] < data['fee']

  make_user_event_rel(user_id, event_id)
  add_user_tokens(user_id, -data['fee'])
  redirect('/events')
end

get('/prices') do
  data = get_prices
  slim(:'prices/index', locals: { prices: data })
end

post('/prices/:id/buy') do
  db = open_db
  price_id = params[:id].to_i
  user_id = session[:id]

  price = get_price(price_id)
  user = get_user(user_id)

  show_error('This price has already been redemeed', '/events') unless price['user_id'].nil?
  show_error("You don't have enough tokens to redeem this price...", '/events') if user['tokens'] < price['value']

  set_user_price(user_id, price_id)
  add_user_tokens(user_id, -price['value'])

  redirect('/prices')
end
