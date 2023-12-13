input_file_name = ARGV[0]
raw_data = File.read(input_file_name)
lines = raw_data.split("\n")

REG = /(-?\d+)/

def process_line(line_data)
  return if line_data.last.all? {|x| x == 0 }
  new_data = line_data.last.each_cons(2).map {|l,r| r - l }
  line_data << new_data
  process_line(line_data)
end

def pretty_print(line_data)
  line_data.each do |d|
    puts d.inspect
  end
end

def append_new_data(line_data)
  return if line_data.length == 1
  line_data.reverse.each_cons(2) do |bottom_line, top_line|
    bottom_val = bottom_line.last
    top_val = top_line.last
    top_line << top_val + bottom_val
  end
end

def prepend_new_data(line_data)
  return if line_data.length == 1
  line_data.reverse.each_cons(2) do |bottom_line, top_line|
    bottom_val = bottom_line.first
    top_val = top_line.first
    top_line.unshift(top_val - bottom_val)
  end
end

values = lines.map do |line|
  line_data = [line.scan(REG).flatten.map(&:to_i)]
  process_line(line_data)
  append_new_data(line_data)
  line_data
end

puzzle1 = values.map do |line_data|
  line_data.first.last
end.sum

puts "Puzzle1: #{puzzle1}"

values = lines.map do |line|
  line_data = [line.scan(REG).flatten.map(&:to_i)]
  process_line(line_data)
  prepend_new_data(line_data)
  line_data
end

puzzle2 = values.map do |line_data|
  pretty_print(line_data)
  line_data.first.first
end.sum

puts "Puzzle2: #{puzzle2}"
