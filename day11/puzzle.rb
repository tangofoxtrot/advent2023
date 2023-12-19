input_file_name = ARGV[0]
raw_data = File.read(input_file_name)
lines = raw_data.split("\n")

require 'pry'

EMPTY_SPACE = "."
SPACE_MULTIPLIER = 1000000 - 1

rows = lines.map(&:chars)

adjusted_x_index = 0
adjusted_y_index = 0
adjusted_x_map = {}
adjusted_y_map = {}

rows.each_with_index do |row, y_index|
  adjusted_y_map[y_index] = adjusted_y_index
  adjusted_y_index += 1
  if row.all? {|x| x == EMPTY_SPACE }
    adjusted_y_index += SPACE_MULTIPLIER
  end
end

0.upto(rows.first.length).each do |x_index|
  adjusted_x_map[x_index] = adjusted_x_index
  col_chars = rows.map {|x| x[x_index] }
  adjusted_x_index += 1
  if col_chars.all? {|x| x == EMPTY_SPACE }
    adjusted_x_index += SPACE_MULTIPLIER
  end
end

class Galaxy
  attr_reader :x, :y, :number
  def initialize(number:, x:, y:)
    @number = number
    @x = x
    @y = y
    @distances = {}
  end

  def store_distance(other)
    new_x = [x, other.x].max - [x, other.x].min
    new_y = [y, other.y].max - [y, other.y].min
    @distances[other] = new_x + new_y
  end

  def sum_distances
    @distances.values.sum
  end
end

class Universe
  attr_reader :galaxies

  def initialize
    @galaxies = []
  end

  def add_galaxy(x:, y:)
    galaxy = Galaxy.new(x:, y:, number: galaxies.count + 1)
    galaxies.each do |other_galaxy|
      other_galaxy.store_distance(galaxy)
    end
    galaxies << galaxy
  end

  def sum_distances
    galaxies.sum(&:sum_distances)
  end
end

universe = Universe.new

rows.each_with_index do |row, y|
  row.each_with_index do |char, x|
    if char != EMPTY_SPACE
      new_x = adjusted_x_map[x]
      new_y = adjusted_y_map[y]
      universe.add_galaxy(x: new_x, y: new_y)
    end
  end
end

puts "Puzzle1 #{universe.sum_distances}"
