require_relative "../config/environment.rb"
require "pry"

class Student

  attr_accessor :id, :name, :grade

    def initialize(name, grade, id=nil)
      @name = name
      @grade = grade
      @id = id
    end

    def self.create_table
      sql = <<-SQL
      CREATE TABLE if NOT EXISTS students(
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade INTEGER
      )
      SQL
      DB[:conn].execute(sql)
    end

    def self.drop_table
      sql = <<-SQL
      DROP TABLE students
      SQL
      DB[:conn].execute(sql)
    end

    def update
      sql = <<-SQL
      UPDATE students
      SET name = ?, grade = ? WHERE id = ?
      SQL
      DB[:conn].execute(sql, self.name, self.grade, self.id)
    end

    def save
      if self.id
        self.update
      else
        sql = <<-SQL
        INSERT INTO students(name, grade)
        VALUES (?,?)
        SQL
        DB[:conn].execute(sql, self.name, self.grade)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
      end
    end

    def self.create(name, grade)
      kido = Student.new(name, grade)
      kido.save
      kido
    end

    def self.new_from_db(row)
      id = row[0]
      name = row[1]
      grade = row[2]
      Student.new(name, grade, id)
    end

    def self.find_by_name(name)
      sql = <<-SQL
      SELECT *
      FROM students
      WHERE name = ?
      SQL

      result = DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
    end


end
