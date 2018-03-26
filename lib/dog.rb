require 'pry'

class Dog
  attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed

    # Dog.save(name, breed)
  end

  def save
    if self.id != nil
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      new_dog = DB[:conn].execute("SELECT * FROM dogs")
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      Dog.new(id: @id, name: new_dog[0][1], breed: new_dog[0][2])
    end
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
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs
    SQL
    DB[:conn].execute(sql)
  end

  def self.create(attributes)
    # binding.pry
    Dog.new(name: attributes[:name], breed: attributes[:breed]).save
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE dogs.id = (?)
    SQL
    new_dog = DB[:conn].execute(sql, id)
    # binding.pry
    Dog.new_from_db(new_dog[0])

  end

  def self.find_or_create_by(dog)
    all_dogs = DB[:conn].execute("SELECT * FROM dogs")
    # binding.pry
    if Dog.find_by_name(dog[:name]).breed == dog[:breed]
      Dog.find_by_name(dog[:name])
    elsif Dog.find_by_name(dog[:name])
      new_dog = Dog.new(name: dog[:name], breed: dog[:breed]).save
      new_dog
    else
      # binding.pry
      new_dog = Dog.new(name: dog[:name], breed: dog[:breed]).save
      new_dog
    end

  end


  # new_dog.find_by_id(last_insert_row_id())

  def self.new_from_db(row)
    # binding.pry
    Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE dogs.name = (?)
    SQL
    new_dog = DB[:conn].execute(sql, name)
    # binding.pry
    Dog.new_from_db(new_dog[0])
  end


  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end


end
