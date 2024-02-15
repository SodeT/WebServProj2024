get('/admin') do
  boosters = get_boosters
  cards = get_cards
  events = get_events
  prices = get_prices

  slim(:admin, locals: { boosters: boosters, cards: cards, events: events, prices: prices })
end
