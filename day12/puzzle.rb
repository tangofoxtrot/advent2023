input_file_name = ARGV[0]
raw_data = File.read(input_file_name)
lines = raw_data.split("\n")

require 'pry'

OPERATIONAL = "."
DAMAGED = "#"
UNKNOWN = "?"

counts = 0
lines.each_with_index do |line, line_index|
  puts "line: #{line_index}"
  springs, damaged_counts = line.split(" ")
  chars = springs.chars
  damaged_counts = damaged_counts.split(",").map(&:to_i)
  unknowns = chars.each_with_index.filter_map {|char, index| index if char == UNKNOWN }
  unknown_count = unknowns.count
  bin_numbers =  (0..2**unknown_count-1).map { |i| "%0#{unknown_count}b" % i }
  matches = []

  bin_numbers.each do |combo|
    new_chars = combo.gsub(/[01]/, '0' => OPERATIONAL, "1" => DAMAGED).chars
    unknowns.each_with_index do |absolute_index, index|
      chars[absolute_index] = new_chars[index]
    end
    damaged_groups = chars.chunk {|x| x }.select {|char, group| char == DAMAGED }.map {|char, group| group.count }
    if damaged_counts == damaged_groups
      matches << chars.join
    end
  end
  counts += matches.uniq.count
end
puts "Puzzle1 #{counts}"
