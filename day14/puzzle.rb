input_file_name = ARGV[0]
raw_data = File.read(input_file_name)
lines = raw_data.split("\n")

require 'pry'

class Dish
  ROUND_ROCK = "O"
  CUBE_ROCK = "#"
  EMPTY = "."

  attr_reader :rows, :tilted_rows, :tilted_columns

  def initialize
    @rows = []
    @tilted_rows = []
  end

  def tilt
    @tilted_rows = []
    new_columns = columns.map do |column|
      tilt_column(column)
    end
    @tilted_columns = new_columns
    @tilted_rows = 0.upto(new_columns.length - 1).map {|n| new_columns.map {|x| x[n] } }
  end

  def columns
    @columns ||= 0.upto(rows.first.length - 1).map {|n| rows.map {|x| x[n] } }
  end

  def compute_load
    max_value = tilted_columns.first.length
    value = 0
    tilted_columns.each do |col|
      col.each_with_index do |char, index|
        case char
        when ROUND_ROCK
          value += (max_value - index)
        end
      end
    end
    value
  end

  def tilt_column(column)
    new_col = []
    column.each_with_index do |char, index|
      case char
      when ROUND_ROCK
        roll_rock(new_col)
      else
        new_col << char
      end
    end
    new_col
  end

  def roll_rock(new_col)
    new_index = new_col.length
    original_length = new_index
    if new_index == 0
      new_col[new_index] = ROUND_ROCK
      return
    end
    (new_col.length - 1).downto(0).each do |possible_index|
      case  new_col[possible_index]
      when ROUND_ROCK, CUBE_ROCK
        break
      when EMPTY
        new_index = possible_index
      end
    end
    new_col[new_index] = ROUND_ROCK
    if new_index != original_length
      new_col[original_length] = EMPTY
    end
  end
end

dish = Dish.new
lines.each do |line|
  dish.rows << line.chars
end

dish.tilt

dish.tilted_rows.each do |row|
  puts row.join
end
puts "Puzzle1 #{dish.compute_load}"
