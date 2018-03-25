class Dog

attr_accessor :name, :breed, :id

def initialize(id: nil, name: name, breed: breed)
  @name = name
  @breed = breed
  @id = id
end

def self.create_table
sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL

DB[:conn].execute(sql)
end


def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

def self.new_from_db(row)
Dog.new(id: row[0], name: row[1], breed: row[2])
end


def save
  sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
  DB[:conn].execute(sql, self.name, self.breed)
  self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
  self
end

def self.create(name: name, breed: breed)
new_dog = Dog.new(name: name, breed: breed)
new_dog.save
new_dog
end

def self.find_by_id(id)
sql = "SELECT * FROM dogs WHERE id = (?)"
self.new_from_db((DB[:conn].execute(sql, id)[0]))
end

def self.find_or_create_by(name: name, breed: breed)
  new_dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
  if !new_dog.empty?
    dog_data =  new_dog[0]
    new_dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
  else
    new_dog = self.create(name: name, breed: breed)
  end
  new_dog
end

def self.find_by_name(name)
sql = "SELECT * FROM dogs WHERE name = (?)"
self.new_from_db((DB[:conn].execute(sql, name)[0]))
end

def update
  sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
  DB[:conn].execute(sql, self.name, self.breed, self.id)
end


# def save(name, breed)
#   sql = "INSERT INTO dogs SET (name, breed) VALUES (?, ?)"
# new_dog = self.new_from_db(DB[:conn].execute(sql, name, breed))
# new_dog.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
# end
































end
