get('/play') do
  id = session['id']
  stats = session['stats']
  p stats
  user = get_user(id)

  boosters = get_user_boosters(id)
  cards = get_user_cards(id)
  events = get_user_events(id)
  prices = get_user_prices(id)

  slim(:play, locals: { user: user, stats: stats, boosters: boosters, cards: cards, events: events, prices: prices })
end

post('/spin') do
  user_id = session['id']
  user = get_user(user_id)

  cost = 30
  show_error('Not enough tokens...', '/play') if user['tokens'] < cost

  boosters = get_user_boosters(user_id)

  total_multiplier = 1
  boosters.each do |booster|
    total_multiplier *= booster['multiplier']
  end

  value = (rand(0..40) - cost) * total_multiplier

  value *= (user['permissions'] + 1) # Casually rigging the game in favor of admins and content creators
  spin_stats = {'multiplier' => total_multiplier, 'tokens' => value}
  session['stats'] = spin_stats

  add_user_tokens(user_id, value)
  redirect('/play')
end

post('/logout') do
  session.clear
  redirect('/')
end

post('/buytokens') do
  id = session['id']
  add_user_tokens(id, 100)
  redirect('/play')
end

get('/boosters') do
  user_id = session[:id]
  user = get_user(user_id)
  boosters = get_boosters
  slim(:'boosters/index', locals: { user: user, boosters: boosters })
end

post('/boosters/:id/buy') do
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
  user_id = session[:id]
  user = get_user(user_id)
  your_cards = get_user_cards(user_id)
  other_cards = get_cards_for_sale
  slim(:'cards/index', locals: { user: user, your_cards: your_cards, other_cards: other_cards })
end

get('/cards/:id/sell') do
  user_id = session[:id]
  card_id = params[:id].to_i
  card = get_card(card_id)

  show_error("You don't own this card...", '/cards') if card['user_id'] != user_id

  # add 30 card value, give 10 of it to the seller
  add_user_tokens(user_id, card['price'] + 10)
  add_card_value(card_id, 30)
  set_card_owner(card_id, nil)
  redirect('/cards')
end

get('/cards/:id/buy') do
  user_id = session[:id]
  card_id = params[:id].to_i
  card = get_card(card_id)
  user = get_user(user_id)

  show_error('Someone already bought this card...', '/cards') unless card['user_id'].nil?
  show_error("You don't have enough tokens to buy this card...", '/cards') if user['tokens'] < card['price']

  add_user_tokens(user_id, -card['price'])
  set_card_owner(card_id, user_id)
  redirect('/cards')
end

get('/events') do
  user_id = session[:id]
  user = get_user(user_id)
  events = get_events
  slim(:'events/index', locals: { user: user, events: events })
end

post('/events/:id/buy') do
  event_id = params[:id].to_i
  user_id = session[:id]

  result = get_user_booster_rel(user_id, event_id)

  show_error('You already own this event...', '/events') unless result.empty?

  data = get_event_price(user_id, event_id)

  show_error("You don't have enough tokens to buy this event...", '/events') if data['tokens'] < data['price']

  make_user_event_rel(user_id, event_id)
  add_user_tokens(user_id, -data['price'])
  redirect('/events')
end

get('/prices') do
  user_id = session[:id]
  user = get_user(user_id)
  data = get_prices
  slim(:'prices/index', locals: { user: user, prices: data })
end

post('/prices/:id/buy') do
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
