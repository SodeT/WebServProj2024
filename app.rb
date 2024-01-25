# The BIG Casino
# frozen_string_literal: true

require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'

enable :sessions
# set :session_secret, 'random-key'

permissions = {
  'user' => 0,
  'creator' => 1,
  'admin' => 2
}

def all_of(*paths)
  /(#{paths.join('|')})/
end

def open_db(path)
  db = SQLite3::Database.new(path)
  db.results_as_hash = true
  db
end

before(all_of('/play', '/boosters', '/cards', '/events', '/prices')) do
  db = open_db('db/db.sqlite3')
  id = session[:id]

  result = db.execute('SELECT COUNT(1) FROM users WHERE id = ?', id).first
  redirect('/login') if result.nil?
end

before('/admin/*') do
  db = open_db('db/db.sqlite3')
  id = session[:id]

  user = db.execute('SELECT permissions FROM users WHERE id = ?', id).first

  p user['permissions']
  p permissions['admin']
  redirect('/') if user['permissions'].to_i != permissions['admin']
end

get('/') do
  slim(:home)
end

get('/signup') do
  slim(:'account/signup')
end

post('/signup') do
  username = params[:username]
  password = params[:password]
  password_confirm = params[:password_confirm]
  permissions = params[:permissions].to_i

  return "Passwords don't match..." if password != password_confirm

  pwd_hash = BCrypt::Password.create(password)
  db = open_db('db/db.sqlite3')
  db.execute('INSERT INTO users (username, pwd_hash, permissions, tokens) VALUES (?,?,?,?)',
             username, pwd_hash, permissions, 0)
  user = db.execute('SELECT * FROM users WHERE username = ?', username).first
  session[:id] = user['id']
  session[:username] = user['username']

  redirect('/play')
end

get('/login') do
  slim(:'account/login')
end

post('/login') do
  db = open_db('db/db.sqlite3')
  username = params[:username]
  password = params[:password]

  user = db.execute('SELECT * FROM users WHERE username = ?', username).first

  pwd_hash = user['pwd_hash']

  if BCrypt::Password.new(pwd_hash) == password
    session[:id] = user['id']
    session[:username] = user['username']
    redirect('/play')
  else
    'Fel lösenord...'
  end
end

get('/play') do
  id = session['id']
  db = open_db('db/db.sqlite3')
  data = db.execute('SELECT username, tokens FROM users WHERE id = ?', id).first
  slim(:play, locals: { user: data })
end

get('/boosters') do
  db = open_db('db/db.sqlite3')
  data = db.execute('SELECT * FROM boosters ORDER BY price')
  slim(:boosters, locals: { boosters: data })
end

get('/cards') do
  db = open_db('db/db.sqlite3')
  data = db.execute('SELECT * FROM cards ORDER BY power')
  slim(:cards, locals: { cards: data })
end

get('/events') do
  db = open_db('db/db.sqlite3')
  data = db.execute('SELECT * FROM events ORDER BY reward')
  slim(:events, locals: { events: data })
end

get('/prices') do
  db = open_db('db/db.sqlite3')
  data = db.execute('SELECT * FROM prices ORDER BY value')
  slim(:prices, locals: { prices: data })
end

get('/admin') do
  db = open_db('db/db.sqlite3')
  id = session[:id]

  user = db.execute('SELECT permissions FROM users WHERE id = ?', id).first
  redirect('/') if user['permission'] != permissions['admin']

  boo = db.execute('SELECT * FROM boosters')
  car = db.execute('SELECT * FROM cards')
  eve = db.execute('SELECT * FROM events')
  pri = db.execute('SELECT * FROM prices')

  slim(:admin, locals: { boosters: boo, cards: car, events: eve, prices: pri })
end

post('/admin/boosters/new') do
  db = open_db('db/db.sqlite3')
  name = params['name']
  multiplier = params['multiplier'].to_i
  price = params['price'].to_i
  db.execute('INSERT INTO boosters (name, multiplier, price) VALUES (?, ?, ?)', name, multiplier, price)
  redirect('/admin')
end

post('/admin/boosters/:id/delete') do
  db = open_db('db/db.sqlite3')
  id = params[:id].to_i
  db.execute('DELETE FROM boosters WHERE id = ?', id)
  db.execute('DELETE FROM user_booster_rel WHERE booster_id = ?', id)
  redirect('/admin')
end

get('/admin/boosters/:id/edit') do
  db = open_db('db/db.sqlite3')
  id = params[:id].to_i
  data = db.execute('SELECT * FROM boosters WHERE id = ?', id)
  slim(:'boosters/edit', locals: { booster: data })
end

post('/admin/boosters/:id/edit') do
  db = open_db('db/db.sqlite3')
  id = params[:id]
  name = params['name']
  multiplier = params['multiplier'].to_i
  price = params['price'].to_i
  db.execute('UPDATE boosters SET name = ?, multiplier = ?, price = ? WHERE id = ?', name, multiplier, price, id)
  redirect('/admin')
end

post('/admin/cards/new') do
  db = open_db('db/db.sqlite3')
  name = params['name']
  power = params['power'].to_i
  db.execute('INSERT INTO cards (name, power) VALUES (?, ?)', name, power)
  redirect('/admin')
end

post('/admin/cards/:id/delete') do
  db = open_db('db/db.sqlite3')
  id = params[:id].to_i
  db.execute('DELETE FROM cards WHERE id = ?', id)
  redirect('/admin')
end

post('/admin/events/new') do
  db = open_db('db/db.sqlite3')
  name = params['name']
  reward = params['reward'].to_i
  condition = params['condition'].to_i
  fee = params['fee'].to_i
  db.execute('INSERT INTO events (name, reward, condition, fee) VALUES (?, ?, ?, ?)', name, reward, condition, fee)
  redirect('/admin')
end

post('/admin/events/:id/delete') do
  db = open_db('db/db.sqlite3')
  id = params[:id].to_i
  db.execute('DELETE FROM events WHERE id = ?', id)
  db.execute('DELETE FROM user_booster_rel WHERE booster_id = ?', id)
  redirect('/admin')
end

post('/admin/prices/new') do
  db = open_db('db/db.sqlite3')
  name = params['name']
  value = params['value'].to_i
  description = params['description']
  db.execute('INSERT INTO prices (name, value, description) VALUES (?, ?, ?)', name, value, description)
  redirect('/admin')
end

post('/admin/prices/:id/delete') do
  db = open_db('db/db.sqlite3')
  id = params[:id].to_i
  db.execute('DELETE FROM prices WHERE id = ?', id)
  redirect('/admin')
end