require "pry"
class Dog
  attr_accessor :id, :name, :breed

  def initialize(id: nil, name: name, breed: breed)
    @id = id
    @name = name
    @breed = breed
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
      DROP TABLE dogs
    SQL
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs(name, breed)
      VALUES (?,?)
    SQL
    DB[:conn].execute(sql, name, breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    # DB.last_insert_row_id
    self
  end

  def self.create(name:,breed:)
    Dog.new(name:name, breed:breed).save
  end

  def self.find_by_id(id)
    sql= <<-SQL
     SELECT *
     FROM dogs
     WHERE id = ?
    SQL
    new_from_db(DB[:conn].execute(sql,id)[0])
  end

  def self.find_or_create_by(name:,breed:)
    sql= <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      AND breed = ?
    SQL
    pup = DB[:conn].execute(sql,name,breed)[0]
    pup ? new_from_db(pup) : create(name:name,breed:breed)
  end

  def self.new_from_db(row)
    new(id:row[0],name:row[1],breed:row[2])
  end

  def self.find_by_name(name)
    sql= <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
    SQL
    new_from_db(DB[:conn].execute(sql,name)[0])
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?,
      breed = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql,name, breed, id)


  end
end
