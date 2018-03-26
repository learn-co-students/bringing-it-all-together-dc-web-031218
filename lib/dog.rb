require 'pry'

class Dog

  attr_accessor :name, :breed, :id

  def initialize(parts = {})
    #binding.pry
    @name = parts[:name]
    @breed = parts[:breed]
    @id = parts[:id]
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs(
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed, TEXT
    )
    SQL
    DB[:conn].execute(sql)
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ?
            WHERE id = ?"
    temp = DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE IF EXISTS dogs
    SQL
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed) VALUES (?,?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      # ret = DB[:conn].execute("SELECT last_insert_rowid()
      # FROM dogs")
      #binding.pry
      @id = DB[:conn].execute("SELECT last_insert_rowid()
      FROM dogs")[0][0]
      self
      #binding.pry
    end
  end

  def self.create(parts)
    dog = Dog.new(parts)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
      LIMIT 1
    SQL
    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
    end.first
    # temp = DB[:conn].execute(sql, id)
    # binding.pry
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE
      name = ? AND breed = ?", name, breed)

    if !dog.empty?
      dog_data = dog[0]
      hash = {id: dog_data[0], name: dog_data[1], breed: dog_data[2]}
      dog = Dog.new(hash)
    else
      dog = self.create(breed: breed, name: name)
    end
    dog
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.new_from_db(row)
    #binding.pry
    hash = {id: row[0], name: row[1], breed: row[2]}
    newDog = self.new(hash)
    newDog.id = row[0]
    newDog
  end


end
