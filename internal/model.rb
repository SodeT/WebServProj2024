# Module containing the database abstraction
module Model
  # Creates a database connection
  # @return [SQLite3] the database
  def open_db
    db = SQLite3::Database.new('db/db.sqlite3')
    db.results_as_hash = true
    db
  end

  # ================ USERS ==================

  # Creates a new user in the database
  # @param username [String] the username of the user
  # @param pwd_hash [String] the hashed password
  # @param permissions [Integer] the permisions the user will get
  def new_user(username, pwd_hash, permissions)
    db = open_db
    db.execute('INSERT INTO users (username, pwd_hash, permissions) VALUES (?,?,?)', username, pwd_hash, permissions)
  end

  # Gets the user with the gived ID
  # @param user_id [Integer] the id of the requested user
  # @return [Hash] a hash representation of the requested users row in the database
  def get_user(user_id)
    db = open_db
    db.execute('SELECT * FROM users WHERE id = ?', user_id).first
  end

  # Gets the user with the gived username
  # @param username [String] the username of the requested user
  # @return [Hash] a hash representation of the requested users row in the database
  def get_user_by_name(username)
    db = open_db
    db.execute('SELECT * FROM users WHERE username = ?', username).first
  end

  # Adds an amount of tokens to a user
  # @param user_id [Integer] the id of the requested user
  # @param amount [Integer] the amount of tokens to be added to the user
  def add_user_tokens(user_id, amount)
    db = open_db
    db.execute('UPDATE users SET tokens = tokens + ? WHERE id = ?', amount, user_id)
  end

  # Gets the number of failed login attempts for the given user
  # @param user_id [Integer] the id of the requested user
  # @return [Integer] the number of failed login attempts
  def get_user_login_attempts(user_id)
    db = open_db
    db.execute('SELECT failed_login FROM users WHERE id = ?', user_id)
  end

  # Sets the number of failed login attempts for the given user
  # @param user_id [Integer] the id of the requested user
  # @param attempts [Integer] the number of failed concecutive login attemps
  def set_user_login_attempts(user_id, attempts)
    db = open_db
    db.execute('UPDATE users SET failed_login = ? WHERE id = ?', attempts, user_id)
  end

  # ================ BOOSTERS ==================

  # Gets every available booster
  # @return [Array] an array of hashes containing the database rows for every booster
  def get_boosters
    db = open_db
    db.execute('SELECT * FROM boosters ORDER BY price')
  end

  # Gets a booster specified by its ID
  # @param booster_id [Integer] the id of the requested booster
  # @return [Hash] a hash containing the database row for the given booster
  def get_booster(booster_id)
    db = open_db
    db.execute('SELECT * FROM boosters WHERE id = ?', booster_id).first
  end

  # Gets all boosters that are the specified user owns
  # @param user_id [Integer] the id of the requested user
  # @return [Array] an array of hashes containing the database rows for the user owned booster
  def get_user_boosters(user_id)
    db = open_db
    db.execute(
      'SELECT boosters.* FROM boosters JOIN user_booster_rel ON boosters.id = user_booster_rel.booster_id WHERE user_booster_rel.user_id = ?', user_id
    )
  end

  # Gets every row containing the user ID and booster ID
  # @param user_id [Integer] the id of the requested user
  # @param booster_id [Integer] the id of the requested booster
  # @return [Array] an array containing every row in the user_booster_rel table where user_id and booster_id matches
  def get_user_booster_rel(user_id, booster_id)
    db = open_db
    db.execute('SELECT * FROM user_booster_rel WHERE user_id = ? AND booster_id = ?', user_id, booster_id)
  end

  # Gets the DB join of the user booster tables
  # @param user_id [Integer] the id of the requested user
  # @param booster_id [Integer] the id of the requested booster
  # @return [Array] an array containing the boosters that the user owns aswell as the user
  def get_user_booster_join(user_id, booster_id)
    db = open_db
    db.execute('SELECT users.*, boosters.* FROM users INNER JOIN boosters ON boosters.id = ? WHERE users.id = ?',
               booster_id, user_id).first
  end

  # Creates a connection between a user and booster in the relational table
  # @param user_id [Integer] the id of the requested user
  # @param booster_id [Integer] the id of the requested booster
  def make_user_booster_rel(user_id, booster_id)
    db = open_db
    db.execute('INSERT INTO user_booster_rel (user_id, booster_id) VALUES (?, ?)', user_id, booster_id)
  end

  # Creates a new booster
  # @param name [String] the name of the new booster
  # @param multiplier [Integer] the multiplier of the new booster
  # @param price [Integer] the price of the new booster
  def new_booster(name, multiplier, price)
    db = open_db
    db.execute('INSERT INTO boosters (name, multiplier, price) VALUES (?, ?, ?)', name, multiplier, price)
  end

  # Deleats a booster
  # @param booster_id [Integer] the boosters id
  def delete_booster(booster_id)
    db = open_db
    db.execute('DELETE FROM boosters WHERE id = ?', booster_id)
    db.execute('DELETE FROM user_booster_rel WHERE booster_id = ?', booster_id)
  end

  # Updates a booster
  # @param booster_id [Integer] the boosters id
  # @param name [String] the boosters name
  # @param multiplier [Integer] the boosters multiplier
  # @param price [Integer] the boosters price
  def update_booster(booster_id, name, multiplier, price)
    db = open_db
    db.execute('UPDATE boosters SET name = ?, multiplier = ?, price = ? WHERE id = ?', name, multiplier, price,
               booster_id)
  end

  # ================ CARDS ==================

  # Gets every card from the database orderd by price
  def get_cards
    db = open_db
    db.execute('SELECT * FROM cards ORDER BY price')
  end

  # Gets a card by id
  # @param card_id [Integer] the cards id
  # @return [Hash] a hash of the cards row
  def get_card(card_id)
    db = open_db
    db.execute('SELECT * FROM cards WHERE id = ?', card_id).first
  end

  # Gets every card a user ownes
  # @param user_id [Integer] the users id
  # @return [Array] an array of hashes of the card rows
  def get_user_cards(user_id)
    db = open_db
    db.execute('SELECT cards.* FROM cards WHERE user_id = ?', user_id)
  end

  # Gets every card that does not have an owner and is thus for sale
  # @return [Array] Array of hashes containing cards for sale
  def get_cards_for_sale()
    db = open_db
    db.execute('SELECT cards.* FROM cards WHERE user_id IS NULL')
  end

  # Sets the owner of the given card
  # @param card_id [Integer] the cards ID
  # @param owner [Integer] the new owners user_id
  def set_card_owner(card_id, owner)
    db = open_db
    if owner == nil
      db.execute('UPDATE cards SET user_id = NULL WHERE id = ?', card_id)
    else
      db.execute('UPDATE cards SET user_id = ? WHERE id = ?', owner, card_id)
    end
  end

  # Increases the value of the card
  # @param card_id [Integer] the id of the card
  # @param price [Integer] the price that gets added to the card value
  def add_card_value(card_id, price)
    db = open_db
    db.execute('UPDATE cards SET price = price + ? WHERE id = ?', price, card_id)
  end

  # Creates a new card with a price and a name
  # @param name [String] the name of the new card
  # @param price [Integer] the price of the card
  def new_card(name, price)
    db = open_db
    db.execute('INSERT INTO cards (name, price) VALUES (?, ?)', name, price)
  end

  # Deletes a card
  # @param card_id [Integer] the cards id
  def delete_card(card_id)
    db = open_db
    db.execute('DELETE FROM cards WHERE id = ?', card_id)
  end

  # updates a card
  # @param card_id [Integer] the cards id
  # @param name [String] the new name of the card
  # @param price [Integer] the new price of the card
  def update_card(card_id, name, price)
    db = open_db
    db.execute('UPDATE cards SET name = ?, price = ? WHERE id = ?', name, price, card_id)
  end

  # ================ EVENTS ==================

  # Gets every event orderd by reward
  # @return [Array] an array of hashes containing every row of rewards
  def get_events
    db = open_db
    db.execute('SELECT * FROM events ORDER BY reward')
  end

  # gets an event specified by id
  # @param event_id [Integer] the events id
  # @return [Hash] a hash of the events db row
  def get_event(event_id)
    db = open_db
    db.execute('SELECT * FROM events WHERE id = ?', event_id).first
  end

  # gets every event that the given user ownes
  # @param user_id [Integer] the users id
  # @return [Array] an array of hashes of every event the user ownes
  def get_user_events(user_id)
    db = open_db
    db.execute(
      'SELECT events.* FROM events JOIN user_event_rel ON events.id = user_event_rel.event_id WHERE user_event_rel.user_id = ?', user_id
    )
  end

  # gets every relation whith the specified user and event ID
  # @param user_id [Integer] the users id
  # @param event_id [Integer] the events id
  # @return [Array] an array of hashes containing every user event relation
  def get_user_events_rel(user_id, event_id)
    db = open_db
    db.execute('SELECT * FROM user_event_rel WHERE user_id = ? AND event_id = ?', user_id, event_id)
  end

  # gets the price of an event and the current amount of tokens the user has
  # @param user_id [Integer] the users id
  # @param event_id [Integer] the events id
  # @return [Hash] a hash containing the users tokens and the event price
  def get_event_price(user_id, event_id)
    db = open_db
    db.execute('SELECT users.tokens, events.price FROM users INNER JOIN events ON events.id = ? WHERE users.id = ?',
               event_id, user_id).first
  end

  # Creates a user event relation
  # @param user_id [Integer] the users id
  # @param event_id [Integer] the event id
  def make_user_event_rel(user_id, event_id)
    db = open_db
    db.execute('INSERT INTO user_event_rel (user_id, event_id) VALUES (?, ?)', user_id, event_id)
  end

  # Deletes a user event relation
  # @param user_id [Integer] the users id
  # @param event_id [Integer] the event id
  def delete_user_event_rel(user_id, event_id)
    db = open_db
    db.execute('DELETE FROM user_event_rel WHERE user_id = ? AND event_id = ?', user_id, event_id)
  end

  # creates a new event
  # @param name [string] the event name
  # @param reward [Integer] the reward of the event
  # @param condition [Integer] the win condition of the event
  # @param price [Integer] the price of entry into the event
  def new_event(name, reward, condition, price)
    db = open_db
    db.execute('INSERT INTO events (name, reward, condition, price) VALUES (?, ?, ?, ?)', name, reward, condition, price)
  end

  # Deletes an event
  # @param event_id [Integer] the events id
  def delete_event(event_id)
    db = open_db
    db.execute('DELETE FROM events WHERE id = ?', event_id)
    db.execute('DELETE FROM user_event_rel WHERE event_id = ?', event_id)
  end

  # update an event
  # @param event_id [Integer] the events id
  # @param name [String] the new name of the event
  # @param reward [Integer] the win reward of the event
  # @param condition [Integer] the win condition of the event
  # @param price [Integer] the price of entry into the event
  def update_event(event_id, name, reward, condition, price)
    db = open_db
    db.execute('UPDATE events SET name = ?, reward = ?, condition = ?, price = ? WHERE id = ?', name, reward, condition,
               price, event_id)
  end

  # ================ PRICES ==================

  # gets every price
  # @return [Array] an array containing hashes for every price
  def get_prices
    db = open_db
    db.execute('SELECT * FROM prices ORDER BY price')
  end

  # gets a price by id
  # @param price_id [Integer] the prices id
  # @return [Hash] a hash of the prices db row
  def get_price(price_id)
    db = open_db
    db.execute('SELECT * FROM prices WHERE id = ?', price_id).first
  end

  # Gets every price the user has redeemed
  # @param user_id [Integer] the id of the user
  # @return [Array] array of hashes containing the users redeemed prices
  def get_user_prices(user_id)
    db = open_db
    db.execute('SELECT prices.* FROM prices WHERE user_id = ?', user_id)
  end

  # sets the owner of the given price to the specified user
  # @param user_id [Integer] the users id
  # @param price_id [Integer] the prices id
  def set_user_price(user_id, price_id)
    db = open_db
    db.execute('UPDATE prices SET user_id = ? WHERE id = ?', user_id, price_id)
  end

  # Creates a new price
  # @param name [String] the name of the new price
  # @param price [Integer] the price(cost) of the new price
  # @param description [String] a description of the price
  def new_price(name, price, description)
    db = open_db
    db.execute('INSERT INTO prices (name, price, description) VALUES (?, ?, ?)', name, price, description)
  end

  # Deletes the specified price
  # @param price_id [Integer] the price id
  def delete_price(price_id)
    db = open_db
    db.execute('DELETE FROM prices WHERE id = ?', price_id)
  end

  # updates the price
  # @param price_id [Integer] the prices id
  # @param name [String] the new name for the price
  # @param price [Integer] the new price(cost) for the price
  # @param description [Integer] the new description for the price
  def update_price(price_id, name, price, description)
    db = open_db
    db.execute('UPDATE prices SET name = ?, price = ?, description = ? WHERE id = ?', name, price, description, price_id)
  end
end
