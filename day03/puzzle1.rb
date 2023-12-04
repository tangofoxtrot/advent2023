input_file_name = ARGV[0]
raw_data = File.read(input_file_name)
lines = raw_data.split("\n")

MAX_COLS = lines.first.length
MAX_ROWS = lines.length

class NumberSequence
  attr_reader :number, :row, :col_start, :col_end
  def initialize(number:, row:, col:)
    @number = number
    @row = row
    @col_start = col
    @col_end = col
  end

  def add(new_number)
    @number += new_number
    @col_end += 1
  end

  def value
    number.to_i
  end

  def has_matching_symbol?(symbols)
    row_range = (top_boundary..bottom_boundary)
    col_range = (left_boundary..right_boundary)
    Array(symbols).any? do |symbol|
      row_range.include?(symbol.row) &&
      col_range.include?(symbol.col)
    end
  end

  private

  def left_boundary
    if col_start == 0
      col_start
    else
      col_start - 1
    end
  end

  def top_boundary
    if row == 0
      row
    else
      row - 1
    end
  end

  def bottom_boundary
    if row == (MAX_ROWS - 1)
      row
    else
      row + 1
    end
  end

  def right_boundary
    if col_end == (MAX_COLS - 1)
      col_end
    else
      col_end + 1
    end
  end

end

class SymbolChar
  attr_reader :char, :row, :col
  def initialize(char:, row:, col:)
    @char = char
    @row = row
    @col = col
  end

  def add(new_number)
    number += new_number
    col_end += 1
  end
end

numbers = []
symbols = []
lines.each_with_index do |line, row_number|
  current_number = nil
  line.chars.each_with_index do |char, col_number|
    case char
    when /\d/
      if current_number.nil?
        current_number = NumberSequence.new(number: char, row: row_number, col: col_number)
        numbers << current_number
      else
        current_number.add(char)
      end
    when "."
      if !current_number.nil?
        current_number = nil
      end
    else
      if !current_number.nil?
        current_number = nil
      end
      symbols << SymbolChar.new(char: char, row: row_number, col: col_number)
    end
  end
end


puts "Puzzle1: #{numbers.select {|n| n.has_matching_symbol?(symbols) }.map(&:value).sum}"

gears = symbols.select {|x| x.char == "*" }
gear_ratios = []
gears.each do |gear|
  matching = []
  numbers.each do |number|
    if number.has_matching_symbol?(gear)
      matching << number
    end
    if matching.count > 2
      break
    end
  end
  if matching.count == 2
    gear_ratios << matching.map(&:value).inject(:*)
  end
end


puts "Puzzle2: #{gear_ratios.sum}"


