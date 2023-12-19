input_file_name = ARGV[0]
raw_data = File.read(input_file_name)
lines = raw_data.split("\n")
MAX_Y = lines.length
MAX_X = lines.first.length

require 'pry'

Movement = Struct.new(:direction)

$count = 0
$current_direction = nil
class CharMovement
  attr_reader :direction_changes
  def initialize
    @direction_changes = {}
  end

  def has_to_dir?(dir)
    direction_changes.has_key?(dir)
  end

  def add(from:, to: nil, change:)
    to = to || from
    direction_changes[from] = {from: from, to: to, change: change}
    self
  end

  def move(from_direction:)
    changes = direction_changes[from_direction]
    return if changes.nil?
    Movement.new(changes[:to])
  end
end


CHARS = {
  "|" => CharMovement.new.add(from: "N", change: [0,-1]).add(from: "S", change: [0,1]),
  "-" => CharMovement.new.add(from: "E", change: [1, 0]).add(from: "W", change: [-1,0]),
  "L" => CharMovement.new.add(from: "S", to: "E", change: [1, 0]).add(from: "W", to: "N", change: [0,-1]),
  "J" => CharMovement.new.add(from: "E", to: "N", change: [-1, 0]).add(from: "S", to: "W", change: [0,-1]),
  "F" => CharMovement.new.add(from: "N", to: "E", change: [1, 0]).add(from: "W", to: "S", change: [0,1]),
  "7" => CharMovement.new.add(from: "E", to: "S", change: [-1, 0]).add(from: "N", to: "W", change: [0,1]),
}

DeadEndError = Class.new(StandardError)
Done = Class.new(StandardError)

class Progress
  attr_accessor :current_point, :visited_points
  attr_reader :points

  def initialize(points:)
    @points = points
    @visited_points = []
  end

  def move(direction)
    neighbor_point = neighbor(direction)
    if visited_points.include?(neighbor_point)
      raise Done.new("Found the end: #{visited_points.count / 2}")
    else
      self.current_point = neighbor_point
      visited_points << neighbor_point
      char_movement = CHARS[neighbor_point.char]
      new_movement = char_movement.move(from_direction: direction)
      if new_movement.nil?
        raise DeadEndError.new("Found dead end with char: #{neighbor_point.char} and direction #{direction}")
      end
      $current_direction = new_movement.direction
    end
  end

  def start_directions
    points = {
      "N" => north_point,
      "S" => south_point,
      "E" => east_point,
      "W" => west_point,
    }
    points.delete_if {|d, p| p.nil? || p.char == "." }.keys
  end

  def reset
    self.current_point = points.detect {|x| x.char == "S" }
    self.visited_points = [current_point]
  end

  def find_point(coordinates)
    points.detect {|x| x.coordinates == coordinates }
  end

  def neighbor(direction)
    case direction
    when "N" then north_point
    when "E" then east_point
    when "S" then south_point
    when "W" then west_point
    end
  end

  def west_point
    coordinates = current_point.west
    return if coordinates.nil?
    points.detect {|x| x.coordinates == coordinates }
  end

  def east_point
    coordinates = current_point.east
    return if coordinates.nil?
    points.detect {|x| x.coordinates == coordinates }
  end

  def north_point
    coordinates = current_point.north
    return if coordinates.nil?
    points.detect {|x| x.coordinates == coordinates }
  end

  def south_point
    coordinates = current_point.south
    return if coordinates.nil?
    points.detect {|x| x.coordinates == coordinates }
  end
end

class Point
  attr_reader :x, :y, :char
  def initialize(x:, y:, char:)
    @x = x
    @y = y
    @char = char
  end

  def to_s
    "(#{x}, #{y}) #{char}"
  end

  def coordinates
    [x,y]
  end

  def north
    return nil if y == 0
    [x, y - 1]
  end

  def coordinates_to_north_boundary
    return [] unless north
    y.downto(0).map {|n| [x, n] }
  end

  def west
    return nil if x == 0
    [x - 1, y]
  end

  def coordinates_to_west_boundary
    return [] unless west
    x.downto(0).map {|n| [n, y] }
  end

  def east
    return nil if x == MAX_X
    [x + 1, y]
  end

  def coordinates_to_east_boundary
    return [] unless east
    x.upto(MAX_X).map {|n| [n, y] }
  end

  def south
    return nil if y == MAX_Y
    [x, y + 1]
  end

  def coordinates_to_south_boundary
    return [] unless south
    y.upto(MAX_Y).map {|n| [x, n] }
  end

end


points = []
lines.each_with_index do |line, y|
  line.chars.each_with_index do |char, x|
    points << Point.new(x: x, y: y, char: char)
  end
end

progress = Progress.new(points: points)

begin
  progress.reset
  progress.start_directions.each do |dir|
    begin
      $current_direction = dir
      progress.move($current_direction)
      loop do
        progress.move($current_direction)
      end
    rescue DeadEndError
      progress.reset
      next
    end
  end
rescue Done => e
  puts e.message
end

inside_count = 0

def count_points_to_boundaries(progress, point)
  all_odd = [:north, :south, :east, :west].any? do |dir|
    coords = point.send("coordinates_to_#{dir}_boundary")
    binding.pry if point.coordinates[1] == 6 && point.coordinates[0] == 6
    if coords.length == 0
      false
    else
      progress.visited_points.select {|x| coords.include?(x.coordinates) }.length.odd?
    end
  end
  all_odd
end

points.each_slice(MAX_X).each do |row|
  data = row.map do |point|
    if point.char == "."
      if count_points_to_boundaries(progress, point)
        inside_count += 1
      end
    end
    if progress.visited_points.include?(point)
      "X"
    else
      "."
    end
  end
  puts data.join
end


puts "Puzzle2: #{inside_count}"
