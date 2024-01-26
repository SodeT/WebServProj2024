get('/admin') do
  db = open_db('db/db.sqlite3')

  boo = db.execute('SELECT * FROM boosters')
  car = db.execute('SELECT * FROM cards')
  eve = db.execute('SELECT * FROM events')
  pri = db.execute('SELECT * FROM prices')

  slim(:admin, locals: { boosters: boo, cards: car, events: eve, prices: pri })
end
