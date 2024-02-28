# Dynamic MVC, mabye overenginered

# ========================= HELPER =================

def open_db
  db = SQLite3::Database.new('db/db.sqlite3')
  db.results_as_hash = true
  db
end

def insert_builder(table, args)
  column_names = '('
  param_count = '('
  l = args.length

  args.each_with_index do |(name, value), i|
    column_names += name
    param_count += '?'
    if l != i + 1
      column_names += ', '
      param_count += ', '
    end
  end
  column_names += ')'
  param_count += ')'

  "INSERT INTO #{table} #{column_names} VALUES #{param_count}"
end

def update_builder(table, args)
  columns = ''
  l = args.length

  args.each_with_index do |(name, _value), i|
    columns += name + ' = ?'
    if l != i + 1
      columns += ', '
    end
  end

  "UPDATE #{table} SET #{columns} WHERE id = ?"
end

# ================== DYNAMIC ===================

def get_row(table, id)
  db = open_db
  db.execute("SELECT * FROM #{table} WHERE id = ?", id).first
end

def get_table(table)
  db = open_db
  db.execute("SELECT * FROM #{table}")
end

def get_rows_by_user(table, user_id)
  db = open_db
  db.execute("SELECT * FROM #{table} WHERE user_id = ?", user_id)
end

def delete_row(table, id)
  db = open_db
  db.execute("DELETE FROM #{table} WHERE id = ?", id)
end

def insert_row(table, values)
  query = insert_builder(table, values)
  db = open_db
  db.execute(query, [*values.values])
end

def update_row(table, id, values)
  query = update_builder(table, values)
  db = open_db
  db.execute(query, [*values.values, id])
end

def make_rel(table, col1, col2, id1, id2)
  query = "INSERT INTO #{table} (#{col1}, #{col2}) VALUES (?, ?)"
  db = open_db
  db.execute(query, id1, id2)
end

def get_rel(table, col1, col2, id1, id2)
  query = "SELECT * FROM #{table} WHERE #{col1} = ? AND #{col2} = ?"
  db = open_db
  db.execute(query, id1, id2)
end

def join_user_with(table, rel_table, id_col, user_id)
  db = open_db
  query = "SELECT #{table}.* FROM #{table} JOIN #{rel_table} ON #{table}.id = #{rel_table}.#{id_col} WHERE #{rel_table}.user_id = ?"
  db.execute(query, user_id)
end