require 'pry'
require 'set'

input_file_name = ARGV[0]
raw_data = File.read(input_file_name)
lines = raw_data.split("\n")
board = lines.map(&:chars)

MAX_WIDTH = board.first.length
MAX_HEIGHT = board.length
class Cursor
  attr_accessor :x, :y, :direction, :history
  def initialize(x:, y:,  direction:, history: nil)
    @x = x
    @y = y
    @direction = direction
    @history = history || Set.new
  end

  def off_map?
    @off_map
  end

  def position
    {x: x, y: y}
  end

  def change_north
    return if @off_map
    @direction = "N"
    self
  end

  def change_south
    return if @off_map
    @direction = "S"
    self
  end

  def change_west
    return if @off_map
    @direction = "W"
    self
  end

  def change_east
    return if @off_map
    @direction = "E"
    self
  end

  def move
    return if @off_map
    delta_x, delta_y = case direction
                 when "N"
                   [0, -1]
                 when "S"
                   [0, 1]
                 when "E"
                   [1, 0]
                 when "W"
                   [-1, 0]
                 end
    new_x = x + delta_x
    new_y = y + delta_y
    if new_x > (MAX_WIDTH - 1) || new_x < 0
      @off_map = true
      return
    end

    if new_y > (MAX_HEIGHT - 1) || new_y < 0
      @off_map = true
      return
    end

    self.x = new_x
    self.y = new_y
    foo = position.merge(dir: direction)
    if history.include?(foo)
      @off_map = true
    else
      history << foo
    end
    history
  end

end

def print_board(board, cursors)
  str = board.each_with_index.map do |row, y|
    row.each_with_index.map do |char, x|
      if cursors.reject(&:off_map?).any? {|c| c.position == [x,y] }
        "#"
      else
        char
      end
    end.join
  end.join("\n")
end

def print_energized_board(board, cursors)
  str = board.each_with_index.map do |row, y|
    row.each_with_index.map do |char, x|
      if cursors.any? {|c| c.energized.include?([x,y]) }
        "#"
      else
        char
      end
    end.join
  end.join("\n")
end

energized = Set.new
cursors = [Cursor.new(x: 0, y: 0, direction: "E")]
tile_map = {
  "." => lambda {|cursor| return [cursor] },
  "|" => lambda do |cursor|
    case cursor.direction
    when "N", "S"
      return [cursor]
    when "E", "W"
      new_cursor = Cursor.new(x: cursor.x, y: cursor.y, direction: "S", history: cursor.history)
      cursors << new_cursor
      return [cursor.change_north, new_cursor]
    end
  end,
  "-" => lambda do |cursor|
    case cursor.direction
    when "E", "W"
      [cursor]
    when "N", "S"
      new_cursor = Cursor.new(x: cursor.x, y: cursor.y, direction: "E", history: cursor.history)
      cursors << new_cursor
      cursor.change_west
      [cursor, new_cursor]
    end
  end,
  "/" => lambda do |cursor|
    case cursor.direction
    when "W"
      [cursor.change_south]
    when "E"
      [cursor.change_north]
    when "N"
      [cursor.change_east]
    when "S"
      [cursor.change_west]
    end
  end,
  "\\" => lambda do |cursor|
    case cursor.direction
    when "W"
      [cursor.change_north]
    when "E"
      [cursor.change_south]
    when "N"
      [cursor.change_west]
    when "S"
      [cursor.change_east]
    end
  end,
}

history = []
6000.times do |n|
  puts n
  last_char = nil
  cursors.reject(&:off_map?).each do |cursor|
    energized << cursor.position
    char = board[cursor.y][cursor.x]
    last_char = char
    tile = tile_map[char]
    tile.call(cursor).each(&:move)
  end
  #new_board = print_board(board, cursors)
  #history << new_board
end

#puts print_energized_board(board, cursors)
#history.each {|x| system("clear");puts(x);sleep(0.1) }; nil
#binding.pry
#puts cursors.map {|x| x.energized }.flatten(1).uniq.count
puts energized.length
