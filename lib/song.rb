require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class Song

# This method make correction of the table format aka "pluralize it": 
  def self.table_name
    self.to_s.downcase.pluralize
  end


# This method will inquire name of each column from the table_name's table itself, from above and insert it into an empty array:

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "pragma table_info('#{table_name}')"
  
    

    table_info = DB[:conn].execute(sql)

    column_names = []
    table_info.each do |row|
      column_names << row["name"]
    end
    column_names.compact
  end

#This method will iterate over each column's name (id,name,album,etc) and make each of them an attribute accessors so they can be used in ruby
  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
  end


  def initialize(options={})
    binding.pry
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end


#this method will insert the instances that have being updated into database using meta programming, other methods to grab table name, column name, and the values that needs to be inserted into:

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    # binding.pry
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def table_name_for_insert
    self.class.table_name
  end
  
  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end


  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end
  

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

end



