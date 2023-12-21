input_file_name = ARGV[0]
raw_data = File.read(input_file_name)
lines = raw_data.split("\n")

require 'pry'

class Dish
  ROUND_ROCK = "O"
  CUBE_ROCK = "#"
  EMPTY = "."

  DIRECTIONS = %w{N W S E}

  attr_reader :rows

  def initialize
    @rows = []
  end

  def tilt(direction="N")
    collection = case direction
    when "N"
      @columns = tilt_collection(columns)
      @rows = recompute_rows(columns)
    when "W"
      @rows = tilt_collection(rows)
      @columns = recompute_columns(rows)
    when "S"
      @columns = tilt_collection(columns.map(&:reverse)).map(&:reverse)
      @rows = recompute_rows(columns)
    when "E" then rows.reverse
      @rows = tilt_collection(rows.reverse.map(&:reverse)).reverse.map(&:reverse)
      @columns = recompute_columns(rows)
    end
  end

  def columns
    @columns ||= recompute_columns(rows)
  end

  def reset_columns!
    @column = nil
  end

  def recompute_columns(rs)
    0.upto(rs.first.length - 1).map {|n| rs.map {|x| x[n] } }
  end

  def recompute_rows(cols)
    0.upto(cols.length - 1).map {|n| cols.map {|x| x[n] } }
  end

  def to_s
    rows.map(&:join).join("\n")
  end

  def compute_load
    max_value = columns.first.length
    value = 0
    columns.each do |col|
      col.each_with_index do |char, index|
        case char
        when ROUND_ROCK
          value += (max_value - index)
        end
      end
    end
    value
  end

  def tilt_collection(collection)
    collection.map do |x|
      new_collection = []
      x.each do |char|
        case char
        when ROUND_ROCK
          roll_rock(new_collection)
        else
          new_collection << char
        end
      end
      new_collection
    end
  end

  def roll_rock(collection)
    new_index = collection.length
    original_length = new_index
    if new_index == 0
      collection[new_index] = ROUND_ROCK
      return
    end
    (collection.length - 1).downto(0).each do |possible_index|
      case  collection[possible_index]
      when ROUND_ROCK, CUBE_ROCK
        break
      when EMPTY
        new_index = possible_index
      end
    end
    collection[new_index] = ROUND_ROCK
    if new_index != original_length
      collection[original_length] = EMPTY
    end
  end
end

dish = Dish.new
lines.each do |line|
  dish.rows << line.chars
end

dish.tilt

puts "Puzzle1 #{dish.compute_load}"

dish = Dish.new
lines.each do |line|
  dish.rows << line.chars
end

cycle_count = 1_000_000_000
cycle_start = 0
maps = [dish.rows]
cycle_count.times do |n|
  Dish::DIRECTIONS.each do |dir|
    dish.tilt(dir)
  end
  idx = maps.index(dish.rows)
  if !idx.nil?
    cycle_start = idx
    break
  end
  maps << dish.rows
end

thing = maps[cycle_start + ((cycle_count - cycle_start) % (maps.size - cycle_start))]

new_dish = Dish.new
thing.each do |line|
  new_dish.rows << line
end


puts "Puzzle2 #{new_dish.compute_load}"
