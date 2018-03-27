class Dog
	attr_accessor :name, :breed
	attr_reader :id

	def initialize(name:, breed:, id: nil)
		@name, @breed = name, breed
		@id = id
	end

	def save
		sql = <<-SQL
			INSERT INTO dogs (name, breed)
			VALUES (?, ?);
		SQL
		if self.id
			self.update
		else
			DB[:conn].execute(sql, self.name, self.breed)
			@id = DB[:conn].execute("SELECT last_insert_rowid()
						FROM dogs;")[0][0]
		end
		self
	end



	def update
		sql = <<-SQL
			UPDATE dogs
			SET name = ?, breed = ?
			WHERE id = ?;
		SQL
		DB[:conn].execute(sql, self.name, self.breed, self.id)
	end



	#----------------Class Methods----------------
	def self.new_from_db(row)
		dog = self.new(name:row[1], breed: row[2], id: row[0])
	end


	def self.find_by_id(int)
		sql = <<-SQL
			SELECT *
			FROM dogs
			WHERE dogs.id = ?
		SQL
		DB[:conn].execute(sql, int).map{|row|self.new_from_db(row)}.first
	end

	def self.find_or_create_by(name:, breed:)
		sql = <<-SQL
			SELECT *
			FROM dogs
			WHERE dogs.name = ? AND dogs.breed = ?;
		SQL
		dog = DB[:conn].execute(sql, name, breed)

		if !dog.empty?
			dog_data = dog[0]
			dog = self.new_from_db(dog_data)
		else
			dog = self.create({name: name, breed: breed})
		end
		dog
	end


	def self.find_by_name(name)
		sql = <<-SQL
			SELECT * 
			FROM dogs
			WHERE dogs.name = ?
			LIMIT 1;
		SQL
		DB[:conn].execute(sql, name).map{|row| self.new_from_db(row)}.first

	end

	def self.create(hash_obj)
		temp = Dog.new(hash_obj)
		temp.save
	end
	

	def self.create_table
		sql = <<-SQL
			CREATE TABLE IF NOT EXISTS dogs(
			id INTEGER PRIMARY KEY,
			name TEXT,
			breed TEXT
			);
		SQL
		DB[:conn].execute(sql)
	end


	def self.drop_table
		sql = <<-SQL
			DROP TABLE IF EXISTS dogs;
		SQL
		DB[:conn].execute(sql)
	end



end