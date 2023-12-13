input_file_name = ARGV[0]
raw_data = File.read(input_file_name)
lines = raw_data.split("\n")

LINE_REGEX = /^(?<node>\w+) = \((?<l>\w+), (?<r>\w+)\)/

instructions = lines.shift
lines.shift

nodes = Hash.new {|h,k| h[k] = {name: k} }
nodes["ZZZ"][:done] = true

lines.each do |line|
  match = line.match(LINE_REGEX)
  node = match[:node]
  l = match[:l]
  r = match[:r]
  l_node = nodes[l]
  r_node = nodes[r]
  node_node = nodes[node]
  node_node["L"] = l_node
  node_node["R"] = r_node
end

step_count = 0

current_node = nodes["AAA"]

enum = instructions.chars.to_enum
loop do
  begin
    char = enum.next
    step_count += 1
    current_node = current_node[char]
    if current_node[:done]
      break
    end
  rescue StopIteration
    enum.rewind
  end
end

puts "Puzzle1 #{step_count}"

node_positions = nodes.values.select {|x| x[:name].end_with?("A") }

puzzle2 = node_positions.map do |node|
  step_count = 0
  current_node = node
  enum = instructions.chars.to_enum
  loop do
    begin
      char = enum.next
      step_count += 1
      current_node = current_node[char]
      if current_node[:name].end_with?("Z")
        break
      end
    rescue StopIteration
      enum.rewind
    end
  end
  step_count
end.inject(&:lcm)

puts "Puzzle2 #{puzzle2}"
