require 'pry'

input_file_name = ARGV[0]
raw_data = File.read(input_file_name)
lines = raw_data.split("\n")
steps = lines.first.split(",")

def hash_step(step)
  current_value = 0
  step.chars.each do |char|
    this_value = char.ord
    current_value += this_value
    current_value = current_value * 17
    current_value = current_value % 256
  end
  current_value
end

values = []
steps.each do |step|
  values << hash_step(step)
end

puts "Puzzle1 #{values.sum}"

boxes = Hash.new {|h,k| h[k] = {} }
0.upto(255).each do |n|
  boxes[n]
end

reg = /^(?<label>\w+)(?<operator>=|-)(?<count>\d+)?$/
steps.each do |step|
  match = step.match(reg)
  label = match[:label]
  operator = match[:operator]
  count = match[:count]
  box_number = hash_step(label)
  case operator
  when "-"
    boxes[box_number].delete(label)
  when "="
    boxes[box_number][label] = count
  end
end

total = boxes.map do |number, lens|
  number = number.to_i + 1
  lens.keys.each_with_index.map do |label, index|
    slot = index + 1
    focal = lens[label]
    number * slot * focal.to_i
  end
end.flatten.sum

puts "Puzzle2 #{total}"
