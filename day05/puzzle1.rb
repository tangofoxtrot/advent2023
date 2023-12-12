input_file_name = ARGV[0]
raw_data = File.read(input_file_name)
lines = raw_data.split("\n")

SEEDS_REGEX = /^seeds:/
NEW_MAP_REGEX = /^([a-z-]+) map:/
MAP_ENTRY_REGEX = /(?<destination>\d+) (?<source>\d+) (?<length>\d+)/

class MapEntry
  attr_reader :source_start, :destination_start, :length, :destination_map, :range, :dest_range

  def initialize(source_start:, destination_start:, length:, destination_map:)
    @source_start = source_start
    @destination_start = destination_start
    @length = length
    @destination_map = destination_map
    @range = (source_start...(source_start + length))
    @dest_range = (destination_start...(destination_start + length))
  end

  def to_s
    "source: #{humanize_num(range)} -> #{humanize_num(dest_range)}"
  end

  def inspect
    "Entry: #{to_s}"
  end

  def humanize_num(val)
    if val.is_a?(Range)
      humanize_num(val.min) + " to " + humanize_num(val.max)
    else
      val.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
    end
  end

  def find(val)
    if destination_map.nil?
      return val
    end
    destination_map.find(dest_value(val))
  end

  def dest_value(val)
    destination_start + compute_offset(val)
  end

  def in_range?(val)
    range.include?(val)
  end

  def ranges_overlap?(other_range)
    range.min <= other_range.max && other_range.min <= range.max
  end

  def construct_new_destination_ranges(source)
    new_ranges = []
    if source.min < range.min
      new_min = source.min
      new_max = range.min
      new_range = (new_min...new_max)
      new_ranges << new_range
    end
    if source.max > range.max
      diff = source.max - range.max
      new_min = dest_range.max + 1
      new_max = new_min + diff
      blah = (new_min...new_max)
      new_ranges << blah
    end

    new_min = [source.min, range.min].max
    new_max = [source.max, range.max].min
    new_min_offset = compute_offset(new_min)
    new_max_offset = compute_offset(new_max)
    destination_min = destination_start + new_min_offset
    destination_max = destination_start + new_max_offset + 1
    new_dest_range = (destination_min...destination_max)
    new_ranges << new_dest_range
    new_ranges
  end

  def compute_offset(val)
    val - source_start
  end

end

class Map
  attr_reader :name, :entries
  attr_accessor :destination_map
  def initialize(name:)
    @name = name
    @entries = []
  end

  def to_chain
    if destination_map
      "#{name} -> #{destination_map.to_chain}"
    else
      "#{name}"
    end
  end

  def find(val)
    match = entries.detect {|x| x.in_range?(val) }
    if match
      match.find(val)
    else
      if destination_map
        destination_map.find(val)
      else
        val
      end
    end
  end

  def destination_ranges(source_range)
    new_ranges = []
    entries.each do |entry|
      if entry.ranges_overlap?(source_range)
        new_ranges << entry.construct_new_destination_ranges(source_range)
      end
    end
    new_ranges.flatten!
    if new_ranges.length == 0
      new_ranges << source_range
    end
    new_ranges
  end

  def add(destination:, source:, length:)
    entries << MapEntry.new(destination_start: destination, source_start: source, length: length, destination_map: destination_map)
  end
end

def process_seeds(line)
  @seeds.concat(line.split(":").last.split(" ").map(&:to_i))
end

def process_blank_line
  @current_map = nil
end

def process_new_map(map_name)
  source_name, destination_name  = map_name.split("-to-")
  source_map = @map_of_maps[source_name]
  destination_map = @map_of_maps[destination_name]
  puts "#{source_name} > #{destination_name}"
  source_map.destination_map = destination_map
  @current_map = source_map
end

def process_entries(line)
  match = line.match(MAP_ENTRY_REGEX)
  @current_map.add(source: match[:source].to_i, destination: match[:destination].to_i, length: match[:length].to_i)
end

@map_of_maps = Hash.new {|hsh, k| hsh[k] = Map.new(name: k) }
@seeds = []
@current_map = nil

lines.each do |line|
  case line
  when SEEDS_REGEX
    process_seeds(line)
  when NEW_MAP_REGEX
    process_new_map($1)
  when MAP_ENTRY_REGEX
    process_entries(line)
  when ""
    process_blank_line
  end
end

puts @map_of_maps['seed'].to_chain
@seeds_with_range = @seeds.each_slice(2).to_a.map do |start, length|
  (start...(start + length))
end

@map_of_maps['seed'].entries.each do |e|
  puts "seed: #{e}"
end

def humanize_num(val)
  if val.is_a?(Range)
    humanize_num(val.min) + " to " + humanize_num(val.max)
  else
    val.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
  end
end

def optimized_find(source_ranges, map)
  puts "Given: #{source_ranges} checking: #{map.name}"
  new_source_ranges = source_ranges.map do |source_range|
    map.destination_ranges(source_range)
  end.flatten.uniq
  if map.destination_map
    optimized_find(new_source_ranges, map.destination_map)
  else
    puts map.name
    new_source_ranges
  end
end

# Works for the sample but doesnt work for the input
#the_min =  optimized_find(@seeds_with_range, @map_of_maps['seed']).map(&:begin).min
#puts "Puzzle2: #{the_min}"

@lowest_val = nil

@seeds_with_range.each do |range|
  puts "starting range: #{humanize_num(range)}"
  range.each do |num|
    val = @map_of_maps['seed'].find(num)
    if @lowest_val.nil?
      @lowest_val = val
    elsif @lowest_val > val
      @lowest_val = val
    end
  end
end

puts "Brute force puzzle 2: #{@lowest_val}"
