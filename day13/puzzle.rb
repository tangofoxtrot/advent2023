input_file_name = ARGV[0]
raw_data = File.read(input_file_name)
lines = raw_data.split("\n")

require 'pry'
MAP = {"." => "#", "#" => "."}

class Frame
  attr_reader :rows, :reflection_dir, :reflection_point, :reflection_set

  def initialize
    @rows = []
    @reflection_dir = nil
    @reflection_set = nil
  end

  def find_vertical_reflection(mutate:)
    vert_match = vertical_reflection_indices.detect do |col_index_set|
      pre_condition = if mutate
                       if reflection_dir == "vertical"
                         col_index_set != reflection_set
                       else
                         true
                       end
                     else
                       true
                     end
      pre_condition && col_index_set.all? do |col_set_index|
        columns[col_set_index[0]] == columns[col_set_index[1]]
      end
    end

    if vert_match
      @reflection_dir = "vertical"
      @reflection_point = vert_match.last.first + 1
      @reflection_set = vert_match
      if mutate
        throw :match_found
      end
    end
  end

  def find_horizonal_reflection(mutate:)
    horz_match = horizontal_reflection_indices.detect do |row_index_set|
      pre_condition = if mutate
                       if reflection_dir == "horizontal"
                         row_index_set != reflection_set
                       else
                         true
                       end
                     else
                       true
                     end
      pre_condition && row_index_set.all? do |row_set_index|
        rows[row_set_index[0]] == rows[row_set_index[1]]
      end
    end

    if horz_match
      @reflection_dir = "horizontal"
      @reflection_point = horz_match.last.first + 1
      @reflection_set = horz_match
      if mutate
        throw :match_found
      end
      return
    end
  end

  def find_reflection_point(mutate: false)
    find_vertical_reflection(mutate:)
    find_horizonal_reflection(mutate:)
  end

  def mutate_and_find
    catch(:match_found) do
      rows.each do |row|
        row.each do |char|
          orig_set = reflection_set
          orig_dir = reflection_dir
          char.replace(MAP[char])
          find_reflection_point(mutate: true)
          char.replace(MAP[char])
        end
      end
    end
  end

  def to_s
    rows.map(&:join).join("\n")
  end

  def value
    case reflection_dir
    when "vertical"
      reflection_point
    when "horizontal"
      reflection_point * 100
    end
  end

  def columns
    @columns ||= 0.upto(max_width - 1).map {|n| rows.map {|x| x[n] } }
  end

  def vertical_reflection_indices # if the reflection point is between 2 and 3 the matching set would be [[2,3],[1,4]]
    0.upto(max_width - 2).map do |n| #2,3,4
      n.downto(0).filter_map do |offset| # 2,1,0 3,2,1,0, 4,3,2,1,0
        left_side = n - offset
        right_side = n + 1 + offset
        if left_side < 0 || right_side > (max_width - 1)
          next
        end
        [left_side, right_side]
      end
    end
  end

  def horizontal_reflection_indices
    0.upto(max_height - 2).map do |n| #2,3,4
      n.downto(0).filter_map do |offset| # 2,1,0 3,2,1,0, 4,3,2,1,0
        top_side = n - offset
        bottom_side = n + 1 + offset
        if top_side < 0 || bottom_side > (max_height - 1)
          next
        end
        [top_side, bottom_side]
      end
    end
  end

  def max_width
    @rows.first.length
  end

  def max_height
    @rows.length
  end
end

frames = []
current_frame = Frame.new
frames << current_frame

lines.each do |line|
  if line.empty?
    current_frame = Frame.new
    frames << current_frame
    next
  else
    current_frame.rows << line.chars
  end
end


frames.each(&:find_reflection_point)
puts "Puzzle1 #{frames.map(&:value).sum}"
frames.each(&:mutate_and_find)
puts "Puzzle2 #{frames.map(&:value).sum}"
