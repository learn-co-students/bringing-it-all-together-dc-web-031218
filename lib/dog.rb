require "pry"

class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
    # binding.pry
  end

  def self.create_table
    sql = "create table if not exists dogs(id integer primary key, name text, breed text);"
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "drop table if exists dogs;"
    DB[:conn].execute(sql)
  end

  def save
    # returns an instance of the dog class
    # saves an instance of the dog class to the database
    #   and then sets the given dogs `id` attribute
    sql = "insert into dogs (name, breed) values (? , ?);"
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("select last_insert_rowid() from dogs;")[0][0]
    self
  end

  def self.create(name:, breed:)
    # takes in a hash of attributes and uses metaprogramming
    # to create a new dog object.
    # Then it uses the #save method to save that dog to the database
    # returns a new dog object
    # self.new({name: "dude", breed: "podle"})
    new_dog = self.new({name: name, breed: breed})
    new_dog.save
    new_dog
  end

  def self.find_by_id(id)
    sql = "select * from dogs where id = ?;"
    dog_row = DB[:conn].execute(sql, id)[0]
    self.new({id: dog_row[0], name: dog_row[1], breed: dog_row[2]})
  end

  def self.find_or_create_by(attributes)
    # creates an instance of a dog if it does not already exist
    # find by name and breed
    name = attributes[:name]
    breed = attributes[:breed]

    sql = "select * from dogs where name = ? and breed = ?;"
    dog_row = DB[:conn].execute(sql, name, breed)[0]
    # binding.pry
    if dog_row # if not empty
      # binding.pry
      new_dog = new_from_db(dog_row)
      # binding.pry
    else # empty, therefore create
      new_dog = self.create({name: name, breed: breed})
    end
    new_dog
  end

  def self.new_from_db(row)
    #binding.pry
    new_dog = self.new({id: row[0], name: row[1], breed: row[2]})
  end

  def self.find_by_name(name)
    # returns an instance of dog that matches the name from the DB
    sql = "select * from dogs where name = ?;"
    dog_row = DB[:conn].execute(sql, name)[0]
    # binding.pry
    if dog_row # if not empty
      # binding.pry
      new_dog = new_from_db(dog_row)
      # binding.pry
    else # empty, therefore create
      nil
    end
  end

  def update
    # updates the record associated with a given instance
    sql = "update dogs set name = ?, breed = ? where id = ?;"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
    self
  end


end
